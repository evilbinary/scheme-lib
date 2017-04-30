; "fluidlet.scm", FLUID-LET for Scheme
; Copyright (c) 1998, Radey Shouman <radey_shouman@splashtech.com>
;
;Permission to copy this software, to redistribute it, and to use it
;for any purpose is granted, subject to the following restrictions and
;understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warrantee or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require 'dynamic-wind)
(require 'macro)

(define-syntax fluid-let
  (syntax-rules ()
    ((_ ((?name ?val) ...) . ?body)
     (fluid-let "make-temps"
       ((?name ?val) ...) () ()
       ((?name ?val) ...) . ?body))
    ((_ "make-temps" (?bind1 . ?binds) ?olds ?news . ?rest)
     (fluid-let "make-temps"
       ?binds
       (old-tmp . ?olds)
       (new-tmp . ?news) . ?rest))
    ((_ "make-temps" () (?old ...) (?new ...) ((?name ?val) ...) . ?body)
     (let ((?new ?val) ... (?old #f) ...)
       (dynamic-wind
	(lambda () (set! ?old ?name) ... (set! ?name ?new) ...)
	(lambda () . ?body)
	(lambda () (set! ?new ?name) ... (set! ?name ?old) ...))))))
