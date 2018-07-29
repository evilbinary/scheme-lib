#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (except (rnrs) error)
  (rnrs r5rs)
  (srfi :23 error)
  (srfi private include)
  (srfi :27 random-bits))

(define eval 'ignore)
(define interaction-environment 'ignore)

(define ascii->char integer->char)

(include/resolve ("srfi" "%3a27") "conftest.scm")

(check-mrg32k3a)
(display "passed (check-mrg32k3a)\n")
