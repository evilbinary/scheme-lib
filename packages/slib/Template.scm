;;; "Template.scm" configuration template of slib:features for Scheme -*-scheme-*-
;;; Author: Aubrey Jaffer
;;;
;;; This code is in the public domain.

;;@ (software-type) should be set to the generic operating system type.
;;; unix, vms, macos, amiga and ms-dos are supported.
(define (software-type) 'unix)

;;@ (scheme-implementation-type) should return the name of the scheme
;;; implementation loading this file.
(define (scheme-implementation-type) 'Template)

;;@ (scheme-implementation-home-page) should return a (string) URI
;;; (Uniform Resource Identifier) for this scheme implementation's home
;;; page; or false if there isn't one.
(define (scheme-implementation-home-page) #f)

;;@ (scheme-implementation-version) should return a string describing
;;; the version the scheme implementation loading this file.
(define (scheme-implementation-version) "?")

;;@ (implementation-vicinity) should be defined to be the pathname of
;;; the directory where any auxillary files to your Scheme
;;; implementation reside.
(define implementation-vicinity
  (let ((impl-path
	 (or (getenv "{TEMPLATE}_IMPLEMENTATION_PATH")
	     (case (software-type)
	       ((unix) "/usr/local/src/scheme/")
	       ((vms) "scheme$src:")
	       ((ms-dos) "C:\\scheme\\")
	       (else "")))))
    (lambda () impl-path)))

;;@ (library-vicinity) should be defined to be the pathname of the
;;; directory where files of Scheme library functions reside.
(define library-vicinity
  (let ((library-path
	 (or
	  ;; Use this getenv if your implementation supports it.
	  (getenv "SCHEME_LIBRARY_PATH")
	  ;; Use this path if your scheme does not support GETENV
	  ;; or if SCHEME_LIBRARY_PATH is not set.
	  (case (software-type)
	    ((unix) "/usr/local/lib/slib/")
	    ((vms) "lib$scheme:")
	    ((ms-dos) "C:\\SLIB\\")
	    (else "")))))
    (lambda () library-path)))

;;@ (home-vicinity) should return the vicinity of the user's HOME
;;; directory, the directory which typically contains files which
;;; customize a computer environment for a user.
(define (home-vicinity)
  (let ((home (getenv "HOME")))
    (and home
	 (case (software-type)
	   ((unix coherent ms-dos)	;V7 unix has a / on HOME
	    (if (eqv? #\/ (string-ref home (+ -1 (string-length home))))
		home
		(string-append home "/")))
	   (else home)))))

;@
(define in-vicinity string-append)
;@
(define (user-vicinity)
  (case (software-type)
    ((vms)	"[.]")
    (else	"")))

(define *load-pathname* #f)
;@
(define vicinity:suffix?
  (let ((suffi
	 (case (software-type)
	   ((amiga)				'(#\: #\/))
	   ((macos thinkc)			'(#\:))
	   ((ms-dos windows atarist os/2)	'(#\\ #\/))
	   ((nosve)				'(#\: #\.))
	   ((unix coherent plan9)		'(#\/))
	   ((vms)				'(#\: #\]))
	   (else
	    (slib:warn "require.scm" 'unknown 'software-type (software-type))
	    "/"))))
    (lambda (chr) (and (memv chr suffi) #t))))
;@
(define (pathname->vicinity pathname)
  (let loop ((i (- (string-length pathname) 1)))
    (cond ((negative? i) "")
	  ((vicinity:suffix? (string-ref pathname i))
	   (substring pathname 0 (+ i 1)))
	  (else (loop (- i 1))))))
(define (program-vicinity)
  (if *load-pathname*
      (pathname->vicinity *load-pathname*)
      (slib:error 'program-vicinity " called; use slib:load to load")))
;@
(define sub-vicinity
  (case (software-type)
    ((vms) (lambda (vic name)
	     (let ((l (string-length vic)))
	       (if (or (zero? (string-length vic))
		       (not (char=? #\] (string-ref vic (- l 1)))))
		   (string-append vic "[" name "]")
		   (string-append (substring vic 0 (- l 1))
				  "." name "]")))))
    (else (let ((*vicinity-suffix*
		 (case (software-type)
		   ((nosve) ".")
		   ((macos thinkc) ":")
		   ((ms-dos windows atarist os/2) "\\")
		   ((unix coherent plan9 amiga) "/"))))
	    (lambda (vic name)
	      (string-append vic name *vicinity-suffix*))))))
;@
(define (make-vicinity <pathname>) <pathname>)
;@
(define with-load-pathname
  (let ((exchange
	 (lambda (new)
	   (let ((old *load-pathname*))
	     (set! *load-pathname* new)
	     old))))
    (lambda (path thunk)
      (let ((old #f))
	(dynamic-wind
	    (lambda () (set! old (exchange path)))
	    thunk
	    (lambda () (exchange old)))))))

;;@ SLIB:FEATURES is a list of symbols naming the (SLIB) features
;;; initially supported by this implementation.
(define slib:features
      '(
	source				;can load scheme source files
					;(SLIB:LOAD-SOURCE "filename")
;;;	compiled			;can load compiled files
					;(SLIB:LOAD-COMPILED "filename")
	vicinity
	srfi-59
	srfi-96

		       ;; Scheme report features
   ;; R5RS-compliant implementations should provide all 9 features.

	r5rs				;conforms to
	eval				;R5RS two-argument eval
	values				;R5RS multiple values
	dynamic-wind			;R5RS dynamic-wind
	macro				;R5RS high level macros
	delay				;has DELAY and FORCE
	multiarg-apply			;APPLY can take more than 2 args.
	char-ready?
	rev4-optional-procedures	;LIST-TAIL, STRING-COPY,
					;STRING-FILL!, and VECTOR-FILL!

      ;; These four features are optional in both R4RS and R5RS

;;;	multiarg/and-			;/ and - can take more than 2 args.
	rationalize
;;;	transcript			;TRANSCRIPT-ON and TRANSCRIPT-OFF
;;;	with-file			;has WITH-INPUT-FROM-FILE and
					;WITH-OUTPUT-TO-FILE

	r4rs				;conforms to

	ieee-p1178			;conforms to

;;;	r3rs				;conforms to

;;;	rev2-procedures			;SUBSTRING-MOVE-LEFT!,
					;SUBSTRING-MOVE-RIGHT!,
					;SUBSTRING-FILL!,
					;STRING-NULL?, APPEND!, 1+,
					;-1+, <?, <=?, =?, >?, >=?
;;;	object-hash			;has OBJECT-HASH

	full-continuation		;can return multiple times
	ieee-floating-point		;conforms to IEEE Standard 754-1985
					;IEEE Standard for Binary
					;Floating-Point Arithmetic.

			;; Other common features

	srfi-0				;srfi-0, COND-EXPAND finds all srfi-*
;;;	sicp				;runs code from Structure and
					;Interpretation of Computer
					;Programs by Abelson and Sussman.
	defmacro			;has Common Lisp DEFMACRO
;;;	syntax-case			;has syncase:eval and syncase:load
;;;	record				;has user defined data structures
;;;	string-port			;has CALL-WITH-INPUT-STRING and
					;CALL-WITH-OUTPUT-STRING
;;;	sort
;;;	pretty-print
;;;	object->string
;;;	format				;Common-lisp output formatting
;;;	trace				;has macros: TRACE and UNTRACE
;;;	compiler			;has (COMPILER)
;;;	ed				;(ED) is editor
;;;	system				;posix (system <string>)
	getenv				;posix (getenv <string>)
;;;	program-arguments		;returns list of strings (argv)
;;;	current-time			;returns time in seconds since 1/1/1970

		  ;; Implementation Specific features

	))

;;@ (FILE-POSITION <port> . <k>)
(define (file-position . args) #f)

;;@ (OUTPUT-PORT-WIDTH <port>)
(define (output-port-width . arg) 79)

;;@ (OUTPUT-PORT-HEIGHT <port>)
(define (output-port-height . arg) 24)

;;@ (CURRENT-ERROR-PORT)
(define current-error-port
  (let ((port (current-output-port)))
    (lambda () port)))

;;@ (TMPNAM) makes a temporary file name.
(define tmpnam (let ((cntr 100))
		 (lambda () (set! cntr (+ 1 cntr))
			 (string-append "slib_" (number->string cntr)))))

;;@ (FILE-EXISTS? <string>)
(define (file-exists? f) #f)

;;@ (DELETE-FILE <string>)
(define (delete-file f) #f)

;;@ FORCE-OUTPUT flushes any pending output on optional arg output port
;;; use this definition if your system doesn't have such a procedure.
(define (force-output . arg) #t)

;;; CALL-WITH-INPUT-STRING and CALL-WITH-OUTPUT-STRING are the string
;;; port versions of CALL-WITH-*PUT-FILE.

;;@ "rationalize" adjunct procedures.
;;(define (find-ratio x e)
;;  (let ((rat (rationalize x e)))
;;    (list (numerator rat) (denominator rat))))
;;(define (find-ratio-between x y)
;;  (find-ratio (/ (+ x y) 2) (/ (- x y) 2)))

;;@ CHAR-CODE-LIMIT is one greater than the largest integer which can
;;; be returned by CHAR->INTEGER.
(define char-code-limit 256)

;;@ MOST-POSITIVE-FIXNUM is used in modular.scm
(define most-positive-fixnum #x0FFFFFFF)

;;@ Return argument
(define (identity x) x)

;;@ SLIB:EVAL is single argument eval using the top-level (user) environment.
(define slib:eval eval)

(define *defmacros*
  (list (cons 'defmacro
	      (lambda (name parms . body)
		`(set! *defmacros* (cons (cons ',name (lambda ,parms ,@body))
					 *defmacros*))))))
;@
(define (defmacro? m) (and (assq m *defmacros*) #t))
;@
(define (macroexpand-1 e)
  (if (pair? e)
      (let ((a (car e)))
	(cond ((symbol? a) (set! a (assq a *defmacros*))
	       (if a (apply (cdr a) (cdr e)) e))
	      (else e)))
      e))
;@
(define (macroexpand e)
  (if (pair? e)
      (let ((a (car e)))
	(cond ((symbol? a)
	       (set! a (assq a *defmacros*))
	       (if a (macroexpand (apply (cdr a) (cdr e))) e))
	      (else e)))
      e))
;@
(define gentemp
  (let ((*gensym-counter* -1))
    (lambda ()
      (set! *gensym-counter* (+ *gensym-counter* 1))
      (string->symbol
       (string-append "slib:G" (number->string *gensym-counter*))))))

(define base:eval slib:eval)
;@
(define (defmacro:eval x) (base:eval (defmacro:expand* x)))

(define (defmacro:expand* x)
  (slib:require 'defmacroexpand) (apply defmacro:expand* x '()))
;@
(define (defmacro:load <pathname>)
  (slib:eval-load <pathname> defmacro:eval))
;@
(define slib:warn
  (lambda args
    (let ((cep (current-error-port)))
      (if (provided? 'trace) (print-call-stack cep))
      (display "Warn: " cep)
      (for-each (lambda (x) (display #\space cep) (write x cep)) args)
      (newline cep))))

;;@ define an error procedure for the library
(define slib:error
  (let ((error error))
    (lambda args
      (if (provided? 'trace) (print-call-stack (current-error-port)))
      (apply error args))))
;@
(define (make-exchanger obj)
  (lambda (rep) (let ((old obj)) (set! obj rep) old)))
(define (open-file filename modes)
  (case modes
    ((r rb) (open-input-file filename))
    ((w wb) (open-output-file filename))
    (else (slib:error 'open-file 'mode? modes))))
(define (port? obj) (or (input-port? obj) (output-port? obj)))
(define (call-with-open-ports . ports)
  (define proc (car ports))
  (cond ((procedure? proc) (set! ports (cdr ports)))
	(else (set! ports (reverse ports))
	      (set! proc (car ports))
	      (set! ports (reverse (cdr ports)))))
  (let ((ans (apply proc ports)))
    (for-each close-port ports)
    ans))
(define (close-port port)
  (cond ((input-port? port)
	 (close-input-port port)
	 (if (output-port? port) (close-output-port port)))
	((output-port? port) (close-output-port port))
	(else (slib:error 'close-port 'port? port))))
;@
(define (browse-url url)
  (define (try cmd end) (zero? (system (string-append cmd url end))))
  (or (try "netscape-remote -remote 'openURL(" ")'")
      (try "netscape -remote 'openURL(" ")'")
      (try "netscape '" "'&")
      (try "netscape '" "'")))

;;@ define these as appropriate for your system.
(define slib:tab (integer->char 9))
(define slib:form-feed (integer->char 12))

;;@ Support for older versions of Scheme.  Not enough code for its own file.
(define (last-pair l) (if (pair? (cdr l)) (last-pair (cdr l)) l))
(define t #t)
(define nil #f)

;;@ Define these if your implementation's syntax can support it and if
;;; they are not already defined.
;(define (1+ n) (+ n 1))
;(define (-1+ n) (+ n -1))
;(define 1- -1+)

;;@ Define SLIB:EXIT to be the implementation procedure to exit or
;;; return if exiting not supported.
(define slib:exit (lambda args #f))

;;@ Here for backward compatability
(define scheme-file-suffix
  (let ((suffix (case (software-type)
		  ((nosve) "_scm")
		  (else ".scm"))))
    (lambda () suffix)))

;;@ (SLIB:LOAD-SOURCE "foo") should load "foo.scm" or with whatever
;;; suffix all the module files in SLIB have.  See feature 'SOURCE.
(define (slib:load-source f) (load (string-append f ".scm")))

;;@ (SLIB:LOAD-COMPILED "foo") should load the file that was produced
;;; by compiling "foo.scm" if this implementation can compile files.
;;; See feature 'COMPILED.
(define slib:load-compiled load)

;;@ At this point SLIB:LOAD must be able to load SLIB files.
(define slib:load slib:load-source)

;;; If your implementation provides R4RS macros:
;;(define macro:eval slib:eval)
;;(define macro:load slib:load-source)

;;; If your implementation provides syntax-case macros:
;;(define syncase:eval slib:eval)
;;(define syncase:load slib:load-source)

(slib:load (in-vicinity (library-vicinity) "require"))
