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

;; Empathy by Kyle McDonald

;; Original version in Processing:

;;     http://www.openprocessing.org/visuals/?visualID=1182

;; Ported to Scheme by Ed Cavazos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import (rnrs)
        (surfage s27 random-bits)
        (gl)
        (glut)
        (dharmalab misc list)
        (dharmalab math basic)
        (dharmalab records define-record-type)
        (agave processing math)
        (agave geometry pt)
        (agave glamour misc)
        (agave glamour window))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gl-vertex-pt p)
  (glVertex2d (pt-x p)
              (pt-y p)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(random-source-randomize! default-random-source)

(initialize-glut)

(window (size 500 500)
        (title "Empathy by Kyle McDonald")
        (reshape (width height) invert-y))

(glEnable GL_LINE_SMOOTH)

(glEnable GL_BLEND)
(glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define number-of-cells     5000)
(define base-line-length    37)
(define rotation-factor     0.004)
(define slow-down-rate      0.97)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define current-mouse-pos  #f)
(define previous-mouse-pos #f)

(glutPassiveMotionFunc
 (lambda (x y)
   (set! current-mouse-pos (pt x y))))

(define (x*y pt)
  (* (pt-x pt)
     (pt-y pt)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ cell
  (fields pos
          spin-velocity
          current-angle))

(define (cell::sense c)
  (import-cell c)
  (let ((spin-velocity (* (+ spin-velocity
                             (/ (* rotation-factor
                                   (- (x*y (pt- previous-mouse-pos pos))
                                      (x*y (pt- current-mouse-pos  pos))))
                                (+ (pt-distance pos current-mouse-pos) 1)))
                          slow-down-rate)))
    (let ((current-angle (+ current-angle spin-velocity)))
      (let ((d (+ 0.001 (* base-line-length spin-velocity))))
        (gl-vertex-pt pos)
        (gl-vertex-pt (pt+ pos
                           (pt (* d (cos current-angle))
                               (* d (sin current-angle))))))
      (make-cell pos spin-velocity current-angle))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define cells
  (let ((center (pt (/ width  2.0)
                    (/ height 2.0))))
    (list-tabulate number-of-cells
                   (lambda (i)
                     (let loop ()
                       (let ((p (pt (inexact (random width))
                                    (inexact (random height)))))
                         (if (< (pt-distance center p)
                                (* width 0.45))
                             (make-cell p 0 0)
                             (loop))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure
 (lambda ()
   (background 1.0)
   (glColor4d 0.0 0.0 0.0 0.5)
   (if previous-mouse-pos
       (gl-begin GL_LINES (set! cells (map cell::sense cells))))
   (set! previous-mouse-pos current-mouse-pos)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "Don't move too fast, you might scare it.\n")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutIdleFunc glutPostRedisplay)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutMainLoop)

