;;;; HTML scan calls procedures for word, tag, whitespac, and newline.
;;; Copyright 2002 Aubrey Jaffer
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

(require 'line-i/o)
(require 'string-port)
(require 'scanf)
(require-if 'compiling 'string-case)

;;@code{(require 'html-for-each)}
;;@ftindex html-for-each

;;@body
;;@1 is an input port or a string naming an existing file containing
;;HTML text.
;;@2 is a procedure of one argument or #f.
;;@3 is a procedure of one argument or #f.
;;@4 is a procedure of one argument or #f.
;;@5 is a procedure of no arguments or #f.
;;
;;@0 opens and reads characters from port @1 or the file named by
;;string @1.  Sequential groups of characters are assembled into
;;strings which are either
;;
;;@itemize @bullet
;;@item
;;enclosed by @samp{<} and @samp{>} (hypertext markups or comments);
;;@item
;;end-of-line;
;;@item
;;whitespace; or
;;@item
;;none of the above (words).
;;@end itemize
;;
;;Procedures are called according to these distinctions in order of
;;the string's occurrence in @1.
;;
;;@5 is called with no arguments for end-of-line @emph{not within a
;;markup or comment}.
;;
;;@4 is called with strings of non-newline whitespace.
;;
;;@3 is called with hypertext markup strings (including @samp{<} and
;;@samp{>}).
;;
;;@2 is called with the remaining strings.
;;
;;@0 returns an unspecified value.
(define (html-for-each file word-proc markup-proc white-proc newline-proc)
  (define nl (string #\newline))
  (define (string-index str . chrs)
    (define len (string-length str))
    (do ((pos 0 (+ 1 pos)))
	((or (>= pos len) (memv (string-ref str pos) chrs))
	 (and (< pos len) pos))))
  (define (proc-words line edx)
    (let loop ((idx 0))
      (define ldx idx)
      (do ((idx idx (+ 1 idx)))
	  ((or (>= idx edx)
	       (not (char-whitespace? (string-ref line idx))))
	   (do ((jdx idx (+ 1 jdx)))
	       ((or (>= jdx edx)
		    (char-whitespace? (string-ref line jdx)))
		(and white-proc (not (= ldx idx))
		     (white-proc (substring line ldx idx)))
		(and word-proc (not (= idx jdx))
		     (word-proc (substring line idx jdx)))
		(if (< jdx edx) (loop jdx))))))))
  ((if (input-port? file) call-with-open-ports call-with-input-file)
   file
   (lambda (iport)
     (do ((line (read-line iport) (read-line iport)))
	 ((eof-object? line))
       (do ((idx (string-index line #\<) (string-index line #\<)))
	   ((not idx) (proc-words line (string-length line)))
					; seen '<'
	 (proc-words line idx)
	 (let ((trm (if (and (<= (+ 4 idx) (string-length line))
			     (string=? "<!--" (substring line idx (+ 4 idx))))
			"-->" #\>)))
	   (let loop ((lne (substring line idx (string-length line)))
		      (tag "")
		      (quot #f))
	     (define edx (or (eof-object? lne)
			     (if quot
				 (string-index lne quot)
				 (if (char? trm)
				     (string-index lne #\" #\' #\>)
				     (string-index lne #\>)))))
	     (cond
	      ((not edx)		; still inside tag
	       ;;(print quot trm 'within-tag lne)
	       (loop (read-line iport)
		     (and markup-proc (string-append tag lne nl))
		     quot))
	      ((eqv? #t edx)		; EOF
	       ;;(print quot trm 'eof lne)
	       (slib:error 'unterminated 'HTML 'entity file)
	       (and markup-proc (markup-proc tag)))
	      ((eqv? quot (string-ref lne edx))	; end of quoted string
	       ;;(print quot trm 'end-quote lne)
	       (set! edx (+ 1 edx))
	       (loop (substring lne edx (string-length lne))
		     (and markup-proc
			  (string-append tag (substring lne 0 edx)))
		     #f))
	      ((not (eqv? #\> (string-ref lne edx))) ; start of quoted
	       ;;(print quot trm 'start-quote lne)
	       (set! edx (+ 1 edx))
	       (loop (substring lne edx (string-length lne))
		     (and markup-proc
			  (string-append tag (substring lne 0 edx)))
		     (string-ref lne (+ -1 edx))))
	      ((or (and (string? trm)	; found matching '>' or '-->'
			(<= 2 edx)
			(equal? trm (substring lne (+ -2 edx) (+ 1 edx))))
		   (eqv? (string-ref lne edx) trm))
	       ;;(print quot trm 'end-> lne)
	       (set! edx (+ 1 edx))
	       (and markup-proc
		    (markup-proc (string-append tag (substring lne 0 edx))))
					; process words after '>'
	       (set! line (substring lne edx (string-length lne))))
	      (else
	       ;;(print quot trm 'within-comment lne)
	       (set! edx (+ 1 edx))
	       (loop (substring lne edx (string-length lne))
		     (and markup-proc
			  (string-append tag (substring lne 0 edx)))
		     #f))))))
       (and newline-proc (newline-proc))))))

;;@args file limit
;;@args file
;;@1 is an input port or a string naming an existing file containing
;;HTML text.  If supplied, @2 must be an integer.  @2 defaults to
;;1000.
;;
;;@0 opens and reads HTML from port @1 or the file named by string @1,
;;until reaching the (mandatory) @samp{TITLE} field.  @0 returns the
;;title string with adjacent whitespaces collapsed to one space.  @0
;;returns #f if the title field is empty, absent, if the first
;;character read from @1 is not @samp{#\<}, or if the end of title is
;;not found within the first (approximately) @2 words.
(define (html:read-title file . limit)
  (set! limit (if (null? limit) 1000 (* 2 (car limit))))
  ((if (input-port? file) call-with-open-ports call-with-input-file)
   file
   (lambda (port)
     (and (eqv? #\< (peek-char port))
	  (call-with-current-continuation
	   (lambda (return)
	     (define (cnt . args)
	       (if (negative? limit)
		   (return #f)
		   (set! limit (+ -1 limit))))
	     (define capturing? #f)
	     (define text '())
	     (html-for-each
	      port
	      (lambda (str)
		(cnt)
		(if capturing? (set! text (cons " " (cons str text)))))
	      (lambda (str)
		(cnt)
		(cond ((prefix-ci? "<title" str)
		       (set! capturing? #t))
		      ((prefix-ci? "</title" str)
		       (return (and (not (null? text))
				    (apply string-append
					   (reverse (cdr text))))))
		      ((or (prefix-ci? "</head" str)
			   (prefix-ci? "<body" str))
		       (return #f))))
	      cnt
	      cnt)
	     #f))))))

(define (prefix-ci? pre str)
  (define prelen (string-length pre))
  (and (< prelen (string-length str))
       (string-ci=? pre (substring str 0 prelen))))

;;@body
;;@1 is a hypertext markup string.
;;
;;If @1 is a (hypertext) comment or DTD, then @0 returns #f.
;;Otherwise @0 returns the hypertext element string consed onto an
;;association list of the attribute name-symbols and values.  If the
;;tag ends with "/>", then "/" is appended to the hypertext element
;;string.  The name-symbols are created by @code{string-ci->symbol}.
;;Each value is a string; or #t if the name had no value
;;assigned within the markup.
(define (htm-fields htm)
  (require 'string-case)
  (and
   (not (and (> (string-length htm) 3) (equal? "<!" (substring htm 0 2))))
   (call-with-input-string htm
     (lambda (port)
       (define element #f)
       (define fields '())
       (cond ((not (eqv? 1 (fscanf port "<%s" element)))
	      (slib:error 'htm-fields 'strange htm)))
       (let loop ((chr (peek-char port)))
	 (define name #f)
	 (define junk #f)
	 (define value #t)
	 (cond
	  ((eof-object? chr)
	   (cond ((and element
		       (eqv? (string-ref element
					 (+ -1 (string-length element)))
			     #\>))
		  (cons (substring element 0 (+ -1 (string-length element)))
			fields))
		 (else
		  (slib:warn 'htm-fields 'missing '> htm)
		  (if element
		      (cons element (reverse fields))
		      (reverse fields)))))
	  ((eqv? #\> chr) (cons element (reverse fields)))
	  ((eqv? #\/ chr)
	   (set! element (string-append element (string (read-char port))))
	   (loop (peek-char port)))
	  ((char-whitespace? chr) (read-char port) (loop (peek-char port)))
	  ((case (fscanf port "%[-a-zA-Z0-9:] %[=] %[-.a-zA-Z0-9]"
			 name junk value)
	     ((3 1) #t)
	     ((2)
	      (case (peek-char port)
		((#\") (cond ((eqv? 1 (fscanf port "\"%[^\"]\"" value)))
			     ((eqv? #\" (peek-char port))
			      (read-char port)
			      (set! value ""))
			     (else #f)))
		((#\') (cond ((eqv? 1 (fscanf port "'%[^']'" value)))
			     ((eqv? #\' (peek-char port))
			      (read-char port)
			      (set! value ""))
			     (else #f)))
		(else #f)))
	     (else #f))
	   (set! fields (cons (cons (string-ci->symbol name) value)
                              fields))
	   (loop (peek-char port)))
	  (else (slib:warn 'htm-fields 'bad 'field htm)
		(reverse fields))))))))
