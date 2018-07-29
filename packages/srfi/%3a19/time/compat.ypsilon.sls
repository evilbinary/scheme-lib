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
    (only (core) microsecond microsecond->utc)
    (srfi :19 time not-implemented))

  (define time-resolution 1000)

  (define timezone-offset
    (let ((t (microsecond)))
      (/ (- t (microsecond->utc t)) #e1e6)))

  (define (current-time)
    (let-values (((d m) (div-and-mod (microsecond) #e1e6)))
      (cons d (* m 1000))))

  (define time-nanosecond cdr)
  (define time-second car)
)
