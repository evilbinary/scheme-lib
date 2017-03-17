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

(library (dharmalab indexable-sequence f32-vector)

  (export make-f32-vector
          f32-vector-length
          f32-vector-ref
          f32-vector-set!
          f32-vector
          
          f32-vector-fold-left
          f32-vector-fold-right
          f32-vector-for-each
          f32-vector-for-each-with-index
          f32-vector-copy
          f32-vector-map!
          f32-vector-map
          f32-vector-subseq
          f32-vector-take
          f32-vector-drop
          f32-vector-filter-to-reverse-list
          f32-vector-filter
          f32-vector-index
          f32-vector-find
          f32-vector-swap!
          f32-vector-reverse!
          f32-vector-reverse)

  (import (rnrs)
          (dharmalab indexable-sequence indexable-functors)
          (dharmalab indexable-sequence define-indexable-sequence-procedures))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-f32-vector n)
    (make-bytevector (* 4 n)))

  (define (f32-vector-length bv)
    (/ (bytevector-length bv) 4))

  (define (f32-vector-ref bv i)
    (bytevector-ieee-single-native-ref bv (* i 4)))

  (define (f32-vector-set! bv i val)
    (bytevector-ieee-single-native-set! bv (* i 4) val))

  (define (f32-vector . lst)
    (let ((bv (make-f32-vector (length lst))))
      (let loop ((i 0) (lst lst))
        (cond ((null? lst) bv)
              (else
               (f32-vector-set! bv i (car lst))
               (loop (+ i 1) (cdr lst)))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-indexable-sequence-procedures
    f32-vector
    f32-vector-length
    f32-vector-ref
    f32-vector-set!
    make-f32-vector)

  )