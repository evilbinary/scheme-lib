;;;; "rmdsff.scm" Space-filling functions and their inverses.
;;; Copyright (C) 2013, 2014 Aubrey Jaffer
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

;;@code{(require 'space-filling)}
;;@ftindex space-filling

;;@ The algorithms and cell properties are described in
;;@url{http://people.csail.mit.edu/jaffer/Geometry/RMDSFF.pdf}

;;; A cell is an object encapsulating the information about a
;;; Hamiltonian path on a rectangular grid of side^rank nodes.
;;; Here are the accessors for a cell:
(define cell-type caar)
(define cell-side cadar)
(define cell-rank caddar)
(define (cell-index cell crds) (apply array-ref (cadadr cell) crds))
(define (cell-coords cell t) (vector-ref (caadr cell) t))
(define (cell-entry cell t) (vector-ref (caddr cell) t))
(define (cell-exit cell t) (vector-ref (cadddr cell) t))
(define (cell-rotation cell t) (vector-ref (cadddr (cdr cell)) t))

;;@args type rank side precession
;;@args type rank side
;;@args type rank
;;
;;@1 must be the symbol @code{diagonal}, @code{adjacent}, or
;;@code{centered}.  @2 must be an integer larger than 1.  @3, if
;;present, must be an even integer larger than 1 if @1 is
;;@code{adjacent} or an odd integer larger than 2 otherwise; @3
;;defaults to the smallest value.  @4, if present, must be an integer
;;between 0 and @3^@2-1; it is relevant only when @1 is
;;@code{diagonal} or @code{centered}.
;;
;;@args Hamiltonian-path-vector precession
;;@args Hamiltonian-path-vector
;;
;;@1 must be a vector of @var{side}^@var{rank} lists of @var{rank} of
;;integers encoding the coordinate positions of a Hamiltonian path on
;;the @var{rank}-dimensional grid of points starting and ending on
;;corners of the grid.  The starting corner must be the origin
;;(all-zero coordinates). If the side-length is even, then the ending
;;corner must be non-zero in only one coordinate; otherwise, the
;;ending corner must be the furthest diagonally opposite corner from
;;the origin.
;;
;;@code{make-cell} returns a data object suitable for passing as the
;;first argument to @code{integer->coordinates} or
;;@code{coordinates->integer}.
(define (make-cell arg1 . args)
  (define (make-serpentine-path rank s)
    (let loop ((path '(())) (rnk (+ -1 rank)))
      (if (negative? rnk) path
	  (loop (let iloop ((seq '()) (sc (+ -1 s)))
		  (if (negative? sc)
		      seq
		      (iloop (append (map (lambda (coords) (cons sc coords))
					  (if (odd? sc) (reverse path) path))
				     seq)
			     (+ -1 sc))))
		(+ -1 rnk)))))
  (if (list? arg1) (set! arg1 (list->vector arg1)))
  (cond
   ((> (length args) 3)
    (slib:error 'make-cell 'extra 'arguments 'not 'handled args))
   ((vector? arg1)
    (let ((path arg1)
	  (precession (and (not (null? args)) (car args))))
      (define frst (vector-ref path 0))
      (define len (vector-length path))
      (define s-1 (apply max (apply append (vector->list path))))
      (let* ((len-1 (+ -1 len))
	     (last (vector-ref path len-1))
	     (d (length frst)))
	;; returns index of first non-zero in LST
	(define (first-non-zero lst)
	  (define pos (lambda (n lst)
			(cond ((zero? (car lst)) (pos (+ 1 n) (cdr lst)))
			      (else n))))
	  (pos 0 lst))
	;; returns the traversal direction of the sub-path.
	(define (U_e N t)
	  (if (= t len-1)
	      (map - (vector-ref path t) (vector-ref path (- t 1)))
	      (let ((dH_i+1 (map - (vector-ref path (+ t 1)) (vector-ref path t))))
		(define dotpr (apply + (map * N dH_i+1)))
		(define csum (apply + dH_i+1))
		(if (or (and (zero? dotpr) (= 1 csum)) (= dotpr csum -1))
		    dH_i+1
		    (map - (vector-ref path t) (vector-ref path (- t 1)))
		    ))))
	(define (flip-direction dir cdir)
	  (map (lambda (px c) (modulo (+ px c) 2)) dir cdir))
	(define (path-diag? path)
	  (define prev frst)
	  (for-each (lambda (lst)
		      (if (not (= d (length lst)))
			  (slib:error 'non-uniform 'ranks frst lst)))
		    (vector->list path))
	  (for-each (lambda (cs)
		      (if (not (= 1 (apply + (map abs (map - prev cs)))))
			  (slib:error 'bad 'step prev cs))
		      (set! prev cs))
		    (cdr (vector->list path)))
	  (cond ((not (zero? (apply + frst))) (slib:error 'strange 'start frst))
		((not (= d (length last))) (slib:error 'non-uniform 'lengths path))
		((apply = s-1 last) #t)
		((and (= s-1 (apply + last))) #f)
		(else (slib:error 'strange 'net-travel frst last))))
	(define diag? (path-diag? path))
	(define entries (make-vector len (vector-ref path 0)))
	(define exits (make-vector
		       len (if diag?
			       (map (lambda (c) (quotient c s-1)) last)
			       (vector-ref path 1))))
	(define rotations (make-vector len 0))
	(define ipath (apply make-array
			     (A:fixZ32b -1)
			     (vector->list (make-vector d (+ 1 s-1)))))
	(define ord 0)
	(for-each (lambda (coords)
		    (apply array-set! ipath ord coords)
		    (set! ord (+ 1 ord)))
		  (vector->list path))
	(let lp ((t 1)
		 (prev-X (if diag?
			     (map (lambda (c) 1) (vector-ref entries 0))
			     (vector-ref path 1))))
	  (cond ((> t len-1)
		 (if (not (equal? (vector-ref exits len-1)
				  (map (lambda (c) (quotient c s-1)) last)))
		     (slib:warn (list (if diag? 'diagonal 'adjacent)
				      (+ 1 s-1) d precession)
				'bad 'last 'exit
				(vector-ref exits len-1) 'should 'be
				(map (lambda (c) (quotient c s-1)) last)))
		 (let ((ord 0)
		       (h (first-non-zero last)))
		   (for-each
		    (lambda (coords)
		      (vector-set! rotations
				   ord
				   (modulo
				    (cond ((not diag?)
					   (- h (first-non-zero
						 (map -
						      (vector-ref exits ord)
						      (vector-ref entries ord)))))
					  (precession (+ precession ord))
					  (else 0))
				    d))
		      (set! ord (+ 1 ord)))
		    (vector->list path)))
		 (list (list (if diag? 'diagonal 'adjacent)
			     (+ 1 s-1)
			     d
			     precession)
		       (list path ipath)
		       entries
		       exits
		       rotations
		       ))
		(else
		 (let ((N (flip-direction
			   prev-X
			   (map - (vector-ref path t)
				(vector-ref path (- t 1))))))
		   (define X (if diag?
				 (map (lambda (tn) (- 1 tn)) N)
				 (flip-direction N (U_e N t))))
		   (vector-set! entries t N)
		   (vector-set! exits t X)
		   (lp (+ 1 t) X))))))))
   ((< (car args) 2)
    (slib:error 'make-cell 'rank 'too 'small (car args)))
   (else
    (case arg1
      ((center centered)
       (let ((cell (make-cell (make-serpentine-path
			       (car args)
			       (if (null? (cdr args)) 3 (cadr args)))
			      (if (= 3 (length args)) (caddr args) #f))))
	 (if (not (eq? 'diagonal (cell-type cell)))
	     (slib:error 'make-cell 'centered 'must 'be 'diagonal (car cell)))
	 (set-car! (car cell) 'centered)
	 cell))
      ((diagonal opposite)
       (make-cell (make-serpentine-path
		   (car args)
		   (if (null? (cdr args)) 3 (cadr args)))
		  (if (= 3 (length args)) (caddr args) #f)))
      ((adjacent)
       (make-cell (make-serpentine-path
		   (car args)
		   (if (null? (cdr args)) 2 (cadr args)))
		  (if (= 3 (length args)) (caddr args) #f)))
      (else
       (slib:error 'make-cell 'unknown 'cell 'type arg1))))))

;;@ Hilbert, Peano, and centered Peano cells are generated
;;respectively by:
;;@example
;;(make-cell 'adjacent @var{rank} 2)   ; Hilbert
;;(make-cell 'diagonal @var{rank} 3)   ; Peano
;;(make-cell 'centered @var{rank} 3)   ; centered Peano
;;@end example

;; Positive k rotates left
(define (rotate-list lst k)
  (define len (length lst))
  (cond ((<= len 1) lst)
	(else
	 (set! k (modulo k len))
	 (if (zero? k)
	     lst
	     (let ((ans (list (car lst))))
	       (do ((ls (cdr lst) (cdr ls))
		    (tail ans (cdr tail))
		    (k (+ -1 k) (+ -1 k)))
		   ((<= k 0)
		    (append ls ans))
		 (set-cdr! tail (list (car ls)))))))))

;;@ In the conversion procedures, if the cell is @code{diagonal} or
;;@code{adjacent}, then the coordinates and scalar must be nonnegative
;;integers.  If @code{centered}, then the integers can be negative.

;;@body
;;@0 converts the integer @2 to a list of coordinates according to @1.
(define (integer->coordinates cell u)
  (define umag (case (cell-type cell)
		 ((centered) (* (abs u) 2))
		 (else u)))
  (define d (cell-rank cell))
  (define s (cell-side cell))
  (let* ((s^d (expt s d))
	 (s^d^2 (expt s^d d)))
    (define (align V t sde)
      (map (lambda (Vj Nj) (if (zero? Nj) Vj (- sde Vj)))
	   (rotate-list V (cell-rotation cell t))
	   (cell-entry cell t)))
    (define (rec u m w)
      (if (positive? w)
	  (let ((t (quotient u m)))
	    (map +
		 (map (lambda (y) (* y w)) (cell-coords cell t))
		 (align (rec (modulo u m) (quotient m s^d) (quotient w s))
			t
			(- w 1))))
	  (cell-coords cell 0)))
    (do ((uscl 1 (* uscl s^d^2))
	 (cscl 1 (* cscl s^d)))
	((> uscl umag)
	 (case (cell-type cell)
	   ((centered)
	    (let ((cscl/2 (quotient cscl 2)))
	      (map (lambda (c) (- c cscl/2))
		   (rec (+ u (quotient uscl 2))
			(quotient uscl s^d)
			(quotient cscl s)))))
	   (else (rec u (quotient uscl s^d) (quotient cscl s))))))))

;;@body
;;@0 converts the list of coordinates @2 to an integer according to @1.
(define (coordinates->integer cell V)
  (define maxc (case (cell-type cell)
		 ((centered) (* 2 (apply max (map abs V))))
		 (else (apply max V))))
  (define d (cell-rank cell))
  (define s (cell-side cell))
  (let* ((s^d (expt s d))
	 (s^d^2 (expt s^d d)))
    (define (align^-1 V t sde)
      (rotate-list (map (lambda (Vj Nj) (if (zero? Nj) Vj (- sde Vj)))
			V
			(cell-entry cell t))
		   (- (cell-rotation cell t))))
    (define (rec u V w)
      (if (positive? w)
	  (let ((dig (cell-index cell (map (lambda (c) (quotient c w)) V))))
	    (rec (+ dig (* s^d u))
		 (align^-1 (map (lambda (cx) (modulo cx w)) V)
			   dig
			   (- w 1))
		 (quotient w s)))
	  u))
    (do ((uscl 1 (* uscl s^d^2))
	 (cscl 1 (* cscl s^d)))
	((> cscl maxc)
	 (case (cell-type cell)
	   ((centered)
	    (let ((cscl/2 (quotient cscl 2)))
	      (- (rec 0
		      (map (lambda (c) (+ c cscl/2)) V)
		      (quotient cscl s))
		 (quotient uscl 2))))
	   (else (rec 0 V (quotient cscl s))))))))

;;@var{coordinates->integer} and @var{integer->coordinates} are
;;inverse functions when passed the same @var{cell} argument.
