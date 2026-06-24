<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell (hyperpolymath)
-->

# Changelog

All notable changes to `double-track-browser` will be documented in this file.

This file is generated from conventional commits by the
[`changelog-reusable.yml`](https://github.com/hyperpolymath/standards/blob/main/.github/workflows/changelog-reusable.yml)
workflow (`hyperpolymath/standards#206`). Adopt the workflow in this repo's CI to keep this file in sync automatically — see
[`templates/cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml)
for the canonical config.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- feat(crg): add crg-grade and crg-badge justfile recipes
- feat: add wokelangiser accessibility+consent manifest
- feat: add stapeln.toml container definition
- feat: deploy UX Manifesto infrastructure
- feat: add CLADE.a2ml — clade taxonomy declaration
- feat: implement data poisoning engine with real tab orchestration
- feat(ci): enable Hypatia scanning

### Fixed

- fix(affine): migrate record literals to #{ } (affinescript#218) (#28)
- fix(ci): bump a2ml/k9-validate-action pins to canonical (#25)
- fix(ci): sync hypatia-scan.yml to canonical (#24)
- fix(ci): adopt canonical hypatia-scan.yml (#22)
- fix(ci): hypatia-scan workdir (${{ env.HOME }} resolves empty) (#21)
- fix(ci): rsr-antipattern duplicate heredoc + setup-beam ubuntu24 (#17)
- fix(ci): repair YAML block-scalar in workflow-linter Check Permissions step (#18)
- fix(ci): move secret-scanner Cargo.toml gate from job-level if: to step-level (#19)
- fix(scorecard): enforce granular permissions and add fuzzing placeholder
- fix(ci): Resolve workflow-linter self-matching and metadata issues

### Changed

- refactor(rust_core): migrate rand 0.8 -> 0.9 API (44 build errors -> 0)
- refactor(rust_core): close .expect("TODO: handle error") anti-pattern
- refactor: migrate 6SCM → 6A2 (.scm → .a2ml format)

### Documentation

- docs(governance): CRG v2.0 STRICT audit — C (declared) -> E (honest)
- docs: substantive CRG C annotation (EXPLAINME.adoc)
- docs: add EXPLAINME.adoc — prove-it file backing README claims
- docs: add checkpoint files for state tracking

### CI

- ci: redistribute concurrency-cancel guard to read-only check workflows (#27)
- ci: bump actions/upload-artifact SHA to current v4 (#16)
- ci(dependabot): restore cargo PR limit so security PRs flow (#15)
- ci(secret-scanner): drop duplicate --fail from trufflehog extra_args (#14)
- ci: SHA-pin hyperpolymath validate-actions in dogfood-gate

## Pre-history

Prior commits to this file's introduction are recorded in git history but not formally classified into Keep-a-Changelog sections. To backfill, run `git cliff -o CHANGELOG.md` locally using the canonical [`cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml) — this is one-shot mechanical work.

---

<!-- This file was seeded by the 2026-05-26 estate tech-debt audit follow-up (Row-2 Phase 3); see [`hyperpolymath/standards/docs/audits/2026-05-26-estate-documentation-debt.md`](https://github.com/hyperpolymath/standards/blob/main/docs/audits/2026-05-26-estate-documentation-debt.md). -->
