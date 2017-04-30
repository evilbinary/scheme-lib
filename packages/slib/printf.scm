;;;; "printf.scm" Implementation of standard C functions for Scheme
;;; Copyright (C) 1991-1993, 1996, 1999-2001 Aubrey Jaffer and Radey Shouman.
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

(require 'string-case)
(require 'multiarg-apply)
(require-if 'compiling 'generic-write)

;; Determine the case of digits > 9.  We assume this to be constant.
(define stdio:hex-upper-case? (string=? "-F" (number->string -15 16)))

;; Parse the output of NUMBER->STRING and pass the results to PROC.
;; PROC takes (SIGN-CHARACTER DIGIT-STRING EXPONENT-INTEGER . IMAGPART)
;; SIGN-CHAR will be either #\+ or #\-, DIGIT-STRING will always begin
;; with a "0", after which a decimal point should be understood.
;; If STR denotes a number with imaginary part not exactly zero,
;; 3 additional elements for the imaginary part are passed.
;; If STR cannot be parsed, return #F without calling PROC.
(define (stdio:parse-float str proc)
  (let ((n (string-length str)))
    (define (parse-error) #f)
    (define (prefix i cont)
      (if (and (< i (- n 1))
	       (char=? #\# (string-ref str i)))
	  (case (string-ref str (+ i 1))
	    ((#\d #\i #\e) (prefix (+ i 2) cont))
	    ((#\.) (cont i))
	    (else (parse-error)))
	  (cont i)))
    (define (sign i cont)
      (if (< i n)
	  (let ((c (string-ref str i)))
	    (case c
	      ((#\- #\+) (cont (+ i 1) c))
	      (else (cont i #\+))))))
    (define (digits i cont)
      (do ((j i (+ j 1)))
	  ((or (>= j n)
	       (not (or (char-numeric? (string-ref str j))
			(char=? #\# (string-ref str j)))))
	   (cont j (if (= i j) "0" (substring str i j))))))
    (define (point i cont)
      (if (and (< i n)
	       (char=? #\. (string-ref str i)))
	  (cont (+ i 1))
	  (cont i)))
    (define (exp i cont)
      (cond ((>= i n) (cont i 0))
	    ((memv (string-ref str i)
		   '(#\e #\s #\f #\d #\l #\E #\S #\F #\D #\L))
	     (sign (+ i 1)
		   (lambda (i sgn)
		     (digits i
			     (lambda (i digs)
			       (cont i
				     (if (char=? #\- sgn)
					 (- (string->number digs))
					 (string->number digs))))))))
	    (else (cont i 0))))
    (define (real i cont)
      (prefix
       i
       (lambda (i)
	 (sign
	  i
	  (lambda (i sgn)
	    (digits
	     i
	     (lambda (i idigs)
	       (point
		i
		(lambda (i)
		  (digits
		   i
		   (lambda (i fdigs)
		     (exp i
			  (lambda (i ex)
			    (let* ((digs (string-append "0" idigs fdigs))
				   (ndigs (string-length digs)))
			      (let loop ((j 1)
					 (ex (+ ex (string-length idigs))))
				(cond ((>= j ndigs) ;; Zero
				       (cont i sgn "0" 1))
				      ((char=? #\0 (string-ref digs j))
				       (loop (+ j 1) (- ex 1)))
				      (else
				       (cont i sgn
					     (substring digs (- j 1) ndigs)
					     ex))))))))))))))))))
    (real 0
	  (lambda (i sgn digs ex)
	    (cond
	     ((= i n) (proc sgn digs ex))
	     ((memv (string-ref str i) '(#\+ #\-))
	      (real i
		    (lambda (j im-sgn im-digs im-ex)
		      (if (and (= j (- n 1))
			       (char-ci=? #\i (string-ref str j)))
			  (proc sgn digs ex im-sgn im-digs im-ex)
			  (parse-error)))))
	     ((eqv? (string-ref str i) #\@)
	      ;; Polar form: No point in parsing the angle ourselves,
	      ;; since some transcendental approximation is unavoidable.
	      (let ((num (string->number str)))
		(if num
		    (stdio:parse-float
		     (number->string (real-part num))
		     (lambda (sgn digs ex)
		       (stdio:parse-float
			(number->string (imag-part num))
			(lambda (im-sgn im-digs im-ex)
			  (proc sgn digs ex im-sgn im-digs im-ex)))))
		    (parse-error))))
	     (else #f))))))

;; STR is a digit string representing a floating point mantissa, STR must
;; begin with "0", after which a decimal point is understood.
;; The output is a digit string rounded to NDIGS digits after the decimal
;; point implied between chars 0 and 1.
;; If STRIP-0S is not #F then trailing zeros will be stripped from the result.
;; In this case, STRIP-0S should be the minimum number of digits required
;; after the implied decimal point.
(define (stdio:round-string str ndigs strip-0s)
  (let* ((n (- (string-length str) 1))
	 (res
	  (cond ((< ndigs 0) "")
		((= n ndigs) str)
		((< n ndigs)
		 (let ((padlen (max 0 (- (or strip-0s ndigs) n))))
		   (if (zero? padlen)
		       str
		       (string-append str
				      (make-string padlen
						   (if (char-numeric?
							(string-ref str n))
						       #\0 #\#))))))
		(else
		 (let ((res (substring str 0 (+ ndigs 1)))
		       (dig (lambda (i)
			      (let ((c (string-ref str i)))
				(if (char-numeric? c)
				    (string->number (string c))
				    0)))))
		   (let ((ldig (dig (+ 1 ndigs))))
		     (if (or (> ldig 5)
			     (and (= ldig 5)
				  (let loop ((i (+ 2 ndigs)))
				    (if (> i n)
					(odd? (dig ndigs))
					(if (zero? (dig i))
					    (loop (+ i 1))
					    #t)))))
			 (let inc! ((i ndigs))
			   (let ((d (dig i)))
			     (if (< d 9)
				 (string-set! res i
					      (string-ref
					       (number->string (+ d 1)) 0))
				 (begin
				   (string-set! res i #\0)
				   (inc! (- i 1))))))))
		   res)))))
    (if strip-0s
	(let loop ((i (- (string-length res) 1)))
	  (if (or (<= i strip-0s)
		  (not (char=? #\0 (string-ref res i))))
	      (substring res 0 (+ i 1))
	      (loop (- i 1))))
	res)))

(define (stdio:iprintf out format-string . args)
  (cond
   ((not (equal? "" format-string))
    (let ((pos -1)
	  (fl (string-length format-string))
	  (fc (string-ref format-string 0)))

      (define (advance)
	(set! pos (+ 1 pos))
	(cond ((>= pos fl) (set! fc #f))
	      (else (set! fc (string-ref format-string pos)))))
      (define (must-advance)
	(set! pos (+ 1 pos))
	(cond ((>= pos fl) (incomplete))
	      (else (set! fc (string-ref format-string pos)))))
      (define (end-of-format?)
	(>= pos fl))
      (define (incomplete)
	(slib:error 'printf "conversion specification incomplete"
		    format-string))
      (define (wna)
	(slib:error 'printf "wrong number of arguments"
		    (length args)
		    format-string))
      (define (out* strs)
	(if (string? strs) (out strs)
	    (let out-loop ((strs strs))
	      (or (null? strs)
		  (and (out (car strs))
		       (out-loop (cdr strs)))))))

      (let loop ((args args))
	(advance)
	(cond
	 ((end-of-format?)
	  ;;(or (null? args) (wna))	;Extra arguments are *not* a bug.
	  )
	 ((eqv? #\\ fc);;Emulating C strings may not be a good idea.
	  (must-advance)
	  (and (case fc
		 ((#\n #\N) (out #\newline))
		 ((#\t #\T) (out slib:tab))
		 ;;((#\r #\R) (out #\return))
		 ((#\f #\F) (out slib:form-feed))
		 ((#\newline) #t)
		 (else (out fc)))
	       (loop args)))
	 ((eqv? #\% fc)
	  (must-advance)
	  (let ((left-adjust #f)	;-
		(signed #f)		;+
		(blank #f)
		(alternate-form #f)	;#
		(leading-0s #f)		;0
		(width 0)
		(precision -1)
		(type-modifier #f)
		(read-format-number
		 (lambda ()
		   (cond
		    ((eqv? #\* fc)	; GNU extension
		     (must-advance)
		     (let ((ans (car args)))
		       (set! args (cdr args))
		       ans))
		    (else
		     (do ((c fc fc)
			  (accum 0 (+ (* accum 10)
				      (string->number (string c)))))
			 ((not (char-numeric? fc)) accum)
		       (must-advance)))))))
	    (define (pad pre . strs)
	      (let loop ((len (string-length pre))
			 (ss strs))
		(cond ((>= len width) (cons pre strs))
		      ((null? ss)
		       (cond (left-adjust
			      (cons pre
				    (append strs
					    (list (make-string
						   (- width len) #\space)))))
			     (leading-0s
			      (cons pre
				    (cons (make-string (- width len) #\0)
					  strs)))
			     (else
			      (cons (make-string (- width len) #\space)
				    (cons pre strs)))))
		      (else
		       (loop (+ len (string-length (car ss))) (cdr ss))))))
	    (define integer-convert
	      (lambda (s radix fixcase)
		(cond ((not (negative? precision))
		       (set! leading-0s #f)
		       (if (and (zero? precision)
				(eqv? 0 s))
			   (set! s ""))))
		(set! s (cond ((symbol? s) (symbol->string s))
			      ((number? s) (number->string s radix))
			      ((or (not s) (null? s)) "0")
			      ((string? s) s)
			      (else "1")))
		(if fixcase (set! s (fixcase s)))
		(let ((pre (cond ((equal? "" s) "")
				 ((eqv? #\- (string-ref s 0))
				  (set! s (substring s 1 (string-length s)))
				  "-")
				 (signed "+")
				 (blank " ")
				 (alternate-form
				  (case radix
				    ((8) "0")
				    ((16) "0x")
				    (else "")))
				 (else ""))))
		  (pad pre
		       (if (< (string-length s) precision)
			   (make-string
			    (- precision (string-length s)) #\0)
			   "")
		       s))))
	    (define (float-convert num fc)
	      (define (f digs exp strip-0s)
		(let ((digs (stdio:round-string
			     digs (+ exp precision) (and strip-0s exp))))
		  (cond ((>= exp 0)
			 (let* ((i0 (cond ((zero? exp) 0)
					  ((char=? #\0 (string-ref digs 0)) 1)
					  (else 0)))
				(i1 (max 1 (+ 1 exp)))
				(idigs (substring digs i0 i1))
				(fdigs (substring digs i1
						  (string-length digs))))
			   (cons idigs
				 (if (and (string=? fdigs "")
					  (not alternate-form))
				     '()
				     (list "." fdigs)))))
			((zero? precision)
			 (list (if alternate-form "0." "0")))
			((and strip-0s (string=? digs "") (list "0")))
			(else
			 (list "0."
			       (make-string (min precision (- -1 exp)) #\0)
			       digs)))))
	      (define (e digs exp strip-0s)
		(let* ((digs (stdio:round-string
			      digs (+ 1 precision) (and strip-0s 0)))
		       (istrt (if (char=? #\0 (string-ref digs 0)) 1 0))
		       (fdigs (substring
			       digs (+ 1 istrt) (string-length digs)))
		       (exp (if (zero? istrt) exp (- exp 1))))
		  (list
		   (substring digs istrt (+ 1 istrt))
		   (if (and (string=? fdigs "") (not alternate-form))
		       "" ".")
		   fdigs
		   (if (char-upper-case? fc) "E" "e")
		   (if (negative? exp) "-" "+")
		   (if (< -10 exp 10) "0" "")
		   (number->string (abs exp)))))
	      (define (g digs exp)
		(let ((strip-0s (not alternate-form)))
		  (set! alternate-form #f)
		  (cond ((<= (- 1 precision) exp precision)
			 (set! precision (- precision exp))
			 (f digs exp strip-0s))
			(else
			 (set! precision (- precision 1))
			 (e digs exp strip-0s)))))
	      (define (k digs exp sep)
		(let* ((units '#("y" "z" "a" "f" "p" "n" "u" "m" ""
				 "k" "M" "G" "T" "P" "E" "Z" "Y"))
		       (base 8)		;index of ""
		       (uind (let ((i (if (negative? exp)
					  (quotient (- exp 3) 3)
					  (quotient (- exp 1) 3))))
			       (and
				(< -1 (+ i base) (vector-length units))
				i))))
		  (cond (uind
			 (set! exp (- exp (* 3 uind)))
			 (set! precision (max 0 (- precision exp)))
			 (append
			  (f digs exp #f)
			  (list sep
				(vector-ref units (+ uind base)))))
			(else
			 (g digs exp)))))

	      (cond ((negative? precision)
		     (set! precision 6))
		    ((and (zero? precision)
			  (char-ci=? fc #\g))
		     (set! precision 1)))
	      (let* ((str
		      (cond ((number? num)
			     (number->string (exact->inexact num)))
			    ((string? num) num)
			    ((symbol? num) (symbol->string num))
			    (else "???"))))
		(define (format-real signed? sgn digs exp . rest)
		  (if (null? rest)
		      (cons
		       (if (char=? #\- sgn) "-"
			   (if signed? "+" (if blank " " "")))
		       (case fc
			 ((#\e #\E) (e digs exp #f))
			 ((#\f #\F) (f digs exp #f))
			 ((#\g #\G) (g digs exp))
			 ((#\k) (k digs exp ""))
			 ((#\K) (k digs exp "."))))
		      (append (format-real signed? sgn digs exp)
			      (apply format-real #t rest)
			      '("i"))))
		(or (stdio:parse-float str
				    (lambda (sgn digs expon . imag)
				      (apply pad
					     (apply format-real
						    signed
						    sgn digs expon imag))))
		    (pad "???"))))
	    (do ()
		((case fc
		   ((#\-) (set! left-adjust #t) #f)
		   ((#\+) (set! signed #t) #f)
		   ((#\space) (set! blank #t) #f)
		   ((#\#) (set! alternate-form #t) #f)
		   ((#\0) (set! leading-0s #t) #f)
		   (else #t)))
	      (must-advance))
	    (cond (left-adjust (set! leading-0s #f)))
	    (cond (signed (set! blank #f)))

	    (set! width (read-format-number))
	    (cond ((negative? width)
		   (set! left-adjust #t)
		   (set! width (- width))))
	    (cond ((eqv? #\. fc)
		   (must-advance)
		   (set! precision (read-format-number))))
	    (case fc			;Ignore these specifiers
	      ((#\l #\L #\h)
	       (set! type-modifier fc)
	       (must-advance)))

	    ;;At this point fc completely determines the format to use.
	    (if (null? args)
		(if (memv (char-downcase fc)
			  '(#\c #\s #\a #\d #\i #\u #\o #\x #\b
			    #\f #\e #\g #\k))
		    (wna)))

	    (case fc
		;; only - is allowed between % and c
	      ((#\c #\C)		; C is enhancement
	       (and (out (string (car args))) (loop (cdr args))))

	      ;; only - flag, no type-modifiers
	      ((#\s #\S)		; S is enhancement
	       (let ((s (cond
			 ((symbol? (car args)) (symbol->string (car args)))
			 ((not (car args)) "(NULL)")
			 (else (car args)))))
		 (cond ((not (or (negative? precision)
				 (>= precision (string-length s))))
			(set! s (substring s 0 precision))))
		 (and
		  (out* (cond
			 ((<= width (string-length s)) s)
			 (left-adjust
			  (list
			   s (make-string (- width (string-length s)) #\space)))
			 (else
			  (list
			   (make-string (- width (string-length s))
					(if leading-0s #\0 #\space))
			   s))))
		  (loop (cdr args)))))

		;; SLIB extension
	      ((#\a #\A)		;#\a #\A are pretty-print
	       (let ((os "") (pr precision))
		 (require 'generic-write)
		 (generic-write
		  (car args) (not alternate-form) #f
		  (cond ((and left-adjust (negative? pr))
			 (set! pr 0)
			 (lambda (s)
			   (set! pr (+ pr (string-length s)))
			   (out s)))
			(left-adjust
			 (lambda (s)
			   (define sl (- pr (string-length s)))
			   (set! pr (cond ((negative? sl)
					   (out (substring s 0 pr)) 0)
					  (else (out s) sl)))
			   (positive? sl)))
			((negative? pr)
			 (set! pr width)
			 (lambda (s)
			   (set! pr (- pr (string-length s)))
			   (cond ((not os) (out s))
				 ((negative? pr)
				  (out os)
				  (set! os #f)
				  (out s))
				 (else (set! os (string-append os s))))
			   #t))
			(else
			 (lambda (s)
			   (define sl (- pr (string-length s)))
			   (cond ((negative? sl)
				  (set! os (string-append
					    os (substring s 0 pr))))
				 (else (set! os (string-append os s))))
			   (set! pr sl)
			   (positive? sl)))))
		 (cond ((and left-adjust (negative? precision))
			(cond
			 ((> width pr) (out (make-string (- width pr) #\space)))))
		       (left-adjust
			(cond
			 ((> width (- precision pr))
			  (out (make-string (- width (- precision pr)) #\space)))))
		       ((not os))
		       ((<= width (string-length os)) (out os))
		       (else (and (out (make-string
					(- width (string-length os)) #\space))
				  (out os)))))
	       (loop (cdr args)))
	      ((#\d #\D #\i #\I #\u #\U)
	       (and (out* (integer-convert (car args) 10 #f))
		    (loop (cdr args))))
	      ((#\o #\O)
	       (and (out* (integer-convert (car args) 8 #f))
		    (loop (cdr args))))
	      ((#\x)
	       (and (out* (integer-convert
			   (car args) 16
			   (if stdio:hex-upper-case? string-downcase #f)))
		    (loop (cdr args))))
	       ((#\X)
	       (and (out* (integer-convert
			   (car args) 16
			   (if stdio:hex-upper-case? #f string-upcase)))
		    (loop (cdr args))))
	      ((#\b #\B)
	       (and (out* (integer-convert (car args) 2 #f))
		    (loop (cdr args))))
	      ((#\%) (and (out #\%) (loop args)))
	      ((#\f #\F #\e #\E #\g #\G #\k #\K)
	       (and (out* (float-convert (car args) fc)) (loop (cdr args))))
	      (else
	       (cond
		((end-of-format?) (incomplete))
		(else (and (out #\%) (out fc) (out #\?) (loop args))))))))
	 (else (and (out fc) (loop args)))))))))
;@
(define (fprintf port format . args)
  (let ((cnt 0))
    (apply stdio:iprintf
	   (lambda (x)
	     (cond ((string? x)
		    (set! cnt (+ (string-length x) cnt)) (display x port) #t)
		   (else (set! cnt (+ 1 cnt)) (display x port) #t)))
	   format args)
    cnt))
;@
(define (printf format . args)
  (apply stdio:fprintf (current-output-port) format args))
;@
(define (sprintf str format . args)
  (let* ((cnt 0)
	 (s (cond ((string? str) str)
		  ((number? str) (make-string str))
		  ((not str) (make-string 100))
		  (else (slib:error 'sprintf "first argument not understood"
				    str))))
	 (end (string-length s)))
    (apply stdio:iprintf
	   (lambda (x)
	     (cond ((string? x)
		    (if (or str (>= (- end cnt) (string-length x)))
			(do ((lend (min (string-length x) (- end cnt)))
			     (i 0 (+ i 1)))
			    ((>= i lend))
			  (string-set! s cnt (string-ref x i))
			  (set! cnt (+ cnt 1)))
			(let ()
			  (set! s (string-append (substring s 0 cnt) x))
			  (set! cnt (string-length s))
			  (set! end cnt))))
		   ((and str (>= cnt end)))
		   (else (cond ((and (not str) (>= cnt end))
				(set! s (string-append s (make-string 100)))
				(set! end (string-length s))))
			 (string-set! s cnt (if (char? x) x #\?))
			 (set! cnt (+ cnt 1))))
	     (not (and str (>= cnt end))))
	   format
	   args)
    (cond ((string? str) cnt)
	  ((eqv? end cnt) s)
	  (else (substring s 0 cnt)))))

(define stdio:fprintf fprintf)

;;(do ((i 0 (+ 1 i))) ((> i 50)) (printf "%s\\n" (sprintf i "%#-13a:%#13a:%-13.8a:" "123456789" "123456789" "123456789")))
