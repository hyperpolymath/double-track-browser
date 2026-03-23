// SPDX-License-Identifier: PMPL-1.0-or-later
// Background service worker for DoubleTrack Browser

open Types

// State
let isRunningRef: ref<bool> = ref(false)

// Track fake tabs: tabId -> fakeTabInfo
let fakeTabsRef: ref<Dict.t<fakeTabInfo>> = ref(Dict.make())

let maxConcurrentFakeTabs = 3

@val external setTimeout: (unit => unit, int) => int = "setTimeout"

let getNextMidnight = (): float => {
  let now = Date.make()
  // Create tomorrow at midnight using raw JS since ReScript 12 Date API uses int args
  let tomorrow: Date.t = %raw(`
    (function(now) {
      var d = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
      return d;
    })
  `)(now)
  Date.getTime(tomorrow)
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
  Array.length(Dict.keysToArray(fakeTabsRef.contents))
}

// Close a fake tab and clean up tracking
let closeFakeTab = async (tabId: int): unit => {
  Dict.delete(fakeTabsRef.contents, Int.toString(tabId))
  switch await Chrome.Tabs.remove(tabId) {
  | () => Console.log2("DoubleTrack: Closed fake tab", tabId)
  | exception _exn => () // Tab may already be closed
  }
}

// Clean up stale fake tabs (open > 5 minutes)
let cleanupStaleFakeTabs = async (): unit => {
  let now = Date.now()
  let staleThreshold = 5.0 *. 60.0 *. 1000.0 // 5 minutes in ms
  let keys = Dict.keysToArray(fakeTabsRef.contents)

  let _: unit = await keys->Array.reduce(Promise.resolve(), async (accPromise, key) => {
    await accPromise
    switch Dict.get(fakeTabsRef.contents, key) {
    | Some(info) if now -. info.openedAt > staleThreshold =>
      await closeFakeTab(info.tabId)
    | _ => ()
    }
  })
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

  let scrollJitter = Math.random() *. 0.3 -. 0.15
  let scrollDepth = Math.min(1.0, Math.max(0.1, baseScroll +. scrollJitter))

  {
    scrollDepth,
    clickLinks: activity.activityType != Search && Math.random() > 0.4,
    dwellSeconds: Pervasives.max(5, activity.durationSeconds / 3),
    fillForms: false,
  }
}

let simulateActivity = async (): unit => {
  let config = await Storage.getConfig()
  let profile = await Storage.getProfile()

  switch (config.enabled, profile) {
  | (true, Some(p)) =>
    // Don't open more tabs if at capacity
    if activeFakeTabCount() >= maxConcurrentFakeTabs {
      Console.log("DoubleTrack: At max fake tab capacity, skipping")
    } else {

    // Check schedule if enabled
    if config.respectSchedule {
      let _schedule = await Wasm.getActivitySchedule(p)
      // Schedule checking logic would go here
    }

    // Generate a single activity
    let activities = await Wasm.generateActivities(p, 0.25) // 15 minutes worth

    if Array.length(activities) > 0 {
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
            openedAt: Date.now(),
          }
          Dict.set(fakeTabsRef.contents, Int.toString(tabId), info)

          Console.log2("DoubleTrack: Opened fake tab", activity.url)

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
              ->Promise.thenResolve(_response => {
                // Schedule tab close after simulation duration
                let closeDelay = (params.dwellSeconds + 5) * 1000
                let _ = setTimeout(() => {
                  closeFakeTab(tabId)->ignore
                }, closeDelay)
              })
              ->Promise.catch(_err => {
                // Content script may not be ready — close tab after dwell time anyway
                let _ = setTimeout(() => {
                  closeFakeTab(tabId)->ignore
                }, activity.durationSeconds * 1000)
                Promise.resolve()
              })
          }, 3000) // 3s page load grace period
        | None => Console.error("DoubleTrack: Tab created but no ID returned")
        }
      | None => ()
      }
    }
    } // end else (not at capacity)
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
    Console.log("Simulation already running")
  } else {
    let config = await Storage.getConfig()
    let profile = await Storage.getProfile()

    switch profile {
    | None => Console.error("No profile found, cannot start simulation")
    | Some(_) =>
      Console.log("Starting activity simulation")
      isRunningRef.contents = true

      // Schedule periodic activity simulation
      let baseInterval = 15.0
      let interval = baseInterval /. config.noiseLevel

      Chrome.Alarms.create(
        "simulate-activity",
        {"periodInMinutes": Math.max(5.0, interval)},
      )

      // Run initial simulation
      await simulateActivity()
    }
  }
}

let stopSimulation = async (): unit => {
  Console.log("Stopping activity simulation")
  isRunningRef.contents = false
  Chrome.Alarms.clear("simulate-activity")

  // Close all fake tabs
  let keys = Dict.keysToArray(fakeTabsRef.contents)
  let _: unit = await keys->Array.reduce(Promise.resolve(), async (accPromise, key) => {
    await accPromise
    switch Dict.get(fakeTabsRef.contents, key) {
    | Some(info) => await closeFakeTab(info.tabId)
    | None => ()
    }
  })
}

let handleMessage = async (messageJson: JSON.t): JSON.t => {
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
    Console.log("DoubleTrack: Content script reported activity complete")
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
      ->Promise.thenResolve(response => {
        sendResponse(Obj.magic(response))
      })
      ->Promise.catch(error => {
        Console.error2("Error handling message:", error)
        sendResponse(Obj.magic({"error": "Internal error"}))
        Promise.resolve()
      })
    true // Return true to indicate async response
  })
}

let initialize = async (): unit => {
  Console.log("DoubleTrack Browser: Initializing background service")

  // Initialize WASM module
  switch await Wasm.initialize() {
  | () => Console.log("WASM core initialized successfully")
  | exception exn => Console.error2("Failed to initialize WASM core:", exn)
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
    Dict.delete(fakeTabsRef.contents, Int.toString(tabId))
  })

  // Load configuration and start if enabled
  let config = await Storage.getConfig()
  if config.enabled && Option.isSome(config.currentProfile) {
    await startSimulation()
  }

  Console.log("DoubleTrack Browser: Background service initialized")
}

// Initialize the background service
let _ = initialize()
