;;;; "dwindtst.scm", routines for characterizing dynamic-wind.
;Copyright (C) 1992 Aubrey Jaffer
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

(define (dwtest n)
  (define cont #f)
  (display "testing escape from thunk") (display n) (newline)
  (display "visiting:") (newline)
  (call-with-current-continuation
   (lambda (x) (set! cont x)))
  (if n
      (dynamic-wind
       (lambda ()
	 (display "thunk1") (newline)
	 (if (eqv? n 1) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp))))
       (lambda ()
	 (display "thunk2") (newline)
	 (if (eqv? n 2) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp))))
       (lambda ()
	 (display "thunk3") (newline)
	 (if (eqv? n 3) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp)))))))
(define (dwctest n)
  (define cont #f)
  (define ccont #f)
  (display "creating continuation thunk") (newline)
  (display "visiting:") (newline)
  (call-with-current-continuation
   (lambda (x) (set! cont x)))
  (if n (set! n (- n)))
  (if n
      (dynamic-wind
       (lambda ()
	 (display "thunk1") (newline)
	 (if (eqv? n 1) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp))))
       (lambda ()
	 (call-with-current-continuation
	  (lambda (x) (set! ccont x)))
	 (display "thunk2") (newline)
	 (if (eqv? n 2) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp))))
       (lambda ()
	 (display "thunk3") (newline)
	 (if (eqv? n 3) (let ((ntmp n))
			  (set! n #f)
			  (cont ntmp))))))
  (cond
   (n
    (set! n (- n))
    (display "testing escape from continuation thunk") (display n) (newline)
    (display "visiting:") (newline)
    (ccont #f))))

(dwtest 1) (dwtest 2) (dwtest 3)
(dwctest 1) (dwctest 2) (dwctest 3)
