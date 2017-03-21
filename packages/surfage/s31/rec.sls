;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s31 rec)
  (export rec)
  (import (rnrs))
  
  ;; Taken directly from the SRFI-31
  (define-syntax rec
    (syntax-rules ()
      [(rec (NAME . VARIABLES) . BODY)
       (letrec ( (NAME (lambda VARIABLES . BODY)) ) NAME)]
      [(rec NAME EXPRESSION)
       (letrec ( (NAME EXPRESSION) ) NAME)]))  
  
)
