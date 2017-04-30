;;;; "timezone.scm" Compute timezones and DST from TZ environment variable.
;;; Copyright (C) 1994, 1996, 1997 Aubrey Jaffer
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

;; The C-library support for time in general and time-zones in particular
;; stands as a fine example of how *not* to create interfaces.
;;
;; Functions are not consistently named.  Support for GMT is offered in one
;; direction only; The localtime function returns some timezone data in the
;; structure which it returns, and some data in shared global variables.
;; The structure which localtime returns is overwritten with each
;; invocation.  There is no way to find local time in zones other than GMT
;; and the local timezone.
;;
;; The tzfile(5) format encodes only a single timezone per file.  There is
;; no dispatch on zone names, so multiple copies of a timezone file exist
;; under different names.  The TZ `:' specification is unix filesystem
;; specific.  The tzfile(5) format makes no provision for byte-order
;; differences; It mixes 32-bit integer data with characters; specifying
;; ASCII bytes, it is incompatible with different character sizes.  The
;; binary format makes it impossible to easily inspect a file for
;; corruption.
;;
;; I have corrected most of the failings of the C-library time interface in
;; SLIB while maintaining compatablility.  I wrote support for Linux
;; timezone files because on a system where TZ is not set, there is no
;; other way to reveal this information.  HP-UX appears to have a more
;; sensible arrangement; I invite you to add support for it and other
;; platforms.
;;
;; Writing this was a long, tedious, and unenlightening process.  I hope it
;; is useful.
;;
;; Sat Nov 15 00:15:33 1997  Aubrey Jaffer

(require 'scanf)
(require 'time-core)
(require-if 'compiling 'tzfile)

;;; This definition is here so that READ-TZFILE can verify the
;;; existence of these files before loading tzfile.scm to actually
;;; read them.
(define tzfile:vicinity (make-vicinity
			 (if (file-exists? "/usr/share/zoneinfo/GMT")
			     "/usr/share/zoneinfo/"
			     "/usr/lib/zoneinfo/")))

(define (read-tzfile path)
  (define (existing path) (and (file-exists? path) path))
  (let ((realpath
	 (cond ((not path)
		(or (existing (in-vicinity tzfile:vicinity "localtime"))
		    (existing "/etc/localtime")))
	       ((or (char-alphabetic? (string-ref path 0))
		    (char-numeric? (string-ref path 0)))
		(in-vicinity tzfile:vicinity path))
	       (else path))))
    (or (and (file-exists? realpath)
	     (let ((zone #f))
	       (require 'tzfile)
	       (set! zone (tzfile:read realpath))
	       (and zone (list->vector (cons 'tz:file zone)))))
	(slib:error 'read-tzfile realpath))))

;;; Parse Posix TZ string.

(define (string->transition-day-time str)
  (let ((month 0) (week 0) (day #f) (junk #f))
    (or (case (sscanf str "J%u%s" day junk)
	  ((1) (and (<= 1 day 365)
		    (list #f #f day)))
	  (else #f))
	(case (sscanf str "%u%s" day junk)
	  ((1) (and (<= 0 day 365)
		    (list #f #t day)))
	  (else #f))
	(case (sscanf str "M%u.%u.%u%s" month week day junk)
	  ((3) (and (<= 1 month 12)
		    (<= 1 week 5)
		    (<= 0 day 6)
		    (list month week day)))
	  (else #f)))))

(define (string->transition-time str)
  (let ((date #f) (time "2") (junk #f))
    (and (or (eqv? 2 (sscanf str "%[JM.0-9]/%[:0-9]%s" date time junk))
	     (eqv? 1 (sscanf str "%[JM.0-9]" date junk)))
	 (let ((day (string->transition-day-time date))
	       (tim (string->time-offset time)))
	   (and day tim (append day (list tim)))))))

(define (string->time-offset str)
  (and str (string? str) (positive? (string-length str))
       (let ((hh #f) (mm 0) (ss 0) (junk #f))
	 (and (<= 1 (sscanf (if (memv (string-ref str 0) '(#\+ #\-))
				(substring str 1 (string-length str))
				str)
			    "%u:%u:%u%s" hh mm ss junk)
		  3)
	      hh (<= 0 hh 23) (<= 0 mm 59) (<= 0 ss 59)
	      (* (if (char=? #\- (string-ref str 0)) -1 1)
		 (+ ss (* 60 (+ mm (* hh 60)))))))))

(define (string->time-zone tz)
  (let ((tzname #f) (offset #f) (dtzname #f) (doffset #f)
		    (start-str #f) (end-str #f) (junk #f))
    (define found
      (sscanf
       tz "%[^0-9,+-]%[-:+0-9]%[^0-9,+-]%[-:+0-9],%[JM.0-9/:],%[JM.0-9/:]%s"
       tzname offset dtzname doffset start-str end-str junk))
    (set! offset (string->time-offset offset))
    (set! doffset (string->time-offset doffset))
    (cond
     ((and offset (eqv? 3 found))
      (set! doffset (+ -3600 offset))
      (set! found
	    (+ 1
	       (sscanf
		tz "%[^0-9,+-]%[-:+0-9]%[^0-9,+-],%[JM.0-9/:],%[JM.0-9/:]%s"
		tzname offset dtzname start-str end-str junk)))
      (set! offset (string->time-offset offset))))
    (case found
      ((2) (vector 'tz:fixed tz tzname offset))
      ((4) (vector 'tz:rule tz tzname dtzname offset doffset
		   (list 4 1 0 7200) (list 10 5 0 7200)))
      ((6) (let ((start (string->transition-time start-str))
		 (end   (string->transition-time   end-str)))
	     (and
	      start end
	      (vector 'tz:rule tz tzname dtzname offset doffset start end))))
      (else #f))))
;@
(define (time-zone tz)
  (cond ((vector? tz) tz)
	((or (not tz)
	     (eqv? #\: (string-ref tz 0)))
	 (let ()
	   (require 'tzfile)
	   (read-tzfile (and tz (substring tz 1 (string-length tz))))))
	(else (string->time-zone tz))))
