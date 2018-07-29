#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (except (rnrs) display newline)
  (srfi :78 lightweight-testing)
  (srfi private include)
  (srfi :26 cut))

(define (ignore . _) (values))
(define display ignore)
(define newline ignore)
(define check-all ignore)

(let-syntax ((define (syntax-rules (check check-all for-each quote equal?)
                       ((_ (check _) . _)
                        (begin))
                       ((_ (check-all) (for-each check '((equal? expr val) ...)))
                        (begin (check expr => val) ...)))))
  (include/resolve ("srfi" "%3a26") "check.scm"))

;;;; free-identifier=? of <> and <...>

(check
 (let* ((<> 'wrong) (f (cut list <> <...>)))
   (set! <> 'ok)
   (f 1 2))
 => '(ok 1 2))
(check
 (let* ((<...> 'wrong) (f (cut list <> <...>)))
   (set! <...> 'ok)
   (f 1))
 => '(1 ok))
(check
 (let* ((<> 'ok) (f (cute list <> <...>)))
   (set! <> 'wrong)
   (f 1 2))
 => '(ok 1 2))
(check
 (let* ((<...> 'ok) (f (cute list <> <...>)))
   (set! <...> 'wrong)
   (f 1))
 => '(1 ok))

(check-report)
