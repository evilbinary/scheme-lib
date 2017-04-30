;;; "htmlform.scm" Generate HTML 2.0 forms. -*-scheme-*-
; Copyright 1997, 1998, 2000, 2001 Aubrey Jaffer
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

(require 'sort)
(require 'printf)
(require 'parameters)
(require 'object->string)
(require 'string-search)
(require 'databases)
(require 'multiarg-apply)
(require 'common-list-functions)

;;;;@code{(require 'html-form)}
;;@ftindex html-form

(define html:blank (string->symbol ""))

;;@body Returns a string with character substitutions appropriate to
;;send @1 as an @dfn{attribute-value}.
(define (html:atval txt)		; attribute-value
  (if (symbol? txt) (set! txt (symbol->string txt)))
  (if (number? txt)
      (number->string txt)
      (string-subst (if (string? txt) txt (object->string txt))
		    "&" "&amp;"
		    "\"" "&quot;"
		    "<" "&lt;"
		    ">" "&gt;")))

;;@body Returns a string with character substitutions appropriate to
;;send @1 as an @dfn{plain-text}.
(define (html:plain txt)		; plain-text `Data Characters'
  (cond ((eq? html:blank txt) "&nbsp;")
	(else
	 (if (symbol? txt) (set! txt (symbol->string txt)))
	 (if (number? txt)
	     (number->string txt)
	     (string-subst (if (string? txt) txt (object->string txt))
			   "&" "&amp;"
			   "<" "&lt;"
			   ">" "&gt;")))))

;;@body Returns a tag of meta-information suitable for passing as the
;;third argument to @code{html:head}.  The tag produced is @samp{<META
;;NAME="@1" CONTENT="@2">}.  The string or symbol @1 can be
;;@samp{author}, @samp{copyright}, @samp{keywords}, @samp{description},
;;@samp{date}, @samp{robots}, @dots{}.
(define (html:meta name content)
  (sprintf #f "\\n<META NAME=\"%s\" CONTENT=\"%s\">" name (html:atval content)))

;;@body Returns a tag of HTTP information suitable for passing as the
;;third argument to @code{html:head}.  The tag produced is @samp{<META
;;HTTP-EQUIV="@1" CONTENT="@2">}.  The string or symbol @1 can be
;;@samp{Expires}, @samp{PICS-Label}, @samp{Content-Type},
;;@samp{Refresh}, @dots{}.
(define (html:http-equiv name content)
  (sprintf #f "\\n<META HTTP-EQUIV=\"%s\" CONTENT=\"%s\">"
	   name (html:atval content)))

;;@args delay uri
;;@args delay
;;
;;Returns a tag suitable for passing as the third argument to
;;@code{html:head}.  If @2 argument is supplied, then @1 seconds after
;;displaying the page with this tag, Netscape or IE browsers will fetch
;;and display @2.  Otherwise, @1 seconds after displaying the page with
;;this tag, Netscape or IE browsers will fetch and redisplay this page.
(define (html:meta-refresh dly . uri)
  (if (null? uri)
      (sprintf #f "\\n<META HTTP-EQUIV=\"Refresh\" CONTENT=\"%d\">" dly)
      (sprintf #f "\\n<META HTTP-EQUIV=\"Refresh\" CONTENT=\"%d;URL=%s\">"
	       dly (car uri))))

;;@args title backlink tags ...
;;@args title backlink
;;@args title
;;
;;Returns header string for an HTML page named @1.  If @2 is a string,
;;it is used verbatim between the @samp{H1} tags; otherwise @1 is
;;used.  If string arguments @3 ... are supplied, then they are
;;included verbatim within the @t{<HEAD>} section.
(define (html:head title . args)
  (define backlink (if (null? args) #f (car args)))
  (if (not (null? args)) (set! args (cdr args)))
  (string-append
   (sprintf #f "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\\n")
   (sprintf #f "<HTML>\\n")
   (sprintf #f "%s"
	    (html:comment "HTML by evilbinary"
			  ""))
   (sprintf #f " <HEAD>\\n  <TITLE>%s</TITLE>\\n  %s\\n </HEAD>\\n"
	    (html:plain title) (apply string-append args))
   (if (and backlink (substring-ci? "<H1>" backlink))
       backlink
       (sprintf #f "<BODY><H1>%s</H1>\\n" (or backlink (html:plain title))))))

;;@body Returns HTML string to end a page.
(define (html:body . body)
  (apply string-append
	 (append body (list (sprintf #f "</BODY>\\n</HTML>\\n")))))

;;@body Returns the strings @1, @2 as @dfn{PRE}formmated plain text
;;(rendered in fixed-width font).  Newlines are inserted between @1,
;;@2.  HTML tags (@samp{<tag>}) within @2 will be visible verbatim.
(define (html:pre line1 . lines)
  (sprintf #f "<PRE>\\n%s%s</PRE>"
	   (html:plain line1)
	   (string-append
	    (apply string-append
		   (map (lambda (line) (sprintf #f "\\n%s" (html:plain line)))
			lines)))))

;;@body Returns the strings @1 as HTML comments.
(define (html:comment line1 . lines)
  (string-append
   (apply string-append
	  (if (substring? "--" line1)
	      (slib:error 'html:comment "line contains --" line1)
	      (sprintf #f "<!--%s--" line1))
	  (map (lambda (line)
		 (if (substring? "--" line)
		     (slib:error 'html:comment "line contains --" line)
		     (sprintf #f "\\n  --%s--" line)))
	       lines))
   (sprintf #f ">\\n")))

(define (html:strong-doc name doc)
  (set! name (if name (html:plain name) ""))
  (set! doc (if doc (html:plain doc) ""))
  (if (equal? "" doc)
      (if (equal? "" name)
	  ""
	  (sprintf #f "<STRONG>%s</STRONG>" (html:plain name)))
      (sprintf #f "<STRONG>%s</STRONG> (%s)"
	       (html:plain name) (html:plain doc))))

;;@section HTML Forms

;;@body The symbol @1 is either @code{get}, @code{head}, @code{post},
;;@code{put}, or @code{delete}.  The strings @3 form the body of the
;;form.  @0 returns the HTML @dfn{form}.
(define (html:form method action . body)
  (cond ((not (memq method '(get head post put delete)))
	 (slib:error 'html:form "method unknown:" method)))
  (string-append
   (apply string-append
	  (sprintf #f "<FORM METHOD=%#a ACTION=%#a>\\n"
		   (html:atval method) (html:atval action))
	  body)
   (sprintf #f "</FORM>\\n")))

;;@body Returns HTML string which will cause @1=@2 in form.
(define (html:hidden name value)
  (sprintf #f "<INPUT TYPE=HIDDEN NAME=%#a VALUE=%#a>"
	   (html:atval name) (html:atval value)))

;;@body Returns HTML string for check box.
(define (html:checkbox pname default)
  (sprintf #f "<INPUT TYPE=CHECKBOX NAME=%#a %s>"
	   (html:atval pname)
	   (if default "CHECKED" "")))

;;@body Returns HTML string for one-line text box.
(define (html:text pname default . size)
  (set! size (if (null? size) #f (car size)))
  (cond (default
	  (sprintf #f "<INPUT NAME=%#a SIZE=%d VALUE=%#a>"
		   (html:atval pname)
		   (or size
		       (max 5
			    (min 20 (string-length
				     (if (symbol? default)
					 (symbol->string default) default)))))
		   (html:atval default)))
	(size (sprintf #f "<INPUT NAME=%#a SIZE=%d>" (html:atval pname) size))
	(else (sprintf #f "<INPUT NAME=%#a>" (html:atval pname)))))

;;@body Returns HTML string for multi-line text box.
(define (html:text-area pname default-list)
  (set! default-list (map (lambda (d) (sprintf #f "%a" d)) default-list))
  (string-append
   (sprintf #f "<TEXTAREA NAME=%#a ROWS=%d COLS=%d>\\n"
	    (html:atval pname) (max 1 (length default-list))
	    (min 32 (apply max 5 (map string-length default-list))))
   (let* ((str (apply string-append
		      (map (lambda (line)
			     (sprintf #f "%s\\n" (html:plain line)))
			   default-list)))
	  (len (+ -1 (string-length str))))
     (if (positive? len) (substring str 0 len) str))
   (sprintf #f "</TEXTAREA>\\n")))

(define (html:s<? s1 s2)
  (if (and (number? s1) (number? s2))
      (< s1 s2)
      (string<? (if (symbol? s1) (symbol->string s1) s1)
		(if (symbol? s2) (symbol->string s2) s2))))

(define (by-car proc)
  (lambda (s1 s2) (proc (car s1) (car s2))))

;;@body Returns HTML string for pull-down menu selector.
(define (html:select pname arity default-list foreign-values)
  (set! foreign-values (sort foreign-values (by-car html:s<?)))
  (let ((value-list (map car foreign-values))
	(visibles (map cadr foreign-values)))
    (string-append
     (sprintf #f "<SELECT NAME=%#a SIZE=%d%s>\\n"
	      (html:atval pname)
	      (case arity
		((single optional) 1)
		((nary nary1) 5))
	      (case arity
		((nary nary1) " MULTIPLE")
		(else "")))
     (apply string-append
	    (map (lambda (value visible)
		   (sprintf #f "<OPTION VALUE=%#a%s>%s\\n"
			    (html:atval value)
			    (if (member value default-list) " SELECTED" "")
			    (html:plain visible)))
		 (case arity
		   ((optional nary) (cons html:blank value-list))
		   (else value-list))
		 (case arity
		   ((optional nary) (cons html:blank visibles))
		   (else visibles))))
     (sprintf #f "</SELECT>"))))

;;@body Returns HTML string for any-of selector.
(define (html:buttons pname arity default-list foreign-values)
  (set! foreign-values (sort foreign-values (by-car html:s<?)))
  (let ((value-list (map car foreign-values))
	(visibles (map cadr foreign-values)))
    (string-append
     (sprintf #f "<MENU>")
     (case arity
       ((single optional)
	(apply
	 string-append
	 (map (lambda (value visible)
		(sprintf #f
			 "<LI><INPUT TYPE=RADIO NAME=%#a VALUE=%#a%s> %s\\n"
			 (html:atval pname) (html:atval value)
			 (if (member value default-list) " CHECKED" "")
			 (html:plain visible)))
	      value-list
	      visibles)))
       ((nary nary1)
	(apply
	 string-append
	 (map (lambda (value visible)
		(sprintf #f
			 "<LI><INPUT TYPE=CHECKBOX NAME=%#a VALUE=%#a%s> %s\\n"
			 (html:atval pname) (html:atval value)
			 (if (member value default-list) " CHECKED" "")
			 (html:plain visible)))
	      value-list
	      visibles))))
     (sprintf #f "</MENU>"))))

;;@args submit-label command
;;@args submit-label
;;
;;The string or symbol @1 appears on the button which submits the form.
;;If the optional second argument @2 is given, then @code{*command*=@2}
;;and @code{*button*=@1} are set in the query.  Otherwise,
;;@code{*command*=@1} is set in the query.
(define (form:submit submit-label . command)
  (if (null? command)
      (sprintf #f "<INPUT TYPE=SUBMIT NAME=%#a VALUE=%#a>"
	       (html:atval '*command*)
	       (html:atval submit-label))
      (sprintf #f "%s<INPUT TYPE=SUBMIT NAME=%#a VALUE=%#a>"
	       (html:hidden '*command* (car command))
	       (html:atval '*button*)
	       (html:atval submit-label))))

;;@body The @2 appears on the button which submits the form.
(define (form:image submit-label image-src)
  (sprintf #f "<INPUT TYPE=IMAGE NAME=%#a SRC=%#a>"
	   (html:atval submit-label)
	   (html:atval image-src)))

;;@body Returns a string which generates a @dfn{reset} button.
(define (form:reset) "<INPUT TYPE=RESET>")

;;@body Returns a string which generates an INPUT element for the field
;;named @1.  The element appears in the created form with its
;;representation determined by its @2 and domain.  For domains which
;;are foreign-keys:
;;
;;@table @code
;;@item single
;;select menu
;;@item optional
;;select menu
;;@item nary
;;check boxes
;;@item nary1
;;check boxes
;;@end table
;;
;;If the foreign-key table has a field named @samp{visible-name}, then
;;the contents of that field are the names visible to the user for
;;those choices.  Otherwise, the foreign-key itself is visible.
;;
;;For other types of domains:
;;
;;@table @code
;;@item single
;;text area
;;@item optional
;;text area
;;@item boolean
;;check box
;;@item nary
;;text area
;;@item nary1
;;text area
;;@end table
(define (form:element pname arity default-list foreign-values)
  (define dflt (if (null? default-list) #f
		   (sprintf #f "%a" (car default-list))))
  ;;(print 'form:element pname arity default-list foreign-values)
  (case (length foreign-values)
    ((0) (case arity
	   ((boolean)
	    (html:checkbox pname dflt))
	   ((single optional)
	    (html:text pname (if (car default-list) dflt "")))
	   (else (html:text-area pname default-list))))
    ((1) (html:checkbox pname dflt))
    (else ((case arity
	     ((single optional) html:select)
	     (else html:buttons))
	   pname arity default-list foreign-values))))

;;@body
;;
;;Returns a HTML string for a form element embedded in a line of a
;;delimited list.  Apply map @0 to the list returned by
;;@code{command->p-specs}.
(define (form:delimited pname doc aliat arity default-list foreign-values)
  (define longname
    (remove-if (lambda (s) (= 1 (string-length s))) (cdr aliat)))
  (set! longname (if (null? longname) #f (car longname)))
  (if longname
      (sprintf #f "<DT>%s\\n<DD>%s\\n"
	       (html:strong-doc longname doc)
	       (form:element pname arity default-list foreign-values))
      ""))

;;@body Wraps its arguments with delimited-list (@samp{DL} command.
(define (html:delimited-list . rows)
  (apply string-append
	 "<DL>"
	 (append rows '("</DL>"))))

;;;used by command:make-editable-table in db2html.scm;
;;; and by command->p-specs in htmlform.scm.
;;@body Returns a list of the @samp{visible-name} or first fields of
;;table @1.
(define (get-foreign-choices tab)
  (define dlst ((tab 'get* 1)))
  (do ((dlst dlst (cdr dlst))
       (vlst (if (memq 'visible-name (tab 'column-names))
		 ((tab 'get* 'visible-name))
		 dlst)
	     (cdr vlst))
       (out '() (if (member (car dlst) (cdr dlst))
		    out
		    (cons (list (car dlst) (car vlst)) out))))
      ((null? dlst) out)))

;;@body
;;
;;The symbol @2 names a command table in the @1 relational database.
;;The symbol @3 names a key in @2.
;;
;;@0 returns a list of lists of @var{pname}, @var{doc}, @var{aliat},
;;@var{arity}, @var{default-list}, and @var{foreign-values}.  The
;;returned list has one element for each parameter of command @3.
;;
;;This example demonstrates how to create a HTML-form for the @samp{build}
;;command.
;;
;;@example
;;(require (in-vicinity (implementation-vicinity) "build.scm"))
;;(call-with-output-file "buildscm.html"
;;  (lambda (port)
;;    (display
;;     (string-append
;;      (html:head 'commands)
;;      (html:body
;;       (sprintf #f "<H2>%s:</H2><BLOCKQUOTE>%s</BLOCKQUOTE>\\n"
;;                (html:plain 'build)
;;                (html:plain ((comtab 'get 'documentation) 'build)))
;;       (html:form
;;        'post
;;        (or "http://localhost:8081/buildscm" "/cgi-bin/build.cgi")
;;        (apply html:delimited-list
;;               (apply map form:delimited
;;                      (command->p-specs build '*commands* 'build)))
;;        (form:submit 'build)
;;        (form:reset))))
;;     port)))
;;@end example
(define (command->p-specs rdb command-table command)
  (define rdb-open (rdb 'open-table))
  (define (row-refer idx) (lambda (row) (list-ref row idx)))
  (let ((comtab (rdb-open command-table #f))
	;;(domain->type ((rdb-open '*domains-data* #f) 'get 'type-id))
	(get-foreign-values
	 (let ((ftn ((rdb-open '*domains-data* #f) 'get 'foreign-table)))
	   (lambda (domain-name)
	     (define tab-name (ftn domain-name))
	     (if tab-name
		 (get-foreign-choices (rdb-open tab-name #f))
		 '())))))
    (define row-ref
      (let ((names (comtab 'column-names)))
	(lambda (row name) (list-ref row (position name names)))))
    (let* ((command:row ((comtab 'row:retrieve) command))
	   (parameter-table (rdb-open (row-ref command:row 'parameters) #f))
	   (pcnames (parameter-table 'column-names))
	   (param-rows (sort! ((parameter-table 'row:retrieve*))
			      (lambda (r1 r2) (< (car r1) (car r2))))))
      (let ((domains (map (row-refer (position 'domain pcnames)) param-rows))
	    (parameter-names (rdb-open (row-ref command:row 'parameter-names) #f))
	    (pnames (map (row-refer (position 'name pcnames)) param-rows)))
	(define foreign-values (map get-foreign-values domains))
	(define aliast (map list pnames))
	(for-each (lambda (alias)
		    (if (> (string-length (car alias)) 1)
			(let ((apr (assq (cadr alias) aliast)))
			  (set-cdr! apr (cons (car alias) (cdr apr))))))
		  (map list
		       ((parameter-names 'get* 'name))
		       (map (parameter-table 'get 'name)
			    ((parameter-names 'get* 'parameter-index)))))
	(list pnames
	      (map (row-refer (position 'documentation pcnames)) param-rows)
	      aliast
	      (map (row-refer (position 'arity pcnames)) param-rows)
	      ;;(map domain->type domains)
	      (map cdr			;(lambda (lst) (if (null? lst) lst (cdr lst)))
		   (fill-empty-parameters
		    (map slib:eval
			 (map (row-refer (position 'defaulter pcnames))
			      param-rows))
		    (make-parameter-list
		     (map (row-refer (position 'name pcnames)) param-rows))))
	      foreign-values)))))
