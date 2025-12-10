;; double-track-browser - Guix Package Definition
;; Run: guix shell -D -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system node)
             ((guix licenses) #:prefix license:)
             (gnu packages base))

(define-public double_track_browser
  (package
    (name "double-track-browser")
    (version "0.1.0")
    (source (local-file "." "double-track-browser-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system node-build-system)
    (synopsis "JavaScript/Node.js application")
    (description "JavaScript/Node.js application - part of the RSR ecosystem.")
    (home-page "https://github.com/hyperpolymath/double-track-browser")
    (license license:agpl3+)))

;; Return package for guix shell
double_track_browser
