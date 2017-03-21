#!r6rs
;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage s23 error tricks)
  (export
    SRFI-23-error->R6RS)
  (import
    (rnrs))

  (define-syntax error-wrap
    (lambda (stx)
      (syntax-case stx ()
        ((_ ctxt signal expr ...)
         (with-syntax ((e (datum->syntax #'ctxt 'error)))
           #'(let-syntax ((e (identifier-syntax signal)))
               expr ...))))))

  (define (AV who)
    (lambda args (apply assertion-violation who args)))

  (define-syntax SRFI-23-error->R6RS
    (lambda (stx)
      (syntax-case stx ()
        ((ctxt ewho expr ...)
         (with-syntax ((e (datum->syntax #'ctxt 'error))
                       (d (datum->syntax #'ctxt 'define)))
           #'(let-syntax ((e (identifier-syntax (AV 'ewho)))
                          (d (lambda (stx)
                               (syntax-case stx ()
                                 ((kw (id . formals) . body)
                                  (identifier? #'id)
                                  #'(error-wrap kw (AV 'id)
                                     (d (id . formals) . body)))
                                 ((kw id . r)
                                  (identifier? #'id)
                                  #'(error-wrap kw (AV 'id)
                                     (d id . r)))))))
               expr ...))))))
)
