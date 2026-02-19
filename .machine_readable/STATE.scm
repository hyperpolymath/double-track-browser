;; SPDX-License-Identifier: PMPL-1.0-or-later
;; STATE.scm - Project state for double-track-browser
;; Media-Type: application/vnd.state+scm

(state
  (metadata
    (version "0.1.0")
    (schema-version "1.0")
    (created "2026-01-03")
    (updated "2026-02-19")
    (project "double-track-browser")
    (repo "github.com/hyperpolymath/double-track-browser"))

  (project-context
    (name "double-track-browser")
    (tagline "Privacy through deliberate visibility — data poisoning browser extension")
    (tech-stack ("Rust/WASM" "ReScript" "Deno" "WebExtensions API")))

  (current-position
    (phase "alpha")
    (overall-completion 55)
    (components
      ("rust-core" "Profile generation, activity simulation, interest URLs, form data" 75)
      ("rescript-ui" "Popup, options, dashboard UI components" 70)
      ("content-script" "Page behavior simulation (scroll, mouse, click, dwell)" 80)
      ("background-engine" "Real tab orchestration, lifecycle management, alarm scheduling" 80)
      ("wasm-bridge" "Dynamic WASM loading with mock fallback" 60)
      ("chrome-bindings" "Storage, runtime, alarms, tabs (query, send, remove)" 70)
      ("consent-integration" "AIBDP respect, HTTP 430 handling" 0)
      ("defensive-multiplicity" "Multi-persona management, fingerprint diversity" 0)
      ("formal-verification" "Idris2 ABI proofs for identity isolation" 0))
    (working-features
      ("profile-generation" "Randomized believable personas with demographics, interests, browsing style")
      ("activity-simulation" "Background generation of realistic browsing activities")
      ("real-tab-orchestration" "Opens real browser tabs with fake URLs, manages lifecycle")
      ("behavior-simulation" "Content script simulates scrolling, mouse movement, link clicks, dwell time")
      ("configurable-noise" "Adjustable noise level, schedule respect, privacy modes")
      ("wasm-with-fallback" "Real WASM loading attempted, JS mocks as fallback")
      ("form-data-generation" "Fake email, display name, preferences tied to profile")))

  (route-to-mvp
    (milestones
      ("m1-engine-done" "Core data poisoning engine working" 80
        "Real tabs open, content script simulates behavior, activities recorded")
      ("m2-consent-aware" "Respect AIBDP manifests and HTTP 430" 0
        "Check /.well-known/aibdp.json before visiting sites, honor refusal")
      ("m3-defensive-multiplicity" "Multiple concurrent personas with fingerprint diversity" 0
        "Rotate personas, vary browser fingerprint signals, cryptographic accountability")
      ("m4-formal-proofs" "Idris2 ABI proofs for identity isolation" 0
        "Prove real identity never leaks into fake browsing sessions")
      ("m5-beta-release" "Stable beta for Chrome/Firefox" 0
        "Cross-browser testing, performance optimization, user documentation")))

  (blockers-and-issues
    (critical)
    (high
      ("WASM module not yet compiled for production" "Need wasm-pack build integration in CI"))
    (medium
      ("Content script behavior may be detectable" "Need fingerprint randomization")
      ("No consent-aware HTTP support yet" "Should check AIBDP before visiting URLs"))
    (low
      ("Pre-existing Rust warnings" "Unused imports in activity.rs, cfg condition")))

  (critical-next-actions
    (immediate
      ("Integrate consent-aware-http AIBDP checking into background engine")
      ("Add defensive-multiplicity persona rotation"))
    (this-week
      ("Build WASM module and test end-to-end in browser")
      ("Add fingerprint diversity (canvas, WebGL, user-agent variation)"))
    (this-month
      ("Cross-browser testing (Chrome + Firefox)")
      ("Formal verification of identity isolation via Idris2 ABI")))

  (session-history
    ("2026-02-19" "Major implementation session"
      "Implemented real tab orchestration, content script behavior simulation, "
      "WASM loading with fallback, expanded Rust interest database, "
      "added form_data module, fixed all license headers to PMPL-1.0-or-later, "
      "integrated defensive-multiplicity and consent-aware-http into roadmap")))
