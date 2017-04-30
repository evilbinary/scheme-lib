;;;; "factor.scm" factorization, prime test and generation
;;; Copyright (C) 1991, 1992, 1993, 1998 Aubrey Jaffer
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

(require 'modular)
(require 'random)
(require 'byte)

;;@body
;;@0 is the random-state (@pxref{Random Numbers}) used by these
;;procedures.  If you call these procedures from more than one thread
;;(or from interrupt), @code{random} may complain about reentrant
;;calls.
(define prime:prngs
  (make-random-state "repeatable seed for primes"))


;;@emph{Note:} The prime test and generation procedures implement (or
;;use) the Solovay-Strassen primality test. See
;;
;;@itemize @bullet
;;@item Robert Solovay and Volker Strassen,
;;@cite{A Fast Monte-Carlo Test for Primality},
;;SIAM Journal on Computing, 1977, pp 84-85.
;;@end itemize

;;; Solovay-Strassen Prime Test
;;;   if n is prime, then J(a,n) is congruent mod n to a**((n-1)/2)

;;; (modulo p 16) is because we care only about the low order bits.
;;; The odd? tests are inline of (expt -1 ...)

(define (prime:jacobi-symbol p q)
  (cond ((zero? p) 0)
	((= 1 p) 1)
	((odd? p)
	 (if (odd? (quotient (* (- (modulo p 16) 1) (- q 1)) 4))
	     (- (prime:jacobi-symbol (modulo q p) p))
	     (prime:jacobi-symbol (modulo q p) p)))
	(else
	 (let ((qq (modulo q 16)))
	   (if (odd? (quotient (- (* qq qq) 1) 8))
	       (- (prime:jacobi-symbol (quotient p 2) q))
	       (prime:jacobi-symbol (quotient p 2) q))))))
;;@args p q
;;Returns the value (+1, @minus{}1, or 0) of the Jacobi-Symbol of
;;exact non-negative integer @1 and exact positive odd integer @2.
(define jacobi-symbol prime:jacobi-symbol)

;;@body
;;@0 the maxinum number of iterations of Solovay-Strassen that will
;;be done to test a number for primality.
(define prime:trials 30)

;;; checks if n is prime.  Returns #f if not prime. #t if (probably) prime.
;;;   probability of a mistake = (expt 2 (- prime:trials))
;;;     choosing prime:trials=30 should be enough
(define (Solovay-Strassen-prime? n)
  (do ((i prime:trials (- i 1))
       (a (+ 2 (random (- n 2) prime:prngs))
	  (+ 2 (random (- n 2) prime:prngs))))
      ((not (and (positive? i)
		 (= (gcd a n) 1)
		 (= (modulo (prime:jacobi-symbol a n) n)
		    (modular:expt n a (quotient (- n 1) 2)))))
       (not (positive? i)))))

;;; prime:products are products of small primes.
;;; was (comlist:notevery (lambda (prd) (= 1 (gcd n prd))) comps))
(define (primes-gcd? n comps)
  (not (let mapf ((lst comps))
	 (or (null? lst) (and (= 1 (gcd n (car lst))) (mapf (cdr lst)))))))
(define prime:prime-sqr 121)
(define prime:products '(105))
(define prime:sieve (bytes 0 0 1 1 0 1 0 1 0 0 0))
(letrec ((lp (lambda (comp comps primes nexp)
	       (cond ((< comp (quotient most-positive-fixnum nexp))
		      (let ((ncomp (* nexp comp)))
			(lp ncomp comps
			    (cons nexp primes)
			    (next-prime nexp (cons ncomp comps)))))
		     ((< (quotient comp nexp) (* nexp nexp))
		      (set! prime:prime-sqr (* nexp nexp))
		      (set! prime:sieve (make-bytes nexp 0))
		      (for-each (lambda (prime)
				  (byte-set! prime:sieve prime 1))
				primes)
		      (set! prime:products (reverse (cons comp comps))))
		     (else
		      (lp nexp (cons comp comps)
			  (cons nexp primes)
			  (next-prime nexp (cons comp comps)))))))
	 (next-prime (lambda (nexp comps)
		       (set! comps (reverse comps))
		       (do ((nexp (+ 2 nexp) (+ 2 nexp)))
			   ((not (primes-gcd? nexp comps)) nexp)))))
  (lp 3 '() '(2 3) 5))

(define (prime:prime? n)
  (set! n (abs n))
  (cond ((< n (bytes-length prime:sieve)) (positive? (byte-ref prime:sieve n)))
	((even? n) #f)
	((primes-gcd? n prime:products) #f)
	((< n prime:prime-sqr) #t)
	(else (Solovay-Strassen-prime? n))))
;;@args n
;;Returns @code{#f} if @1 is composite; @code{#t} if @1 is prime.
;;There is a slight chance @code{(expt 2 (- prime:trials))} that a
;;composite will return @code{#t}.
(define prime? prime:prime?)

(define (prime:prime< start)
  (do ((nbr (+ -1 start) (+ -1 nbr)))
      ((or (negative? nbr) (prime:prime? nbr))
       (if (negative? nbr) #f nbr))))

;;@body
;;Returns a list of the first @2 prime numbers less than
;;@1.  If there are fewer than @var{count} prime numbers
;;less than @var{start}, then the returned list will have fewer than
;;@var{start} elements.
(define (primes< start count)
  (do ((cnt (+ -2 count) (+ -1 cnt))
       (lst '() (cons prime lst))
       (prime (prime:prime< start) (prime:prime< prime)))
      ((or (not prime) (negative? cnt))
       (if prime (cons prime lst) lst))))

(define (prime:prime> start)
  (do ((nbr (+ 1 start) (+ 1 nbr)))
      ((prime:prime? nbr) nbr)))

;;@body
;;Returns a list of the first @2 prime numbers greater than @1.
(define (primes> start count)
  (set! start (max 0 start))
  (do ((cnt (+ -2 count) (+ -1 cnt))
       (lst '() (cons prime lst))
       (prime (prime:prime> start) (prime:prime> prime)))
      ((negative? cnt)
       (reverse (cons prime lst)))))

;;;;Lankinen's recursive factoring algorithm:
;From: ld231782@longs.LANCE.ColoState.EDU (L. Detweiler)

;                  |  undefined if n<0,
;                  |  (u,v) if n=0,
;Let f(u,v,b,n) := | [otherwise]
;                  |  f(u+b,v,2b,(n-v)/2) or f(u,v+b,2b,(n-u)/2) if n odd
;                  |  f(u,v,2b,n/2) or f(u+b,v+b,2b,(n-u-v-b)/2) if n even

;Thm: f(1,1,2,(m-1)/2) = (p,q) iff pq=m for odd m.

;It may be illuminating to consider the relation of the Lankinen function in
;a `computational hierarchy' of other factoring functions.*  Assumptions are
;made herein on the basis of conventional digital (binary) computers.  Also,
;complexity orders are given for the worst case scenarios (when the number to
;be factored is prime).  However, all algorithms would probably perform to
;the same constant multiple of the given orders for complete composite
;factorizations.

;Thm: Eratosthenes' Sieve is very roughtly O(ln(n)/n) in time and
;     O(n*log2(n)) in space.
;Pf: It works with all prime factors less than n (about ln(n)/n by the prime
;    number thm), requiring an array of size proportional to n with log2(n)
;    space for each entry.

;Thm: `Odd factors' is O((sqrt(n)/2)*log2(n)) in time and O(log2(n)) in
;     space.
;Pf: It tests all odd factors less than the square root of n (about
;    sqrt(n)/2), with log2(n) time for each division.  It requires only
;    log2(n) space for the number and divisors.

;Thm: Lankinen's algorithm is O(sqrt(n)/2) in time and O((sqrt(n)/2)*log2(n))
;     in space.
;Pf: The algorithm is easily modified to seach only for factors p<q for all
;    pq=m.  Then the recursive call tree forms a geometric progression
;    starting at one, and doubling until reaching sqrt(n)/2, or a length of
;    log2(sqrt(n)/2).  From the formula for a geometric progression, there is
;    a total of about 2^log2(sqrt(n)/2) = sqrt(n)/2 calls.  Assuming that
;    addition, subtraction, comparison, and multiplication/division by two
;    occur in constant time, this implies O(sqrt(n)/2) time and a
;    O((sqrt(n)/2)*log2(n)) requirement of stack space.

(define (prime:f u v b n)
  (if (<= n 0)
      (cond ((negative? n) #f)
	    ((= u 1) #f)
	    ((= v 1) #f)
	    ; Do both of these factors need to be factored?
	    (else (append (or (prime:f 1 1 2 (quotient (- u 1) 2))
			      (list u))
			  (or (prime:f 1 1 2 (quotient (- v 1) 2))
			      (list v)))))
      (if (even? n)
	  (or (prime:f u v (+ b b) (quotient n 2))
	      (prime:f (+ u b) (+ v b) (+ b b) (quotient (- n (+ u v b)) 2)))
	  (or (prime:f (+ u b) v (+ b b) (quotient (- n v) 2))
	      (prime:f u (+ v b) (+ b b) (quotient (- n u) 2))))))

(define (prime:fo m)
  (let* ((s (gcd m (car prime:products)))
	 (r (quotient m s)))
    (if (= 1 s)
	(or (prime:f 1 1 2 (quotient (- m 1) 2)) (list m))
	(append
	 (if (= 1 r) '()
	     (or (prime:f 1 1 2 (quotient (- r 1) 2)) (list r)))
	 (or (prime:f 1 1 2 (quotient (- s 1) 2)) (list s))))))

(define (prime:fe m)
  (if (even? m)
      (cons 2 (prime:fe (quotient m 2)))
      (if (eqv? 1 m)
	  '()
	  (prime:fo m))))

;;@body
;;Returns a list of the prime factors of @1.  The order of the
;;factors is unspecified.  In order to obtain a sorted list do
;;@code{(sort! (factor @var{k}) <)}.
(define (factor k)
  (case k
    ((-1 0 1) (list k))
    (else (if (negative? k)
	      (cons -1 (prime:fe (- k)))
	      (prime:fe k)))))
