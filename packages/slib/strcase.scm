;;; "strcase.scm" String casing functions.
; Written 1992 by Dirk Lutzebaeck (lutzeb@cs.tu-berlin.de)
;
; This code is in the public domain.

; Modified by Aubrey Jaffer Nov 1992.
; SYMBOL-APPEND and StudlyCapsExpand added by A. Jaffer 2001.
; Authors of the original version were Ken Dickey and Aubrey Jaffer.

(require 'rev4-optional-procedures)	;string-copy

;string-upcase, string-downcase, string-capitalize
; are obvious string conversion procedures and are non destructive.
;string-upcase!, string-downcase!, string-capitalize!
; are destructive versions.
;@
(define (string-upcase! str)
  (do ((i (- (string-length str) 1) (- i 1)))
      ((< i 0) str)
    (string-set! str i (char-upcase (string-ref str i)))))
;@
(define (string-upcase str)
  (string-upcase! (string-copy str)))
;@
(define (string-downcase! str)
  (do ((i (- (string-length str) 1) (- i 1)))
      ((< i 0) str)
    (string-set! str i (char-downcase (string-ref str i)))))
;@
(define (string-downcase str)
  (string-downcase! (string-copy str)))
;@
(define (string-capitalize! str)	; "hello" -> "Hello"
  (let ((non-first-alpha #f)		; "hELLO" -> "Hello"
	(str-len (string-length str)))	; "*hello" -> "*Hello"
    (do ((i 0 (+ i 1)))			; "hello you" -> "Hello You"
	((= i str-len) str)
      (let ((c (string-ref str i)))
	(if (char-alphabetic? c)
	    (if non-first-alpha
		(string-set! str i (char-downcase c))
		(begin
		  (set! non-first-alpha #t)
		  (string-set! str i (char-upcase c))))
	    (set! non-first-alpha #f))))))
;@
(define (string-capitalize str)
  (string-capitalize! (string-copy str)))
;@
(define string-ci->symbol
  (let ((s2cis (if (equal? "x" (symbol->string 'x))
		   string-downcase string-upcase)))
    (lambda (str) (string->symbol (s2cis str)))))
;@
(define symbol-append
  (let ((s2cis (cond ((equal? "x" (symbol->string 'X)) string-downcase)
		     ((equal? "X" (symbol->string 'x)) string-upcase)
		     (else identity))))
    (lambda args
      (string->symbol
       (apply string-append
	      (map
	       (lambda (obj)
		 (cond ((string? obj) (s2cis obj))
		       ((number? obj) (s2cis (number->string obj)))
		       ((symbol? obj) (symbol->string obj))
		       ((not obj) "")
		       (else (slib:error 'wrong-type-to 'symbol-append obj))))
	       args))))))
;@
(define (StudlyCapsExpand nstr . delimitr)
  (set! delimitr
	(cond ((null? delimitr) "-")
	      ((char? (car delimitr)) (string (car delimitr)))
	      (else (car delimitr))))
  (do ((idx (+ -1 (string-length nstr)) (+ -1 idx)))
      ((> 1 idx) nstr)
    (cond ((and (> idx 1)
		(char-upper-case? (string-ref nstr (+ -1 idx)))
		(char-lower-case? (string-ref nstr idx)))
	   (set! nstr
		 (string-append (substring nstr 0 (+ -1 idx))
				delimitr
				(substring nstr (+ -1 idx)
					   (string-length nstr)))))
	  ((and (char-lower-case? (string-ref nstr (+ -1 idx)))
		(char-upper-case? (string-ref nstr idx)))
	   (set! nstr
		 (string-append (substring nstr 0 idx)
				delimitr
				(substring nstr idx
					   (string-length nstr))))))))
