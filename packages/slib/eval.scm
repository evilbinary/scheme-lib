; "eval.scm", Eval proposed by Guillermo (Bill) J. Rozas for R5RS.
; Copyright (C) 1997, 1998 Aubrey Jaffer
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

;;; Rather than worry over the status of all the optional procedures,
;;; just require as many as possible.

(require 'rev4-optional-procedures)
(require 'dynamic-wind)
(require 'transcript)
(require 'with-file)
(require 'values)

(define eval:make-environment
  (let ((eval-1 slib:eval))
    (lambda (identifiers)
      ((lambda args args)
       #f
       identifiers
       (lambda (expression)
	 (eval-1 `(lambda ,identifiers ,expression)))))))

(define eval:capture-environment!
  (let ((set-car! set-car!)
	(eval-1 slib:eval)
	(apply apply))
    (lambda (environment)
      (set-car!
       environment
       (apply (lambda (environment-values identifiers procedure)
		(eval-1 `((lambda args args) ,@identifiers)))
	      environment)))))
;@
(define interaction-environment
  (let ((env (eval:make-environment '())))
    (lambda () env)))

;;;@ null-environment is set by first call to scheme-report-environment at
;;; the end of this file.
(define null-environment #f)
;@
(define scheme-report-environment
  (let* ((r4rs-procedures
	  (append
	   (cond ((provided? 'inexact)
		  (append
		   '(acos angle asin atan cos exact->inexact exp
			  expt imag-part inexact->exact log magnitude
			  make-polar make-rectangular real-part sin
			  sqrt tan)
		   (if (let ((n (string->number "1/3")))
			 (and (number? n) (exact? n)))
		       '(denominator numerator)
		       '())))
		 (else '()))
	   (cond ((provided? 'rationalize)
		  '(rationalize))
		 (else '()))
	   (cond ((provided? 'delay)
		  '(force))
		 (else '()))
	   (cond ((provided? 'char-ready?)
		  '(char-ready?))
		 (else '()))
	   '(* + - / < <= = > >= abs append apply assoc assq assv boolean?
	       caaaar caaadr caaar caadar caaddr caadr caar cadaar cadadr cadar
	       caddar cadddr caddr cadr call-with-current-continuation
	       call-with-input-file call-with-output-file car cdaaar cdaadr
	       cdaar cdadar cdaddr cdadr cdar cddaar cddadr cddar cdddar cddddr
	       cdddr cddr cdr ceiling char->integer char-alphabetic?  char-ci<=?
	       char-ci<?  char-ci=?  char-ci>=?  char-ci>?  char-downcase
	       char-lower-case?  char-numeric?  char-upcase char-upper-case?
	       char-whitespace?  char<=?  char<?  char=?  char>=?  char>?  char?
	       close-input-port close-output-port complex?  cons
	       current-input-port current-output-port display eof-object?  eq?
	       equal?  eqv?  even?  exact?  floor for-each gcd inexact?
	       input-port?  integer->char integer?  lcm length list list->string
	       list->vector list-ref list-tail list?  load make-string
	       make-vector map max member memq memv min modulo negative?
	       newline not null?  number->string number?  odd?  open-input-file
	       open-output-file output-port?  pair?  peek-char positive?
	       procedure?  quotient rational?  read read-char real?  remainder
	       reverse round set-car!  set-cdr!  string string->list
	       string->number string->symbol string-append string-ci<=?
	       string-ci<?  string-ci=?  string-ci>=?  string-ci>?  string-copy
	       string-fill!  string-length string-ref string-set!  string<=?
	       string<?  string=?  string>=?  string>?  string?  substring
	       symbol->string symbol?  transcript-off transcript-on truncate
	       vector vector->list vector-fill!  vector-length vector-ref
	       vector-set!  vector?  with-input-from-file with-output-to-file
	       write write-char zero?
	       )))
	 (r5rs-procedures
	  (append
	   '(call-with-values dynamic-wind eval interaction-environment
			      null-environment scheme-report-environment values)
	   r4rs-procedures))
	 (r4rs-environment (eval:make-environment r4rs-procedures))
	 (r5rs-environment (eval:make-environment r5rs-procedures)))
    (let ((car car))
      (lambda (version)
	(cond ((car r5rs-environment))
	      (else
	       (let ((null-env (eval:make-environment r5rs-procedures)))
		 (set-car! null-env (map (lambda (i) #f) r5rs-procedures))
		 (set! null-environment (lambda version null-env)))
	       (eval:capture-environment! r4rs-environment)
	       (eval:capture-environment! r5rs-environment)))
	(case version
	  ((4) r4rs-environment)
	  ((5) r5rs-environment)
	  (else (slib:error 'eval 'version version 'not 'available)))))))
;@
(define eval
  (let ((eval-1 slib:eval)
	(apply apply)
	(null? null?)
	(eq? eq?))
    (lambda (expression . environment)
      (if (null? environment) (eval-1 expression)
	  (apply
	   (lambda (environment)
	     (if (eq? (interaction-environment) environment) (eval-1 expression)
		 (apply (lambda (environment-values identifiers procedure)
			  (apply (procedure expression) environment-values))
			environment)))
	   environment)))))
(set! slib:eval eval)

;;; Now that all the R5RS procedures are defined, capture r5rs-environment.
(and (scheme-report-environment 5) #t)
