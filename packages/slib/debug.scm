;;;; "debug.scm" Utility functions for debugging in Scheme.
;;; Copyright (C) 1991, 1992, 1993, 1995, 1999 Aubrey Jaffer
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

(require 'trace)
(require 'break)
(require 'line-i/o)

(define (for-each-top-level-definition-in-file file proc)
  (call-with-input-file
      file
    (lambda (port)
      (letrec
	  ((walk
	    (lambda (exp)
	      (cond
	       ((not (and (pair? exp) (list? exp))))
	       ((not (symbol? (car exp))))
	       (else
		(case (car exp)
		  ((begin) (for-each walk (cdr exp)))
		  ((cond)  (for-each
			    (lambda (exp)
			      (for-each walk
					(if (list? (car exp)) exp (cdr exp))))
			    (cdr exp)))
		  ((if)    (for-each
			    walk (if (list? (cadr exp)) (cdr exp) (cddr exp))))
		  ((defmacro define-syntax) (proc exp))
		  ((define) (proc exp))))))))
	(if (eqv? #\# (peek-char port))
	    (read-line port))		;remove `magic-number'
	(do ((form (read port) (read port)))
	    ((eof-object? form))
	  (walk form))))))

(define (for-each-top-level-defined-procedure-symbol-in-file file proc)
  (letrec ((get-defined-symbol
	    (lambda (form)
	      (if (pair? form)
		  (get-defined-symbol (car form))
		  form))))
    (for-each-top-level-definition-in-file
     file
     (lambda (form)
       (and (eqv? 'define (car form))
	    (let ((sym (get-defined-symbol (cadr form))))
	      (cond ((procedure? (slib:eval sym))
		     (proc sym)))))))))
;@
(define (trace-all file . ...)
  (for-each
   (lambda (file)
     (for-each-top-level-defined-procedure-symbol-in-file
      file
      (lambda (sym)
	(slib:eval `(set! ,sym (trace:trace-procedure 'trace ,sym ',sym))))))
   (cons file ...)))
(define (track-all file . ...)
  (for-each
   (lambda (file)
     (for-each-top-level-defined-procedure-symbol-in-file
      file
      (lambda (sym)
	(slib:eval `(set! ,sym (trace:trace-procedure 'track ,sym ',sym))))))
   (cons file ...)))
(define (stack-all file . ...)
  (for-each
   (lambda (file)
     (for-each-top-level-defined-procedure-symbol-in-file
      file
      (lambda (sym)
	(slib:eval `(set! ,sym (trace:trace-procedure 'stack ,sym ',sym))))))
   (cons file ...)))
;@
(define (break-all file . ...)
  (for-each
   (lambda (file)
     (for-each-top-level-defined-procedure-symbol-in-file
      file
      (lambda (sym)
	(slib:eval `(set! ,sym (break:breakf ,sym ',sym))))))
   (cons file ...)))
