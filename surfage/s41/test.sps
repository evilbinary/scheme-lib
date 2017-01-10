; #!/usr/bin/env scheme-script

; Copyright (C) 2007 by Philip L. Bewig of Saint Louis, Missouri, USA.
; All rights reserved.  Permission is hereby granted, free of charge,
; to any person obtaining a copy of
; this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without
; limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject
; to the following conditions: The above copyright notice and this
; permission notice shall be included in all copies or substantial
; portions of the Software.  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
; WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
; TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
; OR OTHER DEALINGS IN THE SOFTWARE.

(import (surfage s41 streams)
        (except (rnrs) assert)
        (rnrs r5rs))

(define (add1 n) (+ n 1))

(define (lsec proc . args)
  (lambda x (apply proc (append args x))))

(define (rsec proc . args)
  (lambda x (apply proc (reverse (append (reverse args) (reverse x))))))

(define-stream (qsort lt? strm)
  (if (stream-null? strm)
      stream-null
      (let ((x (stream-car strm))
            (xs (stream-cdr strm)))
        (stream-append
          (qsort lt?
            (stream-filter
              (lambda (u) (lt? u x))
              xs))
          (stream x)
          (qsort lt?
            (stream-filter
              (lambda (u) (not (lt? u x)))
              xs))))))

(define-stream (isort lt? strm)
    (define-stream (insert strm x)
      (stream-match strm
        (() (stream x))
        ((y . ys)
          (if (lt? y x)
              (stream-cons y (insert ys x))
              (stream-cons x strm)))))
    (stream-fold insert stream-null strm))

(define-stream (stream-merge lt? . strms)
  (define-stream (merge xx yy)
    (stream-match xx (() yy) ((x . xs)
      (stream-match yy (() xx) ((y . ys)
        (if (lt? y x)
            (stream-cons y (merge xx ys))
            (stream-cons x (merge xs yy))))))))
  (stream-let loop ((strms strms))
    (cond ((null? strms) stream-null)
          ((null? (cdr strms)) (car strms))
          (else (merge (car strms)
                       (apply stream-merge lt?
                         (cdr strms)))))))

(define-stream (msort lt? strm)
  (let* ((n (quotient (stream-length strm) 2))
         (ts (stream-take n strm))
         (ds (stream-drop n strm)))
    (if (zero? n)
        strm
        (stream-merge lt?
          (msort < ts) (msort < ds)))))

(define-stream (stream-unique eql? strm)
  (if (stream-null? strm)
      stream-null
      (stream-cons (stream-car strm)
        (stream-unique eql?
          (stream-drop-while
            (lambda (x)
              (eql? (stream-car strm) x))
            strm)))))

(define nats
  (stream-cons 0
    (stream-map add1 nats)))

(define hamming
  (stream-unique =
    (stream-cons 1
      (stream-merge <
        (stream-map (lsec * 2) hamming)
        (stream-merge <
          (stream-map (lsec * 3) hamming)
          (stream-map (lsec * 5) hamming))))))

(define primes (let ()
  (define-stream (next base mult strm)
    (let ((first (stream-car strm))
          (rest (stream-cdr strm)))
      (cond ((< first mult)
              (stream-cons first
                (next base mult rest)))
            ((< mult first)
              (next base (+ base mult) strm))
            (else (next base
                    (+ base mult) rest)))))
  (define-stream (sift base strm)
    (next base (+ base base) strm))
  (define-stream (sieve strm)
    (let ((first (stream-car strm))
          (rest (stream-cdr strm)))
      (stream-cons first
        (sieve (sift first rest)))))
  (sieve (stream-from 2))))

