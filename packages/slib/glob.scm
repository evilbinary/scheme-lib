;;; "glob.scm" String matching for filenames (a la BASH).
;;; Copyright (C) 1998 Radey Shouman.
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

;;@code{(require 'filename)}
;;@ftindex filename
;;@ftindex glob

(define (glob:pattern->tokens pat)
  (cond
   ((string? pat)
    (let loop ((i 0)
	       (toks '()))
      (if (>= i (string-length pat))
	  (reverse toks)
	  (let ((pch (string-ref pat i)))
	    (case pch
	      ((#\? #\*)
	       (loop (+ i 1)
		     (cons (substring pat i (+ i 1)) toks)))
	      ((#\[)
	       (let ((j
		      (let search ((j (+ i 2)))
			(cond
			 ((>= j (string-length pat))
			  (slib:error 'glob:make-matcher
				      "unmatched [" pat))
			 ((char=? #\] (string-ref pat j))
			  (if (and (< (+ j 1) (string-length pat))
				   (char=? #\] (string-ref pat (+ j 1))))
			      (+ j 1)
			      j))
			 (else (search (+ j 1)))))))
		 (loop (+ j 1) (cons (substring pat i (+ j 1)) toks))))
	      (else
	       (let search ((j (+ i 1)))
		 (cond ((= j (string-length pat))
			(loop j (cons (substring pat i j) toks)))
		       ((memv (string-ref pat j) '(#\? #\* #\[))
			(loop j (cons (substring pat i j) toks)))
		       (else (search (+ j 1)))))))))))
   ((pair? pat)
    (for-each (lambda (elt) (or (string? elt)
				(slib:error 'glob:pattern->tokens
					    "bad pattern" pat)))
	      pat)
    pat)
   (else (slib:error 'glob:pattern->tokens "bad pattern" pat))))

(define (glob:make-matcher pat ch=? ch<=?)
  (define (match-end str k kmatch)
    (and (= k (string-length str)) (reverse (cons k kmatch))))
  (define (match-str pstr nxt)
    (let ((plen (string-length pstr)))
      (lambda (str k kmatch)
	(and (<= (+ k plen) (string-length str))
	     (let loop ((i 0))
	       (cond ((= i plen)
		      (nxt str (+ k plen) (cons k kmatch)))
		     ((ch=? (string-ref pstr i)
			    (string-ref str (+ k i)))
		      (loop (+ i 1)))
		     (else #f)))))))
  (define (match-? nxt)
    (lambda (str k kmatch)
      (and (< k (string-length str))
	   (nxt str (+ k 1) (cons k kmatch)))))
  (define (match-set1 chrs)
    (let recur ((i 0))
      (cond ((= i (string-length chrs))
	     (lambda (ch) #f))
	    ((and (< (+ i 2) (string-length chrs))
		  (char=? #\- (string-ref chrs (+ i 1))))
	     (let ((nxt (recur (+ i 3))))
	       (lambda (ch)
		 (or (and (ch<=? ch (string-ref chrs (+ i 2)))
			  (ch<=? (string-ref chrs i) ch))
		     (nxt ch)))))
	    (else
	     (let ((nxt (recur (+ i 1)))
		   (chrsi (string-ref chrs i)))
	       (lambda (ch)
		 (or (ch=? chrsi ch) (nxt ch))))))))
  (define (match-set tok nxt)
    (let ((chrs (substring tok 1 (- (string-length tok) 1))))
      (if (and (positive? (string-length chrs))
	       (memv (string-ref chrs 0) '(#\^ #\!)))
	  (let ((pred (match-set1 (substring chrs 1 (string-length chrs)))))
	    (lambda (str k kmatch)
	      (and (< k (string-length str))
		   (not (pred (string-ref str k)))
		   (nxt str (+ k 1) (cons k kmatch)))))
	  (let ((pred (match-set1 chrs)))
	    (lambda (str k kmatch)
	      (and (< k (string-length str))
		   (pred (string-ref str k))
		   (nxt str (+ k 1) (cons k kmatch))))))))
  (define (match-* nxt)
    (lambda (str k kmatch)
      (let ((kmatch (cons k kmatch)))
	(let loop ((kk (string-length str)))
	  (and (>= kk k)
	       (or (nxt str kk kmatch)
		   (loop (- kk 1))))))))

  (let ((matcher
	 (let recur ((toks (glob:pattern->tokens pat)))
	   (if (null? toks)
	       match-end
	       (let ((pch (or (string=? (car toks) "")
			      (string-ref (car toks) 0))))
		 (case pch
		   ((#\?) (match-? (recur (cdr toks))))
		   ((#\*) (match-* (recur (cdr toks))))
		   ((#\[) (match-set (car toks) (recur (cdr toks))))
		   (else (match-str (car toks) (recur (cdr toks))))))))))
    (lambda (str) (matcher str 0 '()))))

(define (glob:caller-with-matches pat proc ch=? ch<=?)
  (define (glob:wildcard? pat)
    (cond ((string=? pat "") #f)
	  ((memv (string-ref pat 0) '(#\* #\? #\[)) #t)
	  (else #f)))
  (let* ((toks (glob:pattern->tokens pat))
	 (wild? (map glob:wildcard? toks))
	 (matcher (glob:make-matcher toks ch=? ch<=?)))
    (lambda (str)
      (let loop ((inds (matcher str))
		 (wild? wild?)
		 (res '()))
	(cond ((not inds) #f)
	      ((null? wild?)
	       (apply proc (reverse res)))
	      ((car wild?)
	       (loop (cdr inds)
		     (cdr wild?)
		     (cons (substring str (car inds) (cadr inds)) res)))
	      (else
	       (loop (cdr inds) (cdr wild?) res)))))))

(define (glob:make-substituter pattern template ch=? ch<=?)
  (define (wildcard? pat)
    (cond ((string=? pat "") #f)
	  ((memv (string-ref pat 0) '(#\* #\? #\[)) #t)
	  (else #f)))
  (define (countq val lst)
    (do ((lst lst (cdr lst))
	 (c 0 (if (eq? val (car lst)) (+ c 1) c)))
	((null? lst) c)))
  (let ((tmpl-literals (map (lambda (tok)
			      (if (wildcard? tok) #f tok))
			    (glob:pattern->tokens template)))
	(pat-wild? (map wildcard? (glob:pattern->tokens pattern)))
	(matcher (glob:make-matcher pattern ch=? ch<=?)))
    (or (= (countq #t pat-wild?) (countq #f tmpl-literals))
	(slib:error 'glob:make-substituter
		    "number of wildcards doesn't match" pattern template))
    (lambda (str)
      (let ((indices (matcher str)))
	(and indices
	     (let loop ((inds indices)
			(wild? pat-wild?)
			(lits tmpl-literals)
			(res '()))
	       (cond
		((null? lits)
		 (apply string-append (reverse res)))
		((car lits)
		 (loop inds wild? (cdr lits) (cons (car lits) res)))
		((null? wild?)		;this should never happen.
		 (loop '() '() lits res))
		((car wild?)
		 (loop (cdr inds) (cdr wild?) (cdr lits)
		       (cons (substring str (car inds) (cadr inds))
			     res)))
		(else
		 (loop (cdr inds) (cdr wild?) lits res)))))))))

;;@body
;;Returns a predicate which returns a non-false value if its string argument
;;matches (the string) @var{pattern}, false otherwise.  Filename matching
;;is like
;;@cindex glob
;;@dfn{glob} expansion described the bash manpage, except that names
;;beginning with @samp{.} are matched and @samp{/} characters are not
;;treated specially.
;;
;;These functions interpret the following characters specially in
;;@var{pattern} strings:
;;@table @samp
;;@item *
;;Matches any string, including the null string.
;;@item ?
;;Matches any single character.
;;@item [@dots{}]
;;Matches any one of the enclosed characters.  A pair of characters
;;separated by a minus sign (-) denotes a range; any character lexically
;;between those two characters, inclusive, is matched.  If the first
;;character following the @samp{[} is a @samp{!} or a @samp{^} then any
;;character not enclosed is matched.  A @samp{-} or @samp{]} may be
;;matched by including it as the first or last character in the set.
;;@end table
(define (filename:match?? pattern)
  (glob:make-matcher pattern char=? char<=?))
(define (filename:match-ci?? pattern)
  (glob:make-matcher pattern char-ci=? char-ci<=?))


;;@args pattern template
;;Returns a function transforming a single string argument according to
;;glob patterns @var{pattern} and @var{template}.  @var{pattern} and
;;@var{template} must have the same number of wildcard specifications,
;;which need not be identical.  @var{pattern} and @var{template} may have
;;a different number of literal sections. If an argument to the function
;;matches @var{pattern} in the sense of @code{filename:match??} then it
;;returns a copy of @var{template} in which each wildcard specification is
;;replaced by the part of the argument matched by the corresponding
;;wildcard specification in @var{pattern}.  A @code{*} wildcard matches
;;the longest leftmost string possible.  If the argument does not match
;;@var{pattern} then false is returned.
;;
;;@var{template} may be a function accepting the same number of string
;;arguments as there are wildcard specifications in @var{pattern}.  In
;;the case of a match the result of applying @var{template} to a list
;;of the substrings matched by wildcard specifications will be returned,
;;otherwise @var{template} will not be called and @code{#f} will be returned.
(define (filename:substitute?? pattern template)
  (cond ((procedure? template)
	 (glob:caller-with-matches pattern template char=? char<=?))
	((string? template)
	 (glob:make-substituter pattern template char=? char<=?))
	(else
	 (slib:error 'filename:substitute?? "bad second argument" template))))
(define (filename:substitute-ci?? pattern template)
  (cond ((procedure? template)
	 (glob:caller-with-matches pattern template char-ci=? char-ci<=?))
	((string? template)
	 (glob:make-substituter pattern template char-ci=? char-ci<=?))
	(else
	 (slib:error 'filename:substitute-ci?? "bad second argument" template))))

;;@example
;;((filename:substitute?? "scm_[0-9]*.html" "scm5c4_??.htm")
;; "scm_10.html")
;;@result{} "scm5c4_10.htm"
;;((filename:substitute?? "??" "beg?mid?end") "AZ")
;;@result{} "begAmidZend"
;;((filename:substitute?? "*na*" "?NA?") "banana")
;;@result{} "banaNA"
;;((filename:substitute?? "?*?" (lambda (s1 s2 s3) (string-append s3 s1)))
;; "ABZ")
;;@result{} "ZA"
;;@end example

;;@body
;;@var{str} can be a string or a list of strings.  Returns a new string
;;(or strings) similar to @code{str} but with the suffix string @var{old}
;;removed and the suffix string @var{new} appended.  If the end of
;;@var{str} does not match @var{old}, an error is signaled.
(define (replace-suffix str old new)
  (let* ((f (glob:make-substituter (list "*" old) (list "*" new)
				   char=? char<=?))
	 (g (lambda (st)
	      (or (f st)
		  (slib:error 'replace-suffix "suffix doesn't match:"
			      old st)))))
    (if (pair? str)
	(map g str)
	(g str))))

;;@example
;;(replace-suffix "/usr/local/lib/slib/batch.scm" ".scm" ".c")
;;@result{} "/usr/local/lib/slib/batch.c"
;;@end example

;;@args proc k
;;@args proc
;;Calls @1 with @2 arguments, strings returned by successive calls to
;;@code{tmpnam}.
;;If @1 returns, then any files named by the arguments to @1 are
;;deleted automatically and the value(s) yielded by the @1 is(are)
;;returned.  @2 may be ommited, in which case it defaults to @code{1}.
;;
;;@args proc suffix1 ...
;;Calls @1 with strings returned by successive calls to @code{tmpnam},
;;each with the corresponding @var{suffix} string appended.
;;If @1 returns, then any files named by the arguments to @1 are
;;deleted automatically and the value(s) yielded by the @1 is(are)
;;returned.
(define (call-with-tmpnam proc . suffi)
  (define (do-call paths)
    (let ((ans (apply proc paths)))
      (for-each (lambda (path) (if (file-exists? path) (delete-file path)))
		paths)
      ans))
  (cond ((null? suffi) (do-call (list (tmpnam))))
	((and (= 1 (length suffi)) (number? (car suffi)))
	 (do ((cnt (if (null? suffi) 0 (+ -1 (car suffi))) (+ -1 cnt))
	      (paths '() (cons (tmpnam) paths)))
	     ((negative? cnt)
	      (do-call paths))))
	(else (do-call (map (lambda (suffix) (string-append (tmpnam) suffix))
			    suffi)))))
