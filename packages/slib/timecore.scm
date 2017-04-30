;;;; "timecore.scm" Core time conversion routines
;;; Copyright (C) 1994, 1997, 2004, 2005 Aubrey Jaffer
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

(define time:days/month
  '#(#(31 28 31 30 31 30 31 31 30 31 30 31) ; Normal years.
     #(31 29 31 30 31 30 31 31 30 31 30 31)))

(define (leap-year? year)
  (and (zero? (remainder year 4))
       (or (not (zero? (remainder year 100)))
	   (zero? (remainder year 400))))) ; Leap years.

;;; Returns the `struct tm' representation of T,
;;; offset TM_GMTOFF seconds east of UCT.
;@
(define (time:split t tm_isdst tm_gmtoff tm_zone)
  (define tms (inexact->exact
	       (round (- (difftime t time:year-70) tm_gmtoff))))
  (let* ((secs (modulo tms 86400))	; SECS/DAY
	 (days (+ (quotient tms 86400)	; SECS/DAY
		  (if (and (negative? tms) (positive? secs)) -1 0))))
    (let ((tm_hour (quotient secs 3600))
	  (secs (remainder secs 3600))
	  (tm_wday (modulo (+ 4 days) 7))) ; January 1, 1970 was a Thursday.
      (let loop ((tm_year 1970)
		 (tm_yday days))
	(let ((diy (if (leap-year? tm_year) 366 365)))
	  (cond
	   ((negative? tm_yday) (loop (+ -1 tm_year) (+ tm_yday diy)))
	   ((>= tm_yday diy) (loop (+ 1 tm_year) (- tm_yday diy)))
	   (else
	    (let ((mv (vector-ref time:days/month (- diy 365))))
	      (do ((tm_mon 0 (+ 1 tm_mon))
		   (tm_mday tm_yday (- tm_mday (vector-ref mv tm_mon))))
		  ((< tm_mday (vector-ref mv tm_mon))
		   (vector
		    (remainder secs 60)	; Seconds.	[0-61] (2 leap seconds)
		    (quotient secs 60)	; Minutes.	[0-59]
		    tm_hour		; Hours.	[0-23]
		    (+ tm_mday 1)	; Day.		[1-31]
		    tm_mon		; Month.	[0-11]
		    (- tm_year 1900)	; Year	- 1900.
		    tm_wday		; Day of week.	[0-6]
		    tm_yday		; Days in year. [0-365]
		    tm_isdst		; DST.		[-1/0/1]
		    tm_gmtoff		; Seconds west of UTC.
		    tm_zone		; Timezone abbreviation.
		    )))))))))))

(define time:year-70
  (let ((t (current-time)))
    (offset-time t (- (difftime t 0)))))
;@
(define (time:invert decoder target)
  (let* ((times '#(1 60 3600 86400 2678400 32140800))
	 (trough			; rough time for target
	  (do ((i 5 (+ i -1))
	       (trough time:year-70
		       (offset-time trough (* (vector-ref target i)
					      (vector-ref times i)))))
	      ((negative? i) trough))))
;;;    (print 'trough trough 'target target)
    (let loop ((guess trough)
	       (j 0)
	       (guess-tm (decoder trough)))
;;;      (print 'guess guess 'guess-tm guess-tm)
      (do ((i 5 (+ i -1))
	   (rough time:year-70
		  (offset-time rough (* (vector-ref guess-tm i)
					(vector-ref times i))))
	   (sign (let ((d (- (vector-ref target 5)
			     (vector-ref guess-tm 5))))
		   (and (not (zero? d)) d))
		 (or sign
		     (let ((d (- (vector-ref target i)
				 (vector-ref guess-tm i))))
		       (and (not (zero? d)) d)))))
	  ((negative? i)
	   (let ((distance (abs (difftime trough rough))))
	     (cond ((and (zero? distance) sign)
;;;		    (print "trying to jump")
		    (set! distance (if (negative? sign) -86400 86400)))
		   ((and sign (negative? sign)) (set! distance (- distance))))
	     (set! guess (offset-time guess distance))
;;;	     (print 'distance distance 'sign sign)
	     (cond ((zero? distance) guess)
		   ((> j 5) #f)		;to prevent inf loops.
		   (else
		    (loop guess
			  (+ 1 j)
			  (decoder guess))))))))))
;@
(define (time:gmtime tm)
  (time:split tm 0 0 "GMT"))

;;;; Use the timezone

(define (tzrule->caltime year previous-gmt-offset
			 tr-month tr-week tr-day tr-time)
  (define leap? (leap-year? year))
  (define gmmt
    (time:invert time:gmtime
		 (vector 0 0 0 1 (if tr-month (+ -1 tr-month) 0) year #f #f 0)))
  (offset-time
   gmmt
   (+ tr-time previous-gmt-offset
      (* 3600 24
	 (if tr-month
	     (let ((fdow (vector-ref (time:gmtime gmmt) 6)))
	       (case tr-week
		 ((1 2 3 4) (+ (modulo (- tr-day fdow) 7)
			       (* 7 (+ -1 tr-week))))
		 ((5)
		  (do ((mmax (vector-ref
			      (vector-ref time:days/month (if leap? 1 0))
			      (+ -1 tr-month)))
		       (d (modulo (- tr-day fdow) 7) (+ 7 d)))
		      ((>= d mmax) (+ -7 d))))
		 (else (slib:error 'tzrule->caltime
				   "week out of range" tr-week))))
	     (+ tr-day
		(if (and (not tr-week) (>= tr-day 60) (leap-year? year))
		    1 0)))))))
;@
(define (tz:params caltime tz)
  (case (vector-ref tz 0)
    ((tz:fixed) (list 0 (vector-ref tz 3) (vector-ref tz 2)))
    ((tz:rule)
     (let* ((year (vector-ref (time:gmtime caltime) 5))
	    (ttime0 (apply tzrule->caltime
			   year (vector-ref tz 4) (vector-ref tz 6)))
	    (ttime1 (apply tzrule->caltime
			   year (vector-ref tz 5) (vector-ref tz 7)))
	    (dst (if (and (not (negative? (difftime caltime ttime0)))
			  (negative? (difftime caltime ttime1)))
		     1 0)))
       (list dst (vector-ref tz (+ 4 dst)) (vector-ref tz (+ 2 dst)))
       ;;(for-each display (list (gtime ttime0) (gtime caltime) (gtime ttime1)))
       ))
    ((tz:file) (let ((zone-spec (tzfile:get-zone-spec caltime tz)))
		 (list (if (vector-ref zone-spec 2) 1 0)
		       (- (vector-ref zone-spec 1))
		       (vector-ref zone-spec 0))))
    (else (slib:error 'tz:params "unknown timezone type" tz))))

(define (tzfile:transition-index time zone)
  (define times (difftime time time:year-70))
  (and zone
       (apply
	(lambda (path mode-table leap-seconds transition-times transition-types)
	  (let ((ntrns (vector-length transition-times)))
	    (if (zero? ntrns) -1
		(let loop ((lidx (quotient (+ 1 ntrns) 2))
			   (jmp (quotient (+ 1 ntrns) 4)))
		  (let* ((idx (max 0 (min lidx (+ -1 ntrns))))
			 (idx-time (vector-ref transition-times idx)))
		    (cond ((<= jmp 0)
			   (+ idx (if (>= times idx-time) 0 -1)))
			  ((= times idx-time) idx)
			  ((and (zero? idx) (< times idx-time)) -1)
			  ((and (not (= idx lidx)) (not (< times idx-time))) idx)
			  (else
			   (loop ((if (< times idx-time) - +) idx jmp)
			 (if (= 1 jmp) 0 (quotient (+ 1 jmp) 2))))))))))
	(cdr (vector->list zone)))))
(define (tzfile:get-std-spec mode-table)
  (do ((type-idx 0 (+ 1 type-idx)))
      ((or (>= type-idx (vector-length mode-table))
	   (not (vector-ref (vector-ref mode-table type-idx) 2)))
       (if (>= type-idx (vector-length mode-table))
	   (vector-ref mode-table 0)
	   (vector-ref mode-table type-idx)))))

(define (tzfile:get-zone-spec time zone)
  (apply
   (lambda (path mode-table leap-seconds transition-times transition-types)
     (let ((trans-idx (tzfile:transition-index time zone)))
       (if (zero? (vector-length transition-types))
	   (vector-ref mode-table 0)
	   (if (negative? trans-idx)
	       (tzfile:get-std-spec mode-table)
	       (vector-ref mode-table
			   (vector-ref transition-types trans-idx))))))
   (cdr (vector->list zone))))
