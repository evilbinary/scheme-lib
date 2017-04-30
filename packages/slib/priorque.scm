;;;; "priorque.scm" priority queues for Scheme.
;;; Copyright (C) 1992, 1993, 1994, 1995, 1997 Aubrey Jaffer
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

;;@code{(require 'priority-queue)}
;;@ftindex priority-queue
;;
;;@noindent
;;This algorithm for priority queues is due to
;;@cite{Introduction to Algorithms}
;;by T. Cormen, C. Leiserson, R. Rivest.
;;1989 MIT Press.

(require 'record)

;; Record type.
(define heap:rtd (make-record-type "heap" '(array size heap<?)))

;; Reference an element.
(define heap:ref
  (let ((ra (record-accessor heap:rtd 'array)))
    (lambda (a i)
      (vector-ref (ra a) (+ -1 i)))))

;; Set an element.
(define heap:set!
  (let ((ra (record-accessor heap:rtd 'array)))
    (lambda (a i v)
      (vector-set! (ra a) (+ -1 i) v))))

;; Exchange two elements.
(define heap:exchange
  (let ((aa (record-accessor heap:rtd 'array)))
    (lambda (a i j)
      (set! i (+ -1 i))
      (set! j (+ -1 j))
      (let* ((ra (aa a))
	     (tmp (vector-ref ra i)))
	(vector-set! ra i (vector-ref ra j))
	(vector-set! ra j tmp)))))

(define heap:heap<? (record-accessor heap:rtd 'heap<?))

(define heap:set-size!
  (let ((aa (record-accessor heap:rtd 'array))
	(am (record-modifier heap:rtd 'array))
	(sm (record-modifier heap:rtd 'size)))
    (lambda (a s)
      (let ((ra (aa a)))
	(if (> s (vector-length ra))
	    (let ((nra (make-vector (+ s (quotient s 2)))))
	      (do ((i (+ -1 (vector-length ra)) (+ -1 i)))
		  ((negative? i) (am a nra))
		(vector-set! nra i (vector-ref ra i)))))
	(sm a s)))))

(define (heap:parent i) (quotient i 2))
(define (heap:left i) (* 2 i))
(define (heap:right i) (+ 1 (* 2 i)))

(define (heap:heapify a i)
  (let* ((l (heap:left i))
	 (r (heap:right i))
	 (largest (if (and (<= l (heap:length a))
			   ((heap:heap<? a) (heap:ref a i) (heap:ref a l)))
		      l
		      i)))
    (cond ((and (<= r (heap:length a))
		((heap:heap<? a) (heap:ref a largest) (heap:ref a r)))
	   (set! largest r)))
    (cond ((not (= largest i))
	   (heap:exchange a i largest)
	   (heap:heapify a largest)))))

;;;; Externals

;;@body
;;Returns a binary heap suitable which can be used for priority queue
;;operations.
(define make-heap
  (let ((cstr (record-constructor heap:rtd '(array size heap<?))))
    (lambda (pred<?)
      (cstr (make-vector 4) 0 pred<?))))

;;@args heap
;;Returns the number of elements in @1.
(define heap-length (record-accessor heap:rtd 'size))

;;@args heap item
;;Inserts @2 into @1.  @2 can be inserted multiple
;;times.  The value returned is unspecified.
(define (heap-insert! a key)
  (define i (+ 1 (heap:length a)))
  (heap:set-size! a i)
  (do ()
      ((not (and (> i 1)
		 ((heap:heap<? a) (heap:ref a (heap:parent i)) key))))
    (heap:set! a i (heap:ref a (heap:parent i)))
    (set! i (heap:parent i)))
  (heap:set! a i key))

;;@args heap
;;Returns the item which is larger than all others according to the
;;@var{pred<?} argument to @code{make-heap}.  If there are no items in
;;@1, an error is signaled.
(define (heap-extract-max! a)
  (if (< (heap:length a) 1)
      (slib:error "heap underflow" a))
  (let ((max (heap:ref a 1)))
    (heap:set! a 1 (heap:ref a (heap:length a)))
    (heap:set-size! a (+ -1 (heap:length a)))
    (heap:heapify a 1)
    max))

;; Internal protect.
(define heap:length heap-length)
