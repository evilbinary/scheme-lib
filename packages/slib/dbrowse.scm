;;; "dbrowse.scm" relational-database-browser
; Copyright 1996, 1997, 1998 Aubrey Jaffer
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
(require 'printf)

(define browse:db #f)
;@
(define (browse . args)
  (define table-name #f)
  (cond ((null? args))
	((procedure? (car args))
	 (set! browse:db (car args))
	 (set! args (cdr args)))
	((string? (car args))
	 (set! browse:db (open-database (car args)))
	 (set! args (cdr args))))
  (cond ((null? args))
	(else (set! table-name (car args))))
  (let* ((open-table (browse:db 'open-table))
	 (catalog (and open-table (open-table '*catalog-data* #f))))
    (cond ((not catalog)
	   (slib:error 'browse "could not open catalog"))
	  ((not table-name)
	   (browse:display-dir '*catalog-data* catalog))
	  (else
	   (let ((table (open-table table-name #f)))
	     (cond (table (browse:display-table table-name table)
			  (table 'close-table))
		   (else (slib:error 'browse "could not open table"
				     table-name))))))))

(define (browse:display-dir table-name table)
  (printf "%s Tables:\\n" table-name)
  ((or (table 'for-each-row-in-order) (table 'for-each-row))
   (lambda (row) (printf "\\t%a\\n" (car row)))))

(define (browse:display-table table-name table)
  (let* ((width 18)
	 (dw (string-append "%-" (number->string width)))
	 (dwp (string-append "%-" (number->string width) "."
			     (number->string (+ -1 width))))
	 (dwp-string (string-append dwp "s"))
	 (dwp-any (string-append dwp "a"))
	 (dw-integer (string-append dw "d"))
	 (underline (string-append (make-string (+ -1 width) #\=) " "))
	 (form ""))
    (printf "Table: %s\\n" table-name)
    (for-each (lambda (name) (printf dwp-string name))
	      (table 'column-names))
    (newline)
    (for-each (lambda (foreign) (printf dwp-any foreign))
	      (table 'column-foreigns))
    (newline)
    (for-each (lambda (domain) (printf dwp-string domain))
	      (table 'column-domains))
    (newline)
    (for-each (lambda (type)
		(case type
		  ((integer number ordinal base-id uint)
		   (set! form (string-append form dw-integer)))
		  ((boolean domain expression atom)
		   (set! form (string-append form dwp-any)))
		  ((string symbol)
		   (set! form (string-append form dwp-string)))
		  (else (slib:error 'browse:display-table "unknown type" type)))
		(printf dwp-string type))
	      (table 'column-types))
    (newline)
    (set! form (string-append form "\\n"))
    (for-each (lambda (domain) (printf underline))
	      (table 'column-domains))
    (newline)
    ((or (table 'for-each-row-in-order) (table 'for-each-row))
     (lambda (row)
       (apply printf (cons form row))))))
