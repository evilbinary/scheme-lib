;;; "bytenumb.scm" Byte integer and IEEE floating-point conversions.
; Copyright (C) 2003 Aubrey Jaffer
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

(require 'byte)
(require 'logical)

;;@code{(require 'byte-number)}
;;@ftindex byte-number

;;@noindent
;;The multi-byte sequences produced and used by numeric conversion
;;routines are always big-endian.  Endianness can be changed during
;;reading and writing bytes using @code{read-bytes} and
;;@code{write-bytes} @xref{Byte, read-bytes}.
;;
;;@noindent
;;The sign of the length argument to bytes/integer conversion
;;procedures determines the signedness of the number.

;;@body
;;Converts the first @code{(abs @var{n})} bytes of big-endian @1 array
;;to an integer.  If @2 is negative then the integer coded by the
;;bytes are treated as two's-complement (can be negative).
;;
;;@example
;;(bytes->integer (bytes   0   0   0  15) -4)   @result{}          15
;;(bytes->integer (bytes   0   0   0  15)  4)   @result{}          15
;;(bytes->integer (bytes 255 255 255 255) -4)   @result{}          -1
;;(bytes->integer (bytes 255 255 255 255)  4)   @result{}  4294967295
;;(bytes->integer (bytes 128   0   0   0) -4)   @result{} -2147483648
;;(bytes->integer (bytes 128   0   0   0)  4)   @result{}  2147483648
;;@end example
(define (bytes->integer bytes n)
  (define cnt (abs n))
  (cond ((zero? n) 0)
	((and (negative? n) (> (byte-ref bytes 0) 127))
	 (do ((lng (- 255 (byte-ref bytes 0))
		   (+ (- 255 (byte-ref bytes idx)) (* 256 lng)))
	      (idx 1 (+ 1 idx)))
	     ((>= idx cnt) (- -1 lng))))
	(else
	 (do ((lng (byte-ref bytes 0)
		   (+ (byte-ref bytes idx) (* 256 lng)))
	      (idx 1 (+ 1 idx)))
	     ((>= idx cnt) lng)))))

;;@body
;;Converts the integer @1 to a byte-array of @code{(abs @var{n})}
;;bytes.  If @1 and @2 are both negative, then the bytes in the
;;returned array are coded two's-complement.
;;
;;@example
;;(bytes->list (integer->bytes          15 -4))   @result{} (0 0 0 15)
;;(bytes->list (integer->bytes          15  4))   @result{} (0 0 0 15)
;;(bytes->list (integer->bytes          -1 -4))   @result{} (255 255 255 255)
;;(bytes->list (integer->bytes  4294967295  4))   @result{} (255 255 255 255)
;;(bytes->list (integer->bytes -2147483648 -4))   @result{} (128 0 0 0)
;;(bytes->list (integer->bytes  2147483648  4))   @result{} (128 0 0 0)
;;@end example
(define (integer->bytes n len)
  (define bytes (make-bytes (abs len)))
  (cond ((and (negative? n) (negative? len))
	 (do ((idx (+ -1 (abs len)) (+ -1 idx))
	      (res (- -1 n) (quotient res 256)))
	     ((negative? idx) bytes)
	   (byte-set! bytes idx (- 255 (modulo res 256)))))
	(else
	 (do ((idx (+ -1 (abs len)) (+ -1 idx))
	      (res n (quotient res 256)))
	     ((negative? idx) bytes)
	   (byte-set! bytes idx (modulo res 256))))))

;;@body
;;@1 must be a 4-element byte-array.  @0 calculates and returns the
;;value of @1 interpreted as a big-endian IEEE 4-byte (32-bit) number.
(define (bytes->ieee-float bytes)
  (define zero (or (string->number "0.0") 0))
  (define one  (or (string->number "1.0") 1))
  (define len (bytes-length bytes))
  (define S (logbit? 7 (byte-ref bytes 0)))
  (define E (+ (ash (logand #x7F (byte-ref bytes 0)) 1)
	       (ash (logand #x80 (byte-ref bytes 1)) -7)))
  (if (not (eqv? 4 len))
      (slib:error 'bytes->ieee-float 'wrong 'length len))
  (do ((F (byte-ref bytes (+ -1 len))
	  (+ (byte-ref bytes idx) (/ F 256)))
       (idx (+ -2 len) (+ -1 idx)))
      ((<= idx 1)
       (set! F (/ (+ (logand #x7F (byte-ref bytes 1)) (/ F 256)) 128))
       (cond ((< 0 E 255) (* (if S (- one) one) (expt 2 (- E 127)) (+ 1 F)))
	     ((zero? E)
	      (if (zero? F)
		  (if S (- zero) zero)
		  (* (if S (- one) one) (expt 2 -126) F)))
	     ;; E must be 255
	     ((not (zero? F)) (/ zero zero))
	     (else (/ (if S (- one) one) zero))))))

;;  S EEEEEEE E FFFFFFF FFFFFFFF FFFFFFFF
;;  ========= ========= ======== ========
;;  0 1       8 9                      31

;;@example
;;(bytes->ieee-float (bytes    0    0 0 0))  @result{}  0.0
;;(bytes->ieee-float (bytes #x80    0 0 0))  @result{} -0.0
;;(bytes->ieee-float (bytes #x40    0 0 0))  @result{}  2.0
;;(bytes->ieee-float (bytes #x40 #xd0 0 0))  @result{}  6.5
;;(bytes->ieee-float (bytes #xc0 #xd0 0 0))  @result{} -6.5
;;
;;(bytes->ieee-float (bytes    0 #x80 0 0))  @result{} 11.754943508222875e-39
;;(bytes->ieee-float (bytes    0 #x40 0 0))  @result{}  5.877471754111437e-39
;;(bytes->ieee-float (bytes    0    0 0 1))  @result{}  1.401298464324817e-45
;;
;;(bytes->ieee-float (bytes #xff #x80 0 0))  @result{} -inf.0
;;(bytes->ieee-float (bytes #x7f #x80 0 0))  @result{} +inf.0
;;(bytes->ieee-float (bytes #x7f #x80 0 1))  @result{}  0/0
;;(bytes->ieee-float (bytes #x7f #xc0 0 0))  @result{}  0/0
;;@end example

;;@body
;;@1 must be a 8-element byte-array.  @0 calculates and returns the
;;value of @1 interpreted as a big-endian IEEE 8-byte (64-bit) number.
(define (bytes->ieee-double bytes)
  (define zero (or (string->number "0.0") 0))
  (define one  (or (string->number "1.0") 1))
  (define len (bytes-length bytes))
  (define S (logbit? 7 (byte-ref bytes 0)))
  (define E (+ (ash (logand #x7F (byte-ref bytes 0)) 4)
	       (ash (logand #xF0 (byte-ref bytes 1)) -4)))
  (if (not (eqv? 8 len))
      (slib:error 'bytes->ieee-double 'wrong 'length len))
  (do ((F (byte-ref bytes (+ -1 len))
	  (+ (byte-ref bytes idx) (/ F 256)))
       (idx (+ -2 len) (+ -1 idx)))
      ((<= idx 1)
       (set! F (/ (+ (logand #x0F (byte-ref bytes 1)) (/ F 256)) 16))
       (cond ((< 0 E 2047) (* (if S (- one) one) (expt 2 (- E 1023)) (+ 1 F)))
	     ((zero? E)
	      (if (zero? F)
		  (if S (- zero) zero)
		  (* (if S (- one) one) (expt 2 -1022) F)))
	     ;; E must be 2047
	     ((not (zero? F)) (/ zero zero))
	     (else (/ (if S (- one) one) zero))))))

;;  S EEEEEEE EEEE FFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF
;;  ========= ========= ======== ======== ======== ======== ======== ========
;;  0 1         11 12                                                      63

;;@example
;;(bytes->ieee-double (bytes    0    0 0 0 0 0 0 0))  @result{}  0.0
;;(bytes->ieee-double (bytes #x80    0 0 0 0 0 0 0))  @result{} -0.0
;;(bytes->ieee-double (bytes #x40    0 0 0 0 0 0 0))  @result{}  2.0
;;(bytes->ieee-double (bytes #x40 #x1A 0 0 0 0 0 0))  @result{}  6.5
;;(bytes->ieee-double (bytes #xC0 #x1A 0 0 0 0 0 0))  @result{} -6.5
;;
;;(bytes->ieee-double (bytes 0 8 0 0 0 0 0 0)) @result{} 11.125369292536006e-309
;;(bytes->ieee-double (bytes 0 4 0 0 0 0 0 0)) @result{}  5.562684646268003e-309
;;(bytes->ieee-double (bytes 0 0 0 0 0 0 0 1)) @result{}  4.0e-324
;;
;;(bytes->ieee-double (list->bytes '(127 239 255 255 255 255 255 255))) 179.76931348623157e306
;;(bytes->ieee-double (bytes #xFF #xF0 0 0 0 0 0 0))  @result{} -inf.0
;;(bytes->ieee-double (bytes #x7F #xF0 0 0 0 0 0 0))  @result{} +inf.0
;;(bytes->ieee-double (bytes #x7F #xF8 0 0 0 0 0 0))  @result{}  0/0
;;@end example

;;@args x
;;Returns a 4-element byte-array encoding the IEEE single-precision
;;floating-point of @1.
(define ieee-float->bytes
  (let ((exactify (if (provided? 'inexact) inexact->exact identity)))
    (lambda (flt)
      (define byts (make-bytes 4 0))
      (define S (and (real? flt) (negative? (if (zero? flt) (/ flt) flt))))
      (define (scale flt scl)
	(cond ((zero? scl)            (out (/ flt 2) scl))
	      ((>= flt 16)
	       (let ((flt/16 (/ flt 16)))
		 (cond ((= flt/16 flt)
			(byte-set! byts 0 (if S #xFF #x7F))
			(byte-set! byts 1 #x80)
			byts)
		       (else          (scale flt/16 (+ scl 4))))))
	      ((>= flt 2)             (scale (/ flt 2) (+ scl 1)))
	      ((and (>= scl 4)
		    (< (* 16 flt) 1)) (scale (* flt 16) (+ scl -4)))
	      ((< flt 1)              (scale (* flt 2) (+ scl -1)))
	      (else                   (out (+ -1 flt) scl))))
      (define (out flt scl)
	(do ((flt (* 128 flt) (* 256 (- flt val)))
	     (val (exactify (floor (* 128 flt)))
		  (exactify (floor (* 256 (- flt val)))))
	     (idx 1 (+ 1 idx)))
	    ((> idx 3)
	     (byte-set! byts 1 (bitwise-if #x80 (ash scl 7) (byte-ref byts 1)))
	     (byte-set! byts 0 (+ (if S 128 0) (ash scl -1)))
	     byts)
	  (byte-set! byts idx val)))
      (set! flt (magnitude flt))
      (cond ((zero? flt) (if S (byte-set! byts 0 #x80)) byts)
	    ((or (not (real? flt))
		 (not (= flt flt)))
	     (byte-set! byts 0 (if S #xFF #x7F))
	     (byte-set! byts 1 #xC0)
	     byts)
	    (else (scale flt 127))))))
;;@example
;;(bytes->list (ieee-float->bytes  0.0))                    @result{} (0     0 0 0)
;;(bytes->list (ieee-float->bytes -0.0))                    @result{} (128   0 0 0)
;;(bytes->list (ieee-float->bytes  2.0))                    @result{} (64    0 0 0)
;;(bytes->list (ieee-float->bytes  6.5))                    @result{} (64  208 0 0)
;;(bytes->list (ieee-float->bytes -6.5))                    @result{} (192 208 0 0)
;;
;;(bytes->list (ieee-float->bytes 11.754943508222875e-39))  @result{} (  0 128 0 0)
;;(bytes->list (ieee-float->bytes  5.877471754111438e-39))  @result{} (  0  64 0 0)
;;(bytes->list (ieee-float->bytes  1.401298464324817e-45))  @result{} (  0   0 0 1)
;;
;;(bytes->list (ieee-float->bytes -inf.0))                  @result{} (255 128 0 0)
;;(bytes->list (ieee-float->bytes +inf.0))                  @result{} (127 128 0 0)
;;(bytes->list (ieee-float->bytes  0/0))                    @result{} (127 192 0 0)
;;@end example


;;@args x
;;Returns a 8-element byte-array encoding the IEEE double-precision
;;floating-point of @1.
(define ieee-double->bytes
  (let ((exactify (if (provided? 'inexact) inexact->exact identity)))
    (lambda (flt)
      (define byts (make-bytes 8 0))
      (define S (and (real? flt) (negative? (if (zero? flt) (/ flt) flt))))
      (define (scale flt scl)
	(cond ((zero? scl)            (out (/ flt 2) scl))
	      ((>= flt 16)
	       (let ((flt/16 (/ flt 16)))
		 (cond ((= flt/16 flt)
			(byte-set! byts 0 (if S #xFF #x7F))
			(byte-set! byts 1 #xF0)
			byts)
		       (else          (scale flt/16 (+ scl 4))))))
	      ((>= flt 2)             (scale (/ flt 2) (+ scl 1)))
	      ((and (>= scl 4)
		    (< (* 16 flt) 1)) (scale (* flt 16) (+ scl -4)))
	      ((< flt 1)              (scale (* flt 2) (+ scl -1)))
	      (else                   (out (+ -1 flt) scl))))
      (define (out flt scl)
	(do ((flt (* 16 flt) (* 256 (- flt val)))
	     (val (exactify (floor (* 16 flt)))
		  (exactify (floor (* 256 (- flt val)))))
	     (idx 1 (+ 1 idx)))
	    ((> idx 7)
	     (byte-set! byts 1 (bitwise-if #xF0 (ash scl 4) (byte-ref byts 1)))
	     (byte-set! byts 0 (+ (if S 128 0) (ash scl -4)))
	     byts)
	  (byte-set! byts idx val)))
      (set! flt (magnitude flt))
      (cond ((zero? flt) (if S (byte-set! byts 0 #x80)) byts)
	    ((or (not (real? flt))
		 (not (= flt flt)))
	     (byte-set! byts 0 #x7F)
	     (byte-set! byts 1 #xF8)
	     byts)
	    (else (scale flt 1023))))))
;;@example
;;(bytes->list (ieee-double->bytes  0.0)) @result{} (0     0 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes -0.0)) @result{} (128   0 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes  2.0)) @result{} (64    0 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes  6.5)) @result{} (64   26 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes -6.5)) @result{} (192  26 0 0 0 0 0 0)
;;
;;(bytes->list (ieee-double->bytes 11.125369292536006e-309))
;;                                        @result{} (  0   8 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes  5.562684646268003e-309))
;;                                        @result{} (  0   4 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes  4.0e-324))
;;                                        @result{} (  0   0 0 0 0 0 0 1)
;;
;;(bytes->list (ieee-double->bytes -inf.0)) @result{} (255 240 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes +inf.0)) @result{} (127 240 0 0 0 0 0 0)
;;(bytes->list (ieee-double->bytes  0/0)) @result{} (127 248 0 0 0 0 0 0)
;;@end example

;;@subsubheading Byte Collation Order
;;
;;@noindent
;;The @code{string<?} ordering of big-endian byte-array
;;representations of fixed and IEEE floating-point numbers agrees with
;;the numerical ordering only when those numbers are non-negative.
;;
;;@noindent
;;Straighforward modification of these formats can extend the
;;byte-collating order to work for their entire ranges.  This
;;agreement enables the full range of numbers as keys in
;;@dfn{indexed-sequential-access-method} databases.

;;@body
;;Modifies sign bit of @1 so that @code{string<?} ordering of
;;two's-complement byte-vectors matches numerical order.  @0 returns
;;@1 and is its own functional inverse.
(define (integer-byte-collate! byte-vector)
  (byte-set! byte-vector 0 (logxor #x80 (byte-ref byte-vector 0)))
  byte-vector)

;;@body
;;Returns copy of @1 with sign bit modified so that @code{string<?}
;;ordering of two's-complement byte-vectors matches numerical order.
;;@0 is its own functional inverse.
(define (integer-byte-collate byte-vector)
  (integer-byte-collate! (bytes-copy byte-vector)))

;;@body
;;Modifies @1 so that @code{string<?} ordering of IEEE floating-point
;;byte-vectors matches numerical order.  @0 returns @1.
(define (ieee-byte-collate! byte-vector)
  (cond ((logtest #x80 (byte-ref byte-vector 0))
	 (do ((idx (+ -1 (bytes-length byte-vector)) (+ -1 idx)))
	     ((negative? idx))
	   (byte-set! byte-vector idx
		      (logxor #xFF (byte-ref byte-vector idx)))))
	(else
	 (byte-set! byte-vector 0 (logxor #x80 (byte-ref byte-vector 0)))))
  byte-vector)
;;@body
;;Given @1 modified by @code{ieee-byte-collate!}, reverses the @1
;;modifications.
(define (ieee-byte-decollate! byte-vector)
  (cond ((not (logtest #x80 (byte-ref byte-vector 0)))
	 (do ((idx (+ -1 (bytes-length byte-vector)) (+ -1 idx)))
	     ((negative? idx))
	   (byte-set! byte-vector idx
		      (logxor #xFF (byte-ref byte-vector idx)))))
	(else
	 (byte-set! byte-vector 0 (logxor #x80 (byte-ref byte-vector 0)))))
  byte-vector)

;;@body
;;Returns copy of @1 encoded so that @code{string<?} ordering of IEEE
;;floating-point byte-vectors matches numerical order.
(define (ieee-byte-collate byte-vector)
  (ieee-byte-collate! (bytes-copy byte-vector)))
;;@body
;;Given @1 returned by @code{ieee-byte-collate}, reverses the @1
;;modifications.
(define (ieee-byte-decollate byte-vector)
  (ieee-byte-decollate! (bytes-copy byte-vector)))
