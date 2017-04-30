; "dynwind.scm", wind-unwind-protect for Scheme
; Copyright (c) 1992, 1993 Aubrey Jaffer
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

;This facility is a generalization of Common Lisp `unwind-protect',
;designed to take into account the fact that continuations produced by
;CALL-WITH-CURRENT-CONTINUATION may be reentered.

;  (dynamic-wind <thunk1> <thunk2> <thunk3>)		procedure

;The arguments <thunk1>, <thunk2>, and <thunk3> must all be procedures
;of no arguments (thunks).

;DYNAMIC-WIND calls <thunk1>, <thunk2>, and then <thunk3>.  The value
;returned by <thunk2> is returned as the result of DYNAMIC-WIND.
;<thunk3> is also called just before control leaves the dynamic
;context of <thunk2> by calling a continuation created outside that
;context.  Furthermore, <thunk1> is called before reentering the
;dynamic context of <thunk2> by calling a continuation created inside
;that context.  (Control is inside the context of <thunk2> if <thunk2>
;is on the current return stack).

;;;WARNING: This code has no provision for dealing with errors or
;;;interrupts.  If an error or interrupt occurs while using
;;;dynamic-wind, the dynamic environment will be that in effect at the
;;;time of the error or interrupt.

(define dynamic:winds '())
;@
(define (dynamic-wind <thunk1> <thunk2> <thunk3>)
  (<thunk1>)
  (set! dynamic:winds (cons (cons <thunk1> <thunk3>) dynamic:winds))
  (let ((ans (<thunk2>)))
    (set! dynamic:winds (cdr dynamic:winds))
    (<thunk3>)
    ans))
;@
(define call-with-current-continuation
  (let ((oldcc call-with-current-continuation))
    (lambda (proc)
      (let ((winds dynamic:winds))
	(oldcc
	 (lambda (cont)
	   (proc (lambda (c2)
		   (dynamic:do-winds winds (- (length dynamic:winds)
					      (length winds)))
		   (cont c2)))))))))

(define (dynamic:do-winds to delta)
  (cond ((eq? dynamic:winds to))
	((negative? delta)
	 (dynamic:do-winds (cdr to) (+ 1 delta))
	 ((caar to))
	 (set! dynamic:winds to))
	(else
	 (let ((from (cdar dynamic:winds)))
	   (set! dynamic:winds (cdr dynamic:winds))
	   (from)
	   (dynamic:do-winds to (+ -1 delta))))))
