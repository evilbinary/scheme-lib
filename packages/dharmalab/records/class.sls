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

(library (dharmalab records class)

  (export class)

  (import (rnrs)
          (dharmalab misc gen-id)
          (dharmalab records define-record-type)
          (dharmalab records define-method))

  (define-syntax class

    (lambda (stx)

      (syntax-case stx ()

        ( (class class-name (field ...) ((method-name param ...) expr ...) ...)

          (with-syntax ( ( (class-name::method-name ...)
                           (map (lambda (x)
                                  (gen-id #'class-name #'class-name "::" x))
                                #'(method-name ...)) ) )

            (syntax

             (begin

               (define-record-type++ class-name
                 (fields field ...)
                 (methods
                  (method-name class-name::method-name)
                  ...))

               (define-method class-name (method-name param ...)
                 expr
                 ...)

               ...)))

          )))))