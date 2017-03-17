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

(library

 (agave misc bytevector-utils)

 (export make-f64-vector
         f64-vector
         f64-vector-ref
         f64-vector-set!)

 (import (rnrs))

 (define (make-f64-vector n)
   (make-bytevector (* n 8)))

 (define (f64-vector . vals)
   (let ((n (length vals)))
     (let ((bv (make-bytevector (* n 8))))
       (let loop ((vals vals) (i 0))
         (if (< i n)
             (begin
               (bytevector-ieee-double-native-set! bv (* i 8) (car vals))
               (loop (cdr vals) (+ i 1)))))
       bv)))

 (define (f64-vector-ref v i)
   (bytevector-ieee-double-native-ref v (* i 8)))

 (define (f64-vector-set! v i val)
   (bytevector-ieee-double-native-set! v (* i 8) val))

 )