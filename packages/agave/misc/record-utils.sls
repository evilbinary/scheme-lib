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

 (agave misc record-utils)

 (export field-changer)

 (import (rnrs))

 (define (field-changer rtd field-name)

   (let ((field-names (record-type-field-names rtd)))

     (let ((index (let loop ((i 0))
                    (if (eq? (vector-ref field-names i) field-name)
                        i
                        (loop (+ i 1))))))

       (let ((accessor (record-accessor rtd index))
             (mutator  (record-mutator  rtd index)))

         (lambda (record procedure)

           (mutator record (procedure (accessor record))))))))

 )