#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(library (srfi :19 time compat)
  (export
    time-resolution
    (rename (my:timezone-offset timezone-offset))
    current-time
    cumulative-thread-time
    cumulative-process-time
    cumulative-gc-time
    time-nanosecond
    time-second)
  (import
    (rnrs base)
    (primitives r5rs:require current-utc-time timezone-offset)
    (srfi :19 time not-implemented))

  (define dummy (begin (r5rs:require 'time) #F))

  ;; Larceny uses gettimeofday() which gives microseconds,
  ;; so our resolution is 1000 nanoseconds
  (define time-resolution 1000)

  (define my:timezone-offset
    (let-values (((secs _) (current-utc-time)))
      (timezone-offset secs)))

  (define (current-time)
    (let-values (((secs micros) (current-utc-time)))
      (cons secs (* micros 1000))))

  (define time-nanosecond cdr)
  (define time-second car)
)
