;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s61 cond)
  (export
    (rename (general-cond cond)))
  (import
    (rnrs))
  
  (define-syntax general-cond
    (lambda (stx)
      (syntax-case stx ()
        [(_ clauses ...)
         (with-syntax ([(ours ...)
                        (map (lambda (c)
                               (syntax-case c (=>)
                                 [(generator guard => receiver)
                                  #'((let-values ([vals generator])
                                       (and (apply guard vals)
                                            vals))
                                     => (lambda (vals)
                                          (apply receiver vals)))]
                                 [_ c]))
                             #'(clauses ...))])
           #'(cond ours ...))])))
)
