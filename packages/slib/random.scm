;;;; "random.scm" Pseudo-Random number generator for scheme.
;;; Copyright (C) 1991, 1993, 1998, 1999, 2002, 2003 Aubrey Jaffer
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
(require-if 'compiling 'object->string)	; for make-random-state

;;@code{(require 'random)}
;;@ftindex random

;;; random:chunk returns an integer in the range of 0 to 255.
;;; export for random-inexact:
;;@
(define (random:chunk sta)
  (cond ((positive? (byte-ref sta 258))
	 (byte-set! sta 258 0)
	 (slib:error "random state called reentrantly")))
  (byte-set! sta 258 1)
  (let* ((idx (logand #xff (+ 1 (byte-ref sta 256))))
	 (xtm (byte-ref sta idx))
	 (idy (logand #xff (+ (byte-ref sta 257) xtm))))
    (byte-set! sta 256 idx)
    (byte-set! sta 257 idy)
    (let ((ytm (byte-ref sta idy)))
      (byte-set! sta idy xtm)
      (byte-set! sta idx ytm)
      (let ((ans (byte-ref sta (logand #xff (+ ytm xtm)))))
	(byte-set! sta 258 0)
	ans))))


;;@args n state
;;@args n
;;
;;@1 must be an exact positive integer.  @0 returns an exact integer
;;between zero (inclusive) and @1 (exclusive).  The values returned by
;;@0 are uniformly distributed from 0 to @1.
;;
;;The optional argument @2 must be of the type returned by
;;@code{(seed->random-state)} or @code{(make-random-state)}.  It
;;defaults to the value of the variable @code{*random-state*}.  This
;;object is used to maintain the state of the pseudo-random-number
;;generator and is altered as a side effect of calls to @code{random}.
(define (random modu . args)
  (define state (if (null? args) *random-state* (car args)))
  (define bitlen (integer-length (+ -1 modu)))
  (define (rnd)
    (do ((bln bitlen (+ -8 bln))
	 (rbs 0 (+ (arithmetic-shift rbs 8) (random:chunk state))))
	((<= bln 7)
	 (cond ((positive? bln)
		(set! rbs (logxor (arithmetic-shift rbs bln)
				  (random:chunk state)))
		(if (>= rbs modu) (rnd) rbs))
	       ((>= rbs modu 1) (rnd))
	       ((positive? modu) rbs)
	       (else (slib:error 'random 'not 'positive? modu))))))
  (rnd))

;;@defvar *random-state*
;;Holds a data structure that encodes the internal state of the
;;random-number generator that @code{random} uses by default.  The nature
;;of this data structure is implementation-dependent.  It may be printed
;;out and successfully read back in, but may or may not function correctly
;;as a random-number state object in another implementation.
;;@end defvar


;;@args state
;;Returns a new copy of argument @1.
;;
;;@args
;;Returns a new copy of @code{*random-state*}.
(define (copy-random-state . sta)
  (bytes-copy (if (null? sta) *random-state* (car sta))))


;;@body
;;Returns a new object of type suitable for use as the value of the
;;variable @code{*random-state*} or as a second argument to @code{random}.
;;The number or string @1 is used to initialize the state.  If
;;@0 is called twice with arguments which are
;;@code{equal?}, then the returned data structures will be @code{equal?}.
;;Calling @0 with unequal arguments will nearly
;;always return unequal states.
(define (seed->random-state seed)
  (define sta (make-bytes (+ 3 256) 0))
  (if (number? seed) (set! seed (number->string seed)))
					; initialize state
  (do ((idx #xff (+ -1 idx)))
      ((negative? idx))
    (byte-set! sta idx idx))
					; merge seed into state
  (do ((i 0 (+ 1 i))
       (j 0 (modulo (+ 1 j) seed-len))
       (seed-len (string-length seed))
       (k 0))
      ((>= i 256))
    (let ((swp (byte-ref sta i)))
      (set! k (logand #xff (+ k
			      (modulo (char->integer (string-ref seed j)) 255)
			      swp)))
      (byte-set! sta i (byte-ref sta k))
      (byte-set! sta k swp)))
  sta)


;;@args
;;@args obj
;;Returns a new object of type suitable for use as the value of the
;;variable @code{*random-state*} or as a second argument to @code{random}.
;;If the optional argument @var{obj} is given, it should be a printable
;;Scheme object; the first 50 characters of its printed representation
;;will be used as the seed.  Otherwise the value of @code{*random-state*}
;;is used as the seed.
(define (make-random-state . args)
  (let ((seed (if (null? args) *random-state* (car args))))
    (cond ((string? seed))
	  ((number? seed) (set! seed (number->string seed)))
	  (else (let ()
		  (require 'object->string)
		  (set! seed (object->limited-string seed 50)))))
    (seed->random-state seed)))
;@
(define *random-state*
  (make-random-state "http://swissnet.ai.mit.edu/~jaffer/SLIB.html"))
