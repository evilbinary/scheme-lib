;;; "alistab.scm" database tables using association lists (assoc)
; Copyright 1994, 1997 Aubrey Jaffer
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

;;; LLDB	is (filename . alist-table)
;;; HANDLE	is (#(table-name key-dim) . TABLE)
;;; TABLE	is an alist of (Primary-key . ROW)
;;; ROW		is a list of non-primary VALUEs

(require 'common-list-functions)
(require 'relational-database)		;for make-relational-system
(require-if 'compiling 'sort)
;@
(define alist-table
  (let ((catalog-id 0)
	(resources '*base-resources*)
	(make-list-keyifier (lambda (prinum types) identity))
	(make-keyifier-1 (lambda (type) list))
	(make-key->list (lambda (prinum types) identity))
	(make-key-extractor (lambda (primary-limit column-type-list index)
			      (let ((i (+ -1 index)))
				(lambda (lst) (list-ref lst i))))))

(define keyify-1 (make-keyifier-1 'atom))

(define (make-base filename dim types)
  (list filename
	(list catalog-id)
	(list resources (list 'free-id 1))))

(define (open-base infile writable)
  (define (reader port)
    (cond ((eof-object? port) #f)
	  ((not (eqv? #\; (read-char port))) #f)
	  ((not (eqv? #\; (read-char port))) #f)
	  (else (cons (and (not (input-port? infile)) infile)
		      (read port)))))
  (cond ((input-port? infile) (reader infile))
	((file-exists? infile) (call-with-input-file infile reader))
	(else #f)))

(define (write-base lldb outfile)
  ((lambda (fun)
     (cond ((output-port? outfile) (fun outfile))
	   ((string? outfile) (call-with-output-file outfile fun))
	   (else #f)))
   (lambda (port)
     (display (string-append
	       ";;; \"" outfile "\" SLIB " *slib-version*
	       " alist-table database	 -*-scheme-*-")
	      port)
     (newline port) (newline port)
     (display "(" port) (newline port)
     (for-each
      (lambda (table)
	(display " (" port)
	(write (car table) port) (newline port)
	(for-each
	 (lambda (row)
	   (display "  " port) (write row port) (newline port))
	 (cdr table))
	(display " )" port) (newline port))
      (cdr lldb))
     (display ")" port) (newline port)
;     (require 'pretty-print)
;     (pretty-print (cdr lldb) port)
     (set-car! lldb (if (string? outfile) outfile #f))
     #t)))

(define (sync-base lldb)
  (cond ((car lldb) (write-base lldb (car lldb)) #t)
	(else
;;;	 (display "sync-base: database filename not known")
	 #f)))

(define (close-base lldb)
  (cond ((car lldb) (write-base lldb (car lldb))
		    (set-cdr! lldb #f)
		    (set-car! lldb #f) #t)
	((cdr lldb) (set-cdr! lldb #f)
		    (set-car! lldb #f) #t)
	(else
;;;	 (display "close-base: database not open")
	 #f)))

(define (make-table lldb dim types)
  (let ((free-hand (open-table lldb resources 1 '(atom integer))))
    (and free-hand
	 (let* ((row (assoc* (keyify-1 'free-id) (handle->alist free-hand)))
		(table-id #f))
	   (cond (row
		  (set! table-id (cadr row))
		  (set-car! (cdr row) (+ 1 table-id))
		  (set-cdr! lldb (cons (list table-id) (cdr lldb)))
		  table-id)
		 (else #f))))))

(define (open-table lldb base-id dim types)
  (assoc base-id (cdr lldb)))

(define (kill-table lldb base-id dim types)
  (define ckey (list base-id))
  (let ((pair (assoc* ckey (cdr lldb))))
    (and pair (set-cdr! lldb (delete-assoc ckey (cdr lldb))))
    (and pair (not (assoc* ckey (cdr lldb))))))

(define handle->alist cdr)
(define set-handle-alist! set-cdr!)

(define (assoc* keys alist)
  (let ((pair (assoc (car keys) alist)))
    (cond ((not pair) #f)
	  ((null? (cdr keys)) pair)
	  (else (assoc* (cdr keys) (cdr pair))))))

(define (make-assoc* keys alist vals)
  (let ((pair (assoc (car keys) alist)))
    (cond ((not pair) (cons (cons (car keys)
				  (if (null? (cdr keys))
				      vals
				      (make-assoc* (cdr keys) '() vals)))
			    alist))
	  (else (set-cdr! pair (if (null? (cdr keys))
				   vals
				   (make-assoc* (cdr keys) (cdr pair) vals)))
		alist))))

(define (delete-assoc ckey alist)
  (cond
   ((null? ckey) '())
   ((assoc (car ckey) alist)
    => (lambda (match)
	 (let ((adl (delete-assoc (cdr ckey) (cdr match))))
	   (cond ((null? adl) (delete match alist))
		 (else (set-cdr! match adl) alist)))))
   (else alist)))

(define (delete-assoc* ckey alist)
  (cond
   ((every not ckey) '())		;includes the null case.
   ((not (car ckey))
    (delete '()
	    (map (lambda (fodder)
		   (let ((adl (delete-assoc* (cdr ckey) (cdr fodder))))
		     (if (null? adl) '() (cons (car fodder) adl))))
		 alist)))
   ((procedure? (car ckey))
    (delete '()
	    (map (lambda (fodder)
		   (if ((car ckey) (car fodder))
		       (let ((adl (delete-assoc* (cdr ckey) (cdr fodder))))
			 (if (null? adl) '() (cons (car fodder) adl)))
		       fodder))
		 alist)))
   ((assoc (car ckey) alist)
    => (lambda (match)
	 (let ((adl (delete-assoc* (cdr ckey) (cdr match))))
	   (cond ((null? adl) (delete match alist))
		 (else (set-cdr! match adl) alist)))))
   (else alist)))

(define (assoc*-for-each proc bkey ckey alist)
  (cond ((null? ckey) (proc (reverse bkey)))
	((not (car ckey))
	 (for-each (lambda (alist)
		     (assoc*-for-each proc
				      (cons (car alist) bkey)
				      (cdr ckey)
				      (cdr alist)))
		   alist))
	((procedure? (car ckey))
	 (for-each (lambda (alist)
		     (if ((car ckey) (car alist))
			 (assoc*-for-each proc
					  (cons (car alist) bkey)
					  (cdr ckey)
					  (cdr alist))))
		   alist))
	((assoc (car ckey) alist)
	 => (lambda (match)
	      (assoc*-for-each proc
			       (cons (car match) bkey)
			       (cdr ckey)
			       (cdr match))))))

(define (assoc*-map proc bkey ckey alist)
  (cond ((null? ckey) (list (proc (reverse bkey))))
	((not (car ckey))
	 (apply append
		(map (lambda (alist)
		       (assoc*-map proc
				   (cons (car alist) bkey)
				   (cdr ckey)
				   (cdr alist)))
		     alist)))
	((procedure? (car ckey))
	 (apply append
		(map (lambda (alist)
		       (if ((car ckey) (car alist))
			   (assoc*-map proc
				       (cons (car alist) bkey)
				       (cdr ckey)
				       (cdr alist))
			   '()))
		     alist)))
	((assoc (car ckey) alist)
	 => (lambda (match)
	      (assoc*-map proc
			  (cons (car match) bkey)
			  (cdr ckey)
			  (cdr match))))
	(else '())))

(define (sorted-assoc*-for-each proc bkey ckey alist)
  (cond ((null? ckey) (proc (reverse bkey)))
	((not (car ckey))
	 (for-each (lambda (alist)
		     (sorted-assoc*-for-each proc
					     (cons (car alist) bkey)
					     (cdr ckey)
					     (cdr alist)))
		   (alist-sort! alist)))
	((procedure? (car ckey))
	 (sorted-assoc*-for-each proc
				 bkey
				 (cons #f (cdr ckey))
				 (remove-if-not (lambda (pair)
						  ((car ckey) (car pair)))
						alist)))
	((assoc (car ckey) alist)
	 => (lambda (match)
	      (sorted-assoc*-for-each proc
				      (cons (car match) bkey)
				      (cdr ckey)
				      (cdr match))))))

(define (alist-sort! alist)
  (define (key->sortable k)
    (cond ((number? k) k)
	  ((string? k) k)
	  ((symbol? k) (symbol->string k))
	  ((vector? k) (map key->sortable (vector->list k)))
	  (else (slib:error "unsortable key" k))))
  ;; This routine assumes that the car of its operands are either
  ;; numbers or strings (or lists of those).
  (define (car-key-< x y)
    (key-< (car x) (car y)))
  (define (key-< x y)
    (cond ((and (number? x) (number? y)) (< x y))
	  ((number? x) #t)
	  ((number? y) #f)
	  ((string? x) (string<? x y))
	  ((key-< (car x) (car y)) #t)
	  ((key-< (car y) (car x)) #f)
	  (else (key-< (cdr x) (cdr y)))))
  (require 'sort)
  (map cdr (sort! (map (lambda (p)
			 (cons (key->sortable (car p)) p))
		       alist)
		  car-key-<)))

(define (present? handle ckey)
  (assoc* ckey (handle->alist handle)))

(define (make-putter prinum types)
  (lambda (handle ckey restcols)
    (set-handle-alist! handle
		       (make-assoc* ckey (handle->alist handle) restcols))))

(define (make-getter prinum types)
  (lambda (handle ckey)
    (let ((row (assoc* ckey (handle->alist handle))))
      (and row (cdr row)))))

(define (for-each-key handle operation primary-limit column-type-list match-keys)
  (assoc*-for-each operation
		   '()
		   match-keys
		   (handle->alist handle)))

(define (map-key handle operation primary-limit column-type-list match-keys)
  (assoc*-map operation
	      '()
	      match-keys
	      (handle->alist handle)))

(define (ordered-for-each-key handle operation
			      primary-limit column-type-list match-keys)
  (sorted-assoc*-for-each operation
			  '()
			  match-keys
			  (handle->alist handle)))

(define (supported-type? type)
  (case type
    ((atom ordinal integer boolean string symbol expression number) #t)
    (else #f)))

(define (supported-key-type? type)
  (case type
    ((atom ordinal integer number symbol string) #t)
    (else #f)))

;;make-table open-table remover assoc* make-assoc*
;;(trace assoc*-for-each assoc*-map sorted-assoc*-for-each)

    (lambda (operation-name)
      (case operation-name
	((make-base) make-base)
	((open-base) open-base)
	((write-base) write-base)
	((sync-base) sync-base)
	((close-base) close-base)
	((catalog-id) catalog-id)
	((make-table) make-table)
	((open-table) open-table)
	((kill-table) kill-table)
	((make-keyifier-1) make-keyifier-1)
	((make-list-keyifier) make-list-keyifier)
	((make-key->list) make-key->list)
	((make-key-extractor) make-key-extractor)
	((supported-type?) supported-type?)
	((supported-key-type?) supported-key-type?)
	((present?) present?)
	((make-putter) make-putter)
	((make-getter) make-getter)
	((delete)
	 (lambda (handle ckey)
	   (set-handle-alist! handle
			      (delete-assoc ckey (handle->alist handle)))))
	((delete*)
	 (lambda (handle primary-limit column-type-list match-keys)
	   (set-handle-alist! handle
			      (delete-assoc* match-keys
					     (handle->alist handle)))))
	((for-each-key) for-each-key)
	((map-key) map-key)
	((ordered-for-each-key) ordered-for-each-key)
	(else #f)))
    ))

(set! *base-table-implementations*
      (cons (list 'alist-table (make-relational-system alist-table))
	    *base-table-implementations*))

;; #f (trace-all "/home/jaffer/slib/alistab.scm") (untrace alist-table) (set! *qp-width* 333)
