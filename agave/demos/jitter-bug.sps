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

;; Jitter Bug by Jeremy Sarchet
;; 
;; Original piece: http://www.openprocessing.org/visuals/?visualID=1238
;;
;; Ported to Scheme by Ed Cavazos

(import (rnrs)
        (agave geometry pt-3d)
        (gl)
        (glut)
        (agave glamour misc)
        (agave glamour window)
        (agave glamour mouse)
        (agave glamour frames-per-second)
        (agave processing math)
        (agave processing shapes-3d))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize-glut)

(window (size 500 500)
        (title "Jitter Bug by Jeremy Sarchet")
        (reshape (width height)))

(glEnable GL_LINE_SMOOTH)
(glEnable GL_POLYGON_SMOOTH)

(glEnable GL_BLEND)
(glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)

(passive-motion mouse-x mouse-y)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define rotate

  (let ((x 0)
        (y 0))
    
    (lambda ()
      
      (set! x (+ x 0.5))
      (set! y (+ y 1.0))
      
      (glRotated x 1.0 0.0 0.0)
      (glRotated y 0.0 1.0 0.0))))

(define (make-vertex n)

  (let ((r      100.0)
        (margin 20))

    (let ((t (cond ((<= mouse-x margin)             0.0)
                   ((>= mouse-x (- width margin)) 2.0)
                   (else
                    (map-number mouse-x
                                margin (- width margin)
                                0.0 2.0)))))

      (let ((i (if (>= t 1) 1 t))

            (j (if (<= t 1) 1 (map-number t 1 2 1.0 0.0))))

        (case n
          ((0)  (pt (* r    j ) 0.0         (* r     i)))
          ((1)  (pt (* r    j ) 0.0         (* r (- i))))
          ((2)  (pt (* r (- j)) 0.0         (* r (- i))))
          ((3)  (pt (* r (- j)) 0.0         (* r    i)))
          ((4)  (pt (* r    i ) (* r    j ) 0.0))
          ((5)  (pt (* r (- i)) (* r    j ) 0.0))
          ((6)  (pt (* r (- i)) (* r (- j)) 0.0))
          ((7)  (pt (* r    i ) (* r (- j)) 0.0))
          ((8)  (pt 0.0         (* r    i ) (* r    j)))
          ((9)  (pt 0.0         (* r (- i)) (* r    j)))
          ((10) (pt 0.0         (* r (- i)) (* r (- j))))
          ((11) (pt 0.0         (* r    i ) (* r (- j)))))))))

(define (draw-triangle i j k)
  (triangle (make-vertex i)
            (make-vertex j)
            (make-vertex k)))

(buffered-display-procedure
 
 (lambda ()

   (background 1.0)

   (glTranslated (/ width 2.0) (/ height 2.0) -100.0)

   (rotate)

   (glLineWidth 2.0)

   (fill 0.0 0.5 1.0 0.5)

   (draw-triangle 0 4 8)
   (draw-triangle 3 5 8)
   (draw-triangle 0 7 9)
   (draw-triangle 3 6 9)
   (draw-triangle 1 4 11)
   (draw-triangle 2 5 11)
   (draw-triangle 1 7 10)
   (draw-triangle 2 6 10)))

(glutIdleFunc
 (frames-per-second 30))

(glutMainLoop)