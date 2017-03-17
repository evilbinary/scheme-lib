#!r6rs
; CONFIDENCE TEST FOR IMPLEMENTATION OF SRFI-26
; =============================================
;
; Sebastian.Egner@philips.com, 3-Jun-2002.
;
; This file checks a few assertions about the implementation.
; If you run it and no error message is issued, the implementation
; is correct on the cases that have been tested.
;
; compliance:
;   Scheme R5RS with
;     SRFI-23: error
;
; loading this file into Scheme 48 0.57 after 'cut.scm' has been loaded:
;   ,open srfi-23
;   ,load check.scm

; (check expr)
;    evals expr and issues an error if it is not #t.

;; Extended by Derick Eddington to test free-identifier=? of <> and <...>.

(import
  (rnrs)
  (rnrs eval))

(define (check expr)
  (if (not (eq? (eval expr (environment '(rnrs) '(surfage s26 cut)))
                #t))
      (assertion-violation 'check "check failed" expr)))

; (check-all)
;    runs several tests on cut and reports.

(define (check-all)
  (for-each 
   check
   '( ; cuts
     (equal? ((cut list)) '())
     (equal? ((cut list <...>)) '())
     (equal? ((cut list 1)) '(1))
     (equal? ((cut list <>) 1) '(1))
     (equal? ((cut list <...>) 1) '(1))
     (equal? ((cut list 1 2)) '(1 2))
     (equal? ((cut list 1 <>) 2) '(1 2))
     (equal? ((cut list 1 <...>) 2) '(1 2))
     (equal? ((cut list 1 <...>) 2 3 4) '(1 2 3 4))
     (equal? ((cut list 1 <> 3 <>) 2 4) '(1 2 3 4))
     (equal? ((cut list 1 <> 3 <...>) 2 4 5 6) '(1 2 3 4 5 6))
     (equal? (let* ((x 'wrong) (y (cut list x))) (set! x 'ok) (y)) '(ok))
     (equal? 
      (let ((a 0))
	(map (cut + (begin (set! a (+ a 1)) a) <>)
	     '(1 2))
	a)
      2)
     (equal?
      (let* ((<> 'wrong) (f (cut list <> <...>)))
        (set! <> 'ok)
        (f 1 2))
      '(ok 1 2))
     (equal?
      (let* ((<...> 'wrong) (f (cut list <> <...>)))
        (set! <...> 'ok)
        (f 1))
      '(1 ok))
      ; cutes
     (equal? ((cute list)) '())
     (equal? ((cute list <...>)) '())
     (equal? ((cute list 1)) '(1))
     (equal? ((cute list <>) 1) '(1))
     (equal? ((cute list <...>) 1) '(1))
     (equal? ((cute list 1 2)) '(1 2))
     (equal? ((cute list 1 <>) 2) '(1 2))
     (equal? ((cute list 1 <...>) 2) '(1 2))
     (equal? ((cute list 1 <...>) 2 3 4) '(1 2 3 4))
     (equal? ((cute list 1 <> 3 <>) 2 4) '(1 2 3 4))
     (equal? ((cute list 1 <> 3 <...>) 2 4 5 6) '(1 2 3 4 5 6))
     (equal? 
      (let ((a 0))
	(map (cute + (begin (set! a (+ a 1)) a) <>)
	     '(1 2))
	a)
      1)
     (equal?
      (let* ((<> 'ok) (f (cute list <> <...>)))
        (set! <> 'wrong)
        (f 1 2))
      '(ok 1 2))
     (equal?
      (let* ((<...> 'ok) (f (cute list <> <...>)))
        (set! <...> 'wrong)
        (f 1))
      '(1 ok))
     )))

; run the checks when loading
(check-all)
;; (display "passed")
;; (newline)
