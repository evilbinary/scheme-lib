;;;; "crc.scm" Compute Cyclic Checksums
;;; Copyright (C) 1995, 1996, 1997, 2001, 2002 Aubrey Jaffer
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

;;@ (define CRC-32-polynomial    "100000100100000010001110110110111") ; IEEE-802, FDDI
(define CRC-32-polynomial    "100000100110000010001110110110111") ; IEEE-802, AAL5
;@
(define CRC-CCITT-polynomial "10001000000100001")	; X25
;@
(define CRC-16-polynomial    "11000000000000101")	; IBM Bisync, HDLC, SDLC, USB-Data

;;@ (define CRC-12-polynomial    "1100000001101")
(define CRC-12-polynomial    "1100000001111")

;;@ (define CRC-10-polynomial   "11000110001")
(define CRC-10-polynomial   "11000110011")
;@
(define CRC-08-polynomial    "100000111")
;@
(define ATM-HEC-polynomial   "100000111")
;@
(define DOWCRC-polynomial    "100110001")
;@
(define USB-Token-polynomial "100101")

;;This procedure is careful not to use more than DEG bits in
;;computing (- (expt 2 DEG) 1).  It returns #f if the integer would
;;be larger than the implementation supports.
(define (crc:make-mask deg)
  (string->number (make-string deg #\1) 2))
;@
(define (crc:make-table str)
  (define deg (+ -1 (string-length str)))
  (define generator (string->number (substring str 1 (string-length str)) 2))
  (define crctab (make-vector 256))
  (if (not (eqv? #\1 (string-ref str 0)))
      (slib:error 'crc:make-table 'first-digit-of-polynomial-must-be-1 str))
  (if (< deg 8)
      (slib:error 'crc:make-table 'degree-must-be>7 deg str))
  (and
   generator
   (do ((i 0 (+ 1 i))
	(deg-1-mask (crc:make-mask (+ -1 deg)))
	(gen generator
	     (if (logbit? (+ -1 deg) gen)
		 (logxor (ash (logand deg-1-mask gen) 1) generator)
		 (ash (logand deg-1-mask gen) 1)))
	(gens '() (cons gen gens)))
       ((>= i 8) (set! gens (reverse gens))
	(do ((crc 0 0)
	     (m 0 (+ 1 m)))
	    ((> m 255) crctab)
	  (for-each (lambda (gen i)
		      (set! crc (if (logbit? i m) (logxor crc gen) crc)))
		    gens '(0 1 2 3 4 5 6 7))
	  (vector-set! crctab m crc))))))

(define crc-32-table (crc:make-table CRC-32-polynomial))

;;@ Computes the P1003.2/D11.2 (POSIX.2) 32-bit checksum.
(define (cksum file)
  (cond ((not crc-32-table) #f)
	((input-port? file) (cksum-port file))
	(else (call-with-input-file file cksum-port))))

(define cksum-port
  (let ((mask-24 (crc:make-mask 24))
	(mask-32 (crc:make-mask 32)))
    (lambda (port)
      (define crc 0)
      (define (accumulate-crc byt)
	(set! crc
	      (logxor (ash (logand mask-24 crc) 8)
		      (vector-ref crc-32-table (logxor (ash crc -24) byt)))))
      (do ((byt (read-byte port) (read-byte port))
	   (byte-count 0 (+ 1 byte-count)))
	  ((eof-object? byt)
	   (do ((byte-count byte-count (ash byte-count -8)))
	       ((zero? byte-count) (logxor mask-32 crc))
	     (accumulate-crc (logand #xff byte-count))))
	(accumulate-crc byt)))))
;@
(define (crc16 file)
  (cond ((not crc-16-table) #f)
	((input-port? file) (crc16-port file))
	(else (call-with-input-file file crc16-port))))

(define crc-16-table (crc:make-table CRC-16-polynomial))

(define crc16-port
  (let ((mask-8 (crc:make-mask 8))
	(mask-16 (crc:make-mask 16)))
    (lambda (port)
      (define crc mask-16)
      (define (accumulate-crc byt)
	(set! crc
	      (logxor (ash (logand mask-8 crc) 8)
		      (vector-ref crc-16-table (logxor (ash crc -8) byt)))))
      (do ((byt (read-byte port) (read-byte port)))
	  ((eof-object? byt) (logxor mask-16 crc))
	(accumulate-crc byt)))))
;@
(define (crc5 file)
  (cond ((input-port? file) (crc5-port file))
	(else (call-with-input-file file crc5-port))))

(define (crc5-port port)
  (define generator #b00101)
  (define crc #b11111)
  (do ((byt (read-byte port) (read-byte port)))
      ((eof-object? byt) (logxor #b11111 crc))
    (do ((data byt (ash data 1))
	 (len (+ -1 8) (+ -1 len)))
	((negative? len))
      (set! crc
	    (logand #b11111
		    (if (eqv? (logbit? 7 data) (logbit? 4 crc))
			(ash crc 1)
			(logxor (ash crc 1) generator)))))))
