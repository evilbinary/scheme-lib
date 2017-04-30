; "prec.scm", dynamically extensible parser/tokenizer	-*-scheme-*-
; Copyright 1989, 1990, 1991, 1992, 1993, 1995, 1997 Aubrey Jaffer
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

; This file implements:
; * a Pratt style parser.
; * a tokenizer which congeals tokens according to assigned classes of
;   constituent characters.
;
; This module is a significant improvement because grammar can be
; changed dynamically from rulesets which don't need compilation.
; Theoretically, all possibilities of bad input are handled and return
; as much structure as was parsed when the error occured; The symbol
; `?' is substituted for missing input.

; References for the parser are:

; Pratt, V. R.
; Top Down Operator Precendence.
; SIGACT/SIGPLAN
; Symposium on Principles of Programming Languages,
; Boston, 1973, 41-51

; WORKING PAPER 121
; CGOL - an Alternative External Representation For LISP users
; Vaughan R. Pratt
; MIT Artificial Intelligence Lab.
; March 1976

; Mathlab Group,
; MACSYMA Reference Manual, Version Ten,
; Laboratory for Computer Science, MIT, 1983

(require 'string-search)
(require 'string-port)
(require 'delay)
(require 'multiarg-apply)

;@
(define *syn-defs* #f)

(define (tok:peek-char dyn) (peek-char (cadr dyn)))
(define (tok:read-char dyn)
  (let ((c (read-char (cadr dyn))))
    (set-car! (cddddr dyn)
	      (if (or (eqv? c #\newline) (eof-object? c))
		  0
		  (+ 1 (car (cddddr dyn)))))
    c))

(define (prec:warn dyn . msgs)
  (do ((j (+ -1 (car (cddddr dyn))) (+ -8 j)))
      ((> 8 j)
       (do ((i j (+ -1 i)))
	   ((>= 0 i)
	    (display "^ ")
	    (newline)
	    (for-each (lambda (x) (write x) (display #\space)) msgs)
	    (newline))
	 (display #\space)))
    (display slib:tab)))

;; Structure of lexical records.
(define tok:make-rec cons)
(define tok:cc car)
(define tok:sfp cdr)

(define (tok:lookup alist char)
  (if (eof-object? char)
      #f
      (let ((pair (assv char alist)))
	(and pair (cdr pair)))))
;@
(define (tok:char-group group chars chars-proc)
  (map (lambda (token)
;;;      (let ((oldlexrec (tok:lookup *syn-defs* token)))
;;;	(cond ((or (not oldlexrec) (eqv? (tok:cc oldlexrec) group)))
;;;	      (else (math:warn 'cc-of token 'redefined-to- group))))
	 (cons token (tok:make-rec group chars-proc)))
       (cond ((string? chars) (string->list chars))
	     ((char? chars) (list chars))
	     (else chars))))

(define (tokenize dyn)
  (let* ((char (tok:read-char dyn))
	 (rec (tok:lookup (car dyn) char))
	 (proc (and rec (tok:cc rec)))
	 (clist (list char)))
    (cond
     ((not proc) char)
     ((procedure? proc)
      (do ((cl clist (begin (set-cdr! cl (list (tok:read-char dyn))) (cdr cl))))
	  ((proc (tok:peek-char dyn))
	   ((or (tok:sfp rec) (lambda (dyn l) (list->string l)))
	    dyn
	    clist))))
     ((eqv? 0 proc) (tokenize dyn))
     (else
      (do ((cl clist (begin (set-cdr! cl (list (tok:read-char dyn))) (cdr cl))))
	  ((not (let* ((prec (tok:lookup (car dyn) (tok:peek-char dyn)))
		       (cclass (and prec (tok:cc prec))))
		  (or (eqv? cclass proc)
		      (eqv? cclass (+ -1 proc)))))
	   ((tok:sfp rec) dyn clist)))))))

;;; PREC:NUD is the null denotation (function and arguments to call when no
;;;     unclaimed tokens).
;;; PREC:LED is the left denotation (function and arguments to call when
;;;     unclaimed token is on left).
;;; PREC:LBP is the left binding power of this LED.  It is the first
;;; argument position of PREC:LED

(define (prec:nudf alist self)
  (let ((pair (assoc (cons 'nud self) alist)))
    (and pair (cdr pair))))
(define (prec:ledf alist self)
  (let ((pair (assoc (cons 'led self) alist)))
    (and pair (cdr pair))))
(define (prec:lbp alist self)
  (let ((pair (assoc (cons 'led self) alist)))
    (and pair (cadr pair))))

(define (prec:call-or-list proc . args)
  (prec:apply-or-cons proc args))
(define (prec:apply-or-cons proc args)
  (if (procedure? proc) (apply proc args) (cons (or proc '?) args)))

;;; PREC:SYMBOLFY and PREC:DE-SYMBOLFY are not exact inverses.
(define (prec:symbolfy obj)
  (cond ((symbol? obj) obj)
	((string? obj) (string->symbol obj))
	((char? obj) (string->symbol (string obj)))
	(else obj)))

(define (prec:de-symbolfy obj)
  (cond ((symbol? obj) (symbol->string obj))
	(else obj)))

;;;Calls to set up tables.
;@
(define (prec:define-grammar . synlsts)
  (set! *syn-defs* (append (apply append synlsts) *syn-defs*)))
;@
(define (prec:make-led toks . args)
  (map (lambda (tok)
	 (cons (cons 'led (prec:de-symbolfy tok))
	       args))
       (if (pair? toks) toks (list toks))))
(define (prec:make-nud toks . args)
  (map (lambda (tok)
	 (cons (cons 'nud (prec:de-symbolfy tok))
	       args))
       (if (pair? toks) toks (list toks))))

;;; Produce dynamically augmented grammars.
(define prec:process-binds append)

;;(define (prec:replace-rules) some-sort-of-magic-cookie)

;;; Here are the procedures to define high-level grammar, along with
;;; utility functions called during parsing.  The utility functions
;;; (prec:parse-*) could be incorportated into the defining commands,
;;; but tracing these functions is useful for debugging.
;@
(define (prec:delim tk)
  (prec:make-led tk 0 #f))
;@
(define (prec:nofix tk sop . binds)
  (prec:make-nud tk prec:parse-nofix sop (apply append binds)))

(define (prec:parse-nofix dyn self sop binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:call-or-list (or sop (prec:symbolfy self)))))
;@
(define (prec:prefix tk sop bp . binds)
  (prec:make-nud tk prec:parse-prefix sop bp (apply append binds)))

(define (prec:parse-prefix dyn self sop bp binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:call-or-list (or sop (prec:symbolfy self)) (prec:parse1 dyn bp))))
;@
(define (prec:infix tk sop lbp bp . binds)
  (prec:make-led tk lbp prec:parse-infix sop bp (apply append binds)))

(define (prec:parse-infix dyn left self lbp sop bp binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:call-or-list (or sop (prec:symbolfy self)) left (prec:parse1 dyn bp))))
;@
(define (prec:nary tk sop bp)
  (prec:make-led tk bp prec:parse-nary sop bp))

(define (prec:parse-nary dyn left self lbp sop bp)
  (prec:apply-or-cons (or sop (prec:symbolfy self))
		      (cons left (prec:parse-list dyn self bp))))
;@
(define (prec:postfix tk sop lbp . binds)
  (prec:make-led tk lbp prec:parse-postfix sop (apply append binds)))

(define (prec:parse-postfix dyn left self lbp sop binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:call-or-list (or sop (prec:symbolfy self)) left)))
;@
(define (prec:prestfix tk sop bp . binds)
  (prec:make-nud tk prec:parse-rest sop bp (apply append binds)))

(define (prec:parse-rest dyn self sop bp binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:apply-or-cons (or sop (prec:symbolfy self)) (prec:parse-list dyn #f bp))))
;@
(define (prec:commentfix tk stp match . binds)
  (append
   (prec:make-nud tk prec:parse-nudcomment stp match (apply append binds))
   (prec:make-led tk 220 prec:parse-ledcomment stp match (apply append binds))))

(define (prec:parse-nudcomment dyn self stp match binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (tok:read-through-comment dyn stp match)
    (prec:advance dyn)
    (cond ((prec:delim? dyn (force (caddr dyn))) #f)
	  (else (prec:parse1 dyn (cadddr dyn))))))

(define (prec:parse-ledcomment dyn left lbp self stp match binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (tok:read-through-comment dyn stp match)
    (prec:advance dyn)
    left))

(define (tok:read-through-comment dyn stp match)
  (set! match (if (char? match)
		  (string match)
		  (prec:de-symbolfy match)))
  (cond ((procedure? stp)
	 (let* ((len #f)
		(str (call-with-output-string
			 (lambda (sp)
			   (set! len (find-string-from-port?
				      match (cadr dyn)
				      (lambda (c) (display c sp) #f)))))))
	   (stp (and len (substring str 0 (- len (string-length match)))))))
	(else (find-string-from-port? match (cadr dyn)))))
;@
(define (prec:matchfix tk sop sep match . binds)
  (define sep-lbp 0)
  (prec:make-nud tk prec:parse-matchfix
		 sop sep-lbp sep match
		 (apply append (prec:delim match) binds)))

(define (prec:parse-matchfix dyn self sop sep-lbp sep match binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (cond (sop (prec:apply-or-cons sop (prec:parse-delimited dyn sep sep-lbp match)))
	  ((equal? (force (caddr dyn)) match)
	   (prec:warn dyn 'expression-missing)
	   (prec:advance dyn)
	   '?)
	  (else (let ((ans (prec:parse1 dyn 0))) ;just parenthesized expression
		  (cond ((equal? (force (caddr dyn)) match)
			 (prec:advance dyn))
			((prec:delim? dyn (force (caddr dyn)))
			 (prec:warn dyn 'mismatched-delimiter (force (caddr dyn))
				    'not match)
			 (prec:advance dyn))
			(else (prec:warn dyn 'delimiter-expected--ignoring-rest
					 (force (caddr dyn)) 'expected match
					 'or-delimiter)
			      (do () ((prec:delim? dyn (force (caddr dyn))))
				(prec:parse1 dyn 0))))
		  ans)))))
;@
(define (prec:inmatchfix tk sop sep match lbp . binds)
  (define sep-lbp 0)
  (prec:make-led tk lbp prec:parse-inmatchfix
		 sop sep-lbp sep match
		 (apply append (prec:delim match) binds)))

(define (prec:parse-inmatchfix dyn left self lbp sop sep-lbp sep match binds)
  (let ((dyn (cons (prec:process-binds binds (car dyn)) (cdr dyn))))
    (prec:apply-or-cons sop (cons left (prec:parse-delimited dyn sep sep-lbp match)))))

;;;; Here is the code which actually parses.

(define (prec:advance dyn)
  (set-car! (cddr dyn) (delay (tokenize dyn))))
(define (prec:advance-return-last dyn)
  (let ((last (and (caddr dyn) (force (caddr dyn)))))
    (prec:advance dyn)
    last))

(define (prec:nudcall dyn self)
  (let ((pob (prec:nudf (car dyn) self)))
    (cond
     (pob (let ((proc (car pob)))
	    (cond ((procedure? proc) (apply proc dyn self (cdr pob)))
		  (proc (cons proc (cdr pob)))
		  (else '?))))
     ((char? self) (prec:warn dyn 'extra-separator)
      (prec:advance dyn)
      (prec:nudcall dyn  (force (caddr dyn))))
     ((string? self) (string->symbol self))
     (else self))))

(define (prec:ledcall dyn left self)
  (let* ((pob (prec:ledf (car dyn) self)))
    (apply (cadr pob) dyn left self (cdr pob))))

;;; PREC:PARSE1 is the heart.
(define (prec:parse1 dyn bp)
  (do ((left (prec:nudcall dyn (prec:advance-return-last dyn))
	     (prec:ledcall dyn left (prec:advance-return-last dyn))))
      ((or (>= bp 200)		       ;to avoid unneccesary lookahead
	   (>= bp (or (prec:lbp (car dyn) (force (caddr dyn))) 0))
	   (not left))
       left)))

(define (prec:delim? dyn token)
  (or (eof-object? token) (<= (or (prec:lbp (car dyn) token) 220) 0)))

(define (prec:parse-list dyn sep bp)
  (cond ((prec:delim? dyn (force (caddr dyn)))
	 (prec:warn dyn 'expression-missing)
	 '(?))
	(else
	 (let ((f (prec:parse1 dyn bp)))
	   (cons f (cond ((equal? (force (caddr dyn)) sep)
			  (prec:advance dyn)
			  (cond ((equal? (force (caddr dyn)) sep)
				 (prec:warn dyn 'expression-missing)
				 (prec:advance dyn)
				 (cons '? (prec:parse-list dyn sep bp)))
				((prec:delim? dyn (force (caddr dyn)))
				 (prec:warn dyn 'expression-missing)
				 '(?))
				(else (prec:parse-list dyn sep bp))))
			 ((prec:delim? dyn (force (caddr dyn))) '())
			 ((not sep) (prec:parse-list dyn sep bp))
			 ((prec:delim? dyn sep) (prec:warn dyn 'separator-missing)
			  (prec:parse-list dyn sep bp))
			 (else '())))))))

(define (prec:parse-delimited dyn sep bp delim)
  (cond ((equal? (force (caddr dyn)) sep)
	 (prec:warn dyn 'expression-missing)
	 (prec:advance dyn)
	 (cons '? (prec:parse-delimited dyn sep bp delim)))
	((prec:delim? dyn (force (caddr dyn)))
	 (if (not (equal? (force (caddr dyn)) delim))
	     (prec:warn dyn 'mismatched-delimiter (force (caddr dyn))
			'expected delim))
	 (if (not sep) (prec:warn dyn 'expression-missing))
	 (prec:advance dyn)
	 (if sep '() '(?)))
	(else (let ((ans (prec:parse-list dyn sep bp)))
		(cond ((equal? (force (caddr dyn)) delim))
		      ((prec:delim? dyn (force (caddr dyn)))
		       (prec:warn dyn 'mismatched-delimiter (force (caddr dyn))
				  'expecting delim))
		      (else (prec:warn dyn 'delimiter-expected--ignoring-rest
				       (force (caddr dyn)) '...)
			    (do () ((prec:delim? dyn (force (caddr dyn))))
			      (prec:parse1 dyn bp))))
		(prec:advance dyn)
		ans))))
;@
(define (prec:parse grammar delim column . ports)
  (define port (if (null? ports) (current-input-port) (car ports)))
  (set! delim (prec:de-symbolfy delim))
  (let ((dyn (list (append (prec:delim delim) grammar)
		   port
		   #f
		   0
		   column)))
    (prec:advance dyn)		   ; setup prec:token with first token
    (cond ((eof-object? (force (caddr dyn))) (force (caddr dyn)))
	  ((equal? (force (caddr dyn)) delim) #f)
	  (else
	   (let ((ans (prec:parse1 dyn 0)))
	     (cond ((eof-object? (force (caddr dyn))))
		   ((equal? (force (caddr dyn)) delim))
		   (else (prec:warn dyn
				    'delimiter-expected--ignoring-rest
				    (force (caddr dyn)) 'not delim)
			 (do () ((or (equal? (force (caddr dyn)) delim)
				     (eof-object? (force (caddr dyn)))))
			   (prec:advance dyn))))
	     ans)))))
;@
(define tok:decimal-digits "0123456789")
(define tok:upper-case "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
(define tok:lower-case "abcdefghijklmnopqrstuvwxyz")
(define tok:whitespaces
  (do ((i (+ -1 (min 256 char-code-limit)) (+ -1 i))
       (ws "" (if (char-whitespace? (integer->char i))
		  (string-append ws (string (integer->char i)))
		  ws)))
      ((negative? i) ws)))

;;;;The parse tables.
;;; Definitions accumulate in top-level variable *SYN-DEFS*.
(set! *syn-defs* '())		       ;Make sure *SYN-DEFS* is empty.

;;; Ignore Whitespace characters.
(prec:define-grammar (tok:char-group 0 tok:whitespaces #f))

;;; On MS-DOS systems, <ctrl>-Z (26) needs to be ignored in order to
;;; avoid problems at end of files.
(case (software-type)
  ((ms-dos)
   (if (not (char-whitespace? (integer->char 26)))
       (prec:define-grammar (tok:char-group 0 (integer->char 26) #f))
       )))

;;;@ Save these convenient definitions.
(define *syn-ignore-whitespace* *syn-defs*)
(set! *syn-defs* '())

;;(begin (trace-all "prec.scm") (set! *qp-width* 333))
;;(pretty-print (grammar-read-tab (get-grammar 'standard)))
;;(prec:trace)
