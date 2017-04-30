;"scmacro.scm", port for Syntactic Closures macro implementation -*- Scheme -*-
;Copyright (C) 1992, 1993, 1994 Aubrey Jaffer
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

(require 'promise)			; Portable support for force and delay.
(require 'record)
(require 'synchk)			; Syntax checker.

;;;; Syntaxer Output Interface

(define syntax-error slib:error)

(define impl-error slib:error)

(define (append-map procedure . lists)
  (apply append (apply map (cons procedure lists))))

(define *counter* 0)

(define (make-name-generator)
  (let ((suffix-promise
	 (make-promise
	  (lambda ()
	    (string-append "."
			   (number->string (begin
					     (set! *counter* (+ *counter* 1))
					     *counter*)))))))
    (lambda (identifier)
      (string->symbol
       (string-append "."
		      (symbol->string (identifier->symbol identifier))
		      (force suffix-promise))))))

(define (output/variable name)
  name)

(define (output/literal-unquoted datum)
  datum)

(define (output/literal-quoted datum);was output/constant (inefficient)
  `(QUOTE ,datum))

(define (output/assignment name value)
  `(SET! ,name ,value))

(define (output/top-level-definition name value)
  `(DEFINE ,name ,value))

(define (output/conditional predicate consequent alternative)
  `(IF ,predicate ,consequent ,alternative))

(define (output/sequence expressions)
  (if (null? (cdr expressions))
      (car expressions)
      `(BEGIN ,@expressions)))

(define (output/combination operator operands)
  `(,operator ,@operands))

(define (output/lambda pattern body)
  `(LAMBDA ,pattern ,body))

(define (output/delay expression)
  `(DELAY ,expression))

(define (output/unassigned)
  `'*UNASSIGNED*)

(define (output/unspecific)
  `'*UNSPECIFIC*)

;;; This file is the macro expander proper.
(slib:load (in-vicinity (library-vicinity) "synclo"))

;;; These files define the R4RS syntactic environment.
(slib:load (in-vicinity (library-vicinity) "r4rsyn"))
(slib:load (in-vicinity (library-vicinity) "synrul"))

;;; OK, time to build the databases.
(initialize-scheme-syntactic-environment!)

;;@ MACRO:EXPAND is for you to use.  It takes an R4RS expression, macro-expands
;;; it, and returns the result of the macro expansion.
(define (synclo:expand expression)
  (set! *counter* 0)
  (compile/top-level (list expression) scheme-syntactic-environment))
(define macro:expand synclo:expand)

;;; Here are EVAL, EVAL! and LOAD which expand macros.  You can replace the
;;; implementation's eval and load with them if you like.
(define base:eval slib:eval)
;;(define base:load load)
;@
(define (synclo:eval x) (base:eval (macro:expand x)))
(define macro:eval synclo:eval)
;@
(define (synclo:load <pathname>)
  (slib:eval-load <pathname> synclo:eval))
(define macro:load synclo:load)

(provide 'syntactic-closures)
(provide 'macro)			;Here because we may have
					;(require 'sc-macro)
