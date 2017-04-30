; "mwsynrul.scm" Compiler for a <transformer spec>.
; Copyright 1992 William Clinger
;
; Permission to copy this software, in whole or in part, to use this
; software for any lawful purpose, and to redistribute this software
; is granted subject to the restriction that all copies made of this
; software must include this copyright notice in full.
;
; I also request that you send me a copy of any improvements that you
; make to this software so that they may be incorporated within it to
; the benefit of the Scheme community.

;;;; Compiler for a <transformer spec>.

;;; The input is a <transformer spec> and a syntactic environment.
;;; Syntactic environments are described in another file.

;;; Transormer specs are in slib.texi.

(define mw:pattern-variable-flag (list 'v))
(define mw:ellipsis-pattern-flag (list 'e))
(define mw:ellipsis-template-flag mw:ellipsis-pattern-flag)

(define (mw:make-patternvar v rank)
  (vector mw:pattern-variable-flag v rank))
(define (mw:make-ellipsis-pattern P vars)
  (vector mw:ellipsis-pattern-flag P vars))
(define (mw:make-ellipsis-template T vars)
  (vector mw:ellipsis-template-flag T vars))

(define (mw:patternvar? x)
  (and (vector? x)
       (= (vector-length x) 3)
       (eq? (vector-ref x 0) mw:pattern-variable-flag)))

(define (mw:ellipsis-pattern? x)
  (and (vector? x)
       (= (vector-length x) 3)
       (eq? (vector-ref x 0) mw:ellipsis-pattern-flag)))

(define (mw:ellipsis-template? x)
  (and (vector? x)
       (= (vector-length x) 3)
       (eq? (vector-ref x 0) mw:ellipsis-template-flag)))

(define (mw:patternvar-name V) (vector-ref V 1))
(define (mw:patternvar-rank V) (vector-ref V 2))
(define (mw:ellipsis-pattern P) (vector-ref P 1))
(define (mw:ellipsis-pattern-vars P) (vector-ref P 2))
(define (mw:ellipsis-template T) (vector-ref T 1))
(define (mw:ellipsis-template-vars T) (vector-ref T 2))

(define (mw:pattern-variable v vars)
  (cond ((null? vars) #f)
	((eq? v (mw:patternvar-name (car vars)))
	 (car vars))
	(else (mw:pattern-variable v (cdr vars)))))

; Given a <transformer spec> and a syntactic environment,
; returns a macro denotation.
;
; A macro denotation is of the form
;
;    (macro (<rule> ...) env)
;
; where each <rule> has been compiled as described above.

(define (mw:compile-transformer-spec spec env)
  (if (and (> (mw:safe-length spec) 1)
	   (eq? (mw:syntax-lookup env (car spec))
		mw:denote-of-syntax-rules))
      (let ((literals (cadr spec))
	    (rules (cddr spec)))
	(if (or (not (list? literals))
		(not (mw:every (lambda (rule)
			      (and (= (mw:safe-length rule) 2)
				   (pair? (car rule))))
			      rules)))
	    (mw:error "Malformed syntax-rules" spec))
	(list 'macro
	      (map (lambda (rule)
		     (mw:compile-rule rule literals env))
		   rules)
	      env))
      (mw:error "Malformed syntax-rules" spec)))

(define (mw:compile-rule rule literals env)
  (mw:compile-pattern (cdr (car rule))
		     literals
		     env
		     (lambda (compiled-rule patternvars)
		       ; should check uniqueness of pattern variables here!!!!!
		       (cons compiled-rule
			     (mw:compile-template
			      (cadr rule)
			      patternvars
			      env)))))

(define (mw:compile-pattern P literals env k)
  (define (loop P vars rank k)
    (cond ((symbol? P)
	   (if (memq P literals)
	       (k P vars)
	       (let ((var (mw:make-patternvar P rank)))
		 (k var (cons var vars)))))
	  ((null? P) (k '() vars))
	  ((pair? P)
	   (if (and (pair? (cdr P))
		    (symbol? (cadr P))
		    (eq? (mw:syntax-lookup env (cadr P))
			 mw:denote-of-...))
	       (if (null? (cddr P))
		   (loop (car P)
			 '()
			 (+ rank 1)
			 (lambda (P vars1)
			   (k (mw:make-ellipsis-pattern P vars1)
			      (mw:union vars1 vars))))
		   (mw:error "Malformed pattern" P))
	       (loop (car P)
		     vars
		     rank
		     (lambda (P1 vars)
		       (loop (cdr P)
			     vars
			     rank
			     (lambda (P2 vars)
			       (k (cons P1 P2) vars)))))))
	  ((vector? P)
	   (loop (vector->list P)
		 vars
		 rank
		 (lambda (P vars)
		   (k (vector P) vars))))
	  (else (k P vars))))
  (loop P '() 0 k))

(define (mw:compile-template T vars env)

  (define (loop T inserted referenced rank escaped? k)
    (cond ((symbol? T)
	   (let ((x (mw:pattern-variable T vars)))
	     (if x
		 (if (>= rank (mw:patternvar-rank x))
		     (k x inserted (cons x referenced))
		     (mw:error
		      "Too few ellipses follow pattern variable in template"
		      (mw:patternvar-name x)))
		 (k T (cons T inserted) referenced))))
	  ((null? T) (k '() inserted referenced))
	  ((pair? T)
	   (cond ((and (not escaped?)
		       (symbol? (car T))
		       (eq? (mw:syntax-lookup env (car T))
			    mw:denote-of-:::)
		       (pair? (cdr T))
		       (null? (cddr T)))
		  (loop (cadr T) inserted referenced rank #t k))
		 ((and (not escaped?)
		       (pair? (cdr T))
		       (symbol? (cadr T))
		       (eq? (mw:syntax-lookup env (cadr T))
			    mw:denote-of-...))
		  (loop1 T inserted referenced rank escaped? k))
		 (else
		  (loop (car T)
			inserted
			referenced
			rank
			escaped?
			(lambda (T1 inserted referenced)
			  (loop (cdr T)
				inserted
				referenced
				rank
				escaped?
				(lambda (T2 inserted referenced)
				  (k (cons T1 T2) inserted referenced))))))))
	  ((vector? T)
	   (loop (vector->list T)
		 inserted
		 referenced
		 rank
		 escaped?
		 (lambda (T inserted referenced)
		   (k (vector T) inserted referenced))))
	  (else (k T inserted referenced))))

  (define (loop1 T inserted referenced rank escaped? k)
    (loop (car T)
	  inserted
	  '()
	  (+ rank 1)
	  escaped?
	  (lambda (T1 inserted referenced1)
	    (loop (cddr T)
		  inserted
		  (append referenced1 referenced)
		  rank
		  escaped?
		  (lambda (T2 inserted referenced)
		    (k (cons (mw:make-ellipsis-template
			      T1
			      (mw:remove-if-not
			       (lambda (var) (> (mw:patternvar-rank var)
						rank))
			       referenced1))
			     T2)
		       inserted
		       referenced))))))

  (loop T
	'()
	'()
	0
	#f
	(lambda (T inserted referenced)
	  (list T inserted))))

; The pattern matcher.
;
; Given an input, a pattern, and two syntactic environments,
; returns a pattern variable environment (represented as an alist)
; if the input matches the pattern, otherwise returns #f.

(define mw:empty-pattern-variable-environment
  (list (mw:make-patternvar (string->symbol "") 0)))

(define (mw:match F P env-def env-use)

  (define (match F P answer rank)
    (cond ((null? P)
	   (and (null? F) answer))
	  ((pair? P)
	   (and (pair? F)
		(let ((answer (match (car F) (car P) answer rank)))
		  (and answer (match (cdr F) (cdr P) answer rank)))))
	  ((symbol? P)
	   (and (symbol? F)
		(mw:same-denotation? (mw:syntax-lookup env-def P)
				     (mw:syntax-lookup env-use F))
		answer))
	  ((mw:patternvar? P)
	   (cons (cons P F) answer))
	  ((mw:ellipsis-pattern? P)
	   (match1 F P answer (+ rank 1)))
	  ((vector? P)
	   (and (vector? F)
		(match (vector->list F) (vector-ref P 0) answer rank)))
	  (else (and (equal? F P) answer))))

  (define (match1 F P answer rank)
    (cond ((not (list? F)) #f)
	  ((null? F)
	   (append (map (lambda (var) (cons var '()))
			(mw:ellipsis-pattern-vars P))
		   answer))
	  (else
	   (let* ((P1 (mw:ellipsis-pattern P))
		  (answers (map (lambda (F) (match F P1 answer rank))
				F)))
	     (if (mw:every identity answers)
		 (append (map (lambda (var)
				(cons var
				      (map (lambda (answer)
					     (cdr (assq var answer)))
					   answers)))
			      (mw:ellipsis-pattern-vars P))
			 answer)
		 #f)))))

  (match F P mw:empty-pattern-variable-environment 0))

(define (mw:rewrite T alist)

  (define (rewrite T alist rank)
    (cond ((null? T) '())
	  ((pair? T)
	   ((if (mw:ellipsis-pattern? (car T))
		append
		cons)
	    (rewrite (car T) alist rank)
	    (rewrite (cdr T) alist rank)))
	  ((symbol? T) (cdr (assq T alist)))
	  ((mw:patternvar? T) (cdr (assq T alist)))
	  ((mw:ellipsis-template? T)
	   (rewrite1 T alist (+ rank 1)))
	  ((vector? T)
	   (list->vector (rewrite (vector-ref T 0) alist rank)))
	  (else T)))

  (define (rewrite1 T alist rank)
    (let* ((T1 (mw:ellipsis-template T))
	   (vars (mw:ellipsis-template-vars T))
	   (rows (map (lambda (var) (cdr (assq var alist)))
		      vars)))
      (map (lambda (alist) (rewrite T1 alist rank))
	   (make-columns vars rows alist))))

  (define (make-columns vars rows alist)
    (define (loop rows)
      (if (null? (car rows))
	  '()
	  (cons (append (map (lambda (var row)
			       (cons var (car row)))
			     vars
			     rows)
			alist)
		(loop (map cdr rows)))))
    (if (or (null? (cdr rows))
	    (apply = (map length rows)))
	(loop rows)
	(mw:error "Use of macro is not consistent with definition"
		 vars
		 rows)))

  (rewrite T alist 0))

; Given a use of a macro, the syntactic environment of the use,
; and a continuation that expects a transcribed expression and
; a new environment in which to continue expansion,
; does the right thing.

(define (mw:transcribe exp env-use k)
  (let* ((m (mw:syntax-lookup env-use (car exp)))
	 (rules (macwork:rules m))
	 (env-def (macwork:env m))
	 (F (cdr exp)))
    (define (loop rules)
      (if (null? rules)
	  (mw:error "Use of macro does not match definition" exp)
	  (let* ((rule (car rules))
		 (pattern (car rule))
		 (alist (mw:match F pattern env-def env-use)))
	    (if alist
		(let* ((template (cadr rule))
		       (inserted (caddr rule))
		       (alist2 (mw:rename-vars inserted))
		       (newexp (mw:rewrite template (append alist2 alist))))
		  (k newexp
		     (mw:syntax-alias env-use alist2 env-def)))
		(loop (cdr rules))))))
    (loop rules)))
