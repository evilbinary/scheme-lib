;;; "obj2str.scm", write objects to a string.
;Copyright (C) 1993, 1994 Aubrey Jaffer
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

(require 'string-port)
(require-if 'compiling 'generic-write)

;;@body Returns the textual representation of @1 as a string.
(define (object->string obj)
  (cond ((symbol? obj) (symbol->string obj))
	((number? obj) (number->string obj))
	(else
	 (call-with-output-string
	  (lambda (port) (write obj port))))))

; File: "obj2str.scm"   (c) 1991, Marc Feeley

;(require 'generic-write)

; (object->string obj) returns the textual representation of 'obj' as a
; string.
;
; Note: (write obj) = (display (object->string obj))

;(define (object->string obj)
;  (let ((result '()))
;    (generic-write obj #f #f (lambda (str) (set! result (cons str result)) #t))
;    (reverse-string-append result)))

; (object->limited-string obj limit) returns a string containing the first
; 'limit' characters of the textual representation of 'obj'.

;;@body Returns the textual representation of @1 as a string of length
;;at most @2.
(define (object->limited-string obj limit)
  (require 'generic-write)
  (let ((result '()) (left limit))
    (generic-write obj #f #f
		   (lambda (str)
		     (let ((len (string-length str)))
		       (cond ((> len left)
			      (set! result (cons (substring str 0 left) result))
			      (set! left 0)
			      #f)
			     (else
			      (set! result (cons str result))
			      (set! left (- left len))
			      #t)))))
    (reverse-string-append result)))
