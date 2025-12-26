// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Options page controller for DoubleTrack Browser

open Types
open Dom

// State
let configRef: ref<option<extensionConfig>> = ref(None)
let profileRef: ref<option<profile>> = ref(None)
let statsRef: ref<option<statistics>> = ref(None)

let sendMessage = async (msg: message): Js.Json.t => {
  await Chrome.Runtime.sendMessage(Obj.magic(msg))
}

let loadState = async (): unit => {
  let configResult = await sendMessage({messageType: "GET_CONFIG", payload: None})
  configRef.contents = Some(Obj.magic(configResult))

  let profileResult = await sendMessage({messageType: "GET_CURRENT_PROFILE", payload: None})
  profileRef.contents = Obj.magic(profileResult)

  let statsResult = await sendMessage({messageType: "GET_STATISTICS", payload: None})
  statsRef.contents = Some(Obj.magic(statsResult))
}

let updateProfileDisplay = () => {
  let noProfileMsg = Document.getElementById(document, "no-profile-message")->Js.Nullable.toOption
  let profileDetails = Document.getElementById(document, "profile-details")->Js.Nullable.toOption
  let exportBtn = Document.getElementById(document, "export-profile-btn")->Js.Nullable.toOption

  switch (profileRef.contents, noProfileMsg, profileDetails, exportBtn) {
  | (None, Some(msg), Some(details), Some(btn)) =>
    Style.setDisplay(Element.style(msg), "block")
    Style.setDisplay(Element.style(details), "none")
    Element.setDisabled(btn, true)
  | (Some(profile), Some(msg), Some(details), Some(btn)) =>
    Style.setDisplay(Element.style(msg), "none")
    Style.setDisplay(Element.style(details), "block")
    Element.setDisabled(btn, false)

    let setField = (id, value) =>
      Document.getElementById(document, id)
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(el => Element.setTextContent(el, value))

    setField("profile-name", profile.name)
    setField("profile-age", Belt.Int.toString(profile.demographics.age))
    setField("profile-gender", genderToString(profile.demographics.gender))
    setField("profile-location", Obj.magic(profile.demographics.locationType))
    setField("profile-occupation", Obj.magic(profile.demographics.occupationCategory))
    setField("profile-education", Obj.magic(profile.demographics.educationLevel))
    setField(
      "profile-interests",
      profile.interests->Js.Array2.map(interestCategoryToString)->Js.Array2.joinWith(", "),
    )
    setField("profile-style", browsingStyleToString(profile.browsingStyle))
    setField("profile-activity", activityLevelToString(profile.activityLevel))
  | _ => ()
  }
}

let updateStatistics = () => {
  switch statsRef.contents {
  | Some(stats) =>
    let setField = (id, value) =>
      Document.getElementById(document, id)
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(el => Element.setTextContent(el, value))

    setField("total-activities", Belt.Int.toString(stats.totalActivities))
    setField("today-activities", Belt.Int.toString(stats.activitiesToday))
    setField("profile-age-days", Belt.Int.toString(stats.profileAgeDays))
  | None => ()
  }
}

let updateUI = () => {
  switch configRef.contents {
  | Some(config) =>
    Document.getElementById(document, "enabled")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => Element.setChecked(el, config.enabled))

    Document.getElementById(document, "privacy-mode")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => Element.setValue(el, privacyModeToString(config.privacyMode)))

    Document.getElementById(document, "noise-level")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(slider => {
      let percentage = Belt.Float.toInt(config.noiseLevel *. 100.0)
      Element.setValue(slider, Belt.Int.toString(percentage))
    })

    Document.getElementById(document, "noise-value")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => {
      let percentage = Belt.Float.toInt(config.noiseLevel *. 100.0)
      Element.setTextContent(el, `${Belt.Int.toString(percentage)}%`)
    })

    Document.getElementById(document, "respect-schedule")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => Element.setChecked(el, config.respectSchedule))

    updateProfileDisplay()
    updateStatistics()
  | None => ()
  }
}

let handleEnabledChange = async (enabled: bool): unit => {
  switch (configRef.contents, enabled, profileRef.contents) {
  | (Some(_), true, None) =>
    Js.Console.log("Please generate a profile first")
    Document.getElementById(document, "enabled")
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(el => Element.setChecked(el, false))
  | (Some(config), _, _) =>
    let newConfig = {...config, enabled}
    let _ = await sendMessage({messageType: "UPDATE_CONFIG", payload: Some(Obj.magic(newConfig))})
  | _ => ()
  }
}

