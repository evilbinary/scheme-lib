;;; "uri.scm" Construct and decode Uniform Resource Identifiers. -*-scheme-*-
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

(require 'scanf)
(require 'printf)
(require 'coerce)
(require 'string-case)
(require 'string-search)
(require 'common-list-functions)
(require-if 'compiling 'directory)	; path->uri uses current-directory

;;@code{(require 'uri)}
;;@ftindex uri
;;
;;@noindent Implements @dfn{Uniform Resource Identifiers} (URI) as
;;described in RFC 2396.

;;@args
;;@args fragment
;;@args query fragment
;;@args path query fragment
;;@args authority path query fragment
;;@args scheme authority path query fragment
;;
;;Returns a Uniform Resource Identifier string from component arguments.
(define (make-uri . args)
  (define nargs (length args))
  (set! args (reverse args))
  (let ((fragment  (if (>= nargs 1) (car args) #f))
	(query     (if (>= nargs 2) (cadr args) #f))
	(path      (if (>= nargs 3) (caddr args) #f))
	(authority (if (>= nargs 4) (cadddr args) #f))
	(scheme    (if (>= nargs 5) (list-ref args 4) #f)))
    (string-append
     (if scheme (sprintf #f "%s:" scheme) "")
     (cond ((string? authority)
	    (sprintf #f "//%s" (uric:encode authority "$,;:@&=+")))
	   ((list? authority)
	    (apply (lambda (userinfo host port)
		     (cond ((and userinfo port)
			    (sprintf #f "//%s@%s:%d"
				     (uric:encode userinfo "$,;:&=+")
				     host port))
			   (userinfo
			    (sprintf #f "//%s@%s"
				     (uric:encode userinfo "$,;:&=+")
				     host))
			   (port
			    (sprintf #f "//%s:%d" host port))
			   (else host)))
		   authority))
	   (else (or authority "")))
     (cond ((string? path) (uric:encode path "/$,;:@&=+"))
	   ((null? path) "")
	   ((list? path) (uri:make-path path))
	   (else (or path "")))
     (if query (sprintf #f "?%s" (uric:encode query "?/$,;:@&=+")) "")
     (if fragment (sprintf #f "#%s" (uric:encode fragment "?/$,;:@&=+")) ""))))

;;@body
;;Returns a URI string combining the components of list @1.
(define (uri:make-path path)
  (apply string-append
	 (cons
	  (uric:encode (car path) "$,;:@&=+")
	  (map (lambda (pth) (string-append "/" (uric:encode pth "$,;:@&=+")))
	       (cdr path)))))

;;@body Returns a string which defines this location in the (HTML) file
;;as @1.  The hypertext @samp{<A HREF="#@1">} will link to this point.
;;
;;@example
;;(html:anchor "(section 7)")
;;@result{}
;;"<A NAME=\"(section%207)\"></A>"
;;@end example
(define (html:anchor name)
  (sprintf #f "<A NAME=\"%s\"></A>" (uric:encode name "#?/:@;=")))

;;@body Returns a string which links the @2 text to @1.
;;
;;@example
;;(html:link (make-uri "(section 7)") "section 7")
;;@result{}
;;"<A HREF=\"#(section%207)\">section 7</A>"
;;@end example
(define (html:link uri highlighted)
  (sprintf #f "<A HREF=\"%s\">%s</A>" uri highlighted))

;;@body Returns a string specifying the @dfn{base} @1 of a document, for
;;inclusion in the HEAD of the document (@pxref{HTML, head}).
(define (html:base uri)
  (sprintf #f "<BASE HREF=\"%s\">" uri))

;;@body Returns a string specifying the search @1 of a document, for
;;inclusion in the HEAD of the document (@pxref{HTML, head}).
(define (html:isindex prompt)
  (sprintf #f "<ISINDEX PROMPT=\"%s\">" prompt))

(define (uri:scheme? str)
  (let ((lst (scanf-read-list "%[-+.a-zA-Z0-9] %s" str)))
    (and (list? lst)
	 (eqv? 1 (length lst))
	 (char-alphabetic? (string-ref str 0)))))

;;@args uri-reference base-tree
;;@args uri-reference
;;
;;Returns a list of 5 elements corresponding to the parts
;;(@var{scheme} @var{authority} @var{path} @var{query} @var{fragment})
;;of string @1.  Elements corresponding to absent parts are #f.
;;
;;The @var{path} is a list of strings.  If the first string is empty,
;;then the path is absolute; otherwise relative.  The optional @2 is a
;;tree as returned by @0; and is used as the base address for relative
;;URIs.
;;
;;If the @var{authority} component is a
;;@dfn{Server-based Naming Authority}, then it is a list of the
;;@var{userinfo}, @var{host}, and @var{port} strings (or #f).  For other
;;types of @var{authority} components the @var{authority} will be a
;;string.
;;
;;@example
;;(uri->tree "http://www.ics.uci.edu/pub/ietf/uri/#Related")
;;@result{}
;;(http "www.ics.uci.edu" ("" "pub" "ietf" "uri" "") #f "Related")
;;@end example
(define (uri->tree uri-reference . base-tree)
  (define split (uri:split uri-reference))
  (apply (lambda (b-scheme b-authority b-path b-query b-fragment)
	   (apply
	    (lambda (scheme authority path query fragment)
	      (define uri-empty?
		(and (equal? "" path) (not scheme) (not authority) (not query)))
	      (list (if (and scheme (uri:scheme? scheme))
			(string-ci->symbol scheme)
			(cond ((not scheme) b-scheme)
			      (else (slib:warn 'uri->tree 'bad 'scheme scheme)
				    b-scheme)))
		    (if authority
			(uri:decode-authority authority)
			b-authority)
		    (if uri-empty?
			(or b-path '(""))
			(uri:decode-path
			 (map uric:decode (uri:split-fields path #\/))
			 (and (not authority) (not scheme) b-path)))
		    (if uri-empty?
			b-query
			query)
		    (or (and fragment (uric:decode fragment))
			(and uri-empty? b-fragment))))
	    split))
	 (if (or (car split) (null? base-tree))
	     '(#f #f #f #f #f)
	     (car base-tree))))

(define (uri:decode-path path-list base-path)
  (cond ((and (equal? "" (car path-list))
	      (not (equal? '("") path-list)))
	 path-list)
	(base-path
	 (let* ((cpath0 (append (butlast base-path 1) path-list))
		(cpath1
		 (let remove ((l cpath0) (result '()))
		   (cond ((null? l) (reverse result))
			 ((not (equal? "." (car l)))
			  (remove (cdr l) (cons (car l) result)))
			 ((null? (cdr l))
			  (reverse (cons "" result)))
			 (else (remove (cdr l) result)))))
		(cpath2
		 (let remove ((l cpath1) (result '()))
		   (cond ((null? l) (reverse result))
			 ((not (equal? ".." (car l)))
			  (remove (cdr l) (cons (car l) result)))
			 ((or (null? result)
			      (equal? "" (car result)))
			  (slib:warn 'uri:decode-path cpath1)
			  (append (reverse result) l))
			 ((null? (cdr l))
			  (reverse (cons "" (cdr result))))
			 (else (remove (cdr l) (cdr result)))))))
	   cpath2))
	(else path-list)))

(define (uri:decode-authority authority)
  (define idx-at (string-index authority #\@))
  (let* ((userinfo (and idx-at (uric:decode (substring authority 0 idx-at))))
	 (hostport
	  (if idx-at
	      (substring authority (+ 1 idx-at) (string-length authority))
	      authority))
	 (cdx (string-index hostport #\:))
	 (host (if cdx (substring hostport 0 cdx) hostport))
	 (port (and cdx
		    (substring hostport (+ 1 cdx) (string-length hostport)))))
    (if (or userinfo port)
	(list userinfo host (or (string->number port) port))
	host)))
;;@args txt chr
;;Returns a list of @1 split at each occurrence of @2.  @2 does not
;;appear in the returned list of strings.
(define uri:split-fields
  (let ((cr (integer->char #xd)))
    (lambda (txt chr)
      (define idx (string-index txt chr))
      (if idx
	  (cons (substring txt 0
			   (if (and (positive? idx)
				    (char=? cr (string-ref txt (+ -1 idx))))
			       (+ -1 idx)
			       idx))
		(uri:split-fields (substring txt (+ 1 idx) (string-length txt))
				  chr))
	  (list txt)))))

;;@body Converts a @dfn{URI} encoded @1 to a query-alist.
(define (uri:decode-query query-string)
  (set! query-string (string-subst query-string " " "" "+" " "))
  (do ((lst '())
       (edx (string-index query-string #\=)
	    (string-index query-string #\=)))
      ((not edx) lst)
    (let* ((rxt (substring query-string (+ 1 edx) (string-length query-string)))
	   (adx (string-index rxt #\&))
	   (urid (uric:decode
		  (substring rxt 0 (or adx (string-length rxt)))))
	   (name (string-ci->symbol
		  (uric:decode (substring query-string 0 edx)))))
      (if (not (equal? "" urid))
	  (set! lst (cons (list name urid) lst))
	  ;; (set! lst (append lst (map (lambda (value) (list name value))
	  ;; 			     (uri:split-fields urid #\newline))))
	  )
      (set! query-string
	    (if adx (substring rxt (+ 1 adx) (string-length rxt)) "")))))

(define (uri:split uri-reference)
  (define len (string-length uri-reference))
  (define idx-sharp (string-index uri-reference #\#))
  (let ((fragment (and idx-sharp
		       (substring uri-reference (+ 1 idx-sharp) len)))
	(uri (if idx-sharp
		 (and (not (zero? idx-sharp))
		      (substring uri-reference 0 idx-sharp))
		 uri-reference)))
    (if uri
	(let* ((len (string-length uri))
	       (idx-? (string-index uri #\?))
	       (query (and idx-? (substring uri (+ 1 idx-?) len)))
	       (front (if idx-?
			  (and (not (zero? idx-?)) (substring uri 0 idx-?))
			  uri)))
	  (if front
	      (let* ((len (string-length front))
		     (cdx (string-index front #\:))
		     (scheme (and cdx (substring front 0 cdx)))
		     (path (if cdx
			       (substring front (+ 1 cdx) len)
			       front)))
		(cond ((eqv? 0 (substring? "//" path))
		       (set! len (string-length path))
		       (set! path (substring path 2 len))
		       (set! len (+ -2 len))
		       (let* ((idx-/ (string-index path #\/))
			      (authority (substring path 0 (or idx-/ len)))
			      (path (if idx-/
					(substring path idx-/ len)
					"")))
			 (list scheme authority path query fragment)))
		      (else (list scheme #f path query fragment))))
	      (list #f #f "" query fragment)))
	(list #f #f "" #f fragment))))

;;@
;;@noindent @code{uric:} prefixes indicate procedures dealing with
;;URI-components.

;;@body Returns a copy of the string @1 in which all @dfn{unsafe} octets
;;(as defined in RFC 2396) have been @samp{%} @dfn{escaped}.
;;@code{uric:decode} decodes strings encoded by @0.
(define (uric:encode uri-component allows)
  (set! uri-component (sprintf #f "%a" uri-component))
  (apply string-append
	 (map (lambda (chr)
		(if (or (char-alphabetic? chr)
			(char-numeric? chr)
			(string-index "-_.!~*'()" chr)
			(string-index allows chr))
		    (string chr)
		    (let ((code (char->integer chr)))
		      (sprintf #f "%%%02x" code))))
	      (string->list uri-component))))

;;@body Returns a copy of the string @1 in which each @samp{%} escaped
;;characters in @1 is replaced with the character it encodes.  This
;;routine is useful for showing URI contents on error pages.
(define (uric:decode uri-component)
  (define len (string-length uri-component))
  (define (sub uri)
    (cond
     ((string-index uri #\%)
      => (lambda (idx)
	   (if (and (< (+ 2 idx) len)
		    (string->number (substring uri (+ 1 idx) (+ 2 idx)) 16)
		    (string->number (substring uri (+ 2 idx) (+ 3 idx)) 16))
	       (string-append
		(substring uri 0 idx)
		(string (integer->char
			 (string->number
			  (substring uri (+ 1 idx) (+ 3 idx))
			  16)))
		(sub (substring uri (+ 3 idx) (string-length uri)))))))
     (else uri)))
  (sub uri-component))

;;@body @1 is a path-list as returned by @code{uri:split-fields}.  @0
;;returns a list of items returned by @code{uri:decode-path}, coerced
;;to types @2.
(define (uri:path->keys path-list ptypes)
  (and (not (null? path-list))
       (not (equal? '("") path-list))
       (let ((path (uri:decode-path (map uric:decode path-list) #f)))
	 (and (= (length path) (length ptypes))
	      (map coerce path ptypes)))))

;;@subheading File-system Locators and Predicates

;;@body Returns a URI-string for @1 on the local host.
(define (path->uri path)
  (require 'directory)
  (if (absolute-path? path)
      (sprintf #f "file:%s" path)
      (sprintf #f "file:%s/%s" (current-directory) path)))

;;@body Returns #t if @1 is an absolute-URI as indicated by a
;;syntactically valid (per RFC 2396) @dfn{scheme}; otherwise returns
;;#f.
(define (absolute-uri? str)
  (let ((lst (scanf-read-list "%[-+.a-zA-Z0-9]:%s" str)))
    (and (list? lst)
	 (eqv? 2 (length lst))
	 (char-alphabetic? (string-ref str 0)))))

;;@body Returns #t if @1 is a fully specified pathname (does not
;;depend on the current working directory); otherwise returns #f.
(define (absolute-path? file-name)
  (and (string? file-name)
       (positive? (string-length file-name))
       (memv (string-ref file-name 0) '(#\\ #\/))))

;;@body Returns #t if changing directory to @1 would leave the current
;;directory unchanged; otherwise returns #f.
(define (null-directory? str)
  (member str '("" "." "./" ".\\")))

;;@body Returns #t if the string @1 contains characters used for
;;specifying glob patterns, namely @samp{*}, @samp{?}, or @samp{[}.
(define (glob-pattern? str)
  (let loop ((idx (+ -1 (string-length str))))
    (if (negative? idx)
	#f
	(case (string-ref str idx)
	  ((#\* #\[ #\?) #t)
	  (else (loop (+ -1 idx)))))))

;;@noindent
;;Before RFC 2396, the @dfn{File Transfer Protocol} (FTP) served a
;;similar purpose.

;;@body
;;Returns a list of the decoded FTP @1; or #f if indecipherable.  FTP
;;@dfn{Uniform Resource Locator}, @dfn{ange-ftp}, and @dfn{getit}
;;formats are handled.  The returned list has four elements which are
;;strings or #f:
;;
;;@enumerate 0
;;@item
;;username
;;@item
;;password
;;@item
;;remote-site
;;@item
;;remote-directory
;;@end enumerate
(define (parse-ftp-address uri)
  (let ((length? (lambda (len lst) (and (eqv? len (length lst)) lst))))
    (cond
     ((not uri) #f)
     ((length? 1 (scanf-read-list " ftp://%s %s" uri))
      => (lambda (host)
	   (let ((login #f) (path #f) (dross #f))
	     (sscanf (car host) "%[^/]/%[^@]%s" login path dross)
	     (and login
		  (append (cond
			   ((length? 2 (scanf-read-list "%[^@]@%[^@]%s" login))
			    => (lambda (userpass@hostport)
				 (append
				  (cond ((length? 2 (scanf-read-list
						     "%[^:]:%[^@/]%s"
						     (car userpass@hostport))))
					(else (list (car userpass@hostport) #f)))
				  (cdr userpass@hostport))))
			   (else (list "anonymous" #f login)))
			  (list path))))))
     (else
      (let ((user@site #f) (colon #f) (path #f) (dross #f))
	(case (sscanf uri " %[^:]%[:]%[^@] %s" user@site colon path dross)
	  ((2 3)
	   (let ((user #f) (site #f))
	     (cond ((or (eqv? 2 (sscanf user@site "/%[^@/]@%[^@]%s"
					user site dross))
			(eqv? 2 (sscanf user@site "%[^@/]@%[^@]%s"
					user site dross)))
		    (list user #f site path))
		   ((eqv? 1 (sscanf user@site "@%[^@]%s" site dross))
		    (list #f #f site path))
		   (else (list #f #f user@site path)))))
	  (else
	   (let ((site (scanf-read-list " %[^@/] %s" uri)))
	     (and (length? 1 site) (list #f #f (car site) #f))))))))))
