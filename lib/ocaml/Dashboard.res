// SPDX-License-Identifier: PMPL-1.0-or-later
// Dashboard page for activity analytics and visualization

open Types
open DomBindings

// State
let activitiesRef: ref<array<browsingActivity>> = ref([])
let profileRef: ref<option<profile>> = ref(None)
let statsRef: ref<option<statistics>> = ref(None)

let loadData = async (): unit => {
  let keys = [StorageKey.activityHistory, StorageKey.profile, StorageKey.statistics]
  let result = await Chrome.Storage.Local.getMultiple(keys)

  activitiesRef.contents =
    Dict.get(result, StorageKey.activityHistory)
    ->Option.map(Obj.magic)
    ->Option.getOr([])

  profileRef.contents = Dict.get(result, StorageKey.profile)->Option.map(Obj.magic)

  statsRef.contents = Dict.get(result, StorageKey.statistics)->Option.map(Obj.magic)
}

let calculateStreak = (): int => {
  let activities = activitiesRef.contents
  if Array.length(activities) == 0 {
    0
  } else {
    let today = Date.make()
    let _: unit = %raw(`today.setHours(0, 0, 0, 0)`)

    let activityDates =
      activities->Array.map(a => {
        let date = Date.fromTime(a.timestamp *. 1000.0)
        let _: unit = %raw(`date.setHours(0, 0, 0, 0)`)
        Date.getTime(date)
      })

    // Build a lookup dict from activity dates for O(1) membership testing
    let dateDict = Dict.make()
    activityDates->Array.forEach(d => Dict.set(dateDict, Float.toString(d), true))
    let hasDate = (d: float) => Dict.get(dateDict, Float.toString(d))->Option.isSome
    let rec countStreak = (currentDate, streak) => {
      if hasDate(currentDate) {
        countStreak(currentDate -. 86400000.0, streak + 1)
      } else {
        streak
      }
    }
    countStreak(Date.getTime(today), 0)
  }
}

let showEmptyState = () => {
  Document.querySelector(document, ".content")
  ->Nullable.toOption
  ->Option.forEach(content =>
    Element.setInnerHTML(
      content,
      `
        <div class="empty-state">
          <div class="empty-state-icon">📊</div>
          <div class="empty-state-title">No Activity Data Yet</div>
          <div class="empty-state-text">
            Enable DoubleTrack and generate a profile to start seeing analytics
          </div>
        </div>
      `,
    )
  )
}

let renderOverviewCards = () => {
  let activities = activitiesRef.contents
  let stats = statsRef.contents->Option.getOr({
    totalActivities: 0,
    activitiesToday: 0,
    profileAgeDays: 0,
    lastActivity: None,
    activityByType: Dict.make(),
  })

  let setField = (id, value) =>
    Document.getElementById(document, id)
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, value))

  setField("total-activities", Int.toString(stats.totalActivities))

  let avgPerDay = switch profileRef.contents {
  | Some(_) =>
    let days = Pervasives.max(1, stats.profileAgeDays)
    stats.totalActivities / days
  | None => 0
  }
  setField("daily-average", Int.toString(avgPerDay))

  let totalSeconds =
    activities->Array.reduce(0, (sum, a) => sum + a.durationSeconds)
  let hours = totalSeconds / 3600
  setField("total-duration", `${Int.toString(hours)}h`)

  let streak = calculateStreak()
  setField("streak-days", Int.toString(streak))
}

let getDailyCounts = (days: int): array<int> => {
  let counts = Array.make(~length=days, 0)
  let today = Date.make()
  let _: unit = %raw(`today.setHours(0, 0, 0, 0)`)
  let todayTime = Date.getTime(today)

  activitiesRef.contents->Array.forEach(activity => {
    let activityDate = Date.fromTime(activity.timestamp *. 1000.0)
    let _: unit = %raw(`activityDate.setHours(0, 0, 0, 0)`)

    let daysDiff = Float.toInt((todayTime -. Date.getTime(activityDate)) /. 86400000.0)

    if daysDiff >= 0 && daysDiff < days {
      let idx = days - 1 - daysDiff
      counts[idx] = counts[idx]->Option.getOr(0) + 1
    }
  })

  counts
}

