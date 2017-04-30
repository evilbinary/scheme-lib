;;; "scaoutp.scm" syntax-case output
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

;;; output.ss
;;; Robert Hieb & Kent Dybvig
;;; 92/06/18

; The output routines can be tailored to feed a specific system or compiler.
; They are set up here to generate the following subset of standard Scheme:

;  <expression> :== <application>
;                |  <variable>
;                |  (set! <variable> <expression>)
;                |  (define <variable> <expression>)
;                |  (lambda (<variable>*) <expression>)
;                |  (lambda <variable> <expression>)
;                |  (lambda (<variable>+ . <variable>) <expression>)
;                |  (letrec (<binding>+) <expression>)
;                |  (if <expression> <expression> <expression>)
;                |  (begin <expression> <expression>)
;                |  (quote <datum>)
; <application> :== (<expression>+)
;     <binding> :== (<variable> <expression>)
;    <variable> :== <symbol>

; Definitions are generated only at top level.

(define syncase:build-application
   (lambda (fun-exp arg-exps)
      `(,fun-exp ,@arg-exps)))

(define syncase:build-conditional
   (lambda (test-exp then-exp else-exp)
      `(if ,test-exp ,then-exp ,else-exp)))

(define syncase:build-lexical-reference (lambda (var) var))

(define syncase:build-lexical-assignment
   (lambda (var exp)
      `(set! ,var ,exp)))

(define syncase:build-global-reference (lambda (var) var))

(define syncase:build-global-assignment
   (lambda (var exp)
      `(set! ,var ,exp)))

(define syncase:build-lambda
   (lambda (vars exp)
      `(lambda ,vars ,exp)))

(define syncase:build-improper-lambda
   (lambda (vars var exp)
      `(lambda (,@vars . ,var) ,exp)))

(define syncase:build-data
   (lambda (exp)
      `(quote ,exp)))

(define syncase:build-identifier
   (lambda (id)
      `(quote ,id)))

(define syncase:build-sequence
   (lambda (exps)
      (if (null? (cdr exps))
          (car exps)
          `(begin ,(car exps) ,(syncase:build-sequence (cdr exps))))))

(define syncase:build-letrec
   (lambda (vars val-exps body-exp)
      (if (null? vars)
          body-exp
          `(letrec ,(map list vars val-exps) ,body-exp))))

(define syncase:build-global-definition
   (lambda (var val)
      `(define ,var ,val)))
