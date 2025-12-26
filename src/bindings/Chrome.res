// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Chrome WebExtension API bindings for ReScript

module Storage = {
  module Local = {
    @scope(("chrome", "storage", "local")) @val
    external get: string => Js.Promise.t<Js.Dict.t<Js.Json.t>> = "get"

    @scope(("chrome", "storage", "local")) @val
    external getMultiple: array<string> => Js.Promise.t<Js.Dict.t<Js.Json.t>> = "get"

    @scope(("chrome", "storage", "local")) @val
    external set: Js.Dict.t<Js.Json.t> => Js.Promise.t<unit> = "set"
  }
}

module Runtime = {
  type messageResponse
  type sender

  @scope(("chrome", "runtime")) @val
  external sendMessage: Js.Json.t => Js.Promise.t<Js.Json.t> = "sendMessage"

  @scope(("chrome", "runtime")) @val
  external onMessageAddListener: (
    (Js.Json.t, sender, messageResponse => unit) => bool
  ) => unit = "onMessage.addListener"

  @scope(("chrome", "runtime")) @val
  external openOptionsPage: unit => unit = "openOptionsPage"

  @scope(("chrome", "runtime")) @val
  external getURL: string => string = "getURL"

  module LastError = {
    @scope(("chrome", "runtime")) @val @return(nullable)
    external lastError: option<{..}> = "lastError"
  }
}

module Alarms = {
  type alarm = {name: string}

  type alarmCreateInfo = {
    when_: option<float>,
    periodInMinutes: option<float>,
  }

  @scope(("chrome", "alarms")) @val
  external create: (string, {..}) => unit = "create"

  @scope(("chrome", "alarms")) @val
  external clear: string => unit = "clear"

  @scope(("chrome", "alarms")) @val
  external onAlarmAddListener: (alarm => unit) => unit = "onAlarm.addListener"
}

module Tabs = {
  type tab = {id: option<int>}

  @scope(("chrome", "tabs")) @val
  external create: {..} => Js.Promise.t<tab> = "create"

  @scope(("chrome", "tabs")) @val
  external remove: int => Js.Promise.t<unit> = "remove"
}
