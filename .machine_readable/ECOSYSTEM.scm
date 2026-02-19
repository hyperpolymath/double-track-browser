;; SPDX-License-Identifier: PMPL-1.0-or-later
;; ECOSYSTEM.scm - Ecosystem position for double-track-browser
;; Media-Type: application/vnd.ecosystem+scm

(ecosystem
  (version "1.0")
  (name "double-track-browser")
  (type "browser-extension")
  (purpose "Privacy through deliberate visibility — generates fictional browsing personas to poison data collection")

  (position-in-ecosystem
    (category "privacy-tools")
    (subcategory "data-poisoning")
    (unique-value
      ("noise-over-silence" "Creates data abundance rather than hiding — flooding trackers with fictional signals")
      ("hybrid-architecture" "Rust/WASM core for memory-safe persona generation + ReScript browser integration")
      ("consent-aware" "Planned: respects AIBDP manifests and HTTP 430 consent boundaries")))

  (related-projects
    ("defensive-multiplicity" "sibling-standard"
      "Privacy paradigm: security through controlled identity proliferation"
      "Provides: ethical framework, cryptographic accountability, persona lifecycle rules"
      "Path: misinformation-defence-platform/defensive-multiplicity/"
      "Integration: persona generation rules, max lifespan (180 days), watermarking, non-interference")

    ("consent-aware-http" "sibling-standard"
      "Internet-Draft protocols for AI usage boundary declaration"
      "Provides: AIBDP manifest format, HTTP 430 status code, consent negotiation"
      "Path: standards/consent-aware-http/"
      "Integration: check /.well-known/aibdp.json before visiting URLs, honor refusal signals")

    ("maa-framework" "inspiration"
      "Full-stack paradigm for verifiably-compliant secure systems"
      "Provides: Idris2 ABI patterns, formal verification approach, microkernel philosophy"
      "Path: maa-framework/"
      "Integration: Idris2 proofs for identity isolation, Zig FFI for cross-platform ABI")

    ("panic-attacker" "tooling"
      "Security vulnerability scanner"
      "Use: scan extension code for weak points before release")

    ("echidna" "tooling"
      "Formal proof verification"
      "Use: verify identity isolation properties")

    ("hypatia" "tooling"
      "Neurosymbolic CI/CD intelligence"
      "Use: automated security scanning in CI pipeline"))

  (what-this-is
    ("A browser extension that generates realistic but fictional browsing behavior")
    ("A privacy tool that uses noise/abundance rather than concealment")
    ("An implementation of defensive-multiplicity principles for web browsing")
    ("A consent-aware tool that will respect AIBDP site boundaries"))

  (what-this-is-not
    ("Not a VPN or proxy — does not hide real traffic")
    ("Not an ad blocker — does not remove tracking")
    ("Not a Tor alternative — does not anonymize network layer")
    ("Not a bot — all activity is tied to a human-controlled extension with ethical guardrails")))
