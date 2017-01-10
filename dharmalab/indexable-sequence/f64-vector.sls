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

(library (dharmalab indexable-sequence f64-vector)

  (export make-f64-vector
          f64-vector-length
          f64-vector-ref
          f64-vector-set!
          f64-vector
          
          f64-vector-fold-left
          f64-vector-fold-right
          f64-vector-for-each
          f64-vector-for-each-with-index
          f64-vector-copy
          f64-vector-map!
          f64-vector-map
          f64-vector-subseq
          f64-vector-filter-to-reverse-list
          f64-vector-filter
          f64-vector-index
          f64-vector-find
          f64-vector-swap!
          f64-vector-reverse!
          f64-vector-reverse)

  (import (rnrs)
          (dharmalab indexable-sequence indexable-functors)
          (dharmalab indexable-sequence define-indexable-sequence-procedures))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-f64-vector n)
    (make-bytevector (* 8 n)))

  (define (f64-vector-length bv)
    (/ (bytevector-length bv) 8))

  (define (f64-vector-ref bv i)
    (bytevector-ieee-double-native-ref bv (* i 8)))

  (define (f64-vector-set! bv i val)
    (bytevector-ieee-double-native-set! bv (* i 8) val))

  (define (f64-vector . lst)
    (let ((bv (make-f64-vector (length lst))))
      (let loop ((i 0) (lst lst))
        (cond ((null? lst) bv)
              (else
               (f64-vector-set! bv i (car lst))
               (loop (+ i 1) (cdr lst)))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-indexable-sequence-procedures
    f64-vector
    f64-vector-length
    f64-vector-ref
    f64-vector-set!
    make-f64-vector)

  )