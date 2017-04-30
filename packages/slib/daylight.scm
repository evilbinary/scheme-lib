;;; "daylight.scm" Model of sun and sky colors.
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

(require 'color-space)

(define pi (* 4 (atan 1)))
(define pi/180 (/ pi 180))

;;@code{(require 'daylight)}
;;@ftindex daylight
;;@ftindex sunlight
;;@ftindex sun
;;@ftindex sky
;;
;;@noindent
;;This package calculates the colors of sky as detailed in:@*
;;@uref{http://www.cs.utah.edu/vissim/papers/sunsky/sunsky.pdf}@*
;;@cite{A Practical Analytic Model for Daylight}@*
;;A. J. Preetham, Peter Shirley, Brian Smits

;;@body
;;
;;Returns the solar-time in hours given the integer @1 in the range 1 to
;;366, and the local time in hours.
;;
;;To be meticulous, subtract 4 minutes for each degree of longitude west
;;of the standard meridian of your time zone.
(define (solar-hour julian-day hour)
  (+ hour
     (* 0.170 (sin (* 4 pi (- julian-day 80) 1/373)))
     (* -0.129 (sin (* 2 pi (- julian-day 8) 1/355)))))

;;@body
(define (solar-declination julian-day)
  (/ (* 0.4093 (sin (* 2 pi (- julian-day 81) 1/368))) pi/180))

;;@body Returns a list of @var{theta_s}, the solar angle from the
;;zenith, and @var{phi_s}, the solar azimuth.  0 <= @var{theta_s}
;;measured in degrees.  @var{phi_s} is measured in degrees from due
;;south; west of south being positive.
(define (solar-polar declination latitude solar-hour)
  (define l (* pi/180 latitude))
  (define d (* pi/180 declination))
  (define pi*t/12 (* pi solar-hour 1/12))
  (map (lambda (x) (/ x pi/180))
       (list (- (/ pi 2) (asin (- (* (sin l) (sin d))
				  (* (cos l) (cos d) (cos pi*t/12)))))
	     (atan (* -1 (cos d) (sin pi*t/12))
		   (- (* (cos l) (sin d))
		      (* (sin l) (cos d) (cos pi*t/12)))))))

;;@noindent
;;In the following procedures, the number 0 <= @var{theta_s} <= 90 is
;;the solar angle from the zenith in degrees.

;;(plot (lambda (t) (+ -.5 (/ 9 (expt 1.55 t)))) 0 6)  ;tweaked

;;@cindex turbidity
;;@noindent
;;Turbidity is a measure of the fraction of scattering due to haze as
;;opposed to molecules.  This is a convenient quantity because it can be
;;estimated based on visibility of distant objects.  This model fails
;;for turbidity values less than 1.3.
;;
;;@example
;;@group
;;    _______________________________________________________________
;;512|-:                                                             |
;;   | * pure-air                                                    |
;;256|-:**                                                           |
;;   | : ** exceptionally-clear                                      |
;;128|-:   *                                                         |
;;   | :    **                                                       |
;; 64|-:      *                                                      |
;;   | :       ** very-clear                                         |
;; 32|-:         **                                                  |
;;   | :           **                                                |
;; 16|-:             *** clear                                       |
;;   | :               ****                                          |
;;  8|-:                  ****                                       |
;;   | :                     **** light-haze                         |
;;  4|-:                         ****                                |
;;   | :                             ******                          |
;;  2|-:                                  ******** haze         thin-|
;;   | :                                          ***********    fog |
;;  1|-:----------------------------------------------------*******--|
;;   |_:____.____:____.____:____.____:____.____:____.____:____.____:_|
;;     1         2         4         8        16        32        64
;;              Meterorological range (km) versus Turbidity
;;@end group
;;@end example

(define sol-spec
  '#(16559.0
     16233.7
     21127.5
     25888.2
     25829.1
     24232.3
     26760.5
     29658.3
     30545.4
     30057.5
     30663.7
     28830.4
     28712.1
     27825.0
     27100.6
     27233.6
     26361.3
     25503.8
     25060.2
     25311.6
     25355.9
     25134.2
     24631.5
     24173.2
     23685.3
     23212.1
     22827.7
     22339.8
     21970.2
     21526.7
     21097.9
     20728.3
     20240.4
     19870.8
     19427.2
     19072.4
     18628.9
     18259.2
     17960				;guesses for the rest
     17730
     17570))

(define k_o-spec
  '#(0.003
     0.006
     0.009
     0.014
     0.021
     0.03
     0.04
     0.048
     0.063
     0.075
     0.085
     0.103
     0.12
     0.12
     0.115
     0.125
     0.12
     0.105
     0.09
     0.079
     0.067
     0.057
     0.048
     0.036
     0.028
     0.023
     0.018
     0.014
     0.011
     0.01
     0.009
     0.007
     0.004
     0))

;;@body Returns a vector of 41 values, the spectrum of sunlight from
;;380.nm to 790.nm for a given @1 and @2.
(define (sunlight-spectrum turbidity theta_s)
  (define (solCurve wl) (vector-ref sol-spec (quotient (- wl 380) 10)))
  (define (k_oCurve wl) (if (>= wl 450)
			    (vector-ref k_o-spec (quotient (- wl 450) 10))
			    0))
  (define (k_gCurve wl) (case wl
			  ((760) 3.0)
			  ((770) 0.21)
			  (else 0)))
  (define (k_waCurve wl) (case wl
			   ((690) 0.016)
			   ((700) 0.024)
			   ((710) 0.0125)
			   ((720) 1)
			   ((730) 0.87)
			   ((740) 0.061)
			   ((750) 0.001)
			   ((760) 1.e-05)
			   ((770) 1.e-05)
			   ((780) 0.0006)
			   (else 0)))

  (define data (make-vector (+ 1 (quotient (- 780 380) 10)) 0.0))
  ;;alpha - ratio of small to large particle sizes. (0:4,usually 1.3)
  (define alpha 1.3)
  ;;beta - amount of aerosols present
  (define beta (- (* 0.04608365822050 turbidity) 0.04586025928522))
  ;;lOzone - amount of ozone in cm(NTP)
  (define lOzone .35)
  ;;w - precipitable water vapor in centimeters (standard = 2)
  (define w 2.0)
  ;;m - Relative Optical Mass
  (define m (/ (+ (cos (* pi/180 theta_s))
		  (* 0.15 (expt (- 93.885 theta_s) -1.253)))))
  (and
   (not (negative? (- 93.885 theta_s)))
   ;; Compute specturm of sunlight
   (do ((wl 780 (+ -5 wl)))
       ((< wl 380) data)
     (let* (;;Rayleigh Scattering
	    ;; paper and program disagree!!  Looks like font-size typo in paper.
	    ;;(tauR (exp (* -0.008735 (expt (/ wl 1000) (* -4.08 m))))) ;sunsky.pdf
	    (tauR (exp (* -0.008735 m (expt (/ wl 1000) -4.08)))) ;RiSunConstants.C
	    ;;Aerosal (water + dust) attenuation
	    ;; paper and program disagree!!  Looks like font-size typo in paper.
	    ;;(tauA (exp (* -1 beta (expt (/ wl 1000) (* -1 m alpha)))))
	    (tauA (exp (* -1 m beta (expt (/ wl 1000) (- alpha)))))
	    ;;Attenuation due to ozone absorption
	    (tauO (exp (* -1 m (k_oCurve wl) lOzone)))
	    ;;Attenuation due to mixed gases absorption
	    (tauG (exp (* -1.41 m (k_gCurve wl)
			  (expt (+ 1 (* 118.93 m (k_gCurve wl))) -0.45))))
	    ;;Attenuation due to water vapor absorbtion
	    (tauWA (exp (* -0.2385 m w (k_waCurve wl)
			   (expt (+ 1 (* 20.07 m w (k_waCurve wl))) -0.45)))))
       (vector-set! data (quotient (- wl 380) 10)
		    (* (solCurve wl) tauR tauA tauO tauG tauWA))))))

;;@body Given @1 and @2, @0 returns the CIEXYZ triple for color of
;;sunlight scaled to be just inside the RGB709 gamut.
(define (sunlight-chromaticity turbidity theta_s)
  (define spectrum (sunlight-spectrum turbidity theta_s))
  (and spectrum (spectrum->chromaticity spectrum 380.e-9 780.e-9)))

;; Arguments and result in radians
(define (angle-between theta phi theta_s phi_s)
  (define cospsi (+ (* (sin theta) (sin theta_s) (cos (- phi phi_s)))
		    (* (cos theta) (cos theta_s))))
  (cond ((> cospsi 1) 0)
	((< cospsi -1) pi)
	(else (acos cospsi))))

;;@body Returns the xyY (chromaticity and luminance) at the zenith.  The
;;Luminance has units kcd/m^2.
(define (zenith-xyY turbidity theta_s)
  (let* ((ths (* theta_s pi/180))
	 (thetas (do ((th 1 (* ths th))
		      (lst '() (cons th lst))
		      (cnt 3 (+ -1 cnt)))
		     ((negative? cnt) lst)))
	 (turbds (do ((tr 1 (* turbidity tr))
		      (lst '() (cons tr lst))
		      (cnt 2 (+ -1 cnt)))
		     ((negative? cnt) lst))))
    (append (map (lambda (row) (apply + (map * row turbds)))
		 (map color:linear-transform
		      '(((+0.00165 -0.00374 +0.00208 +0      )
			 (-0.02902 +0.06377 -0.03202 +0.00394)
			 (+0.11693 -0.21196 +0.06052 +0.25885))
			((+0.00275 -0.00610 +0.00316 +0      )
			 (-0.04214 +0.08970 -0.04153 +0.00515)
			 (+0.15346 -0.26756 +0.06669 +0.26688)))
		      (list thetas thetas)))
	    (list (+ (* (tan (* (+ 4/9 (/ turbidity -120)) (+ pi (* -2 ths))))
			(- (* 4.0453 turbidity) 4.9710))
		     (* -0.2155 turbidity)
		     2.4192)))))

;;@body @1 is a positive real number expressing the amount of light
;;scattering.  The real number @2 is the solar angle from the zenith in
;;degrees.
;;
;;@0 returns a function of one angle @var{theta}, the angle from the
;;zenith of the viewing direction (in degrees); and returning the xyY
;;value for light coming from that elevation of the sky.
(define (overcast-sky-color-xyY turbidity theta_s)
  (define xyY_z (zenith-xyY turbidity theta_s))
  (lambda (theta . phi)
    (list (car xyY_z) (cadr xyY_z)
	  (* 1/3 (caddr xyY_z) (+ 1 (* 2 (cos (* pi/180 theta))))))))

;;@body @1 is a positive real number expressing the amount of light
;;scattering.  The real number @2 is the solar angle from the zenith in
;;degrees.  The real number @3 is the solar angle from south.
;;
;;@0 returns a function of two angles, @var{theta} and @var{phi} which
;;specify the angles from the zenith and south meridian of the viewing
;;direction (in degrees); returning the xyY value for light coming from
;;that direction of the sky.
;;
;;@code{sky-color-xyY} calls @code{overcast-sky-color-xyY} for
;;@1 <= 20; otherwise the @0 function.
(define (clear-sky-color-xyY turbidity theta_s phi_s)
  (define xyY_z (zenith-xyY turbidity theta_s))
  (define th_s (* pi/180 theta_s))
  (define ph_s (* pi/180 phi_s))
  (define (F~ A B C D E)
    (lambda (th gm)
      (* (+ 1 (* A (exp (/ B (cos th)))))
	 (+ 1 (* C (exp (* D gm))) (* E (expt (cos gm) 2))))))
  (let* ((tb1 (list turbidity 1))
	 (Fs (map (lambda (mat) (apply F~ (color:linear-transform mat tb1)))
		  '((( 0.17872 -1.46303)
		     (-0.35540 +0.42749)
		     (-0.02266 +5.32505)
		     ( 0.12064 -2.57705)
		     (-0.06696 +0.37027))
		    ((-0.01925 -0.25922)
		     (-0.06651 +0.00081)
		     (-0.00041 +0.21247)
		     (-0.06409 -0.89887)
		     (-0.00325 +0.04517))
		    ((-0.01669 -0.26078)
		     (-0.09495 +0.00921)
		     (-0.00792 +0.21023)
		     (-0.04405 -1.65369)
		     (-0.01092 +0.05291)))))
	 (F_0s (map (lambda (F) (F 0 th_s)) Fs)))
    (lambda (theta phi)
      (let* ((th (* pi/180 theta))
	     (ph (* pi/180 phi))
	     (gm (angle-between th_s ph_s th ph)))
	;;(print th ph '=> gm)
	(map (lambda (x F F_0) (* x (/ (F th gm) F_0)))
	     xyY_z
	     Fs
	     F_0s)))))
(define (sky-color-xyY turbidity theta_s phi_s)
  (if (> turbidity 20)
      (overcast-sky-color-xyY turbidity theta_s)
      (clear-sky-color-xyY turbidity theta_s phi_s)))
