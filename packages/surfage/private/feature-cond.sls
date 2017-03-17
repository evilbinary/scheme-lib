#!r6rs
;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage private feature-cond)
  (export
    feature-cond)
  (import
    (rnrs)
    (surfage private registry))

  (define-syntax feature-cond
    (lambda (stx)
      (define (identifier?/name=? x n)
        (and (identifier? x)
             (symbol=? n (syntax->datum x))))
      (define (make-test t)
        (define (invalid-test)
          (syntax-violation #F "invalid test syntax" stx t))
        (syntax-case t ()
          ((c x ...)
           (identifier?/name=? (syntax c) (quote and))
           (cons (syntax and) (map make-test (syntax (x ...)))))
          ((c x ...)
           (identifier?/name=? (syntax c) (quote or))
           (cons (syntax or) (map make-test (syntax (x ...)))))
          ((c x ...)
           (identifier?/name=? (syntax c) (quote not))
           (if (= 1 (length (syntax (x ...))))
             (list (syntax not) (make-test (car (syntax (x ...)))))
             (invalid-test)))
          (datum
           (not (and (identifier? (syntax datum))
                     (memq (syntax->datum (syntax datum))
                           (quote (and or not else)))))
           (syntax (and (member (quote datum) available-features) #T)))
          (_ (invalid-test))))
      (syntax-case stx ()
        ((_ (test . exprs) ... (e . eexprs))
         (identifier?/name=? (syntax e) (quote else))
         (with-syntax (((clause ...)
                        (map cons (map make-test (syntax (test ...)))
                                  (syntax (exprs ...)))))
           (syntax (cond clause ... (else . eexprs)))))
        ((kw (test . exprs) ...)
         (syntax (kw (test . exprs) ... (else (no-clause-true))))))))

  (define (no-clause-true)
    (assertion-violation (quote feature-cond) "no clause true"))
)
