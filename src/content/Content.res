// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Content script for DoubleTrack Browser
// Runs in the context of web pages

Js.Console.log("DoubleTrack Browser: Content script loaded")

// Listen for messages from background script
let _ = Chrome.Runtime.onMessageAddListener((messageJson, _sender, sendResponse) => {
  let message: Types.message = Obj.magic(messageJson)

  switch message.messageType {
  | "PING" => sendResponse(Obj.magic({"status": "alive"}))
  | "GET_PAGE_INFO" =>
    sendResponse(
      Obj.magic({
        "url": Webapi.Dom.Window.location(Webapi.Dom.window)->Webapi.Dom.Location.href,
        "title": Webapi.Dom.Document.title(Webapi.Dom.document),
        "timestamp": Js.Date.now(),
      }),
    )
  | _ => sendResponse(Obj.magic({"error": "Unknown message type"}))
  }
  true
})

// Privacy protection: Ensure real browsing data is never leaked
let ensurePrivacy = () => {
  // Future: Implement additional privacy protections
  // - Prevent fingerprinting of simulated vs real activity
  // - Ensure storage separation
  // - Monitor for data leakage
  ()
}

let _ = ensurePrivacy()
