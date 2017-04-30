; "withfile.scm", with-input-from-file and with-output-to-file for Scheme
; Copyright (c) 1992, 1993, 2007 Aubrey Jaffer
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

(require 'dynamic-wind)

(define withfile:current-input (current-input-port))
(define withfile:current-output (current-output-port))
;@
(define (current-input-port) withfile:current-input)
(define (current-output-port) withfile:current-output)
;@
(define (with-input-from-file file thunk)
  (define oport withfile:current-input)
  (define port (open-input-file file))
  (dynamic-wind (lambda () (set! oport withfile:current-input)
			   (set! withfile:current-input port))
		(lambda() (let ((ans (thunk))) (close-input-port port) ans))
		(lambda() (set! withfile:current-input oport))))
;@
(define (with-output-to-file file thunk)
  (define oport withfile:current-output)
  (define port (open-output-file file))
  (dynamic-wind (lambda() (set! oport withfile:current-output)
		          (set! withfile:current-output port))
		(lambda() (let ((ans (thunk))) (close-output-port port) ans))
		(lambda() (set! withfile:current-output oport))))
;@
(define peek-char
  (let ((pk-chr peek-char))
    (lambda opt
      (pk-chr (if (null? opt) withfile:current-input (car opt))))))
;@
(define read-char
  (let ((rd-chr read-char))
    (lambda opt
      (rd-chr (if (null? opt) withfile:current-input (car opt))))))
;@
(define read
  (let ((rd read))
    (lambda opt
      (rd (if (null? opt) withfile:current-input (car opt))))))
;@
(define write-char
  (let ((wrt-chr write-char))
    (lambda (obj . opt)
      (wrt-chr obj (if (null? opt) withfile:current-output (car opt))))))
;@
(define write
  (let ((wrt write))
    (lambda (obj . opt)
      (wrt obj (if (null? opt) withfile:current-output (car opt))))))
;@
(define display
  (let ((dspl display))
    (lambda (obj . opt)
      (dspl obj (if (null? opt) withfile:current-output (car opt))))))
;@
(define newline
  (let ((nwln newline))
    (lambda opt
      (nwln (if (null? opt) withfile:current-output (car opt))))))
;@
(define force-output
  (let ((frc-otpt force-output))
    (lambda opt
      (frc-otpt (if (null? opt) withfile:current-output (car opt))))))
