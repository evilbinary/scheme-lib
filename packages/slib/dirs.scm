;;; "dirs.scm" Directories.
; Copyright 1998, 2002 Aubrey Jaffer
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

(require 'filename)
(require 'line-i/o)
(require 'system)
(require 'filename)

;;@code{(require 'directory)}
;;@ftindex directory

;;@args
;;@0 returns a string containing the absolute file
;;name representing the current working directory.  If this string
;;cannot be obtained, #f is returned.
;;
;;If @0 cannot be supported by the platform, then #f is returned.
(define current-directory
  (case (software-type)
    ;;((amiga)				)
    ;;((macos thinkc)			)
    ((ms-dos windows atarist os/2) (lambda () (system->line "cd")))
    ;;((nosve)				)
    ((unix coherent plan9) (lambda () (system->line "pwd")))
    ;;((vms)				)
    (else #f)))

;;@body
;;Creates a sub-directory @1 of the current-directory.  If
;;successful, @0 returns #t; otherwise #f.
(define (make-directory name)
  (eqv? 0 (system (string-append "mkdir \"" name "\""))))

(define (dir:lister dirname tmp)
  (case (software-type)
    ((unix coherent plan9)
     (zero? (system (string-append "ls '" dirname "' > " tmp))))
    ((ms-dos windows os/2 atarist)
     (zero? (system (string-append "DIR /B \"" dirname "\" > " tmp))))
    (else (slib:error (software-type) 'list?))))

;;@args proc directory
;;@var{proc} must be a procedure taking one argument.
;;@samp{Directory-For-Each} applies @var{proc} to the (string) name of
;;each file in @var{directory}.  The dynamic order in which @var{proc} is
;;applied to the filenames is unspecified.  The value returned by
;;@samp{directory-for-each} is unspecified.
;;
;;@args proc directory pred
;;Applies @var{proc} only to those filenames for which the procedure
;;@var{pred} returns a non-false value.
;;
;;@args proc directory match
;;Applies @var{proc} only to those filenames for which
;;@code{(filename:match?? @var{match})} would return a non-false value
;;(@pxref{Filenames, , , slib, SLIB}).
;;
;;@example
;;(require 'directory)
;;(directory-for-each print "." "[A-Z]*.scm")
;;@print{}
;;"Bev2slib.scm"
;;"Template.scm"
;;@end example
(define (directory-for-each proc dirname . args)
  (define selector
    (cond ((null? args) identity)
	  ((> (length args) 1)
	   (slib:error 'directory-for-each 'too-many-arguments (cdr args)))
	  ((procedure? (car args)) (car args))
	  ((string? (car args)) (filename:match?? (car args)))
	  (else
	   (slib:error 'directory-for-each 'filter? (car args)))))
  (call-with-tmpnam
   (lambda (tmp)
     (and (dir:lister dirname tmp)
	  (file-exists? tmp)
	  (call-with-input-file tmp
	    (lambda (port)
	      (do ((filename (read-line port) (read-line port)))
		  ((or (eof-object? filename) (equal? "" filename)))
		(and (selector filename) (proc filename)))))))))

;;@body
;;@2 is a pathname whose last component is a (wildcard) pattern
;;(@pxref{Filenames, , , slib, SLIB}).
;;@1 must be a procedure taking one argument.
;;@samp{directory*-for-each} applies @var{proc} to the (string) name of
;;each file in the current directory.  The dynamic order in which @var{proc} is
;;applied to the filenames is unspecified.  The value returned by
;;@samp{directory*-for-each} is unspecified.
(define (directory*-for-each proc path-glob)
  (define dir (pathname->vicinity path-glob))
  (let ((glob (substring path-glob
			 (string-length dir)
			 (string-length path-glob))))
    (directory-for-each proc
			(if (equal? "" dir) "." dir)
			glob)))
