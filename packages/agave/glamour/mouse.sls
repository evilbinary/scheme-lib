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

 (agave glamour mouse)

 (export mouse mouse-press pressed-motion passive-motion motion)

 (import (rnrs) (glut))

 (define-syntax mouse
   (syntax-rules ()
     ( (mouse var-button var-state var-x var-y)

       (begin

         (define var-x 0)
         (define var-y 0)

         (define var-button 0)
         (define var-state  1)

         (glutMouseFunc
          (lambda (button state x y)
            (set! var-button button)
            (set! var-state  state)
            (set! var-x      x)
            (set! var-y      y)))

         (glutMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))

         (glutPassiveMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))) )))

 (define-syntax mouse-press
   (syntax-rules ()

     ( (mouse-press var-button var-state var-x var-y)

       (begin

         (define var-x 0)
         (define var-y 0)

         (define var-button 0)
         (define var-state  1)

         (glutMouseFunc
          (lambda (button state x y)
            (set! var-button button)
            (set! var-state  state)
            (set! var-x      x)
            (set! var-y      y)))) )))

 (define-syntax pressed-motion
   (syntax-rules ()

     ( (pressed-motion var-x var-y)

       (begin

         (define var-x 0)
         (define var-y 0)

         (glutMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))) )))

 (define-syntax passive-motion
   (syntax-rules ()

     ( (passive-motion var-x var-y)

       (begin

         (define var-x 0)
         (define var-y 0)

         (glutPassiveMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))) )))
 
 (define-syntax motion
   (syntax-rules ()

     ( (motion var-x var-y)

       (begin

         (define var-x 0)
         (define var-y 0)

         (glutMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))

         (glutPassiveMotionFunc
          (lambda (x y)
            (set! var-x x)
            (set! var-y y)))) )))

 )