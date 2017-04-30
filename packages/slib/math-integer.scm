; "math-integer.scm": mathematical functions restricted to exact integers
; Copyright (C) 2006, 2013 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require 'logical)			; srfi-60

;;@code{(require 'math-integer)}
;;@ftindex math-integer

;;@body
;;Returns @1 raised to the power @2 if that result is an exact
;;integer; otherwise signals an error.
;;
;;@code{(integer-expt 0 @2)}
;;
;;returns 1 for @2 equal to 0;
;;returns 0 for positive integer @2;
;;signals an error otherwise.
(define (integer-expt n1 n2)
  (cond ((and (exact? n1) (integer? n1)
	      (exact? n2) (integer? n2)
	      (not (and (not (<= -1 n1 1)) (negative? n2))))
	 (expt n1 n2))
	(else (slib:error 'integer-expt n1 n2))))

;;@body
;;Returns the largest exact integer whose power of @1 is less than or
;;equal to @2. If @1 or @2 is not a positive exact integer, then
;;@0 signals an error.
(define (integer-log base k)
  (define (ilog m b k)
    (cond ((< k b) k)
	  (else
	   (set! n (+ n m))
	   (let ((q (ilog (+ m m) (* b b) (quotient k b))))
	     (cond ((< q b) q)
		   (else (set! n (+ m n))
			 (quotient q b)))))))
  (define n 1)
  (define (eigt? k j) (and (exact? k) (integer? k) (> k j)))
  (cond ((not (and (eigt? base 1) (eigt? k 0)))
	 (slib:error 'integer-log base k))
	((< k base) 0)
	(else (ilog 1 base (quotient k base)) n)))

;;;; http://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/lang/lisp/code/math/isqrt/isqrt.txt
;;; Akira Kurihara
;;; School of Mathematics
;;; Japan Women's University

;;@args k
;;For non-negative integer @1 returns the largest integer whose square
;;is less than or equal to @1; otherwise signals an error.
(define integer-sqrt
  (let ((table '#(0
		  1 1 1
		  2 2 2 2 2
		  3 3 3 3 3 3 3
		  4 4 4 4 4 4 4 4 4))
	(square (lambda (x) (* x x))))
    (lambda (n)
      (define (isqrt n)
	(if (> n 24)
	    (let* ((len/4 (quotient (- (integer-length n) 1) 4))
		   (top (isqrt (ash n (* -2 len/4))))
		   (init (ash top len/4))
		   (q (quotient n init))
		   (iter (quotient (+ init q) 2)))
	      (cond ((odd? q) iter)
		    ((< (remainder n init) (square (- iter init))) (- iter 1))
		    (else iter)))
	    (vector-ref table n)))
      (if (and (exact? n) (integer? n) (not (negative? n)))
	  (isqrt n)
	  (slib:error 'integer-sqrt n)))))

(define (must-be-exact-integer2 name proc)
  (lambda (n1 n2)
    (if (and (integer? n1) (integer? n2) (exact? n1) (exact? n2)
	     (not (zero? n2)))
	(proc n1 n2)
	(slib:error name n1 n2))))
;;@args n1 n2
;;@defunx remainder n1 n2
;;@defunx modulo n1 n2
;;are redefined so that they accept only exact-integer arguments.
(define quotient  (must-be-exact-integer2 'quotient quotient))
(define remainder (must-be-exact-integer2 'remainder remainder))
(define modulo    (must-be-exact-integer2 'modulo modulo))

;;@args n1 n2
;;Returns the quotient of @1 and @2 rounded toward even.
;;
;;@example
;;(quotient 3 2)        @result{} 1
;;(round-quotient 3 2)  @result{} 2
;;@end example
(define (round-quotient num den)
  (define quo (quotient num den))
  (define rem (remainder num den))
  (if ((if (even? quo) > >=) (abs (* 2 rem)) (abs den))
      (+ quo (if (eq? (negative? num) (negative? den)) 1 -1))      
      quo))
