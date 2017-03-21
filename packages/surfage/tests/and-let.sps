;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

#!r6rs
(import 
  (rnrs)
  (rnrs eval)
  (surfage s2 and-let)
  (surfage s78 lightweight-testing))

(define-syntax expect
  (syntax-rules ()
    [(_ expr result)
     (check expr => result)]))

(define-syntax must-be-a-syntax-error
  (syntax-rules ()
    [(_ expr)
     (check 
       (guard (ex [#t (syntax-violation? ex)])  
         (eval 'expr (environment '(rnrs) '(surfage s2 and-let))))
       => #t)]))

;; Taken straight from the reference implementation tests

(expect  (and-let* () 1) 1)
(expect  (and-let* () 1 2) 2)
(expect  (and-let* () ) #t)

(expect (let ((x #f)) (and-let* (x))) #f)
(expect (let ((x 1)) (and-let* (x))) 1)
(expect (and-let* ((x #f)) ) #f)
(expect (and-let* ((x 1)) ) 1)
(must-be-a-syntax-error (and-let* ( #f (x 1))) )
(expect (and-let* ( (#f) (x 1)) ) #f)
(must-be-a-syntax-error (and-let* (2 (x 1))) )
(expect (and-let* ( (2) (x 1)) ) 1)
(expect (and-let* ( (x 1) (2)) ) 2)
(expect (let ((x #f)) (and-let* (x) x)) #f)
(expect (let ((x "")) (and-let* (x) x)) "")
(expect (let ((x "")) (and-let* (x)  )) "")
(expect (let ((x 1)) (and-let* (x) (+ x 1))) 2)
(expect (let ((x #f)) (and-let* (x) (+ x 1))) #f)
(expect (let ((x 1)) (and-let* (((positive? x))) (+ x 1))) 2)
(expect (let ((x 1)) (and-let* (((positive? x))) )) #t)
(expect (let ((x 0)) (and-let* (((positive? x))) (+ x 1))) #f)
(expect (let ((x 1)) (and-let* (((positive? x)) (x (+ x 1))) (+ x 1)))  3)
;; This next one is from the reference implementation tests
;; but I can't see how it "must be a syntax-error".
#;(must-be-a-syntax-error
  (let ((x 1)) (and-let* (((positive? x)) (x (+ x 1)) (x (+ x 1))) (+ x 1))))

(expect (let ((x 1)) (and-let* (x ((positive? x))) (+ x 1))) 2)
(expect (let ((x 1)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) 2)
(expect (let ((x 0)) (and-let* (x ((positive? x))) (+ x 1))) #f)
(expect (let ((x #f)) (and-let* (x ((positive? x))) (+ x 1))) #f)
(expect (let ((x #f)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) #f)

(expect  (let ((x 1)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  (let ((x 0)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  (let ((x #f)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #f)
(expect  (let ((x 3)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) 3/2)

(check-report)
