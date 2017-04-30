;;;; "arraymap.scm", applicative routines for arrays in Scheme.
;;; Copyright (C) 1993, 2003 Aubrey Jaffer
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
(require 'multiarg-apply)

;;@code{(require 'array-for-each)}
;;@ftindex array-for-each

;;@args array0 proc array1 @dots{}
;;@var{array1}, @dots{} must have the same number of dimensions as
;;@var{array0} and have a range for each index which includes the range
;;for the corresponding index in @var{array0}.  @var{proc} is applied to
;;each tuple of elements of @var{array1} @dots{} and the result is stored
;;as the corresponding element in @var{array0}.  The value returned is
;;unspecified.  The order of application is unspecified.
(define (array-map! ra0 proc . ras)
  (define (ramap rdims inds)
    (if (null? (cdr rdims))
	(do ((i (+ -1 (car rdims)) (+ -1 i))
	     (is (cons (+ -1 (car rdims)) inds)
		 (cons (+ -1 i) inds)))
	    ((negative? i))
	  (apply array-set!
		 ra0
		 (apply proc (map (lambda (ra) (apply array-ref ra is)) ras))
		 is))
	(let ((crdims (cdr rdims)))
	  (do ((i (+ -1 (car rdims)) (+ -1 i)))
	      ((negative? i))
	    (ramap crdims (cons i inds))))))
  (ramap (reverse (array-dimensions ra0)) '()))

;;@args prototype proc array1 array2 @dots{}
;;@var{array2}, @dots{} must have the same number of dimensions as
;;@var{array1} and have a range for each index which includes the
;;range for the corresponding index in @var{array1}.  @var{proc} is
;;applied to each tuple of elements of @var{array1}, @var{array2},
;;@dots{} and the result is stored as the corresponding element in a
;;new array of type @var{prototype}.  The new array is returned.  The
;;order of application is unspecified.
(define (array-map prototype proc ra1 . ras)
  (define nra (apply make-array prototype (array-dimensions ra1)))
  (apply array-map! nra proc ra1 ras)
  nra)

;;@args proc array0 @dots{}
;;@var{proc} is applied to each tuple of elements of @var{array0} @dots{}
;;in row-major order.  The value returned is unspecified.
(define (array-for-each proc . ras)
  (define (rafe rdims inds)
    (if (null? (cdr rdims))
	(let ((sdni (reverse (cons #f inds))))
	  (define lastpair (last-pair sdni))
	  (do ((i 0 (+ 1 i)))
	      ((> i (+ -1 (car rdims))))
	    (set-car! lastpair i)
	    (apply proc (map (lambda (ra) (apply array-ref ra sdni)) ras))))
	(let ((crdims (cdr rdims))
	      (ll (+ -1 (car rdims))))
	  (do ((i 0 (+ 1 i)))
	      ((> i ll))
	    (rafe crdims (cons i inds))))))
  (rafe (array-dimensions (car ras)) '()))

;;@args array
;;Returns an array of lists of indexes for @var{array} such that, if
;;@var{li} is a list of indexes for which @var{array} is defined,
;;(equal?  @var{li} (apply array-ref (array-indexes @var{array})
;;@var{li})).
(define (array-indexes ra)
  (let ((ra0 (apply make-array '#() (array-dimensions ra))))
    (array-index-map! ra0 list)
    ra0))

;;@args array proc
;;applies @var{proc} to the indices of each element of @var{array} in
;;turn.  The value returned and the order of application are
;;unspecified.
;;
;;One can implement @var{array-index-map!} as
;;@example
;;(define (array-index-map! ra fun)
;;  (array-index-for-each
;;   ra
;;   (lambda is (apply array-set! ra (apply fun is) is))))
;;@end example
(define (array-index-for-each ra fun)
  (define (ramap rdims inds)
    (if (null? (cdr rdims))
	(do ((i (+ -1 (car rdims)) (+ -1 i))
	     (is (cons (+ -1 (car rdims)) inds)
		 (cons (+ -1 i) inds)))
	    ((negative? i))
	  (apply fun is))
	(let ((crdims (cdr rdims)))
	  (do ((i (+ -1 (car rdims)) (+ -1 i)))
	      ((negative? i))
	    (ramap crdims (cons i inds))))))
  (if (zero? (array-rank ra))
      (fun)
      (ramap (reverse (array-dimensions ra)) '())))

;;@args array proc
;;applies @var{proc} to the indices of each element of @var{array} in
;;turn, storing the result in the corresponding element.  The value
;;returned and the order of application are unspecified.
;;
;;One can implement @var{array-indexes} as
;;@example
;;(define (array-indexes array)
;;    (let ((ra (apply make-array '#() (array-dimensions array))))
;;      (array-index-map! ra (lambda x x))
;;      ra))
;;@end example
;;Another example:
;;@example
;;(define (apl:index-generator n)
;;    (let ((v (make-vector n 1)))
;;      (array-index-map! v (lambda (i) i))
;;      v))
;;@end example
(define (array-index-map! ra fun)
  (array-index-for-each ra
			(lambda is (apply array-set! ra (apply fun is) is))))

;;@args destination source
;;Copies every element from vector or array @var{source} to the
;;corresponding element of @var{destination}.  @var{destination} must
;;have the same rank as @var{source}, and be at least as large in each
;;dimension.  The order of copying is unspecified.
(define (array:copy! dest source)
  (array-map! dest identity source))
