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

(library (agave processing math)

 (export map-number random)

 (import (rnrs)
         (surfage s27 random-bits))

 (define (map-number value low1 high1 low2 high2)
   (+ low2
      (* (/ (- value low1)
            (- high1 low1))
         (- high2 low2))))

 (define random
   (case-lambda
    ((a b)
     (cond ((and (integer? a)
                 (integer? b))
            (+ a (random-integer (- b a))))
           (else
            (+ a (* (- b a)
                    (random-real))))))
    ((a)
     (cond ((integer? a) (random 0 a))
           (else (random 0.0 a))))
    (() (random-real))))
 
 )