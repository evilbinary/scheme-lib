;;;; "ppfile.scm".  Pretty print a Scheme file.
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

(require 'pretty-print)

;@
(define (pprint-filter-file inport filter . optarg)
  ((lambda (fun)
     (if (input-port? inport)
	 (fun inport)
	 (call-with-input-file inport fun)))
   (lambda (port)
     ((lambda (fun)
	(let ((outport
	       (if (null? optarg) (current-output-port) (car optarg))))
	  (if (output-port? outport)
	      (fun outport)
	      (call-with-output-file outport fun))))
      (lambda (export)
	(with-load-pathname inport
	  (letrec ((lp (lambda (c)
			 (cond ((eof-object? c))
			       ((char-whitespace? c)
				(display (read-char port) export)
				(lp (peek-char port)))
			       ((char=? #\; c)
				(cmt c))
			       (else (sx)))))
		   (cmt (lambda (c)
			  (cond ((eof-object? c))
				((char=? #\newline c)
				 (display (read-char port) export)
				 (lp (peek-char port)))
				(else
				 (display (read-char port) export)
				 (cmt (peek-char port))))))
		   (sx (lambda ()
			 (let ((o (read port)))
			   (cond ((eof-object? o))
				 (else
				  (pretty-print (filter o) export)
				  ;; pretty-print seems to have extra newline
				  (let ((c (peek-char port)))
				    (cond ((eqv? #\newline c)
					   (read-char port)
					   (set! c (peek-char port))))
				    (lp c))))))))
	    (lambda ()
	      (lp (peek-char port))))))))))
;@
(define (pprint-file ifile . optarg)
  (pprint-filter-file ifile
		      identity
		      (if (null? optarg) (current-output-port) (car optarg))))
