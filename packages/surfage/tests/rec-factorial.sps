;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

#!r6rs
(import (rnrs) (surfage s31 rec))

(display 
 ((rec (F N) 
    (if (zero? N) 1 
      (* N (F (- N 1)))))
  10))
(newline)
