;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s19 time compat)
  (export
    format
    host:time-resolution
    host:current-time 
    host:time-nanosecond 
    host:time-second 
    host:time-gmt-offset)
  (import
    (rnrs base)
    (only (scheme base) format current-inexact-milliseconds date-time-zone-offset
                        seconds->date current-seconds))

  ;; MzScheme uses milliseconds, so our resolution in nanoseconds is #e1e6
  (define host:time-resolution #e1e6)
  
  (define (host:current-time)
    (exact (floor (current-inexact-milliseconds))))
  
  (define (host:time-nanosecond t)
    (* (mod t 1000) #e1e6))
  
  (define (host:time-second t)
    (div t 1000))
  
  (define (host:time-gmt-offset t)
    (date-time-zone-offset (seconds->date (host:time-second t))))
)
