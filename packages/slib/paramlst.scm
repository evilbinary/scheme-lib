;;; "paramlst.scm" passing parameters by name.
; Copyright 1995, 1996, 1997, 2001 Aubrey Jaffer
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

;;; Format of arity-spec: (name predicate conversion)

(require 'common-list-functions)

(define arity->arity-spec
  (let ((table
	 `((nary
	    ,(lambda (a) #t)
	    ,identity)
	   (nary1
	    ,(lambda (a) (not (null? a)))
	    ,identity)
	   (single
	    ,(lambda (a) (and (pair? a) (null? (cdr a))))
	    ,car)
	   (optional
	    ,(lambda (a) (or (null? a) (and (pair? a) (null? (cdr a)))))
	    ,identity)
	   (boolean
	    ,(lambda (a)
	       (or (null? a)
		   (and (pair? a) (null? (cdr a)) (boolean? (car a)))))
	    ,(lambda (a) (if (null? a) #f (car a)))))))
    (lambda (arity)
      (assq arity table))))
;@
(define (fill-empty-parameters defaulters parameter-list)
  (map (lambda (defaulter parameter)
	 (cond ((null? (cdr parameter))
		(cons (car parameter)
		      (if defaulter (defaulter parameter-list) '())))
	       (else parameter)))
       defaulters parameter-list))
;@
(define (check-parameters checks parameter-list)
  (and (every (lambda (check parameter)
		(every
		 (lambda (p)
		   (let ((good? (not (and check (not (check p))))))
		     (if (not good?) (slib:warn (car parameter) 'parameter? p))
		     good?))
		 (cdr parameter)))
	      checks parameter-list)
       parameter-list))

(define (check-arities arity-specs parameter-list)
  (every (lambda (arity-spec param)
	   (cond ((not arity-spec) (slib:warn 'missing 'arity arity-specs) #f)
		 (((cadr arity-spec) (cdr param)) #t)
		 ((null? (cdr param)) (slib:warn param 'missing) #f)
		 (else (slib:warn param 'not (car arity-spec)) #f)))
	 arity-specs parameter-list))
;@
(define (parameter-list->arglist positions arities parameter-list)
  (and (= (length arities) (length positions) (length parameter-list))
       (let ((arity-specs (map arity->arity-spec arities))
	     (ans (make-vector (length positions) #f)))
	 (and (check-arities arity-specs parameter-list)
	      (for-each
	       (lambda (pos arity-spec param)
		 (vector-set! ans (+ -1 pos)
			      ((caddr arity-spec) (cdr param))))
	       positions arity-specs parameter-list)
	      (vector->list ans)))))
;@
(define (make-parameter-list parameter-names)
  (map list parameter-names))
;@
(define (parameter-list-ref parameter-list i)
  (let ((ans (assoc i parameter-list)))
    (and ans (cdr ans))))
;@
(define (parameter-list-expand expanders parms)
  (do ((lens (map length parms) (map length parms))
       (olens '() lens))
      ((equal? lens olens))
    (for-each (lambda (expander parm)
		(cond
		 (expander
		  (for-each
		   (lambda (news)
		     (cond ((adjoin-parameters! parms news))
			   (else (slib:error
				  "expanded feature unknown: " news))))
		   (apply append
			  (map (lambda (p)
				 (cond ((expander p))
				       ((not '()) '())
				       (else (slib:error
					      "couldn't expand feature: " p))))
			       (cdr parm)))))))
	      expanders
	      parms)))
;@
(define (adjoin-parameters! parameter-list . parameters)
  (let ((apairs (map (lambda (param)
		       (cond ((pair? param)
			      (assoc (car param) parameter-list))
			     (else (assoc param parameter-list))))
		     parameters)))
    (and (every identity apairs)	;same as APPLY AND?
	 (for-each
	  (lambda (apair param)
	    (cond ((pair? param)
		   (for-each (lambda (o)
			       (if (not (member o (cdr apair)))
				   (set-cdr! apair (cons o (cdr apair)))))
			     (cdr param)))
		  (else (if (not (memv #t (cdr apair)))
			    (set-cdr! apair (cons #t (cdr apair)))))))
	  apairs parameters)
	 parameter-list)))
;@
(define (remove-parameter pname parameter-list)
  (define found? #f)
  (remove-if (lambda (elt)
	       (cond ((not (and (pair? elt) (eqv? pname (car elt)))) #f)
		     (found?
		      (slib:error
		       'remove-parameter 'multiple pname 'in parameter-list))
		     (else (set! found? #t) #t)))
	     parameter-list))
