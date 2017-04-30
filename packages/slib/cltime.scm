;;;; "cltime.scm" Common-Lisp time conversion routines.
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

(require 'values)
(require 'time-core)
(require 'time-zone)

(define time:1900 (time:invert
		   (lambda (tm) (time:split tm 0 0 "GMT")) ;time:gmtime
		   '#(0 0 0 1 0 0 #f #f 0 0 "GMT")))
;@
(define (get-decoded-time)
  (decode-universal-time (get-universal-time)))
;@
(define (get-universal-time)
  (difftime (current-time) time:1900))
;@
(define (decode-universal-time utime . tzarg)
  (let ((tv (apply time:split
		   (offset-time time:1900 utime)
		   (if (null? tzarg)
		       (tz:params utime (time-zone (getenv "TZ")))
		       (list 0 (* 3600 (car tzarg)) "???")))))
    (values
     (vector-ref tv 0)			;second	[0..59]
     (vector-ref tv 1)			;minute	[0..59]
     (vector-ref tv 2)			;hour	[0..23]
     (vector-ref tv 3)			;date	[1..31]
     (+ 1 (vector-ref tv 4))		;month	[1..12]
     (+ 1900 (vector-ref tv 5))		;year	[0....]
     (modulo (+ -1 (vector-ref tv 6)) 7) ;day-of-week	[0..6] (0 is Monday)
     (eqv? 1 (vector-ref tv 8))		;daylight-saving-time?
     (if (provided? 'inexact)
	 (inexact->exact (/ (vector-ref tv 9) 3600))
	 (/ (vector-ref tv 9) 3600))	;time-zone	[-24..24]
     )))
;@
(define (encode-universal-time second minute hour date month year . tzarg)
  (let* ((tz (time-zone
	      (if (null? tzarg)
		  (getenv "TZ")
		  (string-append "???" (number->string (car tzarg))))))
	 (tv (vector second
		     minute
		     hour
		     date
		     (+ -1 month)
		     (+ -1900 year)
		     #f			;ignored
		     #f			;ignored
		     )))
    (difftime (time:invert
	       (lambda (tm) (apply time:split tm (tz:params tm tz))) ;localtime
	       tv)
	      time:1900)))
