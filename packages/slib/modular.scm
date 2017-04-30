;;;; "modular.scm", modular fixnum arithmetic for Scheme
;;; Copyright (C) 1991, 1993, 1995, 2001, 2002, 2006 Aubrey Jaffer
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

;;@code{(require 'modular)}
;;@ftindex modular

;;@args n1 n2
;;Returns a list of 3 integers @code{(d x y)} such that d = gcd(@var{n1},
;;@var{n2}) = @var{n1} * x + @var{n2} * y.
(define (extended-euclid x y)
  (define q 0)
  (do ((r0 x r1) (r1 y (remainder r0 r1))
       (u0 1 u1) (u1 0 (- u0 (* q u1)))
       (v0 0 v1) (v1 1 (- v0 (* q v1))))
      ((zero? r1) (list r0 u0 v0))
    (set! q (quotient r0 r1))))

(define modular:extended-euclid extended-euclid)

;;@body
;;For odd positive integer @1, returns an object suitable for passing
;;as the first argument to @code{modular:} procedures, directing them
;;to return a symmetric modular number, ie. an @var{n} such that
;;@example
;;(<= (quotient @var{m} -2) @var{n} (quotient @var{m} 2)
;;@end example
(define (symmetric:modulus m)
  (cond ((or (not (number? m)) (not (positive? m)) (even? m))
	 (slib:error 'symmetric:modulus m))
	(else (quotient (+ -1 m) -2))))

;;@args modulus
;;Returns the non-negative integer characteristic of the ring formed when
;;@var{modulus} is used with @code{modular:} procedures.
(define (modular:characteristic m)
  (cond ((negative? m) (- 1 (+ m m)))
	((zero? m) #f)
	(else m)))

;;@args modulus n
;;Returns the integer @code{(modulo @var{n} (modular:characteristic
;;@var{modulus}))} in the representation specified by @var{modulus}.
(define modular:normalize
  (if (provided? 'bignum)
      (lambda (m k)
	(cond ((positive? m) (modulo k m))
	      ((zero? m) k)
	      ((<= m k (- m)) k)
	      (else
	       (let* ((pm (+ 1 (* -2 m)))
		      (s (modulo k pm)))
		 (if (<= s (- m)) s (- s pm))))))
      (lambda (m k)
	(cond ((positive? m) (modulo k m))
	      ((zero? m) k)
	      ((<= m k (- m)) k)
	      ((<= m (quotient (+ -1 most-positive-fixnum) 2))
	       (let* ((pm (+ 1 (* -2 m)))
		      (s (modulo k pm)))
		 (if (<= s (- m)) s (- s pm))))
	      ((positive? k) (+ (+ (+ k -1) m) m))
	      (else  (- (- (+ k 1) m) m))))))

;;;; NOTE: The rest of these functions assume normalized arguments!

;;@noindent
;;The rest of these functions assume normalized arguments; That is, the
;;arguments are constrained by the following table:
;;
;;@noindent
;;For all of these functions, if the first argument (@var{modulus}) is:
;;@table @code
;;@item positive?
;;Integers mod @var{modulus}.  The result is between 0 and
;;@var{modulus}.
;;
;;@item zero?
;;The arguments are treated as integers.  An integer is returned.
;;@end table
;;
;;@noindent
;;Otherwise, if @var{modulus} is a value returned by
;;@code{(symmetric:modulus @var{radix})}, then the arguments and
;;result are treated as members of the integers modulo @var{radix},
;;but with @dfn{symmetric} representation; i.e.
;;@example
;;(<= (quotient @var{radix} 2) @var{n} (quotient (- -1 @var{radix}) 2)
;;@end example

;;@noindent
;;If all the arguments are fixnums the computation will use only fixnums.

;;@args modulus k
;;Returns @code{#t} if there exists an integer n such that @var{k} * n
;;@equiv{} 1 mod @var{modulus}, and @code{#f} otherwise.
(define (modular:invertable? m a)
  (eqv? 1 (gcd (or (modular:characteristic m) 0) a)))

;;@args modulus n2
;;Returns an integer n such that 1 = (n * @var{n2}) mod @var{modulus}.  If
;;@var{n2} has no inverse mod @var{modulus} an error is signaled.
(define (modular:invert m a)
  (define (barf) (slib:error 'modular:invert "can't invert" m a))
  (cond ((eqv? 1 (abs a)) a)		; unit
	(else
	 (let ((pm (modular:characteristic m)))
	   (cond
	    (pm
	     (let ((d (modular:extended-euclid (modular:normalize pm a) pm)))
	       (if (= 1 (car d))
		   (modular:normalize m (cadr d))
		   (barf))))
	    (else (barf)))))))

;;@args modulus n2
;;Returns (@minus{}@var{n2}) mod @var{modulus}.
(define (modular:negate m a)
  (cond ((zero? a) 0)
	((negative? m) (- a))
	(else (- m a))))

;;; Being careful about overflow here

;;@args modulus n2 n3
;;Returns (@var{n2} + @var{n3}) mod @var{modulus}.
(define (modular:+ m a b)
  (cond ((positive? m) (modulo (+ (- a m) b) m))
	((zero? m) (+ a b))
	;; m is negative
	((negative? a)
	 (if (negative? b)
	     (let ((s (+ (- a m) b)))
	       (if (negative? s)
		   (- s (+ -1 m))
		   (+ s m)))
	     (+ a b)))
	((negative? b) (+ a b))
	(else (let ((s (+ (+ a m) b)))
		(if (positive? s)
		    (+ s -1 m)
		    (- s m))))))

;;@args modulus n2 n3
;;Returns (@var{n2} @minus{} @var{n3}) mod @var{modulus}.
(define (modular:- m a b)
  (modular:+ m a (modular:negate m b)))

;;; See: L'Ecuyer, P. and Cote, S. "Implementing a Random Number Package
;;; with Splitting Facilities." ACM Transactions on Mathematical
;;; Software, 17:98-111 (1991)

;;; modular:r = 2**((nb-2)/2) where nb = number of bits in a word.
(define modular:r
  (do ((mpf most-positive-fixnum (quotient mpf 4))
       (r 1 (* 2 r)))
      ((<= mpf 0) (quotient r 2))))

;;@args modulus n2 n3
;;Returns (@var{n2} * @var{n3}) mod @var{modulus}.
;;
;;The Scheme code for @code{modular:*} with negative @var{modulus} is
;;not completed for fixnum-only implementations.
(define modular:*
  (if (provided? 'bignum)
      (lambda (m a b)
	(cond ((zero? m) (* a b))
	      ((positive? m) (modulo (* a b) m))
	      (else (modular:normalize m (* a b)))))
      (lambda (m a b)
	(define a0 a)
	(define p 0)
	(cond
	 ((zero? m) (* a b))
	 ((negative? m)
	  ;; Need algorighm to work with symmetric representation.
	  (modular:normalize m (* (modular:normalize m a)
				  (modular:normalize m b))))
	 (else
	  (set! a (modulo a m))
	  (set! b (modulo b m))
	  (set! a0 a)
	  (cond ((< a modular:r))
		((< b modular:r) (set! a b) (set! b a0) (set! a0 a))
		(else
		 (set! a0 (modulo a modular:r))
		 (let ((a1 (quotient a modular:r))
		       (qh (quotient m modular:r))
		       (rh (modulo m modular:r)))
		   (cond ((>= a1 modular:r)
			  (set! a1 (- a1 modular:r))
			  (set! p (modulo (- (* modular:r (modulo b qh))
					     (* (quotient b qh) rh)) m))))
		   (cond ((not (zero? a1))
			  (let ((q (quotient m a1)))
			    (set! p (- p (* (quotient b q) (modulo m a1))))
			    (set! p (modulo (+ (if (positive? p) (- p m) p)
					       (* a1 (modulo b q))) m)))))
		   (set! p (modulo (- (* modular:r (modulo p qh))
				      (* (quotient p qh) rh)) m)))))
	  (if (zero? a0)
	      p
	      (let ((q (quotient m a0)))
		(set! p (- p (* (quotient b q) (modulo m a0))))
		(modulo (+ (if (positive? p) (- p m) p)
			   (* a0 (modulo b q))) m))))))))

;;@args modulus n2 n3
;;Returns (@var{n2} ^ @var{n3}) mod @var{modulus}.
(define (modular:expt m base xpn)
  (cond ((zero? m) (expt base xpn))
	((= base 1) 1)
	((if (negative? m) (= -1 base) (= (- m 1) base))
	 (if (odd? xpn) base 1))
	((negative? xpn)
	 (modular:expt m (modular:invert m base) (- xpn)))
	((zero? base) 0)
	(else
	 (do ((x base (modular:* m x x))
	      (j xpn (quotient j 2))
	      (acc 1 (if (even? j) acc (modular:* m x acc))))
	     ((<= j 1)
	      (case j
		((0) acc)
		((1) (modular:* m x acc))))))))
