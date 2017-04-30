;;; "r4rsyn.scm" R4RS syntax		-*-Scheme-*-
;;; Copyright (c) 1989-91 Massachusetts Institute of Technology
;;;
;;; This material was developed by the Scheme project at the
;;; Massachusetts Institute of Technology, Department of Electrical
;;; Engineering and Computer Science.  Permission to copy and modify
;;; this software, to redistribute either the original software or a
;;; modified version, and to use this software for any purpose is
;;; granted, subject to the following restrictions and understandings.
;;;
;;; 1. Any copy made of this software must include this copyright
;;; notice in full.
;;;
;;; 2. Users of this software agree to make their best efforts (a) to
;;; return to the MIT Scheme project any improvements or extensions
;;; that they make, so that these may be included in future releases;
;;; and (b) to inform MIT of noteworthy uses of this software.
;;;
;;; 3. All materials developed as a consequence of the use of this
;;; software shall duly acknowledge such use, in accordance with the
;;; usual standards of acknowledging credit in academic research.
;;;
;;; 4. MIT has made no warranty or representation that the operation
;;; of this software will be error-free, and MIT is under no
;;; obligation to provide any services, by way of maintenance, update,
;;; or otherwise.
;;;
;;; 5. In conjunction with products arising from the use of this
;;; material, there shall be no use of the name of the Massachusetts
;;; Institute of Technology nor of any adaptation thereof in any
;;; advertising, promotional, or sales literature without prior
;;; written consent from MIT in each case.

;;;; R4RS Syntax

