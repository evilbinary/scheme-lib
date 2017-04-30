;;; "colornam.scm" color name databases
;Copyright 2001, 2002 Aubrey Jaffer
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

(require 'databases)
(require 'color)

;;@code{(require 'color-names)}
;;@ftindex color-names

;;@noindent
;;Rather than ballast the color dictionaries with numbered grays,
;;@code{file->color-dictionary} discards them.  They are provided
;;through the @code{grey} procedure:

;;@body
;;Returns @code{(inexact->exact (round (* k 2.55)))}, the X11 color
;;grey@i{<k>}.
(define (grey k)
  (define int (inexact->exact (round (* k 2.55))))
  (color:sRGB int int int))

;;@noindent
;;A color dictionary is a database table relating @dfn{canonical}
;;color-names to color-strings
;;(@pxref{Color Data-Type, External Representation}).
;;
;;@noindent
;;The column names in a color dictionary are unimportant; the first
;;field is the key, and the second is the color-string.

;;@body Returns a downcased copy of the string or symbol @1 with
;;@samp{_}, @samp{-}, and whitespace removed.
(define (color-name:canonicalize name)
  (list->string
   (apply append (map (lambda (c) (if (or (char-alphabetic? c)
					  (char-numeric? c))
				      (list (char-downcase c))
				      '()))
		      (string->list (if (symbol? name)
					(symbol->string name)
					name))))))

;;@args name table1 table2 @dots{}
;;
;;@2, @3, @dots{} must be color-dictionary tables.  @0 searches for the
;;canonical form of @1 in @2, @3, @dots{} in order; returning the
;;color-string of the first matching record; #f otherwise.
(define (color-name->color name . tables)
  (define cancol (color-name:canonicalize name))
  (define found #f)
  (do ((tabs tables (cdr tabs)))
      ((or found (null? tabs)) (and found (string->color found)))
    (set! found (((car tabs) 'get 2) cancol))))

;;@args table1 table2 @dots{}
;;
;;@1, @2, @dots{} must be color-dictionary tables.  @0 returns a
;;procedure which searches for the canonical form of its string argument
;;in @1, @2, @dots{}; returning the color-string of the first matching
;;record; and #f otherwise.
(define (color-dictionaries->lookup . tables)
  (define procs (map (lambda (tab) (tab 'get 2)) tables))
  (lambda (name)
    (define cancol (color-name:canonicalize name))
    (define found #f)
    (do ((procs procs (cdr procs)))
	((or found (null? procs)) (and found (string->color found)))
      (set! found ((car procs) cancol)))))

;;@args name rdb base-table-type
;;
;;@2 must be a string naming a relational database file; and the symbol
;;@1 a table therein.  The database will be opened as
;;@var{base-table-type}.  @0 returns the read-only table @1 in database
;;@1 if it exists; #f otherwise.
;;
;;@args name rdb
;;
;;@2 must be an open relational database or a string naming a relational
;;database file; and the symbol @1 a table therein.  @0 returns the
;;read-only table @1 in database @1 if it exists; #f otherwise.
(define (color-dictionary table-name . *db*)
  (define rdb (apply open-database *db*))
  (and rdb ((rdb 'open-table) table-name #f)))


;;@args name rdb base-table-type
;;@args name rdb
;;
;;@2 must be a string naming a relational database file; and the symbol
;;@1 a table therein.  If the symbol @3 is provided, the database will
;;be opened as @3.  @0 creates a top-level definition of the symbol @1
;;to a lookup procedure for the color dictionary @1 in @2.
;;
;;The value returned by @0 is unspecified.
(define (load-color-dictionary table-name . db)
  (slib:eval
   `(define ,table-name
      (color-dictionaries->lookup
       (color-dictionary ',table-name
			 ,@(map (lambda (arg) (list 'quote arg)) db))))))
