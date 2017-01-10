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

(library (dharmalab misc list)

  (export all-are all-of any-are any-of list-tabulate
          list-map-indices-reversed
          list-map-indices
          list-fold-head
          list-index
          list-sum
          list-sum-head)

  (import (rnrs)
          (dharmalab misc extended-curry))
  
  (define all-are (curry for-all a b)) ;; (all-are <pred>) -> (<proc> <list>)
  (define all-of  (curry for-all b a)) ;; (all-of  <list>) -> (<proc> <pred>)
  (define any-are (curry exists  a b)) ;; (any-are <pred>) -> (<proc> <list>)
  (define any-of  (curry exists  b a)) ;; (any-of  <list>) -> (<proc> <pred>)

  (define (list-tabulate n f)
    (do ((i 0 (+ i 1))
         (accum '() (cons (f i) accum)))
        ((>= i n) (reverse accum))))

  (define (list-map-indices-reversed ls proc)
    (let loop ((i 0) (ls ls) (accum '()))
      (if (null? ls)
          accum
          (loop (+ i 1)
                (cdr ls)
                (cons (proc i) accum)))))

  (define (list-map-indices ls proc)
    (reverse (list-map-indices-reversed ls proc)))

  (define (list-fold-head ls n val proc)
    (if (zero? n)
        val
        (list-fold-head (cdr ls)
                        (- n 1)
                        (proc val (car ls))
                        proc)))

  (define (list-index ls proc)
    (let loop ((i 0) (ls ls))
      (cond ((null? ls) #f)
            ((proc (car ls)) i)
            (else (loop (+ i 1)
                        (cdr ls))))))

  (define (list-sum ls)
    (fold-left + 0 ls))

  (define (list-sum-head ls n)
    (list-fold-head ls n 0 +))
  
  )