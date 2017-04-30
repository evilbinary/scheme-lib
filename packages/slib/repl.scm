; "repl.scm", read-eval-print-loop for Scheme
; Copyright (C) 1993, 2003 Aubrey Jaffer
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

(require 'values)
(require 'dynamic-wind)
(require-if 'compiling 'qp)
(require-if 'compiling 'debug)
;@
(define (repl:quit) (slib:error "not in repl:repl"))
;@
(define (repl:top-level repl:eval)
  (repl:repl (lambda () (display "> ")
		     (force-output (current-output-port))
		     (read))
	     repl:eval
	     (lambda objs
	       (cond ((null? objs))
		     (else
		      (write (car objs))
		      (for-each (lambda (obj)
				  (display " ;") (newline) (write obj))
				(cdr objs))))
	       (newline))))

(define (repl:repl repl:read repl:eval repl:print)
  (let* ((old-quit repl:quit)
	 (old-error slib:error)
	 (old-eval slib:eval)
	 (old-load load)
	 (repl:load (lambda (<pathname>)
		      (call-with-input-file <pathname>
			(lambda (port)
			  (with-load-pathname <pathname>
			    (lambda ()
			      (do ((o (read port) (read port)))
				  ((eof-object? o))
				(repl:eval o))))))))
	 (repl:restart #f)
	 (has-char-ready? (provided? 'char-ready?))
	 (repl:error (lambda args (require 'debug) (apply qpn args)
			     (repl:restart #f))))
    (dynamic-wind
	(lambda ()
	  (set! load repl:load)
	  (set! slib:eval repl:eval)
	  (set! slib:error repl:error)
	  (set! repl:quit
		(lambda () (let ((cont repl:restart))
			     (set! repl:restart #f)
			     (cont #t)))))
	(lambda ()
	  (do () ((call-with-current-continuation
		   (lambda (cont)
		     (set! repl:restart cont)
		     (do ((obj (repl:read) (repl:read)))
			 ((eof-object? obj) (repl:quit))
		       (cond
			(has-char-ready?
			 (let loop ()
			   (cond ((char-ready?)
				  (let ((c (peek-char)))
				    (cond
				     ((eof-object? c))
				     ((char=? #\newline c) (read-char))
				     ((char-whitespace? c)
				      (read-char) (loop))
				     (else (newline)))))))))
		       (call-with-values (lambda () (repl:eval obj))
			 repl:print)))))))
	(lambda () (cond (repl:restart
			  (display ">>ERROR<<") (newline)
			  (repl:restart #f)))
		(set! load old-load)
		(set! slib:eval old-eval)
		(set! slib:error old-error)
		(set! repl:quit old-quit)))))
