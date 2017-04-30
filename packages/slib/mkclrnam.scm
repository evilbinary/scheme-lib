;;; "mkclrnam.scm" create color name databases
;Copyright 2001, 2002, 2003, 2007, 2008 Aubrey Jaffer
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

(require 'multiarg-apply)
(require 'string-search)
(require 'line-i/o)
(require 'scanf)
(require 'color)
(require 'color-names)
(require 'databases)
(require-if 'compiling 'filename)

;;@subsubheading Dictionary Creation
;;
;;@code{(require 'color-database)}
;;@ftindex color-database

;;@args file table-name rdb base-table-type
;;@args file table-name rdb
;;
;;@3 must be an open relational database or a string naming a relational
;;database file, @2 a symbol, and the string @1 must name an existing
;;file with colornames and their corresponding xRGB (6-digit hex)
;;values.  @0 creates a table @2 in @3 and enters the associations found
;;in @1 into it.
(define (file->color-dictionary file table-name . *db*)
  (define rdb (apply open-database! *db*))
  (define-tables rdb
    `(,table-name
      ((name string))
      ((color string)
       (order ordinal))
      ()))
  (let ((table ((rdb 'open-table) table-name #t)))
    (and table (load-rgb-txt file table))))

;;@args url table-name rdb base-table-type
;;@args url table-name rdb
;;
;;@3 must be an open relational database or a string naming a relational
;;database file and @2 a symbol.  @0 retrieves the resource named by the
;;string @1 using the @dfn{wget} program; then calls
;;@code{file->color-dictionary} to enter its associations in @2 in @1.
(define (url->color-dictionary url table-name . rdb)
  (require 'filename)
  (call-with-tmpnam
   (lambda (file)
     (system (string-append "wget -c -O" file " -USLIB" *slib-version* " " url))
     (apply file->color-dictionary file table-name rdb))))

(define (load-rgb-txt path color-table)
  (cond ((not (file-exists? path))
	 (slib:error 'load-color-dictionary! 'file-exists? path)))
  (write 'load-rgb-txt) (display #\space) (write path) (newline)
  (let ((color-table:row-insert (color-table 'row:insert))
	(color-table:row-retrieve (color-table 'row:retrieve))
	(method-id #f))
    (define (floats->rgb . rgbi)
      (apply color:sRGB
	     (map (lambda (x) (inexact->exact (round (* 255 x)))) rgbi)))
    (define (parse-rgb-line line)
      (let ((rgbx #f) (r #f) (g #f) (b #f)
	    (ri #f) (gi #f) (bi #f) (name #f) (junk #f) (ans #f))
	(define (check-match line color1 . colors)
	  (cond ((null? colors) (color->string color1))
		((> (CMC:DE* color1 (car colors)) 5.0)
		 (newline) (display line) (force-output)
		 (slib:warn (round (CMC:DE* color1 (car colors)))
			    'mismatch (color->string color1)
			    (color->string (car colors)))
		 (apply check-match line colors))
		(else (apply check-match line colors))))
	(for-each
	 (lambda (method)
	   (or ans
	       (let ((try (method line)))
		 (cond (try (set! ans try)
			    (display "**** Using method ")
			    (display method-id) (newline)
			    (set! parse-rgb-line method))))))
	 (list
	  (lambda (line)
	    (define use #f)
	    (case (sscanf line "%[^;]; red=%d, green=%d, blue=%d; hex=%6x; %[^.].%s"
			  name r g b rgbx use junk)
	      ((6)
	       (set! method-id 'm6e)
	       (list (check-match line (xrgb->color rgbx) (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (define en #f) (define fr #f) (define de #f)
	    (define es #f) (define cz #f) (define hu #f)
	    (case (sscanf line "#%6x	%[^	]	%[^	]	%[^	]	%[^	]	%[^	]	%[^	]%s"
			  rgbx en fr de es cz hu junk)
	      ((7)
	       (set! method-id 'm77)
	       (cons (check-match line (xRGB->color rgbx))
		     (map color-name:canonicalize (list en fr de es cz hu))))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %24[a-zA-Z0-9_ ] %d %d %d %e %e %e %s"
			  name r g b ri gi bi junk)
	      ((7)
	       (set! method-id 'm7)
	       (list (check-match line (color:sRGB r g b) (floats->rgb ri gi bi))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[a-zA-Z0-9_] %6x %d %d %d %e %e %e %s"
			  name rgbx r g b ri gi bi junk)
	      ((8)
	       (set! method-id 'm8)
	       (list (check-match line (xrgb->color rgbx)
				  (color:sRGB r g b)
				  (floats->rgb ri gi bi))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[a-zA-Z0-9] %6x %d,%d,%d" name rgbx r g b)
	      ((5)
	       (set! method-id 'm5)
	       (list (check-match line (xrgb->color rgbx) (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[- a-zA-Z0-9_'] #%6x %d %d %d %s"
			  name rgbx r g b junk)
	      ((6 5)
	       (set! method-id 'm65)
	       (list (check-match line (xrgb->color rgbx) (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %d %d %d %[a-zA-Z0-9 ]%s" r g b name junk)
	      ((4) (set! method-id 'm4a)
	       (list (check-match line (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "bang %d %d %d %d %[a-zA-Z0-9, ]%s"
			  r g b ri name junk)
	      ((5) (set! method-id 'm5b)
	       (list (check-match line (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[- a-zA-Z.] %d %d %d %s"
			  name r g b junk)
	      ((4) (set! method-id 'm4b)
	       (list (check-match line (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "\" Resene %[^\"]\" %d %d %d %s"
			  name r g b junk)
	      ((4) (set! method-id 'm4d)
	       (list (check-match line (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "\" %[^\"]\" %d %d %d %s"
			  name r g b junk)
	      ((4) (set! method-id 'm4c)
	       (list (check-match line (color:sRGB r g b))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[a-zA-Z()] %e %e %e %s"
			  name ri gi bi junk)
	      ((4) (set! method-id 'm4e)
	       (list (check-match line (color:L*a*b* ri gi bi))
		     (color-name:canonicalize
		      (string-downcase! (StudlyCapsExpand name " ")))))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line " %[a-zA-Z0-9_] #%6x%s" name rgbx junk)
	      ((2) (set! method-id 'm2a)
	       (list (check-match line (xrgb->color rgbx))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "[\"%6x\", \"%[^\"]\"], %s" rgbx name junk)
	      ((2) (set! method-id 'js)
	       (list (check-match line (xrgb->color rgbx))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "%[- a-zA-Z']=#%6x<br>" name rgbx)
	      ((2) (set! method-id 'm2b)
	       (let ((idx (substring? "rgb" name)))
		 (and (eqv? idx (+ -3 (string-length name)))
		      (list (check-match line (xrgb->color rgbx))
			    (color-name:canonicalize (substring name 0 idx))))))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "%[ a-zA-Z/'] #%6x" name rgbx)
	      ((2) (set! method-id 'm2d)
	       (list (check-match line (xrgb->color rgbx))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "\" %[^\"]\" %s" name junk)
	      ((2) (set! method-id 'm2c)
	       (let ((clr (string->color junk)))
		 (and clr (list (check-match line clr)
				(color-name:canonicalize name)))))
	      (else #f)))
	  (lambda (line)
	    (case (sscanf line "%[a-z0-9 ]\t%[A-Z]:%[./0-9] %s"
			  name r rgbx junk)
	      ((3) (set! method-id 'm3x)
	       (list (check-match line (string->color
					(string-append r ":" rgbx)))
		     (color-name:canonicalize name)))
	      (else #f)))
	  (lambda (line)
	    ;; FED-STD-595C - read only the first
	    (case (sscanf line "%5[0-9] %[A-Z]:%f/%f/%f"
	  		  name ri r g b)
	      ((5) (set! method-id 'm5x)
	       (cond ((string-ci=? "CIEXYZ" ri)
		      (list (check-match line (color:CIEXYZ (/ r 100)
							    (/ g 100)
							    (/ b 100)))
			    (color-name:canonicalize name)))
		     ((string-ci=? "CIELAB" ri)
		      (list (check-match line (color:L*A*B* r g b))
			    (color-name:canonicalize name)))
		     (else #f)))
	      (else #f)))
	  ))
	ans))
    (define (numbered-gray? str)
      (define idx #f)
      (and (or (eqv? 0 (substring-ci? "gray" str))
	       (eqv? 0 (substring-ci? "grey" str)))
	   (eqv? 1 (sscanf (substring str 4 (string-length str))
			   "%d%s" idx str))))
    (call-with-input-file path
      (lambda (port)
	(define *idx* 0)
	(define *rcs-header* (read-line port))
	(do ((line (read-line port) (read-line port)))
	    ((eof-object? line)
	     (display "Inserted ") (display *idx*) (display " colors") (newline)
	     *rcs-header*)
	  (let ((colin (parse-rgb-line line)))
	    (cond ((equal? "" line))
		  ;;((char=? #\# (string-ref line 0)))
		  ((not colin) (write-line line))
		  ((numbered-gray? (cadr colin)))
		  (else
		   (for-each
		    (lambda (name)
		      (let ((oclin (color-table:row-retrieve name)))
			(cond
			 ((and oclin (equal? (car colin) (cadr oclin))))
			 ((not oclin)
			  (set! *idx* (+ 1 *idx*))
			  (color-table:row-insert
			   (list name (car colin) *idx*)))
			 (else (slib:warn 'collision colin oclin)))))
		    (cdr colin))))))))))

;;@noindent
;;This section has detailed the procedures for creating and loading
;;color dictionaries.  So where are the dictionaries to load?
;;
;;@uref{http://people.csail.mit.edu/jaffer/Color/Dictionaries.html}
;;
;;@noindent
;;Describes and evaluates several color-name dictionaries on the web.
;;The following procedure creates a database containing two of these
;;dictionaries.

;;@body
;;Creates an @r{alist-table} relational database in @r{library-vicinity}
;;containing the @dfn{Resene} and @dfn{saturate} color-name
;;dictionaries.
;;
;;If the files @file{resenecolours.txt}, @file{nbs-iscc.txt}, and
;;@file{saturate.txt} exist in the @r{library-vicinity}, then they
;;used as the source of color-name data.  Otherwise, @0 calls
;;url->color-dictionary with the URLs of appropriate source files.
(define (make-slib-color-name-db)
  (define cndb (create-database (in-vicinity (library-vicinity) "clrnamdb.scm")
				'alist-table))
  (or cndb (slib:error 'cannot 'create 'database "clrnamdb.scm"))
  (for-each
   (lambda (lst)
     (apply
      (lambda (url path name)
	(define filename (in-vicinity (library-vicinity) path))
	(if (file-exists? filename)
	    (file->color-dictionary filename name cndb)
	    (url->color-dictionary url name cndb)))
      lst))
   '(("http://people.csail.mit.edu/jaffer/Color/saturate.txt"
      "saturate.txt"
      saturate)
     ("http://people.csail.mit.edu/jaffer/Color/resenecolours.txt"
      "resenecolours.txt"
      resene)
     ("http://people.csail.mit.edu/jaffer/Color/nbs-iscc.txt"
      "nbs-iscc.txt"
      nbs-iscc)))
  (close-database cndb))
