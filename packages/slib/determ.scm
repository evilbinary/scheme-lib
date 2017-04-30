;;; "determ.scm" Matrix Algebra
;Copyright 2002, 2004 Aubrey Jaffer
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

(require 'array)
(require 'multiarg-apply)

;;@code{(require 'determinant)}
;;@ftindex determinant

;;@noindent
;;A Matrix can be either a list of lists (rows) or an array.
;;Unlike linear-algebra texts, this package uses 0-based coordinates.

;;; Internal conversion routines
(define (matrix2array matrix prototype)
  (let* ((dim1 (length matrix))
	 (dim2 (length (car matrix)))
	 (mat (make-array '#() dim1 dim2)))
    (do ((idx 0 (+ 1 idx))
	 (rows matrix (cdr rows)))
	((>= idx dim1) rows)
      (do ((jdx 0 (+ 1 jdx))
	   (row (car rows) (cdr row)))
	  ((>= jdx dim2))
	(array-set! mat (car row) idx jdx)))
    mat))
(define (matrix2lists matrix)
  (let ((dims (array-dimensions matrix)))
    (do ((idx (+ -1 (car dims)) (+ -1 idx))
	 (rows '()
	       (cons (do ((jdx (+ -1 (cadr dims)) (+ -1 jdx))
			  (row '() (cons (array-ref matrix idx jdx) row)))
			 ((< jdx 0) row))
		     rows)))
	((< idx 0) rows))))
(define (coerce-like-arg matrix arg)
  (cond ((array? arg) (matrix2array matrix arg))
	(else matrix)))

;;@body
;;Returns the list-of-lists form of @1.
(define (matrix->lists matrix)
  (cond ((array? matrix)
	 (if (not (eqv? 2 (array-rank matrix)))
	     (slib:error 'not 'matrix matrix))
	 (matrix2lists matrix))
	((and (pair? matrix) (list? (car matrix))) matrix)
	((vector? matrix) (list (vector->list matrix)))
	(else (slib:error 'not 'matrix matrix))))

;;@body
;;Returns the array form of @1.
(define (matrix->array matrix)
  (cond ((array? matrix)
	 (if (not (eqv? 2 (array-rank matrix)))
	     (slib:error 'not 'matrix matrix))
	 matrix)
	((and (pair? matrix) (list? (car matrix)))
	 (matrix2array matrix '#()))
	((vector? matrix) matrix)
	(else (slib:error 'not 'matrix matrix))))

(define (matrix:cofactor matrix i j)
  (define mat (matrix->lists matrix))
  (define (butnth n lst)
    (if (<= n 1) (cdr lst) (cons (car lst) (butnth (+ -1 n) (cdr lst)))))
  (define (minor matrix i j)
    (map (lambda (x) (butnth j x)) (butnth i mat)))
  (coerce-like-arg
   (* (if (odd? (+ i j)) -1 1) (determinant (minor mat i j)))
   matrix))

;;@body
;;@1 must be a square matrix.
;;@0 returns the determinant of @1.
;;
;;@example
;;(require 'determinant)
;;(determinant '((1 2) (3 4))) @result{} -2
;;(determinant '((1 2 3) (4 5 6) (7 8 9))) @result{} 0
;;@end example
(define (determinant matrix)
  (define mat (matrix->lists matrix))
  (let ((n (length mat)))
    (if (eqv? 1 n) (caar mat)
	(do ((j n (+ -1 j))
	     (ans 0 (+ ans (* (list-ref (car mat) (+ -1 j))
			      (matrix:cofactor mat 1 j)))))
	    ((<= j 0) ans)))))

;;@body
;;Returns a copy of @1 flipped over the diagonal containing the 1,1
;;element.
(define (transpose matrix)
  (if (number? matrix)
      matrix
      (let ((mat (matrix->lists matrix)))
	(coerce-like-arg (apply map list mat)
			  matrix))))

;;@body
;;Returns the element-wise sum of matricies @1 and @2.
(define (matrix:sum m1 m2)
  (define mat1 (matrix->lists m1))
  (define mat2 (matrix->lists m2))
  (coerce-like-arg (map (lambda (row1 row2) (map + row1 row2)) mat1 mat2)
		   m1))

;;@body
;;Returns the element-wise difference of matricies @1 and @2.
(define (matrix:difference m1 m2)
  (define mat1 (matrix->lists m1))
  (define mat2 (matrix->lists m2))
  (coerce-like-arg (map (lambda (row1 row2) (map - row1 row2)) mat1 mat2)
		   m1))

(define (matrix:scale m1 scl)
  (coerce-like-arg (map (lambda (row1) (map (lambda (x) (* scl x)) row1))
			(matrix->lists m1))
		   m1))

;;@args m1 m2
;;Returns the product of matrices @1 and @2.
;;@args m1 z
;;Returns matrix @var{m1} times scalar @var{z}.
;;@args z m1
;;Returns matrix @var{m1} times scalar @var{z}.
(define (matrix:product m1 m2)
  (cond ((number? m1) (matrix:scale m2 m1))
	((number? m2) (matrix:scale m1 m2))
	(else
	 (let ((mat1 (matrix->lists m1))
	       (mat2 (matrix->lists m2)))
	   (define (dot-product v1 v2) (apply + (map * v1 v2)))
	   (coerce-like-arg
	    (map (lambda (arow)
		   (apply map
			  (lambda bcol (dot-product bcol arow))
			  mat2))
		 mat1)
	    m1)))))

;;@body
;;@1 must be a square matrix.
;;If @1 is singular, then @0 returns #f; otherwise @0 returns the
;;@code{matrix:product} inverse of @1.
(define (matrix:inverse matrix)
  (let* ((mat (matrix->lists matrix))
	 (det (determinant mat))
	 (rank (length mat)))
    (and (not (zero? det))
	 (do ((i rank (+ -1 i))
	      (inv '() (cons
			(do ((j rank (+ -1 j))
			     (row '()
				  (cons (/ (matrix:cofactor mat j i) det) row)))
			    ((<= j 0) row))
			inv)))
	     ((<= i 0)
	      (coerce-like-arg inv matrix))))))
