;;; "comparse.scm" Break command line into arguments.
;Copyright (C) 1995, 1997, 2003 Aubrey Jaffer
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

;;;; This is a simple command-line reader.  It could be made fancier
;;; to handle lots of `shell' syntaxes.

;;; Albert L. Ting points out that a similar process can be used for
;;; reading files of options -- therefore READ-OPTIONS-FILE.

(require 'string-port)

;;@code{(require 'read-command)}
;;@ftindex read-command

(define (read-command-from-port port nl-term?)
  (define argv '())
  (define obj "")
  (define chars '())
  (define readc (lambda () (read-char port)))
  (define peekc (lambda () (peek-char port)))
  (define s-expression
    (lambda ()
      (splice-arg (call-with-output-string
		   (lambda (p) (display (slib:eval (read port)) p))))))
  (define backslash
    (lambda (goto)
      (readc)
      (let ((c (readc)))
	(cond ((eqv? #\newline c) (goto (peekc)))
	      ((and (char-whitespace? c) (eqv? #\newline (peekc))
		    (eqv? 13 (char->integer c)))
	       (readc) (goto (peekc)))
	      (else (set! chars (cons c chars)) (build-token (peekc)))))))
  (define loop
    (lambda (c)
      (case c
	((#\\) (backslash loop))
	((#\") (splice-arg (read port)))
	((#\( #\') (s-expression))
	((#\#) (do ((c (readc) (readc)))
		   ((or (eof-object? c) (eqv? #\newline c))
		    (if nl-term? c (loop (peekc))))))
	((#\;) (readc))
	((#\newline) (readc) (and (not nl-term?) (loop (peekc))))
	(else (cond ((eof-object? c) c)
		    ((char-whitespace? c) (readc) (loop (peekc)))
		    (else (build-token c)))))))
  (define splice-arg
    (lambda (arg)
      (set! obj (string-append obj (list->string (reverse chars)) arg))
      (set! chars '())
      (build-token (peekc))))
  (define buildit
    (lambda ()
      (readc)
      (set! argv (cons (string-append obj (list->string (reverse chars)))
		       argv))))
  (define build-token
    (lambda (c)
      (case c
	((#\") (splice-arg (read port)))
	((#\() (s-expression))
	((#\\) (backslash build-token))
	((#\;) (buildit))
	(else (cond ((or (eof-object? c) (char-whitespace? c))
		     (buildit)
		     (cond ((not (and nl-term? (eqv? c #\newline)))
			    (set! obj "")
			    (set! chars '())
			    (loop (peekc)))))
		    (else (set! chars (cons (readc) chars))
			  (build-token (peekc))))))))
  (let ((c (loop (peekc))))
    (cond ((and (null? argv) (eof-object? c)) c)
	  (else (reverse argv)))))

;;@args port
;;@args
;;@code{read-command} converts a @dfn{command line} into a list of strings
;;@cindex command line
;;suitable for parsing by @code{getopt}.  The syntax of command lines
;;supported resembles that of popular @dfn{shell}s.  @code{read-command}
;;updates @var{port} to point to the first character past the command
;;delimiter.
;;
;;If an end of file is encountered in the input before any characters are
;;found that can begin an object or comment, then an end of file object is
;;returned.
;;
;;The @var{port} argument may be omitted, in which case it defaults to the
;;value returned by @code{current-input-port}.
;;
;;The fields into which the command line is split are delimited by
;;whitespace as defined by @code{char-whitespace?}.  The end of a command
;;is delimited by end-of-file or unescaped semicolon (@key{;}) or
;;@key{newline}.  Any character can be literally included in a field by
;;escaping it with a backslach (@key{\}).
;;
;;The initial character and types of fields recognized are:
;;@table @asis
;;@item @samp{\}
;;The next character has is taken literally and not interpreted as a field
;;delimiter.  If @key{\} is the last character before a @key{newline},
;;that @key{newline} is just ignored.  Processing continues from the
;;characters after the @key{newline} as though the backslash and
;;@key{newline} were not there.
;;@item @samp{"}
;;The characters up to the next unescaped @key{"} are taken literally,
;;according to [R4RS] rules for literal strings
;;(@pxref{Strings, , ,r4rs, Revised(4) Scheme}).
;;@item @samp{(}, @samp{%'}
;;One scheme expression is @code{read} starting with this character.  The
;;@code{read} expression is evaluated, converted to a string
;;(using @code{display}), and replaces the expression in the returned
;;field.
;;@item @samp{;}
;;Semicolon delimits a command.  Using semicolons more than one command
;;can appear on a line.  Escaped semicolons and semicolons inside strings
;;do not delimit commands.
;;@end table
;;
;;@noindent
;;The comment field differs from the previous fields in that it must be
;;the first character of a command or appear after whitespace in order to
;;be recognized.  @key{#} can be part of fields if these conditions are
;;not met.  For instance, @code{ab#c} is just the field ab#c.
;;
;;@table @samp
;;@item #
;;Introduces a comment.  The comment continues to the end of the line on
;;which the semicolon appears.  Comments are treated as whitespace by
;;@code{read-dommand-line} and backslashes before @key{newline}s in
;;comments are also ignored.
;;@end table
(define (read-command . port)
  (read-command-from-port (cond ((null? port) (current-input-port))
				((= 1 (length port)) (car port))
				(else
				 (slib:error 'read-command
					     "Wrong Number of ARGs:" port)))
			  #t))

;;@body
;;@code{read-options-file} converts an @dfn{options file} into a list of
;;@cindex options file
;;strings suitable for parsing by @code{getopt}.  The syntax of options
;;files is the same as the syntax for command
;;lines, except that @key{newline}s do not terminate reading (only @key{;}
;;or end of file).
;;
;;If an end of file is encountered before any characters are found that
;;can begin an object or comment, then an end of file object is returned.
(define (read-options-file filename)
  (call-with-input-file filename
    (lambda (port) (read-command-from-port port #f))))
