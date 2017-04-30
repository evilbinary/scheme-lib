;"top-refs.scm" List Scheme code's top-level variable references.
;Copyright (C) 1995, 2003 Aubrey Jaffer
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

(require 'fluid-let)
(require 'line-i/o)			; exports<-info-index uses
(require 'string-case)			; exports<-info-index uses
(require 'string-search)		; exports<-info-index uses
(require 'manifest)			; load->path

;;@code{(require 'top-refs)}
;;@ftindex top-refs
;;@cindex top-level variable references
;;@cindex variable references
;;
;;@noindent
;;These procedures complement those in @ref{Module Manifests} by
;;finding the top-level variable references in Scheme source code.
;;They work by traversing expressions and definitions, keeping track
;;of bindings encountered.  It is certainly possible to foil these
;;functions, but they return useful information about SLIB source
;;code.

(define *references* '())
(define *bindings* '())

(define (top-refs:warn proc msg . more)
  (for-each display (list "WARN:" proc ": " msg " "))
  (for-each (lambda (x) (write x) (display #\space))
	    more)
  (newline))
;;@body
;;Returns a list of the top-level variables referenced by the Scheme
;;expression @1.
(define (top-refs obj)
  (fluid-let ((*references* '()))
    (if (string? obj)
	(top-refs:include obj)
	(top-refs:top-level obj))
    *references*))
;;@body
;;@1 should be a string naming an existing file containing Scheme
;;source code.  @0 returns a list of the top-level variable references
;;made by expressions in the file named by @1.
;;
;;Code in modules which @1 @code{require}s is not traversed.  Code in
;;files loaded from top-level @emph{is} traversed if the expression
;;argument to @code{load}, @code{slib:load}, @code{slib:load-source},
;;@code{macro:load}, @code{defmacro:load}, @code{synclo:load},
;;@code{syncase:load}, or @code{macwork:load} is a literal string
;;constant or composed of combinations of vicinity functions and
;;string literal constants; and the resulting file exists (possibly
;;with ".scm" appended).
(define (top-refs<-file filename)
  (fluid-let ((*references* '()))
    (top-refs:include filename)
    *references*))

(define (top-refs:include filename)
  (cond ((not (and (string? filename) (file-exists? filename)))
	 (top-refs:warn 'top-refs:include 'skipping filename))
	(else (call-with-input-file filename
		(lambda (port)
		  (with-load-pathname filename
		    (lambda ()
		      (do ((exp (read port) (read port)))
			  ((eof-object? exp))
			(top-refs:top-level exp)))))))))

(define (top-refs:top-level exp)
  (cond ((not (and (pair? exp) (list? exp)))
	 (top-refs:warn 'top-refs "non-list at top level?" exp))
	((not (symbol? (car exp))) (top-refs:expression exp))
	(else
	 (case (car exp)
	   ((begin) (for-each top-refs:top-level (cdr exp)))
	   ((cond)  (for-each (lambda (clause)
				(for-each top-refs:top-level clause))
			      (cdr exp)))
	   ((if)    (for-each top-refs:top-level
			      (if (list? (cadr exp)) (cdr exp) (cddr exp))))
	   ((define define-operation)
	    ;;(display ";  walking ") (write (cadr exp)) (newline)
	    (top-refs:binding (cadr exp) (cddr exp)))
	   ((define-syntax)
	    (top-refs:binding (cadr exp) (cddr exp)))
	   ((defmacro)
	    ;;(display ";  malking ") (write (cadr exp)) (newline)
	    (if (pair? (cadr exp))
		(top-refs:binding (cdadr exp) (cddr exp))
		(top-refs:binding (caddr exp) (cdddr exp))))
	   ((load slib:load slib:load-source macro:load defmacro:load
		  syncase:load synclo:load macwork:load)
	    (top-refs:include (load->path (cadr exp))))
	   ;;((require) (top-refs:require ''compiling (cadr exp)))
	   ;;((require-if) (top-refs:require (cadr exp) (caddr exp)))
	   (else (top-refs:expression exp))))))

(define (arglist:flatten b)
  (cond ((symbol? b) (list b))
	((pair? b)
	 (if (pair? (car b))
	     (append (arglist:flatten (car b)) (arglist:flatten (cdr b)))
	     (cons (car b) (arglist:flatten (cdr b)))))
	((list? b) b)
	(else (slib:error 'arglist:flatten 'bad b))))

(define (top-refs:binding binding body)
  (fluid-let ((*bindings* (append (arglist:flatten binding)
				  *bindings*)))
    (for-each (lambda (exp)
		(cond ((and (pair? exp) (eq? 'define (car exp)))
		       (set! *bindings* (cons (if (symbol? (cadr exp))
						  (cadr exp)
						  (caadr exp))
					      *bindings*)))))
	      body)
    (for-each top-refs:expression body)))

(define (top-refs:expression exp)
  (define (cwq exp)
    (cond ((vector? exp) (for-each cwq (vector->list exp)))
	  ((not (pair? exp)))
	  ((not (list? exp)) (top-refs:warn " dotted list? " exp))
	  ((memq (car exp) '(unquote unquote-splicing))
	   (top-refs:expression (cadr exp)))
	  (else (for-each cwq exp))))
  (define (cwe exp)
    (cond ((symbol? exp)
	   (if (and (not (memq exp *bindings*))
		    (not (memq exp *references*)))
	       (set! *references* (cons exp *references*))))
	  ((not (pair? exp)))
	  ((not (list? exp))
	   (for-each top-refs:expression (arglist:flatten exp)))
	  ((not (symbol? (car exp))) (for-each top-refs:expression exp))
	  (else
	   (case (car exp)
	     ((quote) #f)
	     ((quasiquote) (cwq (cadr exp)))
	     ((begin) (for-each cwe (cdr exp)))
	     ((define)
	      (cond ((pair? (cadr exp)) ; (define (foo ...) ...)
		     (top-refs:binding (cadr exp) (cddr exp)))
		    (else
		     (top-refs:binding (cadr exp) (list (cddr exp))))))
	     ((lambda) (top-refs:binding (cadr exp) (cddr exp)))
	     ((case)
	      (top-refs:expression (cadr exp))
	      (for-each (lambda (exp)
			  (if (list? exp)
			      (for-each top-refs:expression (cdr exp))
			      (top-refs:expression exp)))
			(cddr exp)))
	     ((cond)
	      (for-each (lambda (exp)
			  (if (list? exp)
			      (for-each top-refs:expression exp)
			      (top-refs:expression exp)))
			(cdr exp)))
	     ((let)
	      (cond ((symbol? (cadr exp))
		     (for-each top-refs:expression (map cadr (caddr exp)))
		     (top-refs:binding (cons (cadr exp) (map car (caddr exp)))
				       (cdddr exp)))
		    (else
		     (for-each top-refs:expression (map cadr (cadr exp)))
		     (top-refs:binding (map car (cadr exp)) (cddr exp)))))
	     ((letrec with-syntax)
	      (top-refs:binding
	       (map car (cadr exp)) (append (map cadr (cadr exp)) (cddr exp))))
	     ((let*)
	      (cond ((null? (cadr exp))
		     (top-refs:binding '() (cddr exp)))
		    ((pair? (caadr exp))
		     (top-refs:expression (cadr (caadr exp)))
		     (top-refs:binding (caaadr exp)
				       `((let* ,(cdadr exp) ,@(cddr exp)))))
		    (else
		     (top-refs:binding (list (caadr exp))
				       `((let* ,(cdadr exp) ,@(cddr exp)))))))
	     ((do)
	      (for-each top-refs:expression (map cadr (cadr exp)))
	      (top-refs:binding
	       (map car (cadr exp))
	       (append
		(map (lambda (binding)
		       (case (length binding)
			 ((2) (car binding))
			 ((3) (caddr binding))
			 (else (top-refs:warn
				'top-refs:expression 'bad 'do-binding exp))))
		     (cadr exp))
		(caddr exp)
		(cddr exp))))
	     ((syntax-rules)
	      (fluid-let ((*bindings* (append (arglist:flatten (cadr exp))
					      *bindings*)))
		(for-each (lambda (exp)
			    (top-refs:binding (car exp) (cdr exp)))
			  (cddr exp))))
	     ((syntax-case)
	      (fluid-let ((*bindings*
			   (cons (cadr exp)
				 (append (arglist:flatten (caddr exp))
					 *bindings*))))
		(for-each (lambda (exp)
			    (top-refs:binding (car exp) (cdr exp)))
			  (cdddr exp))))
	     (else (for-each top-refs:expression exp))))))
  (cwe exp))

;;@noindent
;;The following function parses an @dfn{Info} Index.
;;@footnote{Although it will
;;work on large info files, feeding it an excerpt is much faster; and
;;has less chance of being confused by unusual text in the info file.
;;This command excerpts the SLIB index into @file{slib-index.info}:
;;
;;@example
;;info -f slib2d6.info -n "Index" -o slib-index.info
;;@end example
;;}

;;@body
;;@2 @dots{} must be an increasing series of positive integers.
;;@0 returns a list of all the identifiers appearing in the @var{n}th
;;@dots{} (info) indexes of @1.  The identifiers have the case that
;;the implementation's @code{read} uses for symbols.  Identifiers
;;containing spaces (eg. @code{close-base on base-table}) are
;;@emph{not} included.  #f is returned if the index is not found.
;;
;;Each info index is headed by a @samp{* Menu:} line.  To list the
;;symbols in the first and third info indexes do:
;;
;;@example
;;(exports<-info-index "slib.info" 1 3)
;;@end example
(define (exports<-info-index file . n)
  (call-with-input-file file
    (lambda (port)
      (define exports '())
      (and
       (find-string-from-port? " Node: Index," port)
       (let loop ((line (read-line port))
		  (iidx 1)
		  (ndxs n))
	 (cond ((null? ndxs) (reverse exports))
	       ((eof-object? line) #f)
	       ((not (string-ci=? "* Menu:" line))
		(loop (read-line port) iidx ndxs))
	       ((>= iidx (car ndxs))
		(let ((blank (read-line port)))
		  (if (not (equal? "" blank))
		      (slib:error 'funny 'blank blank)))
		(do ((line (read-line port) (read-line port)))
		    ((or (eof-object? line)
			 (not (and (> (string-length line) 5)
				   (or (string=? "* " (substring line 0 2))
				       (substring? "(line " line)))))
		     (loop (read-line port) (+ 1 iidx) (cdr ndxs)))
		  (and
		   (string=? "* " (substring line 0 2))
		   (let ((<n> (substring? " <" line)))
		     (define csi (or (and <n>
					  (> (string-length line) (+ 3 <n>))
					  (string-index
					   "0123456789"
					   (string-ref line (+ 2 <n>)))
					  <n>)
				     (substring? ": " line)))
		     (and
		      csi
		      (let ((str (substring line 2 csi)))
			(if (and (not (substring? " " str))
				 (not (memq (string-ci->symbol str) exports)))
			    (set! exports (cons (string-ci->symbol str) exports)))))))))
	       (else (loop (read-line port) (+ 1 iidx) ndxs))))))))
