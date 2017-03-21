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

 (agave demos cfdg-rule)

 (export rule)

 (import (rnrs)
         (agave demos cfdg)
         (agave misc random-weighted))

 (define-syntax rule

   (syntax-rules ()

     ( (rule
        name
        (weight (shape adjustment ...) ...)
        ...)

       (define name

         (let ((selector (random-weighted* (list weight ...)))

               (procedures

                (vector

                 (lambda ()

                   (block

                    (lambda ()

                      adjustment ... (shape)))

                   ...)

                 ...)))

           (lambda ()
             
             (if (iterate?)

                 ((vector-ref procedures (selector))))))) )))
 )