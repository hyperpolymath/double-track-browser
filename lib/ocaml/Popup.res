// SPDX-License-Identifier: PMPL-1.0-or-later
// Popup UI controller for DoubleTrack Browser

open Types
open DomBindings

// State
let configRef: ref<option<extensionConfig>> = ref(None)
let profileRef: ref<option<profile>> = ref(None)
let statsRef: ref<option<statistics>> = ref(None)

let sendMessage = async (msg: message): JSON.t => {
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

let updateProfileInfo = () => {
  let noProfile = Document.getElementById(document, "no-profile")->Nullable.toOption
  let profileDetails = Document.getElementById(document, "profile-details")->Nullable.toOption

  switch (profileRef.contents, noProfile, profileDetails) {
  | (None, Some(np), Some(pd)) =>
    Style.setDisplay(Element.style(np), "block")
    Style.setDisplay(Element.style(pd), "none")
  | (Some(profile), Some(np), Some(pd)) =>
    Style.setDisplay(Element.style(np), "none")
    Style.setDisplay(Element.style(pd), "block")

    Document.getElementById(document, "profile-name")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, profile.name))

    Document.getElementById(document, "profile-age")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, Int.toString(profile.demographics.age)))

    Document.getElementById(document, "profile-occupation")
    ->Nullable.toOption
    ->Option.forEach(el =>
      Element.setTextContent(el, Obj.magic(profile.demographics.occupationCategory))
    )

    Document.getElementById(document, "profile-interests")
    ->Nullable.toOption
    ->Option.forEach(el =>
      Element.setTextContent(
        el,
        profile.interests->Array.map(interestCategoryToString)->Array.join(", "),
      )
    )

    Document.getElementById(document, "profile-activity-level")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, activityLevelToString(profile.activityLevel)))
  | _ => ()
  }
}

let updateStatistics = () => {
  switch statsRef.contents {
  | Some(stats) =>
    Document.getElementById(document, "total-activities")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, Int.toString(stats.totalActivities)))

    Document.getElementById(document, "today-activities")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, Int.toString(stats.activitiesToday)))

    Document.getElementById(document, "profile-age")
    ->Nullable.toOption
    ->Option.forEach(el => Element.setTextContent(el, Int.toString(stats.profileAgeDays)))
  | None => ()
  }
}

let updateUI = () => {
  switch configRef.contents {
  | Some(config) =>
    let statusDot = Document.getElementById(document, "status-dot")->Nullable.toOption
    let statusText = Document.getElementById(document, "status-text")->Nullable.toOption
    let toggleBtn = Document.getElementById(document, "toggle-btn")->Nullable.toOption

    switch (statusDot, statusText, toggleBtn) {
    | (Some(dot), Some(text), Some(btn)) =>
      if config.enabled {
        ClassList.add(Element.classList(dot), "active")
        ClassList.remove(Element.classList(dot), "inactive")
        Element.setTextContent(text, "Enabled")
        Element.setTextContent(btn, "Disable")
        ClassList.add(Element.classList(btn), "active")
      } else {
        ClassList.remove(Element.classList(dot), "active")
        ClassList.add(Element.classList(dot), "inactive")
        Element.setTextContent(text, "Disabled")
        Element.setTextContent(btn, "Enable")
        ClassList.remove(Element.classList(btn), "active")
      }
    | _ => ()
    }

    updateProfileInfo()
    updateStatistics()

    // Update controls
    Document.getElementById(document, "noise-level")
    ->Nullable.toOption
    ->Option.forEach(slider => {
      let percentage = Float.toInt(config.noiseLevel *. 100.0)
      Element.setValue(slider, Int.toString(percentage))
    })

    Document.getElementById(document, "noise-value")
    ->Nullable.toOption
    ->Option.forEach(el => {
      let percentage = Float.toInt(config.noiseLevel *. 100.0)
      Element.setTextContent(el, `${Int.toString(percentage)}%`)
    })

    Document.getElementById(document, "respect-schedule")
    ->Nullable.toOption
    ->Option.forEach(checkbox => Element.setChecked(checkbox, config.respectSchedule))
  | None => ()
  }
}

