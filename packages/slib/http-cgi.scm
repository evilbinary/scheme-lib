;;; "http-cgi.scm" service HTTP or CGI requests. -*-scheme-*-
; Copyright 1997, 1998, 2000, 2001, 2003 Aubrey Jaffer
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

(require 'uri)
(require 'scanf)
(require 'printf)
(require 'coerce)
(require 'line-i/o)
(require 'html-form)
(require 'parameters)
(require 'string-case)
(require 'string-port)
(require 'string-search)
(require 'database-commands)
(require 'common-list-functions)	; position

;;@code{(require 'http)} or @code{(require 'cgi)}
;;@ftindex http
;;@ftindex cgi

(define http:crlf (string (integer->char 13) #\newline))
(define (http:read-header port)
  (define alist '())
  (do ((line (read-line port) (read-line port)))
      ((or (zero? (string-length line))
	   (and (= 1 (string-length line))
		(char-whitespace? (string-ref line 0)))
	   (eof-object? line))
       (if (and (= 1 (string-length line))
		(char-whitespace? (string-ref line 0)))
	   (set! http:crlf (string (string-ref line 0) #\newline)))
       (if (eof-object? line) line alist))
    (let ((len (string-length line))
	  (idx (string-index line #\:)))
      (if (char-whitespace? (string-ref line (+ -1 len)))
	  (set! len (+ -1 len)))
      (and idx (do ((idx2 (+ idx 1) (+ idx2 1)))
		   ((or (>= idx2 len)
			(not (char-whitespace? (string-ref line idx2))))
		    (set! alist
			  (cons
			   (cons (string-ci->symbol (substring line 0 idx))
				 (substring line idx2 len))
			   alist)))))
      ;;Else -- ignore malformed line
      ;;(else (slib:error 'http:read-header 'malformed-input line))
      )))

(define (http:read-query-string request-line header port)
  (case (car request-line)
    ((get head)
     (let* ((request-uri (cadr request-line))
	    (len (string-length request-uri)))
       (and (> len 3)
	    (string-index request-uri #\?)
	    (substring request-uri
		       (+ 1 (string-index request-uri #\?))
		       (if (eqv? #\/ (string-ref request-uri (+ -1 len)))
			   (+ -1 len)
			   len)))))
    ((post put delete)
     (let ((content-length (assq 'content-length header)))
       (and content-length
	    (set! content-length (string->number (cdr content-length))))
       (and content-length
	    (let ((str (make-string content-length #\space)))
	      (do ((idx 0 (+ idx 1)))
		  ((>= idx content-length)
		   (if (>= idx (string-length str)) str (substring str 0 idx)))
		(let ((chr (read-char port)))
		  (if (char? chr)
		      (string-set! str idx chr)
		      (set! content-length idx))))))))
    (else #f)))

(define (http:status-line status-code reason)
  (sprintf #f "HTTP/1.0 %d %s%s" status-code reason http:crlf))

;;@body Returns a string containing lines for each element of @1; the
;;@code{car} of which is followed by @samp{: }, then the @code{cdr}.
(define (http:header alist)
  (string-append
   (apply string-append
	  (map (lambda (pair)
		 (sprintf #f "%s: %s%s" (car pair) (cdr pair) http:crlf))
	       alist))
   http:crlf))

;;@body Returns the concatenation of strings @2 with the
;;@code{(http:header @1)} and the @samp{Content-Length} prepended.
(define (http:content alist . body)
  (define hunk (apply string-append body))
  (string-append (http:header
		  (cons (cons "Content-Length"
			      (number->string (string-length hunk)))
			alist))
		 hunk))

;;@body String appearing at the bottom of error pages.
(define *http:byline* #f)

;;@body @1 and @2 should be an integer and string as specified in
;;@cite{RFC 2068}.  The returned page (string) will show the @1 and @2
;;and any additional @3 @dots{}; with @var{*http:byline*} or SLIB's
;;default at the bottom.
(define (http:error-page status-code reason-phrase . html-strings)
  (define byline
    (or
     *http:byline*
     (sprintf
      #f
      "<A HREF=http://people.csail.mit.edu/jaffer/SLIB.html>SLIB</A> %s server"
      (if (getenv "SERVER_PROTOCOL") "CGI/1.0" "HTTP/1.0"))))
  (string-append (http:status-line status-code reason-phrase)
		 (http:content
		  '(("Content-Type" . "text/html"))
		  (html:head (sprintf #f "%d %s" status-code reason-phrase))
		  (apply html:body
			 (append html-strings
				 (list (sprintf #f "<HR>\\n%s\\n" byline)))))))

;;@body The string or symbol @1 is the page title.  @2 is a non-negative
;;integer.  The @4 @dots{} are typically used to explain to the user why
;;this page is being forwarded.
;;
;;@0 returns an HTML string for a page which automatically forwards to
;;@3 after @2 seconds.  The returned page (string) contains any @4
;;@dots{} followed by a manual link to @3, in case the browser does not
;;forward automatically.
(define (http:forwarding-page title dly uri . html-strings)
  (string-append
   (html:head title #f (html:meta-refresh dly uri))
   (apply html:body
	  (append html-strings
		  (list (sprintf #f "\\n\\n<HR>\\nReturn to %s.\\n"
				 (html:link uri title)))))))

;;@body reads the @dfn{URI} and @dfn{query-string} from @2.  If the
;;query is a valid @samp{"POST"} or @samp{"GET"} query, then @0 calls
;;@1 with three arguments, the @var{request-line}, @var{query-string},
;;and @var{header-alist}.  Otherwise, @0 calls @1 with the
;;@var{request-line}, #f, and @var{header-alist}.
;;
;;If @1 returns a string, it is sent to @3.  If @1 returns a list
;;whose first element is an integer, then an error page with the
;;status integer which is the first element of the list and strings
;;from the list.  If @1 returns a list whose first element isn't an
;;number, then an error page with the status code 500 and strings from
;;the list.  If @1 returns #f, then a @samp{Bad Request} (400) page is
;;sent to @3.
;;
;;Otherwise, @0 replies (to @3) with appropriate HTML describing the
;;problem.
(define (http:serve-query serve-proc input-port output-port)
  (let* ((request-line (http:read-request-line input-port))
	 (header (and request-line (http:read-header input-port)))
	 (query-string (and header (http:read-query-string
				    request-line header input-port))))
    (display (http:service serve-proc request-line query-string header)
	     output-port)))

(define (http:service serve-proc request-line query-string header)
  (cond ((not request-line) (http:error-page 400 "Bad Request."))
	((string? (car request-line))
	 (http:error-page 501 "Not Implemented" (html:plain request-line)))
	((not (memq (car request-line) '(get post)))
	 (http:error-page 405 "Method Not Allowed" (html:plain request-line)))
	((serve-proc request-line query-string header) =>
	 (lambda (reply)
	   (cond ((string? reply)
		  (string-append (http:status-line 200 "OK")
				 reply))
		 ((and (pair? reply) (list? reply))
		  (if (number? (car reply))
		      (apply http:error-page reply)
		      (apply http:error-page (cons 500 reply))))
		 (else (http:error-page 500 "Internal Server Error")))))
	((not query-string)
	 (http:error-page 400 "Bad Request" (html:plain request-line)))
	(else
	 (http:error-page 500 "Internal Server Error" (html:plain header)))))

;;@
;;
;;This example services HTTP queries from @var{port-number}:
;;@example
;;
;;(define socket (make-stream-socket AF_INET 0))
;;(and (socket:bind socket port-number) ; AF_INET INADDR_ANY
;;     (socket:listen socket 10)        ; Queue up to 10 requests.
;;     (dynamic-wind
;;         (lambda () #f)
;;         (lambda ()
;;           (do ((port (socket:accept socket) (socket:accept socket)))
;;               (#f)
;;             (let ((iport (duplicate-port port "r"))
;;                   (oport (duplicate-port port "w")))
;;               (http:serve-query build:serve iport oport)
;;               (close-port iport)
;;               (close-port oport))
;;             (close-port port)))
;;         (lambda () (close-port socket))))
;;@end example

(define (http:read-start-line port)
  (do ((line (read-line port) (read-line port)))
      ((or (not (equal? "" line)) (eof-object? line)) line)))

;; @body
;; Request lines are a list of three itmes:
;;
;; @enumerate 0
;;
;; @item Method
;;
;; A symbol (@code{options}, @code{get}, @code{head}, @code{post},
;; @code{put}, @code{delete}, @code{trace} @dots{}).
;;
;; @item Request-URI
;;
;; A string.  For direct HTTP, at the minimum it will be the string
;; @samp{"/"}.
;;
;; @item HTTP-Version
;;
;; A string.  For example, @samp{HTTP/1.0}.
;; @end enumerate
(define (http:read-request-line port)
  (let ((lst (scanf-read-list "%s %s %s %s" (http:read-start-line port))))
    (and (list? lst)
	 (= 3 (length lst))
	 (cons (string-ci->symbol (car lst)) (cdr lst)))))
(define (cgi:request-line)
  (define method (getenv "REQUEST_METHOD"))
  (and method
       (list (string-ci->symbol method)
	     (getenv "SCRIPT_NAME")
	     (getenv "SERVER_PROTOCOL"))))

(define (cgi:query-header)
  (define assqs '())
  (cond ((and (getenv "SERVER_NAME") (getenv "SERVER_PORT"))
	 (set! assqs (cons (cons 'host (string-append (getenv "SERVER_NAME")
						      ":"
						      (getenv "SERVER_PORT")))
			   assqs))))
  (for-each
   (lambda (envar)
     (define valstr (getenv envar))
     (if valstr (set! assqs
		      (cons (cons (string-ci->symbol
				   (string-subst envar "HTTP_" "" "_" "-"))
				  valstr)
			    assqs))))
   '(
     ;;"AUTH_TYPE"
     "CONTENT_LENGTH"
     "CONTENT_TYPE"
     "DOCUMENT_ROOT"
     "GATEWAY_INTERFACE"
     "HTTP_ACCEPT"
     "HTTP_ACCEPT_CHARSET"
     "HTTP_ACCEPT_ENCODING"
     "HTTP_ACCEPT_LANGUAGE"
     "HTTP_CONNECTION"
     "HTTP_HOST"
     ;;"HTTP_PRAGMA"
     "HTTP_REFERER"
     "HTTP_USER_AGENT"
     "PATH_INFO"
     "PATH_TRANSLATED"
     "QUERY_STRING"
     "REMOTE_ADDR"
     "REMOTE_HOST"
     ;;"REMOTE_IDENT"
     ;;"REMOTE_USER"
     "REQUEST_URI"
     "SCRIPT_FILENAME"
     "SCRIPT_NAME"
     ;;"SERVER_SIGNATURE"
     ;;"SERVER_SOFTWARE"
     ))
  assqs)

;; @body Reads the @dfn{query-string} from @code{(current-input-port)}.
;; @0 reads a @samp{"POST"} or @samp{"GET"} queries, depending on the
;; value of @code{(getenv "REQUEST_METHOD")}.
(define (cgi:read-query-string)
  (define request-method (getenv "REQUEST_METHOD"))
  (cond ((and request-method (string-ci=? "GET" request-method))
	 (getenv "QUERY_STRING"))
	((and request-method (string-ci=? "POST" request-method))
	 (let ((content-length (getenv "CONTENT_LENGTH")))
	   (and content-length
		(set! content-length (string->number content-length)))
	   (and content-length
		(let ((str (make-string content-length #\space)))
		  (do ((idx 0 (+ idx 1)))
		      ((>= idx content-length)
		       (if (>= idx (string-length str))
			   str
			   (substring str 0 idx)))
		    (let ((chr (read-char)))
		      (if (char? chr)
			  (string-set! str idx chr)
			  (set! content-length idx))))))))
	(else #f)))

;;@body reads the @dfn{URI} and @dfn{query-string} from
;;@code{(current-input-port)}.  If the query is a valid @samp{"POST"}
;;or @samp{"GET"} query, then @0 calls @1 with three arguments, the
;;@var{request-line}, @var{query-string}, and @var{header-alist}.
;;Otherwise, @0 calls @1 with the @var{request-line}, #f, and
;;@var{header-alist}.
;;
;;If @1 returns a string, it is sent to @code{(current-ouput-port)}.
;;If @1 returns a list whose first element is an integer, then an
;;error page with the status integer which is the first element of the
;;list and strings from the list.  If @1 returns a list whose first
;;element isn't an number, then an error page with the status code 500
;;and strings from the list.  If @1 returns #f, then a @samp{Bad
;;Request} (400) page is sent to @code{(current-ouput-port)}.
;;
;;Otherwise, @0 replies (to @code{(current-output-port)}) with
;;appropriate HTML describing the problem.
(define (cgi:serve-query serve-proc)
  (let* ((script-name (getenv "SCRIPT_NAME"))
	 (request-line (cgi:request-line))
	 (header (and request-line (cgi:query-header)))
	 (query-string (and header (cgi:read-query-string)))
	 (reply (http:service serve-proc request-line query-string header)))
    (display (if (and script-name
		      (not (eqv? 0 (substring? "nph-" script-name))))
		 ;; Eat http status line.
		 (substring reply (+ 2 (substring? http:crlf reply))
			    (string-length reply))
		 reply))))

(define (coerce->list str type)
  (call-with-input-string str
    (lambda (port)
      (case type
	((expression)
	 (slib:warn 'coerce->list 'unsafe 'read)
	 (do ((tok (read port) (read port))
	      (lst '() (cons tok lst)))
	     ((or (null? tok) (eof-object? tok)) lst)))
	((symbol)
	 (do ((tok (scanf-read-list " %s" port)
		   (scanf-read-list " %s" port))
	      (lst '() (cons (string-ci->symbol (car tok)) lst)))
	     ((or (null? tok) (eof-object? tok)) lst)))
	(else
	 (do ((tok (scanf-read-list " %s" port)
		   (scanf-read-list " %s" port))
	      (lst '() (cons (coerce (car tok) type) lst)))
	     ((or (null? tok) (eof-object? tok)) lst)))))))

(define (query-alist->parameter-list alist optnames arities types)
  (let ((parameter-list (make-parameter-list optnames)))
    (for-each
     (lambda (lst)
       (let* ((value (cadr lst))
	      (name (car lst))
	      (opt-pos (position name optnames)))
	 (cond ((not opt-pos)
		(slib:warn 'query-alist->parameter-list
			   'unknown 'parameter name))
	       ((eq? (list-ref arities opt-pos) 'boolean)
		(adjoin-parameters! parameter-list (list name #t)))
	       ((and (equal? value "")
		     (not (memq (list-ref types opt-pos) '(expression string))))
		(adjoin-parameters! parameter-list (list name #f)))
	       (value
		(adjoin-parameters!
		 parameter-list
		 (cons name
		       (case (list-ref arities opt-pos)
			 ((nary nary1)
			  (coerce->list value (list-ref types opt-pos)))
			 (else
			  (list (coerce value (list-ref types opt-pos)))))))))))
     (reverse alist))
    parameter-list))

;;@args rdb command-table
;;@args rdb command-table #t
;;
;;Returns a procedure of one argument.  When that procedure is called
;;with a @var{query-alist} (as returned by @code{uri:decode-query}, the
;;value of the @samp{*command*} association will be the command invoked
;;in @2.  If @samp{*command*} is not in the @var{query-alist} then the
;;value of @samp{*suggest*} is tried.  If neither name is in the
;;@var{query-alist}, then the literal value @samp{*default*} is tried in
;;@2.
;;
;;If optional third argument is non-false, then the command is called
;;with just the parameter-list; otherwise, command is called with the
;;arguments described in its table.
(define (make-query-alist-command-server rdb command-table . just-params?)
  (define comsrvcal (make-command-server rdb command-table))
  (set! just-params? (if (null? just-params?) #f (car just-params?)))
  (lambda (query-alist)
    (define comnam #f)
    (define find-command?
      (lambda (cname)
	(define tryp (and query-alist (parameter-list-ref query-alist cname)))
	(cond ((not tryp) #f)
	      (comnam
	       (set! query-alist (remove-parameter cname query-alist)))
	      (else
	       (set! query-alist (remove-parameter cname query-alist))
	       (set! comnam (string-ci->symbol (car tryp)))))))
    (find-command? '*command*)
    (find-command? '*suggest*)
    (find-command? '*button*)
    (cond ((not comnam) (set! comnam '*default*)))
    (cond
     (comnam
      (comsrvcal comnam
		 (lambda (comname comval options positions
				  arities types defaulters dirs aliases)
		   (let* ((params (query-alist->parameter-list
				   query-alist options arities types))
			  (fparams (fill-empty-parameters defaulters params)))
		     (and (list? fparams)
			  (check-parameters dirs fparams)
			  (if just-params?
			      (comval fparams)
			      (let ((arglist (parameter-list->arglist
					      positions arities fparams)))
				(and arglist
				     (apply comval arglist))))))))))))
