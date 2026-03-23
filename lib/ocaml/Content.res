// SPDX-License-Identifier: PMPL-1.0-or-later
// Content script for DoubleTrack Browser
// Runs in the context of web pages — simulates realistic user behavior

// External DOM bindings needed for behavior simulation
@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@val external clearTimeout: int => unit = "clearTimeout"
@val external setInterval: (unit => unit, int) => int = "setInterval"
@val external clearInterval: int => unit = "clearInterval"

module Window = {
  @val external scrollTo: {"top": float, "behavior": string} => unit = "window.scrollTo"
  @val external scrollY: float = "window.scrollY"
  @val external innerHeight: float = "window.innerHeight"
}

module Doc = {
  @val external documentElement: {..} = "document.documentElement"
  @scope("document") @val
  external querySelectorAll: string => array<{..}> = "querySelectorAll"

  @scope("document") @val @return(nullable)
  external querySelector: string => option<{..}> = "querySelector"
}

// Dispatch a synthetic mouse event on a target element
let dispatchMouseEvent = (target: {..}, eventType: string) => {
  let _: unit = %raw(`
    function(target, eventType) {
      var rect = target.getBoundingClientRect();
      var x = rect.left + rect.width * Math.random();
      var y = rect.top + rect.height * Math.random();
      var evt = new MouseEvent(eventType, {
        bubbles: true, cancelable: true, view: window,
        clientX: x, clientY: y
      });
      target.dispatchEvent(evt);
    }
  `)(target, eventType)
}

// Get the full scrollable height of the page
let getScrollHeight = (): float => {
  let _el = Doc.documentElement
  %raw(`el.scrollHeight`)->Obj.magic
}

// Simulate gradual, human-like scrolling
let simulateScroll = (targetDepth: float, onComplete: unit => unit) => {
  let maxScroll = getScrollHeight() -. Window.innerHeight
  let targetY = ref(0.0)
  targetY := maxScroll *. targetDepth

  let currentY = ref(Window.scrollY)
  let scrollStep = ref(0)

  let intervalId = ref(0)

  let step = () => {
    scrollStep := scrollStep.contents + 1

    // Variable scroll speed: sometimes fast, sometimes slow (human-like)
    let jitter = Math.random() *. 80.0 +. 20.0
    currentY := currentY.contents +. jitter

    if currentY.contents >= targetY.contents || scrollStep.contents > 200 {
      clearInterval(intervalId.contents)
      onComplete()
    } else {
      Window.scrollTo({"top": currentY.contents, "behavior": "smooth"})
    }
  }

  // Variable interval between 50ms and 300ms for human-like pacing
  let baseInterval = 100 + Float.toInt(Math.random() *. 200.0)
  intervalId := setInterval(step, baseInterval)
}

// Simulate mouse movement over visible content elements
let simulateMouseMovement = (onComplete: unit => unit) => {
  let elements = Doc.querySelectorAll("p, h1, h2, h3, a, img, li, span")
  let numMoves = Float.toInt(Math.random() *. 5.0) + 2
  let moveIndex = ref(0)

  let rec doMove = () => {
    if moveIndex.contents >= numMoves || Array.length(elements) == 0 {
      onComplete()
    } else {
      let idx = Float.toInt(Math.random() *. Int.toFloat(Array.length(elements)))
      switch elements[idx] {
      | Some(el) =>
        dispatchMouseEvent(el, "mouseover")
        dispatchMouseEvent(el, "mousemove")
        // Pause like a human reading, then move on
        let delay = 300 + Float.toInt(Math.random() *. 1200.0)
        let _ = setTimeout(() => {
          dispatchMouseEvent(el, "mouseout")
          moveIndex := moveIndex.contents + 1
          doMove()
        }, delay)
      | None =>
        moveIndex := moveIndex.contents + 1
        doMove()
      }
    }
  }

  doMove()
}

// Simulate clicking an internal link (same-origin navigation)
let simulateClick = (onComplete: unit => unit) => {
  let links = Doc.querySelectorAll("a[href]")

  // Filter to internal links only
  let internalLinks: array<{..}> = %raw(`
    function(links) {
      return Array.from(links).filter(function(a) {
        try {
          var href = a.getAttribute('href');
          if (!href || href.startsWith('#') || href.startsWith('javascript:')) return false;
          var url = new URL(href, window.location.origin);
          return url.origin === window.location.origin;
        } catch(e) { return false; }
      });
    }
  `)(links)

  if Array.length(internalLinks) > 0 {
    let idx = Float.toInt(Math.random() *. Int.toFloat(Array.length(internalLinks)))
    switch internalLinks[idx] {
    | Some(link) =>
      dispatchMouseEvent(link, "mouseover")
      let _ = setTimeout(() => {
        dispatchMouseEvent(link, "click")
        onComplete()
      }, 500 + Float.toInt(Math.random() *. 800.0))
    | None => onComplete()
    }
  } else {
    onComplete()
  }
}

// Main simulation orchestrator — runs scroll, mouse, optional click, then dwells
let runSimulation = (params: Types.simulationParams, onComplete: unit => unit) => {
  Console.log("DoubleTrack: Starting page behavior simulation")

  // Phase 1: Scroll
  simulateScroll(params.scrollDepth, () => {
    // Phase 2: Mouse movement
    simulateMouseMovement(() => {
      // Phase 3: Optional link click
      if params.clickLinks && Math.random() > 0.5 {
        simulateClick(() => {
          // Phase 4: Dwell for remaining time then signal completion
          let _ = setTimeout(onComplete, params.dwellSeconds * 1000)
        })
      } else {
        // Phase 4: Dwell then signal completion
        let _ = setTimeout(onComplete, params.dwellSeconds * 1000)
      }
    })
  })
}

// Listen for messages from background script
let _ = Chrome.Runtime.onMessageAddListener((messageJson, _sender, sendResponse) => {
  let message: Types.message = Obj.magic(messageJson)

  switch message.messageType {
  | "PING" => sendResponse(Obj.magic({"status": "alive"}))
  | "GET_PAGE_INFO" =>
    sendResponse(
      Obj.magic({
        "url": %raw(`window.location.href`),
        "title": %raw(`document.title`),
        "timestamp": Date.now(),
      }),
    )
  | "SIMULATE_ACTIVITY" =>
    let params: Types.simulationParams = switch message.payload {
    | Some(p) => Obj.magic(p)
    | None => {
        scrollDepth: 0.6,
        clickLinks: true,
        dwellSeconds: 15,
        fillForms: false,
      }
    }

    runSimulation(params, () => {
      Console.log("DoubleTrack: Simulation complete, signaling background")
      let _ = Chrome.Runtime.sendMessage(
        Obj.magic({"type": "ACTIVITY_COMPLETE", "payload": Nullable.null}),
      )
    })

    // Respond immediately — completion signaled asynchronously
    sendResponse(Obj.magic({"status": "simulation_started"}))
  | _ => sendResponse(Obj.magic({"error": "Unknown message type"}))
  }
  true
})
