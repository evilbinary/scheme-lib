;;;; "trace.scm" Utility functions and macros for tracing in Scheme.
;;; Copyright (C) 1991, 1992, 1993, 1994, 1995, 1999, 2000, 2003 Aubrey Jaffer
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

(require 'qp)				;for the qp printer.
(require 'multiarg-apply)
(require 'alist)

(define trace:indent 0)
(define debug:call-stack '())		;keeps track of call stack.
;@
(define debug:max-count 5)

;;Formats for call-stack elements:
;; (procedure-count name . args)	;for debug:track procedure
;; (procedure-count name)		;for debug:stack procedure
;;Traced functions also stack.

;@
(define print-call-stack
  (let ((car car) (null? null?) (current-error-port current-error-port)
	(qpn qpn) (for-each for-each))
    (lambda cep
      (set! cep (if (null? cep) (current-error-port) (car cep)))
      (for-each qpn debug:call-stack))))

(define (call-stack-news? name)
  (or (null? debug:call-stack)
      (not (eq? name (cadar debug:call-stack)))
      (< (caar debug:call-stack) debug:max-count)))

(define debug:trace-procedure
  (let ((null? null?) (not not)		;These bindings are so that
	(cdar cdar) (cadar cadar)	;trace will not trace parts
	(car car) (cdr cdr) (caar caar)	;of itself.
	(eq? eq?) (+ +) (zero? zero?) (modulo modulo)
	(apply apply) (display display) (qpn qpn) (list list) (cons cons)

	(CALL 'CALL)			;(string->symbol "CALL")
	(RETN 'RETN))			;(string->symbol "RETN")
    (lambda (how function . optname)
      (set! trace:indent 0)
      (let ((name (if (null? optname) function (car optname))))
	(case how
	  ((trace)
	   (lambda args
	     (cond ((and (not (null? args))
			 (eq? (car args) 'debug:untrace-object)
			 (null? (cdr args)))
		    function)
		   ((call-stack-news? name)
		    (let ((cs debug:call-stack))
		      (set! debug:call-stack
			    (if (and (not (null? debug:call-stack))
				     (eq? name (cadar debug:call-stack)))
				(cons (cons (+ 1 (caar debug:call-stack))
					    (cdar debug:call-stack))
				      (cdr debug:call-stack))
				(cons (list 1 name) debug:call-stack)))
		      (do ((i trace:indent (+ -1 i))) ((zero? i)) (display #\space))
		      (apply qpn CALL name args)
		      (set! trace:indent (modulo (+ 2 trace:indent) 31))
		      (let ((ans (apply function args)))
			(set! trace:indent (modulo (+ -2 trace:indent) 31))
			(do ((i trace:indent (+ -1 i))) ((zero? i)) (display #\space))
			(qpn RETN name ans)
			(set! debug:call-stack cs)
			ans)))
		   (else (apply function args)))))
	  ((track)
	   (lambda args
	     (cond ((and (not (null? args))
			 (eq? (car args) 'debug:untrace-object)
			 (null? (cdr args)))
		    function)
		   ((call-stack-news? name)
		    (let ((cs debug:call-stack))
		      (set! debug:call-stack
			    (if (and (not (null? debug:call-stack))
				     (eq? name (cadar debug:call-stack)))
				(cons (cons (+ 1 (caar debug:call-stack))
					    (cdar debug:call-stack))
				      (cdr debug:call-stack))
				(cons (cons 1 (cons name args))
				      debug:call-stack)))
		      (let ((ans (apply function args)))
			(set! debug:call-stack cs)
			ans)))
		   (else (apply function args)))))
	  ((stack)
	   (lambda args
	     (cond ((and (not (null? args))
			 (eq? (car args) 'debug:untrace-object)
			 (null? (cdr args)))
		    function)
		   ((call-stack-news? name)
		    (let ((cs debug:call-stack))
		      (set! debug:call-stack
			    (if (and (not (null? debug:call-stack))
				     (eq? name (cadar debug:call-stack)))
				(cons (cons (+ 1 (caar debug:call-stack))
					    (cdar debug:call-stack))
				      (cdr debug:call-stack))
				(cons (list 1 name) debug:call-stack)))
		      (let ((ans (apply function args)))
			(set! debug:call-stack cs)
			ans)))
		   (else (apply function args)))))
	  (else
	   (slib:error 'debug:trace-procedure 'unknown 'how '= how)))))))

;;; The reason I use a symbol for debug:untrace-object is so that
;;; functions can still be untraced if this file is read in twice.
;@
(define (untracef function)
  (set! trace:indent 0)
  (function 'debug:untrace-object))

;;;;The trace: functions wrap around the debug: functions to provide
;;; niceties like keeping track of traced functions and dealing with
;;; redefinition.

(define trace:adder (alist-associator eq?))
(define trace:deler (alist-remover eq?))

(define *traced-procedures* '())
(define *tracked-procedures* '())
(define *stacked-procedures* '())
(define (trace:trace-procedure how fun sym)
  (define cep (current-error-port))
  (cond ((not (procedure? fun))
	 (display "WARNING: not a procedure " cep)
	 (display sym cep)
	 (newline cep)
	 (set! *traced-procedures* (trace:deler *traced-procedures* sym))
	 (set! *tracked-procedures* (trace:deler *tracked-procedures* sym))
	 (set! *stacked-procedures* (trace:deler *stacked-procedures* sym))
	 fun)
	(else
	 (let ((p (assq sym (case how
			      ((trace) *traced-procedures*)
			      ((track) *tracked-procedures*)
			      ((stack) *stacked-procedures*)))))
	   (cond ((and p (eq? (cdr p) fun))
		  fun)
		 (else
		  (let ((tfun (debug:trace-procedure how fun sym)))
		    (case how
		      ((trace)
		       (set! *traced-procedures*
			     (trace:adder *traced-procedures* sym tfun)))
		      ((track)
		       (set! *tracked-procedures*
			     (trace:adder *tracked-procedures* sym tfun)))
		      ((stack)
		       (set! *stacked-procedures*
			     (trace:adder *stacked-procedures* sym tfun))))
		    tfun)))))))

(define (trace:untrace-procedure fun sym)
  (define finish
    (lambda (p)
      (cond ((not (procedure? fun)) fun)
	    ((eq? (cdr p) fun) (untracef fun))
	    (else fun))))
  (cond ((assq sym *traced-procedures*)
	 =>
	 (lambda (p)
	   (set! *traced-procedures* (trace:deler *traced-procedures* sym))
	   (finish p)))
	((assq sym *tracked-procedures*)
	 =>
	 (lambda (p)
	   (set! *tracked-procedures* (trace:deler *tracked-procedures* sym))
	   (finish p)))
	((assq sym *stacked-procedures*)
	 =>
	 (lambda (p)
	   (set! *stacked-procedures* (trace:deler *stacked-procedures* sym))
	   (finish p)))
	(else fun)))
;@
(define (tracef . args) (apply debug:trace-procedure 'trace args))
;@
(define (trackf . args) (apply debug:trace-procedure 'track args))
;@
(define (stackf . args) (apply debug:trace-procedure 'stack args))
;;;; Finally, the macros trace and untrace
;@
(defmacro trace xs
  (if (null? xs)
      `(begin (set! trace:indent 0)
	      ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'trace ,x ',x)))
		     (map car *traced-procedures*))
	      (map car *traced-procedures*))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'trace ,x ',x))) xs))))
(defmacro track xs
  (if (null? xs)
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'track ,x ',x)))
		     (map car *tracked-procedures*))
	      (map car *tracked-procedures*))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'track ,x ',x))) xs))))
(defmacro stack xs
  (if (null? xs)
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'stack ,x ',x)))
		     (map car *stacked-procedures*))
	      (map car *stacked-procedures*))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:trace-procedure 'stack ,x ',x))) xs))))
;@
(defmacro untrace xs
  (if (null? xs)
      (slib:eval
       `(begin ,@(map (lambda (x)
			`(set! ,x (trace:untrace-procedure ,x ',x)))
		      (map car *traced-procedures*))
	       '',(map car *traced-procedures*)))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (trace:untrace-procedure ,x ',x))) xs))))
(defmacro untrack xs
  (if (null? xs)
      (slib:eval
       `(begin ,@(map (lambda (x)
			`(set! ,x (track:untrack-procedure ,x ',x)))
		      (map car *tracked-procedures*))
	       '',(map car *tracked-procedures*)))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (track:untrack-procedure ,x ',x))) xs))))
(defmacro unstack xs
  (if (null? xs)
      (slib:eval
       `(begin ,@(map (lambda (x)
			`(set! ,x (stack:unstack-procedure ,x ',x)))
		      (map car *stacked-procedures*))
	       '',(map car *stacked-procedures*)))
      `(begin ,@(map (lambda (x)
		       `(set! ,x (stack:unstack-procedure ,x ',x))) xs))))