let handleNoiseChange = async (value: string): unit => {
  switch configRef.contents {
  | Some(config) =>
    let newLevel = Belt.Float.fromString(value)->Belt.Option.getWithDefault(50.0) /. 100.0
    let newConfig = {...config, noiseLevel: newLevel}
    let _ = await sendMessage({messageType: "UPDATE_CONFIG", payload: Some(Obj.magic(newConfig))})
  | None => ()
  }
}

let handleScheduleChange = async (checked: bool): unit => {
  switch configRef.contents {
  | Some(config) =>
    let newConfig = {...config, respectSchedule: checked}
    let _ = await sendMessage({messageType: "UPDATE_CONFIG", payload: Some(Obj.magic(newConfig))})
  | None => ()
  }
}

let handleGenerateProfile = async (): unit => {
  let btn = Document.getElementById(document, "generate-profile-btn")->Js.Nullable.toOption

  switch btn {
  | Some(b) =>
    Element.setTextContent(b, "Generating...")
    Element.setDisabled(b, true)

    let result = await sendMessage({messageType: "GENERATE_PROFILE", payload: None})
    profileRef.contents = Some(Obj.magic(result))
    await loadState()
    updateUI()

    Element.setTextContent(b, "Generate New Profile")
    Element.setDisabled(b, false)
  | None => ()
  }
}

let handleExportProfile = () => {
  switch profileRef.contents {
  | Some(profile) =>
    let dataStr = Js.Json.stringifyAny(Obj.magic(profile))->Belt.Option.getWithDefault("{}")
    Js.Console.log2("Export profile:", dataStr)
    // In browser, would create blob and download link
  | None => ()
  }
}

let handleViewDashboard = () => {
  let url = Chrome.Runtime.getURL("dashboard.html")
  let _ = Chrome.Tabs.create({"url": url, "active": true})
}

let handleClearHistory = async (): unit => {
  let _ = await sendMessage({messageType: "CLEAR_HISTORY", payload: None})
  await loadState()
  updateUI()
}

let showModal = () => {
  Document.getElementById(document, "activity-modal")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(modal => Style.setDisplay(Element.style(modal), "flex"))
}

let closeModal = () => {
  Document.getElementById(document, "activity-modal")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(modal => Style.setDisplay(Element.style(modal), "none"))
}

let setupEventListeners = () => {
  Document.getElementById(document, "enabled")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(el =>
    Element.addEventListener(el, "change", e => {
      let _ = handleEnabledChange(Element.checked(Event.target(e)))
    })
  )

  Document.getElementById(document, "noise-level")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(slider => {
    Element.addEventListener(slider, "input", e => {
      let value = Element.value(Event.target(e))
      Document.getElementById(document, "noise-value")
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(el => Element.setTextContent(el, `${value}%`))
    })
    Element.addEventListener(slider, "change", e => {
      let _ = handleNoiseChange(Element.value(Event.target(e)))
    })
  })

  Document.getElementById(document, "respect-schedule")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(el =>
    Element.addEventListener(el, "change", e => {
      let _ = handleScheduleChange(Element.checked(Event.target(e)))
    })
  )

  Document.getElementById(document, "generate-profile-btn")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      let _ = handleGenerateProfile()
    })
  )

  Document.getElementById(document, "export-profile-btn")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn => Element.addEventListener(btn, "click", _ => handleExportProfile()))

  Document.getElementById(document, "view-dashboard-btn")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn => Element.addEventListener(btn, "click", _ => handleViewDashboard()))

  Document.getElementById(document, "view-history-btn")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn => Element.addEventListener(btn, "click", _ => showModal()))

  Document.getElementById(document, "clear-history-btn")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      let _ = handleClearHistory()
    })
  )

  Document.querySelector(document, ".modal-close")
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(btn => Element.addEventListener(btn, "click", _ => closeModal()))
}

let initialize = async (): unit => {
  await loadState()
  setupEventListeners()
  updateUI()
}

let _ = Document.addEventListener(document, "DOMContentLoaded", () => {
  let _ = initialize()
})
