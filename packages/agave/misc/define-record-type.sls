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

 (agave misc define-record-type)

 (export define-record-type++)

 (import (rnrs))

 (define-syntax define-record-type++

   (syntax-rules (fields mutable)

     ( (define-record-type++
         (name constructor predicate cloner assigner applier)
         (fields (mutable field accessor mutator changer)
                 ...))

       (begin

         (define-record-type (name constructor predicate)
           (fields (mutable field accessor mutator)
                   ...))

         (define (cloner record)
           (constructor (accessor record)
                        ...))

         (define (assigner a b)
           (mutator a (accessor b))
           ...)

         (define applier

           (case-lambda ((procedure record)
                         (procedure (accessor record)
                                    ...))

                        ((procedure)
                         (lambda (record)
                           (procedure (accessor record)
                                      ...)))))

         (define (changer record procedure)
           (mutator record (procedure (accessor record))))
         ...

         ) )))

 )