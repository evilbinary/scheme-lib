#!r6rs
;; Copyright 2009 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rnrs)
  (srfi :25 multi-dimensional-arrays)
  (srfi :78 lightweight-testing)
  (srfi private include))

(let-syntax ((or
              (syntax-rules (error)
                ((_ expr (error msg))
                 (check (and expr #T) => #T))
                ((_ . r) (or . r))))
             (past
              (syntax-rules ()
                ((_ . r) (values)))))
  (include/resolve ("srfi" "%3a25") "test.scm"))

(check-report)