(define (handle-assertion thunk expr result)
  (cond
    [(string? result) 
     ;;; error case
     (call/cc
       (lambda (k) 
         ;;; ignoring result string
         (with-exception-handler k thunk)
         (error 'test "did not fail" expr)))]
    [else
     (unless (equal? result (thunk)) 
       (error 'test "failed" expr))]))

(define-syntax assert
  (syntax-rules ()
    [(_ expr result) 
     (handle-assertion (lambda () expr) 'expr result)]))

(define (unit-test)
  
  (define strm123 (stream 1 2 3))

  ; stream-null
  (assert (stream? stream-null) #t)
  (assert (stream-null? stream-null) #t)
  (assert (stream-pair? stream-null) #f)
  
  ; stream-cons
  (assert (stream? (stream-cons 1 stream-null)) #t)
  (assert (stream-null? (stream-cons 1 stream-null)) #f)
  (assert (stream-pair? (stream-cons 1 stream-null)) #t)
  
  ; stream?
  (assert (stream? stream-null) #t)
  (assert (stream? (stream-cons 1 stream-null)) #t)
  (assert (stream? "four") #f)
  
  ; stream-null?
  (assert (stream-null? stream-null) #t)
  (assert (stream-null? (stream-cons 1 stream-null)) #f)
  (assert (stream-null? "four") #f)
  
  ; stream-pair?
  (assert (stream-pair? stream-null) #f)
  (assert (stream-pair? (stream-cons 1 stream-null)) #t)
  (assert (stream-pair? "four") #f)
  
  ; stream-car
  (assert (stream-car "four") "stream-car: non-stream")
  (assert (stream-car stream-null) "stream-car: null stream")
  (assert (stream-car strm123) 1)
  
  ; stream-cdr
  (assert (stream-cdr "four") "stream-cdr: non-stream")
  (assert (stream-cdr stream-null) "stream-cdr: null stream")
  (assert (stream-car (stream-cdr strm123)) 2)
  
  ; stream-lambda
  (assert
    (stream->list
      (letrec ((double
        (stream-lambda (strm)
          (if (stream-null? strm)
              stream-null
              (stream-cons
                (* 2 (stream-car strm))
                (double (stream-cdr strm)))))))
        (double strm123)))
    '(2 4 6))
  
  ; define-stream
  (assert
    (stream->list
      (let ()
        (define-stream (double strm)
          (if (stream-null? strm)
              stream-null
              (stream-cons
                (* 2 (stream-car strm))
                (double (stream-cdr strm)))))
        (double strm123)))
    '(2 4 6))
  
  ; list->stream
  (assert (list->stream "four") "list->stream: non-list argument")
  (assert (stream->list (list->stream '())) '())
  (assert (stream->list (list->stream '(1 2 3))) '(1 2 3))
  
  ; port->stream
  ;; (let* ((p (open-input-file "streams.ss"))
  ;;        (s (port->stream p)))
  ;;   (assert (port->stream "four") "port->stream: non-input-port argument")
  ;;   (assert (string=? (list->string (stream->list 11 s)) "; Copyright") #t)
  ;;   (close-input-port p))

  ; stream
  (assert (stream->list (stream)) '())
  (assert (stream->list (stream 1)) '(1))
  (assert (stream->list (stream 1 2 3)) '(1 2 3))
  
  ; stream->list
  (assert (stream->list '()) "stream->list: non-stream argument")
  (assert (stream->list "four" strm123) "stream->list: non-integer count")
  (assert (stream->list -1 strm123) "stream->list: negative count")
  (assert (stream->list (stream)) '())
  (assert (stream->list strm123) '(1 2 3))
  (assert (stream->list 5 strm123) '(1 2 3))
  (assert (stream->list 3 (stream-from 1)) '(1 2 3))
  
  ; stream-append
  (assert (stream-append "four") "stream-append: non-stream argument")
  (assert (stream->list (stream-append strm123)) '(1 2 3))
  (assert (stream->list (stream-append strm123 strm123)) '(1 2 3 1 2 3))
  (assert (stream->list (stream-append strm123 strm123 strm123)) '(1 2 3 1 2 3 1 2 3))
  (assert (stream->list (stream-append strm123 stream-null)) '(1 2 3))
  (assert (stream->list (stream-append stream-null strm123)) '(1 2 3))
  
  ; stream-concat
  (assert (stream-concat "four") "stream-concat: non-stream argument")
  (assert (stream->list (stream-concat (stream strm123))) '(1 2 3))
  (assert (stream->list (stream-concat (stream strm123 strm123))) '(1 2 3 1 2 3))
  
  ; stream-constant
  (assert (stream-ref (stream-constant 1) 100) 1)
  (assert (stream-ref (stream-constant 1 2) 100) 1)
  (assert (stream-ref (stream-constant 1 2 3) 3) 1)
  
  ; stream-drop
  (assert (stream-drop "four" strm123) "stream-drop: non-integer argument")
  (assert (stream-drop -1 strm123) "stream-drop: negative argument")
  (assert (stream-drop 2 "four") "stream-drop: non-stream argument")
  (assert (stream->list (stream-drop 0 stream-null)) '())
  (assert (stream->list (stream-drop 0 strm123)) '(1 2 3))
  (assert (stream->list (stream-drop 1 strm123)) '(2 3))
  (assert (stream->list (stream-drop 5 strm123)) '())
  
  ; stream-drop-while
  (assert (stream-drop-while "four" strm123) "stream-drop-while: non-procedural argument")
  (assert (stream-drop-while odd? "four") "stream-drop-while: non-stream argument")
  (assert (stream->list (stream-drop-while odd? stream-null)) '())
  (assert (stream->list (stream-drop-while odd? strm123)) '(2 3))
  (assert (stream->list (stream-drop-while even? strm123)) '(1 2 3))
  (assert (stream->list (stream-drop-while positive? strm123)) '())
  (assert (stream->list (stream-drop-while negative? strm123)) '(1 2 3))
  
  ; stream-filter
  (assert (stream-filter "four" strm123) "stream-filter: non-procedural argument")
  (assert (stream-filter odd? '()) "stream-filter: non-stream argument")
  (assert (stream-null? (stream-filter odd? (stream))) #t)
  (assert (stream->list (stream-filter odd? strm123)) '(1 3))
  (assert (stream->list (stream-filter even? strm123)) '(2))
  (assert (stream->list (stream-filter positive? strm123)) '(1 2 3))
  (assert (stream->list (stream-filter negative? strm123)) '())
  (let loop ((n 10))
    (assert (odd? (stream-ref (stream-filter odd? (stream-from 0)) n)) #t)
    (if (positive? n) (loop (- n 1))))
  (let loop ((n 10))
    (assert (even? (stream-ref (stream-filter odd? (stream-from 0)) n)) #f)
    (if (positive? n) (loop (- n 1))))
  
  ; stream-fold
  (assert (stream-fold "four" 0 strm123) "stream-fold: non-procedural argument")
  (assert (stream-fold + 0 '()) "stream-fold: non-stream argument")
  (assert (stream-fold + 0 strm123) 6)
  
  ; stream-for-each
  (assert (stream-for-each "four" strm123) "stream-for-each: non-procedural argument")
  (assert (stream-for-each display) "stream-for-each: no stream arguments")
  (assert (stream-for-each display "four") "stream-for-each: non-stream argument")
  (assert (let ((sum 0)) (stream-for-each (lambda (x) (set! sum (+ sum x))) strm123) sum) 6)

  ; stream-from
  (assert (stream-from "four") "stream-from: non-numeric starting number")
  (assert (stream-from 1 "four") "stream-from: non-numeric step size")
  (assert (stream-ref (stream-from 0) 100) 100)
  (assert (stream-ref (stream-from 1 2) 100) 201)
  (assert (stream-ref (stream-from 0 -1) 100) -100)
  
  ; stream-iterate
  (assert (stream-iterate "four" 0) "stream-iterate: non-procedural argument")
  
  (assert (stream->list 3 (stream-iterate (lsec + 1) 1)) '(1 2 3))
  
  ; stream-length
  (assert (stream-length "four") "stream-length: non-stream argument")
  (assert (stream-length (stream)) 0)
  (assert (stream-length strm123) 3)
  
  ; stream-let
  (assert (stream->list
            (stream-let loop ((strm strm123))
              (if (stream-null? strm)
                  stream-null
                  (stream-cons
                    (* 2 (stream-car strm))
                    (loop (stream-cdr strm))))))
          '(2 4 6))
  
  ; stream-map
  (assert (stream-map "four" strm123) "stream-map: non-procedural argument")
  (assert (stream-map odd?) "stream-map: no stream arguments")
  (assert (stream-map odd? "four") "stream-map: non-stream argument")
  (assert (stream->list (stream-map - strm123)) '(-1 -2 -3))
  (assert (stream->list (stream-map + strm123 strm123)) '(2 4 6))
  (assert (stream->list (stream-map + strm123 (stream-from 1))) '(2 4 6))
  (assert (stream->list (stream-map + (stream-from 1) strm123)) '(2 4 6))
  (assert (stream->list (stream-map + strm123 strm123 strm123)) '(3 6 9))
  
  ; stream-match
  (assert (stream-match '(1 2 3) (_ 'ok)) "stream-match: non-stream argument")
  (assert (stream-match strm123 (() 42)) "stream-match: pattern failure")
  (assert (stream-match stream-null (() 'ok)) 'ok)
  (assert (stream-match strm123 (() 'no) (else 'ok)) 'ok)
  (assert (stream-match (stream 1) (() 'no) ((a) a)) 1)
  (assert (stream-match (stream 1) (() 'no) ((_) 'ok)) 'ok)
  (assert (stream-match strm123 ((a b c) (list a b c))) '(1 2 3))
  (assert (stream-match strm123 ((a . _) a)) 1)
  (assert (stream-match strm123 ((a b . _) (list a b))) '(1 2))
  (assert (stream-match strm123 ((a b . c) (list a b (stream-car c)))) '(1 2 3))
  (assert (stream-match strm123 (s (stream->list s))) '(1 2 3))
  (assert (stream-match strm123 ((a . _) (= a 1) 'ok)) 'ok)
  (assert (stream-match strm123 ((a . _) (= a 2) 'yes) (_ 'no)) 'no)
  (assert (stream-match strm123 ((a b c) (= a b) 'yes) (_ 'no)) 'no)
  (assert (stream-match (stream 1 1 2) ((a b c) (= a b) 'yes) (_ 'no)) 'yes)
  
  ; stream-of
  (assert (stream->list
            (stream-of (+ y 6)
              (x in (stream-range 1 6))
              (odd? x)
              (y is (* x x)))) '(7 15 31))
  (assert (stream->list
            (stream-of (* x y)
              (x in (stream-range 1 4))
              (y in (stream-range 1 5))))
          '(1 2 3 4 2 4 6 8 3 6 9 12))
  (assert (stream-car (stream-of 1)) 1)

  ; stream-range
  (assert (stream-range "four" 0) "stream-range: non-numeric starting number")
  (assert (stream-range 0 "four") "stream-range: non-numeric ending number")
  (assert (stream-range 1 2 "three") "stream-range: non-numeric step size")
  (assert (stream->list (stream-range 0 5)) '(0 1 2 3 4))
  (assert (stream->list (stream-range 5 0)) '(5 4 3 2 1))
  (assert (stream->list (stream-range 0 5 2)) '(0 2 4))
  (assert (stream->list (stream-range 5 0 -2)) '(5 3 1))
  (assert (stream->list (stream-range 0 1 -1)) '())
  
  ; stream-ref
  (assert (stream-ref '() 4) "stream-ref: non-stream argument")
  (assert (stream-ref nats 3.5) "stream-ref: non-integer argument")
  (assert (stream-ref nats -3) "stream-ref: negative argument")
  (assert (stream-ref strm123 5) "stream-ref: beyond end of stream")
  (assert (stream-ref strm123 0) 1)
  (assert (stream-ref strm123 1) 2)
  (assert (stream-ref strm123 2) 3)
  
  ; stream-reverse
  (assert (stream-reverse '()) "stream-reverse: non-stream argument")
  (assert (stream->list (stream-reverse (stream))) '())
  (assert (stream->list (stream-reverse strm123)) '(3 2 1))
  
  ; stream-scan
  (assert (stream-scan "four" 0 strm123) "stream-scan: non-procedural argument")
  (assert (stream-scan + 0 '()) "stream-scan: non-stream argument")
  (assert (stream->list (stream-scan + 0 strm123)) '(0 1 3 6))
  
  ; stream-take
  (assert (stream-take 5 "four") "stream-take: non-stream argument")
  (assert (stream-take "four" strm123) "stream-take: non-integer argument")
  (assert (stream-take -4 strm123) "stream-take: negative argument")
  (assert (stream->list (stream-take 5 stream-null)) '())
  (assert (stream->list (stream-take 0 stream-null)) '())
  (assert (stream->list (stream-take 0 strm123)) '())
  (assert (stream->list (stream-take 2 strm123)) '(1 2))
  (assert (stream->list (stream-take 3 strm123)) '(1 2 3))
  (assert (stream->list (stream-take 5 strm123)) '(1 2 3))
  
  ; stream-take-while
  (assert (stream-take-while odd? "four") "stream-take-while: non-stream argument")
  (assert (stream-take-while "four" strm123) "stream-take-while: non-procedural argument")
  (assert (stream->list (stream-take-while odd? strm123)) '(1))
  (assert (stream->list (stream-take-while even? strm123)) '())
  (assert (stream->list (stream-take-while positive? strm123)) '(1 2 3))
  (assert (stream->list (stream-take-while negative? strm123)) '())
  
  ; stream-unfold
  (assert (stream-unfold "four" odd? + 0) "stream-unfold: non-procedural mapper")
  (assert (stream-unfold + "four" + 0) "stream-unfold: non-procedural pred?")
  (assert (stream-unfold + odd? "four" 0) "stream-unfold: non-procedural generator")

  (assert (stream->list (stream-unfold (rsec expt 2) (rsec < 10) (rsec + 1) 0))
           '(0 1 4 9 16 25 36 49 64 81))
  
  ; stream-unfolds
  (assert
    (stream->list
      (stream-unfolds
        (lambda (x)
          (let ((n (car x)) (s (cdr x)))
            (if (zero? n)
                (values 'dummy '())
                (values
                  (cons (- n 1) (stream-cdr s))
                  (list (stream-car s))))))
        (cons 5 (stream-from 0))))
      '(0 1 2 3 4))
  
  ; stream-zip
  (assert (stream-zip) "stream-zip: no stream arguments")
  (assert (stream-zip "four") "stream-zip: non-stream argument")
  (assert (stream-zip strm123 "four") "stream-zip: non-stream argument")
  (assert (stream->list (stream-zip strm123 stream-null)) '())
  (assert (stream->list (stream-zip strm123)) '((1) (2) (3)))
  (assert (stream->list (stream-zip strm123 strm123)) '((1 1) (2 2) (3 3)))
  (assert (stream->list (stream-zip strm123 (stream-from 1))) '((1 1) (2 2) (3 3)))
  (assert (stream->list (stream-zip strm123 strm123 strm123)) '((1 1 1) (2 2 2) (3 3 3)))
  
  ; other tests

  (assert
    (stream-car
      (stream-reverse
        (stream-take-while
          (rsec < 1000)
          primes)))
    997)
  
  (assert
    (equal?
      (stream->list (qsort < (stream 3 1 5 2 4)))
      (stream->list (isort < (stream 2 5 1 4 3))))
    #t)
   
  (assert
    (equal?
      (stream->list (msort < (stream 3 1 5 2 4)))
      (stream->list (isort < (stream 2 5 1 4 3))))
    #t)
   
  ; http://www.research.att.com/~njas/sequences/A051037
  (assert (stream-ref hamming 999) 51200000)
  
)


(unit-test)