; "lineio.scm", line oriented input/output functions for Scheme.
; Copyright (C) 1992, 1993 Aubrey Jaffer
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

(require-if 'compiling 'filename)

;;@args
;;@args port
;;Returns a string of the characters up to, but not including a
;;newline or end of file, updating @var{port} to point to the
;;character following the newline.  If no characters are available, an
;;end of file object is returned.  The @var{port} argument may be
;;omitted, in which case it defaults to the value returned by
;;@code{current-input-port}.
(define (read-line . port)
  (let* ((char (apply read-char port)))
    (if (eof-object? char)
	char
	(do ((char char (apply read-char port))
	     (clist '() (cons char clist)))
	    ((or (eof-object? char) (char=? #\newline char))
	     (list->string (reverse clist)))))))

;;@args string
;;@args string port
;;Fills @1 with characters up to, but not including a newline or end
;;of file, updating the @var{port} to point to the last character read
;;or following the newline if it was read.  If no characters are
;;available, an end of file object is returned.  If a newline or end
;;of file was found, the number of characters read is returned.
;;Otherwise, @code{#f} is returned.  The @var{port} argument may be
;;omitted, in which case it defaults to the value returned by
;;@code{current-input-port}.
(define (read-line! str . port)
  (let* ((char (apply read-char port))
	 (midx (+ -1 (string-length str))))
    (if (eof-object? char)
	char
	(do ((char char (apply read-char port))
	     (i 0 (+ 1 i)))
	    ((or (eof-object? char)
		 (char=? #\newline char)
		 (> i midx))
	     (if (> i midx) #f i))
	  (string-set! str i char)))))

;;@args string
;;@args string port
;;Writes @1 followed by a newline to the given @var{port} and returns
;;an unspecified value.  The @var{Port} argument may be omitted, in
;;which case it defaults to the value returned by
;;@code{current-input-port}.
(define (write-line str . port)
  (apply display (cons str port))
  (apply newline port))

;;@args command tmp
;;@args command
;;@1 must be a string.  The string @2, if supplied, is a path to use as
;;a temporary file.  @0 calls @code{system} with @1 as argument,
;;redirecting stdout to file @2.  @0 returns a string containing the
;;first line of output from @2.
;;
;;@0 is intended to be a portable method for getting one-line results
;;from programs like @code{pwd}, @code{whoami}, @code{hostname},
;;@code{which}, @code{identify}, and @code{cksum}.  Its behavior when
;;called with programs which generate lots of output is unspecified.
(define (system->line command . tmp)
  (require 'filename)
  (cond ((null? tmp)
	 (call-with-tmpnam
	  (lambda (tmp) (system->line command tmp))))
	(else
	 (set! tmp (car tmp))
	 (and (zero? (system (string-append command " > " tmp)))
	      (file-exists? tmp)
	      (let ((line (call-with-input-file tmp read-line)))
		(if (eof-object? line) "" line))))))
