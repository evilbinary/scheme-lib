#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(library (srfi :19 time compat)
  (export
    time-resolution
    timezone-offset
    current-time
    cumulative-thread-time
    cumulative-process-time
    cumulative-gc-time
    time-nanosecond
    time-second)
  (import
    (rnrs base)
    (only (scheme base)
          current-seconds
          seconds->date
          date-time-zone-offset
          current-inexact-milliseconds
          current-thread
          current-process-milliseconds
          current-gc-milliseconds))

  ;; MzScheme uses milliseconds, so our resolution in nanoseconds is #e1e6
  (define time-resolution #e1e6)

  (define timezone-offset
    (date-time-zone-offset (seconds->date (current-seconds))))

  (define (millis->repr x)
    (let-values (((d m) (div-and-mod x 1000)))
      (cons d (* m #e1e6))))

  (define (current-time)
    (millis->repr (exact (floor (current-inexact-milliseconds)))))

  (define (cumulative-thread-time)
    (millis->repr (current-process-milliseconds (current-thread))))

  (define (cumulative-process-time)
    (millis->repr (current-process-milliseconds #F)))

  (define (cumulative-gc-time)
    (millis->repr (current-gc-milliseconds)))

  (define time-nanosecond cdr)
  (define time-second car)
)
