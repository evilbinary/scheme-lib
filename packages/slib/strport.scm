;;;;"strport.scm" Portable string ports for Scheme
;;;Copyright 1993 Dorai Sitaram and Aubrey Jaffer.
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

;N.B.: This implementation assumes you have tmpnam and
;delete-file defined in your .init file.  tmpnam generates
;temp file names.  delete-file may be defined to be a dummy
;procedure that does nothing.
;@
(define (call-with-output-string f)
  (let ((tmpf (tmpnam)))
    (call-with-output-file tmpf f)
    (let ((s "") (buf (make-string 512)))
      (call-with-input-file tmpf
	(lambda (inp)
	  (let loop ((i 0))
	    (let ((c (read-char inp)))
	      (cond ((eof-object? c)
		     (set! s (string-append s (substring buf 0 i))))
		    ((>= i 512)
		     (set! s (string-append s buf (string c)))
		     (loop 0))
		    (else
		     (string-set! buf i c)
		     (loop (+ i 1))))))))
      (delete-file tmpf)
      s)))
;@
(define (call-with-input-string s f)
  (let ((tmpf (tmpnam)))
    (call-with-output-file tmpf
      (lambda (outp)
	(display s outp)))
    (let ((x (call-with-input-file tmpf f)))
      (delete-file tmpf)
      x)))
