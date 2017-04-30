;;; "color.scm" color data-type
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

(require 'record)
(require 'color-space)
(require 'scanf)
(require 'printf)
(require 'string-case)
(require 'multiarg-apply)

(define color:rtd
  (make-record-type "color"
		    '(encoding		;symbol
		      coordinates	;list of coordinates
		      parameter		;white-point or precision
		      )))

(define color:construct
  (record-constructor color:rtd '(encoding coordinates parameter)))

(define color:encoding (record-accessor color:rtd 'encoding))

(define color:coordinates (record-accessor color:rtd 'coordinates))

(define color:parameter (record-accessor color:rtd 'parameter))
(define color:precision color:parameter)

(define color:color? (record-predicate color:rtd))

(define (color:white-point color)
  (case (color:encoding color)
    ((CIEXYZ
      RGB709
      sRGB
      xRGB
      e-sRGB) CIEXYZ:D65)
    ((L*a*b*
      L*u*v*
      L*C*h)
     (or (color:parameter color) CIEXYZ:D65))))

;;@subsubheading Measurement-based Color Spaces

(define (color:helper num-of-nums name list->color)
  (lambda args
    (define cnt 0)
    (for-each (lambda (x)
		(if (and (< cnt num-of-nums) (not (real? x)))
		    (slib:error name ': 'wrong-type x))
		(set! cnt (+ 1 cnt)))
	      args)
    (or (list->color args)
	(slib:error name ': 'out-of-range args))))

;;@noindent
;;@cindex tristimulus
;;The @dfn{tristimulus} color spaces are those whose component values
;;are proportional measurements of light intensity.  The CIEXYZ(1931)
;;system provides 3 sets of spectra to dot-product with a spectrum of
;;interest.  The result of those dot-products is coordinates in CIEXYZ
;;space.  All tristimuls color spaces are related to CIEXYZ by linear
;;transforms, namely matrix multiplication.  Of the color spaces listed
;;here, CIEXYZ and RGB709 are tristimulus spaces.

;;@deftp {Color Space} CIEXYZ
;;The CIEXYZ color space covers the full @dfn{gamut}.
;;It is the basis for color-space conversions.
;;
;;CIEXYZ is a list of three inexact numbers between 0.0 and 1.1.
;;'(0. 0. 0.) is black; '(1. 1. 1.) is white.
;;@end deftp

;;@body
;;@1 must be a list of 3 numbers.  If @1 is valid CIEXYZ coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (CIEXYZ->color XYZ)
  (and (eqv? 3 (length XYZ))
       (apply (lambda (x y z)
		(and (real? x) (<= -0.001 x)
		     (real? y) (<= -0.001 y 1.001)
		     (real? z) (<= -0.001 z)
		     (color:construct 'CIEXYZ XYZ #f)))
	      XYZ)))

;;@args x y z
;;Returns the CIEXYZ color composed of @1, @2, @3.  If the
;;coordinates do not encode a valid CIEXYZ color, then an error is
;;signaled.
(define color:CIEXYZ (color:helper 3 'color:CIEXYZ CIEXYZ->color))

;;@body Returns the list of 3 numbers encoding @1 in CIEXYZ.
(define (color->CIEXYZ color)
  (if (not (color:color? color))
      (slib:error 'color->CIEXYZ ': 'not 'color? color))
  (case (color:encoding color)
    ((CIEXYZ) (append (color:coordinates color) '()))
    ((RGB709) (RGB709->CIEXYZ (color:coordinates color)))
    ((L*a*b*) (L*a*b*->CIEXYZ (color:coordinates color)
			      (color:white-point color)))
    ((L*u*v*) (L*u*v*->CIEXYZ (color:coordinates color)
			      (color:white-point color)))
    ((sRGB)     (sRGB->CIEXYZ (color:coordinates color)))
    ((e-sRGB) (e-sRGB->CIEXYZ (color:precision color)
			      (color:coordinates color)))
    ((L*C*h)  (L*a*b*->CIEXYZ (L*C*h->L*a*b* (color:coordinates color))
			      (color:white-point color)))
    (else (slib:error 'color->CIEXYZ ': (color:encoding color) color))))


;;@deftp {Color Space} RGB709
;;BT.709-4 (03/00) @cite{Parameter values for the HDTV standards for
;;production and international programme exchange} specifies parameter
;;values for chromaticity, sampling, signal format, frame rates, etc., of
;;high definition television signals.
;;
;;An RGB709 color is represented by a list of three inexact numbers
;;between 0.0 and 1.0.  '(0. 0. 0.) is black '(1. 1. 1.) is white.
;;@end deftp

;;@body
;;@1 must be a list of 3 numbers.  If @1 is valid RGB709 coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (RGB709->color RGB)
  (and (eqv? 3 (length RGB))
       (apply (lambda (r g b)
		(and (real? r) (<= -0.001 r 1.001)
		     (real? g) (<= -0.001 g 1.001)
		     (real? b) (<= -0.001 b 1.001)
		     (color:construct 'RGB709 RGB #f)))
	      RGB)))

;;@args r g b
;;Returns the RGB709 color composed of @1, @2, @3.  If the
;;coordinates do not encode a valid RGB709 color, then an error is
;;signaled.
(define color:RGB709 (color:helper 3 'color:RGB709 RGB709->color))

;;@body Returns the list of 3 numbers encoding @1 in RGB709.
(define (color->RGB709 color)
  (if (not (color:color? color))
      (slib:error 'color->RGB709 ': 'not 'color? color))
  (case (color:encoding color)
    ((RGB709) (append (color:coordinates color) '()))
    ((CIEXYZ) (CIEXYZ->RGB709 (color:coordinates color)))
    (else     (CIEXYZ->RGB709 (color->CIEXYZ color)))))

;;@subsubheading Perceptual Uniformity

;;@noindent
;;Although properly encoding the chromaticity, tristimulus spaces do not
;;match the logarithmic response of human visual systems to intensity.
;;Minimum detectable differences between colors correspond to a smaller
;;range of distances (6:1) in the L*a*b* and L*u*v* spaces than in
;;tristimulus spaces (80:1).  For this reason, color distances are
;;computed in L*a*b* (or L*C*h).

;;@deftp {Color Space} L*a*b*
;;Is a CIE color space which better matches the human visual system's
;;perception of color.  It is a list of three numbers:

;;@itemize @bullet
;;@item
;;0 <= L* <= 100 (CIE @dfn{Lightness})

;;@item
;;-500 <= a* <= 500
;;@item
;;-200 <= b* <= 200
;;@end itemize
;;@end deftp

;;@args L*a*b* white-point
;;@1 must be a list of 3 numbers.  If @1 is valid L*a*b* coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (L*a*b*->color L*a*b* . white-point)
  (and (list? L*a*b*)
       (eqv? 3 (length L*a*b*))
       (<= 0 (length white-point) 1)
       (apply (lambda (L* a* b*)
		(and (real? L*) (<= 0 L* 100)
		     (real? a*) (<= -500 a* 500)
		     (real? b*) (<= -200 b* 200)
		     (color:construct
		      'L*a*b* L*a*b*
		      (if (null? white-point) #f
			  (color->CIEXYZ (car white-point))))))
	      L*a*b*)))

;;@args L* a* b* white-point
;;Returns the L*a*b* color composed of @1, @2, @3 with @4.
;;@args L* a* b*
;;Returns the L*a*b* color composed of @1, @2, @3.  If the coordinates
;;do not encode a valid L*a*b* color, then an error is signaled.
(define color:L*a*b* (color:helper 3 'color:L*a*b* L*a*b*->color))

;;@args color white-point
;;Returns the list of 3 numbers encoding @1 in L*a*b* with @2.
;;@args color
;;Returns the list of 3 numbers encoding @1 in L*a*b*.
(define (color->L*a*b* color . white-point)
  (define (wp) (if (null? white-point)
		   CIEXYZ:D65
		   (color:coordinates (car white-point))))
  (if (not (color:color? color))
      (slib:error 'color->L*a*b* ': 'not 'color? color))
  (case (color:encoding color)
    ((L*a*b*) (if (equal? (wp) (color:white-point color))
		  (append (color:coordinates color) '())
		  (CIEXYZ->L*a*b* (L*a*b*->CIEXYZ (color:coordinates color)
						  (color:white-point color))
				  (wp))))
    ((L*u*v*) (CIEXYZ->L*a*b* (L*u*v*->CIEXYZ (color:coordinates color)
					      (color:white-point color))
			      (wp)))
    ((L*C*h)  (if (equal? (wp) (color:white-point color))
		  (L*C*h->L*a*b* (color:coordinates color))
		  (CIEXYZ->L*a*b* (L*a*b*->CIEXYZ
				   (L*C*h->L*a*b* (color:coordinates color))
				   (color:white-point color))
				  (wp))))
    ((CIEXYZ) (CIEXYZ->L*a*b* (color:coordinates color) (wp)))
    (else     (CIEXYZ->L*a*b* (color->CIEXYZ color) (wp)))))

;;@deftp {Color Space} L*u*v*
;;Is another CIE encoding designed to better match the human visual
;;system's perception of color.
;;@end deftp

;;@args L*u*v* white-point
;;@1 must be a list of 3 numbers.  If @1 is valid L*u*v* coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (L*u*v*->color L*u*v* . white-point)
  (and (list? L*u*v*)
       (eqv? 3 (length L*u*v*))
       (<= 0 (length white-point) 1)
       (apply (lambda (L* u* v*)
		(and (real? L*) (<= 0 L* 100)
		     (real? u*) (<= -500 u* 500)
		     (real? v*) (<= -200 v* 200)
		     (color:construct
		      'L*u*v* L*u*v*
		      (if (null? white-point) #f
			  (color->CIEXYZ (car white-point))))))
	      L*u*v*)))

;;@args L* u* v* white-point
;;Returns the L*u*v* color composed of @1, @2, @3 with @4.
;;@args L* u* v*
;;Returns the L*u*v* color composed of @1, @2, @3.  If the coordinates
;;do not encode a valid L*u*v* color, then an error is signaled.
(define color:L*u*v* (color:helper 3 'color:L*u*v* L*u*v*->color))

;;@args color white-point
;;Returns the list of 3 numbers encoding @1 in L*u*v* with @2.
;;@args color
;;Returns the list of 3 numbers encoding @1 in L*u*v*.
(define (color->L*u*v* color . white-point)
  (define (wp) (if (null? white-point)
		   (color:white-point color)
		   (car white-point)))
  (if (not (color:color? color))
      (slib:error 'color->L*u*v* ': 'not 'color? color))
  (case (color:encoding color)
    ((L*u*v*) (append (color:coordinates color) '()))
    ((L*a*b*) (CIEXYZ->L*u*v* (L*a*b*->CIEXYZ (color:coordinates color)
					      (color:white-point color))
			      (wp)))
    ((L*C*h)  (CIEXYZ->L*u*v*
	       (L*a*b*->CIEXYZ (L*C*h->L*a*b* (color:coordinates color))
			       (color:white-point color))
	       (wp)))
    ((CIEXYZ) (CIEXYZ->L*u*v* (color:coordinates color) (wp)))
    (else     (CIEXYZ->L*u*v* (color->CIEXYZ color) (wp)))))

;;@subsubheading Cylindrical Coordinates

;;@noindent
;;HSL (Hue Saturation Lightness), HSV (Hue Saturation Value), HSI (Hue
;;Saturation Intensity) and HCI (Hue Chroma Intensity) are cylindrical
;;color spaces (with angle hue).  But these spaces are all defined in
;;terms device-dependent RGB spaces.

;;@noindent
;;One might wonder if there is some fundamental reason why intuitive
;;specification of color must be device-dependent.  But take heart!  A
;;cylindrical system can be based on L*a*b* and is used for predicting how
;;close colors seem to observers.

;;@deftp {Color Space} L*C*h
;;Expresses the *a and b* of L*a*b* in polar coordinates.  It is a list of
;;three numbers:

;;@itemize @bullet
;;@item
;;0 <= L* <= 100 (CIE @dfn{Lightness})

;;@item
;;C* (CIE @dfn{Chroma}) is the distance from the neutral (gray) axis.
;;@item
;;0 <= h <= 360 (CIE @dfn{Hue}) is the angle.
;;@end itemize
;;
;;The colors by quadrant of h are:

;;@multitable @columnfractions .20 .60 .20
;;@item 0 @tab red, orange, yellow @tab 90
;;@item 90 @tab yellow, yellow-green, green @tab 180
;;@item 180 @tab green, cyan (blue-green), blue @tab 270
;;@item 270 @tab blue, purple, magenta @tab 360
;;@end multitable

;;@end deftp


;;@args L*C*h white-point
;;@1 must be a list of 3 numbers.  If @1 is valid L*C*h coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (L*C*h->color L*C*h . white-point)
  (and (list? L*C*h)
       (eqv? 3 (length L*C*h))
       (<= 0 (length white-point) 1)
       (apply (lambda (L* C* h)
		(and (real? L*) (<= 0 L* 100)
		     (real? C*) (<= 0 C*)
		     (real? h)  (<= 0 h 360)
		     (color:construct
		      'L*C*h L*C*h
		      (if (null? white-point) #f
			  (color->CIEXYZ (car white-point))))))
	      L*C*h)))

;;@args L* C* h white-point
;;Returns the L*C*h color composed of @1, @2, @3 with @4.
;;@args L* C* h
;;Returns the L*C*h color composed of @1, @2, @3.  If the coordinates
;;do not encode a valid L*C*h color, then an error is signaled.
(define color:L*C*h (color:helper 3 'color:L*C*h L*C*h->color))

;;@args color white-point
;;Returns the list of 3 numbers encoding @1 in L*C*h with @2.
;;@args color
;;Returns the list of 3 numbers encoding @1 in L*C*h.
(define (color->L*C*h color . white-point)
  (if (not (color:color? color))
      (slib:error 'color->L*C*h ': 'not 'color? color))
  (if (and (eqv? 'L*C*h (color:encoding color))
	   (equal? (color:white-point color)
		   (if (null? white-point)
		       CIEXYZ:D65
		       (color:coordinates (car white-point)))))
      (append (color:coordinates color) '())
      (L*a*b*->L*C*h (apply color->L*a*b* color white-point))))

;;@subsubheading Digital Color Spaces

;;@noindent
;;The color spaces discussed so far are impractical for image data because
;;of numerical precision and computational requirements.  In 1998 the IEC
;;adopted @cite{A Standard Default Color Space for the Internet - sRGB}
;;(@url{http://www.w3.org/Graphics/Color/sRGB}).  sRGB was cleverly
;;designed to employ the 24-bit (256x256x256) color encoding already in
;;widespread use; and the 2.2 gamma intrinsic to CRT monitors.

;;@noindent
;;Conversion from CIEXYZ to digital (sRGB) color spaces is accomplished by
;;conversion first to a RGB709 tristimulus space with D65 white-point;
;;then each coordinate is individually subjected to the same non-linear
;;mapping.  Inverse operations in the reverse order create the inverse
;;transform.

;;@deftp {Color Space} sRGB
;;Is "A Standard Default Color Space for the Internet".  Most display
;;monitors will work fairly well with sRGB directly.  Systems using ICC
;;profiles
;;@ftindex ICC Profile
;;@footnote{
;;@noindent
;;A comprehensive encoding of transforms between CIEXYZ and device color
;;spaces is the International Color Consortium profile format,
;;ICC.1:1998-09:

;;@quotation
;;The intent of this format is to provide a cross-platform device profile
;;format.  Such device profiles can be used to translate color data
;;created on one device into another device's native color space.
;;@end quotation
;;}
;;should work very well with sRGB.

;;An sRGB color is a triplet of integers ranging 0 to 255.  D65 is the
;;white-point for sRGB.
;;@end deftp

;;@body
;;@1 must be a list of 3 numbers.  If @1 is valid sRGB coordinates,
;;then @0 returns the color specified by @1; otherwise returns #f.
(define (sRGB->color RGB)
  (and (eqv? 3 (length RGB))
       (apply (lambda (r g b)
		(and  (integer? r) (<= 0 r 255)
		      (integer? g) (<= 0 g 255)
		      (integer? b) (<= 0 b 255)
		      (color:construct 'sRGB RGB #f)))
	      RGB)))

;;@args r g b
;;Returns the sRGB color composed of @1, @2, @3.  If the
;;coordinates do not encode a valid sRGB color, then an error is
;;signaled.
(define color:sRGB (color:helper 3 'color:sRGB sRGB->color))

;;@deftp {Color Space} xRGB
;;Represents the equivalent sRGB color with a single 24-bit integer.  The
;;most significant 8 bits encode red, the middle 8 bits blue, and the
;;least significant 8 bits green.
;;@end deftp

;;@body
;;Returns the list of 3 integers encoding @1 in sRGB.
(define (color->sRGB color)
  (if (not (color:color? color))
      (slib:error 'color->sRGB ': 'not 'color? color))
  (case (color:encoding color)
    ((CIEXYZ) (CIEXYZ->sRGB (color:coordinates color)))
    ((sRGB)   (append (color:coordinates color) '()))
    (else     (CIEXYZ->sRGB (color->CIEXYZ color)))))

;;@body Returns the 24-bit integer encoding @1 in sRGB.
(define (color->xRGB color) (sRGB->xRGB (color->sRGB color)))

;;@args k
;;Returns the sRGB color composed of the 24-bit integer @1.
(define (xRGB->color xRGB)
  (and (integer? xRGB) (<= 0 xRGB #xffffff)
       (sRGB->color (xRGB->sRGB xRGB))))


;;@deftp {Color Space} e-sRGB
;;Is "Photography - Electronic still picture imaging - Extended sRGB color
;;encoding" (PIMA 7667:2001).  It extends the gamut of sRGB; and its
;;higher precision numbers provide a larger dynamic range.
;;
;;A triplet of integers represent e-sRGB colors.  Three precisions are
;;supported:

;;@table @r
;;@item e-sRGB10
;;0 to 1023
;;@item e-sRGB12
;;0 to 4095
;;@item e-sRGB16
;;0 to 65535
;;@end table
;;@end deftp

(define (esRGB->color prec-RGB)
  (and (eqv? 4 (length prec-RGB))
       (let ((range (and (pair? prec-RGB)
			 (case (car prec-RGB)
			   ((10) 1023)
			   ((12) 4095)
			   ((16) 65535)
			   (else #f)))))
	 (apply (lambda (precision r g b)
		  (and  (integer? r) (<= 0 r range)
			(integer? g) (<= 0 g range)
			(integer? b) (<= 0 b range)
			(color:construct 'e-sRGB (cdr prec-RGB) precision)))
		prec-RGB))))

;;@body @1 must be the integer 10, 12, or 16.  @2 must be a list of 3
;;numbers.  If @2 is valid e-sRGB coordinates, then @0 returns the color
;;specified by @2; otherwise returns #f.
(define (e-sRGB->color precision RGB)
  (esRGB->color (cons precision RGB)))

;;@args 10 r g b
;;Returns the e-sRGB10 color composed of integers @2, @3, @4.
;;@args 12 r g b
;;Returns the e-sRGB12 color composed of integers @2, @3, @4.
;;@args 16 r g b
;;Returns the e-sRGB16 color composed of integers @2, @3, @4.
;;If the coordinates do not encode a valid e-sRGB color, then an error
;;is signaled.
(define color:e-sRGB (color:helper 4 'color:e-sRGB esRGB->color))

;;@body @1 must be the integer 10, 12, or 16.  @0 returns the list of 3
;;integers encoding @2 in sRGB10, sRGB12, or sRGB16.
(define (color->e-sRGB precision color)
  (case precision
    ((10 12 16)
     (if (not (color:color? color))
	 (slib:error 'color->e-sRGB ': 'not 'color? color)))
    (else (slib:error 'color->e-sRGB ': 'invalid 'precision precision)))
  (case (color:encoding color)
    ((e-sRGB) (e-sRGB->e-sRGB (color:precision color)
			      (color:coordinates color)
			      precision))
    ((sRGB)     (sRGB->e-sRGB precision (color:coordinates color)))
    (else     (CIEXYZ->e-sRGB precision (color->CIEXYZ color)))))

;;;; Polytypic Colors

;;; The rest of documentation is in "slib.texi"
;@
(define D65 (CIEXYZ->color CIEXYZ:D65))
(define D50 (CIEXYZ->color CIEXYZ:D50))
;@
(define (color? obj . typ)
  (cond ((not (color:color? obj)) #f)
	((null? typ) #t)
	(else (eqv? (car typ) (color:encoding obj)))))
;@
(define (make-color space . args)
  (apply (case space
	   ((CIEXYZ) CIEXYZ->color)
	   ((RGB709) RGB709->color)
	   ((L*a*b*) L*a*b*->color)
	   ((L*u*v*) L*u*v*->color)
	   ((L*C*h)  L*C*h->color)
	   ((sRGB)   sRGB->color)
	   ((xRGB)   xRGB->color)
	   ((e-sRGB) e-sRGB->color)
	   (else (slib:error 'make-color ': 'not 'space? space)))
	 args))
;@
(define color-space color:encoding)
;@
(define (color-precision color)
  (if (not (color:color? color))
      (slib:error 'color-precision ': 'not 'color? color))
  (case (color:encoding color)
    ((e-sRGB) (color:precision color))
    ((sRGB)   8)
    (else     #f)))
;@
(define (color-white-point color)
  (if (not (color:color? color))
      (slib:error 'color-white-point ': 'not 'color? color))
  (case (color:encoding color)
    ((L*a*b*) (color:CIEXYZ (color:white-point color)))
    ((L*u*v*) (color:CIEXYZ (color:white-point color)))
    ((L*C*h)  (color:CIEXYZ (color:white-point color)))
    ((RGB709) D65)
    ((sRGB)   D65)
    ((e-sRGB) D65)
    (else #f)))
;@
(define (convert-color color encoding . opt-arg)
  (define (noarg)
    (if (not (null? opt-arg))
	(slib:error 'convert-color ': 'too-many 'arguments opt-arg)))
  (if (not (color:color? color))
      (slib:error 'convert-color ': 'not 'color? color))
  (case encoding
    ((CIEXYZ) (noarg) (CIEXYZ->color (color->CIEXYZ color)))
    ((RGB709) (noarg) (RGB709->color (color->RGB709 color)))
    ((sRGB)   (noarg) (sRGB->color   (color->sRGB color)))
    ((e-sRGB) (e-sRGB->color (car opt-arg) (color->e-sRGB (car opt-arg) color)))
    ((L*a*b*) (apply L*a*b*->color (color->L*a*b* color) opt-arg))
    ((L*u*v*) (apply L*u*v*->color (color->L*u*v* color) opt-arg))
    ((L*C*h)  (apply L*C*h->color  (color->L*C*h color) opt-arg))
    (else (slib:error 'convert-color ': encoding '?))))

;;; External color representations
;@
(define (color->string color)
  (if (not (color:color? color))
      (slib:error 'color->string ': 'not 'color? color))
  (case (color:encoding color)
    ((CIEXYZ) (apply sprintf #f "CIEXYZ:%g/%g/%g"
		     (color:coordinates color)))
    ((L*a*b*) (apply sprintf #f "CIELab:%.2f/%.2f/%.2f"
		     (if (equal? CIEXYZ:D65 (color:white-point color))
			 (color:coordinates color)
			 (CIEXYZ->L*a*b* (L*a*b*->CIEXYZ
					  (color:coordinates color)
					  (color:white-point color))))))
    ((L*u*v*) (apply sprintf #f "CIELuv:%.2f/%.2f/%.2f"
		     (if (equal? CIEXYZ:D65 (color:white-point color))
			 (color:coordinates color)
			 (CIEXYZ->L*u*v* (L*u*v*->CIEXYZ
					  (color:coordinates color)
					  (color:white-point color))))))
    ((L*C*h)  (apply sprintf #f "CIELCh:%.2f/%.2f/%.2f"
		     (if (equal? CIEXYZ:D65 (color:white-point color))
			 (color:coordinates color)
			 (L*a*b*->L*C*h
			  (CIEXYZ->L*a*b* (L*a*b*->CIEXYZ
					   (L*C*h->L*a*b*
					    (color:coordinates color))
					   (color:white-point color)))))))
    ((RGB709) (apply sprintf #f "RGBi:%g/%g/%g" (color:coordinates color)))
    ((sRGB)   (apply sprintf #f "sRGB:%d/%d/%d" (color:coordinates color)))
    ((e-sRGB) (apply sprintf #f "e-sRGB%d:%d/%d/%d"
		     (color:precision color) (color:coordinates color)))
    (else (slib:error 'color->string ': (color:encoding color) color))))
;@
(define (string->color str)
  (define prec #f) (define coding #f)
  (define x #f) (define y #f) (define z #f)
  (cond ((eqv? 4 (sscanf str " %[CIEXYZciexyzLABUVlabuvHhRrGg709]:%f/%f/%f"
			 coding x y z))
	 (case (string-ci->symbol coding)
	   ((CIEXYZ) (color:CIEXYZ x y z))
	   ((CIELab) (color:L*a*b* x y z))
	   ((CIELuv) (color:L*u*v* x y z))
	   ((CIELCh) (color:L*C*h  x y z))
	   ((RGBi		       ; Xlib - C Language X Interface
	     RGB709) (color:RGB709 x y z))
	   (else #f)))
	((eqv? 4 (sscanf str " %[sRGBSrgb]:%d/%d/%d" coding x y z))
	 (case (string-ci->symbol coding)
	   ((sRGB)   (color:sRGB x y z))
	   (else #f)))
	((eqv? 5 (sscanf str " %[-esRGBESrgb]%d:%d/%d/%d" coding prec x y z))
	 (case (string-ci->symbol coding)
	   ((e-sRGB) (color:e-sRGB prec x y z))
	   (else #f)))
	((eqv? 2 (sscanf str " %[sRGBxXXRGB]:%6x%[/0-9a-fA-F]" coding x y))
	 (case (string-ci->symbol coding)
	   ((sRGB
	     xRGB
	     sRGBx)  (xRGB->color x))
	   (else #f)))
	((and (eqv? 1 (sscanf str " #%6[0-9a-fA-F]%[0-9a-fA-F]" x y))
	      (eqv? 6 (string-length x)))
	 (xRGB->color (string->number x 16)))
	((and (eqv? 2 (sscanf str " %[#0xX]%6[0-9a-fA-F]%[0-9a-fA-F]"
			      coding x y))
	      (eqv? 6 (string-length x))
	      (member coding '("#" "#x" "0x" "#X" "0X")))
	 (xRGB->color (string->number x 16)))
	(else #f)))

;;;; visual color metrics
;@
(define (CIE:DE* color1 color2 . white-point)
  (L*a*b*:DE* (apply color->L*a*b* color1 white-point)
	      (apply color->L*a*b* color2 white-point)))
;@
(define (CIE:DE*94 color1 color2 . parametric-factors)
  (apply L*a*b*:DE*94
	 (color->L*a*b* color1)
	 (color->L*a*b* color2)
	 parametric-factors))
;@
(define (CMC:DE* color1 color2 . parametric-factors)
  (apply CMC-DE
	 (color->L*C*h color1)
	 (color->L*C*h color2)
	 parametric-factors))

;;; Short names

;; (define CIEXYZ color:CIEXYZ)
;; (define RGB709 color:RGB709)
;; (define L*a*b* color:L*a*b*)
;; (define L*u*v* color:L*u*v*)
;; (define L*C*h  color:L*C*h)
;; (define sRGB   color:sRGB)
;; (define xRGB   xRGB->color)
;; (define e-sRGB color:e-sRGB)
