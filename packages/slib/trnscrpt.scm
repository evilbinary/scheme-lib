; "trnscrpt.scm", transcript functions for Scheme.
; Copyright (c) 1992, 1993, 1995, 2007 Aubrey Jaffer
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

(define transcript:port #f)
;@
(define (transcript-on filename)
  (set! transcript:port (open-output-file filename)))
;@
(define (transcript-off)
  (if (output-port? transcript:port)
      (close-output-port transcript:port))
  (set! transcript:port #f))
;@
(define read-char
  (let ((rd-chr read-char) (wrt-chr write-char))
    (lambda opt
      (let ((ans (apply rd-chr opt)))
	(cond ((eof-object? ans))
	      ((output-port? transcript:port)
	       (wrt-chr ans transcript:port)))
	ans))))
;@
(define read
  (let ((rd read) (wrt write) (nwln newline))
    (lambda opt
      (let ((ans (apply rd opt)))
	(cond ((eof-object? ans))
	      ((output-port? transcript:port)
	       (wrt ans transcript:port)
	       (if (eqv? #\newline (apply peek-char opt))
		   (nwln transcript:port))))
	ans))))
;@
(define write-char
  (let ((wrt-chr write-char))
    (lambda (obj . opt)
      (apply wrt-chr (cons obj opt))
      (if (output-port? transcript:port)
	  (wrt-chr obj transcript:port)))))
;@
(define write
  (let ((wrt write))
    (lambda (obj . opt)
      (apply wrt (cons obj opt))
      (if (output-port? transcript:port)
	  (wrt obj transcript:port)))))
;@
(define display
  (let ((dspl display))
    (lambda (obj . opt)
      (apply dspl (cons obj opt))
      (if (output-port? transcript:port)
	  (dspl obj transcript:port)))))
;@
(define newline
  (let ((nwln newline))
    (lambda opt
      (apply nwln opt)
      (if (output-port? transcript:port)
	  (nwln transcript:port)))))
