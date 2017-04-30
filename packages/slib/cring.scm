;;;"cring.scm" Extend Scheme numerics to any commutative ring.
;Copyright (C) 1997, 1998, 2001 Aubrey Jaffer
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

(require 'common-list-functions)
(require 'relational-database)
(require 'databases)
(require 'sort)

(define number^ expt)
(define number* *)
(define number+ +)
(define number- -)
(define number/ /)
(define number0? zero?)
(define (zero? x) (and (number? x) (number0? x)))
;;(define (sign x) (if (positive? x) 1 (if (negative? x) -1 0)))

(define cring:db (create-database #f 'alist-table))
;@
(define (make-ruleset . rules)
  (define name #f)
  (cond ((and (not (null? rules)) (symbol? (car rules)))
	 (set! name (car rules))
	 (set! rules (cdr rules)))
	(else (set! name (gentemp))))
  (define-tables cring:db
    (list name
	  '((op symbol)
	    (sub-op1 symbol)
	    (sub-op2 symbol))
	  '((reduction expression))
	  rules))
  (let ((table ((cring:db 'open-table) name #t)))
    (and table
	 (list (table 'get 'reduction)
	       (table 'row:update)
	       table))))
;@
(define *ruleset* (make-ruleset 'default))
(define (cring:define-rule . args)
  (if *ruleset*
      ((cadr *ruleset*) args)
      (slib:warn "No ruleset in *ruleset*")))
;@
(define (combined-rulesets . rulesets)
  (define name #f)
  (cond ((symbol? (car rulesets))
	 (set! name (car rulesets))
	 (set! rulesets (cdr rulesets)))
	(else (set! name (gentemp))))
  (apply make-ruleset name
	 (apply append
		(map (lambda (ruleset) (((caddr ruleset) 'row:retrieve*)))
		     rulesets))))

;;; Distribute * over + (and -)
;@
(define distribute*
  (make-ruleset
   'distribute*
   `(* + identity
       ,(lambda (exp1 exp2)
	  ;;(print 'distributing '* '+ exp1 exp2 '==>)
	  (apply + (map (lambda (trm) (* trm exp2)) (cdr exp1)))))
   `(* - identity
       ,(lambda (exp1 exp2)
	  ;;(print 'distributing '* '- exp1 exp2 '==>)
	  (apply - (map (lambda (trm) (* trm exp2)) (cdr exp1)))))))

;;; Distribute / over + (and -)
;@
(define distribute/
  (make-ruleset
   'distribute/
   `(/ + identity
       ,(lambda (exp1 exp2)
	  ;;(print 'distributing '/ '+ exp1 exp2 '==>)
	  (apply + (map (lambda (trm) (/ trm exp2)) (cdr exp1)))))
   `(/ - identity
       ,(lambda (exp1 exp2)
	  ;;(print 'distributing '/ '- exp1 exp2 '==>)
	  (apply - (map (lambda (trm) (/ trm exp2)) (cdr exp1)))))))

(define (symbol-alpha? sym)
  (char-alphabetic? (string-ref (symbol->string sym) 0)))
(define (expression-< x y)
  (cond ((and (number? x) (number? y)) (> x y))	;want negatives last
	((number? x) #t)
	((number? y) #f)
	((and (symbol? x) (symbol? y))
	 (cond ((eqv? (symbol-alpha? x) (symbol-alpha? y))
		(string<? (symbol->string x) (symbol->string y)))
	       (else (symbol-alpha? x))))
	((symbol? x) #t)
	((symbol? y) #f)
	((null? x) #t)
	((null? y) #f)
	((expression-< (car x) (car y)) #t)
	((expression-< (car y) (car x)) #f)
	(else (expression-< (cdr x) (cdr y)))))
(define (expression-sort seq) (sort! seq expression-<))

(define is-term-op? (lambda (term op) (and (pair? term) (eq? op (car term)))))

;; To convert to CR internal form, NUMBER-op all the `numbers' in the
;; argument list and remove them from the argument list.  Collect the
;; remaining arguments into equivalence classes, keeping track of the
;; number of arguments in each class.  The returned list is thus:
;; (<numeric> (<expression1> . <exp1>) ...)

;;; Converts * argument list to CR internal form
(define (cr*-args->fcts args)
  ;;(print (cons 'cr*-args->fcts args) '==>)
  (let loop ((args args) (pow 1) (nums 1) (arg_exps '()))
    ;;(print (list 'loop args pow nums denoms arg_exps) '==>)
    (cond ((null? args) (cons nums arg_exps))
	  ((number? (car args))
	   (let ((num^pow (number^ (car args) (abs pow))))
	     (if (negative? pow)
		 (loop (cdr args) pow (number/ (number* num^pow nums))
		       arg_exps)
		 (loop (cdr args) pow (number* num^pow nums) arg_exps))))
	  ;; Associative Rule
	  ((is-term-op? (car args) '*) (loop (append (cdar args) (cdr args))
					     pow nums arg_exps))
	  ;; Do singlet -
	  ((and (is-term-op? (car args) '-) (= 2 (length (car args))))
	   ;;(print 'got-here (car args))
	   (set! arg_exps (loop (cdar args) pow (number- nums) arg_exps))
	   (loop (cdr args) pow
		 (car arg_exps)
		 (cdr arg_exps)))
	  ((and (is-term-op? (car args) '/) (= 2 (length (car args))))
	   ;; Do singlet /
	   ;;(print 'got-here=cr+ (car args))
	   (set! arg_exps (loop (cdar args) (number- pow) nums arg_exps))
	   (loop (cdr args) pow
		 (car arg_exps)
		 (cdr arg_exps)))
	  ((is-term-op? (car args) '/)
	   ;; Do multi-arg /
	   ;;(print 'doing '/ (cddar args) (number- pow))
	   (set! arg_exps
		 (loop (cddar args) (number- pow) nums arg_exps))
	   ;;(print 'finishing '/ (cons (cadar args) (cdr args)) pow)
	   (loop (cons (cadar args) (cdr args))
		 pow
		 (car arg_exps)
		 (cdr arg_exps)))
	  ;; Pull out numeric exponents as powers
	  ((and (is-term-op? (car args) '^)
		(= 3 (length (car args)))
		(number? (caddar args)))
	   (set! arg_exps (loop (list (cadar args))
				(number* pow (caddar args))
				nums
				arg_exps))
	   (loop (cdr args) pow (car arg_exps) (cdr arg_exps)))
	  ;; combine with same terms
	  ((assoc (car args) arg_exps)
	   => (lambda (pair) (set-cdr! pair (number+ pow (cdr pair)))
		      (loop (cdr args) pow nums arg_exps)))
	  ;; Add new term to arg_exps
	  (else (loop (cdr args) pow nums
		      (cons (cons (car args) pow) arg_exps))))))

;;; Converts + argument list to CR internal form
(define (cr+-args->trms args)
  (let loop ((args args) (cof 1) (numbers 0) (arg_exps '()))
    (cond ((null? args) (cons numbers arg_exps))
	  ((number? (car args))
	   (loop (cdr args)
		 cof
		 (number+ (number* (car args) cof) numbers)
		 arg_exps))
	  ;; Associative Rule
	  ((is-term-op? (car args) '+) (loop (append (cdar args) (cdr args))
					     cof
					     numbers
					     arg_exps))
	  ;; Idempotent singlet *
	  ((and (is-term-op? (car args) '*) (= 2 (length (car args))))
	   (loop (cons (cadar args) (cdr args))
		 cof
		 numbers
		 arg_exps))
	  ((and (is-term-op? (car args) '-) (= 2 (length (car args))))
	   ;; Do singlet -
	   (set! arg_exps (loop (cdar args) (number- cof) numbers arg_exps))
	   (loop (cdr args) cof (car arg_exps) (cdr arg_exps)))
	  ;; Pull out numeric factors as coefficients
	  ((and (is-term-op? (car args) '*) (some number? (cdar args)))
	   ;;(print 'got-here (car args) '=> (cons '* (remove-if number? (cdar args))))
	   (set! arg_exps
		 (loop (list (cons '* (remove-if number? (cdar args))))
		       (apply number* cof (remove-if-not number? (cdar args)))
		       numbers
		       arg_exps))
	   (loop (cdr args) cof (car arg_exps) (cdr arg_exps)))
	  ((is-term-op? (car args) '-)
	   ;; Do multi-arg -
	   (set! arg_exps (loop (cddar args) (number- cof) numbers arg_exps))
	   (loop (cons (cadar args) (cdr args))
		 cof
		 (car arg_exps)
		 (cdr arg_exps)))
	  ;; combine with same terms
	  ((assoc (car args) arg_exps)
	   => (lambda (pair) (set-cdr! pair (number+ cof (cdr pair)))
		      (loop (cdr args) cof numbers arg_exps)))
	  ;; Add new term to arg_exps
	  (else (loop (cdr args) cof numbers
		      (cons (cons (car args) cof) arg_exps))))))

;;; Converts + or * internal form to Scheme expression
(define (cr-terms->form op ident inv-op higher-op res_cofs)
  (define (negative-cof? fct_cof)
    (negative? (cdr fct_cof)))
  (define (finish exprs)
    (if (null? exprs) ident
	(if (null? (cdr exprs))
	    (car exprs)
	    (cons op exprs))))
  (define (do-terms sign fct_cofs)
    (expression-sort
     (map (lambda (fct_cof)
	    (define cof (number* sign (cdr fct_cof)))
	    (cond ((eqv? 1 cof) (car fct_cof))
		  ((number? (car fct_cof)) (number* cof (car fct_cof)))
		  ((is-term-op? (car fct_cof) higher-op)
		   (if (eq? higher-op '^)
		       (list '^ (cadar fct_cof) (* cof (caddar fct_cof)))
		       (cons higher-op (cons cof (cdar fct_cof)))))
		  ((eqv? -1 cof) (list inv-op (car fct_cof)))
		  (else (list higher-op (car fct_cof) cof))))
	  fct_cofs)))
  (let* ((all_cofs (remove-if (lambda (fct_cof)
				(or (zero? (cdr fct_cof))
				    (eqv? ident (car fct_cof))))
			      res_cofs))
	 (cofs (map cdr all_cofs))
	 (some-positive? (some positive? cofs)))
    ;;(print op 'positive? some-positive? 'negative? (some negative? cofs) all_cofs)
    (cond ((and some-positive? (some negative? cofs))
	   (append (list inv-op
			 (finish (do-terms
				  1 (remove-if negative-cof? all_cofs))))
		   (do-terms -1 (remove-if-not negative-cof? all_cofs))))
	  (some-positive? (finish (do-terms 1 all_cofs)))
	  ((not (some negative? cofs)) ident)
	  (else (list inv-op (finish (do-terms -1 all_cofs)))))))

(define (* . args)
  (cond
   ((null? args) 1)
   ;;This next line is commented out so ^ will collapse numerical expressions.
   ;;((null? (cdr args)) (car args))
   (else
    (let ((in (cr*-args->fcts args)))
      (cond
       ((zero? (car in)) 0)
       (else
	(if (null? (cdr in))
	    (set-cdr! in (list (cons 1 1))))
	(let* ((num #f)
	       (ans (cr-terms->form
		     '* 1 '/ '^
		     (apply
		      (lambda (numeric red_cofs res_cofs)
			(set! num numeric)
			(append
			 ;;(list (cons (abs numeric) 1))
			 red_cofs
			 res_cofs))
		      (cr1 '* number* '^ '/ (car in) (cdr in))))))
	  (cond ((number0? (+ -1 num)) ans)
		((number? ans) (number* num ans))
		((number0? (+ 1 num))
		 (if (and (list? ans) (= 2 (length ans)) (eq? '- (car ans)))
		     (cadr ans)
		     (list '- ans)))
		((not (pair? ans)) (list '* num ans))
		(else
		 (case (car ans)
		   ((*) (append (list '* num) (cdr ans)))
		   ((+) (apply + (map (lambda (mon) (* num mon)) (cdr ans))))
		   ((-) (apply - (map (lambda (mon) (* num mon)) (cdr ans))))
		   (else (list '* num ans))))))))))))

(define (+ . args)
  (cond ((null? args) 0)
	;;((null? (cdr args)) (car args))
	(else
	 (let ((in (cr+-args->trms args)))
	   (if (null? (cdr in))
	       (car in)
	       (cr-terms->form
		'+ 0 '- '*
		(apply (lambda (numeric red_cofs res_cofs)
			 (append
			  (list (if (and (number? numeric)
					 (negative? numeric))
				    (cons (abs numeric) -1)
				    (cons numeric 1)))
			  red_cofs
			  res_cofs))
		       (cr1 '+ number+ '* '- (car in) (cdr in)))))))))

(define (- arg1 . args)
  (if (null? args)
      (if (number? arg1) (number- arg1)
	  (* -1 arg1)			;(list '- arg1)
	  )
      (+ arg1 (* -1 (apply + args)))))

;;(print `(/ ,arg1 ,@args) '=> )
(define (/ arg1 . args)
  (if (null? args)
      (^ arg1 -1)
      (* arg1 (^ (apply * args) -1))))

(define (^ arg1 arg2)
  (cond ((and (number? arg2) (integer? arg2))
	 (* (list '^ arg1 arg2)))
	(else (list '^ arg1 arg2))))

;; TRY-EACH-PAIR-ONCE algorithm.  I think this does the minimum
;; number of rule lookups given no information about how to sort
;; terms.

;; Pick equivalence classes one at a time and move them into the
;; result set of equivalence classes by searching for rules to
;; multiply an element of the chosen class by itself (if multiple) and
;; the element of each class already in the result group.  Each
;; (multiplicative) term resulting from rule application would be put
;; in the result class, if that class exists; or put in an argument
;; class if not.

(define (cr1 op number-op hop inv-op numeric in)
  (define red_pows '())
  (define res_pows '())
  (define (cring:apply-rule->terms exp1 exp2) ;(display op)
    (let ((ans (cring:apply-rule op exp1 exp2)))
      (cond ((not ans) #f)
	    ((number? ans) (list ans))
	    (else (list (cons ans 1))))))
  (define (cring:apply-inv-rule->terms exp1 exp2) ;(display inv-op)
    (let ((ans (cring:apply-rule inv-op exp1 exp2)))
      (cond ((not ans) #f)
	    ((number? ans) (list ans))
	    (else (list (cons ans 1))))))
  (let loop_arg_pow_s ((arg (caar in)) (pow (cdar in)) (arg_pows (cdr in)))
    (define (arg-loop arg_pows)
      (cond ((not (null? arg_pows))
	     (loop_arg_pow_s (caar arg_pows) (cdar arg_pows) (cdr arg_pows)))
	    (else (list numeric red_pows res_pows)))) ; Actually return!
    (define (merge-res tmp_pows multiplicity)
      (cond ((null? tmp_pows))
	    ((number? (car tmp_pows))
	     (do ((m (number+ -1 (abs multiplicity)) (number+ -1 m))
		  (n numeric (number-op n (abs (car tmp_pows)))))
		 ((negative? m) (set! numeric n)))
	     (merge-res (cdr tmp_pows) multiplicity))
	    ((or (assoc (car tmp_pows) res_pows)
		 (assoc (car tmp_pows) arg_pows))
	     => (lambda (pair)
		  (set-cdr! pair (number+
				  pow (number-op multiplicity (cdar tmp_pows))))
		  (merge-res (cdr tmp_pows) multiplicity)))
	    ((assoc (car tmp_pows) red_pows)
	     => (lambda (pair)
		  (set! arg_pows
			(cons (cons (caar tmp_pows)
				    (number+
				     (cdr pair)
				     (number* multiplicity (cdar tmp_pows))))
			      arg_pows))
		  (set-cdr! pair 0)
		  (merge-res (cdr tmp_pows) multiplicity)))
	    (else (set! arg_pows
			(cons (cons (caar tmp_pows)
				    (number* multiplicity (cdar tmp_pows)))
			      arg_pows))
		  (merge-res (cdr tmp_pows) multiplicity))))
    (define (try-fct_pow fct_pow)
      ;;(print 'try-fct_pow fct_pow op 'arg arg 'pow pow)
      (cond ((or (zero? (cdr fct_pow)) (number? (car fct_pow))) #f)
	    ((not (and (number? pow) (number? (cdr fct_pow))
		       (integer? pow)	;(integer? (cdr fct_pow))
		       ))
	     #f)
	    ;;((zero? pow) (slib:error "Don't try exp-0 terms") #f)
	    ;;((or (number? arg) (number? (car fct_pow)))
	    ;; (slib:error 'found-number arg fct_pow) #f)
	    ((and (positive? pow) (positive? (cdr fct_pow))
		  (or (cring:apply-rule->terms arg (car fct_pow))
		      (cring:apply-rule->terms (car fct_pow) arg)))
	     => (lambda (terms)
		  ;;(print op op terms)
		  (let ((multiplicity (min pow (cdr fct_pow))))
		    (set-cdr! fct_pow (number- (cdr fct_pow) multiplicity))
		    (set! pow (number- pow multiplicity))
		    (merge-res terms multiplicity))))
	    ((and (negative? pow) (negative? (cdr fct_pow))
		  (or (cring:apply-rule->terms arg (car fct_pow))
		      (cring:apply-rule->terms (car fct_pow) arg)))
	     => (lambda (terms)
		  ;;(print inv-op inv-op terms)
		  (let ((multiplicity (max pow (cdr fct_pow))))
		    (set-cdr! fct_pow (number+ (cdr fct_pow) multiplicity))
		    (set! pow (number+ pow multiplicity))
		    (merge-res terms multiplicity))))
	    ((and (positive? pow) (negative? (cdr fct_pow))
		  (cring:apply-inv-rule->terms arg (car fct_pow)))
	     => (lambda (terms)
		  ;;(print op inv-op terms)
		  (let ((multiplicity (min pow (number- (cdr fct_pow)))))
		    (set-cdr! fct_pow (number+ (cdr fct_pow) multiplicity))
		    (set! pow (number- pow multiplicity))
		    (merge-res terms multiplicity))))
	    ((and (negative? pow) (positive? (cdr fct_pow))
		  (cring:apply-inv-rule->terms (car fct_pow) arg))
	     => (lambda (terms)
		  ;;(print inv-op op terms)
		  (let ((multiplicity (max (number- pow) (cdr fct_pow))))
		    (set-cdr! fct_pow (number- (cdr fct_pow) multiplicity))
		    (set! pow (number+ pow multiplicity))
		    (merge-res terms multiplicity))))
	    (else #f)))
    ;;(print op numeric 'arg arg 'pow pow 'arg_pows arg_pows 'red_pows red_pows 'res_pows res_pows)
    ;;(trace arg-loop cring:apply-rule->terms merge-res try-fct_pow) (set! *qp-width* 333)
    (cond ((or (zero? pow) (eqv? 1 arg)) ;(number? arg) arg seems to always be 1
	   (arg-loop arg_pows))
	  ((assoc arg res_pows) => (lambda (pair)
				     (set-cdr! pair (number+ pow (cdr pair)))
				     (arg-loop arg_pows)))
	  ((and (> (abs pow) 1) (cring:apply-rule->terms arg arg))
	   => (lambda (terms)
		(merge-res terms (quotient pow 2))
		(if (odd? pow)
		    (loop_arg_pow_s arg 1 arg_pows)
		    (arg-loop arg_pows))))
	  ((or (some try-fct_pow res_pows) (some try-fct_pow arg_pows))
	   (loop_arg_pow_s arg pow arg_pows))
	  (else (set! res_pows (cons (cons arg pow) res_pows))
		(arg-loop arg_pows)))))

(define (cring:try-rule op sop1 sop2 exp1 exp2)
  (and *ruleset*
       (let ((rule ((car *ruleset*) op sop1 sop2)))
	 (and rule (rule exp1 exp2)))))

(define (cring:apply-rule op exp1 exp2)
  (and (pair? exp1)
       (or (and (pair? exp2)
		(cring:try-rule op (car exp1) (car exp2) exp1 exp2))
	   (cring:try-rule op (car exp1) 'identity exp1 exp2))))

;;(begin (trace cr-terms->form) (set! *qp-width* 333))
