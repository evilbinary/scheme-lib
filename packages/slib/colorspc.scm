;;; "colorspc.scm" color-space conversions
;Copyright 2001, 2002 Aubrey Jaffer
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
(require 'multiarg/and-)
(require-if 'compiling 'sort)
(require-if 'compiling 'ciexyz)
;@
(define (color:linear-transform matrix row)
  (map (lambda (mrow) (apply + (map * mrow row)))
       matrix))

(define RGB709:into-matrix
  '((  3.240479 -1.537150 -0.498535 )
    ( -0.969256  1.875992  0.041556 )
    (  0.055648 -0.204043  1.057311 )))

;;; http://www.pima.net/standards/it10/PIMA7667/PIMA7667-2001.PDF gives
;;; matrix identical to sRGB:from-matrix, but colors drift under
;;; repeated conversions to and from CIEXYZ.  Instead use RGB709.

(define RGB709:from-matrix
  '((  0.412453  0.357580  0.180423 )
    (  0.212671  0.715160  0.072169 )
    (  0.019334  0.119193  0.950227 )))

;; From http://www.cs.rit.edu/~ncs/color/t_convert.html
;@
(define (CIEXYZ->RGB709 XYZ)
  (color:linear-transform RGB709:into-matrix XYZ))
(define (RGB709->CIEXYZ rgb)
  (color:linear-transform RGB709:from-matrix rgb))

;;; From http://www.w3.org/Graphics/Color/sRGB.html

(define sRGB-log
  (lambda (sv)
    (if (<= sv 0.00304)
	(* 12.92 sv)
	(+ -0.055 (* 1.055 (expt sv 10/24))))))
(define sRGB-exp
  (lambda (x)
    (if (<= x 0.03928)
	(/ x 12.92)
	(expt (/ (+ 0.055 x) 1.055) 2.4))))

;; Clipping as recommended by sRGB spec.
;@
(define (CIEXYZ->sRGB XYZ)
  (map (lambda (sv)
	 (inexact->exact (round (* 255 (sRGB-log (max 0 (min 1 sv)))))))
       (color:linear-transform RGB709:into-matrix XYZ)))
(define (sRGB->CIEXYZ sRGB)
  (color:linear-transform
   RGB709:from-matrix
   (map sRGB-exp
	(map (lambda (b8v) (/ b8v 255.0)) sRGB))))

;;; sRGB values are sometimes written as 24-bit integers 0xRRGGBB
;@
(define (xRGB->sRGB xRGB)
  (list (ash xRGB -16)
	(logand (ash xRGB -8) 255)
	(logand xRGB 255)))
