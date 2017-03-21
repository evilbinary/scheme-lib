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

(import (rnrs)
        (only (surfage s1 lists) first second)
        (surfage s27 random-bits)
        (gl)
        (glut)
        (agave glamour misc)
        (agave glamour window))

(initialize-glut)

(glutInitWindowSize 500 500)

(glutCreateWindow "Brian's Brain - Cube Projection")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutReshapeFunc
 (lambda (w h)

   (glViewport 0 0 w h)
   
   (glMatrixMode GL_PROJECTION)
   
   (glLoadIdentity)
   
   (glFrustum -1.0 1.0 -1.0 1.0 1.5 1000.0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type rotating-camera (fields establish accelerate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define camera

  (let ((angle 0.0)
        
        (speed 0.0))

    (define (establish)

      (set! angle (+ angle speed))

      (set! speed (* 0.98 speed))

      (glTranslated 0.0 0.0 -150.0)

      (glRotated angle 0.0 1.0 0.0))
    
    (define (accelerate)
      (set! speed (if (< speed 1.0)
                      1.0
                      (* speed 1.1))))

    (make-rotating-camera establish accelerate)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type cell-world (fields randomize iterate accelerate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define cells

  (let ((width  400)
        (height 100))

    (let ((state-a (make-vector (* width height) 0))
          (state-b #f))

      (define (at x y)

        (let ((x (mod x width))
              (y (mod y height)))
          
          (vector-ref state-a (+ (* width y) x))))

      (define (set x y val)

        (let ((x (mod x width))
              (y (mod y height)))

          (vector-set! state-b (+ (* width y) x) val)))

      (define (randomize)
        (set! state-a
          (vector-map (lambda (elt) (random-integer 3))
                      state-a)))

      (define (step)

        (set! state-b (make-vector (* width height) 0))

        (do ((x 0 (+ x 1)))
            ((>= x width))

          (do ((y 0 (+ y 1)))
              ((>= y height))

            (case (at x y)

              ((0)

               (let loop ((firing 0)
                          (offsets '((-1  1) ( 0  1) ( 1  1)
                                     (-1  0)         ( 1  0)
                                     (-1 -1) ( 0 -1) ( 1 -1))))

                 (cond ((> firing 2) #t)

                       ((null? offsets)
                        (if (= firing 2)
                            (set x y 1)))

                       (else

                        (if (= 1 (at (+ x (first  (car offsets)))
                                     (+ y (second (car offsets)))))

                            (loop (+ firing 1) (cdr offsets))
                            (loop    firing    (cdr offsets)))))))

              ((1) (set x y 2))

              ((2) (set x y 0)))))

        (set! state-a state-b))

      (define angle 0.0)

      (define speed 0.0)

      (define (accelerate)
        (set! speed (if (< speed 1.0)
                        1.0
                        (* speed 1.1))))

      (define draw

        (let ((cube-width  100)
              (cube-height 100)
              (cube-depth  100))

          (lambda ()

            (glRotated angle 1.0 0.0 0.0)

            (set! angle (+ angle speed))

            (set! speed (* 0.98 speed))

            (glTranslated (- (/ cube-width  2.0))
                          (- (/ cube-height 2.0))
                          (- (/ cube-depth  2.0)))
            
            (do ((x 0 (+ x 1)))
                ((>= x width))

              (do ((y 0 (+ y 1)))
                  ((>= y height))

                ;; project x into cube space
                (let ((px (cond ((<=   0 x  99)  x)
                                ((<= 100 x 199) 99)
                                ((<= 200 x 299) (- 99 (- x 200)))
                                ((<= 300 x 399)  0)))

                      (pz (cond ((<=   0 x  99) 0)
                                ((<= 100 x 199) (- x 100))
                                ((<= 200 x 299) 99)
                                ((<= 300 x 399) (- 99 (- x 300))))))

                  (case (at x y)
                    
                    ((1)
                     
                     (glColor4d 1.0 0.0 0.0 1.0)

                     (gl-matrix-excursion
                      (glTranslated (inexact px) (inexact y) (inexact pz))
                      (glutWireCube 1.0)))

                    ((2)

                     (glColor4d 1.0 0.5 0.0 1.0)

                     (gl-matrix-excursion
                      (glTranslated (inexact px) (inexact y) (inexact pz))
                      (glutWireCube 1.0))))))))))

      (define (iterate)
        (step)
        (draw))

      (make-cell-world randomize iterate accelerate))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutKeyboardFunc
 
 (lambda (key x y)

   (case (integer->char key)

     ((#\r) ((cell-world-randomize cells)))

     ((#\x) ((cell-world-accelerate cells)))

     ((#\c) ((rotating-camera-accelerate camera))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutDisplayFunc
 
 (lambda ()

   (glClearColor 0.0 0.0 0.0 0.0)   

   (glClear GL_COLOR_BUFFER_BIT)

   (glMatrixMode GL_MODELVIEW)

   (glLoadIdentity)

   ((rotating-camera-establish camera))

   ((cell-world-iterate cells))

   (glutSwapBuffers)))

(glutIdleFunc glutPostRedisplay)

(random-source-randomize! default-random-source)

((cell-world-randomize cells))

(for-each (lambda (line) (display line) (newline))
          '(""
            "Menu:"
            ""
            "    r - Randomize"
            "    x - Rotate cube"
            "    c - Rotate camera"))

(glutMainLoop)
