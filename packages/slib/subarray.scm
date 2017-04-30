;;;;"subarray.scm" Scheme array accessory procedures.
; Copyright (C) 2002 Aubrey Jaffer and Radey Shouman
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

;;@code{(require 'subarray)}
;;@ftindex subarray

;;@args array select @dots{}
;;selects a subset of an array.  For 0 <= @i{j} < n, @2@i{j} is either
;;an integer, a list of two integers within the range for the @i{j}th
;;index, or #f.
;;
;;When @2@i{j} is a list of two integers, then the @i{j}th index is
;;restricted to that subrange in the returned array.
;;
;;When @2@i{j} is #f, then the full range of the @i{j}th index is
;;accessible in the returned array.  An elided argument is equivalent to #f.
;;
;;When @2@i{j} is an integer, then the rank of the returned array is
;;less than @1, and only elements whose @i{j}th index equals @2@i{j} are
;;shared.
;;
;;@example
;;> (define ra '#2A((a b c) (d e f)))
;;#<unspecified>
;;> (subarray ra 0 #f)
;;#1A(a b c)
;;> (subarray ra 1 #f)
;;#1A(d e f)
;;> (subarray ra #f 1)
;;#1A(b e)
;;> (subarray ra '(0 1) #f)
;;#2A((a b c) (d e f))
;;> (subarray ra #f '(0 1))
;;#2A((a b) (d e))
;;> (subarray ra #f '(1 2))
;;#2A((b c) (e f))
;;> (subarray ra #f '(2 1))
;;#2A((c b) (f e))
;;@end example
;;
;;Arrays can be reflected (reversed) using @0:
;;
;;@example
;;> (subarray '#1A(a b c d e) '(4 0))
;;#1A(e d c b a)
;;@end example
(define (subarray array . selects)
  (apply make-shared-array
	 array
	 (lambda args
	   (let loop ((sels selects)
		      (args args)
		      (lst '()))
	     (cond ((null? sels)
                    (if (null? args)
                        (reverse lst)
                        (loop sels (cdr args) (cons (car args) lst))))
		   ((number? (car sels))
		    (loop (cdr sels) args (cons (car sels) lst)))
		   ((list? (car sels))
		    (loop (cdr sels)
			  (cdr args)
			  (cons (if (< (cadar sels) (caar sels))
				    (+ (- (caar sels) (car args)))
				    (+ (caar sels) (car args)))
				lst)))
		   (else
		    (loop (cdr sels) (cdr args) (cons (car args) lst))))))
         (let loop ((sels selects)
                    (dims (array-dimensions array))
                    (ndims '()))
           (cond ((null? dims)
                  (if (null? sels)
                      (reverse ndims)
                      (slib:error
		       'subarray 'rank (array-rank array) 'mismatch selects)))
                 ((null? sels)
                  (loop sels (cdr dims) (cons (car dims) ndims)))
                 ((number? (car sels))
                  (loop (cdr sels) (cdr dims) ndims))
                 ((not (car sels))
                  (loop (cdr sels) (cdr dims) (cons (car dims) ndims)))
		 ((list? (car sels))
		  (loop (cdr sels)
			(cdr dims)
			(cons (list 0 (abs (- (cadar sels) (caar sels))))
			      ndims)))
                 (else
                  (loop (cdr sels) (cdr dims) (cons (car sels) ndims)))))))

;;@body
;;
;;Returns a subarray sharing contents with @1 except for slices removed
;;from either side of each dimension.  Each of the @2 is an exact
;;integer indicating how much to trim.  A positive @var{s} trims the
;;data from the lower end and reduces the upper bound of the result; a
;;negative @var{s} trims from the upper end and increases the lower
;;bound.
;;
;;For example:
;;@example
;;(array-trim '#(0 1 2 3 4) 1)  @result{} #1A(1 2 3 4)
;;(array-trim '#(0 1 2 3 4) -1) @result{} #1A(0 1 2 3)
;;
;;(require 'array-for-each)
;;(define (centered-difference ra)
;;  (array-map ra - (array-trim ra 1) (array-trim ra -1)))
;;
;;(centered-difference '#(0 1 3 5 9 22))
;;  @result{} #(1 2 2 4 13)
;;@end example
(define (array-trim array . trims)
  (define (loop dims trims shps)
    (cond ((null? trims)
	   (if (null? dims)
	       (reverse shps)
	       (loop (cdr dims)
		     '()
		     (cons (list 0 (+ -1 (car dims))) shps))))
	  ((null? dims)
	   (slib:error 'array-trim 'too 'many 'trims trims))
	  ((negative? (car trims))
	   (loop (cdr dims)
		 (cdr trims)
		 (cons (list 0 (+ (car trims) (car dims) -1)) shps)))
	  (else
	   (loop (cdr dims)
		 (cdr trims)
		 (cons (list (car trims) (+ -1 (car dims))) shps)))))
  (apply subarray array (loop (array-dimensions array) trims '())))
