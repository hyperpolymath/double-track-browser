// SPDX-License-Identifier: PMPL-1.0-or-later
// Storage utility for managing extension data

open Types

// JSON encoding/decoding helpers
external jsonParse: string => JSON.t = "JSON.parse"
external jsonStringify: 'a => string = "JSON.stringify"

let defaultConfig: extensionConfig = {
  enabled: false,
  currentProfile: None,
  noiseLevel: 0.5,
  respectSchedule: true,
  privacyMode: Moderate,
}

let defaultStatistics: unit => statistics = () => {
  totalActivities: 0,
  activitiesToday: 0,
  profileAgeDays: 0,
  lastActivity: None,
  activityByType: Dict.make(),
}

let getConfig = async (): extensionConfig => {
  let result = await Chrome.Storage.Local.get(StorageKey.config)
  switch Dict.get(result, StorageKey.config) {
  | Some(json) =>
    // In production, proper JSON decoding would be used
    Obj.magic(json)
  | None => defaultConfig
  }
}

let setConfig = async (config: extensionConfig): unit => {
  let dict = Dict.make()
  Dict.set(dict, StorageKey.config, Obj.magic(config))
  await Chrome.Storage.Local.set(dict)
}

let getProfile = async (): option<profile> => {
  let result = await Chrome.Storage.Local.get(StorageKey.profile)
  switch Dict.get(result, StorageKey.profile) {
  | Some(json) => Some(Obj.magic(json))
  | None => None
  }
}

let setProfile = async (profile: profile): unit => {
  let dict = Dict.make()
  Dict.set(dict, StorageKey.profile, Obj.magic(profile))
  await Chrome.Storage.Local.set(dict)
}

let getStatistics = async (): statistics => {
  let result = await Chrome.Storage.Local.get(StorageKey.statistics)
  switch Dict.get(result, StorageKey.statistics) {
  | Some(json) => Obj.magic(json)
  | None => defaultStatistics()
  }
}

let setStatistics = async (stats: statistics): unit => {
  let dict = Dict.make()
  Dict.set(dict, StorageKey.statistics, Obj.magic(stats))
  await Chrome.Storage.Local.set(dict)
}

let getActivityHistory = async (): array<browsingActivity> => {
  let result = await Chrome.Storage.Local.get(StorageKey.activityHistory)
  switch Dict.get(result, StorageKey.activityHistory) {
  | Some(json) => Obj.magic(json)
  | None => []
  }
}

let addActivity = async (activity: browsingActivity): unit => {
  let history = await getActivityHistory()
  let newHistory = Array.concat(history, [activity])
  // Keep only the last 1000 activities
  let trimmedHistory = if Array.length(newHistory) > 1000 {
    Array.slice(newHistory, ~start=Array.length(newHistory) - 1000, ~end=Array.length(newHistory))
  } else {
    newHistory
  }
  let dict = Dict.make()
  Dict.set(dict, StorageKey.activityHistory, Obj.magic(trimmedHistory))
  await Chrome.Storage.Local.set(dict)

  // Update statistics
  let stats = await getStatistics()
  stats.totalActivities = stats.totalActivities + 1
  stats.lastActivity = Some(activity.timestamp)

  // Update activities today
  let today = Date.make()
  let _: unit = %raw(`today.setHours(0, 0, 0, 0)`)
  let activityDate = Date.fromTime(activity.timestamp *. 1000.0)
  if Date.getTime(activityDate) >= Date.getTime(today) {
    stats.activitiesToday = stats.activitiesToday + 1
  }

  // Update activity by type
  let typeStr = activityTypeToString(activity.activityType)
  let currentCount = switch Dict.get(stats.activityByType, typeStr) {
  | Some(c) => c
  | None => 0
  }
  Dict.set(stats.activityByType, typeStr, currentCount + 1)

  await setStatistics(stats)
}

let clearActivityHistory = async (): unit => {
  let dict = Dict.make()
  Dict.set(dict, StorageKey.activityHistory, Obj.magic([]))
  await Chrome.Storage.Local.set(dict)
  await setStatistics(defaultStatistics())
}

let resetDailyStatistics = async (): unit => {
  let stats = await getStatistics()
  stats.activitiesToday = 0
  await setStatistics(stats)
}

let updateProfileAge = async (): unit => {
  let profile = await getProfile()
  switch profile {
  | Some(p) =>
    let stats = await getStatistics()
    let now = Date.now() /. 1000.0
    let ageSeconds = now -. p.createdAt
    stats.profileAgeDays = Float.toInt(ageSeconds /. 86400.0)
    await setStatistics(stats)
  | None => ()
  }
}
