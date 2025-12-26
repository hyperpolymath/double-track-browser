// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// DOM bindings for ReScript

@val external document: Dom.document = "document"
@val external window: Dom.window = "window"

module Document = {
  @send external getElementById: (Dom.document, string) => Js.Nullable.t<Dom.element> = "getElementById"
  @send external querySelector: (Dom.document, string) => Js.Nullable.t<Dom.element> = "querySelector"
  @get external title: Dom.document => string = "title"
  @send external addEventListener: (Dom.document, string, unit => unit) => unit = "addEventListener"
}

module Window = {
  @send external close: Dom.window => unit = "close"
  module Location = {
    @get external href: Dom.window => string = "location.href"
  }
}

module Element = {
  @send external addEventListener: (Dom.element, string, Dom.event => unit) => unit = "addEventListener"
  @get external classList: Dom.element => Dom.domTokenList = "classList"
  @get external textContent: Dom.element => string = "textContent"
  @set external setTextContent: (Dom.element, string) => unit = "textContent"
  @get external value: Dom.element => string = "value"
  @set external setValue: (Dom.element, string) => unit = "value"
  @get external checked: Dom.element => bool = "checked"
  @set external setChecked: (Dom.element, bool) => unit = "checked"
  @get external disabled: Dom.element => bool = "disabled"
  @set external setDisabled: (Dom.element, bool) => unit = "disabled"
  @get external style: Dom.element => Dom.cssStyleDeclaration = "style"
  @set external setInnerHTML: (Dom.element, string) => unit = "innerHTML"
}

module ClassList = {
  @send external add: (Dom.domTokenList, string) => unit = "add"
  @send external remove: (Dom.domTokenList, string) => unit = "remove"
}

module Style = {
  @set external setDisplay: (Dom.cssStyleDeclaration, string) => unit = "display"
}

module Event = {
  @get external target: Dom.event => Dom.element = "target"
}
