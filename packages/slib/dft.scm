;;;"dft.scm" Discrete Fourier Transform
;Copyright (C) 1999, 2003, 2006 Aubrey Jaffer
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

;;;; For one-dimensional power-of-two length see:
;;; Introduction to Algorithms (MIT Electrical
;;;    Engineering and Computer Science Series)
;;; by Thomas H. Cormen, Charles E. Leiserson (Contributor),
;;;    Ronald L. Rivest (Contributor)
;;; MIT Press; ISBN: 0-262-03141-8 (July 1990)

;;; Flipped polarity of exponent to agree with
;;; http://en.wikipedia.org/wiki/Discrete_Fourier_transform

(require 'array)
(require 'logical)
(require 'subarray)
(require 'multiarg-apply)

;;@code{(require 'dft)} or
;;@code{(require 'Fourier-transform)}
;;@ftindex dft, Fourier-transform
;;
;;@code{fft} and @code{fft-1} compute the Fast-Fourier-Transforms
;;(O(n*log(n))) of arrays whose dimensions are all powers of 2.
;;
;;@code{sft} and @code{sft-1} compute the Discrete-Fourier-Transforms
;;for all combinations of dimensions (O(n^2)).

(define (dft:sft1d! new ara n dir)
  (define scl (if (negative? dir) (/ 1.0 n) 1))
  (define pi2i/n (/ (* 0-8i (atan 1) dir) n))
  (do ((k (+ -1 n) (+ -1 k)))
      ((negative? k) new)
    (let ((sum 0))
      (do ((j (+ -1 n) (+ -1 j)))
	  ((negative? j) (array-set! new sum k))
	(set! sum (+ sum (* (exp (* pi2i/n j k))
			    (array-ref ara j)
			    scl)))))))

(define (dft:fft1d! new ara n dir)
  (define scl (if (negative? dir) (/ 1.0 n) 1))
  (define lgn (integer-length (+ -1 n)))
  (define pi2i (* 0-8i (atan 1) dir))
  (do ((k 0 (+ 1 k)))
      ((>= k n))
    (array-set! new (* (array-ref ara k) scl) (reverse-bit-field k 0 lgn)))
  (do ((s 1 (+ 1 s))
       (m (expt 2 1) (expt 2 (+ 1 s))))
      ((> s lgn) new)
    (let ((w_m (exp (/ pi2i m)))
	  (m/2-1 (+ (quotient m 2) -1)))
      (do ((j 0 (+ 1 j))
	   (w 1 (* w w_m)))
	  ((> j m/2-1))
	(do ((k j (+ m k))
	     (k+m/2 (+ j m/2-1 1) (+ m k m/2-1 1)))
	    ((>= k n))
	  (let ((t (* w (array-ref new k+m/2)))
		(u (array-ref new k)))
	    (array-set! new (+ u t) k)
	    (array-set! new (- u t) k+m/2)))))))

;;; Row-major order is suboptimal for Scheme.
;;; N are copied into and operated on in place
;;;  A[a, *, c] --> N1[c, a, *]
;;; N1[c, *, b] --> N2[b, c, *]
;;; N2[b, *, a] --> N3[a, b, *]

(define (dft:rotate-indexes idxs)
  (define ridxs (reverse idxs))
  (cons (car ridxs) (reverse (cdr ridxs))))

(define (dft:dft prot ara dir transform-1d)
  (define (ranker ara rdx dims)
    (define ndims (dft:rotate-indexes dims))
    (if (negative? rdx)
	ara
	(let ((new (apply make-array prot ndims))
	      (rdxlen (car (last-pair ndims))))
	  (define x1d
	    (cond (transform-1d)
		  ((eqv? rdxlen (expt 2 (integer-length (+ -1 rdxlen))))
		   dft:fft1d!)
		  (else dft:sft1d!)))
	  (define (ramap rdims inds)
	    (cond ((null? rdims)
		   (x1d (apply subarray new (dft:rotate-indexes inds))
			(apply subarray ara inds)
			rdxlen dir))
		  ((null? inds)
		   (do ((i (+ -1 (car rdims)) (+ -1 i)))
		       ((negative? i))
		     (ramap (cddr rdims)
			    (cons #f (cons i inds)))))
		  (else
		   (do ((i (+ -1 (car rdims)) (+ -1 i)))
		       ((negative? i))
		     (ramap (cdr rdims) (cons i inds))))))
	  (if (= 1 (length dims))
	      (x1d new ara rdxlen dir)
	      (ramap (reverse dims) '()))
	  (ranker new (+ -1 rdx) ndims))))
  (ranker ara (+ -1 (array-rank ara)) (array-dimensions ara)))

;;@args array prot
;;@args array
;;@var{array} is an array of positive rank.  @code{sft} returns an
;;array of type @2 (defaulting to @1) of complex numbers comprising
;;the @dfn{Discrete Fourier Transform} of @var{array}.
(define (sft ara . prot)
  (dft:dft (if (null? prot) ara (car prot)) ara 1 dft:sft1d!))

;;@args array prot
;;@args array
;;@var{array} is an array of positive rank.  @code{sft-1} returns an
;;array of type @2 (defaulting to @1) of complex numbers comprising
;;the inverse Discrete Fourier Transform of @var{array}.
(define (sft-1 ara . prot)
  (dft:dft (if (null? prot) ara (car prot)) ara -1 dft:sft1d!))

(define (dft:check-dimensions ara name)
  (for-each (lambda (n)
	      (if (not (eqv? n (expt 2 (integer-length (+ -1 n)))))
		  (slib:error name "array length not power of 2" n)))
	    (array-dimensions ara)))

;;@args array prot
;;@args array
;;@var{array} is an array of positive rank whose dimensions are all
;;powers of 2.  @code{fft} returns an array of type @2 (defaulting to
;;@1) of complex numbers comprising the Discrete Fourier Transform of
;;@var{array}.
(define (fft ara . prot)
  (dft:check-dimensions ara 'fft)
  (dft:dft (if (null? prot) ara (car prot)) ara 1 dft:fft1d!))

;;@args array prot
;;@args array
;;@var{array} is an array of positive rank whose dimensions are all
;;powers of 2.  @code{fft-1} returns an array of type @2 (defaulting
;;to @1) of complex numbers comprising the inverse Discrete Fourier
;;Transform of @var{array}.
(define (fft-1 ara . prot)
  (dft:check-dimensions ara 'fft-1)
  (dft:dft (if (null? prot) ara (car prot)) ara -1 dft:fft1d!))

;;@code{dft} and @code{dft-1} compute the discrete Fourier transforms
;;using the best method for decimating each dimension.

;;@args array prot
;;@args array
;;@0 returns an array of type @2 (defaulting to @1) of complex
;;numbers comprising the Discrete Fourier Transform of @var{array}.
(define (dft ara . prot)
  (dft:dft (if (null? prot) ara (car prot)) ara 1 #f))

;;@args array prot
;;@args array
;;@0 returns an array of type @2 (defaulting to @1) of
;;complex numbers comprising the inverse Discrete Fourier Transform of
;;@var{array}.
(define (dft-1 ara . prot)
  (dft:dft (if (null? prot) ara (car prot)) ara -1 #f))

;;@noindent
;;@code{(fft-1 (fft @var{array}))} will return an array of values close to
;;@var{array}.
;;
;;@example
;;(fft '#(1 0+i -1 0-i 1 0+i -1 0-i)) @result{}
;;
;;#(0.0 0.0 0.0+628.0783185208527e-18i 0.0
;;  0.0 0.0 8.0-628.0783185208527e-18i 0.0)
;;
;;(fft-1 '#(0 0 0 0 0 0 8 0)) @result{}
;;
;;#(1.0 -61.23031769111886e-18+1.0i -1.0 61.23031769111886e-18-1.0i
;;  1.0 -61.23031769111886e-18+1.0i -1.0 61.23031769111886e-18-1.0i)
;;@end example
