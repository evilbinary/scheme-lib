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

(library (dharmalab misc if)

  (export if)

  (import (rename (rnrs) (if rnrs:if)))

  (define-syntax if

    (syntax-rules (-> =>)

      ( (if test -> var then else)

        (let ((var test))

          (rnrs:if var then else)) )

      ( (if test -> var then)

        (let ((var test))

          (rnrs:if var then)) )

      ( (if test => then else)

        (let ((val test))

          (rnrs:if val (then val) else)) )

      ( (if test => then)

        (let ((val test))

          (rnrs:if val (then val))) )

      ( (if test then else)

        (rnrs:if test then else) )

      ( (if test then)

        (rnrs:if test then) )))

  )

      

      

      