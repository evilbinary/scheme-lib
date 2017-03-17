;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

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
    (only (ikarus) format)
    (prefix (only (ikarus) current-time time-nanosecond time-second time-gmt-offset) 
            host:))

  ;; Ikarus uses gettimeofday() which gives microseconds,
  ;; so our resolution is 1000 nanoseconds
  (define host:time-resolution 1000)
)
