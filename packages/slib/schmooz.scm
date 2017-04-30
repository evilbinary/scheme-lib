;;; "schmooz.scm" Program for extracting texinfo comments from Scheme.
;;; Copyright (C) 1998, 2000 Radey Shouman and Aubrey Jaffer.
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

(require 'common-list-functions)	;some
(require 'string-search)
(require 'fluid-let)
(require 'line-i/o)			;read-line
(require 'filename)

;;(require 'debug) (set! *qp-width* 100) (define qreport qpn)

;;; REPORT an error or warning
(define report
  (lambda args
    (display *scheme-source-name*)
    (display ": In function `")
    (display *procedure*)
    (display "': ")
    (newline)

    (display *derived-txi-name*)
    (display ": ")
    (display *output-line*)
    (display ": warning: ")
    (apply qreport args)))

(define qreport
  (lambda args
    (for-each (lambda (x) (write x) (display #\space)) args)
    (newline)))

;;; This allows us to test without generating files
(define *scheme-source* (current-input-port))
(define *scheme-source-name* "stdin")
(define *derived-txi* (current-output-port))
(define *derived-txi-name* "?")

(define *procedure* #f)
(define *output-line* 0)

(define CONTLINE -80)

;;; OUT indents and displays the arguments
(define (out indent . args)
  (cond ((>= indent 0)
	 (newline *derived-txi*)
	 (set! *output-line* (+ 1 *output-line*))
	 (do ((j indent (- j 8)))
	     ((> 8 j)
	      (do ((i j (- i 1)))
		  ((>= 0 i))
		(display #\space *derived-txi*)))
	   (display #\	 *derived-txi*))))
  (for-each (lambda (a)
	      (cond ((symbol? a)
		     (display a *derived-txi*))
		    ((string? a)
		     (display a *derived-txi*)
;		     (cond ((string-index a #\newline)
;			    (set! *output-line* (+ 1 *output-line*))
;			    (report "newline in string" a)))
		     )
		    (else
		     (display a *derived-txi*))))
	    args))

;; LINE is a string, ISTRT the index in LINE at which to start.
;; Returns a list (next-char-number . list-of-tokens).
;; arguments look like:
;;    "(arg1 arg2)"  or "{arg1,arg2}" or the whole line is split
;; into whitespace separated tokens.
(define (parse-args line istrt)
  (define (tok1 istrt close sep? splice)
    (let loop-args ((istrt istrt)
		    (args '()))
      (let loop ((iend istrt))
	(cond ((>= iend (string-length line))
	       (if close
		   (slib:error close "not found in" line)
		   (cons iend
			 (reverse
			  (if (> iend istrt)
			      (cons (substring line istrt iend) args)
			      args)))))
	      ((eqv? close (string-ref line iend))
	       (cons (+ iend 1)
		     (reverse (if (> iend istrt)
				  (cons (substring line istrt iend) args)
				  args))))
	      ((sep? (string-ref line iend))
	       (let ((arg (and (> iend istrt)
			       (substring line istrt iend))))
		 (if (equal? arg splice)
		     (let ((rest (tok1 (+ iend 1) close sep? splice)))
		       (cons (car rest)
			     (append args (cadr rest))))
		     (loop-args (+ iend 1)
				(if arg
				    (cons arg args)
				    args)))))
	      (else
	       (loop (+ iend 1)))))))
  (let skip ((istrt istrt))
    (cond ((>= istrt (string-length line)) (cons istrt '()))
	  ((char-whitespace? (string-ref line istrt))
	   (skip (+ istrt 1)))
	  ((eqv? #\{ (string-ref line istrt))
	   (tok1 (+ 1 istrt) #\} (lambda (c) (eqv? c #\,)) #f))
	  ((eqv? #\( (string-ref line istrt))
	   (tok1 (+ 1 istrt) #\) char-whitespace? "."))
	  (else
	   (tok1 istrt #f char-whitespace? #f)))))


;; Substitute @ macros in string LINE.
;; Returns a list, the first element is the substituted version
;; of LINE, the rest are lists beginning with '@dfn or '@args
;; and followed by the arguments that were passed to those macros.
;; MACS is an alist of (macro-name . macro-value) pairs.
(define (substitute-macs line macs)
  (define (get-word i)
    (let loop ((j (+ i 1)))
      (cond ((>= j (string-length line))
	     (substring line i j))
	    ((or (char-alphabetic? (string-ref line j))
		 (char-numeric? (string-ref line j)))
	     (loop (+ j 1)))
	    (else (substring line i j)))))
  (let loop ((istrt 0)
	     (i 0)
	     (res '()))
    (cond ((>= i (string-length line))
	   (list
	    (apply string-append
		   (reverse
		    (cons (substring line istrt (string-length line))
			  res)))))
	  ((char=? #\@ (string-ref line i))
	   (let* ((w (get-word i))
		  (symw (string->symbol w)))
	     (cond ((eq? '@cname symw)
		    (let ((args (parse-args
				 line (+ i (string-length w)))))
		      (cond ((and args (= 2 (length args)))
			     (loop (car args) (car args)
				   (cons
				    (string-append
				     "@code{" (cadr args) "}")
				    (cons (substring line istrt i) res))))
			    (else
			     (report "@cname wrong number of args" line)
			     (loop istrt (+ i (string-length w)) res)))))
		   ((eq? '@dfn symw)
		    (let* ((args (parse-args
				  line (+ i (string-length w))))
			   (inxt (car args))
			   (rest (loop inxt inxt
				       (cons (substring line istrt inxt)
					     res))))
		      (cons (car rest)
			    (cons (cons '@dfn (cdr args))
				  (cdr rest)))))
		   ((eq? '@args symw)
		    (let* ((args (parse-args
				  line (+ i (string-length w))))
			   (inxt (car args))
			   (rest (loop inxt inxt res)))
		      (cons (car rest)
			    (cons (cons '@args (cdr args))
				  (cdr rest)))))
		   ((assq symw macs) =>
		    (lambda (s)
		      (loop (+ i (string-length w))
			    (+ i (string-length w))
			    (cons (cdr s)
				  (cons (substring line istrt i) res)))))
		   (else (loop istrt (+ i (string-length w)) res)))))
	  (else (loop istrt (+ i 1) res)))))


(define (sexp-def sexp)
  (and (pair? sexp)
       (memq (car sexp) '(DEFINE DEFVAR DEFCONST DEFINE-SYNTAX DEFMACRO))
       (car sexp)))

(define def->var-name cadr)

(define (def->args sexp)
  (define name (cadr sexp))
  (define (body forms)
    (if (pair? forms)
	(if (null? (cdr forms))
	    (form (car forms))
	    (body (cdr forms)))
	#f))
  (define (form sexp)
    (if (pair? sexp)
	(case (car sexp)
	  ((LAMBDA) (cons name (cadr sexp)))
	  ((BEGIN) (body (cdr sexp)))
	  ((LET LET* LETREC)
	   (if (or (null? (cadr sexp))
		   (pair? (cadr sexp)))
	       (body (cddr sexp))
	       (body (cdddr sexp))))	;named LET
	  (else #f))
	#f))
  (case (car sexp)
    ((DEFINE) (if (pair? name)
		  name
		  (form (caddr sexp))))
    ((DEFINE-SYNTAX)
     (case (caaddr sexp)
       ((SYNTAX-RULES)
	(caaddr (caddr sexp)))
       (else '())))
    ((DEFMACRO) (cons (cadr sexp) (caddr sexp)))
    ((DEFVAR DEFCONST) #f)
    (else (slib:error 'schmooz "doesn't look like definition" sexp))))

;; Generate alist of argument macro definitions.
;; If ARGS is a symbol or string, then the definitions will be used in a
;; `defvar', if ARGS is a (possibly improper) list, they will be used in
;; a `defun'.
(define (scheme-args->macros args)
  (define (arg->string a)
    (if (string? a) a (symbol->string a)))
  (define (arg->macros arg i)
    (let ((s (number->string i))
	  (m (string-append "@var{" (arg->string arg) "}")))
      (list (cons (string->symbol (string-append "@" s)) m)
	    (cons (string->symbol (string-append "@arg" s)) m))))
  (let* ((fun? (pair? args))
	 (arg0 (if fun? (car args) args))
	 (args (if fun? (cdr args) '())))
    (let ((m0 (string-append
	       (if fun? "@code{" "@var{") (arg->string arg0) "}")))
      (append
       (list (cons '@arg0 m0) (cons '@0 m0))
       (let recur ((i 1)
		   (args args))
	 (cond ((null? args) '())
	       ((or (symbol? args)		;Rest list
		    (string? args))
		(arg->macros args i))
	       (else
		(append (arg->macros (car args) i)
			(recur (+ i 1) (cdr args))))))))))

;; Extra processing to be done for @dfn
(define (out-cindex arg)
  (out 0 "@cindex " arg))

;; ARGS looks like the cadr of a function definition:
;; (fun-name arg1 arg2 ...)
(define (schmooz-fun defop args body xdefs)
  (define (out-header args op)
    (let ((fun (car args))
	  (args (cdr args)))
      (out 0 #\@ op #\space fun)
      (let loop ((args args))
	(cond ((null? args))
	      ((symbol? args)
	       (loop (symbol->string args)))
	      ((string? args)
	       (out CONTLINE " "
		    (let ((n (- (string-length args) 1)))
		      (if (eqv? #\s (string-ref args n))
			  (substring args 0 n)
			  args))
		    " @dots{}"))
	      ((pair? args)
	       (out CONTLINE " "
		    (if (or (eq? '... (car args))
			    (equal? "..." (car args)))
			"@dots{}"
			(car args)))
	       (loop (cdr args)))
	      (else (slib:error 'schmooz-fun args))))))
  (let* ((mac-list (scheme-args->macros args))
	 (ops (case defop
		((DEFINE-SYNTAX) '("defspec" "defspecx" "defspec"))
		((DEFMACRO) '("defmac" "defmacx" "defmac"))
		(else
		 (if (and (symbol? (car args))
			  (char=? (string-ref
				   (symbol->string (car args))
				   (+ -1 (string-length (symbol->string
							 (car args)))))
				  #\!))
		     '("deffn {Procedure}" "deffnx {Procedure}" "deffn")
		     '("defun" "defunx" "defun"))))))
    (define in-body? #f)
    (out-header args (car ops))
    (let loop ((xdefs xdefs))
      (cond ((pair? xdefs)
	     (out-header (car xdefs) (cadr ops))
	     (loop (cdr xdefs)))))
    (for-each (lambda (subl)
		;;(print 'in-body? in-body? 'subl subl)
		(out 0 (car subl))
		(for-each (lambda (l)
			    (case (car l)
			      ((@dfn)
			       (out-cindex (cadr l)))
			      ((@args)
			       (cond
				(in-body?
				 (out 0 "@end " (caddr ops))
				 (set! in-body? #f)
				 (out-header (cons (car args) (cdr l))
					     (car ops)))
				(else
				 (out-header (cons (car args) (cdr l))
					     (cadr ops)))))))
			  (cdr subl))
		(if (not (equal? "" (car subl)))
		    (set! in-body? #t)))
	      (map (lambda (bl)
		     (substitute-macs bl mac-list))
		   body))
    (out 0 "@end " (caddr ops))
    (out 0)
    (out 0)))

(define (schmooz-var defop name body xdefs)
  (let* ((mac-list (scheme-args->macros name)))
    (out 0 "@defvar " name)
    (let loop ((xdefs xdefs))
      (cond ((pair? xdefs)
	     (out 0 "@defvarx " (car xdefs))
	     (loop (cdr xdefs)))))
    (for-each (lambda (subl)
		(out 0 (car subl))
		(for-each (lambda (l)
			    (case (car l)
			      ((@dfn) (out-cindex (cadr l)))
			      (else
			       (report "bad macro" l))))
			  (cdr subl)))
	      (map (lambda (bl) (substitute-macs bl mac-list)) body))
    (out 0 "@end defvar")
    (out 0)))

(define (schmooz:read-word port)
  (do ((chr (peek-char port) (peek-char port)))
      ((not (and (char? chr) (char-whitespace? chr))))
    (read-char port))
  (do ((chr (peek-char port) (peek-char port))
       (str "" (string-append str (string chr))))
      ((not (and (char? chr) (not (char-whitespace? chr)))) str)
    (read-char port)))

(define (pathname->local-filename path)
  (define vic (pathname->vicinity path))
  (define plen (string-length path))
  (let ((vlen (string-length vic)))
    (if (and (substring? vic path)
	     (< vlen plen))
	(in-vicinity (user-vicinity) (substring path vlen plen))
	(slib:error 'pathname->local-filename path))))

;;;@ SCHMOOZ files.
(define schmooz
  (let* ((scheme-file? (filename:match-ci?? "*??scm"))
	 (txi-file? (filename:match-ci?? "*??txi"))
	 (texi-file? (let ((tex? (filename:match-ci?? "*??tex"))
			   (texi? (filename:match-ci?? "*??texi")))
		       (lambda (filename) (or (txi-file? filename)
					      (tex? filename)
					      (texi? filename)))))
	 (txi->scm (filename:substitute?? "*txi" "*scm"))
	 (scm->txi (filename:substitute?? "*scm" "*txi")))
    (define (schmooz-texi-file file)
      (call-with-input-file file
	(lambda (port)
	  (do ((pos (find-string-from-port? "@include" port)
		    (find-string-from-port? "@include" port)))
	      ((not pos))
	    (let ((fname (schmooz:read-word port)))
	      (cond ((equal? "" fname))
		    ((not (txi-file? fname)))
		    ((not (file-exists? (txi->scm fname))))
		    (else (schmooz (txi->scm fname)))))))))
    (define (schmooz-scm-file file txi-name)
      (display "Schmoozing ") (write file)
      (display " -> ") (write txi-name) (newline)
      (fluid-let ((*scheme-source* (open-input-file file))
		  (*scheme-source-name* file)
		  (*derived-txi* (open-output-file txi-name))
		  (*derived-txi-name* txi-name))
	(set! *output-line* 1)
	(cond ((scheme-file? file))
	      (else (find-string-from-port? ";" *scheme-source* #\;)
		    (read-line *scheme-source*)))
	(schmooz-tops schmooz-top)
	(close-input-port *scheme-source*)
	(close-output-port *derived-txi*)))
    (lambda files
      (for-each (lambda (file)
		  (define sl (string-length file))
		  (cond ((texi-file? file) (schmooz-texi-file file))
			((scheme-file? file)
			 (schmooz-scm-file
			  file (pathname->local-filename (scm->txi file))))
			(else (schmooz-scm-file
			       file
			       (pathname->local-filename
				(string-append file ".txi"))))))
		files))))

;;; SCHMOOZ-TOPS - schmooz top level forms.
(define schmooz-tops
  (let ((semispaces (cons slib:tab '(#\space #\;))))
    (lambda (schmooz-top)
      (let ((doc-lines '())
	    (doc-args #f))
	(define (skip-ws line istrt)
	  (do ((i istrt (+ i 1)))
	      ((or (>= i (string-length line))
		   (not (memv (string-ref line i) semispaces)))
	       (substring line i (string-length line)))))

	(define (tok1 line)
	  (let loop ((i 0))
	    (cond ((>= i (string-length line)) line)
		  ((or (char-whitespace? (string-ref line i))
		       (memv (string-ref line i) '(#\; #\( #\{)))
		   (substring line 0 i))
		  (else (loop (+ i 1))))))

	(define (read-cmt-line)
	  (cond ((eqv? #\; (peek-char *scheme-source*))
		 (read-char *scheme-source*)
		 (read-cmt-line))
		(else (read-line *scheme-source*))))

	(define (read-meta-cmt)
	  (let skip ((metarg? #f))
	    (let ((c (read-char *scheme-source*)))
	      (case c
		((#\newline) (if metarg? (skip #t)))
		((#\\) (skip #t))
		((#\!) (cond ((eqv? #\# (peek-char *scheme-source*))
			      (read-char *scheme-source*)
			      (if #f #f))
			     (else
			      (skip metarg?))))
		(else
		 (if (char? c) (skip metarg?) c))))))

	(define (lp c)
	  (cond ((eof-object? c)
		 (cond ((pair? doc-lines)
			(report "No definition found for @body doc lines"
				(reverse doc-lines)))))
		((eqv? c #\newline)
		 (read-char *scheme-source*)
		 (set! *output-line* (+ 1 *output-line*))
		 ;;(newline *derived-txi*)
		 (lp (peek-char *scheme-source*)))
		((char-whitespace? c)
		 (write-char (read-char *scheme-source*) *derived-txi*)
		 (lp (peek-char *scheme-source*)))
		((char=? c #\;)
		 (c-cmt c))
		((char=? c #\#)
		 (read-char *scheme-source*)
		 (if (eqv? #\! (peek-char *scheme-source*))
		     (read-meta-cmt)
		     (report "misread sharp object" (peek-char *scheme-source*)))
		 (lp (peek-char *scheme-source*)))
		(else
		 (sx))))

	(define (sx)
	  (let* ((s1 (read *scheme-source*))
		 ;;Read all forms separated only by single newlines
		 ;;and trailing whitespace.
		 (ss (let recur ()
		       (let ((c (peek-char *scheme-source*)))
			 (cond ((eof-object? c) '())
			       ((eqv? c #\newline)
				(read-char *scheme-source*)
				(if (eqv? #\( (peek-char *scheme-source*))
				    (let ((s (read *scheme-source*)))
				      (cons s (recur)))
				    '()))
			       ((char-whitespace? c)
				(read-char *scheme-source*)
				(recur))
			       (else '()))))))
	    (cond ((eof-object? s1))
		  (else
		   (schmooz-top s1 ss (reverse doc-lines) doc-args)
		   (set! doc-lines '())
		   (set! doc-args #f)
		   (lp (peek-char *scheme-source*))))))

	(define (out-cmt line)
	  (let ((subl (substitute-macs line '())))
	    (display (car subl) *derived-txi*)
	    (for-each
	     (lambda (l)
	       (case (car l)
		 ((@dfn)
		  (out-cindex (cadr l)))
		 (else
		  (report "bad macro" line))))
	     (cdr subl))
	    (newline *derived-txi*)))

	;;Comments not transcribed to generated Texinfo files.
	(define (c-cmt c)
	  (cond ((eof-object? c) (lp c))
		((eqv? #\; c)
		 (read-char *scheme-source*)
		 (c-cmt (peek-char *scheme-source*)))
		;; Escape to start Texinfo comments
		((eqv? #\@ c)
		 (let* ((line (read-line *scheme-source*))
			(tok (tok1 line)))
		   (cond ((or (string=? tok "@body")
			      (string=? tok "@text"))
			  (set! doc-lines
				(cons (skip-ws line (string-length tok))
				      doc-lines))
			  (body-cmt (peek-char *scheme-source*)))
			 ((string=? tok "@args")
			  (let ((args
				 (parse-args line (string-length tok))))
			    (set! doc-args (cdr args))
			    (set! doc-lines
				  (cons (skip-ws line (car args))
					doc-lines)))
			  (body-cmt (peek-char *scheme-source*)))
			 (else
			  (out-cmt (if (string=? tok "@")
				       (skip-ws line 1)
				       line))
			  (doc-cmt (peek-char *scheme-source*))))))
		;; Transcribe the comment line to C source file.
		(else
		 (read-line *scheme-source*)
		 (lp (peek-char *scheme-source*)))))

	;;Comments incorporated in generated Texinfo files.
	;;Continue adding lines to DOC-LINES until a non-comment
	;;line is reached (may be a blank line).
	(define (body-cmt c)
	  (cond ((eof-object? c) (lp c))
		((eqv? #\; c)
		 (set! doc-lines (cons (read-cmt-line) doc-lines))
		 (body-cmt (peek-char *scheme-source*)))
		((eqv? c #\newline)
		 (read-char *scheme-source*)
		 (lp (peek-char *scheme-source*)))
		;; Allow whitespace before ; in doc comments.
		((char-whitespace? c)
		 (read-char *scheme-source*)
		 (body-cmt (peek-char *scheme-source*)))
		(else
		 (lp (peek-char *scheme-source*)))))

	;;Comments incorporated in generated Texinfo files.
	;;Transcribe comments to current position in Texinfo file
	;;until a non-comment line is reached (may be a blank line).
	(define (doc-cmt c)
	  (cond ((eof-object? c) (lp c))
		((eqv? #\; c)
		 (out-cmt (read-cmt-line))
		 (doc-cmt (peek-char *scheme-source*)))
		((eqv? c #\newline)
		 (read-char *scheme-source*)
		 (newline *derived-txi*)
		 (lp (peek-char *scheme-source*)))
		;; Allow whitespace before ; in doc comments.
		((char-whitespace? c)
		 (read-char *scheme-source*)
		 (doc-cmt (peek-char *scheme-source*)))
		(else
		 (newline *derived-txi*)
		 (lp (peek-char *scheme-source*)))))
	(lp (peek-char *scheme-source*))))))

(define (schmooz-top-doc-begin def1 defs doc proc-args)
  (let ((op1 (sexp-def def1)))
    (cond
     ((not op1)
      (or (null? doc)
	  (report "SCHMOOZ: no definition found for Texinfo documentation"
		  doc (car defs))))
     (else
      (let* ((args (def->args def1))
	     (args (if proc-args
		       (cons (if args (car args) (def->var-name def1))
			     proc-args)
		       args)))
	(let loop ((ss defs)
		   (smatch (list (or args (def->var-name def1)))))
	  (if (null? ss)
	      (let ((smatch (reverse smatch)))
		((if args schmooz-fun schmooz-var)
		    op1 (car smatch) doc (cdr smatch)))
	      (if (eq? op1 (sexp-def (car ss)))
		  (let ((a (def->args (car ss))))
		    (loop (cdr ss)
			  (if args
			      (if a
				  (cons a smatch)
				  smatch)
			      (if a
				  smatch
				  (cons (def->var-name (car ss))
					smatch)))))))))))))

;;; SCHMOOZ-TOP - schmooz top level form sexp1 ...
(define (schmooz-top sexp1 sexps doc proc-args)
  (cond ((not (pair? sexp1)))
	((pair? sexps)
	 (if (pair? doc)
	     (schmooz-top-doc-begin sexp1 sexps doc proc-args))
	 (set! doc '()))
	(else
	 (case (car sexp1)
	   ((LOAD REQUIRE)		;If you redefine load, you lose
	    #f)
	   ((BEGIN)
	    (schmooz-top (cadr sexp1) '() doc proc-args)
	    (set! doc '())
	    (for-each (lambda (s)
			(schmooz-top s '() doc #f))
		      (cddr sexp1)))
	   ((DEFVAR DEFINE DEFCONST DEFINE-SYNTAX DEFMACRO)
	    (let* ((args (def->args sexp1))
		   (args (if proc-args
			     (cons (if args (car args) (cadr sexp1))
				   proc-args)
			     args)))
	      (cond (args
		     (set! *procedure* (car args))
		     (cond ((pair? doc)
			    (schmooz-fun (car sexp1) args doc '())
			    (set! doc '()))))
		    (else
		     (cond ((pair? doc)
			    (schmooz-var (car sexp1) (cadr sexp1) doc '())
			    (set! doc '()))))))))))
  (or (null? doc)
      (report
       "SCHMOOZ: no definition found for Texinfo documentation"
       doc sexp1))
  (set! *procedure* #f))
