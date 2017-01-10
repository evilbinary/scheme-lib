;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s78 lightweight-testing)
  (export
    check
    check-ec
    check-report
    check-set-mode!
    check-reset!
    check-passed?)
  (import 
    (rnrs)
    (surfage s78 lightweight-testing compat)
    (surfage s39 parameters)
    (surfage private include)
    (surfage s23 error tricks)
    (surfage s42 eager-comprehensions))
  
  ;; (SRFI-23-error->R6RS "(library (surfage s78 lightweight-testing))"
  ;;  (include/resolve ("surfage" "%3a78") "check.scm"))

  (SRFI-23-error->R6RS "(library (surfage s78 lightweight-testing))"
   (include/resolve ("surfage" "s78") "check.scm"))
)
