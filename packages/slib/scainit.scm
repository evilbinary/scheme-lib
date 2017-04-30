;;; "scainit.scm" Syntax-case macros port to SLIB	-*- Scheme -*-
;;; Copyright (C) 1992 R. Kent Dybvig
;;;
;;; Permission to copy this software, in whole or in part, to use this
;;; software for any lawful purpose, and to redistribute this software
;;; is granted subject to the restriction that all copies made of this
;;; software must include this copyright notice in full.  This software
;;; is provided AS IS, with NO WARRANTY, EITHER EXPRESS OR IMPLIED,
;;; INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY
;;; OR FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE
;;; AUTHORS BE LIABLE FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES OF ANY
;;; NATURE WHATSOEVER.

;;; From: Harald Hanche-Olsen <hanche@imf.unit.no>

;;; compat.ss
;;; Robert Hieb & Kent Dybvig
;;; 92/06/18

(require 'common-list-functions)	;to pick up EVERY
(define syncase:andmap every)

; In Chez Scheme "(syncase:void)" returns an object that is ignored by the
; REP loop.  It is returned whenever a "nonspecified" value is specified
; by the standard.  The following should pick up an appropriate value.

(define syncase:void
   (let ((syncase:void-object (if #f #f)))
      (lambda () syncase:void-object)))

(define syncase:eval-hook slib:eval)

(define syncase:error-hook slib:error)

(define syncase:new-symbol-hook
  (let ((c 0))
    (lambda (string)
      (set! c (+ c 1))
      (string->symbol
       (string-append string ":Sca" (number->string c))))))

(define syncase:put-global-definition-hook #f)
(define syncase:get-global-definition-hook #f)
(let ((*macros* '()))
  (set! syncase:put-global-definition-hook
	(lambda (symbol binding)
	  (let ((pair (assq symbol *macros*)))
	    (if pair
		(set-cdr! pair binding)
		(set! *macros* (cons (cons symbol binding) *macros*))))))
  (set! syncase:get-global-definition-hook
	(lambda (symbol)
	  (let ((pair (assq symbol *macros*)))
	    (and pair (cdr pair))))))


;;;! expand.pp requires list*
(define (syncase:list* . args)
  (if (null? args)
      '()
      (let ((r (reverse args)))
	(append (reverse (cdr r))
		(car r)			; Last arg
		'()))))			; Make sure the last arg is copied

(define syntax-error syncase:error-hook)
(define impl-error slib:error)

(define base:eval slib:eval)
;@
(define syncase:eval base:eval)
(define macro:eval base:eval)
(define syncase:expand #f)
(define macro:expand #f)

(define (syncase:expand-install-hook expand)
  (set! syncase:eval (lambda (x) (base:eval (expand x))))
  (set! macro:eval syncase:eval)
  (set! syncase:expand expand)
  (set! macro:expand syncase:expand))
;;; We Need This for bootstrapping purposes:
;@
(define (syncase:load <pathname>)
  (slib:eval-load <pathname> syncase:eval))
(define macro:load syncase:load)
;@
(define syncase:sanity-check #f)

;;; LOADING THE SYSTEM ITSELF:
(slib:load (in-vicinity (program-vicinity) "scaoutp"))
(slib:load (in-vicinity (program-vicinity) "scaglob"))
(slib:load (in-vicinity (program-vicinity) "scaexpp"))

(let ((scmhere (lambda (file)
		 (in-vicinity (library-vicinity) file))))
  (syncase:expand-install-hook expand-syntax)
  (syncase:load (scmhere "scamacr"))
  (set! syncase:sanity-check
	(lambda ()
	  (syncase:load (scmhere "sca-exp"))
	  (syncase:expand-install-hook expand-syntax)
	  (syncase:load (scmhere "sca-macr")))))

(provide 'syntax-case)
(provide 'macro)
