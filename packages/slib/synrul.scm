;;; "synrul.scm" Rule-based Syntactic Expanders		-*-Scheme-*-
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

;;;; Rule-based Syntactic Expanders

;;; See "Syntactic Extensions in the Programming Language Lisp", by
;;; Eugene Kohlbecker, Ph.D. dissertation, Indiana University, 1986.
;;; See also "Macros That Work", by William Clinger and Jonathan Rees
;;; (reference? POPL?).  This implementation is derived from an
;;; implementation by Kent Dybvig, and includes some ideas from
;;; another implementation by Jonathan Rees.

;;; The expansion of SYNTAX-RULES references the following keywords:
;;;   ER-TRANSFORMER LAMBDA IF BEGIN SET! QUOTE
;;; and the following procedures:
;;;   CAR CDR NULL? PAIR? EQUAL? MAP LIST CONS APPEND
;;;   ILL-FORMED-SYNTAX
;;; it also uses the anonymous keyword SYNTAX-QUOTE.

;;; For testing.
;;;(define (run-sr form)
;;;  (expand/syntax-rules form (lambda (x) x) eq?))

(define (make-syntax-rules-macrology)
  (make-er-expander-macrology
   (lambda (define-classifier base-environment)
     base-environment			;ignore
     (define-classifier 'SYNTAX-RULES expand/syntax-rules))))

(define (expand/syntax-rules form rename compare)
  (if (syntax-match? '((* IDENTIFIER) + ((IDENTIFIER . DATUM) EXPRESSION))
		     (cdr form))
      (let ((keywords (cadr form))
	    (clauses (cddr form)))
	(if (let loop ((keywords keywords))
	      (and (pair? keywords)
		   (or (memq (car keywords) (cdr keywords))
		       (loop (cdr keywords)))))
	    (syntax-error "keywords list contains duplicates" keywords)
	    (let ((r-form (rename 'FORM))
		  (r-rename (rename 'RENAME))
		  (r-compare (rename 'COMPARE)))
	      `(,(rename 'ER-TRANSFORMER)
		(,(rename 'LAMBDA)
		 (,r-form ,r-rename ,r-compare)
		 ,(let loop ((clauses clauses))
		    (if (null? clauses)
			`(,(rename 'ILL-FORMED-SYNTAX) ,r-form)
			(let ((pattern (caar clauses)))
			  (let ((sids
				 (parse-pattern rename compare keywords
						pattern r-form)))
			    `(,(rename 'IF)
			      ,(generate-match rename compare keywords
					       r-rename r-compare
					       pattern r-form)
			      ,(generate-output rename compare r-rename
						sids (cadar clauses)
						syntax-error)
			      ,(loop (cdr clauses))))))))))))
      (ill-formed-syntax form)))

(define (parse-pattern rename compare keywords pattern expression)
  (let loop
      ((pattern pattern)
       (expression expression)
       (sids '())
       (control #f))
    (cond ((identifier? pattern)
	   (if (memq pattern keywords)
	       sids
	       (cons (make-sid pattern expression control) sids)))
	  ((and (or (zero-or-more? pattern rename compare)
		    (at-least-one? pattern rename compare))
		(null? (cddr pattern)))
	   (let ((variable ((make-name-generator) 'CONTROL)))
	     (loop (car pattern)
		   variable
		   sids
		   (make-sid variable expression control))))
	  ((pair? pattern)
	   (loop (car pattern)
		 `(,(rename 'CAR) ,expression)
		 (loop (cdr pattern)
		       `(,(rename 'CDR) ,expression)
		       sids
		       control)
		 control))
	  (else sids))))

(define (generate-match rename compare keywords r-rename r-compare
			pattern expression)
  (letrec
      ((loop
	(lambda (pattern expression)
	  (cond ((identifier? pattern)
		 (if (memq pattern keywords)
		     (let ((temp (rename 'TEMP)))
		       `((,(rename 'LAMBDA)
			  (,temp)
			  (,(rename 'IF)
			   (,(rename 'IDENTIFIER?) ,temp)
			   (,r-compare ,temp
				       (,r-rename ,(syntax-quote pattern)))
			   #f))
			 ,expression))
		     `#t))
		((and (zero-or-more? pattern rename compare)
		      (null? (cddr pattern)))
		 (do-list (car pattern) expression))
		((and (at-least-one? pattern rename compare)
		      (null? (cddr pattern)))
		 `(,(rename 'IF) (,(rename 'NULL?) ,expression)
				 #F
				 ,(do-list (car pattern) expression)))
		((pair? pattern)
		 (let ((generate-pair
			(lambda (expression)
			  (conjunction
			   `(,(rename 'PAIR?) ,expression)
			   (conjunction
			    (loop (car pattern)
				  `(,(rename 'CAR) ,expression))
			    (loop (cdr pattern)
				  `(,(rename 'CDR) ,expression)))))))
		   (if (identifier? expression)
		       (generate-pair expression)
		       (let ((temp (rename 'TEMP)))
			 `((,(rename 'LAMBDA) (,temp) ,(generate-pair temp))
			   ,expression)))))
		((null? pattern)
		 `(,(rename 'NULL?) ,expression))
		(else
		 `(,(rename 'EQUAL?) ,expression
				     (,(rename 'QUOTE) ,pattern))))))
       (do-list
	(lambda (pattern expression)
	  (let ((r-loop (rename 'LOOP))
		(r-l (rename 'L))
		(r-lambda (rename 'LAMBDA)))
	    `(((,r-lambda
		(,r-loop)
		(,(rename 'BEGIN)
		 (,(rename 'SET!)
		  ,r-loop
		  (,r-lambda
		   (,r-l)
		   (,(rename 'IF)
		    (,(rename 'NULL?) ,r-l)
		    #T
		    ,(conjunction
		      `(,(rename 'PAIR?) ,r-l)
		      (conjunction (loop pattern `(,(rename 'CAR) ,r-l))
				   `(,r-loop (,(rename 'CDR) ,r-l)))))))
		 ,r-loop))
	       #F)
	      ,expression))))
       (conjunction
	(lambda (predicate consequent)
	  (cond ((eq? predicate #T) consequent)
		((eq? consequent #T) predicate)
		(else `(,(rename 'IF) ,predicate ,consequent #F))))))
    (loop pattern expression)))

(define (generate-output rename compare r-rename sids template syntax-error)
  (let loop ((template template) (ellipses '()))
    (cond ((identifier? template)
	   (let ((sid
		  (let loop ((sids sids))
		    (and (not (null? sids))
			 (if (eq? (sid-name (car sids)) template)
			     (car sids)
			     (loop (cdr sids)))))))
	     (if sid
		 (begin
		   (add-control! sid ellipses syntax-error)
		   (sid-expression sid))
		 `(,r-rename ,(syntax-quote template)))))
	  ((or (zero-or-more? template rename compare)
	       (at-least-one? template rename compare))
	   (optimized-append rename compare
			     (let ((ellipsis (make-ellipsis '())))
			       (generate-ellipsis rename
						  ellipsis
						  (loop (car template)
							(cons ellipsis
							      ellipses))))
			     (loop (cddr template) ellipses)))
	  ((pair? template)
	   (optimized-cons rename compare
			   (loop (car template) ellipses)
			   (loop (cdr template) ellipses)))
	  (else
	   `(,(rename 'QUOTE) ,template)))))

(define (add-control! sid ellipses syntax-error)
  (let loop ((sid sid) (ellipses ellipses))
    (let ((control (sid-control sid)))
      (cond (control
	     (if (null? ellipses)
		 (syntax-error "missing ellipsis in expansion" #f)
		 (let ((sids (ellipsis-sids (car ellipses))))
		   (cond ((not (memq control sids))
			  (set-ellipsis-sids! (car ellipses)
					      (cons control sids)))
			 ((not (eq? control (car sids)))
			  (syntax-error "illegal control/ellipsis combination"
					control sids)))))
	     (loop control (cdr ellipses)))
	    ((not (null? ellipses))
	     (syntax-error "extra ellipsis in expansion" #f))))))

(define (generate-ellipsis rename ellipsis body)
  (let ((sids (ellipsis-sids ellipsis)))
    (let ((name (sid-name (car sids)))
	  (expression (sid-expression (car sids))))
      (cond ((and (null? (cdr sids))
		  (eq? body name))
	     expression)
	    ((and (null? (cdr sids))
		  (pair? body)
		  (pair? (cdr body))
		  (eq? (cadr body) name)
		  (null? (cddr body)))
	     `(,(rename 'MAP) ,(car body) ,expression))
	    (else
	     `(,(rename 'MAP) (,(rename 'LAMBDA) ,(map sid-name sids) ,body)
			      ,@(map sid-expression sids)))))))

(define (zero-or-more? pattern rename compare)
  (and (pair? pattern)
       (pair? (cdr pattern))
       (identifier? (cadr pattern))
       (compare (cadr pattern) (rename '...))))

(define (at-least-one? pattern rename compare)
;;;  (and (pair? pattern)
;;;       (pair? (cdr pattern))
;;;       (identifier? (cadr pattern))
;;;       (compare (cadr pattern) (rename '+)))
  pattern rename compare		;ignore
  #f)

(define (optimized-cons rename compare a d)
  (cond ((and (pair? d)
	      (compare (car d) (rename 'QUOTE))
	      (pair? (cdr d))
	      (null? (cadr d))
	      (null? (cddr d)))
	 `(,(rename 'LIST) ,a))
	((and (pair? d)
	      (compare (car d) (rename 'LIST))
	      (list? (cdr d)))
	 `(,(car d) ,a ,@(cdr d)))
	(else
	 `(,(rename 'CONS) ,a ,d))))

(define (optimized-append rename compare x y)
  (if (and (pair? y)
	   (compare (car y) (rename 'QUOTE))
	   (pair? (cdr y))
	   (null? (cadr y))
	   (null? (cddr y)))
      x
      `(,(rename 'APPEND) ,x ,y)))

(define sid-type
  (make-record-type "sid" '(NAME EXPRESSION CONTROL OUTPUT-EXPRESSION)))

(define make-sid
  (record-constructor sid-type '(NAME EXPRESSION CONTROL)))

(define sid-name
  (record-accessor sid-type 'NAME))

(define sid-expression
  (record-accessor sid-type 'EXPRESSION))

(define sid-control
  (record-accessor sid-type 'CONTROL))

(define sid-output-expression
  (record-accessor sid-type 'OUTPUT-EXPRESSION))

(define set-sid-output-expression!
  (record-modifier sid-type 'OUTPUT-EXPRESSION))

(define ellipsis-type
  (make-record-type "ellipsis" '(SIDS)))

(define make-ellipsis
  (record-constructor ellipsis-type '(SIDS)))

(define ellipsis-sids
  (record-accessor ellipsis-type 'SIDS))

(define set-ellipsis-sids!
  (record-modifier ellipsis-type 'SIDS))
