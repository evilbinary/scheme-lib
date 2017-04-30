;;; "dbcom.scm" embed commands in relational-database
; Copyright 1994, 1995, 1997, 2000, 2001 Aubrey Jaffer
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

(require 'common-list-functions)	;for position
(require 'relational-database)
(require 'multiarg-apply)
(require 'databases)
;@
(define (wrap-command-interface rdb)
  (let* ((rdms:commands ((rdb 'open-table) '*commands* #f))
	 (command:get (and rdms:commands (rdms:commands 'get 'procedure))))
    (and command:get
	 (letrec ((wdb (lambda (command)
			 (let ((com (command:get command)))
			   (if com ((slib:eval com) wdb) (rdb command))))))
	   (let ((init (wdb '*initialize*)))
	     (if (procedure? init) init wdb))))))
;@
(define (open-command-database! path . arg)
  (define bt (apply open-database! path arg))
  (and bt (wrap-command-interface bt)))
;@
(define (open-command-database path . arg)
  (define bt (apply open-database path arg))
  (and bt (wrap-command-interface bt)))
;@
(define (add-command-tables rdb)
  (define-tables
    rdb
    '(type
      ((name symbol))
      ()
      ((atom)
       (symbol)
       (string)
       (number)
       (money)
       (date-time)
       (boolean)
       (foreign-key)
       (expression)
       (virtual)))
    '(parameter-arity
      ((name symbol))
      ((predicate? expression)
       (procedure expression))
      ((single (lambda (a) (and (pair? a) (null? (cdr a)))) car)
       (optional
	(lambda (lambda (a) (or (null? a) (and (pair? a) (null? (cdr a))))))
	identity)
       (boolean
	(lambda (a) (or (null? a)
			(and (pair? a) (null? (cdr a)) (boolean? (car a)))))
	(lambda (a) (if (null? a) #f (car a))))
       (nary (lambda (a) #t) identity)
       (nary1 (lambda (a) (not (null? a))) identity))))
  (for-each (((rdb 'open-table) '*domains-data* #t) 'row:insert)
	    '((parameter-list *catalog-data* #f symbol 1)
	      (parameter-name-translation *catalog-data* #f symbol 1)
	      (parameter-arity parameter-arity #f symbol 1)
	      (table *catalog-data* #f atom 1)))
  (define-tables
    rdb
    '(*parameter-columns*
      *columns*
      *columns*
      ((1 #t index #f ordinal)
       (2 #f name #f symbol)
       (3 #f arity #f parameter-arity)
       (4 #f domain #f domain)
       (5 #f defaulter #f expression)
       (6 #f expander #f expression)
       (7 #f documentation #f string)))
    '(no-parameters
      *parameter-columns*
      *parameter-columns*
      ())
    '(no-parameter-names
      ((name string))
      ((parameter-index ordinal))
      ())
    '(add-domain-params
      *parameter-columns*
      *parameter-columns*
      ((1 domain-name single atom #f #f "new domain name")
       (2 foreign-table optional table #f #f
	  "if present, domain-name must be existing key into this table")
       (3 domain-integrity-rule optional expression #f #f
	  "returns #t if single argument is good")
       (4 type-id single type #f #f "base type of new domain")
       (5 type-param optional expression #f #f
	  "which (key) field of the foreign-table")
       ))
    '(add-domain-pnames
      ((name string))
      ((parameter-index ordinal))	;should be add-domain-params
      (
       ("n" 1) ("name" 1)
       ("f" 2) ("foreign (key) table" 2)
       ("r" 3) ("domain integrity rule" 3)
       ("t" 4) ("type" 4)
       ("p" 5) ("type param" 5)
       ))
    '(del-domain-params
      *parameter-columns*
      *parameter-columns*
      ((1 domain-name single domain #f #f "domain name")))
    '(del-domain-pnames
      ((name string))
      ((parameter-index ordinal))	;should be del-domain-params
      (("n" 1) ("name" 1)))
    '(*commands*
      ((name symbol))
      ((parameters parameter-list)
       (parameter-names parameter-name-translation)
       (procedure expression)
       (documentation string))
      ((domain-checker
	no-parameters
	no-parameter-names
	dbcom:check-domain
	"return procedure to check given domain name")

       (add-domain
	add-domain-params
	add-domain-pnames
	(lambda (rdb)
	  (((rdb 'open-table) '*domains-data* #t) 'row:update))
	"add a new domain")

       (delete-domain
	del-domain-params
	del-domain-pnames
	(lambda (rdb)
	  (((rdb 'open-table) '*domains-data* #t) 'row:remove))
	"delete a domain"))))
  (let* ((tab ((rdb 'open-table) '*domains-data* #t))
	 (row ((tab 'row:retrieve) 'type)))
    ((tab 'row:update) (cons 'type (cdr row))))
  (wrap-command-interface rdb))
;@
(define (define-*commands* rdb . cmd-defs)
  (define defcmd (((rdb 'open-table) '*commands* #t) 'row:update))
  (for-each (lambda (def)
	      (define procname (caar def))
	      (define args (cdar def))
	      (define body (cdr def))
	      (let ((comment (and (string? (car body)) (car body))))
		(define nbody (if comment (cdr body) body))
		(defcmd (list procname
			      'no-parameters
			      'no-parameter-names
			      `(lambda ,args ,@nbody)
			      (or comment "")))))
	    cmd-defs))

;; Actually put into command table by add-command-tables
(define (dbcom:check-domain rdb)
  (let* ((ro:domains ((rdb 'open-table) '*domains-data* #f))
	 (ro:get-dir (ro:domains 'get 'domain-integrity-rule))
	 (ro:for-tab (ro:domains 'get 'foreign-table)))
    (lambda (domain)
      (let ((fkname (ro:for-tab domain))
	    (dir (slib:eval (ro:get-dir domain))))
	(if fkname (let* ((fktab ((rdb 'open-table) fkname #f))
			  (p? (fktab 'get 1)))
		     (if dir (lambda (e) (and (dir e) (p? e))) p?))
	    dir)))))
;@
(define (make-command-server rdb command-table)
  (let* ((comtab ((rdb 'open-table) command-table #f))
	 (names (comtab 'column-names))
	 (row-ref (lambda (row name) (list-ref row (position name names))))
	 (comgetrow (comtab 'row:retrieve)))
    (lambda (comname command-callback)
      (cond ((not comname) (set! comname '*default*)))
      (cond ((not (comgetrow comname))
	     (slib:error 'command 'not 'known: comname)))
      (let* ((command:row (comgetrow comname))
	     (parameter-table
	      ((rdb 'open-table) (row-ref command:row 'parameters) #f))
	     (parameter-names
	      ((rdb 'open-table) (row-ref command:row 'parameter-names) #f))
	     (comval ((slib:eval (row-ref command:row 'procedure)) rdb))
	     (options ((parameter-table 'get* 'name)))
	     (positions ((parameter-table 'get* 'index)))
	     (arities ((parameter-table 'get* 'arity)))
	     (defaulters (map slib:eval ((parameter-table 'get* 'defaulter))))
	     (domains ((parameter-table 'get* 'domain)))
	     (types (map (((rdb 'open-table) '*domains-data* #f) 'get 'type-id)
			 domains))
	     (dirs (map (or (rdb 'domain-checker) (lambda (domain)
						    (lambda (domain) #t)))
			domains))
	     (aliases
	      (map list ((parameter-names 'get* 'name))
		   (map (parameter-table 'get 'name)
			((parameter-names 'get* 'parameter-index))))))
	(command-callback comname comval options positions
			  arities types defaulters dirs aliases)))))
