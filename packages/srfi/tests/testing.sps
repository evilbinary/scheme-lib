#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (except (rnrs base) error)
  (rnrs lists)
  (srfi :23 error)
  (srfi private include)
  (srfi :64 testing))

(include/resolve ("srfi" "%3a64") "srfi-64-test.scm")
