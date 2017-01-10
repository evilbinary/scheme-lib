;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

#!r6rs
(import
  (rnrs base) ; no R6RS records
  (only (rnrs io simple) display write newline)
  (surfage s9 records))

(define-record-type thing
  (make-thing x)
  thing?
  (x thing-x)
  (y thing-y set-thing-y!))

(define t (make-thing 123))
(display "t => ") (write t) (newline)
(set-thing-y! t 'blah)
(display "t => ") (write t) (newline)
