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

(library (agave misc random-weighted)

 (export random-weighted random-weighted* call-random-weighted)

 (import (rnrs)
         (only (surfage s1 lists) iota take list-index)
         (surfage s27 random-bits)
         (dharmalab math basic))

 (define (probabilities weights)
   (let ((sum (apply + weights)))
     (map (lambda (w) (/ w sum))
          weights)))

 (define (layers probabilities)
   (let ((n (+ (length probabilities) 1)))
     (map (lambda (l) (apply + l))
          (cdr
           (map (lambda (num)
                  (take probabilities num))
                (iota n))))))

 (define (random-weighted weights)
   (list-index (let ((n (random-integer 1000)))
                 (lambda (elt)
                   (> elt n)))
               (map (lambda (elt) (* elt 1000))
                    (layers (probabilities weights)))))

 (define (random-weighted* weights)

   (let ((scaled-layers (map (multiply-by 1000)
                             (layers (probabilities weights)))))

     (lambda ()

       (let ((n (random-integer 1000)))

         (list-index (greater-than n) scaled-layers)))))

 (define-syntax call-random-weighted
   
   (syntax-rules ()

     ( (call-random-weighted (weight procedure) ...)

       (let ((weights    (list   weight    ...))
             (procedures (vector procedure ...)))

         ((vector-ref procedures (random-weighted weights)))))))

 )

         

   
        
