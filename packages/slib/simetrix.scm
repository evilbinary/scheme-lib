;;;; "simetrix.scm" SI Metric Interchange Format for Scheme
;;; Copyright (C) 2000, 2001, 2006 Aubrey Jaffer
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

;; Implements "Representation of numerical values and SI units in
;; character strings for information interchanges"
;; http://people.csail.mit.edu/jaffer/MIXF

(require 'precedence-parse)
(require 'string-port)

;;; Combine alists
(define (SI:adjoin unitlst SIms)
  (for-each (lambda (new)
	      (define pair (assoc (car new) SIms))
	      (if pair
		  (set-cdr! pair (+ (cdr new) (cdr pair)))
		  (set! SIms (cons (cons (car new) (cdr new)) SIms))))
	    unitlst)
  SIms)

;;; Combine unit-alists
(define (SI:product unit1 unit2)
  (define nunits '())
  (set! unit1 (SI:expand-unit unit1))
  (set! unit2 (SI:expand-unit unit2))
  (cond ((and unit1 unit2)
	 (set! nunits (SI:adjoin unit1 nunits))
	 (set! nunits (SI:adjoin unit2 nunits))
	 nunits)
	(else #f)))

(define (SI:quotient unit1 . units)
  (apply SI:product unit1
	 (map (lambda (unit) (SI:pow unit -1)) units)))

(define (SI:pow unit expon)
  (define punit (SI:expand-unit unit))
  (and punit (number? expon)
       (map (lambda (unit-pair)
	      (cons (car unit-pair) (* (cdr unit-pair) expon)))
	    punit)))

;;; Parse helper functions.
(define (SI:solidus . args)
  (if (and (= 2 (length args))
	   (number? (car args))
	   (number? (cadr args)))
      (/ (car args) (cadr args))
      (apply SI:quotient args)))

(define (SI:e arg1 arg2)
  (cond ((and (number? arg1) (number? arg2)
	      (exact? arg2))
	 (let ((expo (string->number
		      (string-append "1e" (number->string arg2)))))
	   (and expo (* arg1 expo))))
	(else (SI:product arg1 arg2))))

(define (SI:dot arg1 arg2)
  (cond ((and (number? arg1) (number? arg2)
	      (exact? arg1) (exact? arg2)
	      (positive? arg2))
	 (string->number
	  (string-append (number->string arg1) "." (number->string arg2))))
	(else (SI:product arg1 arg2))))

(define (SI:minus arg) (and (number? arg) (- arg)))

(define (SI:identity . args) (and (= 1 (length args)) (car args)))

;;; Binary prefixes are (zero? (modulo expo 10))
(define SI:prefix-exponents
  '(("Y" 24) ("Z" 21) ("E" 18) ("P" 15)
    ("T" 12) ("G" 9) ("M" 6) ("k" 3) ("h" 2) ("da" 1)
    ("d" -1) ("c" -2) ("m" -3) ("u" -6) ("n" -9)
    ("p" -12) ("f" -15) ("a" -18) ("z" -21) ("y" -24)

    ("Ei" 60) ("Pi" 50) ("Ti" 40) ("Gi" 30) ("Mi" 20) ("Ki" 10)
    ))

(define SI:unit-infos
  `(
    ("s" all #f)
    ("min" none "60.s")
    ("h" none "3600.s")
    ("d" none "86400.s")
    ("Hz" all "s^-1")
    ("Bd" pos "s^-1")
    ("m" all #f)
    ("L" neg "dm^3")
    ("rad" neg #f)
    ("sr" neg "rad^2")
    ("r" pos ,(string-append (number->string (* 8 (atan 1))) ".rad"))
    ("o" neg ,(string-append (number->string (/ 360)) ".r"))
    ("bit" bin #f)
    ("B" pin "8.b")
    ("g" all #f)
    ("t" pos "Mg")
    ("u" none "1.66053886e-27.kg")
    ("mol" all #f)
    ("kat" all "mol/s")
    ("K" all #f)
    ("oC" neg #f)
    ("cd" all #f)
    ("lm" all "cd.sr")
    ("lx" all "lm/m^2")
    ("N" all "m.kg/s^2")
    ("Pa" all "N/m^2")
    ("J" all "N.m")
    ("eV" all "1.60217653e-19.J")
    ("W" all "J/s")
    ("Np" neg #f)
    ("dB" none ,(string-append (number->string (/ (log 10) 20)) ".Np"))
    ("A" all #f)
    ("C" all "A.s")
    ("V" all "W/A")
    ("F" all "C/V")
    ("Ohm" all "V/A")
    ("S" all "A/V")
    ("Wb" all "V.s")
    ("T" all "Wb/m^2")
    ("H" all "Wb/A")
    ("Bq" all "s^-1")
    ("Gy" all "m^2.s^-2")
    ("Sv" all "m^2.s^-2")
    ))

(define (SI:try-split preSI SIm)
  (define expo (assoc preSI SI:prefix-exponents))
  (define stuff (assoc SIm SI:unit-infos))
  (if expo (set! expo (cadr expo)))
  (if stuff (set! stuff (cdr stuff)))
  (and expo stuff
       (let ((equivalence (cadr stuff)))
	 (and (case (car stuff)		;restriction
		((all) (not (zero? (modulo expo 10))))
		((pos) (and (positive? expo) (not (zero? (modulo expo 10)))))
		((bin) #t)
		((pin) (positive? expo))
		((neg) (and (negative? expo) (not (zero? (modulo expo 10)))))
		((none) #f)
		(else #f))
	      (if (and (positive? expo) (zero? (modulo expo 10)))
		  (if equivalence
		      (let ((eqv (SI:expand-equivalence equivalence)))
			(and eqv
			     (SI:adjoin (list (cons 1024 (quotient expo 10)))
					eqv)))
		      (list (cons 1024 (quotient expo 10))
			    (cons SIm 1)))
		  (if equivalence
		      (let ((eqv (SI:expand-equivalence equivalence)))
			(and eqv (SI:adjoin (list (cons 10 expo)) eqv)))
		      (list (cons 10 expo) (cons SIm 1))))))))

(define (SI:try-simple SIm)
  (define stuff (assoc SIm SI:unit-infos))
  (if stuff (set! stuff (cdr stuff)))
  (and stuff (if (cadr stuff)
		 (SI:expand-equivalence (cadr stuff))
		 (list (cons SIm 1)))))

(define (SI:expand-unit str)
  (if (symbol? str) (set! str (symbol->string str)))
  (cond
   ((pair? str) str)
   ((number? str) (list (cons str 1)))
   ((string? str)
    (let ((len (string-length str)))
      (let ((s1 (and (> len 1)
		     (SI:try-split (substring str 0 1) (substring str 1 len))))
	    (s2 (and (> len 2)
		     (SI:try-split (substring str 0 2) (substring str 2 len))))
	    (sn (and (SI:try-simple str))))
	(define cnt (+ (if s1 1 0) (if s2 1 0) (if sn 1 0)))
	(if (> cnt 1) (slib:warn 'ambiguous s1 s2 sn))
	(or s1 s2 sn))))
   (else #f)))

(define (SI:expand-equivalence str)
  (call-with-input-string
      str (lambda (sport)
	    (define result (prec:parse SI:grammar 'EOS 0 sport))
	    (cond ((eof-object? result) (list (cons 1 0)))
		  ((symbol? result) (SI:expand-unit result))
		  (else result)))))

;;;;@ advertised interface
(define (SI:conversion-factor to-unit from-unit)
  (let ((funit (SI:expand-equivalence from-unit))
	(tunit (SI:expand-equivalence to-unit)))
    (if (and funit tunit)
	(let loop ((unit-pairs (SI:quotient funit tunit))
		   (flactor 1))
	  (cond ((null? unit-pairs) flactor)
		((zero? (round (* 2 (cdar unit-pairs))))
		 (loop (cdr unit-pairs) flactor))
		((number? (caar unit-pairs))
		 (loop (cdr unit-pairs)
		       ((if (negative? (cdar unit-pairs)) / *)
			flactor
			(expt (caar unit-pairs)
			      (abs (cdar unit-pairs))))))
		(else 0)))
	(+ (if tunit 0 -1) (if funit 0 -2)))))

(define SI:grammar #f)

;;;;			  The parse tables.
;;; Definitions accumulate in top-level variable *SYN-DEFS*.
;;(trace-all (in-vicinity (program-vicinity) "simetrix.scm"))

(define (list2string dyn lst) (list->string lst))
;;; Character classes
(prec:define-grammar (tok:char-group 70 #\^ list2string))
(prec:define-grammar (tok:char-group 49 #\. list2string))
(prec:define-grammar (tok:char-group 50 #\/ list2string))
(prec:define-grammar (tok:char-group 51 #\- list2string))
(prec:define-grammar (tok:char-group 40 tok:decimal-digits
		      (lambda (dyn l) (string->number (list->string l)))))
(prec:define-grammar (tok:char-group 44
		      (string-append tok:upper-case tok:lower-case "@_")
		      list2string))

(prec:define-grammar (prec:prefix '- SI:minus 130))
(prec:define-grammar (prec:infix "." SI:dot 120 120))
(prec:define-grammar (prec:infix '("e" "E") SI:e 115 125))
(prec:define-grammar (prec:infix '/ SI:solidus 100 150))
(prec:define-grammar (prec:infix '^ SI:pow 160 140))
(prec:define-grammar (prec:matchfix #\( SI:identity #f #\)))

(set! SI:grammar *syn-defs*)
