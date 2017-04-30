;;;;"cvs.scm" enumerate files under CVS control.
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

(require 'scanf)
(require 'line-i/o)
(require 'string-search)

;;@body Returns a list of the local pathnames (with prefix @1) of all
;;CVS controlled files in @1 and in @1's subdirectories.
(define (cvs-files directory/)
  (cvs:entries directory/ #t))

;;@body Returns a list of all of @1 and all @1's CVS controlled
;;subdirectories.
(define (cvs-directories directory/)
  (and (file-exists? (in-vicinity directory/ "CVS/Entries"))
       (cons directory/ (cvs:entries directory/ #f))))

(define (cvs:entries directory do-files?)
  (define files '())
  (define cvse (in-vicinity directory "CVS/Entries"))
  (define cvsel (in-vicinity directory "CVS/Entries.Log"))
  (set! directory (substring directory
			     (if (eqv? 0 (substring? "./" directory)) 2 0)
			     (string-length directory)))
  (if (file-exists? cvse)
      (call-with-input-file cvse
	(lambda (port)
	  (do ((line (read-line port) (read-line port)))
	      ((eof-object? line))
	    (let ((fname #f))
	      (cond ((eqv? 1 (sscanf line "/%[^/]" fname))
		     (and do-files?
			  (set! files
				(cons (in-vicinity directory fname) files))))
		    ((eqv? 1 (sscanf line "D/%[^/]" fname))
		     (set! files
			   (append (cvs:entries (sub-vicinity directory fname)
						do-files?)
				   (if do-files? '()
				       (list (sub-vicinity directory fname)))
				   files))))))))
      (slib:warn 'cvs:entries 'missing cvse))
  (set! files (reverse files))
  (if (file-exists? cvsel)
      (call-with-input-file cvsel
	(lambda (port)
	  (do ((line (read-line port) (read-line port)))
	      ((eof-object? line) files)
	    (let ((fname #f))
	      (cond ((eqv? 1 (sscanf line "A D/%[^/]/" fname))
		     (set! files
			   (append files
				   (if do-files? '()
				       (list (sub-vicinity directory fname)))
				   (cvs:entries (sub-vicinity directory fname)
						do-files?)))))))))
      files))

;;@body Returns the (string) contents of @var{path/}CVS/Root;
;;or @code{(getenv "CVSROOT")} if Root doesn't exist.
(define (cvs-root path/)
  (if (not (vicinity:suffix? (string-ref path/ (+ -1 (string-length path/)))))
      (slib:error 'missing 'vicinity-suffix path/))
  (let ((rootpath (string-append path/ "CVS/Root")))
    (if (file-exists? rootpath)
	(call-with-input-file rootpath read-line)
	(getenv "CVSROOT"))))

;;@body Returns the (string) contents of @var{directory/}CVS/Root appended
;;with @var{directory/}CVS/Repository; or #f if @var{directory/}CVS/Repository
;;doesn't exist.
(define (cvs-repository directory/)
  (let ((root (cvs-root directory/))
	(repath (in-vicinity (sub-vicinity directory/ "CVS/") "Repository")))
    (define root/idx (substring? "/" root))
    (define rootlen (string-length root))
    (and
     root/idx
     (file-exists? repath)
     (let ((repos (call-with-input-file repath read-line)))
       (define replen (and (string? repos) (string-length repos)))
       (cond ((not (and replen (< 1 replen))) #f)
	     ((not (char=? #\/ (string-ref repos 0)))
	      (string-append root "/" repos))
	     ((eqv? 0 (substring? (substring root root/idx rootlen) repos))
	      (string-append
	       root
	       (substring repos (- rootlen root/idx) replen)))
	     (else (slib:error 'mismatched root repos)))))))

;;@body
;;Writes @1 to file CVS/Root of @2.
(define (cvs-set-root! new-root directory/)
  (define root (cvs-root directory/))
  (define repos (cvs-repository directory/))
  (if (not repos) (slib:error 'not 'cvs directory/))
  (if (not (eqv? 0 (substring? root repos)))
      (slib:error 'bad 'cvs root repos))
  (call-with-output-file
      (in-vicinity (sub-vicinity directory/ "CVS") "Root")
    (lambda (port) (write-line new-root port)))
  (call-with-output-file
      (in-vicinity (sub-vicinity directory/ "CVS") "Repository")
    (lambda (port)
      (write-line
       (substring repos (+ 1 (string-length root)) (string-length repos))
       port))))

;;@body
;;Writes @1 to file CVS/Root of @2 and all its CVS subdirectories.
(define (cvs-set-roots! new-root directory/)
  (for-each (lambda (dir/) (cvs-set-root! new-root dir/))
	    (cvs-directories directory/)))

;;@body
;;Signals an error if CVS/Repository or CVS/Root files in @1 or any
;;subdirectory do not match.
(define (cvs-vet directory/)
  (define diroot (cvs-root directory/))
  (for-each
   (lambda (path/)
     (define path/CVS (sub-vicinity path/ "CVS/"))
     (cond ((not (cvs-repository path/))
	    (slib:error 'bad (in-vicinity path/CVS "Repository")))
	   ((not (equal? diroot (cvs-root path/)))
	    (slib:error 'mismatched 'root (in-vicinity path/CVS "Root")))))
   (or (cvs-directories directory/) (slib:error 'not 'cvs directory/))))

;;(define cvs-rsh (or (getenv "CVS_RSH") "rsh"))
