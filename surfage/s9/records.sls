;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s9 records)
  (export 
    (rename (srfi:define-record-type define-record-type)))
  (import 
    (rnrs))
  
  (define-syntax srfi:define-record-type
    (lambda (stx)
      (syntax-case stx ()
        [(_ type (constructor constructor-tag ...)
                 predicate
                 (field-tag accessor setter ...) ...)         
         (and (for-all identifier? 
                       #'(type constructor predicate constructor-tag ... 
                               field-tag ... accessor ...))
              (for-all (lambda (s) 
                         (or (and (= 1 (length s)) (identifier? (car s)))
                             (= 0 (length s))))
                       #'((setter ...) ...))
              (for-all (lambda (ct) 
                         (memp (lambda (ft) (bound-identifier=? ct ft))
                               #'(field-tag ...)))
                       #'(constructor-tag ...)))         
         (with-syntax ([(field-clause ...)
                        (map (lambda (clause)
                               (if (= 2 (length clause)) 
                                 #`(immutable . #,clause) 
                                 #`(mutable . #,clause)))
                             #'((field-tag accessor setter ...) ...))]
                       [(unspec-tag ...)
                        (remp (lambda (ft) 
                                (memp (lambda (ct) (bound-identifier=? ft ct))
                                      #'(constructor-tag ...)))
                              #'(field-tag ...))])
           #'(define-record-type (type constructor predicate)
               (sealed #t)
               (protocol (lambda (ctor)
                           (lambda (constructor-tag ...)
                             (define unspec-tag)
                             ...
                             (ctor field-tag ...))))
               (fields field-clause ...)))])))
  
)
