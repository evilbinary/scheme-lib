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

(library (dharmalab misc curry)

  (export curry)

  (import (rnrs))

  ;; (define-syntax curry
  ;;   (syntax-rules ()
  ;;     ((curry (f x)) f)
  ;;     ((curry (f x y ...))
  ;;      (lambda (x)
  ;;        (curry ((lambda (y ...)
  ;;                  (f x y ...))
  ;;                y ...))) )))

  (define-syntax curry
    (syntax-rules ()

      ((curry (f x)) f)

      ((curry (f x y ...))

       (let ((f* f))
       
         (lambda (x)
           (curry ((lambda (y ...)
                     (f* x y ...))
                   y ...)))))))

  )