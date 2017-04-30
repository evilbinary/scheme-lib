;"sierpinski.scm" Hash function for 2d data which preserves nearness.
;From: jjb@isye.gatech.edu (John Bartholdi)
;
; This code is in the public domain.

;Date: Fri, 6 May 94 13:22:34 -0500
;@
(define MAKE-SIERPINSKI-INDEXER
  (lambda (max-coordinate)
    (lambda (x y)
      (if (not (and (<= 0 x max-coordinate)
		    (<= 0 y max-coordinate)))
	  (slib:error 'sierpinski-index
		 "Coordinate exceeds specified maximum.")
	  ;
	  ; The following two mutually recursive procedures
	  ; correspond to to partitioning successive triangles
	  ; into two sub-triangles, adjusting the index according
	  ; to which sub-triangle (x,y) lies in, then rescaling
	  ; and possibly rotating to continue the recursive
	  ; decomposition:
	  ;
	  (letrec ((loopA
		    (lambda (resolution x y index)
		      (cond ((zero? resolution) index)
			    (else
			     (let ((finer-index (+ index index)))
			       (if (> (+ x y) max-coordinate)
				   ;
				   ; In the upper sub-triangle:
				   (loopB resolution
					  (- max-coordinate y)
					  x
					  (+ 1 finer-index))
				   ;
				   ; In the lower sub-triangle:
				   (loopB resolution
					  x
					  y
					  finer-index)))))))
		   (loopB
		    (lambda (resolution x y index)
		      (let ((new-x (+ x x))
			    (new-y (+ y y))
			    (finer-index (+ index index)))
			(if (> new-y max-coordinate)
			    ;
			    ; In the upper sub-triangle:
			    (loopA (quotient resolution 2)
				   (- new-y max-coordinate)
				   (- max-coordinate new-x)
				   (+ finer-index 1))
			    ;
			    ; In the lower sub-triangle:
			    (loopA (quotient resolution 2)
				   new-x
				   new-y
				   finer-index))))))
	    (if (<= x y)
		;
		; Point in NW triangle of initial square:
		(loopA max-coordinate
		       x
		       y
		       0)
		;
		; Else point in SE triangle of initial square
		; so translate point and increase index:
		(loopA max-coordinate
		       (- max-coordinate x)
		       (- max-coordinate y) 1)))))))
