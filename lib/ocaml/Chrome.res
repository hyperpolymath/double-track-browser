// SPDX-License-Identifier: PMPL-1.0-or-later
// Chrome WebExtension API bindings for ReScript

module Storage = {
  module Local = {
    @scope(("chrome", "storage", "local")) @val
    external get: string => promise<Dict.t<JSON.t>> = "get"

    @scope(("chrome", "storage", "local")) @val
    external getMultiple: array<string> => promise<Dict.t<JSON.t>> = "get"

    @scope(("chrome", "storage", "local")) @val
    external set: Dict.t<JSON.t> => promise<unit> = "set"
  }
}

module Runtime = {
  type messageResponse
  type sender

  @scope(("chrome", "runtime")) @val
  external sendMessage: JSON.t => promise<JSON.t> = "sendMessage"

  @scope(("chrome", "runtime")) @val
  external onMessageAddListener: (
    (JSON.t, sender, messageResponse => unit) => bool
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
  type tab = {id: option<int>, url: option<string>}

  @scope(("chrome", "tabs")) @val
  external create: {..} => promise<tab> = "create"

  @scope(("chrome", "tabs")) @val
  external remove: int => promise<unit> = "remove"

  @scope(("chrome", "tabs")) @val
  external query: {..} => promise<array<tab>> = "query"

  @scope(("chrome", "tabs")) @val
  external sendMessage: (int, JSON.t) => promise<JSON.t> = "sendMessage"

  module OnRemoved = {
    @scope(("chrome", "tabs", "onRemoved")) @val
    external addListener: (int => unit) => unit = "addListener"
  }
}
