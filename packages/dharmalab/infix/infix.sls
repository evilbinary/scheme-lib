;; Copyright 2016 Eduardo Cavazos
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
#!r6rs

(library (dharmalab infix infix)

  (export infix)
  
  (import (rnrs)
          (only (surfage s1 lists) circular-list list-index take drop)
          (surfage s64 testing))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define precedence-table
    '((sentinel . 0)
      (=        . 1)
      (+        . 2)
      (-        . 2)
      (*        . 4)
      (/        . 4)
      (^        . 5)))

  (define (precedence item)
    (let ((result (assq item precedence-table)))
      (if result
          (cdr result)
          100)))

  (define (right-associative? obj)
    (member obj '(^)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define operators (cdr (map car precedence-table)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (operator? obj)
    (member obj operators))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (args->operands expr)

    (if (null? expr)

        '()

        (let ((i (list-index (lambda (x) (eq? x #\,)) expr)))

          (if i

              (cons (infix (take expr i))
                    (args->operands (drop expr (+ i 1))))

              (list (infix expr))))))  

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (shunting-yard expr operands operators)

    (define (rewrite-unaries expr)

      (if (and (operator? (list-ref expr 0))
               (operator? (list-ref expr 1)))

          (list (list-ref expr 0)
                (cdr expr))

          expr))
    
    (define (check-for-mul expr)

      (if (and (>= (length expr) 2)

               (not (operator? (list-ref expr 0)))

               (not (operator? (list-ref expr 1)))

               (not (list? (list-ref expr 1))))

          (cons (car expr)
                (cons '*
                      (cdr expr)))

          expr))

    (define (apply-operator)

      (cond ((and (operator? (car operators))
                  (= (length operands) 1))
             (shunting-yard expr
                            (cons (list (car operators)
                                        (list-ref operands 0))
                                  (cdr operands))
                            (cdr operators)))

            ((operator? (car operators))
             (shunting-yard expr
                            (cons (list (car operators)
                                        (list-ref operands 1)
                                        (list-ref operands 0))
                                  (cdr (cdr operands)))
                            (cdr operators)))

            (else
             (shunting-yard expr
                            (cons (list (car operators)
                                        (list-ref operands 0))
                                  (cdr operands))
                            (cdr operators)))))

    ;; (display (list 'shunting-yard expr operands operators)) (newline)

    (if (null? expr)
        
        (if (eq? (car operators) 'sentinel)
            (car operands)
            (apply-operator))

        (let ((expr (check-for-mul (rewrite-unaries expr))))

          (let ((elt (car expr)))
            
            (cond ((operator? elt)

                   (if (or (> (precedence elt)
                              (precedence (car operators)))

                           (and (right-associative? elt)

                                (= (precedence elt)
                                   (precedence (car operators)))))

                       (shunting-yard (cdr expr) operands (cons elt operators))

                       (apply-operator)))


                  ;; f(x)

                  ;; f(x,y,z)
                  
                  ((and (>= (length expr) 2)
                        (list? (list-ref expr 1)))

                   (shunting-yard (cdr (cdr expr))
                                  (cons (cons elt
                                              (args->operands (list-ref expr 1)))
                                        operands)
                                  operators))
                                  
                  ((list? elt)
                   (shunting-yard (cdr expr)
                                  (cons (infix elt) operands)
                                  operators))

                  (else

                   (shunting-yard (cdr expr) (cons elt operands) operators)))))))
  
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (infix expr)
    (shunting-yard expr '() (circular-list 'sentinel)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; Examples

  ;; (infix '(a + b - c * d / e = f))
  ;;
  ;; (= (- (+ a b) (/ (* c d) e)) f)

  ;; (infix '( (a - b) / (c + d) ))
  ;;
  ;; (/ (- a b) (+ c d))

  ;; > (infix '(a + b + c))
  ;;
  ;; (+ (+ a b) c)

  ;; > (infix '(sin (cos (x))))
  ;;
  ;; (sin (cos x))

  ;; (infix '(2 a b + 3 b c))
  ;;
  ;; > (+ (* (* 2 a) b) (* (* 3 b) c))

  ;; If it has parenthesis after it, it's a function
  ;;
  ;; > (infix '( abc(x) + def(y) ))
  ;;
  ;; (+ (abc x) (def y))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (infix-examples)

    (test-begin "infix-examples")

    ;; Juxtaposition indicates multiplication:

    (test-equal (infix '(2 a b)) '(* (* 2 a) b))

    ;; ^ is right associative:

    (test-equal (infix '(a ^ b ^ c)) '(^ a (^ b c)))

    ;; Misc
    
    (test-equal (infix '(a + b)) '(+ a b))

    (test-end "infix-examples")

    )

  )