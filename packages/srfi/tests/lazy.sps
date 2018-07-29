#!r6rs
;; Copyright André van Tonder. All Rights Reserved.
;;
;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;; Modified by Andreas Rottmann to be an R6RS program.

(import (rnrs)
        (only (rnrs r5rs) modulo)
        (srfi :64 testing)
        (srfi :45 lazy))

(define-syntax test-output
  (syntax-rules ()
    ((_ expected proc)
     (test-equal expected
       (call-with-string-output-port proc)))))

(define-syntax test-leak
  (syntax-rules ()
    ((_ expr)
     (begin
       (display "Leak test, please watch memory consumption; press C-c when satisfied.\n")
       (guard (c (#t 'aborted))
         expr)))))

(test-begin "lazy-tests")

;=========================================================================
; TESTS AND BENCHMARKS:
;=========================================================================

;=========================================================================
; Memoization test 1:

(test-output "hello"
  (lambda (port)
    (define s (delay (begin (display 'hello port) 1)))
    (test-equal 1 (force s))
    (test-equal 1 (force s))))

;=========================================================================
; Memoization test 2:

(test-output "bonjour"
  (lambda (port)
    (let ((s (delay (begin (display 'bonjour port) 2))))
      (test-equal 4 (+ (force s) (force s))))))

;=========================================================================
; Memoization test 3: (pointed out by Alejandro Forero Cuervo) 

(test-output "hi"
  (lambda (port)
    (define r (delay (begin (display 'hi port) 1)))
    (define s (lazy r))
    (define t (lazy s))
    (test-equal 1 (force t))
    (test-equal 1 (force r))))

;=========================================================================
; Memoization test 4: Stream memoization

(define (stream-drop s index)
  (lazy
   (if (zero? index)
       s
       (stream-drop (cdr (force s)) (- index 1)))))

(define (ones port)
  (delay (begin
           (display 'ho port)
           (cons 1 (ones port)))))

(test-output "hohohohoho"
  (lambda (port)
    (define s (ones port))
    (test-equal 1
                (car (force (stream-drop s 4))))
    (test-equal 1
                (car (force (stream-drop s 4))))))

;=========================================================================
; Reentrancy test 1: from R5RS

(letrec ((count 0)
         (p (delay (begin (set! count (+ count 1))
                          (if (> count x)
                              count
                              (force p)))))
         (x 5))
  (test-equal 6 (force p))
  (set! x 10)
  (test-equal 6 (force p)))

;=========================================================================
; Reentrancy test 2: from SRFI 40

(letrec ((f (let ((first? #t))
              (delay
                (if first?
                    (begin
                      (set! first? #f)
                      (force f))
                    'second)))))
  (test-equal 'second (force f)))

;=========================================================================
; Reentrancy test 3: due to John Shutt

(let* ((q (let ((count 5))
            (define (get-count) count)
            (define p (delay (if (<= count 0)
                                 count
                                 (begin (set! count (- count 1))
                                        (force p)
                                        (set! count (+ count 2))
                                        count))))
            (list get-count p)))
       (get-count (car q))
       (p (cadr q)))

  (test-equal 5 (get-count))
  (test-equal 0 (force p))
  (test-equal 10 (get-count)))

;=========================================================================
; Test leaks:  All the leak tests should run in bounded space.

;=========================================================================
; Leak test 1: Infinite loop in bounded space.

(define (loop) (lazy (loop)))
(test-leak (force (loop)))   ;==> bounded space

;=========================================================================
; Leak test 2: Pending memos should not accumulate
;              in shared structures.

(let ()
  (define s (loop))
  (test-leak (force s)))     ;==> bounded space

;=========================================================================
; Leak test 3: Safely traversing infinite stream.

(define (from n)
  (delay (cons n (from (+ n 1)))))

(define (traverse s)
  (lazy (traverse (cdr (force s)))))

(test-leak (force (traverse (from 0))))         ;==> bounded space

;=========================================================================
; Leak test 4: Safely traversing infinite stream
;              while pointer to head of result exists.

(let ()
  (define s (traverse (from 0)))
  (test-leak (force s)))     ;==> bounded space

;=========================================================================
; Convenient list deconstructor used below.

(define-syntax match
  (syntax-rules ()
    ((match exp
       (()      exp1)
       ((h . t) exp2))
     (let ((lst exp))
       (cond ((null? lst) exp1)
             ((pair? lst) (let ((h (car lst))
                                (t (cdr lst)))
                            exp2))
             (else 'match-error))))))

;========================================================================
; Leak test 5: Naive stream-filter should run in bounded space.
;              Simplest case.

(define (stream-filter p? s)
  (lazy (match (force s)
          (()      (delay '()))
          ((h . t) (if (p? h)
                       (delay (cons h (stream-filter p? t)))
                       (stream-filter p? t))))))

(test-leak
 (force (stream-filter (lambda (n) (= n 10000000000))
                       (from 0))))                     ;==> bounded space

;========================================================================
; Leak test 6: Another long traversal should run in bounded space.

; The stream-ref procedure below does not strictly need to be lazy.
; It is defined lazy for the purpose of testing safe compostion of
; lazy procedures in the times3 benchmark below (previous
; candidate solutions had failed this).

(define (stream-ref s index)
  (lazy
   (match (force s)
     (()      'error)
     ((h . t) (if (zero? index)
                  (delay h)
                  (stream-ref t (- index 1)))))))

; Check that evenness is correctly implemented - should terminate:

(test-equal 0
  (force (stream-ref (stream-filter zero? (from 0))
                     0)))

(let ()
  (define s (stream-ref (from 0) 100000000))
  (test-equal 100000000 (force s)))     ;==> bounded space

;======================================================================
; Leak test 7: Infamous example from SRFI 40.

(define (times3 n)
  (stream-ref (stream-filter
               (lambda (x) (zero? (modulo x n)))
               (from 0))
              3))

(test-equal 21 (force (times3 7)))
(test-equal 300000000 (force (times3 100000000)))    ;==> bounded space

(test-end "lazy-tests")
