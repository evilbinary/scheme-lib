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

(library (dharmalab infix alg)

  (export alg string->infix)

  (import (rnrs)
          (rnrs r5rs)
          (rnrs mutable-strings)
          (dharmalab infix tokenizer)
          (dharmalab infix infix))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (parse-eof) #f)

  (define (parse-comma) #\,)

  (define (string->infix str)

    (define (expr)

      (let loop ()

        (let ((token (lexer)))

          (cond ((eq? token #\()
                 (let ((a (expr)))
                   (let ((b (loop)))
                     (cons a b))))

                ((eq? token #\))
                 '())

                ((eq? token #f)
                 '())

                (else (cons token (loop)))))))

    (lexer-init 'string str)

    (expr))

  (define (alg str)
    (infix (string->infix str)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Examples
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (alg "a+b-c*d/e=f")

  ;; (alg "(a-b)/(c+d)")

  ;; (alg "a+b+c")

  ;; (alg "sin (cos (x)")

  ;; (alg "2 a b + 3 b c")

  ;; (alg "abc(x) + def(y)")

  ;; (alg "f(x,y) + g(i,j)")

  )