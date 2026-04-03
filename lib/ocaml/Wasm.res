// SPDX-License-Identifier: PMPL-1.0-or-later
// WASM module wrapper for Rust core
// Loads compiled wasm-pack output with mock fallback

open Types

// Singleton state
// Use a concrete type to avoid polymorphic ref issues
type wasmModule
let wasmModuleRef: ref<option<wasmModule>> = ref(None)
let initializedRef: ref<bool> = ref(false)

// Dynamic import of the compiled WASM module
let importWasmModule: unit => promise<{..}> = %raw(`
  function() {
    // wasm-pack produces a JS glue file alongside the .wasm binary
    // In the built extension, it lives at wasm/doubletrack_core.js
    return import(chrome.runtime.getURL('wasm/doubletrack_core.js'))
      .then(function(mod) {
        // wasm-pack web target exports a default init function
        if (mod.default && typeof mod.default === 'function') {
          return mod.default().then(function() { return mod; });
        }
        return mod;
      });
  }
`)

let initialize = async (): unit => {
  if initializedRef.contents {
    ()
  } else {
    // Try loading real WASM module
    switch await importWasmModule() {
    | wasmModule =>
      wasmModuleRef := Some(Obj.magic(wasmModule))
      initializedRef := true
      Console.log("DoubleTrack: WASM core loaded successfully")
    | exception _exn =>
      Console.warn("DoubleTrack: WASM load failed, falling back to mock engine")
      initializedRef := true
    }
  }
}

let ensureInitialized = async (): unit => {
  if !initializedRef.contents {
    await initialize()
  }
}

// Call a WASM export if available, otherwise fall back to mock
let callWasm: (string, array<Obj.t>) => option<Obj.t> = (fnName, args) => {
  switch wasmModuleRef.contents {
  | Some(m) =>
    let fn: option<Obj.t> = %raw(`function(m, name) { return m[name]; }`)(Obj.magic(m), fnName)
    switch fn {
    | Some(f) =>
      let result: Obj.t = %raw(`function(f, args) { return f.apply(null, args); }`)(f, args)
      Some(result)
    | None => None
    }
  | None => None
  }
}

// --- Mock implementations (fallback when WASM is unavailable) ---

let mockGenerateProfile = (seed: option<int>): profile => {
  let timestamp = Date.now()
  let randStr = Math.random()->Float.toString
  let randPart = randStr->String.slice(~start=2, ~end=String.length(randStr))
  let id = `profile_${Float.toString(timestamp)}_${randPart}`

  let names = ["Alex Smith", "Jordan Johnson", "Taylor Williams", "Casey Brown", "Morgan Davis"]
  let nameIndex = switch seed {
  | Some(s) => mod(s, 5)
  | None => Float.toInt(Math.floor(Math.random() *. 5.0))
  }
  let name = names[nameIndex]->Option.getOr("Alex Smith")

  let allInterests: array<interestCategory> = [
    Technology,
    Gaming,
    Sports,
    Fitness,
    Cooking,
    Travel,
    Fashion,
    Music,
    Movies,
    Books,
    Art,
    Science,
    News,
    FinanceInterest,
    HomeImprovement,
    Photography,
    Programming,
    DataScience,
  ]

  // Pick 3-6 random interests
  let numInterests = 3 + Float.toInt(Math.floor(Math.random() *. 4.0))
  let shuffled = Array.copy(allInterests)
  // Fisher-Yates shuffle on first numInterests elements
  for i in 0 to numInterests - 1 {
    let j = i + Float.toInt(Math.floor(Math.random() *. Int.toFloat(Array.length(shuffled) - i)))
    let tmp = shuffled[i]->Option.getOrThrow(~message="shuffle source index")
    Array.setUnsafe(shuffled, i, shuffled[j]->Option.getOrThrow(~message="shuffle swap index"))
    Array.setUnsafe(shuffled, j, tmp)
  }
  let interests = Array.slice(shuffled, ~start=0, ~end=numInterests)

  let genders: array<gender> = [Male, Female, NonBinary, PreferNotToSay]
  let gender =
    genders[Float.toInt(Math.floor(Math.random() *. 4.0))]->Option.getOr(
      Male,
    )

  let locations: array<locationType> = [Urban, Suburban, Rural]
  let locationType =
    locations[Float.toInt(Math.floor(Math.random() *. 3.0))]->Option.getOr(
      Urban,
    )

  let styles: array<browsingStyle> = [Focused, Explorer, Researcher, Casual]
  let browsingStyle =
    styles[Float.toInt(Math.floor(Math.random() *. 4.0))]->Option.getOr(
      Explorer,
    )

  let levels: array<activityLevel> = [Low, Medium, High, VeryHigh]
  let activityLevel =
    levels[Float.toInt(Math.floor(Math.random() *. 4.0))]->Option.getOr(
      Medium,
    )

  {
    id,
    name,
    demographics: {
      age: 22 + Float.toInt(Math.floor(Math.random() *. 45.0)),
      gender,
      locationType,
      occupationCategory: Technology,
      educationLevel: Bachelor,
    },
    interests,
    browsingStyle,
    activityLevel,
    createdAt: Date.now() /. 1000.0,
  }
}

