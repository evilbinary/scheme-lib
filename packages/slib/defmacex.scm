;;;"defmacex.scm" defmacro:expand* for any Scheme dialect.
;;;Copyright 1993-1994 Dorai Sitaram and Aubrey Jaffer.
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

;;;expand thoroughly, not just topmost expression.  While expanding
;;;subexpressions, the primitive forms quote, lambda, set!, let/*/rec,
;;;cond, case, do, quasiquote: need to be destructured properly.  (if,
;;;and, or, begin: don't need special treatment.)

(define (defmacro:iqq e depth)
  (letrec
      ((map1 (lambda (f x)
	       (if (pair? x) (cons (f (car x)) (map1 f (cdr x)))
		   x)))
       (iqq (lambda (e depth)
	      (if (pair? e)
		  (case (car e)
		    ((quasiquote) (list (car e) (iqq (cadr e) (+ 1 depth))))
		    ((unquote unquote-splicing)
		     (list (car e) (if (= 1 depth)
				       (defmacro:expand* (cadr e))
				       (iqq (cadr e) (+ -1 depth)))))
		    (else (map1 (lambda (e) (iqq e depth)) e)))
		  e))))
    (iqq e depth)))
;@
(define (defmacro:expand* e)
  (if (pair? e)
      (let* ((c (macroexpand e)))
	(if (not (eq? e c))
	    (defmacro:expand* c)
	    (case (car e)
	      ((quote) e)
	      ((quasiquote) (defmacro:iqq e 0))
	      ((lambda define set!)
	       (cons (car e) (cons (cadr e) (map defmacro:expand* (cddr e)))))
	      ((let)
	       (let ((b (cadr e)))
		 (if (symbol? b)	;named let
		     `(let ,b
			,(map (lambda (vv)
				`(,(car vv)
				  ,(defmacro:expand* (cadr vv))))
			      (caddr e))
			,@(map defmacro:expand*
			       (cdddr e)))
		     `(let
			  ,(map (lambda (vv)
				  `(,(car vv)
				    ,(defmacro:expand* (cadr vv))))
				b)
			,@(map defmacro:expand*
			       (cddr e))))))
	      ((let* letrec)
	       `(,(car e) ,(map (lambda (vv)
				  `(,(car vv)
				    ,(defmacro:expand* (cadr vv))))
				(cadr e))
			  ,@(map defmacro:expand* (cddr e))))
	      ((cond)
	       `(cond
		 ,@(map (lambda (c)
			  (map defmacro:expand* c))
			(cdr e))))
	      ((case)
	       `(case ,(defmacro:expand* (cadr e))
		  ,@(map (lambda (c)
			   `(,(car c)
			     ,@(map defmacro:expand* (cdr c))))
			 (cddr e))))
	      ((do)
	       `(do ,(map
		      (lambda (initsteps)
			`(,(car initsteps)
			  ,@(map defmacro:expand*
				 (cdr initsteps))))
		      (cadr e))
		    ,(map defmacro:expand* (caddr e))
		  ,@(map defmacro:expand* (cdddr e))))
	      ((defmacro)
	       (cons (car e)
		     (cons (cadr e)
			   (cons (caddr e) (map defmacro:expand* (cdddr e))))))
	      (else (map defmacro:expand* e)))))
      e))