let renderRecentActivities = () => {
  Document.getElementById(document, "recent-activities")
  ->Nullable.toOption
  ->Option.forEach(container => {
    let recent =
      activitiesRef.contents
      ->Array.slice(~start=-20, ~end=Array.length(activitiesRef.contents))
      ->Array.toReversed

    let icons = Dict.fromArray([
      ("Search", `🔍`),
      ("PageVisit", `📄`),
      ("VideoWatch", `🎥`),
      ("Shopping", `🛒`),
      ("SocialMedia", `💬`),
      ("News", `📰`),
      ("Research", `📚`),
    ])

    let html =
      recent
      ->Array.map(activity => {
        let typeStr = activityTypeToString(activity.activityType)
        let icon = Dict.get(icons, typeStr)->Option.getOr(`📄`)
        let date = Date.fromTime(activity.timestamp *. 1000.0)
        let timeStr = Date.toLocaleTimeString(date)

        `
          <div class="activity-item">
            <div class="activity-icon">${icon}</div>
            <div class="activity-content">
              <div class="activity-title">${activity.title}</div>
              <div class="activity-url">${activity.url}</div>
            </div>
            <div class="activity-meta">${timeStr}</div>
          </div>
        `
      })
      ->Array.join("")

    Element.setInnerHTML(container, html)
  })
}

let renderInsights = () => {
  switch profileRef.contents {
  | Some(profile) =>
    let activities = activitiesRef.contents
    let stats = statsRef.contents->Option.getOr({
      totalActivities: 0,
      activitiesToday: 0,
      profileAgeDays: 0,
      lastActivity: None,
      activityByType: Dict.make(),
    })

    let setField = (id, value) =>
      Document.getElementById(document, id)
      ->Nullable.toOption
      ->Option.forEach(el => Element.setTextContent(el, value))

    let age = Int.toString(profile.demographics.age)
    let occupation = Obj.magic(profile.demographics.occupationCategory)->String.toLowerCase
    let interestCount = Int.toString(Array.length(profile.interests))
    setField(
      "insight-profile",
      `Your profile "${profile.name}" is a ${age}-year-old ${occupation} with ${interestCount} main interests.`,
    )

    let activityCount = Int.toString(Array.length(activities))
    let days = Int.toString(stats.profileAgeDays)
    let avgPerDay = Int.toString(
      Array.length(activities) / Pervasives.max(1, stats.profileAgeDays),
    )
    setField(
      "insight-activity",
      `Generated ${activityCount} activities over ${days} days, averaging ${avgPerDay} per day.`,
    )

    let style = browsingStyleToString(profile.browsingStyle)->String.toLowerCase
    setField(
      "insight-pattern",
      `Your ${style} browsing style creates a natural, believable activity pattern.`,
    )

    let level = activityLevelToString(profile.activityLevel)->String.toLowerCase
    setField(
      "insight-performance",
      `Activity level is ${level}, which provides good privacy coverage without excessive resource usage.`,
    )
  | None => ()
  }
}

let renderDashboard = () => {
  if Array.length(activitiesRef.contents) == 0 {
    showEmptyState()
  } else {
    renderOverviewCards()
    renderRecentActivities()
    renderInsights()
    // Charts would be rendered here with canvas API
  }
}

let setupEventListeners = () => {
  Document.getElementById(document, "back-btn")
  ->Nullable.toOption
  ->Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      Chrome.Runtime.openOptionsPage()
      Window.close(window)
    })
  )
}

let initialize = async (): unit => {
  await loadData()
  setupEventListeners()
  renderDashboard()
}

let _ = Document.addEventListener(document, "DOMContentLoaded", () => {
  let _ = initialize()
})
