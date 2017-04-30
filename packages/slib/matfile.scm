; "matfile.scm", Read MAT-File Format version 4 (MATLAB)
; Copyright (C) 2001, 2002, 2003 Aubrey Jaffer
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
(require 'byte)
(require 'byte-number)
(require-if 'compiling 'string-case) ; string-ci->symbol used by matfile:load

(define (unwritten-stubber name)
  (lambda (arg) (slib:error 'name 'not 'written "matfile.scm")))
(define bytes->vax-d-double (unwritten-stubber 'bytes->vax-d-double))
(define bytes->vax-g-double (unwritten-stubber 'bytes->vax-g-double))
(define bytes->cray-double  (unwritten-stubber 'bytes->cray-double))
(define bytes->vax-d-float  (unwritten-stubber 'bytes->vax-d-float))
(define bytes->vax-g-float  (unwritten-stubber 'bytes->vax-g-float))
(define bytes->cray-float   (unwritten-stubber 'bytes->cray-float))

;;@code{(require 'matfile)}
;;@ftindex matfile
;;@ftindex matlab
;;
;;@uref{http://www.mathworks.com/access/helpdesk/help/pdf_doc/matlab/matfile_format.pdf}
;;
;;@noindent
;;This package reads MAT-File Format version 4 (MATLAB) binary data
;;files.  MAT-files written from big-endian or little-endian computers
;;having IEEE format numbers are currently supported.  Support for files
;;written from VAX or Cray machines could also be added.
;;
;;@noindent
;;The numeric and text matrix types handled; support for @dfn{sparse}
;;matrices awaits a sample file.

(define (bytes->long lst)
  (bytes->integer lst -4))
(define (bytes->short lst)
  (bytes->integer lst -2))
(define (bytes->ushort lst)
  (bytes->integer lst  2))

;;Version 4 MAT-file endianness cannot be detected solely from the
;;first word; it is ambiguous when 0.
(define (matfile:read-matrix port)
  (define null (integer->char 0))
  (define (read1 endian type mrows ncols imagf namlen)
    (set! type (bytes->long type))
    (set! mrows (bytes->long mrows))
    (set! ncols (bytes->long ncols))
    (set! imagf (bytes->long imagf))
    (set! namlen (+ -1 (bytes->long namlen)))
    (let ((d-prot (modulo (quotient type 10) 10))
	  (d-endn (case (quotient type 1000)
		    ((0			;ieee-little-endian
		      2			;vax-d-float
		      3) endian)	;vag-g-float
		    ((1			;ieee-big-endian
		      4) (- endian))	;cray
		    (else #f)))
	  (m-type (case (modulo type 10)
		    ((0) 'numeric)
		    ((1) 'text)
		    ((2) 'sparse)
		    (else #f))))
      (define d-leng (case d-prot
		       ((0) 8)
		       ((1 2) 4)
		       ((3 4) 2)
		       ((5) 1)
		       (else #f)))
      (define d-conv (case d-prot
		       ((0) (case (quotient type 1000)
			      ((0 1) bytes->ieee-double)
			      ((2) bytes->vax-d-double)
			      ((3) bytes->vax-g-double)
			      ((4) bytes->cray-double)))
		       ((1) (case (quotient type 1000)
			      ((0 1) bytes->ieee-float)
			      ((2) bytes->vax-d-float)
			      ((3) bytes->vax-g-float)
			      ((4) bytes->cray-float)))
		       ((2) bytes->long)
		       ((3) bytes->short)
		       ((4) bytes->ushort)
		       ((5) (if (eqv? 'text m-type)
				(lambda (lst) (integer->char (byte-ref lst 0)))
				(lambda (lst) (byte-ref lst 0))))
		       (else #f)))
      ;;(@print d-leng d-endn m-type type mrows ncols imagf namlen d-conv)
      (cond ((and (= 0 (modulo (quotient type 100) 10) (quotient type 65536))
		  d-leng d-endn m-type
		  (<= 0 imagf 1)
		  (< 0 mrows #xFFFFFF)
		  (< 0 ncols #xFFFFFF)
		  (< 0 namlen #xFFFF))
	     (set! imagf (case imagf ((0) #f) ((1) #t)))
	     (let ((namstr (make-string namlen))
		   (mat (case m-type
			  ((numeric) (make-array
				      (case d-prot
					((0) ((if imagf A:floC64b A:floR64b)))
					((1) ((if imagf A:floC32b A:floR32b)))
					((2) (A:fixZ32b))
					((3) (A:fixZ16b))
					((4) (A:fixN16b))
					((5) (A:fixN8b))
					(else (slib:error 'p 'type d-prot)))
				      mrows ncols))
			  ((text)    (make-array "." mrows ncols))
			  ((sparse)  (slib:error 'sparse '?))))
		   (d-endn*leng (* -1 d-endn d-leng)))
	       (do ((idx 0 (+ 1 idx)))
		   ((>= idx namlen))
		 (string-set! namstr idx (read-char port)))
	       ;;(@print namstr)
	       (if (not (eqv? null (read-char port)))
		   (slib:error 'matfile 'string 'missing null))
	       (do ((jdx 0 (+ 1 jdx)))
		   ((>= jdx ncols))
		 (do ((idx 0 (+ 1 idx)))
		     ((>= idx mrows))
		   (array-set! mat (d-conv (read-bytes d-endn*leng port))
			       idx jdx)))
	       (if imagf
		   (do ((jdx 0 (+ 1 jdx)))
		       ((>= jdx ncols))
		     (do ((idx 0 (+ 1 idx)))
			 ((>= idx mrows))
		       (array-set! mat
				   (+ (* (d-conv (read-bytes d-endn*leng port))
					 +i)
				      (array-ref mat idx jdx))
				   idx jdx))))
	       (list namstr mat)))
	    (else #f))))
  ;;(trace read1)
  (let* ((type (read-bytes 4 port))
	 (mrows (read-bytes 4 port))
	 (ncols (read-bytes 4 port))
	 (imagf (read-bytes 4 port))
	 (namlen (read-bytes 4 port)))
    ;;Try it with either endianness:
    (or (read1 1 type mrows ncols imagf namlen)
	(read1 -1
	       (bytes-reverse type)
	       (bytes-reverse mrows)
	       (bytes-reverse ncols)
	       (bytes-reverse imagf)
	       (bytes-reverse namlen)))))

;;@body @1 should be a string naming an existing file containing a
;;MATLAB Version 4 MAT-File.  The @0 procedure reads matrices from the
;;file and returns a list of the results; a list of the name string and
;;array for each matrix.
(define (matfile:read filename)
  (call-with-open-ports
   (open-file filename 'rb)
   (lambda (port)
     (do ((mat (matfile:read-matrix port) (matfile:read-matrix port))
	  (mats '() (cons mat mats)))
	 ((or (not mat) (eof-object? (peek-char port)))
	  (if (and (null? mats) (not mat))
	      '()
	      (reverse (cons mat mats))))))))

;;@body @1 should be a string naming an existing file containing a
;;MATLAB Version 4 MAT-File.  The @0 procedure reads matrices from the
;;file and defines the @code{string-ci->symbol} for each matrix to its
;;corresponding array.  @0 returns a list of the symbols defined.
(define (matfile:load filename)
  (require 'string-case)
  (let ((mats (matfile:read filename)))
    (for-each (lambda (nam-mat)
		(and nam-mat
		     (slib:eval
		      (list 'define
			    (string-ci->symbol (car nam-mat))
			    (list 'quote (cadr nam-mat))))))
	      mats)
    (map string-ci->symbol (map car mats))))

;;(trace-all "/home/jaffer/slib/matfile.scm")
