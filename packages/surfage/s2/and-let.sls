;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s2 and-let)  
  (export 
    and-let*)
  (import 
    (rnrs))
  
  (define-syntax and-let*
    (lambda (stx)
      (define (get-id c)
        (syntax-case c () [(var expr) #'var] [_ #f]))
      (syntax-case stx ()
        [(_ (clause* ...) body* ...)
         (for-all identifier? (filter values (map get-id #'(clause* ...))))
         #'(and-let*-core #t (clause* ...) body* ...)])))
  
  (define-syntax and-let*-core
    (lambda (stx)
      (syntax-case stx ()
        [(kw _ ([var expr] clause* ...) body* ...)
         #'(let ([var expr])
             (if var
               (kw var (clause* ...) body* ...)
               #f))]
        [(kw _ ([expr] clause* ...) body* ...)
         #'(let ([t expr])
             (if t
               (kw t (clause* ...) body* ...)
               #f))]
        [(kw _ (id clause* ...) body* ...)
         (or (identifier? #'id)
             (syntax-violation #f "invalid clause" stx #'id))
         #'(if id
             (kw id (clause* ...) body* ...)
             #f)]
        [(kw last () body* ...)
         (if (positive? (length #'(body* ...)))
           #'(begin body* ...)
           #'last)])))
)
