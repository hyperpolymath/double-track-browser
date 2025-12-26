// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Background service worker for DoubleTrack Browser

open Types

// State
let isRunningRef: ref<bool> = ref(false)

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

let rec simulateActivity = async (): unit => {
  let config = await Storage.getConfig()
  let profile = await Storage.getProfile()

  switch (config.enabled, profile) {
  | (true, Some(p)) =>
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
        await Storage.addActivity(activity)
        Js.Console.log2("Simulated activity:", activity)
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

      Chrome.Alarms.create("simulate-activity", {"periodInMinutes": Js.Math.max_float(5.0, interval)})

      // Run initial simulation
      await simulateActivity()
    }
  }
}

let stopSimulation = async (): unit => {
  Js.Console.log("Stopping activity simulation")
  isRunningRef.contents = false
  Chrome.Alarms.clear("simulate-activity")
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

  // Load configuration and start if enabled
  let config = await Storage.getConfig()
  if config.enabled && Belt.Option.isSome(config.currentProfile) {
    await startSimulation()
  }

  Js.Console.log("DoubleTrack Browser: Background service initialized")
}

// Initialize the background service
let _ = initialize()
