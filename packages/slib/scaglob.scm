;;; "scaglob.scm" syntax-case initializations
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

;;; init.ss
;;; Robert Hieb & Kent Dybvig
;;; 92/06/18

; These initializations are done here rather than "expand.ss" so that
; "expand.ss" can be loaded twice (for bootstrapping purposes).

(define expand-syntax #f)
(define syntax-dispatch #f)
(define generate-temporaries #f)
(define identifier? #f)
(define syntax-error #f)
(define syntax-object->datum #f)
(define bound-identifier=? #f)
(define free-identifier=? #f)
(define syncase:install-global-transformer #f)
(define implicit-identifier #f)