// Search queries and domains for mock activity generation
let mockSearchQueries: array<string> = [
  "best coffee shops nearby",
  "how to fix a leaky faucet",
  "latest smartphone reviews 2026",
  "healthy dinner recipes under 30 minutes",
  "vintage car restoration tips",
  "Slovenian poetry translations",
  "home espresso machine comparison",
  "weekend hiking trails",
  "beginner piano lessons online",
  "climate change research papers",
  "best board games for adults",
  "how to start a vegetable garden",
  "mechanical keyboard guide",
  "travel insurance comparison",
  "history of Japanese ceramics",
]

let mockDomains: array<string> = [
  "reddit.com",
  "stackoverflow.com",
  "medium.com",
  "theguardian.com",
  "arstechnica.com",
  "bbc.com",
  "allrecipes.com",
  "instructables.com",
  "wikipedia.org",
  "youtube.com",
  "nytimes.com",
  "bonappetit.com",
  "nature.com",
  "wired.com",
]

let mockGenerateActivities = (profile: profile, durationHours: float): array<browsingActivity> => {
  let baseTime = Date.now() /. 1000.0
  let activitiesCount = Pervasives.max(1, Float.toInt(durationHours *. 4.0))

  let activityTypes: array<activityType> = [
    Search,
    PageVisit,
    VideoWatch,
    Shopping,
    SocialMedia,
    News,
    Research,
  ]

  Array.fromInitializer(~length=activitiesCount, i => {
    let timestamp = baseTime +. Int.toFloat(i) *. 900.0 +. Math.random() *. 300.0

    let at =
      activityTypes[Float.toInt(
        Math.floor(Math.random() *. Int.toFloat(Array.length(activityTypes))),
      )]->Option.getOr(PageVisit)

    let queryIdx = Float.toInt(
      Math.floor(Math.random() *. Int.toFloat(Array.length(mockSearchQueries))),
    )
    let domainIdx = Float.toInt(
      Math.floor(Math.random() *. Int.toFloat(Array.length(mockDomains))),
    )

    let query = mockSearchQueries[queryIdx]->Option.getOr("latest news")
    let domain = mockDomains[domainIdx]->Option.getOr("example.com")

    let (url, title) = switch at {
    | Search => {
        let encoded = String.replaceRegExp(query, %re("/\\s+/g"), "+")
        (`https://www.google.com/search?q=${encoded}`, `${query} - Google Search`)
      }
    | VideoWatch => {
        let vidStr = Math.random()->Float.toString
        let vidId = vidStr->String.slice(~start=2, ~end=String.length(vidStr))->String.slice(~start=0, ~end=11)
        (
          `https://www.youtube.com/watch?v=${vidId}`,
          `Video: ${query}`,
        )
      }
    | _ => (`https://${domain}/${query->String.replaceRegExp(%re("/\\s+/g"), "-")->String.toLowerCase}`, `${query} | ${domain}`)
    }

    {
      activityType: at,
      url,
      title,
      durationSeconds: 30 + Float.toInt(Math.floor(Math.random() *. 240.0)),
      timestamp,
      interestCategory: profile.interests[Float.toInt(
        Math.floor(Math.random() *. Int.toFloat(Array.length(profile.interests))),
      )],
    }
  })
}

let mockGetSchedule = (_profile: profile): schedule => {
  {
    timePatterns: [],
    timezoneOffset: 0,
  }
}

// --- Public API ---

let generateProfile = async (seed: option<int>): profile => {
  await ensureInitialized()
  let seedArg: Obj.t = switch seed {
  | Some(s) => Obj.magic(s)
  | None => Obj.magic(Nullable.null)
  }

  switch callWasm("generate_profile", [seedArg]) {
  | Some(result) => Obj.magic(result)
  | None => mockGenerateProfile(seed)
  }
}

let generateActivities = async (profile: profile, durationHours: float): array<browsingActivity> => {
  await ensureInitialized()
  switch callWasm("generate_activities", [Obj.magic(profile), Obj.magic(durationHours)]) {
  | Some(result) => Obj.magic(result)
  | None => mockGenerateActivities(profile, durationHours)
  }
}

let validateProfile = async (profile: profile): bool => {
  await ensureInitialized()
  switch callWasm("validate_profile", [Obj.magic(profile)]) {
  | Some(result) => Obj.magic(result)
  | None =>
    profile.name != "" && Array.length(profile.interests) > 0 && profile.demographics.age >= 18
  }
}

let getActivitySchedule = async (profile: profile): schedule => {
  await ensureInitialized()
  switch callWasm("get_activity_schedule", [Obj.magic(profile)]) {
  | Some(result) => Obj.magic(result)
  | None => mockGetSchedule(profile)
  }
}