(define (sRGB->xRGB sRGB)
  (apply + (map * sRGB '(#x10000 #x100 #x1))))
;@
(define (xRGB->CIEXYZ xRGB) (sRGB->CIEXYZ (xRGB->sRGB xRGB)))
(define (CIEXYZ->xRGB xyz)   (sRGB->xRGB (CIEXYZ->sRGB xyz)))

;;;  http://www.pima.net/standards/it10/PIMA7667/PIMA7667-2001.PDF
;;;	    Photography - Electronic still picture imaging -
;;;		 Extended sRGB color encoding - e-sRGB

(define e-sRGB-log
  (lambda (sv)
    (cond ((< sv -0.0031308)
	   (- 0.055 (* 1.055 (expt (- sv) 10/24))))
	  ((<= sv 0.0031308)
	   (* 12.92 sv))
	  (else (+ -0.055 (* 1.055 (expt sv 10/24)))))))
(define e-sRGB-exp
  (lambda (x)
    (cond ((< x -0.04045)
	   (- (expt (/ (- 0.055 x) 1.055) 2.4)))
	  ((<= x 0.04045)
	   (/ x 12.92))
	  (else (expt (/ (+ 0.055 x) 1.055) 2.4)))))
;@
(define (CIEXYZ->e-sRGB n XYZ)
  (define two^n-9 (ash 1 (- n 9)))
  (define offset (* 3 (ash 1 (- n 3))))
  (map (lambda (x)
	 (+ (inexact->exact (round (* x 255 two^n-9))) offset))
       (map e-sRGB-log
	    (color:linear-transform
	     RGB709:into-matrix
	     XYZ))))
;@
(define (e-sRGB->CIEXYZ n rgb)
  (define two^n-9 (ash 1 (- n 9)))
  (define offset (* 3 (ash 1 (- n 3))))
  (color:linear-transform
   RGB709:from-matrix
   (map e-sRGB-exp
	(map (lambda (b8v) (/ (- b8v offset) 255.0 two^n-9))
	     rgb))))
;@
(define (sRGB->e-sRGB n sRGB)
  (define two^n-9 (ash 1 (- n 9)))
  (define offset (* 3 (ash 1 (- n 3))))
  (map (lambda (x) (+ offset (* two^n-9 x))) sRGB))
;@
(define (e-sRGB->sRGB n rgb)
  (define two^n-9 (ash 1 (- n 9)))
  (define offset (* 3 (ash 1 (- n 3))))
  (map (lambda (x) (/ (- x offset) two^n-9)) rgb))
;@
(define (e-sRGB->e-sRGB n rgb m)
  (define shft (- m n))
  (cond ((zero? shft) rgb)
	(else (map (lambda (x) (ash x shft)) rgb))))

;;; From http://www.cs.rit.edu/~ncs/color/t_convert.html

;;; CIE 1976 L*a*b* is based directly on CIE XYZ and is an attampt to
;;; linearize the perceptibility of color differences. The non-linear
;;; relations for L*, a*, and b* are intended to mimic the logarithmic
;;; response of the eye. Coloring information is referred to the color
;;; of the white point of the system, subscript n.

;;;; L* is CIE lightness
;;;     L* = 116 * (Y/Yn)^1/3 - 16    for Y/Yn > 0.008856
;;;     L* = 903.3 * Y/Yn             otherwise

(define (CIE:Y/Yn->L* Y/Yn)
  (if (> Y/Yn 0.008856)
      (+ -16 (* 116 (expt Y/Yn 1/3)))
      (* 903.3 Y/Yn)))
(define (CIE:L*->Y/Yn L*)
  (cond ((<= L* (* 903.3 0.008856))
	 (/ L* 903.3))
	((<= L* 100.)
	 (expt (/ (+ L* 16) 116) 3))
	(else 1)))

;;; a* = 500 * ( f(X/Xn) - f(Y/Yn) )
;;; b* = 200 * ( f(Y/Yn) - f(Z/Zn) )
;;;     where f(t) = t^1/3              for t > 0.008856
;;;           f(t) = 7.787 * t + 16/116 otherwise

(define (ab-log t)
  (if (> t 0.008856)
      (expt t 1/3)
      (+ 16/116 (* t 7.787))))
(define (ab-exp f)
  (define f3 (expt f 3))
  (if (> f3 0.008856)
      f3
      (/ (- f 16/116) 7.787)))
;@
(define (CIEXYZ->L*a*b* XYZ . white-point)
  (apply (lambda (X/Xn Y/Yn Z/Zn)
	   (list (CIE:Y/Yn->L* Y/Yn)
		 (* 500 (- (ab-log X/Xn) (ab-log Y/Yn)))
		 (* 200 (- (ab-log Y/Yn) (ab-log Z/Zn)))))
	 (map / XYZ (if (null? white-point)
			CIEXYZ:D65
			(car white-point)))))

;;; Here Xn, Yn and Zn are the tristimulus values of the reference white.
;@
(define (L*a*b*->CIEXYZ L*a*b* . white-point)
  (apply (lambda (Xn Yn Zn)
	   (apply (lambda (L* a* b*)
		    (let* ((Y/Yn (CIE:L*->Y/Yn L*))
			   (fY/Yn (ab-log Y/Yn)))
		      (list (* Xn (ab-exp (+ fY/Yn (/ a* 500))))
			    (* Yn Y/Yn)
			    (* Zn (ab-exp (+ fY/Yn (/ b* -200)))))))
		  L*a*b*))
	 (if (null? white-point)
	     CIEXYZ:D65
	     (car white-point))))

;;; XYZ to CIELUV

;;; CIE 1976 L*u*u* (CIELUV) is based directly on CIE XYZ and is another
;;; attampt to linearize the perceptibility of color differences.  L* is
;;; CIE lightness as for L*a*b* above.  The non-linear relations for u*
;;; and v* are:

;;;     u* =  13 L* ( u' - un' )
;;;     v* =  13 L* ( v' - vn' )

;;; The quantities un' and vn' refer to the reference white or the light
;;; source; for the 2.o observer and illuminant C, un' = 0.2009, vn' =
;;; 0.4610. Equations for u' and v' are given below:

;;;     u' = 4 X / (X + 15 Y + 3 Z)
;;;     v' = 9 Y / (X + 15 Y + 3 Z)

(define (XYZ->uv XYZ)
  (apply (lambda (X Y Z)
	   (define denom (+ X (* 15 Y) (* 3 Z)))
	   (if (zero? denom)
	       '(4. 9.)
	       (list (/ (* 4 X) denom)
		     (/ (* 9 Y) denom))))
	 XYZ))
;@
(define (CIEXYZ->L*u*v* XYZ . white-point)
  (set! white-point (if (null? white-point)
			CIEXYZ:D65
			(car white-point)))
  (let* ((Y/Yn (/ (cadr XYZ) (cadr white-point)))
	 (L* (CIE:Y/Yn->L* Y/Yn)))
    (cons L* (map (lambda (q) (* 13 L* q))
		  (map - (XYZ->uv XYZ) (XYZ->uv white-point))))))

;;; CIELUV to XYZ

;;; The transformation from CIELUV to XYZ is performed as following:

;;;     u' = u / ( 13 L* ) + un
;;;     v' = v / ( 13 L* ) + vn
;;;     X = 9 Y u' / 4 v'
;;;     Z = ( 12 Y - 3 Y u' - 20 Y v' ) / 4 v'
;@
(define (L*u*v*->CIEXYZ L*u*v* . white-point)
  (set! white-point (if (null? white-point)
			CIEXYZ:D65
			(car white-point)))
  (apply (lambda (un vn)
	   (apply (lambda (L* u* v*)
		    (if (not (positive? L*))
			'(0. 0. 0.)
			(let* ((up (+ (/ u* 13 L*) un))
			       (vp (+ (/ v* 13 L*) vn))
			       (Y (* (CIE:L*->Y/Yn L*) (cadr white-point))))
			  (list (/ (* 9 Y up) 4 vp)
				Y
				(/ (* Y (+ 12 (* -3 up) (* -20 vp))) 4 vp)))))
		  L*u*v*))
	 (XYZ->uv white-point)))

;;; http://www.inforamp.net/~poynton/PDFs/coloureq.pdf

(define pi (* 4 (atan 1)))
(define pi/180 (/ pi 180))
;@
(define (L*a*b*->L*C*h lab)
  (define h (/ (atan (caddr lab) (cadr lab)) pi/180))
  (list (car lab)
	(sqrt (apply + (map * (cdr lab) (cdr lab))))
	(if (negative? h) (+ 360 h) h)))
;@
(define (L*C*h->L*a*b* lch)
  (apply (lambda (L* C* h)
	   (set! h (* h pi/180))
	   (list L*
		 (* C* (cos h))
		 (* C* (sin h))))
	 lch))
;@
(define (L*a*b*:DE* lab1 lab2)
  (sqrt (apply + (map (lambda (x) (* x x)) (map - lab1 lab2)))))

;;; http://www.colorpro.com/info/data/cie94.html

(define (color:process-params parametric-factors)
  (define ans
    (case (length parametric-factors)
      ((0) #f)
      ((1) (if (list? parametric-factors)
	       (apply color:process-params parametric-factors)
	       (append parametric-factors '(1 1))))
      ((2) (append parametric-factors '(1)))
      ((3) parametric-factors)
      (else (slib:error 'parametric-factors 'too-many parametric-factors))))
  (and ans
       (for-each (lambda (obj)
		   (if (not (number? obj))
		       (slib:error 'parametric-factors 'not 'number? obj)))
		 ans))
  ans)
;;; http://www.brucelindbloom.com/index.html?Eqn_DeltaE_CIE94.html
;@
(define (L*a*b*:DE*94 lab1 lab2 . parametric-factors)
  (define (square x) (* x x))
  (let ((C1 (sqrt (apply + (map square (cdr lab1)))))
	(C2 (sqrt (apply + (map square (cdr lab2))))))
    (define dC^2 (square (- C1 C2)))
    (sqrt (apply + (map /
			(list (square (- (car lab1) (car lab2)))
			      dC^2
			      (- (apply + (map square
					       (map - (cdr lab1) (cdr lab2))))
				 dC^2))
			(list 1			 ; S_l
			      (+ 1 (* .045 C1))	 ; S_c
			      (+ 1 (* .015 C1))) ; S_h
			(or (color:process-params parametric-factors)
			    '(1 1 1)))))))

;;; CMC-DE is designed only for small color-differences.  But try to do
;;; something reasonable for large differences.  Use bisector (h*) of
;;; the hue angles if separated by less than 90.o; otherwise, pick h of
;;; the color with larger C*.
;@
(define (CMC-DE lch1 lch2 . parametric-factors)
  (apply (lambda (L* C* h_)		;Geometric means
	   (let ((ang1 (* pi/180 (caddr lch1)))
		 (ang2 (* pi/180 (caddr lch2))))
	     (cond ((>= 90 (abs (/ (atan (sin (- ang1 ang2))
					 (cos (- ang1 ang2)))
				   pi/180)))
		    (set! h_ (/ (atan (+ (sin ang1) (sin ang2))
				      (+ (cos ang1) (cos ang2)))
				pi/180)))
		   ((>= (cadr lch1) (cadr lch2)) (caddr lch1))
		   (else (caddr lch2))))
	   (let* ((C*^4 (expt C* 4))
		  (f    (sqrt (/ C*^4 (+ C*^4 1900))))
		  (T    (if (and (> h_ 164) (< h_ 345))
			    (+ 0.56 (abs (* 0.2 (cos (* (+ h_ 168) pi/180)))))
			    (+ 0.36 (abs (* 0.4 (cos (* (+ h_ 35) pi/180)))))))
		  (S_l  (if (< L* 16)
			    0.511
			    (/ (* 0.040975 L*) (+ 1 (* 0.01765 L*)))))
		  (S_c  (+ (/ (* 0.0638 C*) (+ 1 (* 0.0131 C*))) 0.638))
		  (S_h  (* S_c (+ (* (+ -1 T) f) 1))))
	     (sqrt (apply
		    + (map /
			   (map (lambda (x) (* x x)) (map - lch1 lch2))
			   (list S_l S_c S_h)
			   (or (color:process-params parametric-factors)
			       '(2 1 1)))))))
	 (map sqrt (map * lch1 lch2))))

;;; Chromaticity
;@
(define (XYZ->chromaticity XYZ)
  (define sum (apply + XYZ))
  (list (/ (car XYZ) sum) (/ (cadr XYZ) sum)))
;@
(define (chromaticity->CIEXYZ x y)
  (list x y (- 1 x y)))
(define (chromaticity->whitepoint x y)
  (list (/ x y) 1 (/ (- 1 x y) y)))
;@
(define (XYZ->xyY XYZ)
  (define sum (apply + XYZ))
  (if (zero? sum)
      '(0 0 0)
      (list (/ (car XYZ) sum) (/ (cadr XYZ) sum) (cadr XYZ))))
;@
(define (xyY->XYZ xyY)
  (define x (car xyY))
  (define y (cadr xyY))
  (if (zero? y)
      '(0 0 0)
      (let ((Y/y (/ (caddr xyY) y)))
	(list (* Y/y x) (caddr xyY) (* Y/y (- 1 x y))))))
;@
(define (xyY:normalize-colors lst . n)
  (define (nthcdr n lst) (if (zero? n) lst (nthcdr (+ -1 n) (cdr lst))))
  (define Ys (map caddr lst))
  (set! n (if (null? n) 1 (car n)))
  (let ((max-Y (if (positive? n)
		   (* n (apply max Ys))
		   (let ()
		     (require 'sort)
		     (apply max (nthcdr (- n) (sort Ys >=)))))))
    (map (lambda (xyY)
	   (let ((x (max 0 (car xyY)))
		 (y (max 0 (cadr xyY))))
	     (define sum (max 1 (+ x y)))
	     (list (/ x sum)
		   (/ y sum)
		   (max 0 (min 1 (/ (caddr xyY) max-Y))))))
	 lst)))

;;;  http://www.aim-dtp.net/aim/technology/cie_xyz/cie_xyz.htm:
;;;  Illuminant D65                           0.312713 0.329016
;; (define CIEXYZ:D65 (chromaticity->whitepoint 0.312713 0.329016))
;; (define CIEXYZ:D65 (chromaticity->whitepoint 0.3127 0.3290))
;@
(define CIEXYZ:D50 (chromaticity->whitepoint 0.3457 0.3585))

;;; With its 16-bit resolution, e-sRGB-16 is extremely sensitive to
;;; whitepoint.  Even the 6 digits of precision specified above is
;;; insufficient to make (color->e-srgb 16 d65) ==> (57216 57216 57216)
;@
(define CIEXYZ:D65 (e-sRGB->CIEXYZ 16 '(57216 57216 57216)))

;;; http://www.efg2.com/Lab/Graphics/Colors/Chromaticity.htm CIE 1931:
;@
(define CIEXYZ:A (chromaticity->whitepoint 0.44757 0.40745)) ; 2856.K
(define CIEXYZ:B (chromaticity->whitepoint 0.34842 0.35161)) ; 4874.K
(define CIEXYZ:C (chromaticity->whitepoint 0.31006 0.31616)) ; 6774.K
(define CIEXYZ:E (chromaticity->whitepoint 1/3 1/3)) ; 5400.K

;;; Converting spectra
(define cie:x-bar #f)
(define cie:y-bar #f)
(define cie:z-bar #f)
;@
(define (load-ciexyz . path)
  (let ((path (if (null? path)
		  (in-vicinity (library-vicinity) "cie1931.xyz")
		  (car path))))
    (set! cie:x-bar (make-vector 80))
    (set! cie:y-bar (make-vector 80))
    (set! cie:z-bar (make-vector 80))
    (call-with-input-file path
      (lambda (iprt)
	(do ((wlen 380 (+ 5 wlen))
	     (idx 0 (+ 1 idx)))
	    ((>= wlen 780))
	  (let ((rlen (read iprt)))
	    (if (not (eqv? wlen rlen))
		(slib:error path 'expected wlen 'not rlen))
	    (vector-set! cie:x-bar idx (read iprt))
	    (vector-set! cie:y-bar idx (read iprt))
	    (vector-set! cie:z-bar idx (read iprt))))))))
;@
(define (read-cie-illuminant path)
  (define siv (make-vector 107))
  (call-with-input-file path
    (lambda (iprt)
      (do ((idx 0 (+ 1 idx)))
	  ((>= idx 107) siv)
	(vector-set! siv idx (read iprt))))))
;@
(define (read-normalized-illuminant path)
  (define siv (read-cie-illuminant path))
  (let ((yw (/ (cadr (spectrum->XYZ siv 300e-9 830e-9)))))
    (illuminant-map (lambda (w x) (* x yw)) siv)))
;@
(define (illuminant-map proc siv)
  (define prod (make-vector 107))
  (do ((idx 106 (+ -1 idx))
       (w 830e-9 (+ -5e-9 w)))
      ((negative? idx) prod)
    (vector-set! prod idx (proc w (vector-ref siv idx)))))
;@
(define (illuminant-map->XYZ proc siv)
  (spectrum->XYZ (illuminant-map proc siv) 300e-9 830e-9))
;@
(define (wavelength->XYZ wl)
  (if (not cie:y-bar) (require 'ciexyz))
  (set! wl (- (/ wl 5.e-9) 380/5))
  (if (<= 0 wl (+ -1 400/5))
      (let* ((wlf (inexact->exact (floor wl)))
	     (res (- wl wlf)))
	(define (interpolate vect idx res)
	  (+ (* (- 1 res) (vector-ref vect idx))
	     (* res (vector-ref vect (+ 1 idx)))))
	(list (interpolate cie:x-bar wlf res)
	      (interpolate cie:y-bar wlf res)
	      (interpolate cie:z-bar wlf res)))
      (slib:error 'wavelength->XYZ 'out-of-range wl)))
(define (wavelength->chromaticity wl)
  (XYZ->chromaticity (wavelength->XYZ wl)))
;@
(define (spectrum->XYZ . args)
  (define x 0)
  (define y 0)
  (define z 0)
  (if (not cie:y-bar) (require 'ciexyz))
  (case (length args)
    ((1)
     (set! args (car args))
     (do ((wvln 380.e-9 (+ 5.e-9 wvln))
	  (idx 0 (+ 1 idx)))
	 ((>= idx 80) (map (lambda (x) (/ x 80)) (list x y z)))
       (let ((inten (args wvln)))
	 (set! x (+ x (* (vector-ref cie:x-bar idx) inten)))
	 (set! y (+ y (* (vector-ref cie:y-bar idx) inten)))
	 (set! z (+ z (* (vector-ref cie:z-bar idx) inten))))))
    ((3)
     (let* ((vect (if (list? (car args)) (list->vector (car args)) (car args)))
	    (vlen (vector-length vect))
	    (x1 (cadr args))
	    (x2 (caddr args))
	    (xinc (/ (- x2 x1) (+ -1 vlen)))
	    (x->j (lambda (x) (inexact->exact (round (/ (- x x1) xinc)))))
	    (x->k (lambda (x) (inexact->exact (round (/ (- x 380.e-9) 5.e-9)))))
	    (j->x (lambda (j) (+ x1 (* j xinc))))
	    (k->x (lambda (k) (+ 380.e-9 (* k 5.e-9))))
	    (xlo (max (min x1 x2) 380.e-9))
	    (xhi (min (max x1 x2) 780.e-9))
	    (jhi (x->j xhi))
	    (khi (x->k xhi))
	    (jinc (if (negative? xinc) -1 1)))
       (if (<= (abs xinc) 5.e-9)
	   (do ((wvln (j->x (x->j xlo)) (+ wvln (abs xinc)))
		(jdx (x->j xlo) (+ jdx jinc)))
	       ((>= jdx jhi)
		(let ((nsmps (abs (- jhi (x->j xlo)))))
		  (map (lambda (x) (/ x nsmps)) (list x y z))))
	     (let ((ciedex (min 79 (x->k wvln)))
		   (inten (vector-ref vect jdx)))
	       (set! x (+ x (* (vector-ref cie:x-bar ciedex) inten)))
	       (set! y (+ y (* (vector-ref cie:y-bar ciedex) inten)))
	       (set! z (+ z (* (vector-ref cie:z-bar ciedex) inten)))))
	   (do ((wvln (k->x (x->k xlo)) (+ wvln 5.e-9))
		(kdx (x->k xlo) (+ kdx 1)))
	       ((>= kdx khi)
		(let ((nsmps (abs (- khi (x->k xlo)))))
		  (map (lambda (x) (/ x nsmps)) (list x y z))))
	     (let ((inten (vector-ref vect (x->j wvln))))
	       (set! x (+ x (* (vector-ref cie:x-bar kdx) inten)))
	       (set! y (+ y (* (vector-ref cie:y-bar kdx) inten)))
	       (set! z (+ z (* (vector-ref cie:z-bar kdx) inten))))))))
    (else (slib:error 'spectrum->XYZ 'wna args))))
(define (spectrum->chromaticity . args)
  (XYZ->chromaticity (apply spectrum->XYZ args)))
;@
(define blackbody-spectrum
  (let* ((c 2.998e8)
	 (h 6.626e-34)
	 (h*c (* h c))
	 (k 1.381e-23)
	 (pi*2*h*c*c (* 2 pi h*c c)))
    (lambda (temp . span)
      (define h*c/kT (/ h*c k temp))
      (define pi*2*h*c*c*span
	(* pi*2*h*c*c (if (null? span) 1.e-9 (car span))))
      (lambda (x)
	(/ pi*2*h*c*c*span
	   (expt x 5)
	   (- (exp (/ h*c/kT x)) 1))))))
;@
(define (temperature->XYZ temp . span)
  (spectrum->XYZ (apply blackbody-spectrum temp span)))	;was .5e-9
(define (temperature->chromaticity temp)
  (XYZ->chromaticity (temperature->XYZ temp)))
