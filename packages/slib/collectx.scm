;"collect.scm" Sample collection operations
; COPYRIGHT (c) Kenneth Dickey 1992
;
;               This software may be used for any purpose whatever
;               without warranty of any kind.
; AUTHOR        Ken Dickey
; DATE          1992 September 1
; LAST UPDATED  1992 September 2
; NOTES         Expository (optimizations & checks elided).
;               Requires YASOS (Yet Another Scheme Object System).

(require 'object)
(require 'yasos)

(define collect:size size)
(define collect:print print)

;@
(define collection?
  (make-generic-method
    (lambda (obj!2)
      (cond ((or (list? obj!2)
                 (vector? obj!2)
                 (string? obj!2))
             #t)
            (else #f)))))
;@
(define empty?
  (lambda (collection!1)
    (zero? (collect:size collection!1))))
;@
(define gen-elts
  (make-generic-method
    (lambda (<collection>!2)
      (cond ((vector? <collection>!2)
             (collect:vector-gen-elts <collection>!2))
            ((list? <collection>!2)
             (collect:list-gen-elts <collection>!2))
            ((string? <collection>!2)
             (collect:string-gen-elts <collection>!2))
            (else
             (slib:error
               'gen-elts
               'operation-not-supported
               (collect:print <collection>!2 #f)))))))
;@
(define gen-keys
  (make-generic-method
    (lambda (collection!2)
      (if (or (vector? collection!2)
              (list? collection!2)
              (string? collection!2))
        (let ((max+1!3 (collect:size collection!2))
              (index!3 0))
          (lambda ()
            (cond ((< index!3 max+1!3)
                   (set! index!3 (collect:add1 index!3))
                   (collect:sub1 index!3))
                  (else (slib:error 'no-more 'keys 'in 'generator)))))
        (slib:error
          'gen-keys
          'operation-not-handled
          collection!2)))))
;@
(define do-elts
  (lambda (<proc>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-elts <collections>!1)))
      (let loop!4 ((counter!3 0))
        (cond ((< counter!3 max+1!2)
               (apply <proc>!1
                      (map (lambda (g!5) (g!5)) generators!2))
               (loop!4 (collect:add1 counter!3)))
              (else 'unspecific))))))
;@
(define do-keys
  (lambda (<proc>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-keys <collections>!1)))
      (let loop!4 ((counter!3 0))
        (cond ((< counter!3 max+1!2)
               (apply <proc>!1
                      (map (lambda (g!5) (g!5)) generators!2))
               (loop!4 (collect:add1 counter!3)))
              (else 'unspecific))))))
;@
(define map-elts
  (lambda (<proc>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-elts <collections>!1))
          (vec!2 (make-vector
                   (collect:size (car <collections>!1)))))
      (let loop!4 ((index!3 0))
        (cond ((< index!3 max+1!2)
               (vector-set!
                 vec!2
                 index!3
                 (apply <proc>!1
                        (map (lambda (g!5) (g!5)) generators!2)))
               (loop!4 (collect:add1 index!3)))
              (else vec!2))))))
;@
(define map-keys
  (lambda (<proc>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-keys <collections>!1))
          (vec!2 (make-vector
                   (collect:size (car <collections>!1)))))
      (let loop!4 ((index!3 0))
        (cond ((< index!3 max+1!2)
               (vector-set!
                 vec!2
                 index!3
                 (apply <proc>!1
                        (map (lambda (g!5) (g!5)) generators!2)))
               (loop!4 (collect:add1 index!3)))
              (else vec!2))))))
;@
(define for-each-key
  (make-generic-method
    (lambda (<collection>!2 <proc>!2)
      (collect:do-keys <proc>!2 <collection>!2))))
;@
(define for-each-elt
  (make-generic-method
    (lambda (<collection>!2 <proc>!2)
      (collect:do-elts <proc>!2 <collection>!2))))
;@
(define reduce
  (lambda (<proc>!1 <seed>!1 . <collections>!1)
    (letrec ((reduce-init!3
               (lambda (pred?!8 init!8 lst!8)
                 (if (null? lst!8)
                   init!8
                   (reduce-init!3
                     pred?!8
                     (pred?!8 init!8 (car lst!8))
                     (cdr lst!8))))))
      (if (null? <collections>!1)
        (cond ((null? <seed>!1) <seed>!1)
              ((null? (cdr <seed>!1)) (car <seed>!1))
              (else
               (reduce-init!3
                 <proc>!1
                 (car <seed>!1)
                 (cdr <seed>!1))))
        (let ((max+1!4 (collect:size (car <collections>!1)))
              (generators!4
                (map collect:gen-elts <collections>!1)))
          (let loop!6 ((count!5 0))
            (cond ((< count!5 max+1!4)
                   (set! <seed>!1
                     (apply <proc>!1
                            (cons <seed>!1
                                  (map (lambda (g!7) (g!7)) generators!4))))
                   (loop!6 (collect:add1 count!5)))
                  (else <seed>!1))))))))


;;@ pred true for every elt?
(define every?
  (lambda (<pred?>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-elts <collections>!1)))
      (let loop!4 ((count!3 0))
        (cond ((< count!3 max+1!2)
               (if (apply <pred?>!1
                          (map (lambda (g!5) (g!5)) generators!2))
                 (loop!4 (collect:add1 count!3))
                 #f))
              (else #t))))))

;;@ pred true for any elt?
(define any?
  (lambda (<pred?>!1 . <collections>!1)
    (let ((max+1!2 (collect:size (car <collections>!1)))
          (generators!2
            (map collect:gen-elts <collections>!1)))
      (let loop!4 ((count!3 0))
        (cond ((< count!3 max+1!2)
               (if (apply <pred?>!1
                          (map (lambda (g!5) (g!5)) generators!2))
                 #t
                 (loop!4 (collect:add1 count!3))))
              (else #f))))))


;; MISC UTILITIES

(define collect:add1
  (lambda (obj!1) (+ obj!1 1)))
(define collect:sub1
  (lambda (obj!1) (- obj!1 1)))

;; Nota Bene:  list-set! is bogus for element 0

(define collect:list-set!
  (lambda (<list>!1 <index>!1 <value>!1)
    (letrec ((set-loop!3
               (lambda (last!4 this!4 idx!4)
                 (cond ((zero? idx!4)
                        (set-cdr! last!4 (cons <value>!1 (cdr this!4)))
                        <list>!1)
                       (else
                        (set-loop!3
                          (cdr last!4)
                          (cdr this!4)
                          (collect:sub1 idx!4)))))))
      (if (zero? <index>!1)
        (cons <value>!1 (cdr <list>!1))
        (set-loop!3
          <list>!1
          (cdr <list>!1)
          (collect:sub1 <index>!1))))))

(add-setter list-ref collect:list-set!)
  ; for (setter list-ref)


;; generator for list elements
(define collect:list-gen-elts
  (lambda (<list>!1)
    (lambda ()
      (if (null? <list>!1)
        (slib:error
          'no-more
          'list-elements
          'in
          'generator)
        (let ((elt!3 (car <list>!1)))
          (begin (set! <list>!1 (cdr <list>!1)) elt!3))))))

;; generator for vector elements
(define collect:make-vec-gen-elts
  (lambda (<accessor>!1)
    (lambda (vec!2)
      (let ((max+1!3 (collect:size vec!2)) (index!3 0))
        (lambda ()
          (cond ((< index!3 max+1!3)
                 (set! index!3 (collect:add1 index!3))
                 (<accessor>!1 vec!2 (collect:sub1 index!3)))
                (else #f)))))))

(define collect:vector-gen-elts
  (collect:make-vec-gen-elts vector-ref))

(define collect:string-gen-elts
  (collect:make-vec-gen-elts string-ref))

;;; exports:

(define collect:gen-keys gen-keys)
(define collect:gen-elts gen-elts)
(define collect:do-elts do-elts)
(define collect:do-keys do-keys)

;;                        --- E O F "collect.oo" ---                    ;;
