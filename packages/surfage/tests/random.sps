;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

#!r6rs
(import (rnrs) (surfage s27 random-bits))

(do ((i 0 (+ i 1)))
  ((= i 10) 'done)
  (display (random-integer 100))
  (newline))

(do ((i 0 (+ i 1)))
  ((= i 10) 'done)
  (display (random-real))
  (newline))
