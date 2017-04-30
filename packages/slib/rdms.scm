;;; "rdms.scm" rewrite 6 - the saga continues
; Copyright 1994, 1995, 1997, 2000, 2002, 2003 Aubrey Jaffer
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

(require 'rev4-optional-procedures)	;list-tail

(define rdms:catalog-name '*catalog-data*)
(define rdms:domains-name '*domains-data*)
(define rdms:columns-name '*columns*)

(define catalog:init-cols
  '((1 #t table-name		#f symbol)
    (2 #f column-limit		#f ordinal)
    (3 #f coltab-name		#f symbol)
    (4 #f bastab-id		#f ordinal)
    (5 #f user-integrity-rule	#f expression)
    (6 #f view-procedure	#f expression)))

(define catalog:column-limit-pos 2)
(define catalog:coltab-name-pos 3)
(define catalog:bastab-id-pos 4)
(define catalog:integrity-rule-pos 5)
;;(define catalog:view-proc-pos 6)

(define columns:init-cols
  '((1 #t column-number		#f ordinal)
    (2 #f primary-key?		#f boolean)
    (3 #f column-name		#f symbol)
    (4 #f column-integrity-rule	#f expression)
    (5 #f domain-name		#f domain)))

(define columns:primary?-pos 2)
(define columns:name-pos 3)
(define columns:integrity-rule-pos 4)
(define columns:domain-name-pos 5)

(define domains:init-cols
  '((1 #t domain-name		#f symbol)
    (2 #f foreign-table		#f atom)
    (3 #f domain-integrity-rule	#f expression)
    (4 #f type-id		#f type)
    (5 #f type-param		#f expression)))

(define domains:foreign-pos 2)
(define domains:integrity-rule-pos 3)
(define domains:type-id-pos 4)
;;(define domains:type-param-pos 5)

(define domains:init-data
  `((type #f symbol? symbol #f)
    (ordinal #f (lambda (x) (and (integer? x) (positive? x))) number #f)
    (boolean #f boolean? boolean #f)
    (expression #f #f expression #f)
    (symbol #f symbol? symbol #f)
    (string #f string? string #f)
    (atom #f (lambda (x) (or (not x) (symbol? x))) atom #f) ; (number? x)
    (domain ,rdms:domains-name #f atom #f)
    ;; Legacy types
    (number #f number? number #f)
    (base-id #f number? ordinal #f)
    (uint #f (lambda (x) (and (integer? x) (not (negative? x)))) number #f)
    ))

;@
(define (make-relational-system base)

  (define (basic name)
    (let ((meth (base name)))
      (cond ((not meth) (slib:error 'make-relational-system
				    "essential method missing for:" name)))
      meth))

  (define (desc-row-type row)
    (let ((domain (assq (car (cddddr row)) domains:init-data)))
      (and domain (cadddr domain))))

  (define (itypes rows)
    (map (lambda (row)
	   (let ((domrow (assq (car (cddddr row)) domains:init-data)))
	     (cond (domrow (cadddr domrow))
		   (else (slib:error 'itypes "type not found for:"
				     (car (cddddr row)))))))
	 rows))

  (let ((make-base (base 'make-base))
	(open-base (basic 'open-base))
	(write-base (base 'write-base))
	(sync-base (base 'sync-base))
	(close-base (basic 'close-base))
	(base:supported-type? (basic 'supported-type?))
	(base:supported-key-type? (basic 'supported-key-type?))
	(base:make-table (base 'make-table))
	(base:open-table (basic 'open-table))
	(base:kill-table (base 'kill-table))
	(present? (basic 'present?))
	(base:ordered-for-each-key (base 'ordered-for-each-key))
	(base:for-each-primary-key (basic 'for-each-key))
	(base:map-primary-key (basic 'map-key))
	(base:make-nexter (base 'make-nexter))
	(base:make-prever (base 'make-prever))
	(base:catalog-id (basic 'catalog-id))
	(cat:keyify-1 ((basic 'make-keyifier-1)
		       (desc-row-type (assv 1 catalog:init-cols)))))

    (define (init-tab lldb id descriptor rows)
      (let ((han (base:open-table lldb id 1 (itypes descriptor)))
	    (keyify-1
	     ((base 'make-keyifier-1) (desc-row-type (assv 1 descriptor))))
	    (putter ((basic 'make-putter) 1 (itypes descriptor))))
	(for-each (lambda (row) (putter han (keyify-1 (car row)) (cdr row)))
		  rows)))

    (define cat:get-row
      (let ((cat:getter ((basic 'make-getter) 1 (itypes catalog:init-cols))))
	(lambda (bastab key)
	  (cat:getter bastab (cat:keyify-1 key)))))

    (define dom:get-row
      (let ((dom:getter ((basic 'make-getter) 1 (itypes domains:init-cols)))
	    (dom:keyify-1 ((basic 'make-keyifier-1)
			   (desc-row-type (assv 1 domains:init-cols)))))
	(lambda (bastab key)
	  (dom:getter bastab (dom:keyify-1 key)))))

    (define des:get-row
      (let ((des:getter ((basic 'make-getter) 1 (itypes columns:init-cols)))
	    (des:keyify-1 ((basic 'make-keyifier-1)
			   (desc-row-type (assv 1 columns:init-cols)))))
	(lambda (bastab key)
	  (des:getter bastab (des:keyify-1 key)))))

    (define (create-database filename)
      ;;(cond ((and filename (file-exists? filename)) (slib:warn 'create-database "file exists:" filename)))
      (let* ((lldb (make-base filename 1 (itypes catalog:init-cols)))
	     (cattab (and lldb (base:open-table lldb base:catalog-id 1
						(itypes catalog:init-cols)))))
	(cond
	 ((not lldb) (slib:error 'make-base "failed.") #f)
	 ((not cattab) (slib:error 'make-base "catalog missing.")
	  (close-base lldb)
	  #f)
	 (else
	  (let ((desdes-id (base:make-table lldb 1 (itypes columns:init-cols)))
		(domdes-id (base:make-table lldb 1 (itypes columns:init-cols)))
		(catdes-id (base:make-table lldb 1 (itypes columns:init-cols)))
		(domtab-id (base:make-table lldb 1 (itypes domains:init-cols)))
		)
	    (cond
	     ((not (and catdes-id domdes-id domtab-id desdes-id))
	      (slib:error 'create-database "make-table failed.")
	      (close-base lldb)
	      #f)
	     (else
	      (init-tab lldb desdes-id columns:init-cols columns:init-cols)
	      (init-tab lldb domdes-id columns:init-cols domains:init-cols)
	      (init-tab lldb catdes-id columns:init-cols catalog:init-cols)
	      (init-tab lldb domtab-id domains:init-cols domains:init-data)
	      (init-tab
	       lldb base:catalog-id catalog:init-cols
	       `((*catalog-desc* 5 ,rdms:columns-name ,catdes-id #f #f)
		 (*domains-desc* 5 ,rdms:columns-name ,domdes-id #f #f)
		 (,rdms:catalog-name 6 *catalog-desc* ,base:catalog-id #f #f)
		 (,rdms:domains-name 5 *domains-desc* ,domtab-id #f #f)
		 (,rdms:columns-name 5 ,rdms:columns-name ,desdes-id #f #f)))
	      (init-database
	       filename #t lldb cattab
	       (base:open-table lldb domtab-id 1 (itypes domains:init-cols))
	       #f))))))))

    (define (base:catalog->domains lldb base:catalog)
      (let ((cat:row (cat:get-row base:catalog rdms:domains-name)))
	(and cat:row
	     (base:open-table lldb
			      (list-ref cat:row (+ -2 catalog:bastab-id-pos))
			      1 (itypes domains:init-cols)))))

    (define (open-database filename mutable)
      (let* ((lldb (open-base filename mutable))
	     (base:catalog
	      (and lldb (base:open-table lldb base:catalog-id
					 1 (itypes catalog:init-cols))))
	     (base:domains
	      (and base:catalog (base:catalog->domains lldb base:catalog))))
	(cond
	 ((not lldb) #f)
	 ((not base:domains) (close-base lldb) #f)
	 (else (init-database
		filename mutable lldb base:catalog base:domains #f)))))

    (define (init-database rdms:filename mutable lldb
			   base:catalog base:domains rdms:catalog)

      (define write-database
	(and mutable
	     (lambda (filename)
	       (let ((ans (write-base lldb filename)))
		 (and ans (set! rdms:filename filename))
		 ans))))

      (define sync-database
	(and mutable
	     (lambda ()
	       (sync-base lldb))))

      (define (solidify-database)
	(cond ((sync-base lldb)
	       (set! mutable #f)
	       (set! sync-database #f)
	       (set! write-database #f)
	       (set! delete-table #f)
	       (set! create-table #f)
	       #t)
	      (else #f)))

      (define (close-database)
	(define ans (close-base lldb))
	(cond (ans (set! rdms:filename #f)
		   (set! base:catalog #f)
		   (set! base:domains #f)
		   (set! rdms:catalog #f)))
	ans)

      (define row-ref (lambda (row pos) (list-ref row (+ -2 pos))))
      (define row-eval (lambda (row pos)
			 (let ((ans (list-ref row (+ -2 pos))))
			   (and ans (slib:eval ans)))))

      (define (open-table table-name writable)
	(define cat:row (cat:get-row base:catalog table-name))
	(cond
	 ((not cat:row)
	  (slib:warn "can't open-table:" table-name)
	  #f)
	 ((and writable (not mutable))
	  (slib:warn "can't open-table for writing:" table-name)
	  #f)
	 (else
	  (let ((column-limit (row-ref cat:row catalog:column-limit-pos))
		(desc-table
		 (base:open-table
		  lldb
		  (row-ref (cat:get-row
			    base:catalog
			    (row-ref cat:row catalog:coltab-name-pos))
			   catalog:bastab-id-pos)
		  1 (itypes columns:init-cols)))
		(base-table #f)
		(base:get #f)
		(primary-limit 1)
		(column-name-alist '())
		(column-foreign-list '())
		(column-foreign-check-list '())
		(column-domain-list '())
		(column-type-list '())
		(export-alist '())
		(cirs '())
		(dirs '())
		(list->key #f)
		(key->list #f))

	    (or desc-table
		(slib:error "descriptor table doesn't exist for:" table-name))
	    (do ((ci column-limit (+ -1 ci)))
		((zero? ci))
	      (let* ((des:row (des:get-row desc-table ci))
		     (column-name (row-ref des:row columns:name-pos))
		     (column-domain (row-ref des:row columns:domain-name-pos)))
		(set! cirs
		      (cons (row-eval des:row columns:integrity-rule-pos) cirs))
		(set! column-name-alist
		      (cons (cons column-name ci) column-name-alist))
		(cond
		 (column-domain
		  (let ((dom:row (dom:get-row base:domains column-domain)))
		    (set! dirs
			  (cons (row-eval dom:row domains:integrity-rule-pos)
				dirs))
		    (set! column-type-list
			  (cons (row-ref dom:row domains:type-id-pos)
				column-type-list))
		    (set! column-domain-list
			  (cons column-domain column-domain-list))
		    (set! column-foreign-list
			  (cons (let ((foreign-name
				       (row-ref dom:row domains:foreign-pos)))
				  (and (not (eq? foreign-name table-name))
				       foreign-name))
				column-foreign-list))
		    (set! column-foreign-check-list
			  (cons
			   (let ((foreign-name (car column-foreign-list)))
			     (and foreign-name
				  (let* ((tab (open-table foreign-name #f))
					 (p? (and tab (tab 'get 1))))
				    (cond
				     ((not tab)
				      (slib:error "foreign key table missing for:"
						  foreign-name))
				     ((not (= (tab 'primary-limit) 1))
				      (slib:error "foreign key table wrong type:"
						  foreign-name))
				     (else p?)))))
			   column-foreign-check-list))))
		 (else
		  (slib:error "missing domain for column:" ci column-name)))
		(cond
		 ((row-ref des:row columns:primary?-pos)
		  (set! primary-limit (max primary-limit ci))
		  (cond
		   ((base:supported-key-type? (car column-type-list)))
		   (else (slib:error "key type not supported by base tables:"
				     (car column-type-list)))))
		 ((base:supported-type? (car column-type-list)))
		 (else (slib:error "type not supported by base tables:"
				   (car column-type-list))))))
	    (set! base-table
		  (base:open-table lldb (row-ref cat:row catalog:bastab-id-pos)
				   primary-limit column-type-list))
	    (set! base:get ((basic 'make-getter) primary-limit column-type-list))
	    (set! list->key
		  ((basic 'make-list-keyifier) primary-limit column-type-list))
	    (set! key->list
		  ((basic 'make-key->list) primary-limit column-type-list))
	    (letrec ((export-method
		      (lambda (name proc)
			(set! export-alist
			      (cons (cons name proc) export-alist))))
		     (ckey:retrieve ;ckey gets whole row (assumes exists)
		      (if (= primary-limit column-limit) key->list
			  (lambda (ckey) (append (key->list ckey)
						 (base:get base-table ckey)))))
		     (accumulate-over-table
		      (lambda (operation)
			(lambda mkeys (base:map-primary-key
				       base-table operation
				       primary-limit column-type-list
				       (norm-mkeys mkeys)))))
		     (norm-mkeys
		      (lambda (mkeys)
			(define mlim (length mkeys))
			(cond ((> mlim primary-limit)
			       (slib:error "too many keys:" mkeys))
			      ((= mlim primary-limit) mkeys)
			      (else
			       (append mkeys
				       (do ((k (- primary-limit mlim) (+ -1 k))
					    (result '() (cons #f result)))
					   ((<= k 0) result))))))))
	      (export-method
	       'row:retrieve
	       (if (= primary-limit column-limit)
		   (lambda keys
		     (let ((ckey (list->key keys)))
		       (and (present? base-table ckey) keys)))
		   (lambda keys
		     (let ((vals (base:get base-table (list->key keys))))
		       (and vals (append keys vals))))))
	      (export-method 'row:retrieve*
			     (accumulate-over-table
			      (if (= primary-limit column-limit) key->list
				  ckey:retrieve)))
	      (export-method
	       'for-each-row
	       (let ((r (if (= primary-limit column-limit) key->list
			    ckey:retrieve)))
		 (lambda (proc . mkeys)
		   (base:for-each-primary-key
		    base-table (lambda (ckey) (proc (r ckey)))
		    primary-limit column-type-list
		    (norm-mkeys mkeys)))))
	      (and base:ordered-for-each-key
		   (export-method
		    'for-each-row-in-order
		    (let ((r (if (= primary-limit column-limit) key->list
				 ckey:retrieve)))
		      (lambda (proc . mkeys)
			(base:ordered-for-each-key
			 base-table (lambda (ckey) (proc (r ckey)))
			 primary-limit column-type-list
			 (norm-mkeys mkeys))))))
	      (cond
	       ((and mutable writable)
		(letrec
		    ((combine-primary-keys
		      (cond
		       ((and (= primary-limit column-limit)
			     (> primary-limit 0))
			list->key)
		       ((eq? list->key car) list->key)
		       (else
			(case primary-limit
			  ((1) (let ((keyify-1 ((base 'make-keyifier-1)
						(car column-type-list))))
				 (lambda (row) (keyify-1 (car row)))))
			  ((2) (lambda (row)
				 (list->key (list (car row) (cadr row)))))
			  ((3) (lambda (row)
				 (list->key (list (car row) (cadr row)
						  (caddr row)))))
			  (else (lambda (row)
				  (do ((rw row (cdr rw))
				       (nrw '() (cons (car rw) nrw))
				       (pl (+ -1 primary-limit) (+ -1 pl)))
				      ((negative? pl)
				       (list->key (reverse nrw))))))))))
		     (uir (row-eval cat:row catalog:integrity-rule-pos))
		     (check-rules
		      (lambda (row)
			(if (= column-limit (length row)) #t
			    (slib:error "bad row length:" row))
			(for-each
			 (lambda (cir dir value column-name column-domain
				      foreign)
			   (cond
			    ((and dir (not (dir value)))
			     (slib:error "violated domain integrity rule:"
					 table-name column-name
					 column-domain value))
			    ((and cir (not (cir value)))
			     (slib:error "violated column integrity rule:"
					 table-name column-name value))
			    ((and foreign (not (foreign value)))
			     (slib:error "foreign key missing:"
					 table-name column-name value))))
			 cirs dirs row column-name-alist column-domain-list
			 column-foreign-check-list)
			(cond ((and uir (not (uir row)))
			       (slib:error "violated user integrity rule:"
					   row)))))
		     (putter
		      ((basic 'make-putter) primary-limit column-type-list))
		     (row:insert
		      (lambda (row)
			(check-rules row)
			(let ((ckey (combine-primary-keys row)))
			  (if (present? base-table ckey)
			      (slib:error 'row:insert "row present:" row))
			  (putter base-table ckey
				  (list-tail row primary-limit)))))
		     (row:update
		      (lambda (row)
			(check-rules row)
			(putter base-table (combine-primary-keys row)
				(list-tail row primary-limit)))))

		  (export-method 'row:insert row:insert)
		  (export-method 'row:insert*
				 (lambda (rows) (for-each row:insert rows)))
		  (export-method 'row:update row:update)
		  (export-method 'row:update*
				 (lambda (rows) (for-each row:update rows))))

		(letrec ((base:delete (basic 'delete))
			 (base:delete* (basic 'delete*))
			 (ckey:remove (lambda (ckey)
					(let ((r (ckey:retrieve ckey)))
					  (and r (base:delete base-table ckey))
					  r))))
		  (export-method 'row:remove
				 (lambda keys
				   (let ((ckey (list->key keys)))
				     (and (present? base-table ckey)
					  (ckey:remove ckey)))))
		  (export-method 'row:delete
				 (lambda keys
				   (base:delete base-table (list->key keys))))
		  (export-method 'row:remove*
				 (accumulate-over-table ckey:remove))
		  (export-method 'row:delete*
				 (lambda mkeys
				   (base:delete* base-table
						 primary-limit column-type-list
						 (norm-mkeys mkeys))))
		  (export-method 'close-table
				 (lambda () (set! base-table #f)
					 (set! desc-table #f)
					 (set! export-alist #f))))))

	      (export-method 'column-names (map car column-name-alist))
	      (export-method 'column-foreigns column-foreign-list)
	      (export-method 'column-domains column-domain-list)
	      (export-method 'column-types column-type-list)
	      (export-method 'primary-limit primary-limit)

	      (let ((translate-column
		     (lambda (column)
		       (let ((colp (assq column column-name-alist)))
			 (cond (colp (cdr colp))
			       ((and (integer? column)
				     (<= 1 column column-limit))
				column)
			       (else (slib:error "column not in table:"
						 column table-name)))))))
		(lambda args
		  (cond
		   ((null? args) #f)
		   ((and base:make-nexter (eq? 'isam-next (car args)))
		    (base:make-nexter
		     base-table primary-limit column-type-list
		     (if (null? (cdr args))
			 primary-limit
			 (translate-column (cadr args)))))
		   ((and base:make-prever (eq? 'isam-prev (car args)))
		    (base:make-prever
		     base-table primary-limit column-type-list
		     (if (null? (cdr args))
			 primary-limit
			 (translate-column (cadr args)))))
		   ((null? (cdr args))
		    (let ((pp (assq (car args) export-alist)))
		      (and pp (cdr pp))))
		   ((not (null? (cddr args)))
		    (slib:error "too many arguments to methods:" args))
		   (else
		    (let ((ci (translate-column (cadr args))))
		      (cond
		       ((<= ci primary-limit) ;primary-key?
			(case (car args)
			  ((get) (lambda gkeys
				   (and (present? base-table (list->key gkeys))
					(list-ref gkeys (+ -1 ci)))))
			  ((get*) (let ((key-extractor
					 ((base 'make-key-extractor)
					  primary-limit column-type-list ci)))
				    (lambda mkeys
				      (base:map-primary-key
				       base-table
				       key-extractor
				       primary-limit column-type-list
				       (norm-mkeys mkeys)))))
			  (else #f)))
		       (else
			(let ((index (- ci (+ primary-limit 1)))
			      (get-1 (base 'make-getter-1)))
			  (cond
			   (get-1
			    (set! get-1
				  (get-1 primary-limit column-type-list ci))
			    (case (car args)
			      ((get) (lambda keys
				       (get-1 base-table (list->key keys))))
			      ((get*) (lambda mkeys
					(base:map-primary-key
					 base-table
					 (lambda (ckey) (get-1 base-table ckey))
					 primary-limit column-type-list
					 (norm-mkeys mkeys))))))
			   (else
			    (case (car args)
			      ((get) (lambda keys
				       (let ((row (base:get base-table
							    (list->key keys))))
					 (and row (list-ref row index)))))
			      ((get*) (lambda mkeys
					(base:map-primary-key
					 base-table
					 (lambda (ckey)
					   (list-ref (base:get base-table ckey)
						     index))
					 primary-limit column-type-list
					 (norm-mkeys mkeys))))
			      (else #f)))))))))))))))))

      (define create-table
	(and
	 mutable
	 (lambda (table-name . desc)
	   (or rdms:catalog
	       (set! rdms:catalog (open-table rdms:catalog-name #t)))
	   (cond
	    ((table-exists? table-name)
	     (slib:error "table already exists:" table-name) #f)
	    ((null? desc)
	     (let ((colt-id
		    (base:make-table lldb 1 (itypes columns:init-cols))))
	       ((rdms:catalog 'row:insert)
		(list table-name
		      (length columns:init-cols)
		      ((rdms:catalog 'get 'coltab-name)
		       rdms:columns-name)
		      colt-id
		      #f
		      #f)))
	     (open-table table-name #t))
	    ((null? (cdr desc))
	     (set! desc (car desc))
	     (let ((colt-id ((rdms:catalog 'get 'bastab-id) desc)))
	       (cond
		(colt-id
		 (let ((coltable (open-table desc #f))
		       (types '())
		       (prilimit 0)
		       (colimit 0)
		       (colerr #f))
		   (for-each (lambda (n p d)
			       (if (number? n) (set! colimit (max colimit n))
				   (set! colerr #t))
			       (if p (set! prilimit (+ 1 prilimit)) #f)
			       (set! types
				     (cons (dom:get-row base:domains d)
					   types)))
			     ((coltable 'get* 'column-number))
			     ((coltable 'get* 'primary-key?))
			     ((coltable 'get* 'domain-name)))
		   (cond (colerr (slib:error "some column lacks a number.") #f)
			 ((or (< prilimit 1)
			      (and (> prilimit 4)
				   (not (= prilimit colimit))))
			  (slib:error "unreasonable number of primary keys:"
				      prilimit))
			 (else
			  ((rdms:catalog 'row:insert)
			   (list table-name colimit desc
				 (base:make-table lldb prilimit types) #f #f))
			  (open-table table-name #t)))))
		(else
		 (slib:error "table descriptor not found for:" desc) #f))))
	    (else (slib:error 'create-table "too many args:"
			      (cons table-name desc))
		  #f)))))

      (define (table-exists? table-name)
	(present? base:catalog (cat:keyify-1 table-name)))

      (define delete-table
	(and mutable
	     (lambda (table-name)
	       (or rdms:catalog (set! rdms:catalog (open-table rdms:catalog-name #t)))
	       (and (table-exists? table-name)
		    (let ((table (open-table table-name #t))
			  (row ((rdms:catalog 'row:remove) table-name)))
		      (and row (base:kill-table
				lldb
				(list-ref row (+ -1 catalog:bastab-id-pos))
				(table 'primary-limit)
				(table 'column-type-list))
			   row))))))

      (lambda (operation-name)
	(case operation-name
	  ((close-database) close-database)
	  ((write-database) write-database)
	  ((sync-database) sync-database)
	  ((solidify-database) solidify-database)
	  ((open-table) open-table)
	  ((delete-table) delete-table)
	  ((create-table) create-table)
	  ((table-exists?) table-exists?)
	  ((filename) rdms:filename)
	  (else #f)))
      )
    (lambda (operation-name)
      (case operation-name
	((create-database) create-database)
	((open-database) open-database)
	(else #f)))
    ))