let handleToggle = async (): unit => {
  switch configRef.contents {
  | Some(config) =>
    if Option.isNone(profileRef.contents) && !config.enabled {
      // Would show confirmation dialog in browser
      Console.log("No profile exists. Generate one first.")
    } else {
      let newConfig = {...config, enabled: !config.enabled}
      let _ = await sendMessage({
        messageType: "UPDATE_CONFIG",
        payload: Some(Obj.magic(newConfig)),
      })
      await loadState()
      updateUI()
    }
  | None => ()
  }
}

let handleGenerateProfile = async (): unit => {
  let generateBtn = Document.getElementById(document, "generate-profile-btn")->Nullable.toOption

  switch generateBtn {
  | Some(btn) =>
    Element.setTextContent(btn, "Generating...")
    Element.setDisabled(btn, true)

    let result = await sendMessage({messageType: "GENERATE_PROFILE", payload: None})
    profileRef.contents = Some(Obj.magic(result))
    await loadState()
    updateUI()

    Element.setTextContent(btn, "Generate New Profile")
    Element.setDisabled(btn, false)
  | None => ()
  }
}

let handleNoiseChange = async (value: string): unit => {
  switch configRef.contents {
  | Some(config) =>
    let newLevel = Float.fromString(value)->Option.getOr(50.0) /. 100.0
    let newConfig = {...config, noiseLevel: newLevel}
    let _ = await sendMessage({
      messageType: "UPDATE_CONFIG",
      payload: Some(Obj.magic(newConfig)),
    })
  | None => ()
  }
}

let handleScheduleChange = async (checked: bool): unit => {
  switch configRef.contents {
  | Some(config) =>
    let newConfig = {...config, respectSchedule: checked}
    let _ = await sendMessage({
      messageType: "UPDATE_CONFIG",
      payload: Some(Obj.magic(newConfig)),
    })
  | None => ()
  }
}

let handleClearHistory = async (): unit => {
  let _ = await sendMessage({messageType: "CLEAR_HISTORY", payload: None})
  await loadState()
  updateUI()
}

let setupEventListeners = () => {
  Document.getElementById(document, "toggle-btn")
  ->Nullable.toOption
  ->Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      let _ = handleToggle()
    })
  )

  Document.getElementById(document, "generate-profile-btn")
  ->Nullable.toOption
  ->Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      let _ = handleGenerateProfile()
    })
  )

  Document.getElementById(document, "noise-level")
  ->Nullable.toOption
  ->Option.forEach(slider => {
    Element.addEventListener(slider, "input", e => {
      let value = Element.value(Event.target(e))
      Document.getElementById(document, "noise-value")
      ->Nullable.toOption
      ->Option.forEach(el => Element.setTextContent(el, `${value}%`))
    })
    Element.addEventListener(slider, "change", e => {
      let _ = handleNoiseChange(Element.value(Event.target(e)))
    })
  })

  Document.getElementById(document, "respect-schedule")
  ->Nullable.toOption
  ->Option.forEach(checkbox =>
    Element.addEventListener(checkbox, "change", e => {
      let _ = handleScheduleChange(Element.checked(Event.target(e)))
    })
  )

  Document.getElementById(document, "options-btn")
  ->Nullable.toOption
  ->Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => Chrome.Runtime.openOptionsPage())
  )

  Document.getElementById(document, "clear-history-btn")
  ->Nullable.toOption
  ->Option.forEach(btn =>
    Element.addEventListener(btn, "click", _ => {
      let _ = handleClearHistory()
    })
  )
}

let initialize = async (): unit => {
  await loadState()
  setupEventListeners()
  updateUI()
}

// Initialize when DOM is loaded
let _ = Document.addEventListener(document, "DOMContentLoaded", () => {
  let _ = initialize()
})
