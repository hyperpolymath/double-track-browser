;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — double-track-browser

(ecosystem
  (version "1.0.0")
  (name "double-track-browser")
  (type "project")
  (purpose "The pendulum has swung way too far on the privacy front.")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "The pendulum has swung way too far on the privacy front.")
  (what-this-is-not "- NOT exempt from RSR compliance"))
