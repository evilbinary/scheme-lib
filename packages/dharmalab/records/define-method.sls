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

(library (dharmalab records define-method)

  (export define-method)

  (import (rnrs)
          (dharmalab misc gen-id)
          (dharmalab records define-record-type))

  (define-syntax define-method
    (lambda (stx)
      (syntax-case stx ()
        ( (define-method class (method-name param ...)
            expr
            ...)
          (with-syntax ( ( import-type   (gen-id #'class "import-" #'class) )
                         ( class::method (gen-id #'class #'class "::" #'method-name) )
                         ( self          (gen-id #'class "self") )
                         ( (param ...)
                           (map (lambda (x)
                                  (gen-id #'class x))
                                #'(param ...)) ) )
            
            (syntax
             
             (define (class::method self param ...)
               (import-type self)
               expr
               ...))))))))