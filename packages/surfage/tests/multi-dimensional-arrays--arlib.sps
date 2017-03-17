#!r6rs
;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

(import
  (rnrs)
  (surfage s25 multi-dimensional-arrays)
  (surfage s25 multi-dimensional-arrays arlib)
  (surfage s78 lightweight-testing)
  (srfi private include))

(define-syntax past (syntax-rules () ((_ . r) (begin))))

(let-syntax ((or
              (syntax-rules (error)
                ((_ expr (error msg))
                 (check expr => #T))
                ((_ . r) (or . r)))))
  (include/resolve ("srfi" "%3a25") "list.scm"))

(check-report)