(define scheme-syntactic-environment #f)

(define (initialize-scheme-syntactic-environment!)
  (set! scheme-syntactic-environment
	((compose-macrologies
	  (make-core-primitive-macrology)
	  (make-binding-macrology syntactic-binding-theory
				  'LET-SYNTAX 'LETREC-SYNTAX 'DEFINE-SYNTAX)
	  (make-binding-macrology variable-binding-theory
				  'LET 'LETREC 'DEFINE)
	  (make-r4rs-primitive-macrology)
	  (make-core-expander-macrology)
	  (make-syntax-rules-macrology))
	 root-syntactic-environment)))

;;;; Core Primitives

(define (make-core-primitive-macrology)
  (make-primitive-macrology
   (lambda (define-classifier define-compiler)

     (define-classifier 'BEGIN
       (lambda (form environment definition-environment)
	 (syntax-check '(KEYWORD * FORM) form)
	 (make-body-item (classify/subforms (cdr form)
					    environment
					    definition-environment))))

     (define-compiler 'DELAY
       (lambda (form environment)
	 (syntax-check '(KEYWORD EXPRESSION) form)
	 (output/delay
	  (compile/subexpression (cadr form)
				 environment))))

     (define-compiler 'IF
       (lambda (form environment)
	 (syntax-check '(KEYWORD EXPRESSION EXPRESSION ? EXPRESSION) form)
	 (output/conditional
	  (compile/subexpression (cadr form) environment)
	  (compile/subexpression (caddr form) environment)
	  (if (null? (cdddr form))
	      (output/unspecific)
	      (compile/subexpression (cadddr form)
				     environment)))))

     (define-compiler 'QUOTE
       (lambda (form environment)
	 environment			;ignore
	 (syntax-check '(KEYWORD DATUM) form)
	 (output/literal-quoted (strip-syntactic-closures (cadr form))))))))

;;;; Bindings

(define (make-binding-macrology binding-theory
				let-keyword letrec-keyword define-keyword)
  (make-primitive-macrology
   (lambda (define-classifier define-compiler)

     (let ((pattern/let-like
	    '(KEYWORD (* (IDENTIFIER EXPRESSION)) + FORM))
	   (compile/let-like
	    (lambda (form environment body-environment output/let)
	      ;; Force evaluation order.
	      (let ((bindings
		     (let loop
			 ((bindings
			   (map (lambda (binding)
				  (cons (car binding)
					(classify/subexpression
					 (cadr binding)
					 environment)))
				(cadr form))))
		       (if (null? bindings)
			   '()
			   (let ((binding
				  (binding-theory body-environment
						  (caar bindings)
						  (cdar bindings))))
			     (if binding
				 (cons binding (loop (cdr bindings)))
				 (loop (cdr bindings))))))))
		(output/let (map car bindings)
			    (map (lambda (binding)
				   (compile-item/expression (cdr binding)))
				 bindings)
			    (compile-item/expression
			     (classify/body (cddr form)
					    body-environment)))))))

       (define-compiler let-keyword
	 (lambda (form environment)
	   (syntax-check pattern/let-like form)
	   (compile/let-like form
			     environment
			     (internal-syntactic-environment environment)
			     output/let)))

       (define-compiler letrec-keyword
	 (lambda (form environment)
	   (syntax-check pattern/let-like form)
	   (let ((environment (internal-syntactic-environment environment)))
	     (reserve-names! (map car (cadr form)) environment)
	     (compile/let-like form
			       environment
			       environment
			       output/letrec)))))

     (define-classifier define-keyword
       (lambda (form environment definition-environment)
	 (syntax-check '(KEYWORD IDENTIFIER EXPRESSION) form)
	 (syntactic-environment/define! definition-environment
					(cadr form)
					(make-reserved-name-item))
	 (make-definition-item binding-theory
			       (cadr form)
			       (make-promise
				(lambda ()
				  (classify/subexpression
				   (caddr form)
				   environment)))))))))

;;;; Bodies

(define (classify/body forms environment)
  (let ((environment (internal-syntactic-environment environment)))
    (let forms-loop
	((forms forms)
	 (bindings '()))
      (if (null? forms)
	  (syntax-error "no expressions in body"
			"")
	  (let items-loop
	      ((items
		(item->list
		 (classify/subform (car forms)
				   environment
				   environment)))
	       (bindings bindings))
	    (cond ((null? items)
		   (forms-loop (cdr forms)
			       bindings))
		  ((definition-item? (car items))
		   (items-loop (cdr items)
			       (let ((binding
				      (bind-definition-item! environment
							     (car items))))
				 (if binding
				     (cons binding bindings)
				     bindings))))
		  (else
		   (let ((body
			  (make-body-item
			   (append items
				   (flatten-body-items
				    (classify/subforms
				     (cdr forms)
				     environment
				     environment))))))
		     (make-expression-item
		      (lambda ()
			(output/letrec
			 (map car bindings)
			 (map (lambda (binding)
				(compile-item/expression (cdr binding)))
			      bindings)
			 (compile-item/expression body))) forms)))))))))

;;;; R4RS Primitives

(define (make-r4rs-primitive-macrology)
  (make-primitive-macrology
   (lambda (define-classifier define-compiler)

     (define (transformer-keyword expander->classifier)
       (lambda (form environment definition-environment)
	 definition-environment		;ignore
	 (syntax-check '(KEYWORD EXPRESSION) form)
	 (let ((item
		(classify/subexpression (cadr form)
					scheme-syntactic-environment)))
	   (let ((transformer (base:eval (compile-item/expression item))))
	     (if (procedure? transformer)
		 (make-keyword-item
		  (expander->classifier transformer environment) item)
		 (syntax-error "transformer not a procedure"
			       transformer))))))

     (define-classifier 'TRANSFORMER
       ;; "Syntactic Closures" transformer
       (transformer-keyword sc-expander->classifier))

     (define-classifier 'ER-TRANSFORMER
       ;; "Explicit Renaming" transformer
       (transformer-keyword er-expander->classifier))

     (define-compiler 'LAMBDA
       (lambda (form environment)
	 (syntax-check '(KEYWORD R4RS-BVL + FORM) form)
	 (let ((environment (internal-syntactic-environment environment)))
	   ;; Force order -- bind names before classifying body.
	   (let ((bvl-description
		  (let ((rename
			 (lambda (identifier)
			   (bind-variable! environment identifier))))
		    (let loop ((bvl (cadr form)))
		      (cond ((null? bvl)
			     '())
			    ((pair? bvl)
			     (cons (rename (car bvl)) (loop (cdr bvl))))
			    (else
			     (rename bvl)))))))
	     (output/lambda bvl-description
			    (compile-item/expression
			     (classify/body (cddr form)
					    environment)))))))

     (define-compiler 'SET!
       (lambda (form environment)
	 (syntax-check '(KEYWORD FORM EXPRESSION) form)
	 (output/assignment
	  (let loop
	      ((form (cadr form))
	       (environment environment))
	    (cond ((identifier? form)
		   (let ((item
			  (syntactic-environment/lookup environment form)))
		     (if (variable-item? item)
			 (variable-item/name item)
			 (slib:error "target of assignment not a variable"
				       form))))
		  ((syntactic-closure? form)
		   (let ((form (syntactic-closure/form form))
			 (environment
			  (filter-syntactic-environment
			   (syntactic-closure/free-names form)
			   environment
			   (syntactic-closure/environment form))))
		     (loop form
			   environment)))
		  (else
		   (slib:error "target of assignment not an identifier"
				 form))))
	  (compile/subexpression (caddr form)
				 environment))))

     ;; end MAKE-R4RS-PRIMITIVE-MACROLOGY
     )))

;;;; Core Expanders

(define (make-core-expander-macrology)
  (make-er-expander-macrology
   (lambda (define-expander base-environment)

     (let ((keyword (make-syntactic-closure base-environment '() 'DEFINE)))
       (define-expander 'DEFINE
	 (lambda (form rename compare)
	   compare			;ignore
	   (if (syntax-match? '((IDENTIFIER . R4RS-BVL) + FORM) (cdr form))
	       `(,keyword ,(caadr form)
			  (,(rename 'LAMBDA) ,(cdadr form) ,@(cddr form)))
	       `(,keyword ,@(cdr form))))))

     (let ((keyword (make-syntactic-closure base-environment '() 'LET)))
       (define-expander 'LET
	 (lambda (form rename compare)
	   compare			;ignore
	   (if (syntax-match? '(IDENTIFIER (* (IDENTIFIER EXPRESSION)) + FORM)
			      (cdr form))
	       (let ((name (cadr form))
		     (bindings (caddr form)))
		 `((,(rename 'LETREC)
		    ((,name (,(rename 'LAMBDA) ,(map car bindings) ,@(cdddr form))))
		    ,name)
		   ,@(map cadr bindings)))
	       `(,keyword ,@(cdr form))))))

     (define-expander 'LET*
       (lambda (form rename compare)
	 compare			;ignore
	 (if (syntax-match? '((* (IDENTIFIER EXPRESSION)) + FORM) (cdr form))
	     (let ((bindings (cadr form))
		   (body (cddr form))
		   (keyword (rename 'LET)))
	       (if (null? bindings)
		   `(,keyword ,bindings ,@body)
		   (let loop ((bindings bindings))
		     (if (null? (cdr bindings))
			 `(,keyword ,bindings ,@body)
			 `(,keyword (,(car bindings))
				    ,(loop (cdr bindings)))))))
	     (ill-formed-syntax form))))

     (define-expander 'AND
       (lambda (form rename compare)
	 compare			;ignore
	 (if (syntax-match? '(* EXPRESSION) (cdr form))
	     (let ((operands (cdr form)))
	       (if (null? operands)
		   `#T
		   (let ((if-keyword (rename 'IF)))
		     (let loop ((operands operands))
		       (if (null? (cdr operands))
			   (car operands)
			   `(,if-keyword ,(car operands)
					 ,(loop (cdr operands))
					 #F))))))
	     (ill-formed-syntax form))))

     (define-expander 'OR
       (lambda (form rename compare)
	 compare			;ignore
	 (if (syntax-match? '(* EXPRESSION) (cdr form))
	     (let ((operands (cdr form)))
	       (if (null? operands)
		   `#F
		   (let ((let-keyword (rename 'LET))
			 (if-keyword (rename 'IF))
			 (temp (rename 'TEMP)))
		     (let loop ((operands operands))
		       (if (null? (cdr operands))
			   (car operands)
			   `(,let-keyword ((,temp ,(car operands)))
					  (,if-keyword ,temp
						       ,temp
						       ,(loop (cdr operands)))))))))
	     (ill-formed-syntax form))))

     (define-expander 'CASE
       (lambda (form rename compare)
	 (if (syntax-match? '(EXPRESSION + (DATUM + EXPRESSION)) (cdr form))
	     (letrec
		 ((process-clause
		   (lambda (clause rest)
		     (cond ((null? (car clause))
			    (process-rest rest))
			   ((and (identifier? (car clause))
				 (compare (rename 'ELSE) (car clause))
				 (null? rest))
			    `(,(rename 'BEGIN) ,@(cdr clause)))
			   ((list? (car clause))
			    `(,(rename 'IF) (,(rename 'MEMV) ,(rename 'TEMP)
							     ',(car clause))
					    (,(rename 'BEGIN) ,@(cdr clause))
					    ,(process-rest rest)))
			   (else
			    (syntax-error "ill-formed clause" clause)))))
		  (process-rest
		   (lambda (rest)
		     (if (null? rest)
			 (unspecific-expression)
			 (process-clause (car rest) (cdr rest))))))
	       `(,(rename 'LET) ((,(rename 'TEMP) ,(cadr form)))
				,(process-clause (caddr form) (cdddr form))))
	     (ill-formed-syntax form))))

     (define-expander 'COND
       (lambda (form rename compare)
	 (letrec
	     ((process-clause
	       (lambda (clause rest)
		 (cond
		  ((or (not (list? clause))
		       (null? clause))
		   (syntax-error "ill-formed clause" clause))
		  ((and (identifier? (car clause))
			(compare (rename 'ELSE) (car clause)))
		   (cond
		    ((or (null? (cdr clause))
			 (and (identifier? (cadr clause))
			      (compare (rename '=>) (cadr clause))))
		     (syntax-error "ill-formed ELSE clause" clause))
		    ((not (null? rest))
		     (syntax-error "misplaced ELSE clause" clause))
		    (else
		     `(,(rename 'BEGIN) ,@(cdr clause)))))
		  ((null? (cdr clause))
		   `(,(rename 'OR) ,(car clause) ,(process-rest rest)))
		  ((and (identifier? (cadr clause))
			(compare (rename '=>) (cadr clause)))
		   (if (and (pair? (cddr clause))
			    (null? (cdddr clause)))
		       `(,(rename 'LET)
			 ((,(rename 'TEMP) ,(car clause)))
			 (,(rename 'IF) ,(rename 'TEMP)
					(,(caddr clause) ,(rename 'TEMP))
					,(process-rest rest)))
		       (syntax-error "ill-formed => clause" clause)))
		  (else
		   `(,(rename 'IF) ,(car clause)
				   (,(rename 'BEGIN) ,@(cdr clause))
				   ,(process-rest rest))))))
	      (process-rest
	       (lambda (rest)
		 (if (null? rest)
		     (unspecific-expression)
		     (process-clause (car rest) (cdr rest))))))
	   (let ((clauses (cdr form)))
	     (if (null? clauses)
		 (syntax-error "no clauses" form)
		 (process-clause (car clauses) (cdr clauses)))))))

     (define-expander 'DO
       (lambda (form rename compare)
	 compare			;ignore
	 (if (syntax-match? '((* (IDENTIFIER EXPRESSION ? EXPRESSION))
			      (+ EXPRESSION)
			      * FORM)
			    (cdr form))
	     (let ((bindings (cadr form)))
	       `(,(rename 'LETREC)
		 ((,(rename 'DO-LOOP)
		   (,(rename 'LAMBDA)
		    ,(map car bindings)
		    (,(rename 'IF) ,(caaddr form)
				   ,(if (null? (cdaddr form))
					(unspecific-expression)
					`(,(rename 'BEGIN) ,@(cdaddr form)))
				   (,(rename 'BEGIN)
				    ,@(cdddr form)
				    (,(rename 'DO-LOOP)
				     ,@(map (lambda (binding)
					      (if (null? (cddr binding))
						  (car binding)
						  (caddr binding)))
					    bindings)))))))
		 (,(rename 'DO-LOOP) ,@(map cadr bindings))))
	     (ill-formed-syntax form))))

     (define-expander 'QUASIQUOTE
       (lambda (form rename compare)
	 (define (descend-quasiquote x level return)
	   (cond ((pair? x) (descend-quasiquote-pair x level return))
		 ((vector? x) (descend-quasiquote-vector x level return))
		 (else (return 'QUOTE x))))
	 (define (descend-quasiquote-pair x level return)
	   (cond ((not (and (pair? x)
			    (identifier? (car x))
			    (pair? (cdr x))
			    (null? (cddr x))))
		  (descend-quasiquote-pair* x level return))
		 ((compare (rename 'QUASIQUOTE) (car x))
		  (descend-quasiquote-pair* x (+ level 1) return))
		 ((compare (rename 'UNQUOTE) (car x))
		  (if (zero? level)
		      (return 'UNQUOTE (cadr x))
		      (descend-quasiquote-pair* x (- level 1) return)))
		 ((compare (rename 'UNQUOTE-SPLICING) (car x))
		  (if (zero? level)
		      (return 'UNQUOTE-SPLICING (cadr x))
		      (descend-quasiquote-pair* x (- level 1) return)))
		 (else
		  (descend-quasiquote-pair* x level return))))
	 (define (descend-quasiquote-pair* x level return)
	   (descend-quasiquote
	    (car x) level
	    (lambda (car-mode car-arg)
	      (descend-quasiquote
	       (cdr x) level
	       (lambda (cdr-mode cdr-arg)
		 (cond ((and (eq? car-mode 'QUOTE) (eq? cdr-mode 'QUOTE))
			(return 'QUOTE x))
		       ((eq? car-mode 'UNQUOTE-SPLICING)
			(if (and (eq? cdr-mode 'QUOTE) (null? cdr-arg))
			    (return 'UNQUOTE car-arg)
			    (return 'APPEND
				    (list car-arg
					  (finalize-quasiquote cdr-mode
							       cdr-arg)))))
		       ((and (eq? cdr-mode 'QUOTE) (list? cdr-arg))
			(return 'LIST
				(cons (finalize-quasiquote car-mode car-arg)
				      (map (lambda (element)
					     (finalize-quasiquote 'QUOTE
								  element))
					   cdr-arg))))
		       ((eq? cdr-mode 'LIST)
			(return 'LIST
				(cons (finalize-quasiquote car-mode car-arg)
				      cdr-arg)))
		       (else
			(return
			 'CONS
			 (list (finalize-quasiquote car-mode car-arg)
			       (finalize-quasiquote cdr-mode cdr-arg))))))))))
	 (define (descend-quasiquote-vector x level return)
	   (descend-quasiquote
	    (vector->list x) level
	    (lambda (mode arg)
	      (case mode
		((QUOTE) (return 'QUOTE x))
		((LIST) (return 'VECTOR arg))
		(else
		 (return 'LIST->VECTOR
			 (list (finalize-quasiquote mode arg))))))))
	 (define (finalize-quasiquote mode arg)
	   (case mode
	     ((QUOTE) `(,(rename 'QUOTE) ,arg))
	     ((UNQUOTE) arg)
	     ((UNQUOTE-SPLICING) (syntax-error ",@ in illegal context" arg))
	     (else `(,(rename mode) ,@arg))))
	 (if (syntax-match? '(EXPRESSION) (cdr form))
	     (descend-quasiquote (cadr form) 0 finalize-quasiquote)
	     (ill-formed-syntax form))))

;;; end MAKE-CORE-EXPANDER-MACROLOGY
     )))
