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

 (agave glamour misc)

 (export initialize-glut
         buffered-display-procedure
         background
         gl-matrix-excursion
         gl-begin
         gl-color-rgba
         gl-clear-color-rgba
         )

 (import (rnrs) (gles gles1) (glut glut) (agave color rgba))

 (define (initialize-glut)
   ;(glut-init)
   ;(glutInitDisplayMode GLUT_DOUBLE)
   #t
   )

 (define (buffered-display-procedure procedure)

   (glut-display

    (lambda ()

      (glMatrixMode GL_MODELVIEW)

      (glLoadIdentity)
      
      (procedure)

      ;(glutSwapBuffers)
      )))

 (define background

   (case-lambda

    ( (r g b a)

      (glClearColor r g b a)

      (glClear GL_COLOR_BUFFER_BIT) )

    ( (r g b)

      (background r g b 1.0) )

    ( (grey alpha)

      (background grey grey grey alpha) )

    ( (grey)

      (background grey grey grey 1.0) )))

 (define-syntax gl-matrix-excursion

   (syntax-rules ()

     ( (gl-matrix-excursion expr ...)

       (begin

         (glPushMatrix)

         expr ...

         (glPopMatrix)))))

 (define-syntax gl-begin

   (syntax-rules ()

     ( (gl-begin mode expr ...)

       (begin

         ;(glBegin mode)

         expr ...

         ;(glEnd)
         ) )))

 (define gl-color-rgba       (apply-rgba glColor4f))
 (define gl-clear-color-rgba (apply-rgba glClearColor))

 )

