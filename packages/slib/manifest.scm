;"manifest.scm" List SLIB module requires and exports.
;Copyright (C) 2003 Aubrey Jaffer
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

(require 'line-i/o)

;;@code{(require 'manifest)}
;;@ftindex manifest

;;@noindent
;;In some of these examples, @var{slib:catalog} is the SLIB part of
;;the catalog; it is free of compiled and implementation-specific
;;entries.  It would be defined by:
;;
;;@example
;;(define slib:catalog (cdr (member (assq 'null *catalog*) *catalog*)))
;;@end example

;;@body
;;Returns a list of the features @code{require}d by @1 assuming the
;;predicate @2 and association-list @3.
(define (file->requires file provided? catalog)
  (call-with-input-file file
    (lambda (port)
      (define requires '())
      (define (add-require feature)
;;; 	(if (and (not (provided? (cadr feature)))
;;; 		 (not (assq (cadr feature) catalog)))
;;; 	    (slib:warn file 'unknown 'feature feature))
	(if (not (memq (cadr feature) requires))
	    (set! requires (cons (cadr feature) requires))))
      (if (eqv? #\# (peek-char port)) (read-line port))
      (let loop ((sexp (read port)))
	(cond ((eof-object? sexp) (reverse requires))
	      ((pair? sexp)
	       (case (car sexp)
		 ((require)
		  (cond ((not (= 2 (length sexp)))
			 (slib:warn 'bad 'require sexp))
			(else (add-require (cadr sexp))))
		  (loop (read port)))
		 ((require-if)
		  (cond ((not (= 3 (length sexp)))
			 (slib:warn 'bad 'require-if sexp))
			((not (and (pair? (cadr sexp))
				   (list? (cadr sexp))
				   (eq? 'quote (caadr sexp))))
			 (slib:warn
			  'file->requires 'unquoted 'feature))
			((feature-eval
			  (cadadr sexp)
			  (lambda (expression)
			    (if (provided? expression) #t
				(let ((path (cdr (or (assq expression catalog)
						     '(#f . #f)))))
				  (cond ((symbol? path) (provided? path))
					(else #f))))))
			 (add-require (caddr sexp))))
		  (loop (read port)))
		 (else (reverse requires))))
	      (else (loop (read port))))))))
;;@example
;;(define (provided+? . features)
;;  (lambda (feature)
;;    (or (memq feature features) (provided? feature))))
;;
;;(file->requires "obj2str.scm" (provided+? 'compiling) '())
;;        @result{} (string-port generic-write)
;;
;;(file->requires "obj2str.scm" provided? '())
;;        @result{} (string-port)
;;@end example

;;@body
;;Returns a list of the features @code{require}d by @1 assuming the
;;predicate @2 and association-list @3.
(define (feature->requires feature provided? catalog)
  (define (f2r feature)
    (define path (cdr (or (assq feature catalog) '(#f . #f))))
    (define (return path)
      (file->requires (string-append path (scheme-file-suffix))
		      provided? catalog))
    (cond ((not path) #f)
	  ((string? path) (return path))
	  ((symbol? path) (f2r path))
	  ((not (pair? path)) (slib:error feature 'path? path))
	  (else (case (car path)
		  ((source defmacro macro-by-example macro macros-that-work
			   syntax-case syntactic-closures)
		   (return (if (pair? (cdr path))
			       (cadr path)
			       (cdr path))))
		  ((compiled) (list feature))
		  ((aggregate)
		   (apply append (map f2r (cdr path))))
		  (else (slib:error feature 'feature? path))))))
  (f2r feature))
;;@example
;;(feature->requires 'batch (provided+? 'compiling) *catalog*)
;;        @result{} (tree line-i/o databases parameters string-port
;;                   pretty-print common-list-functions posix-time)
;;
;;(feature->requires 'batch provided? *catalog*)
;;        @result{} (tree line-i/o databases parameters string-port
;;                   pretty-print common-list-functions)
;;
;;(feature->requires 'batch provided? '((batch . "batch")))
;;        @result{} (tree line-i/o databases parameters string-port
;;                   pretty-print common-list-functions)
;;@end example

(define (features->requires* features provided? catalog)
  (and
   features
   (let loop ((new features)
	      (done '()))
     (cond
      ((null? new) done)
      ((memq (car new) done) (loop (cdr new) done))
      (else
       (loop (append (or (feature->requires (car new) provided? catalog) '())
		     (cdr new))
	     (cons (car new) done)))))))

;;@body
;;Returns a list of the features transitively @code{require}d by @1
;;assuming the predicate @2 and association-list @3.
(define (feature->requires* feature provided? catalog)
  (features->requires* (or (feature->requires feature provided? catalog) '())
		       provided? catalog))

;;@body
;;Returns a list of the features transitively @code{require}d by @1
;;assuming the predicate @2 and association-list @3.
(define (file->requires* file provided? catalog)
  (features->requires* (file->requires file provided? catalog)
		       provided? catalog))

;;@body
;;Returns a list of strings naming existing files loaded (load
;;slib:load slib:load-source macro:load defmacro:load syncase:load
;;synclo:load macwork:load) by @1 or any of the files it loads.
(define (file->loads file)
  (define loads '())
  (define (f2l file)
    (call-with-input-file file
      (lambda (port)
	(define (sxp o)
	  (cond ((eof-object? o))
		((not (list? o)))
		((< (length o) 2))
		((memq (car o) '(load slib:load slib:load-source macro:load
				      defmacro:load syncase:load synclo:load
				      macwork:load))
		 (let ((path (load->path (cadr o))))
		   (cond ((not (member path loads))
			  (set! loads (cons path loads))
			  (f2l path)))
		   (sxp (read port))))
		((eq? 'begin (car o)) (for-each sxp (cdr o)))
		(else (sxp (read port)))))
	(with-load-pathname file
	  (lambda ()
	    (if (eqv? #\# (peek-char port)) (read-line port))
	    (sxp (read port))
	    loads)))))
  (f2l file))
;;@example
;;(file->loads (in-vicinity (library-vicinity) "scainit.scm"))
;;        @result{} ("/usr/local/lib/slib/scaexpp.scm"
;;            "/usr/local/lib/slib/scaglob.scm"
;;            "/usr/local/lib/slib/scaoutp.scm")
;;@end example

;;@body
;;Given a @code{(load '<expr>)}, where <expr> is a string or vicinity
;;stuff), @code{(load->path <expr>)} figures a path to the file.
;;@0 returns that path if it names an existing file; otherwise #f.
(define (load->path exp)
  (define (cwv vicproc exp)
    (let ((a1 (cwp (cadr exp)))
	  (a2 (cwp (caddr exp))))
      (if (and (string? a1) (string? a2)) (vicproc a1 a2) exp)))
  (define (cwp exp)
    (cond ((string? exp) exp)
	  ((not (pair? exp)) ;(slib:warn 'load->path 'strange 'feature exp)
	   exp)
	  (else (case (car exp)
		  ((program-vicinity)        (program-vicinity))
		  ((library-vicinity)        (library-vicinity))
		  ((implementation-vicinity) (implementation-vicinity))
		  ((user-vicinity)           (user-vicinity))
		  ((in-vicinity)             (cwv in-vicinity exp))
		  ((sub-vicinity)            (cwv sub-vicinity exp))
		  (else                      (slib:eval exp))))))
  (let ((ans (cwp exp)))
    (if (and (string? ans) (file-exists? (string-append ans ".scm")))
	(string-append ans ".scm")
	ans)))
;;@example
;;(load->path '(in-vicinity (library-vicinity) "mklibcat"))
;;        @result{} "/usr/local/lib/slib/mklibcat.scm"
;;@end example

;;@body
;;Returns a list of the identifier symbols defined by SLIB (or
;;SLIB-style) file @1.  The optional arguments @2 should be symbols
;;signifying a defining form.  If none are supplied, then the symbols
;;@code{define-operation}, @code{define}, @code{define-syntax}, and
;;@code{defmacro} are captured.
(define (file->definitions file . definers)
  (if (null? definers)
      (set! definers '(define-operation define define-syntax defmacro)))
  (call-with-input-file file
    (lambda (port)
      (define defs '())
      (define (sxp o)
	(cond ((eof-object? o))
	      ((not (list? o)))
	      ((< (length o) 2))
	      ((eq? 'begin (car o)) (for-each sxp (cdr o)))
	      ((< (length o) 3))
	      ((not (memq (car o) definers)))
	      ((symbol? (cadr o)) (set! defs (cons (cadr o) defs)))
	      ((not (pair? (cadr o))))
	      ((not (symbol? (caadr o))))
	      (else (set! defs (cons (caadr o) defs))))
	(cond ((eof-object? o) defs)
	      (else (sxp (read port)))))
      (with-load-pathname file
	(lambda ()
	  (if (eqv? #\# (peek-char port)) (read-line port))
	  (sxp (read port))
	  defs)))))
;;@example
;;(file->definitions "random.scm")
;;        @result{} (*random-state* make-random-state
;;           seed->random-state copy-random-state random
;;           random:chunk)
;;@end example

;;@body
;;Returns a list of the identifier symbols exported (advertised) by
;;SLIB (or SLIB-style) file @1.  The optional arguments @2 should be
;;symbols signifying a defining form.  If none are supplied, then the
;;symbols @code{define-operation}, @code{define},
;;@code{define-syntax}, and @code{defmacro} are captured.
(define (file->exports file . definers)
  (if (null? definers)
      (set! definers '(define-operation define define-syntax defmacro)))
  (call-with-input-file file
    (lambda (port)
      (define exports '())
      (define seen-at? #f)
      (define (top)
	(define c (peek-char port))
	(cond ((eof-object? c))
	      ((char=? #\newline c)
	       (read-line port)
	       (set! seen-at? #f)
	       (top))
	      ((char-whitespace? c)
	       (read-char port)
	       (top))
	      ((char=? #\; c)
	       (read-char port)
	       (cmt))
	      (else (sxp (read port))
		    (if (char-whitespace? (peek-char port)) (read-char port))
		    (top))))
      (define (cmt)
	(define c (peek-char port))
	(cond ((eof-object? c))
	      ((char=? #\; c)
	       (read-char port)
	       (cmt))
	      ((char=? #\@ c)
	       (set! seen-at? #t)
	       (read-line port)
	       (top))
	      (else
	       (read-line port)
	       (top))))
      (define (sxp o)
	(cond ((eof-object? o))
	      ((not seen-at?))
	      ((not (list? o)))
	      ((< (length o) 2))
	      ((eq? 'begin (car o)) (for-each sxp (cdr o)))
	      ((< (length o) 3))
	      ((not (memq (car o) definers)))
	      ((symbol? (cadr o)) (set! exports (cons (cadr o) exports)))
	      ((not (pair? (cadr o))))
	      ((not (symbol? (caadr o))))
	      (else (set! exports (cons (caadr o) exports)))))
      (with-load-pathname file
	(lambda ()
	  (if (eqv? #\# (peek-char port)) (read-line port))
	  (top)
	  exports)))))
;;@example
;;(file->exports "random.scm")
;;        @result{} (make-random-state seed->random-state
;;            copy-random-state random)
;;
;;(file->exports "randinex.scm")
;;        @result{} (random:solid-sphere! random:hollow-sphere!
;;            random:normal-vector! random:normal
;;            random:exp random:uniform)
;;@end example

;;@body
;;Returns a list of lists; each sublist holding the name of the file
;;implementing @1, and the identifier symbols exported (advertised) by
;;SLIB (or SLIB-style) feature @1, in @2.
(define (feature->export-alist feature catalog)
  (define (f2e feature)
    (define path (cdr (or (assq feature catalog) '(#f . #f))))
    (define (return path)
      (define path_scm (string-append path (scheme-file-suffix)))
      (cond ((file-exists? path_scm)
	     (cons path_scm (file->exports path_scm)))
	    (else (slib:warn 'feature->export-alist 'path? path_scm)
		  (list path))))
    (cond ((not path) '())
	  ((symbol? path) (f2e path))
	  ((string? path) (list (return path)))
	  ((not (pair? path))
	   (slib:error 'feature->export-alist feature 'path? path))
	  (else (case (car path)
		  ((source defmacro macro-by-example macro macros-that-work
			   syntax-case syntactic-closures)
		   (list (return (if (pair? (cdr path))
				     (cadr path)
				     (cdr path)))))
		  ((compiled) (map list (cdr path)))
		  ((aggregate) (apply append (map f2e (cdr path))))
		  (else (slib:warn 'feature->export-alist feature 'feature? path)
			'())))))
  (f2e feature))
;;@body
;;Returns a list of all exports of @1.
(define (feature->exports feature catalog)
  (apply append (map cdr (feature->export-alist feature catalog))))
;;@noindent
;;In the case of @code{aggregate} features, more than one file may
;;have export lists to report:
;;
;;@example
;;(feature->export-alist 'r5rs slib:catalog))
;;        @result{} (("/usr/local/lib/slib/values.scm"
;;             call-with-values values)
;;            ("/usr/local/lib/slib/mbe.scm"
;;             define-syntax macro:expand
;;             macro:load macro:eval)
;;            ("/usr/local/lib/slib/eval.scm"
;;             eval scheme-report-environment
;;             null-environment interaction-environment))
;;
;;(feature->export-alist 'stdio *catalog*)
;;        @result{} (("/usr/local/lib/slib/scanf.scm"
;;             fscanf sscanf scanf scanf-read-list)
;;            ("/usr/local/lib/slib/printf.scm"
;;             sprintf printf fprintf)
;;            ("/usr/local/lib/slib/stdio.scm"
;;             stderr stdout stdin))
;;
;;(feature->exports 'stdio slib:catalog)
;;        @result{} (fscanf sscanf scanf scanf-read-list
;;             sprintf printf fprintf stderr stdout stdin)
;;@end example
