// SPDX-License-Identifier: PMPL-1.0-or-later
// Background service worker for DoubleTrack Browser

open Types

// State
let isRunningRef: ref<bool> = ref(false)

// Track fake tabs: tabId -> fakeTabInfo
let fakeTabsRef: ref<Js.Dict.t<fakeTabInfo>> = ref(Js.Dict.empty())

let maxConcurrentFakeTabs = 3

@val external setTimeout: (unit => unit, int) => int = "setTimeout"

let getNextMidnight = (): float => {
  let now = Js.Date.make()
  let tomorrow = Js.Date.makeWithYMD(
    ~year=Js.Date.getFullYear(now),
    ~month=Js.Date.getMonth(now),
    ~date=Js.Date.getDate(now) +. 1.0,
    (),
  )
  Js.Date.getTime(tomorrow)
}

let setupAlarms = () => {
  // Daily reset at midnight
  Chrome.Alarms.create(
    "daily-reset",
    {"when": getNextMidnight(), "periodInMinutes": 24.0 *. 60.0},
  )

  // Update profile age daily
  Chrome.Alarms.create("update-profile-age", {"periodInMinutes": 60.0 *. 24.0})
}

let activeFakeTabCount = (): int => {
  Js.Array2.length(Js.Dict.keys(fakeTabsRef.contents))
}

// Close a fake tab and clean up tracking
let closeFakeTab = async (tabId: int): unit => {
  Js.Dict.unsafeDeleteKey(. fakeTabsRef.contents, Belt.Int.toString(tabId))
  switch await Chrome.Tabs.remove(tabId) {
  | () => Js.Console.log2("DoubleTrack: Closed fake tab", tabId)
  | exception _exn => () // Tab may already be closed
  }
}

// Clean up stale fake tabs (open > 5 minutes)
let cleanupStaleFakeTabs = async (): unit => {
  let now = Js.Date.now()
  let staleThreshold = 5.0 *. 60.0 *. 1000.0 // 5 minutes in ms
  let keys = Js.Dict.keys(fakeTabsRef.contents)

  let _: unit = await Js.Array2.reduce(keys, async (accPromise, key) => {
    await accPromise
    switch Js.Dict.get(fakeTabsRef.contents, key) {
    | Some(info) if now -. info.openedAt > staleThreshold =>
      await closeFakeTab(info.tabId)
    | _ => ()
    }
  }, Js.Promise.resolve())
}

// Generate simulation parameters based on activity type and profile
let getSimulationParams = (activity: browsingActivity): simulationParams => {
  let baseScroll = switch activity.activityType {
  | Research => 0.8
  | News => 0.6
  | Shopping => 0.5
  | PageVisit => 0.7
  | Search => 0.3
  | VideoWatch => 0.2
  | SocialMedia => 0.4
  }

  let scrollJitter = Js.Math.random() *. 0.3 -. 0.15
  let scrollDepth = Js.Math.min_float(1.0, Js.Math.max_float(0.1, baseScroll +. scrollJitter))

  {
    scrollDepth,
    clickLinks: activity.activityType != Search && Js.Math.random() > 0.4,
    dwellSeconds: Js.Math.max_int(5, activity.durationSeconds / 3),
    fillForms: false,
  }
}

let rec simulateActivity = async (): unit => {
  let config = await Storage.getConfig()
  let profile = await Storage.getProfile()

  switch (config.enabled, profile) {
  | (true, Some(p)) =>
    // Don't open more tabs if at capacity
    if activeFakeTabCount() >= maxConcurrentFakeTabs {
      Js.Console.log("DoubleTrack: At max fake tab capacity, skipping")
      return
    }

    // Check schedule if enabled
    if config.respectSchedule {
      let _schedule = await Wasm.getActivitySchedule(p)
      // Schedule checking logic would go here
    }

    // Generate a single activity
    let activities = await Wasm.generateActivities(p, 0.25) // 15 minutes worth

    if Js.Array2.length(activities) > 0 {
      switch activities[0] {
      | Some(activity) =>
        // Record the activity in storage
        await Storage.addActivity(activity)

        // Open a real tab with the generated URL
        let tab = await Chrome.Tabs.create({"url": activity.url, "active": false})

        switch tab.id {
        | Some(tabId) =>
          // Track this fake tab
          let info: fakeTabInfo = {
            tabId,
            activity,
            openedAt: Js.Date.now(),
          }
          Js.Dict.set(fakeTabsRef.contents, Belt.Int.toString(tabId), info)

          Js.Console.log2("DoubleTrack: Opened fake tab", activity.url)

          // After a short delay for the page to load, send simulation command
          let params = getSimulationParams(activity)
          let _ = setTimeout(() => {
            let _ =
              Chrome.Tabs.sendMessage(
                tabId,
                Obj.magic({
                  "type": "SIMULATE_ACTIVITY",
                  "payload": Obj.magic(params),
                }),
              )
              ->Js.Promise.then_(_response => {
                // Schedule tab close after simulation duration
                let closeDelay = (params.dwellSeconds + 5) * 1000
                let _ = setTimeout(async () => {
                  await closeFakeTab(tabId)
                }, closeDelay)
                Js.Promise.resolve()
              }, _)
              ->Js.Promise.catch(_err => {
                // Content script may not be ready — close tab after dwell time anyway
                let _ = setTimeout(async () => {
                  await closeFakeTab(tabId)
                }, activity.durationSeconds * 1000)
                Js.Promise.resolve()
              }, _)
          }, 3000) // 3s page load grace period
        | None => Js.Console.error("DoubleTrack: Tab created but no ID returned")
        }
      | None => ()
      }
    }
  | _ => ()
  }
}

