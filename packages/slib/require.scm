;;;; Implementation of VICINITY and MODULES for Scheme
;Copyright (C) 1991, 1992, 1993, 1994, 1997, 2002, 2003, 2005 Aubrey Jaffer
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
;@
(define *slib-version* "3b5")

;;;; MODULES
;@
(define *catalog* #f)
(define *base-table-implementations* '())
;@
(define (slib:version path)
  (let ((expr (and (file-exists? path)
		   (call-with-input-file path (lambda (port) (read port))))))
    (and (list? expr) (= 3 (length expr))
	 (eq? (car expr) 'define) (eq? (cadr expr) '*slib-version*)
	 (string? (caddr expr)) (caddr expr))))

(define (catalog/require-version-match? slibcat)
  (let* ((apair (assq '*slib-version* slibcat))
	 (req (in-vicinity (library-vicinity)
			   (string-append "require" (scheme-file-suffix))))
	 (reqvers (slib:version req)))
    (cond ((not (file-exists? req))
	   (slib:warn "can't find " req) #f)
	  ((not apair) #f)
	  ((not (equal? reqvers (cdr apair))) #f)
	  ((not (equal? reqvers *slib-version*))
	   (slib:warn "The loaded " req " is stale.")
	   #t)
	  (else #t))))

(define (catalog:try-read vicinity name)
  (or (and vicinity name
	   (let ((path (in-vicinity vicinity name)))
	     (and (file-exists? path)
		  (call-with-input-file path
		    (lambda (port)
		      (do ((expr (read port) (read port))
			   (lst '() (cons expr lst)))
			  ((eof-object? expr)
			   (apply append lst))))))))
      '()))
;@
(define (catalog:resolve vicinity catlist)
  (define (res1 e) (if (string? e) (in-vicinity vicinity e) e))
  (define (resolve p)
    (cond ((symbol? (cdr p)) p)
	  ((not (list? p)) (cons (car p) (res1 (cdr p))))
	  ((null? (cddr p)) (cons (car p) (res1 (cadr p))))
	  (else (map res1 p))))
  (map resolve catlist))
;@
(define (catalog:read vicinity cat)
  (catalog:get #f)			; make sure *catalog* exists
  (set! *catalog*
	(append (catalog:resolve vicinity (catalog:try-read vicinity cat))
		*catalog*)))

(define (catalog:get feature)
  (if (not *catalog*)
      (let ((slibcat (catalog:try-read (implementation-vicinity) "slibcat")))
	(cond ((not (catalog/require-version-match? slibcat))
	       (slib:load-source (in-vicinity (library-vicinity) "mklibcat"))
	       (set! slibcat
		     (catalog:try-read (implementation-vicinity) "slibcat"))))
	(cond (slibcat
	       (set! *catalog* ((slib:eval
				 (cadr (or (assq 'catalog:filter slibcat)
					   '(#f identity))))
				slibcat))))
	(and (home-vicinity)
	     (set! *catalog*
		   (append (catalog:try-read (home-vicinity) "homecat")
			   *catalog*)))
	(set! *catalog*
	      (append (catalog:try-read (user-vicinity) "usercat") *catalog*))))
  (and feature *catalog* (cdr (or (assq feature *catalog*) '(#f . #f)))))
;@
(define (slib:in-catalog? feature)
  (let ((path (catalog:get feature)))
    (if (symbol? path) (slib:in-catalog? path) path)))

;@
(define (feature-eval expression provided?)
  (define (bail expression)
    (slib:error 'invalid 'feature 'expression expression))
  (define (feval expression)
    (cond ((not expression) expression)
	  ((symbol? expression) (provided? expression))
	  ((and (list? expression) (pair? expression))
	   (case (car expression)
	     ((not) (case (length expression)
		      ((2) (not (feval (cadr expression))))
		      (else (bail expression))))
	     ((or)  (case (length expression)
		      ((1) #f)
		      ;;((2) (feval (cadr expression)))
		      (else (or (feval (cadr expression))
				(feval (cons 'or (cddr expression)))))))
	     ((and) (case (length expression)
		      ((1) #t)
		      ;;((2) (feval (cadr expression)))
		      (else (and (feval (cadr expression))
				 (feval (cons 'and (cddr expression)))))))
	     (else (bail expression))))
	  (else (bail expression))))
  (feval expression))
;@
(define (slib:provided? expression)
  (define feature-list (cons (scheme-implementation-type)
			     (cons (software-type) slib:features)))
  (define (provided? expression)
    (if (memq expression feature-list) #t
	(and *catalog*
	     (let ((path (catalog:get expression)))
	       (cond ((symbol? path) (provided? path))
		     (else #f))))))
  (feature-eval expression provided?))
;@
(define (slib:provide feature)
  (if (not (memq feature slib:features))
      (set! slib:features (cons feature slib:features))))
;@
(define (slib:require feature)
  (cond
   ((not feature) (set! *catalog* #f))
   ((slib:provided? feature))
   (else
    (let ((path (catalog:get feature)))
      (cond ((not path)
	     (slib:error 'slib:require 'unsupported 'feature feature))
	    ((symbol? path) (slib:provide feature) (slib:require path))
	    ((string? path)		;simple name
	     (if (not (eq? 'new-catalog feature)) (slib:provide feature))
	     (slib:load path))
	    (else			;dispatched loads
	     (slib:require (car path))
	     (if (not (eq? 'new-catalog feature)) (slib:provide feature))
	     (apply (case (car path)
		      ((macro) macro:load)
		      ((syntactic-closures) synclo:load)
		      ((syntax-case) syncase:load)
		      ((macros-that-work) macwork:load)
		      ((macro-by-example) defmacro:load)
		      ((defmacro) defmacro:load)
		      ((source) slib:load-source)
		      ((compiled) slib:load-compiled)
		      ((aggregate)
		       (lambda feature (for-each slib:require feature)))
		      ((spectral-tristimulus-values) load-ciexyz)
		      ((color-names)
		       (lambda (filename)
			 (load-color-dictionary feature filename)))
		      (else (slib:error "unknown package loader" path)))
		    (if (list? path) (cdr path) (list (cdr path))))))))))
;@
(define (slib:require-if feature? feature)
  (if (slib:provided? feature?) (slib:require feature)))

;@
(define provide slib:provide)
(define provided? slib:provided?)
(define require slib:require)
(define require-if slib:require-if)

(let ((x (string->number "0.0")))
  (if (and x (inexact? x)) (slib:provide 'inexact)))
(if (rational? (string->number "1/19")) (slib:provide 'rational))
(let ((x (string->number "0.01")))
  (if (and (real? x) (not (integer? x))) (slib:provide 'real)))
(let ((z (string->number "0.01+i")))
  (if (and (complex? z) (not (real? z))) (slib:provide 'complex)))
(let ((n (string->number "9999999999999999999999999999999")))
  (if (and n (exact? n)) (slib:provide 'bignum)))

(cond
 ((slib:provided? 'srfi-0)
  (slib:provide 'srfi-59)
  (slib:provide 'srfi-96)
  (do ((idx 0 (+ 1 idx))
       (srfis (symbol->string 'srfi-)))
      ((> idx 150))
    (let ((srfi (string->symbol (string-append srfis (number->string idx)))))
      (if (slib:eval `(cond-expand (,srfi #t) (else #f)))
	  (slib:provide srfi))))))

(define (slib:pathnameize-load *old-load*)
  (lambda (<pathname> . extra)
    (with-load-pathname <pathname>
      (lambda ()
	(apply *old-load* (cons <pathname> extra))))))

(set! slib:load-source
      (slib:pathnameize-load slib:load-source))
(set! slib:load
      (slib:pathnameize-load slib:load))

;@
(define (slib:eval-load <pathname> evl)
  (if (not (file-exists? <pathname>))
      (set! <pathname> (string-append <pathname> (scheme-file-suffix))))
  (call-with-input-file <pathname>
    (lambda (port)
      (with-load-pathname <pathname>
	(lambda ()
	  (do ((o (read port) (read port)))
	      ((eof-object? o))
	    (evl o)))))))

(define (report:print . args)
  (for-each (lambda (x) (write x) (display #\space)) args)
  (newline))
;@
(define (slib:report . args)
  (define rpt (lambda () (slib:report-version) (slib:report-locations #t)))
  (cond ((null? args)
	 (slib:report-version) (slib:report-locations))
	((not (string? (car args)))
	 (rpt))
	((slib:provided? 'transcript)
	 (transcript-on (car args))
	 (rpt)
	 (transcript-off))
	((slib:provided? 'with-file)
	 (with-output-to-file (car args) rpt))
	(else (rpt))))

;@
(define (slib:report-version)
  (report:print
   'SLIB *slib-version* 'on (scheme-implementation-type)
   (scheme-implementation-version) 'on (software-type)))

(define slib:report-locations
  (let ((lfeatures slib:features))	; Capture load-time value
    (lambda args
      (define sit (scheme-implementation-type))
      (define siv (string->symbol (scheme-implementation-version)))
      (report:print '(IMPLEMENTATION-VICINITY) 'is (implementation-vicinity))
      (report:print '(LIBRARY-VICINITY) 'is (library-vicinity))
      (report:print '(SCHEME-FILE-SUFFIX) 'is (scheme-file-suffix))
      (let* ((i (+ -1 5)))
	(cond ((eq? (car lfeatures) (car slib:features)))
	      (else (report:print 'loaded 'SLIB:FEATURES ':) (display slib:tab)))
	(for-each
	 (lambda (x)
	   (cond ((eq? (car lfeatures) x)
		  (if (not (eq? (car lfeatures) (car slib:features))) (newline))
		  (report:print sit siv 'SLIB:FEATURES ':)
		  (display slib:tab) (set! i (+ -1 5)))
		 ((zero? i) (newline) (display slib:tab) (set! i (+ -1 5)))
		 ((not (= (+ -1 5) i)) (display #\space)))
	   (write x) (set! i (+ -1 i)))
	 slib:features))
      (newline)
      (report:print sit siv '*CATALOG* ':)
      (catalog:get #f)
      (cond ((pair? args)
	     (for-each (lambda (x) (display slib:tab) (report:print x))
		       *catalog*))
	    (else (display slib:tab) (report:print (car *catalog*))
		  (display slib:tab) (report:print '...)))
      (newline))))

(let ((siv (scheme-implementation-version)))
  (cond ((zero? (string-length siv)))
	((or (not (string? siv)) (char=? #\? (string-ref siv 0)))
	 (newline)
	 (slib:report-version)
	 (report:print 'edit (scheme-implementation-type) ".init"
		       'to 'set '(scheme-implementation-version) 'string)
	 (report:print '(IMPLEMENTATION-VICINITY) 'is (implementation-vicinity))
	 (report:print 'type '(slib:report) 'for 'configuration)
	 (newline))))
