;;;; "break.scm" Breakpoints for debugging in Scheme.
;;; Copyright (C) 1991, 1992, 1993, 1995, 2003 Aubrey Jaffer
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

(require 'qp)
(require 'alist)
(require 'multiarg-apply)

;;;; BREAKPOINTS

;;; Typing (init-debug) at top level sets up a continuation for
;;; breakpoint.  When (breakpoint arg1 ...) is then called it returns
;;; from the top level continuation and pushes the continuation from
;;; which it was called on breakpoint:continuation-stack.  If
;;; (continue) is later called, it pops the topmost continuation off
;;; of breakpoint:continuation-stack and returns #f to it.

(define breakpoint:continuation-stack '())
;@
(define breakpoint
  (let ((call-with-current-continuation call-with-current-continuation)
	(apply apply) (qpn qpn)
	(cons cons) (length length))
    (lambda args
      (if (provided? 'trace) (print-call-stack (current-error-port)))
      (apply qpn "BREAKPOINT:" args)
      (let ((ans
	     (call-with-current-continuation
	      (lambda (x)
		(set! breakpoint:continuation-stack
		      (cons x breakpoint:continuation-stack))
		(debug:top-continuation
		 (length breakpoint:continuation-stack))))))
	(cond ((not (eq? ans breakpoint:continuation-stack)) ans))))))
;@
(define continue
  (let ((null? null?) (car car) (cdr cdr))
    (lambda args
      (cond ((null? breakpoint:continuation-stack)
	     (display "; no break to continue from")
	     (newline))
	    (else
	     (let ((cont (car breakpoint:continuation-stack)))
	       (set! breakpoint:continuation-stack
		     (cdr breakpoint:continuation-stack))
	       (if (null? args) (cont #f)
		   (apply cont args))))))))

(define debug:top-continuation
  (if (provided? 'abort)
      (lambda (val) (display val) (newline) (abort))
      (begin (display "; type (init-debug)") #f)))
;@
(define (init-debug)
  (call-with-current-continuation
   (lambda (x) (set! debug:top-continuation x))))
;@
(define breakf
  (let ((null? null?)			;These bindings are so that
	(not not)			;breakf will not break on parts
	(car car) (cdr cdr)		;of itself.
	(eq? eq?) (+ +) (zero? zero?) (modulo modulo)
	(apply apply) (display display) (breakpoint breakpoint))
    (lambda (function . optname)
      ;; (set! trace:indent 0)
      (let ((name (if (null? optname) function (car optname))))
	(lambda args
	  (cond ((and (not (null? args))
		      (eq? (car args) 'debug:unbreak-object)
		      (null? (cdr args)))
		 function)
		(else
		 (breakpoint name args)
		 (apply function args))))))))

;;; the reason I use a symbol for debug:unbreak-object is so
;;; that functions can still be unbreaked if this file is read in twice.
;@
(define (unbreakf function)
  ;; (set! trace:indent 0)
  (function 'debug:unbreak-object))

;;;;The break: functions wrap around the debug: functions to provide
;;; niceties like keeping track of breakd functions and dealing with
;;; redefinition.

(define break:adder (alist-associator eq?))
(define break:deler (alist-remover eq?))

(define *breakd-procedures* '())
(define (break:breakf fun sym)
  (cond ((not (procedure? fun))
	 (display "WARNING: not a procedure " (current-error-port))
	 (display sym (current-error-port))
	 (newline (current-error-port))
	 (set! *breakd-procedures* (break:deler *breakd-procedures* sym))
	 fun)
	(else
	 (let ((p (assq sym *breakd-procedures*)))
	   (cond ((and p (eq? (cdr p) fun))
		  fun)
		 (else
		  (let ((tfun (breakf fun sym)))
		    (set! *breakd-procedures*
			  (break:adder *breakd-procedures* sym tfun))
		    tfun)))))))

(define (break:unbreakf fun sym)
  (let ((p (assq sym *breakd-procedures*)))
    (set! *breakd-procedures* (break:deler *breakd-procedures* sym))
    (cond ((not (procedure? fun)) fun)
	  ((not p) fun)
	  ((eq? (cdr p) fun)
	   (unbreakf fun))
	  (else fun))))
;;;; Finally, the macros break and unbreak
;@
(defmacro break xs
  (if (null? xs)
      `(begin ,@(map (lambda (x) `(set! ,x (break:breakf ,x ',x)))
		     (map car *breakd-procedures*))
	      (map car *breakd-procedures*))
      `(begin ,@(map (lambda (x) `(set! ,x (break:breakf ,x ',x))) xs))))
(defmacro unbreak xs
  (if (null? xs)
      (slib:eval
       `(begin ,@(map (lambda (x) `(set! ,x (break:unbreakf ,x ',x)))
		      (map car *breakd-procedures*))
	       '',(map car *breakd-procedures*)))
      `(begin ,@(map (lambda (x) `(set! ,x (break:unbreakf ,x ',x))) xs))))
