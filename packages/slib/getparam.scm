;;; "getparam.scm" convert getopt to passing parameters by name.
; Copyright 1995, 1996, 1997, 2001 Aubrey Jaffer
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

(require 'getopt)
(require 'coerce)
(require 'parameters)
(require 'multiarg-apply)
(require 'rev4-optional-procedures)	; string-copy
(require-if 'compiling 'printf)
(require-if 'compiling 'common-list-functions)

;;@code{(require 'getopt-parameters)}
;;@ftindex getopt-parameters

;;@args optnames arities types aliases desc @dots{}
;;Returns @var{*argv*} converted to a parameter-list.  @var{optnames} are
;;the parameter-names.  @var{arities} and @var{types} are lists of symbols
;;corresponding to @var{optnames}.
;;
;;@var{aliases} is a list of lists of strings or integers paired with
;;elements of @var{optnames}.  Each one-character string will be treated
;;as a single @samp{-} option by @code{getopt}.  Longer strings will be
;;treated as long-named options (@pxref{Getopt, getopt--}).
;;
;;If the @var{aliases} association list has only strings as its
;;@code{car}s, then all the option-arguments after an option (and before
;;the next option) are adjoined to that option.
;;
;;If the @var{aliases} association list has integers, then each (string)
;;option will take at most one option-argument.  Unoptioned arguments are
;;collected in a list.  A @samp{-1} alias will take the last argument in
;;this list; @samp{+1} will take the first argument in the list.  The
;;aliases -2 then +2; -3 then +3; @dots{} are tried so long as a positive
;;or negative consecutive alias is found and arguments remain in the list.
;;Finally a @samp{0} alias, if found, absorbs any remaining arguments.
;;
;;In all cases, if unclaimed arguments remain after processing, a warning
;;is signaled and #f is returned.
(define (getopt->parameter-list optnames arities types aliases . description)
  (define (can-take-arg? opt)
    (not (eq? 'boolean (list-ref arities (position opt optnames)))))
  (let ((progname (list-ref *argv* (+ -1 *optind*)))
	(optlist '())
	(long-opt-list '())
	(optstring #f)
	(pos-args '())
	(parameter-list (make-parameter-list optnames))
	(curopt '*unclaimed-argument*)
	(positional? (assv 0 aliases))
	(unclaimeds '()))
    (define (adjoin-val val curopt)
      (define ntyp (list-ref types (position curopt optnames)))
      (adjoin-parameters! parameter-list
			  (list curopt (case ntyp
					 ((expression) val)
					 (else (coerce val ntyp))))))
    (define (finish)
      (cond
       (positional?
	(set! unclaimeds (reverse unclaimeds))
	(do ((idx 2 (+ 1 idx))
	     (alias+ (assv 1 aliases) (assv idx aliases))
	     (alias- (assv -1 aliases) (assv (- idx) aliases)))
	    ((or (not (or alias+ alias-)) (null? unclaimeds)))
	  (set! unclaimeds (reverse unclaimeds))
	  (cond (alias-
		 (set! curopt (cadr alias-))
		 (adjoin-val (car unclaimeds) curopt)
		 (set! unclaimeds (cdr unclaimeds))))
	  (set! unclaimeds (reverse unclaimeds))
	  (cond ((and alias+ (not (null? unclaimeds)))
		 (set! curopt (cadr alias+))
		 (adjoin-val (car unclaimeds) curopt)
		 (set! unclaimeds (cdr unclaimeds)))))
	(let ((alias (assv '0 aliases)))
	  (cond (alias
		 (set! curopt (cadr alias))
		 (for-each (lambda (unc) (adjoin-val unc curopt)) unclaimeds)
		 (set! unclaimeds '()))))))
      (cond ((not (null? unclaimeds))
	     (getopt-barf "%s: Unclaimed argument '%s'"
			  progname (car unclaimeds))
	     (apply parameter-list->getopt-usage
		    progname optnames arities types aliases description))
	    (else parameter-list)))
    (set! aliases
	  (map (lambda (alias)
		 (cond ((string? (car alias))
			(let ((str (string-copy (car alias))))
			  (do ((i (+ -1 (string-length str)) (+ -1 i)))
			      ((negative? i) (cons str (cdr alias)))
			    (cond ((char=? #\space (string-ref str i))
				   (string-set! str i #\-))))))
		       ((number? (car alias))
			(set! positional? (car alias))
			alias)
		       (else alias)))
	       aliases))
    (for-each
     (lambda (alias)
       (define opt (car alias))
       (cond ((number? opt) (set! pos-args (cons opt pos-args)))
	     ((not (string? opt)))
	     ((< 1 (string-length opt))
	      (set! long-opt-list (cons opt long-opt-list)))
	     ((not (= 1 (string-length opt))))
	     ((can-take-arg? (cadr alias))
	      (set! optlist (cons (string-ref opt 0) (cons #\: optlist))))
	     (else (set! optlist (cons (string-ref opt 0) optlist)))))
     aliases)
    (set! optstring (list->string (cons #\: optlist)))
    (let loop ()
      (let ((opt (getopt-- optstring)))
	(case opt
	  ((#\: #\?)
	   (getopt-barf (case opt
			  ((#\:) "%s: argument missing after '-%c'")
			  ((#\?) "%s: unrecognized option '-%c'"))
			progname
			getopt:opt)
	   (apply parameter-list->getopt-usage
		  progname optnames arities types aliases description))
	  ((#f)
	   (cond ((and (< *optind* (length *argv*))
		       (string=? "-" (list-ref *argv* *optind*)))
		  (set! *optind* (+ 1 *optind*))
		  (finish))
		 ((< *optind* (length *argv*))
		  (let ((topt (assoc curopt aliases)))
		    (if topt (set! curopt (cadr topt)))
		    (cond
		     ((and positional? (not topt))
		      (set! unclaimeds
			    (cons (list-ref *argv* *optind*) unclaimeds))
		      (set! *optind* (+ 1 *optind*)) (loop))
		     ((and (member curopt optnames)
			   (adjoin-val (list-ref *argv* *optind*) curopt))
		      (set! *optind* (+ 1 *optind*)) (loop))
		     (else (slib:error 'getopt->parameter-list curopt
				       (list-ref *argv* *optind*)
				       'not 'supported)))))
		 (else (finish))))
	  (else
	   (cond ((char? opt) (set! opt (string opt))))
	   (let ((topt (assoc opt aliases)))
	     (if topt (set! topt (cadr topt)))
	     (cond
	      ((not topt)
	       (getopt-barf "%s: '--%s' option not recognized" progname opt)
	       (apply parameter-list->getopt-usage
		      progname optnames arities types aliases description))
	      ((not (can-take-arg? topt))
	       (adjoin-parameters! parameter-list (list topt #t))
	       (loop))
	      (*optarg* (set! curopt topt) (adjoin-val *optarg* curopt) (loop))
	      (else
	       ;;(getopt-barf "%s: '--%s' option expects '='" progname opt)
	       ;;(apply parameter-list->getopt-usage progname optnames arities types aliases description)
	       (set! curopt topt) (loop))))))))))

(define (getopt-barf . args)
  (require 'printf)
  (apply fprintf (current-error-port) args)
  (newline (current-error-port)))

(define (parameter-list->getopt-usage comname optnames arities types aliases
				      . description)
  (require 'printf)
  (require 'common-list-functions)
  (let ((aliast (map list optnames))
	(strlen=1? (lambda (s) (= 1 (string-length s))))
	(cep (current-error-port)))
    (for-each (lambda (alias)
		(let ((apr (assq (cadr alias) aliast)))
		  (set-cdr! apr (cons (car alias) (cdr apr)))))
	      aliases)
    (fprintf cep "Usage: %s [OPTION ARGUMENT ...] ..." comname)
    (do ((pos+ '()) (pos- '())
	 (idx 2 (+ 1 idx))
	 (alias+ (assv 1 aliases) (assv idx aliases))
	 (alias- (assv -1 aliases) (assv (- idx) aliases)))
	((not (or alias+ alias-))
	 (for-each (lambda (alias) (fprintf cep " <%s>" (cadr alias)))
		   (reverse pos+))
	 (let ((alias (assv 0 aliases)))
	   (if alias (fprintf cep " <%s> ..." (cadr alias))))
	 (for-each (lambda (alias) (fprintf cep " <%s>" (cadr alias)))
		   pos-))
      (cond (alias- (set! pos- (cons alias- pos-))))
      (cond (alias+ (set! pos+ (cons alias+ pos+)))))
    (fprintf cep "\\n\\n")
    (for-each
     (lambda (optname arity aliat)
       (let loop ((initials (remove-if-not strlen=1? (remove-if number? (cdr aliat))))
		  (longname (remove-if strlen=1? (remove-if number? (cdr aliat)))))
	 (cond ((and (null? initials) (null? longname)))
	       (else (fprintf cep
			      (case arity
				((boolean) "  %3s %s\\n")
				(else "  %3s %s<%s> %s\\n"))
			      (if (null? initials)
				  ""
				  (string-append "-" (car initials)
						 (if (null? longname) " " ",")))
			      (if (null? longname)
				  "      "
				  (string-append "--" (car longname)
						 (case arity
						   ((boolean) " ")
						   (else "="))))
			      (case arity
				((boolean) "")
				(else optname))
			      (case arity
				((nary nary1) "...")
				(else "")))
		     (loop (if (null? initials) '() (cdr initials))
			   (if (null? longname) '() (cdr longname)))))))
     optnames arities aliast)
    (for-each (lambda (desc) (fprintf cep "  %s\\n" desc)) description))
  #f)

;;@args optnames positions arities types defaulters checks aliases desc @dots{}
;;Like @code{getopt->parameter-list}, but converts @var{*argv*} to an
;;argument-list as specified by @var{optnames}, @var{positions},
;;@var{arities}, @var{types}, @var{defaulters}, @var{checks}, and
;;@var{aliases}.  If the options supplied violate the @var{arities} or
;;@var{checks} constraints, then a warning is signaled and #f is returned.
(define (getopt->arglist optnames positions
			 arities types defaulters checks aliases . description)
  (define progname (list-ref *argv* (+ -1 *optind*)))
  (let* ((params (apply getopt->parameter-list
			optnames arities types aliases description))
	 (fparams (and params (fill-empty-parameters defaulters params))))
    (cond ((and (list? params)
		(check-parameters checks fparams)
		(parameter-list->arglist positions arities fparams)))
	  (params (apply parameter-list->getopt-usage
			 progname optnames arities types aliases description))
	  (else #f))))

;;@noindent
;;These @code{getopt} functions can be used with SLIB relational
;;databases.  For an example, @xref{Using Databases, make-command-server}.
;;
;;@noindent
;;If errors are encountered while processing options, directions for using
;;the options (and argument strings @var{desc} @dots{}) are printed to
;;@code{current-error-port}.
;;
;;@example
;;(begin
;;  (set! *optind* 1)
;;  (set! *argv* '("cmd" "-?")
;;  (getopt->parameter-list
;;   '(flag number symbols symbols string flag2 flag3 num2 num3)
;;   '(boolean optional nary1 nary single boolean boolean nary nary)
;;   '(boolean integer symbol symbol string boolean boolean integer integer)
;;   '(("flag" flag)
;;     ("f" flag)
;;     ("Flag" flag2)
;;     ("B" flag3)
;;     ("optional" number)
;;     ("o" number)
;;     ("nary1" symbols)
;;     ("N" symbols)
;;     ("nary" symbols)
;;     ("n" symbols)
;;     ("single" string)
;;     ("s" string)
;;     ("a" num2)
;;     ("Abs" num3))))
;;@print{}
;;Usage: cmd [OPTION ARGUMENT ...] ...
;;
;;  -f, --flag
;;  -o, --optional=<number>
;;  -n, --nary=<symbols> ...
;;  -N, --nary1=<symbols> ...
;;  -s, --single=<string>
;;      --Flag
;;  -B
;;  -a        <num2> ...
;;      --Abs=<num3> ...
;;
;;ERROR: getopt->parameter-list "unrecognized option" "-?"
;;@end example
