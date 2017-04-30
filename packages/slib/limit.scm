;;; "limit.scm" Scheme Implementation of one-side limit algorithm.
;Copyright 2005 Aubrey Jaffer
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

;;@code{(require 'limit)}

(require-if 'compiling 'root)

(define (finite? val)
  (and (not (= val (+ 1 val val)))
       (= val val)))

(define (inv-root f1 f2 f3 prec)
  (define f1^2 (* f1 f1))
  (define f2^2 (* f2 f2))
  (define f3^2 (expt f3 2))
  (require 'root)			; SLIB
  (newton:find-root (lambda (f0)
		      (+ (- (* (expt f0 2) f1))
			 (* f0 f1^2)
			 (* (- (* 2 (expt f0 2)) (* 3 f1^2)) f2)
			 (* (+ (- (* 2 f0)) (* 3 f1)) f2^2)
			 (* (- (+ (- (expt f0 2)) (* 2 f1^2)) f2^2)
			    f3)
			 (* (+ (- f0 (* 2 f1)) f2) f3^2)))
		    (lambda (f0)
		      (+ (- (+ (* -2 f0 f1) f1^2 (* 4 f0 f2))
			    (* 2 f2^2)
			    (* 2 f0 f3))
			 f3^2))
		    f1
		    prec))

(define (invintp f1 f2 f3)
  (define f1^2 (* f1 f1))
  (define f2^2 (* f2 f2))
  (define f3^2 (expt f3 2))
  (let ((c (+ (* -3 f1^2 f2)
	      (* 3 f1 f2^2)
	      (* (- (* 2 f1^2) f2^2) f3)
	      (* (- f2 (* 2 f1)) f3^2)))
	(b (+ (- f1^2 (* 2 f2^2)) f3^2))
	(a (- (* 2 f2) f1 f3)))
    (define disc (- (* b b) (* 4 a c)))
    ;;(printf "discriminant: %g\n" disc)
        (if (negative? (real-part disc))
	(/ b -2 a)
	(let ((sqrt-disc (sqrt disc)))
	  (define root+ (/ (- sqrt-disc b) 2 a))
	  (define root- (/ (+ sqrt-disc b) -2 a))
	  (if (< (magnitude (- root+ f1)) (magnitude (- root- f1)))
	      root+
	      root-)))))

(define (extrapolate-0 fs)
  (define n (length fs))
  (define (choose n k)
    (do ((kdx 1 (+ 1 kdx))
	 (prd 1 (/ (* (- n kdx -1) prd) kdx)))
	((> kdx k) prd)))
  (do ((k 1 (+ 1 k))
       (lst fs (cdr lst))
       (L 0 (+ (* -1 (expt -1 k) (choose n k) (car lst)) L)))
      ((null? lst) L)))

(define (sequence->limit proc sequence)
  (define lval (proc (car sequence)))
  (if (finite? lval)
      (let ((val (proc (cadr sequence))))
	(define h_n*nsamps (* (length sequence) (magnitude (- val lval))))
	(if (finite? val)
	    (let loop ((sequence (cddr sequence))
		       (fxs (list val lval))
		       (trend #f)
		       (ldelta (- val lval))
		       (jdx (+ -1 (length sequence))))
	      (cond ((null? sequence)
		     (case trend
		       ((diverging) (and (real? val) (/ ldelta 0.0)))
		       ((bounded) (invintp val lval (caddr fxs)))
		       (else (cond ((zero? ldelta) val)
				   ((not (real? val)) #f)
				   (else (extrapolate-0 fxs))))))
		    (else
		     (set! lval val)
		     (set! val (proc (car sequence)))
		     ;;(printf "f(%12g)=%12g; delta=%12g hyp=%12g j=%3d %s\n" (car sequence) val (- val lval) (/ h_n*nsamps jdx) jdx (or trend ""))
		     (if (finite? val)
			 (let ((delta (- val lval)))
			   (define h_j (/ h_n*nsamps jdx))
			   (cond ((case trend
				    ((converging) (<= (magnitude delta) h_j))
				    ((bounded)    (<= (magnitude ldelta) (magnitude delta)))
				    ((diverging)  (>= (magnitude delta) h_j))
				    (else #f))
				  (loop (cdr sequence) (cons val fxs) trend delta (+ -1 jdx)))
				 (trend #f)
				 (else
				  (loop (cdr sequence) (cons val fxs)
					(cond ((> (magnitude delta) h_j) 'diverging)
					      ((< (magnitude ldelta) (magnitude delta)) 'bounded)
					      (else 'converging))
					delta (+ -1 jdx)))))
			 (and (eq? trend 'diverging) val)))))
	    (and (real? val) val)))
      (and (real? lval) lval)))

(define (limit proc x1 x2 . k)
  (set! k (if (null? k) 8 (car k)))
  (cond ((not (finite? x2)) (slib:error 'limit 'infinite 'x2 x2))
	((not (finite? x1))
	 (or (positive? (* x1 x2)) (slib:error 'limit 'start 'mismatch x1 x2))
	 (limit (lambda (x) (proc (/ x))) 0.0 (/ x2) k))
	((= x1 (+ x1 x2)) (slib:error 'limit 'null 'range x1 (+ x1 x2)))
	(else (let ((dec (/ x2 k)))
		(do ((x (+ x1 x2 0.0) (- x dec))
		     (cnt (+ -1 k) (+ -1 cnt))
		     (lst '() (cons x lst)))
		    ((negative? cnt)
		     (sequence->limit proc (reverse lst))))))))
