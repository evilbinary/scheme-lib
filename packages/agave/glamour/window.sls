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
  (agave glamour window)
  (export window invert-y)

  (import (rnrs) (gles gles1) (glut glut))


 (define-syntax window
   (syntax-rules ()
     ((_ (size width height)
               (title name)
               (reshape (width-var height-var) procedure ...)
               )
     
       (begin
         (define width-var  width)
         (define height-var height)
         (glut-init (lambda()
            (glut-init-window-size width height)
         ))
         (glut-set-window-title name)
         (glut-reshape
          (lambda (w h)
            (glViewport 0 0 w h)
            (glMatrixMode GL_PROJECTION)
            (glLoadIdentity)
            (glOrthof 0.0 (inexact w) 0.0 (inexact h) -1000.0 1000.0)
            (procedure w h)
            ...
            (set! width-var  w)
            (set! height-var h)))
             ) )) )


 (define (invert-y w h)
   (glMatrixMode GL_PROJECTION)
   (glLoadIdentity)
   (glOrthof 0.0 (inexact w) (inexact h) 0.0 -1000.0 1000.0))

 )