;;;; "charplot.scm", plotting on character devices for Scheme
;;; Copyright (C) 1992, 1993, 2001, 2003 Aubrey Jaffer
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

(require 'printf)
(require 'array)
(require 'array-for-each)
(require 'multiarg/and-)
(require 'multiarg-apply)

;;;@ These determine final graph size.
(define charplot:dimensions #f)

;;; The left margin and legends
(define charplot:left-margin 12)

(define char:xborder #\_)
(define char:yborder #\|)
(define char:xaxis   #\-)
(define char:yaxis   #\:)
(define char:xtick   #\.)
(define char:bar     #\I)
(define char:curves  "*+x@#$%&='")

;;;Converts X to a string whose length is at most MWID.
(define (charplot:number->string x mwid)
  (define str (sprintf #f "%g" x))
  (if (> (string-length str) mwid)
      (substring str 0 mwid)
      str))

;;;SCALE is a list of numerator and denominator.
(define charplot:scale-it
  (if (provided? 'inexact)
      (lambda (z scale)
	(inexact->exact (round (/ (* z (car scale)) (cadr scale)))))
      (lambda (z scale)
	(quotient (+ (* z (car scale)) (quotient (cadr scale) 2))
		  (cadr scale)))))

;;; Given the width or height (in characters) and the data-span,
;;; returns a list of numerator and denominator (NUM DEN) suitable for
;;; passing as a second argument to CHARPLOT:SCALE-IT.
;;;
;;; NUM will be 1, 2, 3, 4, 5, 6, or 8 times a power of ten.
;;; DEN will be a power of ten.
;;;
;;; num   isize
;;; === < =====
;;; den   delta
(define (charplot:find-scale isize delta)
  (cond ((zero? delta) (set! delta 1))
	((inexact? delta) (set! isize (exact->inexact isize))))
  (do ((d 1 (* d 10))
       (isize isize (* isize 10)))
      ((<= delta isize)
       (do ((n 1 (* n 10))
	    (delta delta (* delta 10)))
	   ((>= (* delta 10) isize)
	    (list (* n (cond ((<= (* delta 8) isize) 8)
			     ((<= (* delta 6) isize) 6)
			     ((<= (* delta 5) isize) 5)
			     ((<= (* delta 4) isize) 4)
			     ((<= (* delta 3) isize) 3)
			     ((<= (* delta 2) isize) 2)
			     (else 1)))
		  d))))))

(define (charplot:make-array)
  (let ((height (or (and charplot:dimensions (car charplot:dimensions))
		    (output-port-height (current-output-port))))
	(width (or  (and charplot:dimensions (cadr charplot:dimensions))
		    (output-port-width (current-output-port)))))
    (define pra (make-array " "  height width))
    ;;Put newlines on right edge
    (do ((idx (+ -1 height) (+ -1 idx)))
	((negative? idx))
      (array-set! pra #\newline idx (+ -1 width)))
    pra))

;;;Creates and initializes character array with axes, scales, and
;;;labels.
(define (charplot:init-array pra xlabel ylabel xmin xscale ymin yscale)
  (define plot-height (- (car (array-dimensions pra)) 3))
  (define plot-width (- (cadr (array-dimensions pra)) charplot:left-margin 4))
  (define xaxis (- (charplot:scale-it ymin yscale)))
  (define yaxis (- (charplot:scale-it xmin xscale)))
  (define xstep (if (zero? (modulo (car xscale) 3)) 12 10))
  ;;CL is the left edge of WIDTH field
  (define (center-field str width ln cl)
    (define len (string-length str))
    (if (< width len)
	(center-field (substring str 0 width) width ln cl)
	(do ((cnt (+ -1 len) (+ -1 cnt))
	     (adx (+ (quotient (- width len) 2) cl) (+ 1 adx))
	     (idx 0 (+ 1 idx)))
	    ((negative? cnt))
	  (array-set! pra (string-ref str idx) ln adx))))

  ;;x and y labels
  (center-field ylabel (+ charplot:left-margin -1) 0 0)
  (center-field xlabel (+ -1 charplot:left-margin) (+ 2 plot-height) 0)

  ;;horizontal borders, x-axis, and ticking
  (let ((xstep/2 (quotient (- xstep 2) 2)))
    (define faxis (modulo (+ charplot:left-margin yaxis) xstep))
    (define faxis/2 (modulo (+ charplot:left-margin yaxis xstep/2 1) xstep))
    (define xfudge (modulo yaxis xstep))
    (do ((cl (+ charplot:left-margin -1) (+ 1 cl)))
	((>= cl (+ plot-width charplot:left-margin)))
      (array-set! pra char:xborder 0 cl)
      (array-set! pra
		  (cond ((eqv? faxis (modulo cl xstep)) char:yaxis)
			((eqv? faxis/2 (modulo cl xstep)) char:xtick)
			(else char:xborder))
		  (+ 1 plot-height) cl)
      (if (<= 0 xaxis plot-height)
	  (array-set! pra char:xaxis (- plot-height xaxis) cl)))

    ;;horizontal coordinates
    (do ((i xfudge (+ i xstep))
	 (cl (+ charplot:left-margin xfudge (- xstep/2)) (+ xstep cl)))
	((> i plot-width))
      (center-field (charplot:number->string
		     (/ (* (- i yaxis) (cadr xscale))
			(car xscale))
		     xstep)
		    xstep (+ 2 plot-height) cl)))

  ;;vertical borders and y-axis
  (do ((ht plot-height (- ht 1)))
      ((negative? ht))
    (array-set! pra char:yborder (+ 1 ht) (+ charplot:left-margin -2))
    (array-set! pra char:yborder (+ 1 ht) (+ charplot:left-margin plot-width))
    (if (< -1 yaxis plot-width)
	(array-set! pra char:yaxis (+ 1 ht) (+ charplot:left-margin yaxis))))

  ;;vertical ticking and coordinates
  (do ((ht (- plot-height 1) (- ht 1))
       (ln 1 (+ 1 ln)))
      ((negative? ht))
    (let ((ystep (if (zero? (modulo (car yscale) 3)) 3 2)))
      (if (zero? (modulo (- ht xaxis) ystep))
	  (let* ((v (charplot:number->string (/ (* (- ht xaxis) (cadr yscale))
						(car yscale))
					     (+ charplot:left-margin -2)))
		 (len (string-length v)))
	    (center-field v len ln (- charplot:left-margin 2 len)) ;Actually flush right
	    (array-set! pra char:xaxis ln (+ charplot:left-margin -1))))))
  ;;return initialized array
  pra)

(define (charplot:array->list ra)
  (define dims (array-dimensions ra))
  (if (= 2 (length dims))
      (do ((idx (+ -1 (car dims)) (+ -1 idx))
	   (cols '() (cons (do ((jdx (+ -1 (cadr dims)) (+ -1 jdx))
				(row '() (cons (array-ref ra idx jdx) row)))
			       ((negative? jdx) row))
			   cols)))
	  ((negative? idx) cols))
      (do ((idx (+ -1 (car dims)) (+ -1 idx))
	   (cols '() (cons (array-ref ra idx) cols)))
	  ((negative? idx) cols))))

;;;Converts data to list of coordinates (list).
(define (charplot:data->lists data)
  (cond ((array? data)
	 (case (array-rank data)
	   ((1) (set! data (map list
				(let ((ra (apply make-array '#()
						 (array-dimensions data))))
				  (array-index-map! ra identity)
				  (charplot:array->list ra))
				(charplot:array->list data))))
	   ((2) (set! data (charplot:array->list data)))))
	((and (pair? (car data)) (not (list? (car data))))
	 (set! data (map (lambda (lst) (list (car lst) (cdr lst))) data))))
  (cond ((list? (cadar data))
	 (set! data (map (lambda (lst) (cons (car lst) (cadr lst))) data))))
  data)

;;;An extremum is a list of the maximum and minimum values.
;;;COORDINATE-EXTREMA returns a rank-length list of these.
(define (coordinate-extrema data)
  (define extrema (map (lambda (x) (list x x)) (car data)))
  (for-each (lambda (lst)
	      (set! extrema (map (lambda (x max-min)
				   (list (max x (car max-min))
					 (min x (cadr max-min))))
				 lst extrema)))
	    data)
  extrema)

;;;Count occurrences of numbers within evenly spaced ranges; and return
;;;lists of coordinates for graph.
(define (histobins data plot-width)
  (define datcnt (length data))
  (define xmax (apply max data))
  (define xmin (apply min data))
  (if (null? data)
      '()
      (let* ((xscale (charplot:find-scale plot-width (- xmax xmin)))
	     (actual-width (- (charplot:scale-it xmax xscale)
			      (charplot:scale-it xmin xscale)
			      -1)))
	(define ix-min (charplot:scale-it xmin xscale))
	(define xinc (/ (- xmax xmin) actual-width))
	(define bins (make-vector actual-width 0))
	(for-each (lambda (x)
		    (define idx (- (charplot:scale-it x xscale) ix-min))
		    (if (< -1 idx actual-width)
			(vector-set! bins idx (+ 1 (vector-ref bins idx)))
			(slib:error x (/ (* x (car xscale)) (cadr xscale))
				    (+ ix-min idx))))
		  data)
	(map list
	     (do ((idx (+ -1 (vector-length bins)) (+ -1 idx))
		  (xvl xmax (- xvl xinc))
		  (lst '() (cons xvl lst)))
		 ((negative? idx) lst))
	     (vector->list bins)))))

;;;@ Plot histogram of DATA.
(define (histograph data label)
  (if (vector? data) (set! data (vector->list data)))
  (charplot:plot (histobins data
			    (- (or (and charplot:dimensions
					(cadr charplot:dimensions))
				   (output-port-width (current-output-port)))
			       charplot:left-margin 3))
		 label "" #t))

(define (charplot:plot data xlabel ylabel . histogram?)
  (define clen (string-length char:curves))
  (set! histogram? (if (null? histogram?) #f (car histogram?)))
  (set! data (charplot:data->lists data))
  (let* ((pra (charplot:make-array))
	 (plot-height (- (car (array-dimensions pra)) 3))
	 (plot-width (- (cadr (array-dimensions pra)) charplot:left-margin 4))
	 (extrema (coordinate-extrema data))
	 (xmax (caar extrema))
	 (xmin (cadar extrema))
	 (ymax (apply max (map car (cdr extrema))))
	 (ymin (apply min (map cadr (cdr extrema))))
	 (xscale (charplot:find-scale plot-width (- xmax xmin)))
	 (yscale (charplot:find-scale plot-height (- ymax ymin)))
	 (ix-min (- (charplot:scale-it xmin xscale) charplot:left-margin))
	 (ybot (charplot:scale-it ymin yscale))
	 (iy-min (+ ybot plot-height)))
    (charplot:init-array pra xlabel ylabel xmin xscale ymin yscale)
    (for-each (if histogram?
		  ;;display data bars
		  (lambda (datum)
		    (define x (- (charplot:scale-it (car datum) xscale) ix-min))
		    (do ((y (charplot:scale-it (cadr datum) yscale) (+ -1 y)))
			((< y ybot))
		      (array-set! pra char:bar (- iy-min y) x)))
		  ;;display data points
		  (lambda (datum)
		    (define x (- (charplot:scale-it (car datum) xscale) ix-min))
		    (define cdx 0)
		    (for-each
		     (lambda (y)
		       (array-set! pra (string-ref char:curves cdx)
				   (- iy-min (charplot:scale-it y yscale)) x)
		       (set! cdx (modulo (+ 1 cdx) clen)))
		     (cdr datum))))
	      data)
    (array-for-each write-char pra)
    (if (not (eqv? #\newline (apply array-ref pra
				    (map (lambda (x) (+ -1 x))
					 (array-dimensions pra)))))
	(newline))))

(define (charplot:plot-function func vlo vhi . npts)
  (set! npts (if (null? npts) 64 (car npts)))
  (let ((dats (make-array (A:floR64b) npts 2)))
    (array-index-map! (make-shared-array dats (lambda (idx) (list idx 0)) npts)
		      (lambda (idx)
			(+ vlo (* (- vhi vlo) (/ idx (+ -1 npts))))))
    (array-map! (make-shared-array dats (lambda (idx) (list idx 1)) npts)
		func
		(make-shared-array dats (lambda (idx) (list idx 0)) npts))
    (charplot:plot dats "" "")))
;@
(define (plot . args)
  (if (procedure? (car args))
      (apply charplot:plot-function args)
      (apply charplot:plot args)))
