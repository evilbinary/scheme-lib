;;; "scamacr.scm" syntax-case macros for Scheme constructs
;;; Copyright (C) 1992 R. Kent Dybvig
;;;
;;; Permission to copy this software, in whole or in part, to use this
;;; software for any lawful purpose, and to redistribute this software
;;; is granted subject to the restriction that all copies made of this
;;; software must include this copyright notice in full.  This software
;;; is provided AS IS, with NO WARRANTY, EITHER EXPRESS OR IMPLIED,
;;; INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY
;;; OR FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE
;;; AUTHORS BE LIABLE FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES OF ANY
;;; NATURE WHATSOEVER.

;;; Written by Robert Hieb & Kent Dybvig

;;; This file was munged by a simple minded sed script since it left
;;; its original authors' hands.  See syncase.sh for the horrid details.

;;; macro-defs.ss
;;; Robert Hieb & Kent Dybvig
;;; 92/06/18

(define-syntax with-syntax
   (lambda (x)
      (syntax-case x ()
         ((_ () e1 e2 ...)
          (syntax (begin e1 e2 ...)))
         ((_ ((out in)) e1 e2 ...)
          (syntax (syntax-case in () (out (begin e1 e2 ...)))))
         ((_ ((out in) ...) e1 e2 ...)
          (syntax (syntax-case (list in ...) ()
                     ((out ...) (begin e1 e2 ...))))))))

(define-syntax syntax-rules
   (lambda (x)
      (syntax-case x ()
         ((_ (k ...) ((keyword . pattern) template) ...)
          (with-syntax (((dummy ...)
                         (generate-temporaries (syntax (keyword ...)))))
             (syntax (lambda (x)
                        (syntax-case x (k ...)
                           ((dummy . pattern) (syntax template))
                           ...))))))))

(define-syntax or
   (lambda (x)
      (syntax-case x ()
         ((_) (syntax #f))
         ((_ e) (syntax e))
         ((_ e1 e2 e3 ...)
          (syntax (let ((t e1)) (if t t (or e2 e3 ...))))))))

(define-syntax and
   (lambda (x)
      (syntax-case x ()
         ((_ e1 e2 e3 ...) (syntax (if e1 (and e2 e3 ...) #f)))
         ((_ e) (syntax e))
         ((_) (syntax #t)))))

(define-syntax cond
   (lambda (x)
      (syntax-case x (else =>)
         ((_ (else e1 e2 ...))
          (syntax (begin e1 e2 ...)))
         ((_ (e0))
          (syntax (let ((t e0)) (if t t))))
         ((_ (e0) c1 c2 ...)
          (syntax (let ((t e0)) (if t t (cond c1 c2 ...)))))
         ((_ (e0 => e1)) (syntax (let ((t e0)) (if t (e1 t)))))
         ((_ (e0 => e1) c1 c2 ...)
          (syntax (let ((t e0)) (if t (e1 t) (cond c1 c2 ...)))))
         ((_ (e0 e1 e2 ...)) (syntax (if e0 (begin e1 e2 ...))))
         ((_ (e0 e1 e2 ...) c1 c2 ...)
          (syntax (if e0 (begin e1 e2 ...) (cond c1 c2 ...)))))))

(define-syntax let*
   (lambda (x)
      (syntax-case x ()
         ((let* () e1 e2 ...)
          (syntax (let () e1 e2 ...)))
         ((let* ((x1 v1) (x2 v2) ...) e1 e2 ...)
          (syncase:andmap identifier? (syntax (x1 x2 ...)))
          (syntax (let ((x1 v1)) (let* ((x2 v2) ...) e1 e2 ...)))))))

(define-syntax case
   (lambda (x)
      (syntax-case x (else)
         ((_ v (else e1 e2 ...))
          (syntax (begin v e1 e2 ...)))
         ((_ v ((k ...) e1 e2 ...))
          (syntax (if (memv v '(k ...)) (begin e1 e2 ...))))
         ((_ v ((k ...) e1 e2 ...) c1 c2 ...)
          (syntax (let ((x v))
                     (if (memv x '(k ...))
                         (begin e1 e2 ...)
                         (case x c1 c2 ...))))))))

(define-syntax do
   (lambda (orig-x)
      (syntax-case orig-x ()
         ((_ ((var init . step) ...) (e0 e1 ...) c ...)
          (with-syntax (((step ...)
                         (map (lambda (v s)
                                 (syntax-case s ()
                                    (() v)
                                    ((e) (syntax e))
                                    (_ (syntax-error orig-x))))
                              (syntax (var ...))
                              (syntax (step ...)))))
             (syntax-case (syntax (e1 ...)) ()
                (() (syntax (let doloop ((var init) ...)
                               (if (not e0)
                                   (begin c ... (doloop step ...))))))
                ((e1 e2 ...)
                 (syntax (let doloop ((var init) ...)
                            (if e0
                                (begin e1 e2 ...)
                                (begin c ... (doloop step ...))))))))))))

(define-syntax quasiquote
   (letrec
      ((gen-cons
        (lambda (x y)
           (syntax-case x (quote)
              ((quote x)
               (syntax-case y (quote list)
                  ((quote y) (syntax (quote (x . y))))
                  ((list y ...) (syntax (list (quote x) y ...)))
                  (y (syntax (cons (quote x) y)))))
              (x (syntax-case y (quote list)
                   ((quote ()) (syntax (list x)))
                   ((list y ...) (syntax (list x y ...)))
                   (y (syntax (cons x y))))))))

       (gen-append
        (lambda (x y)
           (syntax-case x (quote list cons)
              ((quote (x1 x2 ...))
               (syntax-case y (quote)
                  ((quote y) (syntax (quote (x1 x2 ... . y))))
                  (y (syntax (append (quote (x1 x2 ...) y))))))
              ((quote ()) y)
              ((list x1 x2 ...)
               (gen-cons (syntax x1) (gen-append (syntax (list x2 ...)) y)))
              (x (syntax-case y (quote list)
                   ((quote ()) (syntax x))
                   (y (syntax (append x y))))))))

       (gen-vector
        (lambda (x)
           (syntax-case x (quote list)
              ((quote (x ...)) (syntax (quote #(x ...))))
              ((list x ...) (syntax (vector x ...)))
              (x (syntax (list->vector x))))))

       (gen
        (lambda (p lev)
           (syntax-case p (unquote unquote-splicing quasiquote)
              ((unquote p)
               (if (= lev 0)
                   (syntax p)
                   (gen-cons (syntax (quote unquote))
                             (gen (syntax (p)) (- lev 1)))))
              (((unquote-splicing p) . q)
               (if (= lev 0)
                   (gen-append (syntax p) (gen (syntax q) lev))
                   (gen-cons (gen-cons (syntax (quote unquote-splicing))
                                       (gen (syntax p) (- lev 1)))
                             (gen (syntax q) lev))))
              ((quasiquote p)
               (gen-cons (syntax (quote quasiquote))
                         (gen (syntax (p)) (+ lev 1))))
              ((p . q)
               (gen-cons (gen (syntax p) lev) (gen (syntax q) lev)))
              (#(x ...) (gen-vector (gen (syntax (x ...)) lev)))
              (p (syntax (quote p)))))))

    (lambda (x)
       (syntax-case x ()
          ((- e) (gen (syntax e) 0))))))

