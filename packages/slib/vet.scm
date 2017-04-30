;"vet.scm"  Check exports, references, and documentation of library modules.
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

;;@code{(require 'vet)}
;;@ftindex vet

(require 'common-list-functions)
(require 'top-refs)
(require 'manifest)

(define r4rs-symbols
  '(* + - -> / < <= = => > >= ... abs acos and angle append apply asin
      assoc assq assv atan begin boolean? caaaar caaadr caaar caadar
      caaddr caadr caar cadaar cadadr cadar caddar cadddr caddr cadr
      call-with-current-continuation call-with-input-file
      call-with-output-file car case cdaaar cdaadr cdaar cdadar cdaddr
      cdadr cdar cddaar cddadr cddar cdddar cddddr cdddr cddr cdr
      ceiling char->integer char-alphabetic? char-ci<=? char-ci<?
      char-ci=? char-ci>=? char-ci>? char-downcase char-lower-case?
      char-numeric? char-ready? char-upcase char-upper-case?
      char-whitespace? char<=? char<? char=? char>=? char>?  char?
      close-input-port close-output-port complex? cond cons cos
      current-input-port current-output-port define display do else
      eof-object? eq? equal? eqv? even? exact->inexact exact? exp expt
      floor for-each gcd if imag-part implementation-vicinity
      in-vicinity inexact->exact inexact?  input-port? integer->char
      integer? lambda lcm length let let* letrec library-vicinity list
      list-ref list->string list->vector list? load log magnitude
      make-polar make-rectangular make-string make-vector
      make-vicinity map max member memq memv min modulo negative?
      newline not null? number->string number?  odd? open-input-file
      open-output-file or output-port? pair?  peek-char positive?
      procedure? quasiquote quotient rational?  read read-char
      real-part real? remainder reverse round set!  set-car!  set-cdr!
      sin sqrt string string->list string->number string->symbol
      string-append string-ci<=? string-ci<?  string-ci=? string-ci>=?
      string-ci>? string-length string-ref string-set! string<=?
      string<? string=? string>=? string>?  string? sub-vicinity
      substring symbol->string symbol? tan truncate unquote
      unquote-splicing user-vicinity vector vector->list vector-length
      vector-ref vector-set! vector? write write-char zero? ))

(define (path<-entry entry)
  (define (findit path)
    (cond ((not (string? path)) #f)
	  ((file-exists? path) path)
	  ((file-exists? (string-append path ".scm"))
	   (string-append path ".scm"))
	  (else #f)))
  (cond ((string? (cdr entry)) (findit (cdr entry)))
	((not (pair? (cdr entry))) #f)
	(else (case (cadr entry)
		((source defmacro macro syntactic-closures
			 syntax-case macros-that-work)
		 (let ((lp (last-pair entry)))
		   (or (and (string? (car lp)) (findit (car lp)))
		       (and (string? (cdr lp)) (findit (cdr lp))))))
		(else #f)))))

(define slib:catalog (cdr (member (assq 'null *catalog*) *catalog*)))

(define (top-refs<-files filenames)
  (remove-duplicates (apply append (map top-refs<-file filenames))))

(define (provided+? . features)
  (lambda (feature)
    (or (memq feature features) (provided? feature))))

(define (requires<-file filename)
  (file->requires filename (provided+? 'compiling) slib:catalog))

(define (requires<-files filenames)
  (remove-duplicates (apply append (map requires<-file filenames))))

(define (definitions<-files filenames)
  (remove-duplicates (apply append (map file->definitions filenames))))

(define (exports<-files filenames)
  (remove-duplicates (apply append (map file->exports filenames))))

(define (code-walk-justify lst . margins)
  (define left-margin (case (length margins)
			((1 2 3) (car margins))
			((0) 0)
			(else (slib:error 'code-walk-justify 'wna margins))))
  (define right-margin (case (length margins)
			 ((2 3) (cadr margins))
			 (else (output-port-width))))
  (define spacer (case (length margins)
		   ((3) (caddr margins))
		   (else #\space)))
  (cond ((>= left-margin right-margin)
	 (slib:error 'code-walk-justify
		     " left margin must be smaller than right: "
		     margins)))
  (let ((cur left-margin)
	(lms (make-string left-margin #\space)))
    (display lms)
    (for-each
     (lambda (obj)
       (if (symbol? obj) (set! obj (symbol->string obj)))
       (let ((objl (string-length obj)))
	 (cond ((= left-margin cur)
		(display obj)
		(set! cur (+ objl cur)))
	       ((<= right-margin (+ 1 objl cur))
		(newline)
		(set! cur (+ objl left-margin))
		(display lms) (display obj))
	       (else
		(display #\space)
		(display obj)
		(set! cur (+ 1 objl cur))))))
     lst)))

;;@args file1 @dots{}
;;Using the procedures in the @code{top-refs} and @code{manifest}
;;modules, @0 analyzes each SLIB module and @1, @dots{}, reporting
;;about any procedure or macro defined whether it is:
;;
;;@table @asis
;;
;;@item orphaned
;;defined, not called, not exported;
;;@item missing
;;called, not defined, and not exported by its @code{require}d modules;
;;@item undocumented-export
;;Exported by module, but no index entry in @file{slib.info};
;;
;;@end table
;;
;;And for the library as a whole:
;;
;;@table @asis
;;
;;@item documented-unexport
;;Index entry in @file{slib.info}, but no module exports it.
;;
;;@end table
;;
;;This straightforward analysis caught three full days worth of
;;never-executed branches, transitive require assumptions, spelling
;;errors, undocumented procedures, missing procedures, and cyclic
;;dependencies in SLIB.
;;
;;The optional arguments @1, @dots{} provide a simple way to vet
;;prospective SLIB modules.
(define (vet-slib . files)
  (define infos
    (exports<-info-index (in-vicinity (library-vicinity) "slib.info") 1 2))
  (define r4rs+slib #f)
  (define export-alist '())
  (define all-exports '())
  (define slib-exports
    (union '(system getenv current-time difftime offset-time)
	   (union (file->exports
		   (in-vicinity (library-vicinity) "Template.scm"))
		  (file->exports
		   (in-vicinity (library-vicinity) "require.scm")))))
  (define (show lst name)
    (cond ((not (null? lst))
	   (display " ") (display name) (display ":") (newline)
	   (code-walk-justify lst 10)
	   (newline))))
  (define (dopath path)
    (define paths (cons path (file->loads path)))
    (let ((requires (requires<-files paths))
	  (defines (definitions<-files paths))
	  (exports (exports<-files paths))
	  (top-refs (top-refs<-files paths)))
      (define orphans (set-difference (set-difference defines exports)
				      top-refs))
      (define missings (set-difference
			(set-difference top-refs defines)
			r4rs+slib))
      (set! all-exports (union exports all-exports))
      (for-each (lambda (req)
		  (define pr (assq req export-alist))
		  (and pr (set! missings (set-difference missings (cdr pr)))))
		requires)
      (let ((undocs (set-difference exports (union r4rs-symbols infos))))
	(cond ((not (every null? (list undocs orphans missings)))
	       (write paths) (newline)
	       ;;(show requires 'requires)
	       ;;(show defines 'defines)
	       ;;(show exports 'exports)
	       (show undocs 'undocumented-exports)
	       (show orphans 'orphans)
	       (show missings 'missing)
	       )))))
  (set! r4rs+slib (union r4rs-symbols slib-exports))
  (let ((catalog
	 (append (map (lambda (file) (cons (string->symbol file) file))
		      files)
		 slib:catalog)))
    (for-each (lambda (entry)
		(set! export-alist
		      (cons (cons (car entry)
				  (feature->exports (car entry) slib:catalog))
			    export-alist)))
	      catalog)
    (for-each (lambda (entry)
		(define path (path<-entry entry))
		(and path (dopath path)))
	      catalog))
  (write '("SLIB"))
  (show (set-difference infos (union r4rs+slib all-exports))
	'documented-unexports))
