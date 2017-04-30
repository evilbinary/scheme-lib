; "peanosfc.scm": Peano space filling mapping
; Copyright (C) 2005, 2006 Aubrey Jaffer
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

(require 'array)

;;@code{(require 'peano-fill)}
;;@ftindex peano-fill

;;; A. R. Butz.
;;; Space filling curves and mathematical programming.
;;; Information and Control, 12:314-330, 1968. 

(define (natural->trit-array scalar rank)
  (do ((trits '() (cons (modulo scl 3) trits))
       (scl scalar (quotient scl 3)))
      ((zero? scl)
       (let ((depth (quotient (+ (length trits) rank -1) rank)))
	 (define tra (make-array (A:fixZ8b 0) rank depth))
	 (set! trits (reverse trits))
	 (do ((idx (+ -1 depth) (+ -1 idx)))
	     ((negative? idx))
	   (do ((rdx 0 (+ 1 rdx)))
	       ((>= rdx rank))
	     (cond ((null? trits))
		   (else (array-set! tra (car trits) rdx idx)
			 (set! trits (cdr trits))))))
	 tra))))

(define (trit-array->natural tra)
  (define rank (car (array-dimensions tra)))
  (define depth (cadr (array-dimensions tra)))
  (define val 0)
  (do ((idx 0 (+ 1 idx)))
      ((>= idx depth) val)
    (do ((rdx (+ -1 rank) (+ -1 rdx)))
	((negative? rdx))
      (set! val (+ (array-ref tra rdx idx) (* 3 val))))))

(define (trit-array->natural-coordinates tra)
  (define depth (cadr (array-dimensions tra)))
  (do ((rdx (+ -1 (car (array-dimensions tra))) (+ -1 rdx))
       (lst '() (cons (do ((idx 0 (+ 1 idx))
			   (val 0 (+ (array-ref tra rdx idx) (* 3 val))))
			  ((>= idx depth) val))
		      lst)))
      ((negative? rdx) lst)))

(define (natural-coordinates->trit-array coords)
  (define depth (do ((scl (apply max coords) (quotient scl 3))
		     (dpt 0 (+ 1 dpt)))
		    ((zero? scl) dpt)))
  (let ((tra (make-array (A:fixN8b 0) (length coords) depth)))
    (do ((rdx 0 (+ 1 rdx))
	 (cds coords (cdr cds)))
	((null? cds))
      (do ((idx (+ -1 depth) (+ -1 idx))
	   (scl (car cds) (quotient scl 3)))
	  ((negative? idx))
	(array-set! tra (modulo scl 3) rdx idx)))
    tra))

(define (peano-flip! tra)
  (define parity 0)
  (define rank (car (array-dimensions tra)))
  (define depth (cadr (array-dimensions tra)))
  (define rra (make-array (A:fixN8b 0) (car (array-dimensions tra))))
  (do ((idx 0 (+ 1 idx)))
      ((>= idx depth))
    (do ((rdx (+ -1 rank) (+ -1 rdx)))
	((negative? rdx))
      (let ((v_ij (array-ref tra rdx idx)))
	(if (odd? (+ parity (array-ref rra rdx)))
	    (array-set! tra (- 2 v_ij) rdx idx))
	(set! parity (modulo (+ v_ij parity) 2))
	(array-set! rra (modulo (+ v_ij (array-ref rra rdx)) 2) rdx)))))

;;@body
;;Returns a list of @2 nonnegative integer coordinates corresponding
;;to exact nonnegative integer @1.  The lists returned by @0 for @1
;;arguments 0 and 1 will differ in the first element.
(define (natural->peano-coordinates scalar rank)
  (define tra (natural->trit-array scalar rank))
  (peano-flip! tra)
  (trit-array->natural-coordinates tra))

;;@body
;;Returns an exact nonnegative integer corresponding to @1, a list of
;;nonnegative integer coordinates.
(define (peano-coordinates->natural coords)
  (define tra (natural-coordinates->trit-array coords))
  (peano-flip! tra)
  (trit-array->natural tra))

;;@body
;;Returns a list of @2 integer coordinates corresponding to exact
;;integer @1.  The lists returned by @0 for @1 arguments 0 and 1 will
;;differ in the first element.
(define (integer->peano-coordinates scalar rank)
  (define nine^rank (expt 9 rank))
  (do ((edx 1 (* edx nine^rank))
       (cdx 1 (* cdx 9)))
      ((>= (quotient edx 2) (abs scalar))
       (let ((tra (natural->trit-array (+ scalar (quotient edx 2)) rank))
	     (offset (quotient cdx 2)))
	 (peano-flip! tra)
	 (map (lambda (k) (- k offset))
	      (trit-array->natural-coordinates tra))))))

;;@body
;;Returns an exact integer corresponding to @1, a list of integer
;;coordinates.
(define (peano-coordinates->integer coords)
  (define nine^rank (expt 9 (length coords)))
  (define cobs (apply max (map abs coords)))
  (let loop ((edx 1) (cdx 1))
    (define offset (quotient cdx 2))
    (if (>= offset cobs)
	(let ((tra (natural-coordinates->trit-array
		    (map (lambda (elt) (+ elt offset))
			 coords))))
	  (peano-flip! tra)
	  (- (trit-array->natural tra)
	     (quotient edx 2)))
	(loop (* nine^rank edx) (* 9 cdx)))))
