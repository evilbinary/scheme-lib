;;; "dbinterp.scm" Interpolate function from database table.
;Copyright 2003 Aubrey Jaffer
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

;;; The procedures returned by MEMOIZE are not reentrant!
(define (dbinterp:memoize proc k)
  (define recent (vector->list (make-vector k '(#f))))
  (let ((tailr (last-pair recent)))
    (lambda args
      (define asp (assoc args recent))
      (if asp
	  (cdr asp)
	  (let ((val (apply proc args)))
	    (set-cdr! tailr (list (cons args val)))
	    (set! tailr (cdr tailr))
	    (set! recent (cdr recent))
	    val)))))

;;@ This procedure works only for tables with a single primary key.
(define (interpolate-from-table table column)
  (define get  (table 'get column))
  (define prev (table 'isam-prev))
  (define next (table 'isam-next))
  (dbinterp:memoize
   (lambda (x)
     (let ((nxt (next x)))
       (if nxt (set! nxt (car nxt)))
       (let ((prv (prev (or nxt x))))
	 (if prv (set! prv (car prv)))
	 (cond ((not nxt) (get prv))
	       ((not prv) (get nxt))
	       (else (/ (+ (* (- x prv) (get nxt))
			   (* (- nxt x) (get prv)))
			(- nxt prv)))))))
   3))
