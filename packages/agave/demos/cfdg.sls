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

(library (agave demos cfdg)

 (export background
         viewport
         start-shape
         threshold
         hue
         saturation
         brightness
         alpha
         size
         flip
         iterate?
         circle
         triangle
         square
         block
         x
         y
         rotate
         run-model)

 (import (rnrs)
         (only (surfage s1 lists) first second third fourth)
         (surfage s27 random-bits)
         (gl)
         (glut)
         (agave color rgba)
         (agave color hsva)
         (agave color conversion)
         (except (agave glamour misc) background)
         (except (dharmalab math basic) square)
         (agave misc list-stack)
         (agave misc bytevector-utils))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (get-modelview-matrix)
   (let ((bv (make-f64-vector 16)))
     (glGetDoublev GL_MODELVIEW_MATRIX bv)
     bv))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (gl-flip angle)

   (let ((angle (/ (* angle pi) 180)))

     (let ((bv (f64-vector (cos (* 2 angle))    (sin (* 2 angle))  0.0 0.0
                           (sin (* 2 angle)) (- (cos (* 2 angle))) 0.0 0.0
                           0.0                 0.0                 1.0 0.0
                           0.0                 0.0                 0.0 1.0)))

       (glMultMatrixd bv))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define *background*  #f)
 (define *threshold*   #f)
 (define *viewport*    #f)
 (define *start-shape* #f)

 (define (background  val) (set! *background*  val))
 (define (threshold   val) (set! *threshold*   val))
 (define (viewport    val) (set! *viewport*    val))
 (define (start-shape val) (set! *start-shape* val))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Transform commands
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (x      amt)   (glTranslated amt 0.0 0.0))
 (define (y      amt)   (glTranslated 0.0 amt 0.0))

 ;; (define (size   scale) (glScaled scale scale 1.0))

 (define size
   
   (case-lambda
    
    ((scale)
     (glScaled scale   scale   1.0))
    
    ((scale-x scale-y)
     (glScaled scale-x scale-y 1.0))))
 
 (define (rotate angle) (glRotated (+ 0.0 angle) 0.0 0.0 1.0))
 (define (flip   angle) (gl-flip angle))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; The state variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define *color*                  #f)
 (define *color-stack*            #f)
 (define *modelview-matrix-stack* #f)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (adjust num)
   (lambda (val)
     (if (> num 0.0)
         (+ val (* (- 1.0 val) num))
         (+ val (*        val  num)))))

 (define (hue num)
   (hsva-hue-change! *color* (lambda (old) (mod (+ old num) 360))))

 (define (saturation num) (hsva-saturation-change! *color* (adjust num)))
 (define (brightness num) (hsva-value-change!      *color* (adjust num)))
 (define (alpha      num) (hsva-alpha-change!      *color* (adjust num)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (circle)
   (gl-color-rgba (hsva->rgba *color*))
   (glutSolidSphere 0.5 32 16))

 (define (square)
   (gl-color-rgba (hsva->rgba *color*))
   (glBegin GL_POLYGON)
   (glVertex2d -0.5  0.5)
   (glVertex2d  0.5  0.5)
   (glVertex2d  0.5 -0.5)
   (glVertex2d -0.5 -0.5)
   (glEnd))

 (define (triangle)
   (gl-color-rgba (hsva->rgba *color*))
   (glBegin GL_POLYGON)
   (glVertex2d  0.0  0.577)
   (glVertex2d  0.5 -0.289)
   (glVertex2d -0.5 -0.289)
   (glEnd))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define block

   (let ()

     (define (push-modelview-matrix)
       (push! *modelview-matrix-stack* (get-modelview-matrix)))
     
     (define (pop-modelview-matrix)
       (glLoadMatrixd (pop! *modelview-matrix-stack*)))

     (define (push-color)
       (push! *color-stack* (hsva-clone *color*)))

     (define (pop-color)
       (set! *color* (pop! *color-stack*)))

     (lambda (procedure)
       (push-modelview-matrix)
       (push-color)
       (procedure)
       (pop-modelview-matrix)
       (pop-color))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (iterate?)
   (let ((bv (get-modelview-matrix)))
     (let ((size (apply max
                        (map (lambda (i)
                               (abs (f64-vector-ref bv i)))
                             '(0 1 4 5)))))
       (> size *threshold*))))
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define *display-list-generated* #f)

 (define (install-display-func)
   
   (glutDisplayFunc

    (let ((display-list (glGenLists 1)))

      (let ((build-display-list
             (lambda ()
               (set! *display-list-generated* #t)
               (glNewList display-list GL_COMPILE_AND_EXECUTE)
               (set! *color* (hsva 0.0 0.0 0.0 1.0))
               (gl-color-rgba (hsva->rgba *color*))
               (*start-shape*)
               (glEndList))))

        (lambda ()

          (glMatrixMode GL_PROJECTION)

          (glLoadIdentity)

          (let ((min-x  (first  *viewport*))
                (width  (second *viewport*))
                (min-y  (third  *viewport*))
                (height (fourth *viewport*)))

            (let ((max-x (+ min-x width))
                  (max-y (+ min-y height)))

              (apply glOrtho
                     (map inexact (list min-x max-x min-y max-y -10 10)))))

          (glMatrixMode GL_MODELVIEW)

          (glLoadIdentity)

          ;; Set background color

          (set! *color* (hsva 0.0 0.0 1.0 1.0))

          (*background*)

          (gl-clear-color-rgba (hsva->rgba *color*))

          (glClear GL_COLOR_BUFFER_BIT)

          ;; Initialize modelview matrix stack

          (set! *modelview-matrix-stack* (list))

          ;; Initialize color stack

          (set! *color-stack* (list))

          (if *display-list-generated*
              (glCallList display-list)
              
              (build-display-list)))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (run-model)

   (random-source-randomize! default-random-source)

   (glutInit (vector 0) (vector ""))

   (glutInitDisplayMode GLUT_RGBA)

   (glutInitWindowPosition 100 100)
   (glutInitWindowSize 500 500)

   (glutCreateWindow "Context Free Art")

   (glutReshapeFunc
    (lambda (w h)
      (glEnable GL_POINT_SMOOTH)
      (glEnable GL_LINE_SMOOTH)
      (glEnable GL_POLYGON_SMOOTH)

      (glEnable GL_BLEND)
      (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
      (glViewport 0 0 w h)))

   (install-display-func)

   (glutMainLoop))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

)
