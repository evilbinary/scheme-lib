;;; "pnm.scm" Read and write PNM image files.
; Copyright 2000, 2003 Aubrey Jaffer
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
(require 'subarray)
(require 'array-for-each)
(require 'line-i/o)
(require 'logical)
(require 'byte)
(require 'multiarg-apply)

;;@code{(require 'pnm)}
;;@ftindex pnm

(define (pnm:read-pbm-char port)
  (let loop ((chr (read-char port)))
    (case chr
      ((#\0) #f)
      ((#\1) #t)
      ((#\#)
       (read-line port)
       (loop (read-char port)))
      (else
       (if (char-whitespace? chr)
           (loop (read-char port))
           (slib:error chr 'unexpected 'character))))))

;; Comments beginning with "#" and ending with newline are permitted in
;; the header of a pnm file.
(define (pnm:read-value port)
  (let loop ()
    (let ((chr (peek-char port)))
      (cond ((eof-object? chr)
             (slib:error 'unexpected 'eof port))
            ((char-whitespace? chr)
             (read-char port)
             (loop))
            ((char=? chr #\#)
             (read-line port)
             (loop))
            (else (read port))))))

;;@args path
;;The string @1 must name a @dfn{portable bitmap graphics} file.
;;@0 returns a list of 4 items:
;;@enumerate
;;@item
;;A symbol describing the type of the file named by @1.
;;@item
;;The image width in pixels.
;;@item
;;The image height in pixels.
;;@item
;;The maximum value of pixels assume in the file.
;;@end enumerate
;;
;;The current set of file-type symbols is:
;;@table @asis
;;@item pbm
;;@itemx pbm-raw
;;@cindex pbm
;;@cindex pbm-raw
;;Black-and-White image; pixel values are 0 or 1.
;;@item pgm
;;@itemx pgm-raw
;;@cindex pgm
;;@cindex pgm-raw
;;Gray (monochrome) image; pixel values are from 0 to @var{maxval}
;;specified in file header.
;;@item ppm
;;@itemx ppm-raw
;;@cindex ppm
;;@cindex ppm-raw
;;RGB (full color) image; red, green, and blue interleaved pixel values
;;are from 0 to @var{maxval}
;;@end table
(define (pnm:type-dimensions port)
  (if (input-port? port)
      (let* ((c1 (read-char port))
	     (c2 (read-char port)))
	(cond
	 ((and (eqv? #\P c1)
	       (char? c2)
	       (char-numeric? c2)
	       (char-whitespace? (peek-char port)))
	  (let* ((format (string->symbol (string #\p c2)))
		 (width (pnm:read-value port))
		 (height (pnm:read-value port))
		 (ret
		  (case format
		    ((p1) (list 'pbm     width height 1))
		    ((p4) (list 'pbm-raw width height 1))
		    ((p2) (list 'pgm     width height (pnm:read-value port)))
		    ((p5) (list 'pgm-raw width height (pnm:read-value port)))
		    ((p3) (list 'ppm     width height (pnm:read-value port)))
		    ((p6) (list 'ppm-raw width height (pnm:read-value port)))
		    (else #f))))
	    (and (char-whitespace? (read-char port)) ret)))
	 (else #f)))
      (call-with-open-ports (open-file port 'rb) pnm:type-dimensions)))

(define (pnm:write-bits array port)
  (define dims (array-dimensions array))
  (let* ((height (car (array-dimensions array)))
	 (width (cadr (array-dimensions array)))
	 (wid8 (logand -8 width)))
    (do ((jdx 0 (+ 1 jdx)))
	((>= jdx height))
      (let ((row (subarray array jdx)))
	(do ((idx 0 (+ 8 idx)))
	    ((>= idx wid8)
	     (if (< idx width)
		 (do ((idx idx (+ 1 idx))
		      (bdx 7 (+ -1 bdx))
		      (bts 0 (+ bts (ash (if (array-ref row idx) 1 0) bdx))))
		     ((>= idx width)
		      (write-byte bts port)))))
	  (do ((idx idx (+ 1 idx))
	       (bdx 7 (+ -1 bdx))
	       (bts 0 (+ bts bts (if (array-ref row idx) 1 0))))
	      ((negative? bdx)
	       (write-byte bts port))))))))

(define (pnm:read-bits! array port)
  (define dims (array-dimensions array))
  (let* ((height (car (array-dimensions array)))
	 (width (cadr (array-dimensions array)))
	 (wid8 (logand -8 width)))
    (do ((jdx 0 (+ 1 jdx)))
	((>= jdx height))
      (let ((row (subarray array jdx)))
	(do ((idx 0 (+ 8 idx)))
	    ((>= idx wid8)
	     (if (< idx width)
		 (let ((byt (read-byte port)))
		   (do ((idx idx (+ 1 idx))
			(bdx 7 (+ -1 bdx)))
		       ((>= idx width))
		     (array-set! row (logbit? bdx byt) idx)))))
	  (let ((byt (read-byte port)))
	    (array-set! row (logbit? 7 byt) (+ 0 idx))
	    (array-set! row (logbit? 6 byt) (+ 1 idx))
	    (array-set! row (logbit? 5 byt) (+ 2 idx))
	    (array-set! row (logbit? 4 byt) (+ 3 idx))
	    (array-set! row (logbit? 3 byt) (+ 4 idx))
	    (array-set! row (logbit? 2 byt) (+ 5 idx))
	    (array-set! row (logbit? 1 byt) (+ 6 idx))
	    (array-set! row (logbit? 0 byt) (+ 7 idx)))))))
  (if (eof-object? (peek-char port))
      array
      (do ((chr (read-char port) (read-char port))
	   (cnt 0 (+ 1 cnt)))
	  ((eof-object? chr) (slib:error cnt 'bytes 'remain 'in port)))))

;;@args path array
;;
;;Reads the @dfn{portable bitmap graphics} file named by @var{path} into
;;@var{array}.  @var{array} must be the correct size and type for
;;@var{path}.  @var{array} is returned.
;;
;;@args path
;;
;;@code{pnm:image-file->array} creates and returns an array with the
;;@dfn{portable bitmap graphics} file named by @var{path} read into it.
(define (pnm:image-file->array path . array)
  (set! array (and (not (null? array)) (car array)))
  (call-with-open-ports
   (open-file path 'rb)
   (lambda (port)
     (apply (lambda (type width height max-pixel)
	      (define (read-binary)
		(array-map! array
			    (if (<= max-pixel 256)
				(lambda () (read-byte port))
				(lambda () (define hib (read-byte port))
					(+ (* 256 hib) (read-byte port)))))
		(if (eof-object? (peek-char port)) array
		    (slib:error type 'not 'at 'file 'end)))
	      (define (read-text)
		(array-map! array (lambda () (read port)))
		(if (not (eof-object? (read port)))
		    (slib:warn type 'not 'at 'file 'end))
		array)
	      (define (read-pbm)
		(array-map! array (lambda () (pnm:read-pbm-char port)))
		(if (not (eof-object? (read port)))
		    (slib:warn type 'not 'at 'file 'end))
		array)
	      (case type
		((pbm)
		 (or array
		     (set! array (make-array (A:bool) height width)))
		 (read-pbm))
		((pgm)
		 (or array
		     (set! array (make-array
				  ((if (<= max-pixel 256) A:fixN8b A:fixN16b))
				  height width)))
		 (read-text))
		((ppm)
		 (or array
		     (set! array (make-array
				  ((if (<= max-pixel 256) A:fixN8b A:fixN16b))
				  height width 3)))
		 (read-text))
		((pbm-raw)
		 (or array
		     (set! array (make-array (A:bool) height width)))
		 (pnm:read-bits! array port))
		((pgm-raw)
		 (or array
		     (set! array (make-array (A:fixN8b) height width)))
		 (read-binary))
		((ppm-raw)
		 (or array
		     (set! array (make-array (A:fixN8b) height width 3)))
		 (read-binary))))
	    (pnm:type-dimensions port)))))

;;@args type array maxval path comment @dots{}
;;
;;Writes the contents of @2 to a @1 image file named @4.  The file
;;will have pixel values between 0 and @3, which must be compatible
;;with @1.  For @samp{pbm} files, @3 must be @samp{1}.
;;@var{comment}s are included in the file header.
(define (pnm:array-write type array maxval port . comments)
  (define (write-header type height width maxval)
    (let ((magic
	   (case type
	     ((pbm) "P1")
	     ((pgm) "P2")
	     ((ppm) "P3")
	     ((pbm-raw) "P4")
	     ((pgm-raw) "P5")
	     ((ppm-raw) "P6")
	     (else (slib:error 'pnm:array-write "bad type" type)))))
      (display magic port) (newline port)
      (for-each (lambda (str)
		  (display "#" port) (display str port) (newline port))
		comments)
      (display width port) (display " " port) (display height port)
      (cond (maxval (newline port) (display maxval port)))))
  (define (write-pixels type array maxval)
    (let* ((shp (array-dimensions array))
	   (height (car shp))
	   (width (cadr shp)))
      (case type
	((pbm-raw)
	 (newline port)
	 (if (not (boolean? (array-ref array 0 0)))
	     (slib:error 'pnm:array-write "expected bit-array" array))
	 (pnm:write-bits array port))
	((pgm-raw ppm-raw)
	 (newline port)
	 (array-for-each (if (<= maxval 256)
			     (lambda (byt) (write-byte byt port))
			     (lambda (byt)
			       (write-byte (quotient byt 256) port)
			       (write-byte (modulo byt 256) port)))
			 array))
	((pbm)
	 (do ((i 0 (+ i 1)))
	     ((>= i height))
	   (do ((j 0 (+ j 1)))
	       ((>= j width))
	     (display (if (zero? (remainder j 35)) #\newline #\space) port)
	     (display (if (array-ref array i j) #\1 #\0) port)))
	 (newline port))
	((pgm)
	 (do ((i 0 (+ i 1)))
	     ((>= i height))
	   (do ((j 0 (+ j 1)))
	       ((>= j width))
	     (display (if (zero? (remainder j 17)) #\newline #\space) port)
	     (display (array-ref array i j) port)))
	 (newline port))
	((ppm)
	 (do ((i 0 (+ i 1)))
	     ((>= i height))
	   (do ((j 0 (+ j 1)))
	       ((>= j width))
	     (display (if (zero? (remainder j 5)) #\newline "  ") port)
	     (display (array-ref array i j 0) port)
	     (display #\space port)
	     (display (array-ref array i j 1) port)
	     (display #\space port)
	     (display (array-ref array i j 2) port)))
	 (newline port)))))

  (if (output-port? port)
      (let ((rnk (array-rank array))
	    (shp (array-dimensions array)))
	(case type
	  ((pbm pbm-raw)
	   (or (and (eqv? 2 rnk)
		    (integer? (car shp))
		    (integer? (cadr shp)))
	       (slib:error 'pnm:array-write "bad shape" type array))
	   (or (eqv? 1 maxval)
	       (slib:error 'pnm:array-write "maxval supplied not 1" type))
	   (write-header type (car shp) (cadr shp) #f)
	   (write-pixels type array 1))
	  ((pgm pgm-raw)
	   (or (and (eqv? 2 rnk)
		    (integer? (car shp))
		    (integer? (cadr shp)))
	       (slib:error 'pnm:array-write "bad shape" type array))
	   (write-header type (car shp) (cadr shp) maxval)
	   (write-pixels type array maxval))
	  ((ppm ppm-raw)
	   (or (and (eqv? 3 rnk)
		    (integer? (car shp))
		    (integer? (cadr shp))
		    (eqv? 3 (caddr shp)))
	       (slib:error 'pnm:array-write "bad shape" type array))
	   (write-header type (car shp) (cadr shp) maxval)
	   (write-pixels type array maxval))
	  (else (slib:error 'pnm:array-write type 'unrecognized 'type))))
      (call-with-open-ports
       (open-file port 'wb)
       (lambda (port)
	 (apply pnm:array-write type array maxval port comments)))))
