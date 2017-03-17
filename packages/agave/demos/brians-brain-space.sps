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

(glutCreateWindow "Brian's Brain - through space")

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

  (let ((width  30)
        (height 30)
        (depth  20))

    (let ((states (make-vector (* width depth height) 0))
          (z 0))

      (define (at x y)

        (let ((x (mod x width))
              (y (mod y height))
              (z (mod z depth)))

          (vector-ref states (+ (* width height z)
                                (* width        y)
                                (*              x)))))

      (define (set x y val)

        (let ((x (mod    x    width))
              (y (mod    y    height))
              (z (mod (+ z 1) depth)))
          
          (vector-set! states
                       (+ (* width height z)
                          (* width        y)
                          (*              x))
                       val)))

      (define (randomize)

        (set! z (- z 1))

        (do ((x 0 (+ x 1)))
            ((>= x width))

          (do ((y 0 (+ y 1)))
              ((>= y height))

            (set x y (random-integer 3))))

        (set! z (+ z 1)))

      (define (step)

        (do ((x 0 (+ x 1)))
            ((>= x width))

          (do ((y 0 (+ y 1)))
              ((>= y height))

            (set x y 0)))

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

        (set! z (+ z 1)))

      (define angle 0.0)

      (define speed 0.0)

      (define (accelerate)
        (set! speed (if (< speed 1.0)
                        1.0
                        (* speed 1.1))))

      (define draw

        (lambda ()

          (glTranslated (- (/ width  2.0))
                        (- (/ height 2.0))
                        -100.0)

          ;; (glRotated 90.0 0.0 1.0 0.0)

          (do ((z 0 (+ z 1)))
              ((>= z depth))

            (glTranslated 0.0 0.0 (inexact z))

            (do ((x 0 (+ x 1)))
                ((>= x width))

              (do ((y 0 (+ y 1)))
                  ((>= y height))

                (case (vector-ref states (+ (* width height z)
                                            (* width        y)
                                            (*              x)))
                  
                  ((1)
                   
                   (glColor4d 1.0 0.0 0.0 1.0)

                   (gl-matrix-excursion
                    (glTranslated (inexact x) (inexact y) 0.0)
                    (glutWireCube 1.0)))

                  ((2)

                   (glColor4d 1.0 0.5 0.0 1.0)

                   (gl-matrix-excursion
                    (glTranslated (inexact x) (inexact y) 0.0)
                    (glutWireCube 1.0)))))))))

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
            "    c - Rotate camera"))

(glutMainLoop)