let handleAlarm = async (alarm: Chrome.Alarms.alarm): unit => {
  switch alarm.name {
  | "daily-reset" => await Storage.resetDailyStatistics()
  | "update-profile-age" => await Storage.updateProfileAge()
  | "simulate-activity" =>
    if isRunningRef.contents {
      await cleanupStaleFakeTabs()
      await simulateActivity()
    }
  | _ => ()
  }
}

let startSimulation = async (): unit => {
  if isRunningRef.contents {
    Js.Console.log("Simulation already running")
  } else {
    let config = await Storage.getConfig()
    let profile = await Storage.getProfile()

    switch profile {
    | None => Js.Console.error("No profile found, cannot start simulation")
    | Some(_) =>
      Js.Console.log("Starting activity simulation")
      isRunningRef.contents = true

      // Schedule periodic activity simulation
      let baseInterval = 15.0
      let interval = baseInterval /. config.noiseLevel

      Chrome.Alarms.create(
        "simulate-activity",
        {"periodInMinutes": Js.Math.max_float(5.0, interval)},
      )

      // Run initial simulation
      await simulateActivity()
    }
  }
}

let stopSimulation = async (): unit => {
  Js.Console.log("Stopping activity simulation")
  isRunningRef.contents = false
  Chrome.Alarms.clear("simulate-activity")

  // Close all fake tabs
  let keys = Js.Dict.keys(fakeTabsRef.contents)
  let _: unit = await Js.Array2.reduce(keys, async (accPromise, key) => {
    await accPromise
    switch Js.Dict.get(fakeTabsRef.contents, key) {
    | Some(info) => await closeFakeTab(info.tabId)
    | None => ()
    }
  }, Js.Promise.resolve())
}

let handleMessage = async (messageJson: Js.Json.t): Js.Json.t => {
  let message: message = Obj.magic(messageJson)

  switch message.messageType {
  | "GET_CONFIG" =>
    let config = await Storage.getConfig()
    Obj.magic(config)

  | "UPDATE_CONFIG" =>
    let config: extensionConfig = Obj.magic(message.payload)
    await Storage.setConfig(config)
    if config.enabled {
      await startSimulation()
    } else {
      await stopSimulation()
    }
    Obj.magic({"success": true})

  | "GENERATE_PROFILE" =>
    let seed: option<int> = Obj.magic(message.payload)
    let profile = await Wasm.generateProfile(seed)
    await Storage.setProfile(profile)
    await Storage.clearActivityHistory()
    Obj.magic(profile)

  | "GET_STATISTICS" =>
    let stats = await Storage.getStatistics()
    Obj.magic(stats)

  | "GET_CURRENT_PROFILE" =>
    let profile = await Storage.getProfile()
    Obj.magic(profile)

  | "SIMULATE_ACTIVITY" =>
    await simulateActivity()
    Obj.magic({"success": true})

  | "ACTIVITY_COMPLETE" =>
    // Content script finished simulation on a page
    Js.Console.log("DoubleTrack: Content script reported activity complete")
    Obj.magic({"acknowledged": true})

  | "CLEAR_HISTORY" =>
    await Storage.clearActivityHistory()
    Obj.magic({"success": true})

  | _ => Obj.magic({"error": `Unknown message type: ${message.messageType}`})
  }
}

let setupMessageListeners = () => {
  Chrome.Runtime.onMessageAddListener((message, _sender, sendResponse) => {
    let _ =
      handleMessage(message)
      ->Js.Promise.then_(response => {
        sendResponse(Obj.magic(response))
        Js.Promise.resolve()
      }, _)
      ->Js.Promise.catch(error => {
        Js.Console.error2("Error handling message:", error)
        sendResponse(Obj.magic({"error": "Internal error"}))
        Js.Promise.resolve()
      }, _)
    true // Return true to indicate async response
  })
}

let initialize = async (): unit => {
  Js.Console.log("DoubleTrack Browser: Initializing background service")

  // Initialize WASM module
  switch await Wasm.initialize() {
  | () => Js.Console.log("WASM core initialized successfully")
  | exception exn => Js.Console.error2("Failed to initialize WASM core:", exn)
  }

  // Set up message listeners
  setupMessageListeners()

  // Set up alarms for scheduled tasks
  setupAlarms()
  Chrome.Alarms.onAlarmAddListener(alarm => {
    let _ = handleAlarm(alarm)
  })

  // Listen for tab removal to clean up tracking
  Chrome.Tabs.OnRemoved.addListener(tabId => {
    Js.Dict.unsafeDeleteKey(. fakeTabsRef.contents, Belt.Int.toString(tabId))
  })

  // Load configuration and start if enabled
  let config = await Storage.getConfig()
  if config.enabled && Belt.Option.isSome(config.currentProfile) {
    await startSimulation()
  }

  Js.Console.log("DoubleTrack Browser: Background service initialized")
}

// Initialize the background service
let _ = initialize()
