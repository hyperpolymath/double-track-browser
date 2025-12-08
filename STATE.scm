;;; STATE.scm - DoubleTrack Browser Project State
;;; A Scheme-based checkpoint for AI conversation continuity
;;; Format: Guile Scheme S-expressions

(state

  ;;; =========================================================================
  ;;; METADATA
  ;;; =========================================================================
  (metadata
    (format-version . "2.0")
    (schema-version . "2025-12-08")
    (created-at . "2025-12-08T00:00:00Z")
    (last-updated . "2025-12-08T00:00:00Z")
    (generator . "Claude Code / Opus 4"))

  ;;; =========================================================================
  ;;; USER CONTEXT
  ;;; =========================================================================
  (user
    (name . "hyperpolymath")
    (roles . ("developer" "privacy-advocate" "open-source-maintainer"))
    (preferences
      (languages-preferred . ("Rust" "TypeScript"))
      (languages-avoid . ())
      (tools-preferred . ("wasm-pack" "webpack" "cargo" "npm"))
      (values . ("privacy" "FOSS" "memory-safety" "reproducibility" "ethical-tech"))))

  ;;; =========================================================================
  ;;; SESSION CONTEXT
  ;;; =========================================================================
  (session
    (conversation-id . "create-state-scm-01LcbLvsswX4kPw92YxPTS4o")
    (started-at . "2025-12-08")
    (purpose . "Create STATE.scm for project state tracking"))

  ;;; =========================================================================
  ;;; CURRENT FOCUS
  ;;; =========================================================================
  (focus
    (current-project . "double-track-browser")
    (current-phase . "prototype-complete-pending-integration")
    (deadline . #f)
    (blocking-projects . ()))

  ;;; =========================================================================
  ;;; PROJECT CATALOG
  ;;; =========================================================================
  (projects
    ((name . "double-track-browser")
     (status . "in-progress")
     (completion . 75)
     (category . "browser-extension")
     (phase . "MVP v1 Development")

     (description . "Privacy through deliberate visibility - creates fictional
                     browsing patterns alongside real activity to obscure tracking")

     (architecture
       (rust-core . "Profile generation, activity simulation, schedule logic")
       (typescript-shell . "Browser API integration, UI components")
       (wasm-bridge . "Rust compiled to WebAssembly for browser integration"))

     (current-position
       (summary . "Functional prototype complete with mock WASM integration")
       (lines-of-code . 6000)
       (test-count . 27)
       (rsr-compliance . "Gold Level (91%)")
       (documentation . "Complete - README, CLAUDE.md, DEVELOPMENT.md, etc."))

     (what-works
       ("Profile generation creates realistic fictional personas")
       ("Activity simulation generates believable browsing patterns")
       ("Storage system persists all data locally")
       ("Background worker schedules and simulates activities")
       ("All UI components functional and responsive")
       ("Analytics dashboard with visualizations")
       ("Automated build system")
       ("All 27 tests pass"))

     (what-needs-work
       ((item . "WASM Integration")
        (priority . "critical")
        (status . "using-mock-implementation")
        (details . "Rust/WASM core is built but TypeScript uses mock functions.
                    Need to properly load compiled WASM module and wire up
                    actual Rust function calls."))

       ((item . "Extension Icons")
        (priority . "high")
        (status . "placeholders-only")
        (details . "Using placeholder files. Need professional icons at
                    16x16, 32x32, 48x48, 128x128 sizes."))

       ((item . "Tab Opening Feature")
        (priority . "medium")
        (status . "disabled-for-safety")
        (details . "Code exists but commented out. Needs user confirmation
                    dialogs and proper cleanup logic."))

       ((item . "Browser Compatibility Testing")
        (priority . "medium")
        (status . "untested")
        (details . "Need to test on Chrome, Firefox, Edge. Handle
                    browser-specific API differences.")))

     (dependencies . ("wasm-pack" "webpack" "typescript"))
     (blockers . ())

     (next
       ("Wire up WASM module loading in src/utils/wasm.ts")
       ("Test actual WASM function calls from TypeScript")
       ("Design and create extension icons")
       ("Test extension loading in Chrome")
       ("Test extension loading in Firefox"))))

  ;;; =========================================================================
  ;;; ROUTE TO MVP v1
  ;;; =========================================================================
  (mvp-v1-roadmap
    (goal . "Fully functional browser extension ready for beta testing")

    (phase-1-integration
      (name . "WASM Integration")
      (tasks
        ("Replace mock implementations in src/utils/wasm.ts with actual WASM calls")
        ("Load compiled WASM module from rust_core/pkg/")
        ("Test generate_profile() through WASM boundary")
        ("Test generate_activities() through WASM boundary")
        ("Test validate_profile() through WASM boundary")
        ("Benchmark WASM vs mock performance")))

    (phase-2-assets
      (name . "Visual Assets")
      (tasks
        ("Design double-track icon concept")
        ("Create SVG master icon")
        ("Generate PNG at all required sizes (16, 32, 48, 128)")
        ("Test icon rendering in browser toolbar")))

    (phase-3-browser-testing
      (name . "Browser Compatibility")
      (tasks
        ("Load extension in Chrome")
        ("Verify all features work in Chrome")
        ("Load extension in Firefox (about:debugging)")
        ("Address any Firefox-specific issues")
        ("Test on Edge (Chromium-based)")))

    (phase-4-hardening
      (name . "Production Hardening")
      (tasks
        ("Enable tab opening with user confirmation")
        ("Add error boundaries to all UI components")
        ("Performance profiling and optimization")
        ("Security audit of data separation")
        ("Update documentation for v1.0"))))

  ;;; =========================================================================
  ;;; OPEN ISSUES
  ;;; =========================================================================
  (issues
    ((id . 1)
     (title . "WASM module uses mock implementation")
     (severity . "blocking-mvp")
     (description . "src/utils/wasm.ts contains mock functions instead of
                     actual WASM calls. The Rust core compiles but isn't loaded."))

    ((id . 2)
     (title . "Icons are placeholders")
     (severity . "blocking-release")
     (description . "No actual icon files. icons/ directory has PLACEHOLDER.txt
                     and a reference SVG but no production PNGs."))

    ((id . 3)
     (title . "Tab opening disabled")
     (severity . "feature-incomplete")
     (description . "openActivityInBackground() is commented out for safety.
                     Core feature of generating actual browsing activity."))

    ((id . 4)
     (title . "No cross-browser testing")
     (severity . "release-risk")
     (description . "Extension untested on actual browsers. May have
                     compatibility issues with Firefox APIs.")))

  ;;; =========================================================================
  ;;; QUESTIONS FOR USER
  ;;; =========================================================================
  (questions
    ((question . "Priority between WASM integration vs icon design?")
     (context . "WASM needed for functionality, icons needed for release."))

    ((question . "Preferred tab opening behavior?")
     (context . "Should tabs open automatically, require confirmation,
                 or stay as simulation-only mode?"))

    ((question . "Target browser priority?")
     (context . "Chrome-first, Firefox-first, or equal priority?"))

    ((question . "Distribution plans?")
     (context . "Chrome Web Store, Firefox Add-ons, self-hosted, or private?"))

    ((question . "Beta testing program?")
     (context . "Internal testing only, or open beta?")))

  ;;; =========================================================================
  ;;; LONG-TERM ROADMAP (Post MVP)
  ;;; =========================================================================
  (roadmap-long-term
    (v1.x-enhancements
      ("Profile templates (pre-made personas for quick setup)")
      ("Multiple profile support (switch between personas)")
      ("Import/export settings and profiles")
      ("Enhanced activity pattern visualizations"))

    (v2.0-features
      ("Browser history integration (learn from actual patterns)")
      ("Machine learning for pattern improvement")
      ("Cross-browser profile synchronization")
      ("Localization/i18n support"))

    (v3.0-vision
      ("Mobile browser support")
      ("API for third-party integrations")
      ("Privacy metrics and effectiveness scoring")
      ("Community-contributed profile templates")))

  ;;; =========================================================================
  ;;; CRITICAL NEXT ACTIONS
  ;;; =========================================================================
  (critical-next
    ("Complete WASM integration - replace mocks with actual module loading")
    ("Create production icons at all required sizes")
    ("Test extension loading in Chrome developer mode")
    ("Document any browser-specific issues found")
    ("Prepare for first beta test"))

  ;;; =========================================================================
  ;;; HISTORY / SNAPSHOTS
  ;;; =========================================================================
  (history
    ((date . "2025-12-08")
     (completion . 75)
     (milestone . "STATE.scm created, project state documented")
     (notes . "Prototype complete. Main work remaining: WASM integration,
               icons, browser testing.")))

  ;;; =========================================================================
  ;;; CONTEXT NOTES
  ;;; =========================================================================
  (context-notes
    (tech-stack . "Rust + TypeScript + WebAssembly + Chrome Extensions MV3")
    (philosophy . "Visibility as camouflage - privacy through noise generation")
    (license . "MIT OR Palimpsest-0.8 (dual-licensed)")
    (governance . "TPCF Perimeter 3 (Community Sandbox)")

    (key-files
      ("rust_core/src/lib.rs - WASM bindings and public API")
      ("src/background/index.ts - Service worker orchestration")
      ("src/utils/wasm.ts - WASM interface (currently mocked)")
      ("src/utils/storage.ts - Chrome storage wrapper")
      ("PROJECT_SUMMARY.md - Comprehensive project overview"))

    (external-resources
      ("RSR Framework - Repository quality standards")
      ("TPCF - Tri-Perimeter Contribution Framework"))))

;;; End of STATE.scm
