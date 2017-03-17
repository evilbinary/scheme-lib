;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s37 args-fold)
  (export
    args-fold
    (rename (make-option option))
    option?
    option-names
    option-required-arg?
    option-optional-arg?
    option-processor)
  (import 
    (rnrs)
    (surfage private include))
  
  
  (define-record-type option
    (fields 
      names required-arg? optional-arg? processor)
    (protocol 
      (lambda (c) 
        (lambda (n ra oa p)
          (if (and 
                (and (list? n)
                     (positive? (length n))
                     (for-all (lambda (x) 
                                (or (and (string? x) (positive? (string-length x))) 
                                    (char? x))) 
                              n))
                (boolean? ra)
                (boolean? oa)
                (not (and ra oa))
                (procedure? p))
            (c n ra oa p)
            (assertion-violation 'option "invalid arguments" n ra oa p))))))

  (define args-fold
    (let ([option make-option])
      (include/resolve ("surfage" "%3a37") "srfi-37-reference.scm")
      args-fold))
)
