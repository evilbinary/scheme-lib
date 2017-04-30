;"db2html.scm" Convert relational database to hyperlinked pages.
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

(require 'uri)
(require 'printf)
(require 'html-form)
(require 'directory)
(require 'databases)
(require 'string-case)
(require 'string-search)
(require 'multiarg-apply)
(require 'common-list-functions)
(require-if 'compiling 'pretty-print)
(require-if 'compiling 'database-commands)
(require 'hash)
(define (crc:hash-obj obj) (number->string (hash obj most-positive-fixnum) 16))

;;@code{(require 'db->html)}
;;@ftindex db->html

;;@body
(define (html:table options . rows)
  (apply string-append
	 (sprintf #f "<TABLE %s>\\n" (or options ""))
	 (append rows (list (sprintf #f "</TABLE>\\n")))))

;;@args caption align
;;@args caption
;;@2 can be @samp{top} or @samp{bottom}.
(define (html:caption caption . align)
  (if (null? align)
      (sprintf #f "  <CAPTION>%s</CAPTION>\\n"
	       (html:plain caption))
      (sprintf #f "  <CAPTION ALIGN=%s>%s</CAPTION>\\n"
	       (car align)
	       (html:plain caption))))

;;@body Outputs a heading row for the currently-started table.
(define (html:heading columns)
  (sprintf #f " <TR VALIGN=\"TOP\">\\n%s\\n"
	   (apply string-append
		  (map (lambda (datum)
			 (sprintf #f "   <TH>%s\\n" (or datum "")))
		       columns))))

;;@body Outputs a heading row with column-names @1 linked to URIs @2.
(define (html:href-heading columns uris)
  (html:heading
   (map (lambda (column uri)
	  (if uri
	      (html:link uri column)
	      column))
	columns uris)))

(define (row->anchor pkl row)
  (sprintf #f "<A NAME=\"%s\"></A>" (uri:make-path (butnthcdr pkl row))))

;;@args k foreigns
;;
;;The positive integer @1 is the primary-key-limit (number of
;;primary-keys) of the table.  @2 is a list of the filenames of
;;foreign-key field pages and #f for non foreign-key fields.
;;
;;@0 returns a procedure taking a row for its single argument.  This
;;returned procedure returns the html string for that table row.
(define (html:linked-row-converter pkl foreigns)
  (define idxs (do ((idx (length foreigns) (+ -1 idx))
		    (nats '() (cons idx nats)))
		   ((not (positive? idx)) nats)))
  (require 'pretty-print)
  (lambda (row)
    (define (present datum)
      (if (or (string? datum) (symbol? datum))
	  (html:plain datum)
	  (let* ((str (pretty-print->string datum))
		 (len (+ -1 (string-length str))))
	    (cond ((eqv? (string-index str #\newline) len)
		   (string-append "<TT>" (substring str 0 len) "</TT>"))
		  (else (html:pre str))))))
    (sprintf #f " <TR VALIGN=TOP>\\n%s\\n"
	     (apply string-append
		    (map (lambda (idx datum foreign)
			   (sprintf
			    #f "   <TD>%s%s\\n"
			    (if (eqv? 1 idx) (row->anchor pkl row) "")
			    (cond ((or (not datum) (null? datum)) "")
				  ((not foreign) (present datum))
				  ((equal? "catalog-data.html" foreign)
				   (html:link (make-uri
					       (table-name->filename datum)
					       #f #f)
					      (present datum)))
				  (else (html:link (make-uri foreign #f datum)
						   (present datum))))))
			 idxs row foreigns)))))

;;@body
;;Returns the symbol @1 converted to a filename.
(define (table-name->filename table-name)
  (and table-name (string-append
		   (string-subst (symbol->string table-name) "*" "" ":" "_")
		   ".html")))

(define (table-name->column-table-name db table-name)
  ((((db 'open-table) '*catalog-data* #f) 'get 'coltab-name)
   table-name))

;;@args caption db table-name match-key1 @dots{}
;;Returns HTML string for @2 table @3 chopped into 50-row HTML tables.
;;Every foreign-key value is linked to the page (of the table)
;;defining that key.
;;
;;The optional @4 @dots{} arguments restrict actions to a subset of
;;the table.  @xref{Table Operations, match-key}.
(define (table->linked-html caption db table-name . args)
  (let* ((table ((db 'open-table) table-name #f))
	 (foreigns (table 'column-foreigns))
	 (tags (map table-name->filename foreigns))
	 (names (table 'column-names))
	 (primlim (table 'primary-limit)))
    (define tables '())
    (define rows '())
    (define cnt 0)
    (define (make-table rows)
      (apply html:table "CELLSPACING=0 BORDER=1"
	     (html:caption caption 'BOTTOM)
	     (html:href-heading
	      names
	      (append (make-list primlim
				 (table-name->filename
				  (table-name->column-table-name db table-name)))
		      (make-list (- (length names) primlim) #f)))
	     (html:heading (table 'column-domains))
	     (html:href-heading foreigns tags)
	     (html:heading (table 'column-types))
	     rows))
    (apply (table 'for-each-row)
	   (lambda (row)
	     (set! cnt (+ 1 cnt))
	     (set! rows (cons row rows))
	     (cond ((<= 50 cnt)
		    (set! tables
			  (cons (make-table
				 (map (html:linked-row-converter primlim tags)
				      (reverse rows)))
				tables))
		    (set! cnt 0)
		    (set! rows '()))))
	   args)
    (apply string-append
	   (reverse (if (and (null? rows) (not (null? tables)))
			tables
			(cons (make-table
			       (map (html:linked-row-converter primlim tags)
				    (reverse rows)))
			      tables))))))

;;@body
;;Returns a complete HTML page.  The string @3 names the page which
;;refers to this one.
;;
;;The optional @4 @dots{} arguments restrict actions to a subset of
;;the table.  @xref{Table Operations, match-key}.
(define (table->linked-page db table-name index-filename . args)
  (string-append
   (if index-filename
       (html:head table-name
		  (html:link (make-uri index-filename #f table-name)
			     (html:plain table-name)))
       (html:head table-name))
   (html:body (apply table->linked-html table-name db table-name args))))

(define (html:catalog-row-converter row foreigns)
  (sprintf #f " <TR VALIGN=TOP>\\n%s\\n"
	   (apply string-append
		  (map (lambda (datum foreign)
			 (sprintf #f "   <TD>%s%s\\n"
				  (html:anchor (sprintf #f "%s" datum))
				  (html:link (make-uri foreign #f #f) datum)))
		       row foreigns))))

;;@body
;;Returns HTML string for the catalog table of @1.
(define (catalog->html db caption . args)
  (apply html:table "BORDER=1"
	 (html:caption caption 'BOTTOM)
	 (html:heading '(table columns))
	 (map (lambda (row)
		(cond ((and (eq? '*columns* (caddr row))
			    (not (eq? '*columns* (car row))))
		       "")
		      (else (html:catalog-row-converter
			     (list (car row) (caddr row))
			     (list (table-name->filename (car row))
				   (table-name->filename (caddr row)))))))
	      (apply (((db 'open-table) '*catalog-data* #f) 'row:retrieve*)
		     args))))

;;Returns complete HTML page (string) for the catalog table of @1.
(define (catalog->page db caption . args)
  (string-append (html:head caption)
		 (html:body (apply catalog->html db caption args))))

;;@subsection HTML editing tables

;;@noindent A client can modify one row of an editable table at a time.
;;For any change submitted, these routines check if that row has been
;;modified during the time the user has been editing the form.  If so,
;;an error page results.
;;
;;@noindent The behavior of edited rows is:
;;
;;@itemize @bullet
;;@item
;;If no fields are changed, then no change is made to the table.
;;@item
;;If the primary keys equal null-keys (parameter defaults), and no other
;;user has modified that row, then that row is deleted.
;;@item
;;If only primary keys are changed, there are non-key fields, and no
;;row with the new keys is in the table, then the old row is
;;deleted and one with the new keys is inserted.
;;@item
;;If only non-key fields are changed, and that row has not been
;;modified by another user, then the row is changed to reflect the
;;fields.
;;@item
;;If both keys and non-key fields are changed, and no row with the
;;new keys is in the table, then a row is created with the new
;;keys and fields.
;;@item
;;If fields are changed, all fields are primary keys, and no row with
;;the new keys is in the table, then a row is created with the new
;;keys.
;;@end itemize
;;
;;@noindent After any change to the table, a @code{sync-database} of the
;;database is performed.

;;@args table-name null-keys update delete retrieve
;;@args table-name null-keys update delete
;;@args table-name null-keys update
;;@args table-name null-keys
;;
;;Returns procedure (of @var{db}) which returns procedure to modify
;;row of @1.  @2 is the list of @dfn{null} keys indicating the row is
;;to be deleted when any matches its corresponding primary key.
;;Optional arguments @3, @4, and @5 default to the @code{row:update},
;;@code{row:delete}, and @code{row:retrieve} of @1 in @var{db}.
(define (command:modify-table table-name null-keys . args)
  (define argc (length args))
  (lambda (rdb)
    (define table ((rdb 'open-table) table-name #t))
    (let ((table:update (or (and (> argc 0) (car args)) (table 'row:update)))
	  (table:delete (or (and (> argc 1) (cadr args)) (table 'row:delete)))
	  (table:retrieve (or (and (> argc 2) (caddr args)) (table 'row:retrieve)))
	  (pkl (length null-keys)))
      (define ptypes (butnthcdr pkl (table 'column-types)))
      (if (> argc 4) (slib:error 'command:modify-table 'too-many-args
				 table-name null-keys args))
      (lambda (*keys* *row-hash* . new-row)
	(let* ((new-pkeys (butnthcdr pkl new-row))
	       (pkeys (uri:path->keys (uri:split-fields *keys* #\/) ptypes))
	       (row (apply table:retrieve pkeys))
	       (same-nonkeys? (equal? (nthcdr pkl new-row) (nthcdr pkl row))))
	  (cond ((equal? pkeys new-pkeys) ;did not change keys
		 (cond ((not row) '("Row deleted by other user"))
		       ((equal? (crc:hash-obj row) *row-hash*)
			(table:update new-row)
			((rdb 'sync-database)) #t)
		       (else '("Row changed by other user"))))
		((command:null-key? null-keys new-pkeys) ;blanked keys
		 (cond ((not row) #t)
		       ((equal? (crc:hash-obj row) *row-hash*)
			;;(slib:warn (sprintf #f "Removing key: %#a => %#a" new-pkeys ))
			(apply table:delete pkeys)
			((rdb 'sync-database)) #t)
		       (else '("Row changed by other user"))))
		(else			;changed keys
		 (set! row (apply table:retrieve new-pkeys))
		 (cond (row (list "Row already exists"
				  (sprintf #f "%#a" row)))
		       (else (table:update new-row)
			     (if (and same-nonkeys?
				      (not (null? (nthcdr pkl new-row))))
				 (apply table:delete pkeys))
			     ((rdb 'sync-database)) #t)))))))))

(define (command:null-key? null-keys new-pkeys)
  (define sts #f)
  (for-each (lambda (nuk nep) (if (equal? nuk nep) (set! sts #t)))
	    null-keys
	    new-pkeys)
  sts)

(define (make-defaulter arity type)
  `(lambda (pl)
     ',(case arity
	 ((optional nary) '())
	 ((boolean) #f)
	 ((single nary1)
	  (case type
	    ((string) '(""))
	    ((symbol) '(nil))
	    ((number) '(0))
	    (else '(#f))))
	 (else (slib:error 'make-defaulter 'unknown 'arity arity)))))

;;@body Given @2 in @1, creates parameter and @code{*command*} tables
;;for editing one row of @2 at a time.  @0 returns a procedure taking a
;;row argument which returns the HTML string for editing that row.
;;
;;Optional @3 are expressions (lists) added to the call to
;;@code{command:modify-table}.
;;
;;The domain name of a column determines the expected arity of the data
;;stored in that column.  Domain names ending in:
;;
;;@table @samp
;;@item *
;;have arity @samp{nary};
;;@item +
;;have arity @samp{nary1}.
;;@end table
(define (command:make-editable-table rdb table-name . args)
  (define table ((rdb 'open-table) table-name #t))
  (require 'database-commands)
  (let ((pkl (table 'primary-limit))
	(columns (table 'column-names))
	(domains (table 'column-domains))
	(types (table 'column-types))
	(idxs (do ((idx (length (table 'column-names)) (+ -1 idx))
		   (nats '() (cons (+ 2 idx) nats)))
		  ((not (positive? idx)) nats)))
	(ftn (((rdb 'open-table) '*domains-data* #f) 'get 'foreign-table)))
    (define field-specs
      (map (lambda (idx column domain type)
	     (let* ((dstr (symbol->string domain))
		    (len (+ -1 (string-length dstr))))
	       (define arity
		 (case (string-ref dstr len)
		   ((#\*) 'nary)
		   ((#\+) 'nary1)
		   (else (if (eq? 'boolean type) 'boolean 'single))))
	       (case (string-ref dstr len)
		 ((#\* #\+)
		  (set! type (string->symbol (substring dstr 0 len)))
		  (set! domain type)))
	       `(,idx ,column ,arity ,domain
		      ,(make-defaulter arity type) #f "")))
	   idxs columns domains types))
    (define foreign-choice-lists
      (map (lambda (domain-name)
	     (define tab-name (ftn domain-name))
	     (if tab-name (get-foreign-choices
			   ((rdb 'open-table) tab-name #f)) '()))
	   domains))
    (define-tables rdb
      `(,(symbol-append table-name '- 'params)
	*parameter-columns* *parameter-columns*
	((1 *keys* single string #f #f "")
	 (2 *row-hash* single string #f #f "")
	 ,@field-specs))
      `(,(symbol-append table-name '- 'pname)
	((name string))
	((parameter-index ordinal))	;should be address-params
	(("*keys*" 1)
	 ("*row-hash*" 2)
	 ,@(map (lambda (idx column) (list (symbol->string column) idx))
		idxs columns)))
      `(*commands*
	desc:*commands* desc:*commands*
	((,(symbol-append 'edit '- table-name)
	  ,(symbol-append table-name '- 'params)
	  ,(symbol-append table-name '- 'pname)
	  (command:modify-table ',table-name
				',(map (lambda (fs)
					 (define dfl
					   ((slib:eval (car (cddddr fs)))
					    '()))
					 (if (pair? dfl) (car dfl) dfl))
				       (butnthcdr pkl field-specs))
				,@args)
	  ,(string-append "Modify " (symbol->string table-name))))))
    (let ((arities (map caddr field-specs)))
      (lambda (row)
	(define elements
	  (map form:element
	       columns
	       arities
	       (map (lambda (fld arity) (case arity
					  ((nary nary1) fld)
					  (else (list fld))))
		    row arities)
	       foreign-choice-lists))
	(sprintf #f " <TR>\\n   <TD>%s%s\\n\\n"
		 (string-append
		  (html:hidden '*row-hash* (crc:hash-obj row))
		  (html:hidden '*keys* (uri:make-path (butnthcdr pkl row)))
		  ;; (html:hidden '*suggest* '<>)
		  (car elements)
		  (form:submit '<> (symbol-append 'edit '- table-name))
		  ;; (form:image "Modify Row" "/icons/bang.png")
		  )
		 (apply string-append
			(map (lambda (elt) (sprintf #f "   <TD>%s\\n" elt))
			     (cdr elements))))))))

;;@args k names edit-point edit-converter
;;
;;The positive integer @1 is the primary-key-limit (number of
;;primary-keys) of the table.  @2 is a list of the field-names.  @3 is
;;the list of primary-keys denoting the row to edit (or #f).  @4 is the
;;procedure called with @1, @2, and the row to edit.
;;
;;@0 returns a procedure taking a row for its single argument.  This
;;returned procedure returns the html string for that table row.
;;
;;Each HTML table constructed using @0 has first @1 fields (typically
;;the primary key fields) of each row linked to a text encoding of these
;;fields (the result of calling @code{row->anchor}).  The page so
;;referenced typically allows the user to edit fields of that row.
(define (html:editable-row-converter pkl names edit-point edit-converter)
  (require 'pretty-print)
  (let ((idxs (do ((idx (length names) (+ -1 idx))
		   (nats '() (cons idx nats)))
		  ((not (positive? idx)) nats)))
	(datum->html
	 (lambda (datum)
	   (if (or (string? datum) (symbol? datum))
	       (html:plain datum)
	       (let* ((str (pretty-print->string datum))
		      (len (+ -1 (string-length str))))
		 (cond ((eqv? (string-index str #\newline) len)
			(string-append "<B>" (substring str 0 len) "</B>"))
		       (else (html:pre str))))))))
    (lambda (row)
      (string-append
       (sprintf #f " <TR VALIGN=TOP>\\n%s\\n"
		(apply string-append
		       (map (lambda (idx datum foreign)
			      (sprintf
			       #f "   <TD>%s%s\\n"
			       (if (eqv? 1 idx) (row->anchor pkl row) "")
			       (cond ((or (not datum) (null? datum)) "")
				     ((<= idx pkl)
				      (let ((keystr (uri:make-path
						     (butnthcdr pkl row))))
					(sprintf #f "<A HREF=\"%s#%s\">%s</A>"
						 keystr keystr
						 (datum->html datum))))
				     (else (datum->html datum)))))
			    idxs row names)))
       (if (and edit-point edit-converter
		(equal? (butnthcdr pkl edit-point) (butnthcdr pkl row)))
	   (edit-converter row)
	   "")))))

;;@subsection HTML databases

;;@body @1 must be a relational database.  @2 must be #f or a
;;non-empty string naming an existing sub-directory of the current
;;directory.
;;
;;@0 creates an html page for each table in the database @1 in the
;;sub-directory named @2, or the current directory if @2 is #f.  The
;;top level page with the catalog of tables (captioned @4) is written
;;to a file named @3.
(define (db->html-files db dir index-filename caption)
  (set! dir (if dir (sub-vicinity "" dir) ""))
  (call-with-output-file (in-vicinity dir index-filename)
    (lambda (port)
      (display (catalog->page db caption) port)))
  (let ((catdat ((db 'open-table) '*catalog-data* #f)))
    ((or (catdat 'for-each-row-in-order) (catdat 'for-each-row))
     (lambda (row)
       (call-with-output-file
	   (in-vicinity dir (table-name->filename (car row)))
	 (lambda (port)
	   (display (table->linked-page db (car row) index-filename) port)))))))

;;@args db dir index-filename
;;@args db dir
;;@1 must be a relational database.  @2 must be a non-empty
;;string naming an existing sub-directory of the current directory or
;;one to be created.  The optional string @3 names the filename of the
;;top page, which defaults to @file{index.html}.
;;
;;@0 creates sub-directory @2 if neccessary, and calls
;;@code{(db->html-files @1 @2 @3 @2)}.  The @samp{file:} URI of @3 is
;;returned.
(define (db->html-directory db dir . index-filename)
  (set! index-filename (if (null? index-filename)
			   "index.html"
			   (car index-filename)))
  (if (symbol? dir) (set! dir (symbol->string dir)))
  (if (not (file-exists? dir)) (make-directory dir))
  (db->html-files db dir index-filename dir)
  (path->uri (in-vicinity (sub-vicinity (user-vicinity) dir) index-filename)))

;;@args db dir index-filename
;;@args db dir
;;@0 is just like @code{db->html-directory}, but calls
;;@code{browse-url} with the uri for the top page after the
;;pages are created.
(define (db->netscape . args)
  (browse-url (apply db->html-directory args)))
