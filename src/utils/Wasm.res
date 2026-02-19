// SPDX-License-Identifier: PMPL-1.0-or-later
// WASM module wrapper for Rust core
// Loads compiled wasm-pack output with mock fallback

open Types

// Singleton state
let wasmModuleRef: ref<option<{..}>> = ref(None)
let initializedRef: ref<bool> = ref(false)

// Dynamic import of the compiled WASM module
let importWasmModule: unit => Js.Promise.t<{..}> = %raw(`
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
      wasmModuleRef := Some(wasmModule)
      initializedRef := true
      Js.Console.log("DoubleTrack: WASM core loaded successfully")
    | exception _exn =>
      Js.Console.warn("DoubleTrack: WASM load failed, falling back to mock engine")
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
let callWasm = (fnName: string, args: array<{..}>): option<{..}> => {
  switch wasmModuleRef.contents {
  | Some(m) =>
    let fn: option<{..}> = %raw(`function(m, name) { return m[name]; }`)(m, fnName)
    switch fn {
    | Some(f) =>
      let result: {..} = %raw(`function(f, args) { return f.apply(null, args); }`)(f, args)
      Some(result)
    | None => None
    }
  | None => None
  }
}

// --- Mock implementations (fallback when WASM is unavailable) ---

let mockGenerateProfile = (seed: option<int>): profile => {
  let timestamp = Js.Date.now()
  let randPart = Js.Math.random() |> Js.Float.toString |> Js.String2.sliceToEnd(~from=2)
  let id = `profile_${Belt.Float.toString(timestamp)}_${randPart}`

  let names = ["Alex Smith", "Jordan Johnson", "Taylor Williams", "Casey Brown", "Morgan Davis"]
  let nameIndex = switch seed {
  | Some(s) => mod(s, 5)
  | None => Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 5.0))
  }
  let name = names[nameIndex]->Belt.Option.getWithDefault("Alex Smith")

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
  let numInterests = 3 + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 4.0))
  let shuffled = Belt.Array.copy(allInterests)
  // Fisher-Yates shuffle on first numInterests elements
  for i in 0 to numInterests - 1 {
    let j = i + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. Belt.Int.toFloat(Js.Array2.length(shuffled) - i)))
    let tmp = shuffled[i]->Belt.Option.getExn
    Js.Array2.unsafe_set(shuffled, i, shuffled[j]->Belt.Option.getExn)
    Js.Array2.unsafe_set(shuffled, j, tmp)
  }
  let interests = Belt.Array.slice(shuffled, ~offset=0, ~len=numInterests)

  let genders: array<gender> = [Male, Female, NonBinary, PreferNotToSay]
  let gender =
    genders[Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 4.0))]->Belt.Option.getWithDefault(
      Male,
    )

  let locations: array<locationType> = [Urban, Suburban, Rural]
  let locationType =
    locations[Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 3.0))]->Belt.Option.getWithDefault(
      Urban,
    )

  let styles: array<browsingStyle> = [Focused, Explorer, Researcher, Casual]
  let browsingStyle =
    styles[Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 4.0))]->Belt.Option.getWithDefault(
      Explorer,
    )

  let levels: array<activityLevel> = [Low, Medium, High, VeryHigh]
  let activityLevel =
    levels[Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 4.0))]->Belt.Option.getWithDefault(
      Medium,
    )

  {
    id,
    name,
    demographics: {
      age: 22 + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 45.0)),
      gender,
      locationType,
      occupationCategory: Technology,
      educationLevel: Bachelor,
    },
    interests,
    browsingStyle,
    activityLevel,
    createdAt: Js.Date.now() /. 1000.0,
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
  let baseTime = Js.Date.now() /. 1000.0
  let activitiesCount = Js.Math.max_int(1, Belt.Float.toInt(durationHours *. 4.0))

  let activityTypes: array<activityType> = [
    Search,
    PageVisit,
    VideoWatch,
    Shopping,
    SocialMedia,
    News,
    Research,
  ]

  Belt.Array.makeBy(activitiesCount, i => {
    let timestamp = baseTime +. Belt.Int.toFloat(i) *. 900.0 +. Js.Math.random() *. 300.0

    let at =
      activityTypes[Belt.Float.toInt(
        Js.Math.floor(Js.Math.random() *. Belt.Int.toFloat(Js.Array2.length(activityTypes))),
      )]->Belt.Option.getWithDefault(PageVisit)

    let queryIdx = Belt.Float.toInt(
      Js.Math.floor(Js.Math.random() *. Belt.Int.toFloat(Js.Array2.length(mockSearchQueries))),
    )
    let domainIdx = Belt.Float.toInt(
      Js.Math.floor(Js.Math.random() *. Belt.Int.toFloat(Js.Array2.length(mockDomains))),
    )

    let query = mockSearchQueries[queryIdx]->Belt.Option.getWithDefault("latest news")
    let domain = mockDomains[domainIdx]->Belt.Option.getWithDefault("example.com")

    let (url, title) = switch at {
    | Search => {
        let encoded = Js.String2.replaceByRe(query, %re("/\\s+/g"), "+")
        (`https://www.google.com/search?q=${encoded}`, `${query} - Google Search`)
      }
    | VideoWatch => (
        `https://www.youtube.com/watch?v=${Js.Math.random()
          ->Js.Float.toString
          ->Js.String2.sliceToEnd(~from=2)
          ->Js.String2.slice(~from=0, ~to_=11)}`,
        `Video: ${query}`,
      )
    | _ => (`https://${domain}/${query->Js.String2.replaceByRe(%re("/\\s+/g"), "-")->Js.String2.toLowerCase}`, `${query} | ${domain}`)
    }

    {
      activityType: at,
      url,
      title,
      durationSeconds: 30 + Belt.Float.toInt(Js.Math.floor(Js.Math.random() *. 240.0)),
      timestamp,
      interestCategory: profile.interests[Belt.Float.toInt(
        Js.Math.floor(Js.Math.random() *. Belt.Int.toFloat(Js.Array2.length(profile.interests))),
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
  let seedArg: {..} = switch seed {
  | Some(s) => Obj.magic(s)
  | None => Obj.magic(Js.Nullable.null)
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
    profile.name != "" && Js.Array2.length(profile.interests) > 0 && profile.demographics.age >= 18
  }
}

let getActivitySchedule = async (profile: profile): schedule => {
  await ensureInitialized()
  switch callWasm("get_activity_schedule", [Obj.magic(profile)]) {
  | Some(result) => Obj.magic(result)
  | None => mockGetSchedule(profile)
  }
}
