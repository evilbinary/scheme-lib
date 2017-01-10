#!r6rs
;; SRFI 101: Purely Functional Random-Access Pairs and Lists
;; Copyright (c) David Van Horn 2009.  All Rights Reserved.

;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without restriction,
;; including without limitation the rights to use, copy, modify, merge,
;; publish, distribute, sublicense, and/or sell copies of the Software,
;; and to permit persons to whom the Software is furnished to do so,
;; subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. REMEMBER, THERE IS NO SCHEME UNDERGROUND. IN NO EVENT
;; SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
;; DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
;; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
;; THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;; This test suite has been successfully run on Ikarus (0.0.3),
;; Larceny (0.97), and PLT Scheme (4.2.1.7).

;; To run:
;;    cp srfi-101.sls srfi/%3A101.sls
;;    ikarus --r6rs-script srfi-101-tests.sls
;;    larceny -r6rs -path . -program srfi-101-tests.sls
;;    plt-r6rs ++path . srfi-101-tests.sls

(import (except (rnrs base)
                quote pair? cons car cdr 
                caar cadr cddr cdar
                caaar caadr caddr cadar
                cdaar cdadr cdddr cddar
                caaaar caaadr caaddr caadar
                cadaar cadadr cadddr caddar
                cdaaar cdaadr cdaddr cdadar
                cddaar cddadr cddddr cdddar
                null? list? list length 
                append reverse list-tail
                list-ref map for-each)
        (prefix (rnrs base) r6:)
        (rnrs exceptions)
        (surfage s101 random-access-lists))

(define (check-expect c e)
  (if (pair? c)
      (begin (assert (pair? e))
             (check-expect (car c)
                           (car e))
             (check-expect (cdr c)
                           (cdr e)))
      (assert (equal? c e))))

(define-syntax check-error
  (syntax-rules ()
    ((_ e)
     (let ((f (cons 0 0)))
       (guard (g ((eq? f g) (assert #f))
                 (else 'OK))
              (begin e
                     (raise f)))))))

; quote  

; Bug in Larceny prevents this from working
; https://trac.ccs.neu.edu/trac/larceny/ticket/656
;(check-expect (quote 5) (r6:quote 5))
;(check-expect (quote x) (r6:quote x))

(check-expect (let ((f (lambda () '(x))))
                (eq? (f) (f)))
              #t)

(check-expect '(1 2 3) (list 1 2 3))

; pair?
(check-expect (pair? (cons 'a 'b)) #t)
(check-expect (pair? (list 'a 'b 'c)) #t)
(check-expect (pair? '()) #f)
(check-expect (pair? '#(a b)) #f)

; cons
(check-expect (cons 'a '()) (list 'a))
(check-expect (cons (list 'a) (list 'b 'c 'd))
              (list (list 'a) 'b 'c 'd))
(check-expect (cons "a" (list 'b 'c))
              (list "a" 'b 'c))
(check-expect (cons 'a 3)
              (cons 'a 3))
(check-expect (cons (list 'a 'b) 'c)
              (cons (list 'a 'b) 'c))

; car
(check-expect (car (list 'a 'b 'c))
              'a)
(check-expect (car (list (list 'a) 'b 'c 'd))
              (list 'a))
(check-expect (car (cons 1 2)) 1)
(check-error (car '()))

; cdr
(check-expect (cdr (list (list 'a) 'b 'c 'd))
              (list 'b 'c 'd))
(check-expect (cdr (cons 1 2))
              2)
(check-error (cdr '()))

; null?
(check-expect (eq? null? r6:null?) #t)
(check-expect (null? '()) #t)
(check-expect (null? (cons 1 2)) #f)
(check-expect (null? 4) #f)

; list?
(check-expect (list? (list 'a 'b 'c)) #t)
(check-expect (list? '()) #t)
(check-expect (list? (cons 'a 'b)) #f)

; list
(check-expect (list 'a (+ 3 4) 'c)
              (list 'a 7 'c))
(check-expect (list) '())

; make-list
(check-expect (length (make-list 5)) 5)
(check-expect (make-list 5 0)
              (list 0 0 0 0 0))

; length
(check-expect (length (list 'a 'b 'c)) 3)
(check-expect (length (list 'a (list 'b) (list 'c))) 3)
(check-expect (length '()) 0)

; append
(check-expect (append (list 'x) (list 'y)) (list 'x 'y))
(check-expect (append (list 'a) (list 'b 'c 'd)) (list 'a 'b 'c 'd))
(check-expect (append (list 'a (list 'b)) (list (list 'c))) 
              (list 'a (list 'b) (list 'c)))
(check-expect (append (list 'a 'b) (cons 'c 'd)) 
              (cons 'a (cons 'b (cons 'c 'd))))
(check-expect (append '() 'a) 'a)

; reverse
(check-expect (reverse (list 'a 'b 'c))
              (list 'c 'b 'a))
(check-expect (reverse (list 'a (list 'b 'c) 'd (list 'e (list 'f))))
              (list (list 'e (list 'f)) 'd (list 'b 'c) 'a))

; list-tail
(check-expect (list-tail (list 'a 'b 'c 'd) 2)
              (list 'c 'd))

; list-ref
(check-expect (list-ref (list 'a 'b 'c 'd) 2) 'c)

; list-set
(check-expect (list-set (list 'a 'b 'c 'd) 2 'x)
              (list 'a 'b 'x 'd))

; list-ref/update
(let-values (((a b) 
              (list-ref/update (list 7 8 9 10) 2 -)))
  (check-expect a 9)
  (check-expect b (list 7 8 -9 10)))

; map
(check-expect (map cadr (list (list 'a 'b) (list 'd 'e) (list 'g 'h)))
              (list 'b 'e 'h))
(check-expect (map (lambda (n) (expt n n))
                   (list 1 2 3 4 5))
              (list 1 4 27 256 3125))
(check-expect (map + (list 1 2 3) (list 4 5 6))
              (list 5 7 9))

; for-each
(check-expect (let ((v (make-vector 5)))
                (for-each (lambda (i)
                            (vector-set! v i (* i i)))
                          (list 0 1 2 3 4))
                v)
              '#(0 1 4 9 16))

; random-access-list->linear-access-list
; linear-access-list->random-access-list
(check-expect (random-access-list->linear-access-list '()) '())
(check-expect (linear-access-list->random-access-list '()) '())

(check-expect (random-access-list->linear-access-list (list 1 2 3))
              (r6:list 1 2 3))

(check-expect (linear-access-list->random-access-list (r6:list 1 2 3))
              (list 1 2 3))
