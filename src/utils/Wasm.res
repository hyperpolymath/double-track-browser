// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// WASM module wrapper for Rust core

open Types

// Singleton state
let wasmRef: ref<option<{..}>> = ref(None)
let initializedRef: ref<bool> = ref(false)

let initialize = async (): unit => {
  if initializedRef.contents {
    ()
  } else {
    // In production, the WASM module would be loaded from the compiled output
    // For now, we create a placeholder
    Js.Console.log("WASM module initialization placeholder")
    initializedRef.contents = true
  }
}

let ensureInitialized = async (): unit => {
  if !initializedRef.contents {
    await initialize()
  }
}

// Mock profile generation (to be replaced with actual WASM call)
let mockGenerateProfile = (seed: option<int>): profile => {
  let timestamp = Js.Date.now()
  let randPart = Js.Math.random() |> Js.Float.toString |> Js.String2.sliceToEnd(~from=2)
  let id = `profile_${Belt.Float.toString(timestamp)}_${randPart}`

  let names = ["Alex Smith", "Jordan Johnson", "Taylor Williams"]
  let nameIndex = switch seed {
  | Some(s) => mod(s, 3)
  | None => Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 3.0))
  }
  let name = names[nameIndex]->Belt.Option.getWithDefault("Alex Smith")

  {
    id,
    name,
    demographics: {
      age: 25 + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 40.0)),
      gender: Male,
      locationType: Urban,
      occupationCategory: Technology,
      educationLevel: Bachelor,
    },
    interests: [Technology, Gaming, Programming],
    browsingStyle: Explorer,
    activityLevel: Medium,
    createdAt: Js.Date.now() /. 1000.0,
  }
}

// Mock activity generation
let mockGenerateActivities = (profile: profile, durationHours: float): array<browsingActivity> => {
  let baseTime = Js.Date.now() /. 1000.0
  let activitiesCount = Belt.Float.toInt(durationHours *. 4.0)

  Belt.Array.makeBy(activitiesCount, i => {
    let timestamp = baseTime +. Belt.Int.toFloat(i) *. 900.0

    {
      activityType: PageVisit,
      url: `https://example.com/page-${Belt.Int.toString(i)}`,
      title: `Example Page ${Belt.Int.toString(i)}`,
      durationSeconds: 60 + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 300.0)),
      timestamp,
      interestCategory: profile.interests[0],
    }
  })
}

// Mock schedule generation
let mockGetSchedule = (_profile: profile): schedule => {
  {
    timePatterns: [],
    timezoneOffset: 0,
  }
}

let generateProfile = async (seed: option<int>): profile => {
  await ensureInitialized()
  // In production: call WASM function
  mockGenerateProfile(seed)
}

let generateActivities = async (profile: profile, durationHours: float): array<browsingActivity> => {
  await ensureInitialized()
  // In production: call WASM function
  mockGenerateActivities(profile, durationHours)
}

let validateProfile = async (profile: profile): bool => {
  await ensureInitialized()
  profile.name != "" && Js.Array2.length(profile.interests) > 0 && profile.demographics.age >= 18
}

let getActivitySchedule = async (profile: profile): schedule => {
  await ensureInitialized()
  mockGetSchedule(profile)
}
