;;;; "process.scm",  Multi-Processing for Scheme
;;; Copyright (C) 1992, 1993 Aubrey Jaffer
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

(require 'full-continuation)
(require 'queue)

;@
(define (add-process! thunk1)
  (cond ((procedure? thunk1)
	 (defer-ints)
	 (enqueue! process:queue thunk1)
	 (allow-ints))
	(else (slib:error "add-process!: wrong type argument " thunk1))))
;@
(define (process:schedule!)
  (defer-ints)
  (cond ((queue-empty? process:queue) (allow-ints)
				      'still-running)
	(else (call-with-current-continuation
	       (lambda (cont)
		 (enqueue! process:queue cont)
		 (let ((proc (dequeue! process:queue)))
		   (allow-ints)
		   (proc 'run))
		 (kill-process!))))))
;@
(define (kill-process!)
  (defer-ints)
  (cond ((queue-empty? process:queue) (allow-ints)
				      (slib:exit))
	(else (let ((proc (dequeue! process:queue)))
		(allow-ints)
		(proc 'run))
	      (kill-process!))))

(define ints-disabled #f)
(define alarm-deferred #f)

(define (defer-ints) (set! ints-disabled #t))

(define (allow-ints)
  (set! ints-disabled #f)
  (cond (alarm-deferred
	  (set! alarm-deferred #f)
	  (alarm-interrupt))))

;;; Make THE process queue.
(define process:queue (make-queue))

(define (alarm-interrupt)
  (alarm 1)
  (if ints-disabled (set! alarm-deferred #t)
      (process:schedule!)))
