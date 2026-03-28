; SPDX-License-Identifier: PMPL-1.0-or-later
;; guix.scm — GNU Guix package definition for double-track-browser
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "double-track-browser")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "double-track-browser")
  (description "double-track-browser — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/double-track-browser")
  (license ((@@ (guix licenses) license) "PMPL-1.0-or-later"
             "https://github.com/hyperpolymath/palimpsest-license")))
