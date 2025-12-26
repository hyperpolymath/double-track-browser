// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Dashboard page for activity analytics and visualization

open Types
open Dom

// State
let activitiesRef: ref<array<browsingActivity>> = ref([])
let profileRef: ref<option<profile>> = ref(None)
let statsRef: ref<option<statistics>> = ref(None)

let loadData = async (): unit => {
  let keys = [StorageKey.activityHistory, StorageKey.profile, StorageKey.statistics]
  let result = await Chrome.Storage.Local.getMultiple(keys)

  activitiesRef.contents =
    Js.Dict.get(result, StorageKey.activityHistory)
    ->Belt.Option.map(Obj.magic)
    ->Belt.Option.getWithDefault([])

  profileRef.contents = Js.Dict.get(result, StorageKey.profile)->Belt.Option.map(Obj.magic)

  statsRef.contents = Js.Dict.get(result, StorageKey.statistics)->Belt.Option.map(Obj.magic)
}

let calculateStreak = (): int => {
  let activities = activitiesRef.contents
  if Js.Array2.length(activities) == 0 {
    0
  } else {
    let today = Js.Date.make()
    let _ = Js.Date.setHours(today, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ~milliseconds=0.0, ())

    let activityDates =
      activities->Js.Array2.map(a => {
        let date = Js.Date.fromFloat(a.timestamp *. 1000.0)
        let _ = Js.Date.setHours(date, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ~milliseconds=0.0, ())
        Js.Date.getTime(date)
      })

    let dateSet = Belt.Set.Float.fromArray(activityDates)
    let rec countStreak = (currentDate, streak) => {
      if Belt.Set.Float.has(dateSet, currentDate) {
        countStreak(currentDate -. 86400000.0, streak + 1)
      } else {
        streak
      }
    }
    countStreak(Js.Date.getTime(today), 0)
  }
}

let showEmptyState = () => {
  Document.querySelector(document, ".content")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(content =>
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
  let stats = statsRef.contents->Belt.Option.getWithDefault({
    totalActivities: 0,
    activitiesToday: 0,
    profileAgeDays: 0,
    lastActivity: None,
    activityByType: Js.Dict.empty(),
  })

  let setField = (id, value) =>
    Document.getElementById(document, id)
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => Element.setTextContent(el, value))

  setField("total-activities", Belt.Int.toString(stats.totalActivities))

  let avgPerDay = switch profileRef.contents {
  | Some(_) =>
    let days = Js.Math.max_int(1, stats.profileAgeDays)
    stats.totalActivities / days
  | None => 0
  }
  setField("daily-average", Belt.Int.toString(avgPerDay))

  let totalSeconds =
    activities->Js.Array2.reduce((sum, a) => sum + a.durationSeconds, 0)
  let hours = totalSeconds / 3600
  setField("total-duration", `${Belt.Int.toString(hours)}h`)

  let streak = calculateStreak()
  setField("streak-days", Belt.Int.toString(streak))
}

let getDailyCounts = (days: int): array<int> => {
  let counts = Belt.Array.make(days, 0)
  let today = Js.Date.make()
  let _ = Js.Date.setHours(today, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ~milliseconds=0.0, ())
  let todayTime = Js.Date.getTime(today)

  activitiesRef.contents->Js.Array2.forEach(activity => {
    let activityDate = Js.Date.fromFloat(activity.timestamp *. 1000.0)
    let _ = Js.Date.setHours(
      activityDate,
      ~hours=0.0,
      ~minutes=0.0,
      ~seconds=0.0,
      ~milliseconds=0.0,
      (),
    )

    let daysDiff = Belt.Float.toInt((todayTime -. Js.Date.getTime(activityDate)) /. 86400000.0)

    if daysDiff >= 0 && daysDiff < days {
      let idx = days - 1 - daysDiff
      counts[idx] = counts[idx]->Belt.Option.getWithDefault(0) + 1
    }
  })

  counts
}

let renderRecentActivities = () => {
  Document.getElementById(document, "recent-activities")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(container => {
    let recent =
      activitiesRef.contents
      ->Js.Array2.slice(~start=-20, ~end_=Js.Array2.length(activitiesRef.contents))
      ->Js.Array2.reverseInPlace

    let icons = Js.Dict.fromArray([
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
      ->Js.Array2.map(activity => {
        let typeStr = activityTypeToString(activity.activityType)
        let icon = Js.Dict.get(icons, typeStr)->Belt.Option.getWithDefault(`📄`)
        let date = Js.Date.fromFloat(activity.timestamp *. 1000.0)
        let timeStr = Js.Date.toLocaleTimeString(date)

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
      ->Js.Array2.joinWith("")

    Element.setInnerHTML(container, html)
  })
}

let renderInsights = () => {
  switch profileRef.contents {
  | Some(profile) =>
    let activities = activitiesRef.contents
    let stats = statsRef.contents->Belt.Option.getWithDefault({
      totalActivities: 0,
      activitiesToday: 0,
      profileAgeDays: 0,
      lastActivity: None,
      activityByType: Js.Dict.empty(),
    })

    let setField = (id, value) =>
      Document.getElementById(document, id)
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(el => Element.setTextContent(el, value))

    let age = Belt.Int.toString(profile.demographics.age)
    let occupation = Obj.magic(profile.demographics.occupationCategory)->Js.String2.toLowerCase
    let interestCount = Belt.Int.toString(Js.Array2.length(profile.interests))
    setField(
      "insight-profile",
      `Your profile "${profile.name}" is a ${age}-year-old ${occupation} with ${interestCount} main interests.`,
    )

    let activityCount = Belt.Int.toString(Js.Array2.length(activities))
    let days = Belt.Int.toString(stats.profileAgeDays)
    let avgPerDay = Belt.Int.toString(
      Js.Array2.length(activities) / Js.Math.max_int(1, stats.profileAgeDays),
    )
    setField(
      "insight-activity",
      `Generated ${activityCount} activities over ${days} days, averaging ${avgPerDay} per day.`,
    )

    let style = browsingStyleToString(profile.browsingStyle)->Js.String2.toLowerCase
    setField(
      "insight-pattern",
      `Your ${style} browsing style creates a natural, believable activity pattern.`,
    )

    let level = activityLevelToString(profile.activityLevel)->Js.String2.toLowerCase
    setField(
      "insight-performance",
      `Activity level is ${level}, which provides good privacy coverage without excessive resource usage.`,
    )
  | None => ()
  }
}

let renderDashboard = () => {
  if Js.Array2.length(activitiesRef.contents) == 0 {
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
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn =>
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
