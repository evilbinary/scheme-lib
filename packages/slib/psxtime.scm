;;;; "psxtime.scm" Posix time conversion routines
;;; Copyright (C) 1994, 1997 Aubrey Jaffer
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

;;; No, it doesn't do leap seconds.

(require 'multiarg-apply)
(require 'time-core)
(require-if 'compiling 'time-zone)
;@
(define (tz:std-offset zone)
  (case (vector-ref zone 0)
    ((tz:fixed) (vector-ref zone 3))
    ((tz:rule) (vector-ref zone 4))
    ((tz:file)
     (let ((mode-table (vector-ref zone 2)))
       (do ((type-idx 0 (+ 1 type-idx)))
	   ((or (>= type-idx (vector-length mode-table))
		(not (vector-ref (vector-ref mode-table type-idx) 2)))
	    (if (>= type-idx (vector-length mode-table))
		(vector-ref (vector-ref mode-table 0) 1)
		(- (vector-ref (vector-ref mode-table type-idx) 1)))))))
    (else (slib:error 'tz:std-offset "unknown timezone type" zone))))
;@
(define (localtime caltime . tz)
  (require 'time-zone)
  (set! tz (if (null? tz) (tzset) (car tz)))
  (apply time:split caltime (tz:params caltime tz)))
;@
(define (mktime univtime . tz)
  (require 'time-zone)
  (set! tz (if (null? tz) (tzset) (car tz)))
  (offset-time (gmktime univtime) (tz:std-offset tz)))
;@
(define (gmktime univtime)
  (time:invert time:gmtime univtime))
;@
(define (asctime decoded)
  (let ((days   '#("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat"))
	(months '#("Jan" "Feb" "Mar" "Apr" "May" "Jun"
			 "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))
	(number->2digits
	 (lambda (n ch)
	   (set! n (number->string n))
	   (if (= 1 (string-length n))
	       (string-append ch n)
	       n))))
    (string-append
     (vector-ref days (vector-ref decoded 6)) " "
     (vector-ref months (vector-ref decoded 4)) " "
     (number->2digits (vector-ref decoded 3) " ") " "
     (number->2digits (vector-ref decoded 2) "0") ":"
     (number->2digits (vector-ref decoded 1) "0") ":"
     (number->2digits (vector-ref decoded 0) "0") " "
     (number->string (+ 1900 (vector-ref decoded 5)))
     (string #\newline))))
;@
(define (ctime . args)
  (time:asctime (apply time:localtime args)))
;@
(define (gtime time)
  (time:asctime (time:gmtime time)))

;;;	GMT				Local -- take optional 2nd TZ arg
;;@
(define gmtime time:gmtime)

(define time:localtime localtime)
;;(define time:gmktime gmktime)	(define time:mktime mktime)
;;(define time:gtime gtime)	(define time:ctime ctime)

(define time:asctime asctime)

;@
(define daylight? #f)
(define *timezone* 0)
(define tzname '#("UTC" "???"))

(define tz:default #f)

;;;@ Interpret the TZ envariable.
(define (tzset . opt-tz)
  (define tz (if (null? opt-tz)
		 (getenv "TZ")
		 (car opt-tz)))
  (if (or (not tz:default)
	  (and (string? tz) (not (string-ci=? tz (vector-ref tz:default 1)))))
      (let ()
	(require 'time-zone)
	(set! tz:default (or (time-zone tz) '#(tz:fixed "UTC" "GMT" 0)))))
  (case (vector-ref tz:default 0)
    ((tz:fixed)
     (set! tzname (vector (vector-ref tz:default 2) "???"))
     (set! daylight? #f)
     (set! *timezone* (vector-ref tz:default 3)))
    ((tz:rule)
     (set! tzname (vector (vector-ref tz:default 2)
			  (vector-ref tz:default 3)))
     (set! daylight? #t)
     (set! *timezone* (vector-ref tz:default 4)))
    ((tz:file)
     (let ((mode-table (vector-ref tz:default 2))
	   (transition-types (vector-ref tz:default 5)))
       (set! daylight? #f)
       (set! *timezone* (vector-ref (vector-ref mode-table 0) 1))
       (set! tzname (make-vector 2 #f))
       (do ((type-idx 0 (+ 1 type-idx)))
	   ((>= type-idx (vector-length mode-table)))
	 (let ((rec (vector-ref mode-table type-idx)))
	   (if (vector-ref rec 2)
	       (set! daylight? #t)
	       (set! *timezone* (- (vector-ref rec 1))))))

       (do ((transition-idx (+ -1 (vector-length transition-types))
			    (+ -1 transition-idx)))
	   ((or (negative? transition-idx)
		(and (vector-ref tzname 0) (vector-ref tzname 1))))
	 (let ((rec (vector-ref mode-table
				(vector-ref transition-types transition-idx))))
	   (if (vector-ref rec 2)
	       (if (not (vector-ref tzname 1))
		   (vector-set! tzname 1 (vector-ref rec 0)))
	       (if (not (vector-ref tzname 0))
		   (vector-set! tzname 0 (vector-ref rec 0))))))))
    (else (slib:error 'tzset "unknown timezone type" tz)))
  tz:default)
