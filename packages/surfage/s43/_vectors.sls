;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s43 vectors)
  (export
    ;;; * Constructors
    make-vector vector
    vector-unfold         vector-unfold-right
    vector-copy           vector-reverse-copy
    vector-append         vector-concatenate
    ;;; * Predicates
    vector?
    vector-empty?
    vector=
    ;;; * Selectors
    vector-ref
    vector-length
    ;;; * Iteration
    vector-fold           vector-fold-right
    vector-map            vector-map!
    vector-for-each
    vector-count
    ;;; * Searching
    vector-index          vector-skip
    vector-index-right    vector-skip-right
    vector-binary-search  vector-any    vector-every
    ;;; * Mutators
    vector-set!
    vector-swap!
    (rename (my:vector-fill! vector-fill!))
    vector-reverse!
    vector-copy!          vector-reverse-copy!
    ;;; * Conversion
    (rename (my:vector->list vector->list))          reverse-vector->list
    (rename (my:list->vector list->vector))          reverse-list->vector )
  (import
    (except (rnrs) vector-map vector-for-each)
    (rnrs r5rs)
    (surfage s23 error tricks)
    (surfage s8 receive)
    (for (surfage private vanish) expand)
    (surfage private include))

  ;; I do these let-syntax tricks so the original vector-lib.scm file does
  ;; not have to be modified at all.
  (let-syntax
      ((define
        (let ((vd (vanish-define define
                   (make-vector vector vector? vector-ref vector-set! vector-length))))
          (lambda (stx)
            (define (rename? id)
              (memp (lambda (x) (free-identifier=? id x))
                    (list #'vector-fill! #'vector->list #'list->vector)))
            (define (rename id)
              (datum->syntax id
               (string->symbol
                (string-append "my:" (symbol->string (syntax->datum id))))))
            (syntax-case stx ()
              ((_ name . r)
               (and (identifier? #'name)
                    (rename? #'name))
               #`(define #,(rename #'name) . r))
              (_ (vd stx))))))
       (define-syntax
        (vanish-define define-syntax
         (receive))))
    (SRFI-23-error->R6RS "(library (surfage s43 vectors))"
     (include/resolve ("surfage" "s43") "vector-lib.scm")))
)
