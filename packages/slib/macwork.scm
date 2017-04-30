;;;; "macwork.scm": Will Clinger's macros that work.	-*- Scheme -*-
;Copyright 1992 William Clinger
;
; Permission to copy this software, in whole or in part, to use this
; software for any lawful purpose, and to redistribute this software
; is granted subject to the restriction that all copies made of this
; software must include this copyright notice in full.
;
; I also request that you send me a copy of any improvements that you
; make to this software so that they may be incorporated within it to
; the benefit of the Scheme community.

(require 'common-list-functions)

(define mw:every every)
(define mw:union union)
(define mw:remove-if-not remove-if-not)

(slib:load (in-vicinity (program-vicinity) "mwexpand"))

;;;; Miscellaneous routines.

(define (mw:warn msg . more)
  (display "WARNING from macro expander:")
  (newline)
  (display msg)
  (newline)
  (for-each (lambda (x) (write x) (newline))
	    more))

(define (mw:error msg . more)
  (display "ERROR detected during macro expansion:")
  (newline)
  (display msg)
  (newline)
  (for-each (lambda (x) (write x) (newline))
	    more)
  (mw:quit #f))

(define (mw:bug msg . more)
  (display "BUG in macro expander: ")
  (newline)
  (display msg)
  (newline)
  (for-each (lambda (x) (write x) (newline))
	    more)
  (mw:quit #f))

; Given a <formals>, returns a list of bound variables.

(define (mw:make-null-terminated x)
  (cond ((null? x) '())
	((pair? x)
	 (cons (car x) (mw:make-null-terminated (cdr x))))
	(else (list x))))

; Returns the length of the given list, or -1 if the argument
; is not a list.  Does not check for circular lists.

(define (mw:safe-length x)
  (define (loop x n)
    (cond ((null? x) n)
	  ((pair? x) (loop (cdr x) (+ n 1)))
	  (else -1)))
  (loop x 0))

; Given an association list, copies the association pairs.

(define (mw:syntax-copy alist)
  (map (lambda (x) (cons (car x) (cdr x)))
       alist))

;;;; Implementation-dependent parameters and preferences that determine
; how identifiers are represented in the output of the macro expander.
;
; The basic problem is that there are no reserved words, so the
; syntactic keywords of core Scheme that are used to express the
; output need to be represented by data that cannot appear in the
; input.  This file defines those data.

; The following definitions assume that identifiers of mixed case
; cannot appear in the input.

;(define mw:begin1  (string->symbol "Begin"))
;(define mw:define1 (string->symbol "Define"))
;(define mw:quote1  (string->symbol "Quote"))
;(define mw:lambda1 (string->symbol "Lambda"))
;(define mw:if1     (string->symbol "If"))
;(define mw:set!1   (string->symbol "Set!"))

(define mw:begin1  'begin)
(define mw:define1 'define)
(define mw:quote1  'quote)
(define mw:lambda1 'lambda)
(define mw:if1     'if)
(define mw:set!1   'set!)

; The following defines an implementation-dependent expression
; that evaluates to an undefined (not unspecified!) value, for
; use in expanding the (define x) syntax.

(define mw:undefined (list (string->symbol "Undefined")))

; A variable is renamed by suffixing a vertical bar followed by a unique
; integer.  In IEEE and R4RS Scheme, a vertical bar cannot appear as part
; of an identifier, but presumably this is enforced by the reader and not
; by the compiler.  Any other character that cannot appear as part of an
; identifier may be used instead of the vertical bar.

(define mw:suffix-character #\!)

(slib:load (in-vicinity (program-vicinity) "mwdenote"))
(slib:load (in-vicinity (program-vicinity) "mwsynrul"))
;@
(define macro:expand macwork:expand)

;;; Here are EVAL, EVAL! and LOAD which expand macros.  You can replace the
;;; implementation's eval and load with them if you like.
(define base:eval slib:eval)
;;(define base:load load)
;@
(define (macwork:eval x) (base:eval (macwork:expand x)))
(define macro:eval macwork:eval)
;@
(define (macwork:load <pathname>)
  (slib:eval-load <pathname> macwork:eval))
(define macro:load macwork:load)

(provide 'macros-that-work)
(provide 'macro)
