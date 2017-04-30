;;;;"scanf.scm" implemenation of formatted input
;Copyright (C) 1996, 1997, 2003, 2010 Aubrey Jaffer
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

;;; Originally jjb@isye.gatech.edu (John Bartholdi) wrote some public
;;; domain code for a subset of scanf, but it was too difficult to
;;; extend to POSIX pattern compliance.  Jan 96, I rewrote the scanf
;;; functions starting from the POSIX man pages.

(require 'string-port)
(require 'multiarg-apply)
(require 'rev2-procedures)
(require 'rev4-optional-procedures)

(define (stdio:scan-and-set format-string input-port . args)
  (define setters (if (equal? '(#f) args) #f args))
  (define assigned-count 0)
  (define chars-scanned 0)
  (define items '())
  (define (return)
    (cond ((and (zero? chars-scanned)
		(eof-object? (peek-char input-port)))
	   (peek-char input-port))
	  (setters assigned-count)
	  (else (reverse items))))
  (cond
   ((equal? "" format-string) (return))
   ((string? input-port)
    (call-with-input-string
	input-port
      (lambda (str-port)
	(apply stdio:scan-and-set format-string str-port args))))
   (else
    (call-with-input-string
	format-string
      (lambda (format-port)

	(define (char-non-numeric? c) (not (char-numeric? c)))

	(define (flush-whitespace port)
	  (do ((c (peek-char port) (peek-char port))
	       (i 0 (+ 1 i)))
	      ((or (eof-object? c) (not (char-whitespace? c))) i)
	    (read-char port)))

	(define (flush-whitespace-input)
	  (set! chars-scanned (+ (flush-whitespace input-port) chars-scanned)))

	(define (read-input-char)
	  (set! chars-scanned (+ 1 chars-scanned))
	  (read-char input-port))

	(define (add-item report-field? next-item)
	  (cond (setters
		 (cond ((and report-field? (null? setters))
			(slib:error 'scanf "not enough variables for format"
				    format-string))
		       ((not next-item) (return))
		       ((not report-field?) (loop1))
		       (else
			(let ((suc ((car setters) next-item)))
			  (cond ((not (boolean? suc))
				 (slib:warn 'scanf "setter returned non-boolean"
					    suc)))
			  (set! setters (cdr setters))
			  (cond ((not suc) (return))
				((eqv? -1 report-field?) (loop1))
				(else
				 (set! assigned-count (+ 1 assigned-count))
				 (loop1)))))))
		((not next-item) (return))
		(report-field? (set! items (cons next-item items))
			       (loop1))
		(else (loop1))))

	(define (read-string width separator?)
	  (cond (width
		 (let ((str (make-string width)))
		   (do ((i 0 (+ 1 i)))
		       ((>= i width)
			str)
		     (let ((c (peek-char input-port)))
		       (cond ((eof-object? c)
			      (set! str (substring str 0 i))
			      (set! i width))
			     ((separator? c)
			      (set! str (if (zero? i) "" (substring str 0 i)))
			      (set! i width))
			     (else
			      (string-set! str i (read-input-char))))))))
		(else
		 (do ((c (peek-char input-port) (peek-char input-port))
		      (l '() (cons c l)))
		     ((or (eof-object? c) (separator? c))
		      (list->string (reverse l)))
		   (read-input-char)))))

	(define (read-word width separator?)
	  (let ((l (read-string width separator?)))
	    (if (zero? (string-length l)) #f l)))

	(define (loop1)
	  (define fc (read-char format-port))
	  (cond
	   ((eof-object? fc)
	    (return))
	   ((char-whitespace? fc)
	    (flush-whitespace format-port)
	    (flush-whitespace-input)
	    (loop1))
	   ((eqv? #\% fc)		; interpret next format
	    (set! fc (read-char format-port))
	    (let ((report-field? (not (eqv? #\* fc)))
		  (width #f))

	      (define (width--) (if width (set! width (+ -1 width))))

	      (define (read-u)
		(string->number (read-string width char-non-numeric?)))

	      (define (read-o)
		(string->number
		 (read-string
		  width
		  (lambda (c)
		    (not (memv c '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)))))
		 8))

	      (define (read-x)
		(string->number
		 (read-string
		  width
		  (lambda (c) (not (memv (char-downcase c)
					 '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8
					   #\9 #\a #\b #\c #\d #\e #\f)))))
		 16))

	      (define (read-radixed-unsigned)
		(let ((c (peek-char input-port)))
		  (case c
		    ((#\0) (read-input-char) (width--)
		     (set! c (peek-char input-port))
		     (case c
		       ((#\x #\X) (read-input-char) (width--) (read-x))
		       (else (read-o))))
		    (else (read-u)))))

	      (define (read-ui)
		(let* ((dot? #f)
		       (mantissa
			(read-word
			 width
			 (lambda (c)
			   (not (or (char-numeric? c)
				    (cond (dot? #f)
					  ((eqv? #\. c) (set! dot? #t) #t)
					  (else #f)))))))
		       (exponent
			(cond
			 ((not mantissa) #f)
			 ((and (or (not width) (> width 1))
			       (memv (peek-char input-port) '(#\E #\e)))
			  (read-input-char)
			  (width--)
			  (let* ((expsign
				  (case (peek-char input-port)
				    ((#\-) (read-input-char)
				     (width--) "-")
				    ((#\+) (read-input-char)
				     (width--) "+")
				    (else "")))
				 (expint
				  (and (or (not width) (positive? width))
				       (read-word width char-non-numeric?))))
			    (and expint (string-append "e" expsign expint))))
			 (else #f))))
		  (and mantissa
		       (string->number
			(string-append
			 "#i" (or mantissa "") (or exponent ""))))))

	      (define (read-signed proc)
		(case (peek-char input-port)
		  ((#\-) (read-input-char) (width--)
		   (let ((ret (proc))) (and ret (- ret))))
		  ((#\+) (read-input-char) (width--) (proc))
		  (else (proc))))

	      ;;(trace read-word read-signed read-ui read-radixed-unsigned read-x read-o read-u)

	      (cond ((not report-field?) (set! fc (read-char format-port))))
	      (if (char-numeric? fc) (set! width 0))
	      (do () ((or (eof-object? fc) (char-non-numeric? fc)))
		(set! width (+ (* 10 width) (string->number (string fc))))
		(set! fc (read-char format-port)))
	      (case fc			;ignore h,l,L modifiers.
		((#\h #\l #\L) (set! fc (read-char format-port))))
	      (case fc
		((#\n) (if (not report-field?)
			   (slib:error 'scanf "not saving %n??"))
		 (add-item -1 chars-scanned)) ;-1 is special flag.
		((#\c #\C)
		 (if (not width) (set! width 1))
		 (let ((str (make-string width)))
		   (do ((i 0 (+ 1 i))
			(c (peek-char input-port) (peek-char input-port)))
		       ((or (>= i width)
			    (eof-object? c))
			(add-item report-field? (substring str 0 i)))
		     (string-set! str i (read-input-char)))))
		((#\s #\S)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-word width char-whitespace?)))
		((#\[)
		 (set! fc (read-char format-port))
		 (let ((allbut #f))
		   (case fc
		     ((#\^) (set! allbut #t)
		      (set! fc (read-char format-port))))

		   (let scanloop ((scanset (list fc)))
		     (set! fc (read-char format-port))
		     (case fc
		       ((#\-)
			(set! fc (peek-char format-port))
			(cond
			 ((and (char<? (car scanset) fc)
			       (not (eqv? #\] fc)))
			  (set! fc (char->integer fc))
			  (do ((i (char->integer (car scanset)) (+ 1 i)))
			      ((> i fc) (scanloop scanset))
			    (set! scanset (cons (integer->char i) scanset))))
			 (else (scanloop (cons #\- scanset)))))
		       ((#\])
			(add-item report-field?
				  (read-word
				   width
				   (if allbut (lambda (c) (memv c scanset))
				       (lambda (c) (not (memv c scanset)))))))
		       (else (cond
			      ((eof-object? fc)
			       (slib:error 'scanf "unmatched [ in format"))
			      (else (scanloop (cons fc scanset)))))))))
		((#\o #\O)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-o)))
		((#\u #\U)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-u)))
		((#\d #\D)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-signed read-u)))
		((#\x #\X)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-x)))
		((#\e #\E #\f #\F #\g #\G)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-signed read-ui)))
		((#\i)
		 ;;(flush-whitespace-input)
		 (add-item report-field? (read-signed read-radixed-unsigned)))
		((#\%)
		 (cond ((or width (not report-field?))
			(slib:error 'SCANF "%% has modifiers?"))
		       ((eqv? #\% (read-input-char))
			(loop1))
		       (else (return))))
		(else (slib:error 'SCANF
				  "Unknown format directive:" fc)))))
	   ((eqv? (peek-char input-port) fc)
	    (read-input-char)
	    (loop1))
	   (else (return))))
	;;(trace flush-whitespace-input flush-whitespace add-item return read-string read-word loop1)
	(loop1))))))

;;;This implements a Scheme-oriented version of SCANF: returns a list of
;;;objects read (rather than set!-ing values).
;@
(define (scanf-read-list format-string . optarg)
  (define input-port
    (cond ((null? optarg) (current-input-port))
	  ((not (null? (cdr optarg)))
	   (slib:error 'scanf-read-list 'wrong-number-of-args optarg))
	  (else (car optarg))))
  (cond ((input-port? input-port)
	 (stdio:scan-and-set format-string input-port #f))
	((string? input-port)
	 (call-with-input-string
	     input-port (lambda (input-port)
			  (stdio:scan-and-set format-string input-port #f))))
	(else (slib:error 'scanf-read-list "argument 2 not a port"
			  input-port))))

(define (stdio:setter-procedure sexp)
  (let ((v (gentemp)))
    (cond ((symbol? sexp) `(lambda (,v) (set! ,sexp ,v) #t))
	  ((not (and (pair? sexp) (list? sexp)))
	   (slib:error 'scanf "setter expression not understood" sexp))
	  (else
	   (case (car sexp)
	     ((vector-ref) `(lambda (,v) (vector-set! ,@(cdr sexp) ,v) #t))
	     ((array-ref) `(lambda (,v) (array-set! ,(cadr sexp) ,v ,@(cddr sexp)) #t))
	     ((substring)
	      `(lambda (,v) (substring-move-left!
			     ,v 0 (min (string-length ,v)
				       (- ,(cadddr sexp) ,(caddr sexp)))
			     ,(cadr sexp) ,(caddr sexp))
		       #t))
	     ((list-ref)
	      `(lambda (,v) (set-car! (list-tail ,@(cdr sexp)) ,v) #t))
	     ((car) `(lambda (,v) (set-car! ,@(cdr sexp) ,v) #t))
	     ((cdr) `(lambda (,v) (set-cdr! ,@(cdr sexp) ,v) #t))
	     (else (slib:error 'scanf "setter not known" sexp)))))))

;@
(defmacro scanf (format-string . args)
  `(stdio:scan-and-set ,format-string (current-input-port)
		       ,@(map stdio:setter-procedure args)))
;@
(defmacro sscanf (str format-string . args)
  `(stdio:scan-and-set ,format-string ,str
		       ,@(map stdio:setter-procedure args)))
;@
(defmacro fscanf (input-port format-string . args)
  `(stdio:scan-and-set ,format-string ,input-port
		       ,@(map stdio:setter-procedure args)))
