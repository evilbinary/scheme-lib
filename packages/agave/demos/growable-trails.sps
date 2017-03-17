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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Based on an example from the Processing book
;;
;; Ported to Scheme by Ed Cavazos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import (rnrs)
        (dharmalab misc queue)
        (gl)
        (agave glu compat)
        (glut)
        (agave glamour window)
        (agave glamour mouse)
        (agave glamour misc))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define circle-xy
  (let ((quadric (gluNewQuadric)))
    (lambda (x y radius)
      (gl-matrix-excursion
       (glTranslated (inexact x) (inexact y) 0.0)
       (gluDisk quadric 0.0 radius 20 1)))))

(define (circle point radius)
  (circle-xy (vector-ref point 0)
             (vector-ref point 1)
             radius))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize-glut)

(window (size 500 500)
        (title "Trails")
        (reshape (width height) invert-y))

(glEnable GL_BLEND)
(glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)

(mouse mouse-button mouse-state mouse-x mouse-y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define trail (queue-tabulate (lambda (x) (vector 0.0 0.0)) 100))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure

 (lambda ()

   (background 0.0)

   (glColor4d 1.0 1.0 1.0 0.1)

   (let ((trail-length (queue-length trail)))

     (queue-for-each-with-index

      (lambda (i point)
        (let ((fraction (/ i trail-length)))
          (circle point (max 5.0 (* fraction 14.0)))))

      trail))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutIdleFunc

 (lambda ()

   (cond ((and (= mouse-state  GLUT_DOWN)
               (= mouse-button GLUT_LEFT_BUTTON))
          (if (not (queue-empty? trail))
              (begin
                (set! trail (queue-insert trail (vector mouse-x mouse-y)))
                (set! trail (queue-cdr trail))
                (set! trail (queue-cdr trail)))))

         ((and (= mouse-state  GLUT_DOWN)
               (= mouse-button GLUT_RIGHT_BUTTON))
          (set! trail (queue-insert trail (vector mouse-x mouse-y))))

         (else
          (set! trail (queue-insert trail (vector mouse-x mouse-y)))
          (set! trail (queue-cdr trail))))
         
   (glutPostRedisplay)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "Right mouse button: grow   trail\n")
(display "Left  mouse button: shrink trail\n")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutMainLoop)
