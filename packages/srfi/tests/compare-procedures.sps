#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (except (rnrs) error)
  (rnrs r5rs)
  (rename (only (rnrs) write) (write pretty-write))
  (srfi :23 error)
  (srfi :42 eager-comprehensions)
  (srfi private include)
  (srfi :67 compare-procedures))

(include/resolve ("srfi" "%3a67") "examples.scm")
