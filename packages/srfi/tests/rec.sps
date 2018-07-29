#!r6rs
;; Copyright 2009 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import (rnrs) (srfi :31 rec))

(display 
 ((rec (F N) 
    (if (zero? N) 1 
      (* N (F (- N 1)))))
  10))
(newline)
