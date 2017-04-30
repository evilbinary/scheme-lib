;;; "strsrch.scm" Search for string from port.
; Written 1995, 1996 by Oleg Kiselyov (oleg@acm.org)
; Modified 1996, 1997, 1998, 2001 by A. Jaffer (agj@alum.mit.edu)
; Modified 2003 by Steve VanDevender (stevev@hexadecimal.uoregon.edu)
; 2013-01 A. Jaffer replaced the skip-vector with an alist

; This code is in the public domain.

(require 'multiarg-apply)		; used in string-subst
(require 'alist)

;;;@ Return the index of the first occurence of chr in str, or #f
(define (string-index str chr)
  (define len (string-length str))
  (do ((pos 0 (+ 1 pos)))
      ((or (>= pos len) (char=? chr (string-ref str pos)))
       (and (< pos len) pos))))
;@
(define (string-index-ci str chr)
  (define len (string-length str))
  (do ((pos 0 (+ 1 pos)))
      ((or (>= pos len) (char-ci=? chr (string-ref str pos)))
       (and (< pos len) pos))))
;@
(define (string-reverse-index str chr)
  (do ((pos (+ -1 (string-length str)) (+ -1 pos)))
      ((or (negative? pos) (char=? (string-ref str pos) chr))
       (and (not (negative? pos)) pos))))
;@
(define (string-reverse-index-ci str chr)
  (do ((pos (+ -1 (string-length str)) (+ -1 pos)))
      ((or (negative? pos) (char-ci=? (string-ref str pos) chr))
       (and (not (negative? pos)) pos))))
;@
(define (substring? pat str)
  (define patlen (string-length pat))
  (define strlen (string-length str))
  (cond ((zero? patlen) 0)		; trivial match
	((>= patlen strlen) (and (= patlen strlen) (string=? pat str) 0))
	;; use faster string-index to match a single-character pattern
	((= 1 patlen) (string-index str (string-ref pat 0)))
	((or (<= strlen (* 2 patlen))
	     (<= patlen 2))
	 (subloop pat patlen str strlen char=?))
	(else
	 ;; compute skip values for search pattern characters
	 ;; for all c not in pat, skip[c] = patlen + 1
	 ;; for c in pat, skip[c] is distance of rightmost occurrence
	 ;;  of c from end of str
	 (let ((skip '()))
	   (define setprop (alist-associator char=?))
	   (do ((i 0 (+ i 1)))
	       ((= i patlen))
	     (set! skip (setprop skip (string-ref pat i) (- patlen i))))
	   (subskip skip pat patlen str strlen char=?)))))
;@
(define (substring-ci? pat str)
  (define patlen (string-length pat))
  (define strlen (string-length str))
  (cond ((zero? patlen) 0)		; trivial match
	((>= patlen strlen) (and (= patlen strlen) (string-ci=? pat str) 0))
	((= 1 patlen) (string-index-ci str (string-ref pat 0)))
	((or (<= strlen (* 2 patlen))
	     (<= patlen 2))
	 (subloop pat patlen str strlen char-ci=?))
	(else
	 (let ((skip '()))
	   (define setprop (alist-associator char-ci=?))
	   (do ((i 0 (+ i 1)))
	       ((= i patlen))
	     (set! skip (setprop skip (string-ref pat i) (- patlen i))))
	   (subskip skip pat patlen str strlen char-ci=?)))))

(define (subskip skip pat patlen str strlen char=)
  (define getprop (alist-inquirer char=?))
  (do ((k patlen (if (< k strlen)
		     (+ k (or (getprop skip (string-ref str k)) (+ patlen 1)))
		     (+ strlen 1))))
      ((or (> k strlen)
	   (do ((i 0 (+ i 1))
		(j (- k patlen) (+ j 1)))
	       ((or (= i patlen)
		    (not (char= (string-ref pat i) (string-ref str j))))
		(= i patlen))))
       (and (<= k strlen) (- k patlen)))))

;;; Assumes that PATLEN > 1
(define (subloop pat patlen str strlen char=)
  (define span (- strlen patlen))
  (define c1 (string-ref pat 0))
  (define c2 (string-ref pat 1))
  (let outer ((pos 0))
    (cond
     ((> pos span) #f)		; nothing was found thru the whole str
     ((not (char= c1 (string-ref str pos)))
      (outer (+ 1 pos)))	; keep looking for the right beginning
     ((not (char= c2 (string-ref str (+ 1 pos))))
      (outer (+ 1 pos)))	 ; could've done pos+2 if c1 == c2....
     (else			  ; two char matched: high probability
					; the rest will match too
      (let inner ((pdx 2) (sdx (+ 2 pos)))
	(if (>= pdx patlen) pos	; the whole pat matched
	    (if (char= (string-ref pat pdx)
		       (string-ref str sdx))
		(inner (+ 1 pdx) (+ 1 sdx))
		;; mismatch after partial match
		(outer (+ 1 pos)))))))))
;@
(define (find-string-from-port? str <input-port> . max-no-char)
  (set! max-no-char (if (null? max-no-char) #f (car max-no-char)))
  (letrec
      ((no-chars-read 0)
       (peeked? #f)
       (my-peek-char			; Return a peeked char or #f
	(lambda () (and (or (not (number? max-no-char))
			    (< no-chars-read max-no-char))
			(let ((c (peek-char <input-port>)))
			  (cond (peeked? c)
				((eof-object? c) #f)
				((procedure? max-no-char)
				 (set! peeked? #t)
				 (if (max-no-char c) #f c))
				((eqv? max-no-char c) #f)
				(else c))))))
       (next-char (lambda () (set! peeked? #f) (read-char <input-port>)
			  (set! no-chars-read  (+ 1 no-chars-read))))
       (match-1st-char			; of the string str
	(lambda ()
	  (let ((c (my-peek-char)))
	    (and c
		 (begin (next-char)
			(if (char=? c (string-ref str 0))
			    (match-other-chars 1)
			    (match-1st-char)))))))
       ;; There has been a partial match, up to the point pos-to-match
       ;; (for example, str[0] has been found in the stream)
       ;; Now look to see if str[pos-to-match] for would be found, too
       (match-other-chars
	(lambda (pos-to-match)
	  (if (>= pos-to-match (string-length str))
	      no-chars-read	       ; the entire string has matched
	      (let ((c (my-peek-char)))
		(and c
		     (if (not (char=? c (string-ref str pos-to-match)))
			 (backtrack 1 pos-to-match)
			 (begin (next-char)
				(match-other-chars (+ 1 pos-to-match)))))))))

       ;; There had been a partial match, but then a wrong char showed up.
       ;; Before discarding previously read (and matched) characters, we check
       ;; to see if there was some smaller partial match. Note, characters read
       ;; so far (which matter) are those of str[0..matched-substr-len - 1]
       ;; In other words, we will check to see if there is such i>0 that
       ;; substr(str,0,j) = substr(str,i,matched-substr-len)
       ;; where j=matched-substr-len - i
       (backtrack
	(lambda (i matched-substr-len)
	  (let ((j (- matched-substr-len i)))
	    (if (<= j 0)
		;; backed off completely to the begining of str
		(match-1st-char)
		(let loop ((k 0))
		  (if (>= k j)
		      (match-other-chars j) ; there was indeed a shorter match
		      (if (char=? (string-ref str k)
				  (string-ref str (+ i k)))
			  (loop (+ 1 k))
			  (backtrack (+ 1 i) matched-substr-len))))))))
       )
    (match-1st-char)))
;@
(define (string-subst text old new . rest)
  (define sub
    (lambda (text)
      (set! text
	    (cond ((equal? "" text) text)
		  ((substring? old text)
		   => (lambda (idx)
			(string-append
			 (substring text 0 idx)
			 new
			 (sub (substring
			       text (+ idx (string-length old))
			       (string-length text))))))
		  (else text)))
      (if (null? rest)
	  text
	  (apply string-subst text rest))))
  (sub text))
;@
(define (count-newlines str)
  (do ((idx (+ -1 (string-length str)) (+ -1 idx))
       (cnt 0 (+ (if (eqv? #\newline (string-ref str idx)) 1 0) cnt)))
      ((<= idx 0) cnt)))
