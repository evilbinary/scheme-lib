;;; "srfi.scm" Implement Scheme Request for Implementation	-*-scheme-*-
; Copyright 2001 Aubrey Jaffer
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

;;@code{(require 'srfi)}
;;@ftindex srfi
;;
;;@noindent Implements @dfn{Scheme Request For Implementation} (SRFI) as
;;described at @url{http://srfi.schemers.org/}

;;@args <clause1> <clause2> @dots{}
;;
;;@emph{Syntax:}
;;Each @r{<clause>} should be of the form
;;
;;@format
;;@t{(@r{<feature>} @r{<expression1>} @dots{})}
;;@end format
;;
;;where @r{<feature>} is a boolean expression composed of symbols and
;;`and', `or', and `not' of boolean expressions.  The last @r{<clause>}
;;may be an ``else clause,'' which has the form
;;
;;@format
;;@t{(else @r{<expression1>} @r{<expression2>} @dots{})@r{.}}
;;@end format
;;
;;The first clause whose feature expression is satisfied is expanded.
;;If no feature expression is satisfied and there is no else clause, an
;;error is signaled.
;;
;;SLIB @0 is an extension of SRFI-0,
;;@url{http://srfi.schemers.org/srfi-0/srfi-0.html}.
(defmacro cond-expand clauses
  (letrec ((errout
	    (lambda (form exp)
	      (slib:error 'cond-expand 'invalid form ': exp)))
	   (feature?
	    (lambda (exp)
	      (cond ((symbol? exp)
		     (or (provided? exp) (eq? exp (software-type))))
		    ((and (pair? exp) (list? exp))
		     (case (car exp)
		       ((not) (not (feature? (cadr exp))))
		       ((or) (if (null? (cdr exp)) #f
				 (or (feature? (cadr exp))
				     (feature? (cons 'or (cddr exp))))))
		       ((and) (if (null? (cdr exp)) #t
				  (and (feature? (cadr exp))
				       (feature? (cons 'and (cddr exp))))))
		       (else (errout 'expression exp)))))))
	   (expand
	    (lambda (clauses)
	      (cond ((null? clauses) (slib:error 'Unfulfilled 'cond-expand))
		    ((not (pair? (car clauses))) (errout 'clause (car clauses)))
		    ((or (eq? 'else (caar clauses)) (feature? (caar clauses)))
		     `(begin ,@(cdar clauses)))
		    (else (expand (cdr clauses)))))))
    (expand clauses)))
