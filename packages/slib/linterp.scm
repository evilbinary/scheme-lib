;;; "linterp.scm" Interpolate array access.
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

;;@code{(require 'array-interpolate)}

(require 'array)
(require 'subarray)
(require 'array-for-each)
(require 'multiarg-apply)

;;@args ra x1 ... xj
;;
;;@1 must be an array of rank j containing numbers.  @0 returns a
;;value interpolated from the nearest j-dimensional cube of elements
;;of @1.
;;
;;@example
;;(interpolate-array-ref '#2A:fixZ32b((1 2 3) (4 5 6)) 1 0.1)
;;                              ==> 4.1
;;(interpolate-array-ref '#2A:fixZ32b((1 2 3) (4 5 6)) 0.5 0.25)
;;                              ==> 2.75
;;@end example
(define (interpolate-array-ref ra . xs)
  (define (mix rat x1 x2) (+ (* (- 1 rat) x1) (* rat x2)))
  (define (iar ra xs dims)
    (define x1 (car xs))
    (define b1 (car dims))
    (define idx (inexact->exact (floor (car xs))))
    (define dim-1 (+ -1 (car dims)))
    (set! xs (cdr xs))
    (set! dims (cdr dims))
    (cond ((<= x1 0) (if (null? xs)
			 (array-ref ra 0)
			 (iar (subarray ra idx) xs dims)))
	  ((>= x1 dim-1) (if (null? xs)
			     (array-ref ra dim-1)
			     (iar (subarray ra dim-1) xs dims)))
	  ((integer? x1) (if (null? xs)
			     (array-ref ra idx)
			     (iar (subarray ra idx) xs dims)))
	  ((null? xs) (mix (- x1 idx)
			   (array-ref ra idx)
			   (array-ref ra (+ 1 idx))))
	  (else (mix (- x1 idx)
		     (iar (subarray ra idx) xs dims)
		     (iar (subarray ra (+ 1 idx)) xs dims)))))
  (if (null? xs)
      (array-ref ra)
      (iar ra xs (array-dimensions ra))))

;;@args ra1 ra2
;;
;;@1 and @2 must be numeric arrays of equal rank.  @0 sets @1 to
;;values interpolated from @2 such that the values of elements at the
;;corners of @1 and @2 are equal.
;;
;;@example
;;(define ra (make-array (A:fixZ32b) 2 2))
;;(resample-array! ra '#2A:fixZ32b((1 2 3) (4 5 6)))
;;ra              ==>  #2A:fixZ32b((1 3) (4 6))
;;(define ra (make-array (A:floR64b) 3 2))
;;(resample-array! ra '#2A:fixZ32b((1 2 3) (4 5 6)))
;;ra              ==>  #2A:floR64b((1.0 3.0) (2.5 4.5) (4.0 6.0))
;;@end example
(define (resample-array! ra1 ra2)
  (define scales (map (lambda (rd1 rd2)
			(if (<= rd1 1)
			    0
			    (/ (+ -1 rd2) (+ -1 rd1))))
		      (array-dimensions ra1)
		      (array-dimensions ra2)))
  (array-index-map! ra1
		    (lambda idxs
		      (apply interpolate-array-ref
			     ra2
			     (map * scales idxs)))))
