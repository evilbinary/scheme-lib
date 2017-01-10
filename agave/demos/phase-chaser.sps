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

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Based on "Phase Chaser" by Ivan Burghart

;; Original version in Processing:

;;     http://www.openprocessing.org/visuals/?visualID=4791

;; Ported to Scheme by Ed Cavazos

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import (rnrs)
        (only (surfage s1 lists) list-tabulate)
        (surfage s27 random-bits)
        (xitomatl fmt)
        (gl)
        (glut)
        (only (dharmalab math basic) pi)
        (agave glamour window)
        (agave glamour misc)
        (agave geometry pt))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (map-in-twos-with-index f l)
  (let ((first (car l)))
    (let loop ((i 0) (l l))
      (if (null? (cdr l))
          (list (f i (car l) first))
          (cons (f i
                   (car l)
                   (car (cdr l)))
                (loop (+ i 1) (cdr l)))))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (radians x)
  (* x (/ pi 180)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (pt->angle p)
  (atan (pt-y p)
        (pt-x p)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize-glut)

(window (size 600 600)
        (title "Phase Chaser")
        (reshape (width height) invert-y))

(glEnable GL_BLEND)
(glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)

(random-source-randomize! default-random-source)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define num-points 600)

(define speed 0.9)

(define wave-range (radians 35))

(define delta-phase 0.02)

(define num-waves 6)

(define phase 0)

(define circle-switch 1)

(define positions #f)

(define two-pi (* 2 pi))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (circular-arrangement)
  (define radius 100)
  (list-tabulate
   num-points
   (lambda (i)
     (pt (+ (/ width  2) (* radius (cos (* i (/ (* 2 pi) num-points)))))
         (+ (/ height 2) (* radius (sin (* i (/ (* 2 pi) num-points)))))))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (random-arrangement)
  (list-tabulate
   num-points
   (lambda (i)
     (pt (random-integer width)
         (random-integer height)))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (calc-positions)

  (map-in-twos-with-index

   (lambda (i a b)

     (let ((direction
            (+ (pt->angle (pt- b a))
               (* wave-range
                  (sin (+ (* (/ i num-points) two-pi num-waves) phase))))))

       (let ((offset (pt (* (cos direction) speed)
                         (* (sin direction) speed))))

         (pt+ a offset))))

   positions))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure

 (lambda ()

   (background 0.0)

   (glColor4d 1.0 1.0 1.0 1.0)

   (set! phase (mod (+ phase delta-phase) two-pi))

   (set! positions (calc-positions))

   (gl-begin GL_POINTS
     (for-each
      (lambda (a)
        (glVertex2d (pt-x a) (pt-y a)))
      positions))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(set! positions (circular-arrangement))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutIdleFunc glutPostRedisplay)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (display-menu)
  (fmt #t
       " q/a - change delta-phase : " (num delta-phase 10 4) nl
       " w/s - change speed       : " (num speed       10 4) nl
       " e/d - change num-waves   : " num-waves              nl
       " r/f - change num-points  : " num-points             nl
       " 1   - arrange circular"                             nl
       " 2   - arrange random"                               nl

       nl))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutKeyboardFunc

 (lambda (key x y)

   (case (integer->char key)

     ((#\q) (set! delta-phase (+ delta-phase 0.001)))
     ((#\a) (set! delta-phase (- delta-phase 0.001)))

     ((#\w) (set! speed       (+ speed       0.01)))
     ((#\s) (set! speed       (- speed       0.01)))

     ((#\e) (set! num-waves   (+ num-waves   1)))
     ((#\d) (set! num-waves   (- num-waves   1)))

     ((#\r) (begin (set! num-points (+ num-points 50))
                   (set! positions (circular-arrangement))))

     ((#\f) (begin (set! num-points (max 0 (- num-points 50)))
                   (set! positions (circular-arrangement))))
     
     ((#\1) (set! positions (circular-arrangement)))
     ((#\2) (set! positions (random-arrangement))))

   (display-menu)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display-menu)

(glutMainLoop)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

