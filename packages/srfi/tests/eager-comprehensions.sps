#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (except (rnrs) error)
  (rnrs mutable-strings)
  (srfi :23 error)
  (srfi private include)
  (srfi :42 eager-comprehensions))

(define (my-open-output-file filename)
  (open-file-output-port filename
                         (file-options no-fail)
                         'block
                         (native-transcoder)))

(define (my-call-with-input-file filename thunk)
  (call-with-input-file filename thunk))

(include/resolve ("srfi" "%3a42") "examples.scm")
