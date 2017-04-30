;"sc4opt.scm" Implementation of optional Scheme^4 functions for IEEE Scheme
;Copyright (C) 1991, 1993 Aubrey Jaffer
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

;;; Some of these functions may be already defined in your Scheme.
;;; Comment out those definitions for functions which are already defined.

;;; This code conforms to: William Clinger and Jonathan Rees, editors.
;;; Revised^4 Report on the Algorithmic Language Scheme.

;@
(define (list-tail l p)
  (if (< p 1) l (list-tail (cdr l) (- p 1))))
;@
(define string-copy string-append)
;@
(define (string-fill! s obj)
  (do ((i (- (string-length s) 1) (- i 1)))
      ((< i 0))
      (string-set! s i obj)))
;@
(define (vector-fill! s obj)
  (do ((i (- (vector-length s) 1) (- i 1)))
      ((< i 0))
      (vector-set! s i obj)))
