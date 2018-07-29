#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rnrs)
  (rnrs r5rs)
  (srfi :42 eager-comprehensions)
  (srfi private include)
  (srfi :78 lightweight-testing))

(include/resolve ("srfi" "%3a78") "examples.scm")
