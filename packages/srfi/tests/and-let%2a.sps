#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rnrs)
  (rnrs eval)
  (srfi :2 and-let*)
  (srfi :78 lightweight-testing))

(define-syntax expect
  (syntax-rules ()
    ((_ expr result)
     (check expr => result))))

(define-syntax must-be-a-syntax-error
  (syntax-rules ()
    ((_ expr)
     (check
       (guard (ex (#T (syntax-violation? ex)))
         (eval 'expr (environment '(rnrs) '(srfi :2 and-let*)))
         'unexpected-return)
       => #T))))

;; Taken from the reference implementation tests

(expect  (and-let* () 1) 1)
(expect  (and-let* () 1 2) 2)
(expect  (and-let* () ) #T)

(expect (let ((x #F)) (and-let* (x))) #F)
(expect (let ((x 1)) (and-let* (x))) 1)
(expect (and-let* ((x #F)) ) #F)
(expect (and-let* ((x 1)) ) 1)
(must-be-a-syntax-error (and-let* ( #F (x 1))) )
(expect (and-let* ( (#F) (x 1)) ) #F)
(must-be-a-syntax-error (and-let* (2 (x 1))) )
(expect (and-let* ( (2) (x 1)) ) 1)
(expect (and-let* ( (x 1) (2)) ) 2)
(expect (let ((x #F)) (and-let* (x) x)) #F)
(expect (let ((x "")) (and-let* (x) x)) "")
(expect (let ((x "")) (and-let* (x)  )) "")
(expect (let ((x 1)) (and-let* (x) (+ x 1))) 2)
(expect (let ((x #F)) (and-let* (x) (+ x 1))) #F)
(expect (let ((x 1)) (and-let* (((positive? x))) (+ x 1))) 2)
(expect (let ((x 1)) (and-let* (((positive? x))) )) #T)
(expect (let ((x 0)) (and-let* (((positive? x))) (+ x 1))) #F)
(expect (let ((x 1)) (and-let* (((positive? x)) (x (+ x 1))) (+ x 1)))  3)
;; Derick thinks variable shadowing should be allowed, because it's a "let*".
#;(must-be-a-syntax-error
  (let ((x 1)) (and-let* (((positive? x)) (x (+ x 1)) (x (+ x 1))) (+ x 1))))

(expect (let ((x 1)) (and-let* (x ((positive? x))) (+ x 1))) 2)
(expect (let ((x 1)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) 2)
(expect (let ((x 0)) (and-let* (x ((positive? x))) (+ x 1))) #F)
(expect (let ((x #F)) (and-let* (x ((positive? x))) (+ x 1))) #F)
(expect (let ((x #F)) (and-let* ( ((begin x)) ((positive? x))) (+ x 1))) #F)

(expect  (let ((x 1)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #F)
(expect  (let ((x 0)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #F)
(expect  (let ((x #F)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) #F)
(expect  (let ((x 3)) (and-let* (x (y (- x 1)) ((positive? y))) (/ x y))) 3/2)

;; Derick's additional tests

(must-be-a-syntax-error (and-let* (("oops" 1))))
(must-be-a-syntax-error (and-let* ((x 1 2))))
(must-be-a-syntax-error (and-let* ((x 1) . oops)))
(expect (let ((x 1))
          (and-let* ((x (+ x 1))
                     (x (+ x 1))
                     (x (+ x 1)))
            (+ x 1)))
        5)
(expect (and-let* () (define x 1) (- x)) -1)
(expect (and-let* ((x 2) (y (+ 1 x))) (define z (* x y)) (/ z)) 1/6)


(check-report)
