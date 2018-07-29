; Copyright (c) 2005 Sebastian Egner and Jens Axel S{\o}gaard.
; 
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; ``Software''), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED ``AS IS'', WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; 
; -----------------------------------------------------------------------
;
; Compare procedures SRFI (confidence tests)
; Sebastian.Egner@philips.com, Jensaxel@soegaard.net, 2005
;
; history of this file:
;   SE, 14-Oct-2004: first version
;   ..
;   SE, 28-Feb-2005: adapted to make it one-source PLT,S48,Chicken
;   JS, 01-Mar-2005: first version
;   SE, 18-Apr-2005: added (<? [c] [x y]) and (</<? [c] [x y z])
;   SE, 13-May-2005: included examples for <? etc.
;   SE, 16-May-2005: naming convention changed; compare-by< optional x y
;
; This program runs some examples on 'compare.scm'.
; It has been tested under 
;   * PLT 208p1
;   * Scheme 48 1.1
;   * Chicken 1.70.

; Portability workarounds
; =======================
;
; The purpose of these procedures is to push the examples
; through a Scheme system with severe limitations. It is
; not the intention to supply the functionality.

; poor man's complex
(define (pm-complex? z)             (or (real? z) (and (pair? z) (eq? (car z) 'complex))))
(define (pm-number? z)              (or (real? z) (pm-complex? z)))
(define (pm-make-rectangular re im) (list 'complex re im))
(define (pm-real-part z)            (if (pm-complex? z) (cadr z) z))
(define (pm-imag-part z)            (if (pm-complex? z) (caddr z) z))

; apply on truncated argument list
(define (make-apply limit)
  (let ((original-apply apply))
    (lambda (f . xs)
      (let ((args (let loop ((xs xs) (rev-args '()))
                    (cond
                      ((null? xs)
                       (reverse rev-args))
                      ((null? (cdr xs))
                       (append (reverse rev-args) (car xs)))
                      (else
                       (loop (cdr xs) (cons (car xs) rev-args)))))))
        (if (<= (length args) limit)
            (original-apply f args)
            (original-apply
             f
             (begin (display "*** warning: truncated apply")
                    (newline)
                    (let truncate ((n 0) (rev-args '()) (xs args))
                      (if (= n limit)
                          (reverse rev-args)
                          (truncate (+ n 1) (cons (car xs) rev-args) (cdr xs)))))))))))

; =============================================================================

; Running the examples in PLT (DrScheme)
; ======================================
;
; 1. Uncomment the following lines:
;
;plt (require 
;plt    (lib "16.ss" "srfi") ; case-lambda
;plt    (lib "23.ss" "srfi") ; error
;plt    (lib "27.ss" "srfi") ; random-integer
;plt    (lib "42.ss" "srfi") ; eager comprehensions list-ec etc.
;plt    (lib "pretty.ss"))   ; pretty-print
;plt (define pretty-write pretty-print)
;plt (load "compare.scm")
;
; 2. Run this file.

; Running the examples in Scheme-48
; =================================
;
; 1. Invoke scheme48 with sufficient heap size (-h <words>).
; 2. Paste this into the REPL:
;      ,open srfi-16 srfi-23 srfi-27 srfi-42 pp
;      (define pretty-write p)
;      ,load compare.scm examples.scm

; Running the examples in the Chicken Scheme Interpreter
; ======================================================
;
; 1. Fetch and install the srfi-42 egg from the Chicken homepage
; 2. Uncomment the following lines:
;      (require-extension srfi-23)
;      (define random-integer random)
;      (require-extension srfi-42)
;      (define pretty-write display)
;      (define complex? pm-complex?)
;      (define number? pm-number?)
;      (define make-rectangular pm-make-rectangular)
;      (define real-part pm-real-part)
;      (define imag-part pm-imag-part)
;      (define apply (make-apply 126)) ; Grrr...
;      (load "compare.scm")
; 3. Invoke csi with:
;      csi -syntax examples.scm
;        
; Note: Chicken doesn't have complex numbers and has a
;       severe limit on the number of arguments for apply.

; =============================================================================

; Test engine
; ===========
;
; We use an extended version of the the checker of SRFI-42 (with
; Felix' reduction on codesize) for running a batch of tests for
; the various procedures of 'compare.scm'. Moreover, we use the
; comprehensions of SRFI-42 to generate examples systematically.

(define my-equal?       equal?)
(define my-pretty-write pretty-write)

(define my-check-correct 0)
(define my-check-wrong   0)

(define (my-check-reset)
  (set! my-check-correct 0)
  (set! my-check-wrong   0))

; (my-check expr => desired-result)
;   evaluates expr and compares the value with desired-result.

(define-syntax my-check
  (syntax-rules (=>)
    ((my-check expr => desired-result)
     (my-check-proc 'expr (lambda () expr) desired-result))))

(define (my-check-proc expr thunk desired-result)
  (newline)
  (my-pretty-write expr)
  (display "  => ")
  (let ((actual-result (thunk)))
    (write actual-result)
    (if (my-equal? actual-result desired-result)
        (begin
          (display " ; correct")
          (set! my-check-correct (+ my-check-correct 1)) )
        (begin
          (display " ; *** wrong ***, desired result:")
          (newline)
          (display "  => ")
          (write desired-result)
          (set! my-check-wrong (+ my-check-wrong 1))))
    (newline)))

; (my-check-ec <qualifier>* <ok?> <expr>)
;    runs (every?-ec <qualifier>* <ok?>), counting the times <ok?>
;    is evaluated as a correct example, and stopping at the first
;    counter example for which <expr> provides the argument.

(define-syntax my-check-ec
  (syntax-rules (nested)
    ((my-check-ec (nested q1 ...) q etc1 etc2 etc ...)
     (my-check-ec (nested q1 ... q) etc1 etc2 etc ...))
    ((my-check-ec q1 q2             etc1 etc2 etc ...)
     (my-check-ec (nested q1 q2)    etc1 etc2 etc ...))
    ((my-check-ec ok? expr)
     (my-check-ec (nested) ok? expr))
    ((my-check-ec (nested q ...) ok? expr)
     (my-check-ec-proc
      '(every?-ec q ... ok?)
      (lambda ()
        (first-ec 
         'ok
         (nested q ...)
         (:let ok ok?)
         (begin 
           (if ok
               (set! my-check-correct (+ my-check-correct 1))
               (set! my-check-wrong   (+ my-check-wrong   1))))
         (if (not ok))
         (list expr)))
      'expr))
    ((my-check-ec q ok? expr)
     (my-check-ec (nested q) ok? expr))))

(define (my-check-ec-proc expr thunk arg-counter-example)
  (let ((my-check-correct-save my-check-correct))
    (newline)
    (my-pretty-write expr)
    (display "  => ")
    (let ((result (thunk)))
      (if (eqv? result 'ok)
          (begin 
            (display "#t ; correct (")
            (write (- my-check-correct my-check-correct-save))
            (display " examples)")
            (newline))
          (begin
            (display "#f ; *** wrong *** (after ")
            (write (- my-check-correct my-check-correct-save))               
            (display " correct examples).")
            (newline)
            (display "        ; Argument of the first counter example:")
            (newline)
            (display "        ;   ")
            (write arg-counter-example)
            (display " = ")
            (write (car result)))))))

(define (my-check-summary)
  (begin
    (newline)
    (newline)
    (display "*** correct examples: ")
    (display my-check-correct)
    (newline)
    (display "*** wrong examples:   ")
    (display my-check-wrong)
    (newline)
    (newline)))

; =============================================================================

; Abstractions etc.
; =================

(define ci integer-compare) ; very frequently used

; (result-ok? actual desired)
;   tests if actual and desired specify the same ordering.

(define (result-ok? actual desired)
  (eqv? actual desired))

; (my-check-compare compare increasing-elements)
;    evaluates (compare x y) for x, y in increasing-elements
;    and checks the result against -1, 0, or 1 depending on
;    the position of x and y in the list increasing-elements.

(define-syntax my-check-compare
  (syntax-rules ()
    ((my-check-compare compare increasing-elements)
     (my-check-ec
      (:list x (index ix) increasing-elements)
      (:list y (index iy) increasing-elements)
      (result-ok? (compare x y) (ci ix iy))
      (list x y)))))

; sorted lists

(define my-booleans   '(#f #t))
(define my-chars      '(#\a #\b #\c))
(define my-chars-ci   '(#\a #\B #\c #\D))
(define my-strings    '("" "a" "aa" "ab" "b" "ba" "bb"))
(define my-strings-ci '("" "a" "aA" "Ab" "B" "bA" "BB"))
(define my-symbols    '(a aa ab b ba bb))

(define my-reals
  (append-ec (:range xn -6 7) 
             (:let x (/ xn 3))
             (list x (+ x (exact->inexact (/ 1 100))))))

(define my-rationals
  (list-ec (:list x my-reals)
           (and (exact? x) (rational? x))
           x))

(define my-integers
  (list-ec (:list x my-reals)
           (if (and (exact? x) (integer? x)))
           x))

(define my-complexes
  (list-ec (:list re-x my-reals)
           (if (inexact? re-x))
           (:list im-x my-reals)
           (if (inexact? im-x))
           (make-rectangular re-x im-x)))

(define my-lists
  '(() (1) (1 1) (1 2) (2) (2 1) (2 2)))

(define my-vector-as-lists
  (map list->vector my-lists))

(define my-list-as-vectors
  '(() (1) (2) (1 1) (1 2) (2 1) (2 2)))

(define my-vectors
  (map list->vector my-list-as-vectors))

(define my-null-or-pairs 
  '(()
    (1) (1 1) (1 2) (1 . 1) (1 . 2) 
    (2) (2 1) (2 2) (2 . 1) (2 . 2)))

(define my-objects
  (append my-null-or-pairs
          my-booleans
          my-chars
          my-strings
          my-symbols
          my-integers
          my-vectors))

; =============================================================================

; The checks
; ==========

(define (check:if3)
  
  ; basic functionality
  
  (my-check (if3 -1 'n 'z 'p) => 'n)
  (my-check (if3  0 'n 'z 'p) => 'z)
  (my-check (if3  1 'n 'z 'p) => 'p)
  
  ; check arguments are evaluated only once
  
  (my-check 
   (let ((x -1))
     (if3 (let ((x0 x)) (set! x (+ x 1)) x0) 'n 'z 'p))
   => 'n)
  
  (my-check 
   (let ((x -1) (y 0)) 
     (if3 (let ((x0 x)) (set! x (+ x 1)) x0)
          (begin (set! y (+ y 1))   y)
          (begin (set! y (+ y 10))  y)
          (begin (set! y (+ y 100)) y)))
   => 1)
  
  (my-check 
   (let ((x 0) (y 0)) 
     (if3 (let ((x0 x)) (set! x (+ x 1)) x0)
          (begin (set! y (+ y 1))   y)
          (begin (set! y (+ y 10))  y)
          (begin (set! y (+ y 100)) y)))
   => 10)
  
  (my-check 
   (let ((x 1) (y 0)) 
     (if3 (let ((x0 x)) (set! x (+ x 1)) x0)
          (begin (set! y (+ y 1))   y)
          (begin (set! y (+ y 10))  y)
          (begin (set! y (+ y 100)) y)))
   => 100)
  
  ) ; check:if3

(define-syntax my-check-if2
  (syntax-rules ()
    ((my-check-if2 if-rel? rel)
     (begin
       ; check result
       (my-check (if-rel? -1 'yes 'no) => (if (rel -1 0) 'yes 'no))
       (my-check (if-rel?  0 'yes 'no) => (if (rel  0 0) 'yes 'no))
       (my-check (if-rel?  1 'yes 'no) => (if (rel  1 0) 'yes 'no))
       
       ; check result of 'laterally challenged if'
       (my-check (let ((x #f)) (if-rel? -1 (set! x #t)) x) => (rel -1 0))
       (my-check (let ((x #f)) (if-rel?  0 (set! x #t)) x) => (rel  0 0))
       (my-check (let ((x #f)) (if-rel?  1 (set! x #t)) x) => (rel  1 0))
       
       ; check that <c> is evaluated exactly once
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1)) -1) #t #f) n) => 1)
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1))  0) #t #f) n) => 1)
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1))  1) #t #f) n) => 1)
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1)) -1) #t) n) => 1)
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1))  0) #t) n) => 1)
       (my-check (let ((n 0)) (if-rel? (begin (set! n (+ n 1))  1) #t) n) => 1)
       ))))

(define (check:ifs)
  
  (my-check-if2 if=?     =)
  (my-check-if2 if<?     <)
  (my-check-if2 if>?     >)
  (my-check-if2 if<=?    <=)
  (my-check-if2 if>=?    >=)
  (my-check-if2 if-not=? (lambda (x y) (not (= x y))))
  
  ) ; check:if2

; <? etc. macros

(define-syntax my-check-chain2
  (syntax-rules ()
    ((my-check-chain2 rel? rel)
     (begin
       ; all chains of length 2
       (my-check (rel? ci 0 0) => (rel 0 0))
       (my-check (rel? ci 0 1) => (rel 0 1))
       (my-check (rel? ci 1 0) => (rel 1 0))
       
       ; using default-compare
       (my-check (rel? 0 0) => (rel 0 0))
       (my-check (rel? 0 1) => (rel 0 1))
       (my-check (rel? 1 0) => (rel 1 0))

       ; as a combinator
       (my-check ((rel? ci) 0 0) => (rel 0 0))
       (my-check ((rel? ci) 0 1) => (rel 0 1))
       (my-check ((rel? ci) 1 0) => (rel 1 0))

       ; using default-compare as a combinator
       (my-check ((rel?) 0 0) => (rel 0 0))
       (my-check ((rel?) 0 1) => (rel 0 1))
       (my-check ((rel?) 1 0) => (rel 1 0))
       ))))

(define (list->set xs) ; xs a list of integers
  (if (null? xs)
      '()
      (let ((max-xs
             (let max-without-apply ((m 1) (xs xs))
               (if (null? xs)
                   m
                   (max-without-apply (max m (car xs)) (cdr xs))))))
        (let ((in-xs? (make-vector (+ max-xs 1) #f)))
          (do-ec (:list x xs) (vector-set! in-xs? x #t))
          (list-ec (:vector in? (index x) in-xs?)
                   (if in?)
                   x)))))

(define-syntax arguments-used ; set of arguments (integer, >=0) used in compare
  (syntax-rules ()
    ((arguments-used (rel1/rel2 compare arg ...))
     (let ((used '()))
       (rel1/rel2 (lambda (x y)
                    (set! used (cons x (cons y used)))
                    (compare x y))
                  arg ...)
       (list->set used)))))

(define-syntax my-check-chain3
  (syntax-rules ()
    ((my-check-chain3 rel1/rel2? rel1 rel2)
     (begin     
       ; all chains of length 3
       (my-check (rel1/rel2? ci 0 0 0) => (and (rel1 0 0) (rel2 0 0)))
       (my-check (rel1/rel2? ci 0 0 1) => (and (rel1 0 0) (rel2 0 1)))
       (my-check (rel1/rel2? ci 0 1 0) => (and (rel1 0 1) (rel2 1 0)))
       (my-check (rel1/rel2? ci 1 0 0) => (and (rel1 1 0) (rel2 0 0)))
       (my-check (rel1/rel2? ci 1 1 0) => (and (rel1 1 1) (rel2 1 0)))
       (my-check (rel1/rel2? ci 1 0 1) => (and (rel1 1 0) (rel2 0 1)))
       (my-check (rel1/rel2? ci 0 1 1) => (and (rel1 0 1) (rel2 1 1)))
       (my-check (rel1/rel2? ci 0 1 2) => (and (rel1 0 1) (rel2 1 2)))
       (my-check (rel1/rel2? ci 0 2 1) => (and (rel1 0 2) (rel2 2 1)))
       (my-check (rel1/rel2? ci 1 2 0) => (and (rel1 1 2) (rel2 2 0)))
       (my-check (rel1/rel2? ci 1 0 2) => (and (rel1 1 0) (rel2 0 2)))
       (my-check (rel1/rel2? ci 2 0 1) => (and (rel1 2 0) (rel2 0 1)))
       (my-check (rel1/rel2? ci 2 1 0) => (and (rel1 2 1) (rel2 1 0)))
       
       ; using default-compare
       (my-check (rel1/rel2? 0 0 0) => (and (rel1 0 0) (rel2 0 0)))
       (my-check (rel1/rel2? 0 0 1) => (and (rel1 0 0) (rel2 0 1)))
       (my-check (rel1/rel2? 0 1 0) => (and (rel1 0 1) (rel2 1 0)))
       (my-check (rel1/rel2? 1 0 0) => (and (rel1 1 0) (rel2 0 0)))
       (my-check (rel1/rel2? 1 1 0) => (and (rel1 1 1) (rel2 1 0)))
       (my-check (rel1/rel2? 1 0 1) => (and (rel1 1 0) (rel2 0 1)))
       (my-check (rel1/rel2? 0 1 1) => (and (rel1 0 1) (rel2 1 1)))
       (my-check (rel1/rel2? 0 1 2) => (and (rel1 0 1) (rel2 1 2)))
       (my-check (rel1/rel2? 0 2 1) => (and (rel1 0 2) (rel2 2 1)))
       (my-check (rel1/rel2? 1 2 0) => (and (rel1 1 2) (rel2 2 0)))
       (my-check (rel1/rel2? 1 0 2) => (and (rel1 1 0) (rel2 0 2)))
       (my-check (rel1/rel2? 2 0 1) => (and (rel1 2 0) (rel2 0 1)))
       (my-check (rel1/rel2? 2 1 0) => (and (rel1 2 1) (rel2 1 0)))
       
       ; as a combinator
       (my-check ((rel1/rel2? ci) 0 0 0) => (and (rel1 0 0) (rel2 0 0)))
       (my-check ((rel1/rel2? ci) 0 0 1) => (and (rel1 0 0) (rel2 0 1)))
       (my-check ((rel1/rel2? ci) 0 1 0) => (and (rel1 0 1) (rel2 1 0)))
       (my-check ((rel1/rel2? ci) 1 0 0) => (and (rel1 1 0) (rel2 0 0)))
       (my-check ((rel1/rel2? ci) 1 1 0) => (and (rel1 1 1) (rel2 1 0)))
       (my-check ((rel1/rel2? ci) 1 0 1) => (and (rel1 1 0) (rel2 0 1)))
       (my-check ((rel1/rel2? ci) 0 1 1) => (and (rel1 0 1) (rel2 1 1)))
       (my-check ((rel1/rel2? ci) 0 1 2) => (and (rel1 0 1) (rel2 1 2)))
       (my-check ((rel1/rel2? ci) 0 2 1) => (and (rel1 0 2) (rel2 2 1)))
       (my-check ((rel1/rel2? ci) 1 2 0) => (and (rel1 1 2) (rel2 2 0)))
       (my-check ((rel1/rel2? ci) 1 0 2) => (and (rel1 1 0) (rel2 0 2)))
       (my-check ((rel1/rel2? ci) 2 0 1) => (and (rel1 2 0) (rel2 0 1)))
       (my-check ((rel1/rel2? ci) 2 1 0) => (and (rel1 2 1) (rel2 1 0)))

       ; as a combinator using default-compare
       (my-check ((rel1/rel2?) 0 0 0) => (and (rel1 0 0) (rel2 0 0)))
       (my-check ((rel1/rel2?) 0 0 1) => (and (rel1 0 0) (rel2 0 1)))
       (my-check ((rel1/rel2?) 0 1 0) => (and (rel1 0 1) (rel2 1 0)))
       (my-check ((rel1/rel2?) 1 0 0) => (and (rel1 1 0) (rel2 0 0)))
       (my-check ((rel1/rel2?) 1 1 0) => (and (rel1 1 1) (rel2 1 0)))
       (my-check ((rel1/rel2?) 1 0 1) => (and (rel1 1 0) (rel2 0 1)))
       (my-check ((rel1/rel2?) 0 1 1) => (and (rel1 0 1) (rel2 1 1)))
       (my-check ((rel1/rel2?) 0 1 2) => (and (rel1 0 1) (rel2 1 2)))
       (my-check ((rel1/rel2?) 0 2 1) => (and (rel1 0 2) (rel2 2 1)))
       (my-check ((rel1/rel2?) 1 2 0) => (and (rel1 1 2) (rel2 2 0)))
       (my-check ((rel1/rel2?) 1 0 2) => (and (rel1 1 0) (rel2 0 2)))
       (my-check ((rel1/rel2?) 2 0 1) => (and (rel1 2 0) (rel2 0 1)))
       (my-check ((rel1/rel2?) 2 1 0) => (and (rel1 2 1) (rel2 1 0)))
       
       ; test if all arguments are type checked
       (my-check (arguments-used (rel1/rel2? ci 0 1 2)) => '(0 1 2))
       (my-check (arguments-used (rel1/rel2? ci 0 2 1)) => '(0 1 2))
       (my-check (arguments-used (rel1/rel2? ci 1 2 0)) => '(0 1 2))
       (my-check (arguments-used (rel1/rel2? ci 1 0 2)) => '(0 1 2))
       (my-check (arguments-used (rel1/rel2? ci 2 0 1)) => '(0 1 2))
       (my-check (arguments-used (rel1/rel2? ci 2 1 0)) => '(0 1 2))
       ))))

(define-syntax my-check-chain
  (syntax-rules ()
    ((my-check-chain chain-rel? rel)
     (begin
       ; the chain of length 0
       (my-check (chain-rel? ci) => #t)
       
       ; a chain of length 1
       (my-check (chain-rel? ci 0) => #t)
       
       ; all chains of length 2
       (my-check (chain-rel? ci 0 0) => (rel 0 0))
       (my-check (chain-rel? ci 0 1) => (rel 0 1))
       (my-check (chain-rel? ci 1 0) => (rel 1 0))
       
       ; all chains of length 3
       (my-check (chain-rel? ci 0 0 0) => (rel 0 0 0))
       (my-check (chain-rel? ci 0 0 1) => (rel 0 0 1))
       (my-check (chain-rel? ci 0 1 0) => (rel 0 1 0))
       (my-check (chain-rel? ci 1 0 0) => (rel 1 0 0))
       (my-check (chain-rel? ci 1 1 0) => (rel 1 1 0))
       (my-check (chain-rel? ci 1 0 1) => (rel 1 0 1))
       (my-check (chain-rel? ci 0 1 1) => (rel 0 1 1))
       (my-check (chain-rel? ci 0 1 2) => (rel 0 1 2))
       (my-check (chain-rel? ci 0 2 1) => (rel 0 2 1))
       (my-check (chain-rel? ci 1 2 0) => (rel 1 2 0))
       (my-check (chain-rel? ci 1 0 2) => (rel 1 0 2))
       (my-check (chain-rel? ci 2 0 1) => (rel 2 0 1))
       (my-check (chain-rel? ci 2 1 0) => (rel 2 1 0))
       
       ; check if all arguments are used
       (my-check (arguments-used (chain-rel? ci 0)) => '(0))
       (my-check (arguments-used (chain-rel? ci 0 1)) => '(0 1))
       (my-check (arguments-used (chain-rel? ci 1 0)) => '(0 1))
       (my-check (arguments-used (chain-rel? ci 0 1 2)) => '(0 1 2))
       (my-check (arguments-used (chain-rel? ci 0 2 1)) => '(0 1 2))
       (my-check (arguments-used (chain-rel? ci 1 2 0)) => '(0 1 2))
       (my-check (arguments-used (chain-rel? ci 1 0 2)) => '(0 1 2))
       (my-check (arguments-used (chain-rel? ci 2 0 1)) => '(0 1 2))
       (my-check (arguments-used (chain-rel? ci 2 1 0)) => '(0 1 2))
       ))))

(define (check:predicates-from-compare)
  
  (my-check-chain2 =?    =)
  (my-check-chain2 <?    <)
  (my-check-chain2 >?    >)
  (my-check-chain2 <=?   <=)
  (my-check-chain2 >=?   >=)
  (my-check-chain2 not=? (lambda (x y) (not (= x y))))
  
  (my-check-chain3 </<?   <  <)
  (my-check-chain3 </<=?  <  <=)
  (my-check-chain3 <=/<?  <= <)
  (my-check-chain3 <=/<=? <= <=)
  
  (my-check-chain3 >/>?   >  >)
  (my-check-chain3 >/>=?  >  >=)
  (my-check-chain3 >=/>?  >= >)
  (my-check-chain3 >=/>=? >= >=)
  
  (my-check-chain chain=?  =)
  (my-check-chain chain<?  <)
  (my-check-chain chain>?  >)
  (my-check-chain chain<=? <=)
  (my-check-chain chain>=? >=)
  
  ) ; check:predicates-from-compare

; pairwise-not=?

(define pairwise-not=?:long-sequences
  (let ()
    
    (define (extremal-pivot-sequence r)
      ; The extremal pivot sequence of order r is a 
      ; permutation of {0..2^(r+1)-2} such that the
      ; middle element is minimal, and this property
      ; holds recursively for each binary subdivision.
      ;   This sequence exposes a naive implementation of
      ; pairwise-not=? chosing the middle element as pivot.
      (if (zero? r)
          '(0)
          (let* ((s (extremal-pivot-sequence (- r 1)))
                 (ns (length s)))
            (append (list-ec (:list x s) (+ x 1))
                    '(0)
                    (list-ec (:list x s) (+ x ns 1))))))
    
    (list (list-ec (: i 4096) i)
          (list-ec (: i 4097 0 -1) i)
          (list-ec (: i 4099) (modulo (* 1003 i) 4099))
          (extremal-pivot-sequence 11))))

(define pairwise-not=?:short-sequences
  (let ()
    
    (define (combinations/repeats n l)
      ; return list of all sublists of l of size n,
      ; the order of the elements occur in the sublists 
      ; of the output is the same as in the input
      (let ((len (length l)))
        (cond
          ((= n 0)   '())
          ((= n 1)   (map list l))
          ((= len 1) (do ((r '() (cons (car l) r))
                          (i n (- i 1)))
                       ((= i 0) (list r))))
          (else      (append (combinations/repeats n (cdr l))
                             (map (lambda (c) (cons (car l) c))
                                  (combinations/repeats (- n 1) l)))))))
    
    (define (permutations l)
      ; return a list of all permutations of l
      (let ((len (length l)))
        (cond
          ((= len 0) '(()))
          ((= len 1) (list l))
          (else      (apply append
                            (map (lambda (p) (insert-every-where (car l) p))
                                 (permutations (cdr l))))))))      
    
    (define (insert-every-where x xs)
      (let loop ((result '()) (before '()) (after  xs))
        (let ((new (append before (cons x after))))
          (cond
            ((null? after) (cons new result))
            (else          (loop (cons new result)
                                 (append before (list (car after)))
                                 (cdr after))))))) 
    
    (define (sequences n max)
      (apply append
             (map permutations
                  (combinations/repeats n (list-ec (: i max) i)))))
    
    (append-ec (: n 5) (sequences n 5))))

(define (colliding-compare x y)
  (ci (modulo x 3) (modulo y 3)))

(define (naive-pairwise-not=? compare . xs)
  (let ((xs (list->vector xs)))
    (every?-ec (:range i (- (vector-length xs) 1))
               (:let xs-i (vector-ref xs i))
               (:range j (+ i 1) (vector-length xs))
               (:let xs-j (vector-ref xs j))
               (not=? compare xs-i xs-j))))

(define (check:pairwise-not=?)
  
  ; 0-ary, 1-ary
  (my-check (pairwise-not=? ci)   => #t)
  (my-check (pairwise-not=? ci 0) => #t)
  
  ; 2-ary
  (my-check (pairwise-not=? ci 0 0) => #f)
  (my-check (pairwise-not=? ci 0 1) => #t)
  (my-check (pairwise-not=? ci 1 0) => #t)
  
  ; 3-ary
  (my-check (pairwise-not=? ci 0 0 0) => #f)
  (my-check (pairwise-not=? ci 0 0 1) => #f)
  (my-check (pairwise-not=? ci 0 1 0) => #f)
  (my-check (pairwise-not=? ci 1 0 0) => #f)
  (my-check (pairwise-not=? ci 1 1 0) => #f)
  (my-check (pairwise-not=? ci 1 0 1) => #f)
  (my-check (pairwise-not=? ci 0 1 1) => #f)
  (my-check (pairwise-not=? ci 0 1 2) => #t)
  (my-check (pairwise-not=? ci 0 2 1) => #t)
  (my-check (pairwise-not=? ci 1 2 0) => #t)
  (my-check (pairwise-not=? ci 1 0 2) => #t)
  (my-check (pairwise-not=? ci 2 0 1) => #t)
  (my-check (pairwise-not=? ci 2 1 0) => #t)
  
  ; n-ary, n large: [0..n-1], [n,n-1..1], 5^[0..96] mod 97
  (my-check (apply pairwise-not=? ci (list-ec (: i 10) i)) => #t)
  (my-check (apply pairwise-not=? ci (list-ec (: i 100) i)) => #t)
  (my-check (apply pairwise-not=? ci (list-ec (: i 1000) i)) => #t)
  
  (my-check (apply pairwise-not=? ci (list-ec (: i 10 0 -1) i)) => #t)
  (my-check (apply pairwise-not=? ci (list-ec (: i 100 0 -1) i)) => #t)
  (my-check (apply pairwise-not=? ci (list-ec (: i 1000 0 -1) i)) => #t)
  
  (my-check (apply pairwise-not=? ci 
                   (list-ec (: i 97) (modulo (* 5 i) 97)))
            => #t)
  
  ; bury another copy of 72 = 5^50 mod 97 in 5^[0..96] mod 97
  (my-check (apply pairwise-not=? ci 
                   (append (list-ec (: i 0 23) (modulo (* 5 i) 97))
                           '(72)
                           (list-ec (: i 23 97) (modulo (* 5 i) 97))))
            => #f)
  (my-check (apply pairwise-not=? ci 
                   (append (list-ec (: i 0 75) (modulo (* 5 i) 97))
                           '(72)
                           (list-ec (: i 75 97) (modulo (* 5 i) 97))))
            => #f)
  
  ; check if all arguments are used
  (my-check (arguments-used (pairwise-not=? ci 0)) => '(0))
  (my-check (arguments-used (pairwise-not=? ci 0 1)) => '(0 1))
  (my-check (arguments-used (pairwise-not=? ci 1 0)) => '(0 1))
  (my-check (arguments-used (pairwise-not=? ci 0 2 1)) => '(0 1 2))
  (my-check (arguments-used (pairwise-not=? ci 1 2 0)) => '(0 1 2))
  (my-check (arguments-used (pairwise-not=? ci 1 0 2)) => '(0 1 2))
  (my-check (arguments-used (pairwise-not=? ci 2 0 1)) => '(0 1 2))
  (my-check (arguments-used (pairwise-not=? ci 2 1 0)) => '(0 1 2))
  (my-check (arguments-used (pairwise-not=? ci 0 0 0 1 0 0 0 2 0 0 0 3))
            => '(0 1 2 3))
  
  ; Guess if the implementation is O(n log n):
  ;   The test is run for 2^e pairwise unequal inputs, e >= 1,
  ;   and the number of calls to the compare procedure is counted.
  ;     all pairs:          A = Binomial[2^e, 2] = 2^(2 e - 1) * (1 - 2^-e).
  ;     divide and conquer: D = e 2^e.
  ;   Since an implementation can be randomized, the actual count may
  ;   be a random number. We put a threshold at 100 e 2^e and choose
  ;   e such that A/D >= 150, i.e. e >= 12.
  ;     The test is applied to several inputs that are known to cause
  ;   trouble in simplistic sorting algorithms: (0..2^e-1), (2^e+1,2^e..1),
  ;   a pseudo-random permutation, and a sequence with an extremal pivot
  ;   at the center of each subsequence.
  
  (my-check-ec 
   (:list input pairwise-not=?:long-sequences)
   (let ((compares 0))
     (apply pairwise-not=? 
            (lambda (x y)
              (set! compares (+ compares 1))
              (ci x y))
            input)
     ;     (display compares) (newline)
     (< compares (* 100 12 4096)))
   (length input))
  
  ; check many short sequences
  
  (my-check-ec 
   (:list input pairwise-not=?:short-sequences)
   (eq?
    (apply pairwise-not=? colliding-compare input)
    (apply naive-pairwise-not=? colliding-compare input))
   input)
  
  ; check if the arguments are used for short sequences
  
  (my-check-ec 
   (:list input pairwise-not=?:short-sequences)
   (let ((args '()))
     (apply pairwise-not=? 
            (lambda (x y)
              (set! args (cons x (cons y args)))
              (colliding-compare x y))
            input)
     (equal? (list->set args) (list->set input)))
   input)
  
  ) ; check:pairwise-not=?


; min/max

(define min/max:sequences
  (append pairwise-not=?:short-sequences
          pairwise-not=?:long-sequences))

(define (check:min/max)
  
  ; all lists of length 1,2,3
  (my-check (min-compare ci 0) => 0)
  (my-check (min-compare ci 0 0) => 0)
  (my-check (min-compare ci 0 1) => 0)
  (my-check (min-compare ci 1 0) => 0)
  (my-check (min-compare ci 0 0 0) => 0)
  (my-check (min-compare ci 0 0 1) => 0)
  (my-check (min-compare ci 0 1 0) => 0)
  (my-check (min-compare ci 1 0 0) => 0)
  (my-check (min-compare ci 1 1 0) => 0)
  (my-check (min-compare ci 1 0 1) => 0)
  (my-check (min-compare ci 0 1 1) => 0)
  (my-check (min-compare ci 0 1 2) => 0)
  (my-check (min-compare ci 0 2 1) => 0)
  (my-check (min-compare ci 1 2 0) => 0)
  (my-check (min-compare ci 1 0 2) => 0)
  (my-check (min-compare ci 2 0 1) => 0)
  (my-check (min-compare ci 2 1 0) => 0)
  
  (my-check (max-compare ci 0) => 0)
  (my-check (max-compare ci 0 0) => 0)
  (my-check (max-compare ci 0 1) => 1)
  (my-check (max-compare ci 1 0) => 1)
  (my-check (max-compare ci 0 0 0) => 0)
  (my-check (max-compare ci 0 0 1) => 1)
  (my-check (max-compare ci 0 1 0) => 1)
  (my-check (max-compare ci 1 0 0) => 1)
  (my-check (max-compare ci 1 1 0) => 1)
  (my-check (max-compare ci 1 0 1) => 1)
  (my-check (max-compare ci 0 1 1) => 1)
  (my-check (max-compare ci 0 1 2) => 2)
  (my-check (max-compare ci 0 2 1) => 2)
  (my-check (max-compare ci 1 2 0) => 2)
  (my-check (max-compare ci 1 0 2) => 2)
  (my-check (max-compare ci 2 0 1) => 2)
  (my-check (max-compare ci 2 1 0) => 2)
  
  ; check that the first minimal value is returned
  (my-check (min-compare (pair-compare-car ci)
                         '(0 1) '(0 2) '(0 3))
            => '(0 1))
  (my-check (max-compare (pair-compare-car ci)
                         '(0 1) '(0 2) '(0 3))
            => '(0 1))
  
  ; check for many inputs
  (my-check-ec 
   (:list input min/max:sequences)
   (= (apply min-compare ci input)
      (apply min (apply max input) input))
   input)
  (my-check-ec 
   (:list input min/max:sequences)
   (= (apply max-compare ci input)
      (apply max (apply min input) input))
   input)
  ; Note the stupid extra argument in the apply for
  ; the standard min/max makes sure the elements are
  ; identical when apply truncates the arglist.
  
  ) ; check:min/max


; kth-largest

(define kth-largest:sequences
  pairwise-not=?:short-sequences)

(define (naive-kth-largest compare k . xs)
  (let ((vec (list->vector xs)))
    ; bubble sort: simple, stable, O(|xs|^2)
    (do-ec (:range n (- (vector-length vec) 1))
           (:range i 0 (- (- (vector-length vec) 1) n))
           (if>? (compare (vector-ref vec i)
                          (vector-ref vec (+ i 1)))
                 (let ((vec-i (vector-ref vec i)))
                   (vector-set! vec i (vector-ref vec (+ i 1)))
                   (vector-set! vec (+ i 1) vec-i))))
    (vector-ref vec (modulo k (vector-length vec)))))

(define (check:kth-largest)
  
  ; check extensively against naive-kth-largest
  (my-check-ec 
   (:list input kth-largest:sequences)
   (: k (- -2 (length input)) (+ (length input) 2))
   (= (apply naive-kth-largest colliding-compare k input)
      (apply kth-largest colliding-compare k input))
   (list input k))
  
  ) ;check:kth-largest

; compare-by< etc. procedures

(define (check:compare-from-predicates)
  
  (my-check-compare
   (compare-by< <)
   my-integers)
  
  (my-check-compare
   (compare-by> >)
   my-integers)
  
  (my-check-compare
   (compare-by<= <=)
   my-integers)
  
  (my-check-compare
   (compare-by>= >=)
   my-integers)
  
  (my-check-compare
   (compare-by=/< = <)
   my-integers)
  
  (my-check-compare
   (compare-by=/> = >)
   my-integers)
  
  ; with explicit arguments

  (my-check-compare
   (lambda (x y) (compare-by< < x y))
   my-integers)
  
  (my-check-compare
   (lambda (x y) (compare-by> > x y))
   my-integers)
  
  (my-check-compare
   (lambda (x y) (compare-by<= <= x y))
   my-integers)
  
  (my-check-compare
   (lambda (x y) (compare-by>= >= x y))
   my-integers)
  
  (my-check-compare
   (lambda (x y) (compare-by=/< = < x y))
   my-integers)
  
  (my-check-compare
   (lambda (x y) (compare-by=/> = > x y))
   my-integers)
  
  ) ; check:compare-from-predicates


(define (check:atomic)
  
  (my-check-compare boolean-compare   my-booleans)
  
  (my-check-compare char-compare      my-chars)
  
  (my-check-compare char-compare-ci   my-chars-ci)
  
  (my-check-compare string-compare    my-strings)
  
  (my-check-compare string-compare-ci my-strings-ci)
  
  (my-check-compare symbol-compare    my-symbols)
  
  (my-check-compare integer-compare   my-integers)
  
  (my-check-compare rational-compare  my-rationals)
  
  (my-check-compare real-compare      my-reals)
  
  (my-check-compare complex-compare   my-complexes)
  
  (my-check-compare number-compare    my-complexes)
  
  ) ; check:atomic

(define (check:refine-select-cond)
  
  ; refine-compare
  
  (my-check-compare
   (lambda (x y) (refine-compare))
   '(#f))
  
  (my-check-compare
   (lambda (x y) (refine-compare (integer-compare x y)))
   my-integers)
  
  (my-check-compare
   (lambda (x y)
     (refine-compare (integer-compare (car x) (car y))
                     (symbol-compare  (cdr x) (cdr y))))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a) (3 . c)))
  
  (my-check-compare
   (lambda (x y)
     (refine-compare (integer-compare (car   x) (car   y))
                     (symbol-compare  (cadr  x) (cadr  y))
                     (string-compare  (caddr x) (caddr y))))
   '((1 a "a") (1 b "a") (1 b "b") (2 b "c") (2 c "a") (3 a "b") (3 c "b")))
  
  ; select-compare
  
  (my-check-compare
   (lambda (x y) (select-compare x y))
   '(#f))
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y 
                     (integer? (ci x y))))
   my-integers)
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y 
                     (pair? (integer-compare (car x) (car y))
                            (symbol-compare  (cdr x) (cdr y)))))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a) (3 . c)))
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y 
                     (else (integer-compare x y))))
   my-integers)
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y 
                     (else (integer-compare (car x) (car y))
                           (symbol-compare  (cdr x) (cdr y)))))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a) (3 . c)))
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y
                     (symbol? (symbol-compare x y))
                     (string? (string-compare x y))))
   '(a b c "a" "b" "c" 1)) ; implicit (else 0)
  
  (my-check-compare
   (lambda (x y)
     (select-compare x y
                     (symbol? (symbol-compare x y))
                     (else    (string-compare x y))))
   '(a b c "a" "b" "c"))
  
  ; test if arguments are only evaluated once
  
  (my-check
   (let ((nx 0) (ny 0) (nt 0))
     (select-compare (begin (set! nx (+ nx 1)) 1)
                     (begin (set! ny (+ ny 1)) 2)
                     ((lambda (z) (set! nt (+ nt   1)) #f) 0)
                     ((lambda (z) (set! nt (+ nt  10)) #f) 0)
                     ((lambda (z) (set! nt (+ nt 100)) #f) 0)
                     (else 0))
     (list nx ny nt))
   => '(1 1 222))
  
  ; cond-compare
  
  (my-check-compare
   (lambda (x y) (cond-compare))
   '(#f))
  
  (my-check-compare
   (lambda (x y) 
     (cond-compare 
      (((integer? x) (integer? y)) (integer-compare x y))))
   my-integers)
  
  (my-check-compare
   (lambda (x y) 
     (cond-compare 
      (((pair? x) (pair? y)) (integer-compare (car x) (car y))
                             (symbol-compare  (cdr x) (cdr y)))))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a) (3 . c)))
  
  (my-check-compare
   (lambda (x y)
     (cond-compare
      (else (integer-compare x y))))
   my-integers)
  
  (my-check-compare
   (lambda (x y) 
     (cond-compare 
      (else (integer-compare (car x) (car y))
            (symbol-compare  (cdr x) (cdr y)))))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a) (3 . c)))
  
  (my-check-compare
   (lambda (x y)
     (cond-compare 
      (((symbol? x) (symbol? y)) (symbol-compare x y))
      (((string? x) (string? y)) (string-compare x y))))
   '(a b c "a" "b" "c" 1)) ; implicit (else 0)
  
  (my-check-compare
   (lambda (x y)
     (cond-compare 
      (((symbol? x) (symbol? y)) (symbol-compare x y))
      (else                      (string-compare x y))))
   '(a b c "a" "b" "c"))
  
  ) ; check:refine-select-cond


; We define our own list/vector data structure
; as '(my-list x[1] .. x[n]), n >= 0, in order
; to make sure the default ops don't work on it.

(define (my-list-checked obj) 
  (if (and (list? obj) (eqv? (car obj) 'my-list))
      obj
      (error "expected my-list but received" obj)))

(define (list->my-list list) (cons 'my-list list))
(define (my-empty? x)        (null? (cdr (my-list-checked x))))
(define (my-head x)          (cadr (my-list-checked x)))
(define (my-tail x)          (cons 'my-list (cddr (my-list-checked x))))
(define (my-size x)          (- (length (my-list-checked x)) 1))
(define (my-ref x i)         (list-ref (my-list-checked x) (+ i 1)))

(define (check:data-structures)
  
  (my-check-compare
   (pair-compare-car ci)
   '((1 . b) (2 . a) (3 . c)))
  
  (my-check-compare
   (pair-compare-cdr ci)
   '((b . 1) (a . 2) (c . 3)))
  
  ; pair-compare
  
  (my-check-compare pair-compare my-null-or-pairs)
  
  (my-check-compare
   (lambda (x y) (pair-compare ci x y))
   my-null-or-pairs)
  
  (my-check-compare
   (lambda (x y) (pair-compare ci symbol-compare x y))
   '((1 . a) (1 . b) (2 . b) (2 . c) (3 . a)))
  
  ; list-compare
  
  (my-check-compare list-compare my-lists)
  
  (my-check-compare
   (lambda (x y) (list-compare ci x y))
   my-lists)
  
  (my-check-compare
   (lambda (x y) (list-compare x y my-empty? my-head my-tail))
   (map list->my-list my-lists))
  
  (my-check-compare
   (lambda (x y) (list-compare ci x y my-empty? my-head my-tail))
   (map list->my-list my-lists))
  
  ; list-compare-as-vector
  
  (my-check-compare list-compare-as-vector my-list-as-vectors)
  
  (my-check-compare
   (lambda (x y) (list-compare-as-vector ci x y))
   my-list-as-vectors)
  
  (my-check-compare
   (lambda (x y) (list-compare-as-vector x y my-empty? my-head my-tail))
   (map list->my-list my-list-as-vectors))
  
  (my-check-compare
   (lambda (x y) (list-compare-as-vector ci x y my-empty? my-head my-tail))
   (map list->my-list my-list-as-vectors))
  
  ; vector-compare
  
  (my-check-compare vector-compare my-vectors)
  
  (my-check-compare
   (lambda (x y) (vector-compare ci x y))
   my-vectors)
  
  (my-check-compare
   (lambda (x y) (vector-compare x y my-size my-ref))
   (map list->my-list my-list-as-vectors))
  
  (my-check-compare
   (lambda (x y) (vector-compare ci x y my-size my-ref))
   (map list->my-list my-list-as-vectors))
  
  ; vector-compare-as-list
  
  (my-check-compare vector-compare-as-list my-vector-as-lists)
  
  (my-check-compare
   (lambda (x y) (vector-compare-as-list ci x y))
   my-vector-as-lists)
  
  (my-check-compare
   (lambda (x y) (vector-compare-as-list x y my-size my-ref))
   (map list->my-list my-lists))
  
  (my-check-compare
   (lambda (x y) (vector-compare-as-list ci x y my-size my-ref))
   (map list->my-list my-lists))
  
  ) ; check:data-structures


(define (check:default-compare)
  
  (my-check-compare default-compare my-objects)
  
  ; check if default-compare refines pair-compare
  
  (my-check-ec
   (:list x (index ix) my-objects)
   (:list y (index iy) my-objects)
   (:let c-coarse (pair-compare x y))
   (:let c-fine (default-compare x y))
   (or (eqv? c-coarse 0) (eqv? c-fine c-coarse))
   (list x y))
  
  ; check if default-compare passes on debug-compare
  
  (my-check-compare (debug-compare default-compare) my-objects)
  
  ) ; check:default-compare


(define (sort-by-less xs pred) ; trivial quicksort
  (if (or (null? xs) (null? (cdr xs)))
      xs
      (append 
       (sort-by-less (list-ec (:list x (cdr xs))
			      (if (pred x (car xs))) 
			      x) 
		     pred)
       (list (car xs))
       (sort-by-less (list-ec (:list x (cdr xs))
			      (if (not (pred x (car xs))))
			      x) 
		     pred))))

(define (check:more-examples)
  
  ; define recursive order on tree type (nodes are dotted pairs)
  
  (my-check-compare
   (letrec ((c (lambda (x y)
                 (cond-compare (((null? x) (null? y)) 0)
                               (else (pair-compare c c x y))))))
     c)
   (list '() (list '()) (list '() '()) (list (list '())))
   ;'(() (() . ()) (() . (() . ())) ((() . ()) . ()))   ; Chicken can't parse this ?
   )
  
  ; redefine default-compare using select-compare
  
  (my-check-compare
   (letrec ((c (lambda (x y)
                 (select-compare x y
                                 (null? 0)
                                 (pair?    (pair-compare    c c x y))
                                 (boolean? (boolean-compare x y))
                                 (char?    (char-compare    x y))
                                 (string?  (string-compare  x y))
                                 (symbol?  (symbol-compare  x y))
                                 (number?  (number-compare  x y))
                                 (vector?  (vector-compare  c x y))
                                 (else (error "unrecognized type in c" x y))))))
     c)
   my-objects)
  
  ; redefine default-compare using cond-compare
  
  (my-check-compare
   (letrec ((c (lambda (x y)
                 (cond-compare
                  (((null?    x) (null?    y)) 0)
                  (((pair?    x) (pair?    y)) (pair-compare    c c x y))
                  (((boolean? x) (boolean? y)) (boolean-compare x y))
                  (((char?    x) (char?    y)) (char-compare    x y))
                  (((string?  x) (string?  y)) (string-compare  x y))
                  (((symbol?  x) (symbol?  y)) (symbol-compare  x y))
                  (((number?  x) (number?  y)) (number-compare  x y))
                  (((vector?  x) (vector?  y)) (vector-compare  c x y))
                  (else (error "unrecognized type in c" x y))))))
     c)
   my-objects)
  
  ; compare strings with character order reversed
  
  (my-check-compare
   (lambda (x y)
     (vector-compare-as-list
      (lambda (x y) (char-compare y x))
      x y string-length string-ref))
   '("" "b" "bb" "ba" "a" "ab" "aa"))

  ; examples from SRFI text for <? etc.

  (my-check (>? "laugh" "LOUD") => #t)
  (my-check (<? string-compare-ci "laugh" "LOUD") => #t)
  (my-check (sort-by-less '(1 a "b") (<?)) => '("b" a 1))
  (my-check (sort-by-less '(1 a "b") (>?)) => '(1 a "b"))
  
  ) ; check:more-examples


; Real life examples
; ==================

; (update/insert compare x s)
;    inserts x into list s, or updates an equivalent element by x.
;      It is assumed that s is sorted with respect to compare,
;    i.e. (apply chain<=? compare s). The result is a list with x
;    replacing the first element s[i] for which (=? compare s[i] x),
;    or with x inserted in the proper place.
;      The algorithm uses linear insertion from the front.

(define (insert/update compare x s) ; insert x into list s, or update
  (if (null? s)
      (list x)
      (if3 (compare x (car s))
           (cons x s)
           (cons x (cdr s))
           (cons (car s) (insert/update compare x (cdr s))))))

; (index-in-vector compare vec x)
;    an index i such that (=? compare vec[i] x), or #f if there is none.
;      It is assumed that s is sorted with respect to compare,
;    i.e. (apply chain<=? compare (vector->list s)). If there are 
;    several elements equivalent to x then it is unspecified which
;    these is chosen.
;      The algorithm uses binary search.

(define (index-in-vector compare vec x)
  (let binary-search ((lo -1) (hi (vector-length vec)))
    ; invariant: vec[lo] < x < vec[hi]
    (if (=? (- hi lo) 1)
        #f
        (let ((mi (quotient (+ lo hi) 2)))
          (if3 (compare x (vector-ref vec mi))
               (binary-search lo mi)
               mi
               (binary-search mi hi))))))  


; Run the checks 
; ==============

(my-check-reset)

; comment in/out as needed
(check:atomic)
(check:if3)
(check:ifs)
(check:predicates-from-compare)
(check:pairwise-not=?)
(check:min/max)
(check:kth-largest)
(check:compare-from-predicates)
(check:refine-select-cond)
(check:data-structures)
(check:default-compare)
(check:more-examples)

(my-check-summary) ; all examples (99486) correct?
