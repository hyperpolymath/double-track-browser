<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# DoubleTrack Browser — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              USER / BROWSER             │
                        │        (Real & Fictional Personas)      │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           WEBEXTENSIONS LAYER           │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ ReScript  │  │  Background       │  │
                        │  │ UI / PWA  │  │  Orchestrator     │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           RUST CORE (WASM)              │
                        │                                         │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Profile   │  │  Activity         │  │
                        │  │ Generator │  │  Simulator        │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │             DATA LAYER                  │
                        │      (LocalStorage, IndexedDB)          │
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  Deno Tooling       .machine_readable/  │
                        │  wasm-pack          RSR Gold (91%)      │
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
IDENTITY ENGINE (RUST)
  Profile Generator (WASM)          ██████████ 100%    Consistent persona generation
  Activity Simulator                ████████░░  80%    Background noise refining
  Memory-safe core                  ██████████ 100%    Rust ownership verified

EXTENSION LAYERS
  ReScript UI Components            ██████████ 100%    Type-safe interface stable
  Background Orchestrator           ██████████ 100%    Task scheduling active
  WebExtensions Integration         ██████████ 100%    Firefox/Chrome hooks stable

REPO INFRASTRUCTURE
  Deno Build System                 ██████████ 100%    deno task build verified
  .machine_readable/                ██████████ 100%    STATE.a2ml tracking
  Test Coverage (Rust/Deno)         ██████████ 100%    Comprehensive suite active

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            █████████░  ~90%   v0.1.0 RSR Gold Compliant
```

## Key Dependencies

```
Profile Gen ──────► Simulator ──────► Background Script ──────► Browser API
     │                 │                   │                      │
     ▼                 ▼                   ▼                      ▼
Rust Core ──────► WASM Bridge ──────► ReScript UI ─────────► User Dashboard
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
