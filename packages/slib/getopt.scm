;;; "getopt.scm" POSIX command argument processing
;Copyright (C) 1993, 1994, 2002 Aubrey Jaffer
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

(define getopt:scan #f)
(define getopt:char #\-)
;@
(define getopt:opt #f)
;;(define *argv* *argv*)
(define *optind* 1)
(define *optarg* 0)
;@
(define (getopt optstring)
  (let ((opts (string->list optstring))
	(place #f)
	(arg #f)
	(argref (lambda () ((if (vector? *argv*) vector-ref list-ref)
			    *argv* *optind*))))
    (and
     (cond ((and getopt:scan (not (string=? "" getopt:scan))) #t)
	   ((>= *optind* (length *argv*)) #f)
	   (else
	    (set! arg (argref))
	    (cond ((or (<= (string-length arg) 1)
		       (not (char=? (string-ref arg 0) getopt:char)))
		   #f)
		  ((and (= (string-length arg) 2)
			(char=? (string-ref arg 1) getopt:char))
		   (set! *optind* (+ *optind* 1))
		   #f)
		  (else
		   (set! getopt:scan (substring arg 1 (string-length arg)))
		   #t))))
     (begin
       (set! getopt:opt (string-ref getopt:scan 0))
       (set! getopt:scan
	     (substring getopt:scan 1 (string-length getopt:scan)))
       (if (string=? "" getopt:scan) (set! *optind* (+ *optind* 1)))
       (set! place (member getopt:opt opts))
       (cond ((not place) #\?)
	     ((or (null? (cdr place)) (not (char=? #\: (cadr place))))
	      getopt:opt)
	     ((not (string=? "" getopt:scan))
	      (set! *optarg* getopt:scan)
	      (set! *optind* (+ *optind* 1))
	      (set! getopt:scan #f)
	      getopt:opt)
	     ((< *optind* (length *argv*))
	      (set! *optarg* (argref))
	      (set! *optind* (+ *optind* 1))
	      getopt:opt)
	     ((and (not (null? opts)) (char=? #\: (car opts))) #\:)
	     (else #\?))))))
;@
(define (getopt-- optstring)
  (let* ((opt (getopt (string-append optstring "-:")))
	 (optarg *optarg*))
    (cond ((eqv? #\- opt)		;long option
	   (do ((l (string-length *optarg*))
		(i 0 (+ 1 i)))
	       ((or (>= i l) (char=? #\= (string-ref optarg i)))
		(cond ((>= i l) (set! *optarg* #f) optarg)
		      (else (set! *optarg* (substring optarg (+ 1 i) l))
			    (substring optarg 0 i))))))
	  (else opt))))
