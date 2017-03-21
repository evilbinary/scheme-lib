;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

;; Fall-back library in case the host Scheme system does not provide SRFI-39.

#!r6rs
(library (surfage s39 parameters)
  (export
    make-parameter 
    parameterize)
  (import
    (rnrs))

  (define make-parameter
    (case-lambda
      [(val) (make-parameter val values)]
      [(val guard)
       (unless (procedure? guard)
         (assertion-violation 'make-parameter "not a procedure" guard))
       (let ([p (case-lambda
                  [() val]
                  [(x) (set! val (guard x))])])
         (p val)
         p)]))
      
  (define-syntax parameterize
    ;; Derived from Ikarus's implementation of parameterize.
    (lambda (stx)
      (syntax-case stx ()
        [(_ () b0 b ...)
         #'(let () b0 b ...)]
        [(_ ([p e] ...) b0 b ...)
         (with-syntax ([(tp ...) (generate-temporaries #'(p ...))]
                       [(te ...) (generate-temporaries #'(e ...))])
           #'(let ([tp p] ...
                   [te e] ...)
               (let ([swap (lambda ()
                             (let ([t (tp)])
                               (tp te)
                               (set! te t))
                             ...)])
                 (dynamic-wind
                  swap
                  (lambda () b0 b ...)
                  swap))))])))  

)

