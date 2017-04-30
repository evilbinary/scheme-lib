;;;"root.scm" Newton's and Laguerre's methods for finding roots.
;Copyright (C) 1996, 1997 Aubrey Jaffer
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

(require 'logical)

;;;; Newton's Method explained in:
;;; D. E. Knuth, "The Art of Computer Programming", Vol 2 /
;;; Seminumerical Algorithms, Reading Massachusetts, Addison-Wesley
;;; Publishing Company, 2nd Edition, p. 510
;@
(define (newton:find-integer-root f df/dx x_0)
  (let loop ((x x_0) (fx (f x_0)))
    (cond
     ((zero? fx) x)
     (else
      (let ((df (df/dx x)))
	(cond
	 ((zero? df) #f)		; stuck at local min/max
	 (else
	  (let* ((delta (quotient (+ fx (quotient df 2)) df))
		 (next-x (cond ((not (zero? delta)) (- x delta))
			       ((positive? fx) (- x 1))
			       (else (- x -1))))
		 (next-fx (f next-x)))
	    (cond ((>= (abs next-fx) (abs fx)) x)
		  (else (loop next-x next-fx)))))))))))

;;(define (integer-sqrt y)
;;  (newton:find-integer-root (lambda (x) (- (* x x) y))
;;			    (lambda (x) (* 2 x))
;;			    (ash 1 (quotient (integer-length y) 2))))

;@
(define (newton:find-root f df/dx x_0 prec)
  (if (and (negative? prec) (integer? prec))
      (let loop ((x x_0) (fx (f x_0)) (count prec))
	(cond ((zero? count) x)
	      (else (let ((df (df/dx x)))
		      (cond ((zero? df) #f) ; stuck at local min/max
			    (else (let* ((next-x (- x (/ fx df)))
					 (next-fx (f next-x)))
				    (cond ((= next-x x) x)
					  ((> (abs next-fx) (abs fx)) #f)
					  (else (loop next-x next-fx
						      (+ 1 count)))))))))))
      (let loop ((x x_0) (fx (f x_0)))
	(cond ((< (abs fx) prec) x)
	      (else (let ((df (df/dx x)))
		      (cond ((zero? df) #f) ; stuck at local min/max
			    (else (let* ((next-x (- x (/ fx df)))
					 (next-fx (f next-x)))
				    (cond ((= next-x x) x)
					  ((> (abs next-fx) (abs fx)) #f)
					  (else (loop next-x next-fx))))))))))))

;;; H. J. Orchard, "The Laguerre Method for Finding the Zeros of
;;; Polynomials", IEEE Transactions on Circuits and Systems, Vol. 36,
;;; No. 11, November 1989, pp 1377-1381.
;@
(define (laguerre:find-root f df/dz ddf/dz^2 z_0 prec)
  (if (and (negative? prec) (integer? prec))
      (let loop ((z z_0) (fz (f z_0)) (count prec))
	(cond ((zero? count) z)
	      (else
	       (let* ((df (df/dz z))
		      (ddf (ddf/dz^2 z))
		      (disc (sqrt (- (* df df) (* fz ddf)))))
		 (if (zero? disc)
		     #f
		     (let* ((next-z
			     (- z (/ fz (if (negative? (+ (* (real-part df)
							     (real-part disc))
							  (* (imag-part df)
							     (imag-part disc))))
					    (- disc) disc))))
			    (next-fz (f next-z)))
		       (cond ((>= (magnitude next-fz) (magnitude fz)) z)
			     (else (loop next-z next-fz (+ 1 count))))))))))
      (let loop ((z z_0) (fz (f z_0)) (delta-z #f))
	(cond ((< (magnitude fz) prec) z)
	      (else
	       (let* ((df (df/dz z))
		      (ddf (ddf/dz^2 z))
		      (disc (sqrt (- (* df df) (* fz ddf)))))
		 ;;(print 'disc disc)
		 (if (zero? disc)
		     #f
		     (let* ((next-z
			     (- z (/ fz (if (negative? (+ (* (real-part df)
							     (real-part disc))
							  (* (imag-part df)
							     (imag-part disc))))
					    (- disc) disc))))
			    (next-delta-z (magnitude (- next-z z))))
		       ;;(print 'next-z next-z )
		       ;;(print '(f next-z) (f next-z))
		       ;;(print 'delta-z delta-z 'next-delta-z next-delta-z)
		       (cond ((zero? next-delta-z) z)
			     ((and delta-z (>= next-delta-z delta-z)) z)
			     (else
			      (loop next-z (f next-z) next-delta-z)))))))))))
;@
(define (laguerre:find-polynomial-root deg f df/dz ddf/dz^2 z_0 prec)
  (if (and (negative? prec) (integer? prec))
      (let loop ((z z_0) (fz (f z_0)) (count prec))
	(cond ((zero? count) z)
	      (else
	       (let* ((df (df/dz z))
		      (ddf (ddf/dz^2 z))
		      (tmp (* (+ deg -1) df))
		      (sqrt-H (sqrt (- (* tmp tmp) (* deg (+ deg -1) fz ddf))))
		      (df+sqrt-H (+ df sqrt-H))
		      (df-sqrt-H (- df sqrt-H))
		      (next-z
		       (- z (/ (* deg fz)
			       (if (>= (magnitude df+sqrt-H)
				       (magnitude df-sqrt-H))
				   df+sqrt-H
				   df-sqrt-H)))))
		 (loop next-z (f next-z) (+ 1 count))))))
      (let loop ((z z_0) (fz (f z_0)))
	(cond ((< (magnitude fz) prec) z)
	      (else
	       (let* ((df (df/dz z))
		      (ddf (ddf/dz^2 z))
		      (tmp (* (+ deg -1) df))
		      (sqrt-H (sqrt (- (* tmp tmp) (* deg (+ deg -1) fz ddf))))
		      (df+sqrt-H (+ df sqrt-H))
		      (df-sqrt-H (- df sqrt-H))
		      (next-z
		       (- z (/ (* deg fz)
			       (if (>= (magnitude df+sqrt-H)
				       (magnitude df-sqrt-H))
				   df+sqrt-H
				   df-sqrt-H)))))
		 (loop next-z (f next-z))))))))

(define (secant:find-root-1 f x0 x1 prec must-bracket?)
  (letrec ((stop?
	    (cond ((procedure? prec) prec)
		  ((and (integer? prec) (negative? prec))
		   (lambda (x0 f0 x1 f1 count)
		     (>= count (- prec))))
		  (else
		   (lambda (x0 f0 x1 f1 count)
		     (and (< (abs f0) prec)
			  (< (abs f1) prec))))))
	   (bracket-iter
	    (lambda (xlo flo glo xhi fhi ghi count)
	      (define (step xnew fnew)
		(cond ((or (= xnew xlo)
			   (= xnew xhi))
		       (let ((xmid (+ xlo (* 1/2 (- xhi xlo)))))
			 (if (= xnew xmid)
			     xmid
			     (step xmid (f xmid)))))
		      ((positive? fnew)
		       (bracket-iter xlo flo (if glo (* 0.5 glo) 1)
				     xnew fnew #f
				     (+ count 1)))
		      (else
		       (bracket-iter xnew fnew #f
				     xhi fhi (if ghi (* 0.5 ghi) 1)
				     (+ count 1)))))
	      (if (stop? xlo flo xhi fhi count)
		  (if (> (abs flo) (abs fhi)) xhi xlo)
		  (let* ((fflo (if glo (* glo flo) flo))
			 (ffhi (if ghi (* ghi fhi) fhi))
			 (del (- (/ fflo (- ffhi fflo))))
			 (xnew (+ xlo (* del (- xhi xlo))))
			 (fnew (f xnew)))
		    (step xnew fnew))))))
    (let ((f0 (f x0))
	  (f1 (f x1)))
      (cond ((<= f0 0 f1)
	     (bracket-iter x0 f0 #f x1 f1 #f 0))
	    ((<= f1 0 f0)
	     (bracket-iter x1 f1 #f x0 f0 #f 0))
	    (must-bracket? #f)
	    (else
	     (let secant-iter ((x0 x0)
			       (f0 f0)
			       (x1 x1)
			       (f1 f1)
			       (count 0))
	       (cond ((stop? x0 f0 x1 f1 count)
		      (if (> (abs f0) (abs f1)) x1 x0))
		     ((<= f0 0 f1)
		      (bracket-iter x0 f0 #f x1 f1 #f count))
		     ((>= f0 0 f1)
		      (bracket-iter x1 f1 #f x0 f0 #f count))
		     ((= f0 f1) #f)
		     (else
		      (let ((xnew (+ x0 (* (- (/ f0 (- f1 f0))) (- x1 x0)))))
			(secant-iter x1 f1 xnew (f xnew) (+ count 1)))))))))))
;@
(define (secant:find-root f x0 x1 prec)
  (secant:find-root-1 f x0 x1 prec #f))
(define (secant:find-bracketed-root f x0 x1 prec)
  (secant:find-root-1 f x0 x1 prec #t))
