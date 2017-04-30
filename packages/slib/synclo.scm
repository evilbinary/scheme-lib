;;; "synclo.scm" Syntactic Closures		-*-Scheme-*-
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

;;;; Syntactic Closures
;;; written by Alan Bawden
;;; extensively modified by Chris Hanson

;;; See "Syntactic Closures", by Alan Bawden and Jonathan Rees, in
;;; Proceedings of the 1988 ACM Conference on Lisp and Functional
;;; Programming, page 86.

;;;; Classifier
;;;  The classifier maps forms into items.  In addition to locating
;;;  definitions so that they can be properly processed, it also
;;;  identifies keywords and variables, which allows a powerful form
;;;  of syntactic binding to be implemented.

(define (classify/form form environment definition-environment)
  (cond ((identifier? form)
	 (syntactic-environment/lookup environment form))
	((syntactic-closure? form)
	 (let ((form (syntactic-closure/form form))
	       (environment
		(filter-syntactic-environment
		 (syntactic-closure/free-names form)
		 environment
		 (syntactic-closure/environment form))))
	   (classify/form form
			  environment
			  definition-environment)))
	((pair? form)
	 (let ((item
		(classify/subexpression (car form) environment)))
	   (cond ((keyword-item? item)
		  ((keyword-item/classifier item) form
						  environment
						  definition-environment))
		 ((list? (cdr form))
		  (let ((items
			 (classify/subexpressions (cdr form)
						  environment)))
		    (make-expression-item
		     (lambda ()
		       (output/combination
			(compile-item/expression item)
			(map compile-item/expression items)))
		     form)))
		 (else
		  (syntax-error "combination must be a proper list"
				form)))))
	(else
	 (make-expression-item ;don't quote literals evaluating to themselves
	   (if (or (boolean? form) (char? form) (number? form) (string? form))
	       (lambda () (output/literal-unquoted form))
	       (lambda () (output/literal-quoted form))) form))))

(define (classify/subform form environment definition-environment)
  (classify/form form
		 environment
		 definition-environment))

(define (classify/subforms forms environment definition-environment)
  (map (lambda (form)
	 (classify/subform form environment definition-environment))
       forms))

(define (classify/subexpression expression environment)
  (classify/subform expression environment environment))

(define (classify/subexpressions expressions environment)
  (classify/subforms expressions environment environment))

;;;; Compiler
;;;  The compiler maps items into the output language.

(define (compile-item/expression item)
  (let ((illegal
	 (lambda (item name)
	   (let ((decompiled (decompile-item item))) (newline)
	   (slib:error (string-append name
					" may not be used as an expression")
			 decompiled)))))
    (cond ((variable-item? item)
	   (output/variable (variable-item/name item)))
	  ((expression-item? item)
	   ((expression-item/compiler item)))
	  ((body-item? item)
	   (let ((items (flatten-body-items (body-item/components item))))
	     (if (null? items)
		 (illegal item "empty sequence")
		 (output/sequence (map compile-item/expression items)))))
	  ((definition-item? item)
	   (let ((binding ;allows later scheme errors, but allows top-level
		  (bind-definition-item! ;(if (not (defined? x)) define it)
		   scheme-syntactic-environment item))) ;as in Init.scm
	     (output/top-level-definition
	      (car binding)
	      (compile-item/expression (cdr binding)))))
	  ((keyword-item? item)
	   (illegal item "keyword"))
	  (else
	   (impl-error "unknown item" item)))))

(define (compile/subexpression expression environment)
  (compile-item/expression
   (classify/subexpression expression environment)))

(define (compile/top-level forms environment)
  ;; Top-level syntactic definitions affect all forms that appear
  ;; after them.
  (output/top-level-sequence
   (let forms-loop ((forms forms))
     (if (null? forms)
	 '()
	 (let items-loop
	     ((items
	       (item->list
		(classify/subform (car forms)
				  environment
				  environment))))
	   (cond ((null? items)
		  (forms-loop (cdr forms)))
		 ((definition-item? (car items))
		  (let ((binding
			 (bind-definition-item! environment (car items))))
		    (if binding
			(cons (output/top-level-definition
			       (car binding)
			       (compile-item/expression (cdr binding)))
			      (items-loop (cdr items)))
			(items-loop (cdr items)))))
		 (else
		  (cons (compile-item/expression (car items))
			(items-loop (cdr items))))))))))

;;;; De-Compiler
;;;  The de-compiler maps partly-compiled things back to the input language,
;;;  as far as possible.  Used to display more meaningful macro error messages.

(define (decompile-item item)
    (display " ")
    (cond ((variable-item? item) (variable-item/name item))
	  ((expression-item? item)
	   (decompile-item (expression-item/annotation item)))
	  ((body-item? item)
	   (let ((items (flatten-body-items (body-item/components item))))
	     (display "sequence")
	     (if (null? items)
		 "empty sequence"
		 "non-empty sequence")))
	  ((definition-item? item) "definition")
	  ((keyword-item? item)
	   (decompile-item (keyword-item/name item)));in case expression
	  ((syntactic-closure? item); (display "syntactic-closure;")
	   (decompile-item (syntactic-closure/form item)))
	  ((list? item) (display "(")
		(map decompile-item item) (display ")") "see list above")
	  ((string? item) item);explicit name-string for keyword-item
	  ((symbol? item) (display item) item) ;symbol for syntactic-closures
	  ((boolean? item) (display item) item) ;symbol for syntactic-closures
	  (else (write item) (impl-error "unknown item" item))))

;;;; Syntactic Closures

(define syntactic-closure-type
  (make-record-type "syntactic-closure" '(ENVIRONMENT FREE-NAMES FORM)))
;@
(define make-syntactic-closure
  (record-constructor syntactic-closure-type '(ENVIRONMENT FREE-NAMES FORM)))

(define syntactic-closure?
  (record-predicate syntactic-closure-type))

(define syntactic-closure/environment
  (record-accessor syntactic-closure-type 'ENVIRONMENT))

(define syntactic-closure/free-names
  (record-accessor syntactic-closure-type 'FREE-NAMES))

(define syntactic-closure/form
  (record-accessor syntactic-closure-type 'FORM))

(define (make-syntactic-closure-list environment free-names forms)
  (map (lambda (form) (make-syntactic-closure environment free-names form))
       forms))

(define (strip-syntactic-closures object)
  (cond ((syntactic-closure? object)
	 (strip-syntactic-closures (syntactic-closure/form object)))
	((pair? object)
	 (cons (strip-syntactic-closures (car object))
	       (strip-syntactic-closures (cdr object))))
	((vector? object)
	 (let ((length (vector-length object)))
	   (let ((result (make-vector length)))
	     (do ((i 0 (+ i 1)))
		 ((= i length))
	       (vector-set! result i
			    (strip-syntactic-closures (vector-ref object i))))
	     result)))
	(else
	 object)))
;@
(define (identifier? object)
  (or (symbol? object)
      (synthetic-identifier? object)))

(define (synthetic-identifier? object)
  (and (syntactic-closure? object)
       (identifier? (syntactic-closure/form object))))

(define (identifier->symbol identifier)
  (cond ((symbol? identifier)
	 identifier)
	((synthetic-identifier? identifier)
	 (identifier->symbol (syntactic-closure/form identifier)))
	(else
	 (impl-error "not an identifier" identifier))))
;@
(define (identifier=? environment-1 identifier-1 environment-2 identifier-2)
  (let ((item-1 (syntactic-environment/lookup environment-1 identifier-1))
	(item-2 (syntactic-environment/lookup environment-2 identifier-2)))
    (or (eq? item-1 item-2)
	;; This is necessary because an identifier that is not
	;; explicitly bound by an environment is mapped to a variable
	;; item, and the variable items are not cached.  Therefore
	;; two references to the same variable result in two
	;; different variable items.
	(and (variable-item? item-1)
	     (variable-item? item-2)
	     (eq? (variable-item/name item-1)
		  (variable-item/name item-2))))))

;;;; Syntactic Environments

(define syntactic-environment-type
  (make-record-type
   "syntactic-environment"
   '(PARENT
     LOOKUP-OPERATION
     RENAME-OPERATION
     DEFINE-OPERATION
     BINDINGS-OPERATION)))

(define make-syntactic-environment
  (record-constructor syntactic-environment-type
		      '(PARENT
			LOOKUP-OPERATION
			RENAME-OPERATION
			DEFINE-OPERATION
			BINDINGS-OPERATION)))

(define syntactic-environment?
  (record-predicate syntactic-environment-type))

(define syntactic-environment/parent
  (record-accessor syntactic-environment-type 'PARENT))

(define syntactic-environment/lookup-operation
  (record-accessor syntactic-environment-type 'LOOKUP-OPERATION))

(define (syntactic-environment/assign! environment name item)
  (let ((binding
	 ((syntactic-environment/lookup-operation environment) name)))
    (if binding
	(set-cdr! binding item)
	(impl-error "can't assign unbound identifier" name))))

(define syntactic-environment/rename-operation
  (record-accessor syntactic-environment-type 'RENAME-OPERATION))

(define (syntactic-environment/rename environment name)
  ((syntactic-environment/rename-operation environment) name))

(define syntactic-environment/define!
  (let ((accessor
	 (record-accessor syntactic-environment-type 'DEFINE-OPERATION)))
    (lambda (environment name item)
      ((accessor environment) name item))))

(define syntactic-environment/bindings
  (let ((accessor
	 (record-accessor syntactic-environment-type 'BINDINGS-OPERATION)))
    (lambda (environment)
      ((accessor environment)))))

(define (syntactic-environment/lookup environment name)
  (let ((binding
	 ((syntactic-environment/lookup-operation environment) name)))
    (cond (binding
	   (let ((item (cdr binding)))
	     (if (reserved-name-item? item)
		 (syntax-error "premature reference to reserved name"
			       name)
		 item)))
	  ((symbol? name)
	   (make-variable-item name))
	  ((synthetic-identifier? name)
	   (syntactic-environment/lookup (syntactic-closure/environment name)
					 (syntactic-closure/form name)))
	  (else
	   (impl-error "not an identifier" name)))))

(define root-syntactic-environment
  (make-syntactic-environment
   #f
   (lambda (name)
     name
     #f)
   (lambda (name)
     name)
   (lambda (name item)
     (impl-error "can't bind name in root syntactic environment" name item))
   (lambda ()
     '())))

(define null-syntactic-environment
  (make-syntactic-environment
   #f
   (lambda (name)
     (impl-error "can't lookup name in null syntactic environment" name))
   (lambda (name)
     (impl-error "can't rename name in null syntactic environment" name))
   (lambda (name item)
     (impl-error "can't bind name in null syntactic environment" name item))
   (lambda ()
     '())))

(define (top-level-syntactic-environment parent)
  (let ((bound '()))
    (make-syntactic-environment
     parent
     (let ((parent-lookup (syntactic-environment/lookup-operation parent)))
       (lambda (name)
	 (or (assq name bound)
	     (parent-lookup name))))
     (lambda (name)
       name)
     (lambda (name item)
       (let ((binding (assq name bound)))
	 (if binding
	     (set-cdr! binding item)
	     (set! bound (cons (cons name item) bound)))))
     (lambda ()
       (map (lambda (pair) (cons (car pair) (cdr pair))) bound)))))

(define (internal-syntactic-environment parent)
  (let ((bound '())
	(free '()))
    (make-syntactic-environment
     parent
     (let ((parent-lookup (syntactic-environment/lookup-operation parent)))
       (lambda (name)
	 (or (assq name bound)
	     (assq name free)
	     (let ((binding (parent-lookup name)))
	       (if binding (set! free (cons binding free)))
	       binding))))
     (make-name-generator)
     (lambda (name item)
       (cond ((assq name bound)
	      =>
	      (lambda (association)
		(if (and (reserved-name-item? (cdr association))
			 (not (reserved-name-item? item)))
		    (set-cdr! association item)
		    (impl-error "can't redefine name; already bound" name))))
	     ((assq name free)
	      (if (reserved-name-item? item)
		  (syntax-error "premature reference to reserved name"
				name)
		  (impl-error "can't define name; already free" name)))
	     (else
	      (set! bound (cons (cons name item) bound)))))
     (lambda ()
       (map (lambda (pair) (cons (car pair) (cdr pair))) bound)))))

(define (filter-syntactic-environment names names-env else-env)
  (if (or (null? names)
	  (eq? names-env else-env))
      else-env
      (let ((make-operation
	     (lambda (get-operation)
	       (let ((names-operation (get-operation names-env))
		     (else-operation (get-operation else-env)))
		 (lambda (name)
		   ((if (memq name names) names-operation else-operation)
		    name))))))
	(make-syntactic-environment
	 else-env
	 (make-operation syntactic-environment/lookup-operation)
	 (make-operation syntactic-environment/rename-operation)
	 (lambda (name item)
	   (impl-error "can't bind name in filtered syntactic environment"
		       name item))
	 (lambda ()
	   (map (lambda (name)
		  (cons name
			(syntactic-environment/lookup names-env name)))
		names))))))

;;;; Items

;;; Reserved name items do not represent any form, but instead are
;;; used to reserve a particular name in a syntactic environment.  If
;;; the classifier refers to a reserved name, a syntax error is
;;; signalled.  This is used in the implementation of LETREC-SYNTAX
;;; to signal a meaningful error when one of the <init>s refers to
;;; one of the names being bound.

(define reserved-name-item-type
  (make-record-type "reserved-name-item" '()))

(define make-reserved-name-item
  (record-constructor reserved-name-item-type '()))

(define reserved-name-item?
  (record-predicate reserved-name-item-type))

;;; Keyword items represent macro keywords.

(define keyword-item-type
  (make-record-type "keyword-item" '(CLASSIFIER NAME)))
;  (make-record-type "keyword-item" '(CLASSIFIER)))

(define make-keyword-item
;  (lambda (cl) (display "make-keyword-item:") (write cl) (newline)
;	((record-constructor keyword-item-type '(CLASSIFIER)) cl)))
  (record-constructor keyword-item-type '(CLASSIFIER NAME)))
;  (record-constructor keyword-item-type '(CLASSIFIER)))

(define keyword-item?
  (record-predicate keyword-item-type))

(define keyword-item/classifier
  (record-accessor keyword-item-type 'CLASSIFIER))

(define keyword-item/name
  (record-accessor keyword-item-type 'NAME))

;;; Variable items represent run-time variables.

(define variable-item-type
  (make-record-type "variable-item" '(NAME)))

(define make-variable-item
  (record-constructor variable-item-type '(NAME)))

(define variable-item?
  (record-predicate variable-item-type))

(define variable-item/name
  (record-accessor variable-item-type 'NAME))

;;; Expression items represent any kind of expression other than a
;;; run-time variable or a sequence.  The ANNOTATION field is used to
;;; make expression items that can appear in non-expression contexts
;;; (for example, this could be used in the implementation of SETF).

(define expression-item-type
  (make-record-type "expression-item" '(COMPILER ANNOTATION)))

(define make-expression-item
  (record-constructor expression-item-type '(COMPILER ANNOTATION)))

(define expression-item?
  (record-predicate expression-item-type))

(define expression-item/compiler
  (record-accessor expression-item-type 'COMPILER))

(define expression-item/annotation
  (record-accessor expression-item-type 'ANNOTATION))

;;; Body items represent sequences (e.g. BEGIN).

(define body-item-type
  (make-record-type "body-item" '(COMPONENTS)))

(define make-body-item
  (record-constructor body-item-type '(COMPONENTS)))

(define body-item?
  (record-predicate body-item-type))

(define body-item/components
  (record-accessor body-item-type 'COMPONENTS))

;;; Definition items represent definitions, whether top-level or
;;; internal, keyword or variable.

(define definition-item-type
  (make-record-type "definition-item" '(BINDING-THEORY NAME VALUE)))

(define make-definition-item
  (record-constructor definition-item-type '(BINDING-THEORY NAME VALUE)))

(define definition-item?
  (record-predicate definition-item-type))

(define definition-item/binding-theory
  (record-accessor definition-item-type 'BINDING-THEORY))

(define definition-item/name
  (record-accessor definition-item-type 'NAME))

(define definition-item/value
  (record-accessor definition-item-type 'VALUE))

(define (bind-definition-item! environment item)
  ((definition-item/binding-theory item)
   environment
   (definition-item/name item)
   (force (definition-item/value item))))

(define (syntactic-binding-theory environment name item)
  (if (or (keyword-item? item)
	  (variable-item? item))
      (begin
	(syntactic-environment/define! environment name item)
	#f)
      (syntax-error "syntactic binding value must be a keyword or a variable"
		    item)))

(define (variable-binding-theory environment name item)
  ;; If ITEM isn't a valid expression, an error will be signalled by
  ;; COMPILE-ITEM/EXPRESSION later.
  (cons (bind-variable! environment name) item))

(define (overloaded-binding-theory environment name item)
  (if (keyword-item? item)
      (begin
	(syntactic-environment/define! environment name item)
	#f)
      (cons (bind-variable! environment name) item)))

;;;; Classifiers, Compilers, Expanders

(define (sc-expander->classifier expander keyword-environment)
  (lambda (form environment definition-environment)
    (classify/form (expander form environment)
		   keyword-environment
		   definition-environment)))

(define (er-expander->classifier expander keyword-environment)
  (sc-expander->classifier (er->sc-expander expander) keyword-environment))

(define (er->sc-expander expander)
  (lambda (form environment)
    (capture-syntactic-environment
     (lambda (keyword-environment)
       (make-syntactic-closure
	environment '()
	(expander form
		  (let ((renames '()))
		    (lambda (identifier)
		      (let ((association (assq identifier renames)))
			(if association
			    (cdr association)
			    (let ((rename
				   (make-syntactic-closure
				    keyword-environment
				    '()
				    identifier)))
			      (set! renames
				    (cons (cons identifier rename)
					  renames))
			      rename)))))
		  (lambda (x y)
		    (identifier=? environment x
				  environment y))))))))

(define (classifier->keyword classifier)
  (make-syntactic-closure
   (let ((environment
	  (internal-syntactic-environment null-syntactic-environment)))
     (syntactic-environment/define! environment
				    'KEYWORD
				    (make-keyword-item classifier "c->k"))
     environment)
   '()
   'KEYWORD))

(define (compiler->keyword compiler)
  (classifier->keyword (compiler->classifier compiler)))

(define (classifier->form classifier)
  `(,(classifier->keyword classifier)))

(define (compiler->form compiler)
  (classifier->form (compiler->classifier compiler)))

(define (compiler->classifier compiler)
  (lambda (form environment definition-environment)
    definition-environment		;ignore
    (make-expression-item
     (lambda () (compiler form environment)) form)))

;;;; Macrologies
;;;  A macrology is a procedure that accepts a syntactic environment
;;;  as an argument, producing a new syntactic environment that is an
;;;  extension of the argument.

(define (make-primitive-macrology generate-definitions)
  (lambda (base-environment)
    (let ((environment (top-level-syntactic-environment base-environment)))
      (let ((define-classifier
	      (lambda (keyword classifier)
		(syntactic-environment/define!
		 environment
		 keyword
		 (make-keyword-item classifier keyword)))))
	(generate-definitions
	 define-classifier
	 (lambda (keyword compiler)
	   (define-classifier keyword (compiler->classifier compiler)))))
      environment)))

(define (make-expander-macrology object->classifier generate-definitions)
  (lambda (base-environment)
    (let ((environment (top-level-syntactic-environment base-environment)))
      (generate-definitions
       (lambda (keyword object)
	 (syntactic-environment/define!
	  environment
	  keyword
	  (make-keyword-item (object->classifier object environment) keyword)))
       base-environment)
      environment)))

(define (make-sc-expander-macrology generate-definitions)
  (make-expander-macrology sc-expander->classifier generate-definitions))

(define (make-er-expander-macrology generate-definitions)
  (make-expander-macrology er-expander->classifier generate-definitions))

(define (compose-macrologies . macrologies)
  (lambda (environment)
    (do ((macrologies macrologies (cdr macrologies))
	 (environment environment ((car macrologies) environment)))
	((null? macrologies) environment))))

;;;; Utilities

(define (bind-variable! environment name)
  (let ((rename (syntactic-environment/rename environment name)))
    (syntactic-environment/define! environment
				   name
				   (make-variable-item rename))
    rename))

(define (reserve-names! names environment)
  (let ((item (make-reserved-name-item)))
    (for-each (lambda (name)
		(syntactic-environment/define! environment name item))
	      names)))
;@
(define (capture-syntactic-environment expander)
  (classifier->form
   (lambda (form environment definition-environment)
     form				;ignore
     (classify/form (expander environment)
		    environment
		    definition-environment))))

(define (unspecific-expression)
  (compiler->form
   (lambda (form environment)
     form environment			;ignore
     (output/unspecific))))

(define (unassigned-expression)
  (compiler->form
   (lambda (form environment)
     form environment			;ignore
     (output/unassigned))))

(define (syntax-quote expression)
  `(,(compiler->keyword
      (lambda (form environment)
	environment			;ignore
	(syntax-check '(KEYWORD DATUM) form)
	(output/literal-quoted (cadr form))))
    ,expression))

(define (flatten-body-items items)
  (append-map item->list items))

(define (item->list item)
  (if (body-item? item)
      (flatten-body-items (body-item/components item))
      (list item)))

(define (output/let names values body)
  (if (null? names)
      body
      (output/combination (output/lambda names body) values)))

(define (output/letrec names values body)
  (if (null? names)
      body
      (output/let
       names
       (map (lambda (name) name (output/unassigned)) names)
       (output/sequence
	(list (if (null? (cdr names))
		  (output/assignment (car names) (car values))
		  (let ((temps (map (make-name-generator) names)))
		    (output/let
		     temps
		     values
		     (output/sequence
		      (map output/assignment names temps)))))
	      body)))))

(define (output/top-level-sequence expressions)
  (if (null? expressions)
      (output/unspecific)
      (output/sequence expressions)))
