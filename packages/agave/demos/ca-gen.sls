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

;; Simulator for the "Generations" family of cellular automata

(library

 (agave demos ca-gen)

 (export ca-gen)
 
 (import (rnrs)
         (surfage s27 random-bits)
         (gl)
         (glut)
         (agave glamour misc)
         (agave glamour window)
         (agave glamour frames-per-second))

 (define (ca-simulation width height S B C)

   (define no-op (begin (initialize-glut) #t))

   (window (size 500 500)
           (title "Cellular Automata")
           (reshape (window-width window-height)
                    (lambda (w h)
                      (glMatrixMode GL_PROJECTION)
                      (glLoadIdentity)
                      (glOrtho 0.0 (inexact width)
                               0.0 (inexact height)
                               -10.0 10.0))))

   (let ((state-a #f)
         (state-b #f))

     (define (at x y)

       (let ((x (mod x width))
             (y (mod y height)))

         (vector-ref state-a (+ (* width y) x))))

     (define (set x y val)
       
       (let ((x (mod x width))
             (y (mod y height)))

         (vector-set! state-b
                      (+ (* width y) x)
                      val)))

     (define (each procedure)
       
       (do ((x 0 (+ x 1)))
           ((>= x width))
         
         (do ((y 0 (+ y 1)))
             ((>= y height))

           (procedure x y))))

     (define (randomize fraction)
       (set! state-a
         (vector-map (lambda (elt)
                       (if (< (random-integer 100)
                              (* fraction 100))
                           (random-integer C)
                           0))
                     (make-vector (* width height)))))

     (define (alive x y)
       (if (= (at x y) 1)
           1
           0))

     (define (count-alive-neighbors x y)
       (+ (alive (+ x -1) (+ y -1))
          (alive (+ x  0) (+ y -1))
          (alive (+ x  1) (+ y -1))
          (alive (+ x -1) (+ y  0))
          (alive (+ x  1) (+ y  0))
          (alive (+ x -1) (+ y  1))
          (alive (+ x  0) (+ y  1))
          (alive (+ x  1) (+ y  1))))

     (define (step)

       (set! state-b (make-vector (* width height) 0))

       (each

        (lambda (x y)

          (case (at x y)

            ((0)
             (if (member (count-alive-neighbors x y) B)
                 (set x y 1)))

            ((1)
             (if (member (count-alive-neighbors x y) S)
                 (set x y 1)
                 (set x y (mod 2 C))))

            (else
             (set x y (mod (+ (at x y) 1) C))))))

       (set! state-a state-b))

     (define (draw)

       (each
        
        (lambda (x y)

          (let ((cell-value (at x y)))

            (if (> cell-value 0)

                (begin

                  (glColor4d 1.0
                             (inexact
                              (/ (- cell-value 1)
                                 (max (- C 2) 1)))
                             0.0
                             1.0)
                        
                  (gl-matrix-excursion
                 
                   (glTranslated (inexact x) (inexact y) 0.0)
                   
                   (glutSolidCube 1.0))))))))

     (define run #t)

     (define (iterate)

       (cond ((eq? run '#t)
              (step))

             ((eq? run 'single-step)
              (set! run #f)
              (step)))

       (draw))

     (define (pause)
       (if run
           (set! run #f)
           (set! run #t)))

     (define (single-step)
       (set! run 'single-step))

     (define frame-rate 20)

     (glutIdleFunc (frames-per-second frame-rate))

     (buffered-display-procedure
      (lambda ()
        (background 0.0)
        (iterate)))

     (glutKeyboardFunc
      
      (lambda (key x y)

        ;; (write (integer->char key))
        ;; (newline)

        (case (integer->char key)

          ((#\1) (randomize 0.1))
          ((#\2) (randomize 0.2))
          ((#\3) (randomize 0.3))
          ((#\4) (randomize 0.4))
          ((#\5) (randomize 0.5))
          ((#\6) (randomize 0.6))
          ((#\7) (randomize 0.7))
          ((#\8) (randomize 0.8))
          ((#\9) (randomize 0.9))
          ((#\0) (randomize 1.0))

          ((#\=)

           (set! width  (round (* width  11/10)))
           (set! height (round (* height 11/10)))

           (glutReshapeWindow window-width window-height)

           (randomize 0.25))

          ((#\-)

           (set! width  (round (* width  9/10)))
           (set! height (round (* height 9/10)))

           (glutReshapeWindow window-width window-height)

           (randomize 0.25))

          ((#\space) (pause))

          ((#\return) (single-step))

          ((#\q)
           (set! frame-rate      (+ frame-rate 1))
           (glutIdleFunc (frames-per-second frame-rate)))
           
          ((#\a)
           (set! frame-rate (max (- frame-rate 1) 1))
           (glutIdleFunc (frames-per-second frame-rate)))

          )))

     (random-source-randomize! default-random-source)

     (randomize 0.25))

   (for-each (lambda (line) (display line) (newline))

             '(

               ""
               "Menu:"
               ""
               "    0-9 - Randomize with fractional density"
               ""
               "    =   - Increase world size by 1/10"
               "    -   - Decrease world size by 1/10"
               ""
               "    spc - Pause and Resume"
               ""
               "    ret - Single step"
               ""
               "    q   - Increase frame rate"
               "    a   - Decrease frame rate"
               ""
               ))

   (glutMainLoop))

 (define-syntax ca-gen

   (syntax-rules (width height S B C)

     ((ca-gen (width w)
              (height h)
              (S s ...)
              (B b ...)
              (C c))
      (ca-simulation w h '(s ...) '(b ...) c))

     ((ca-gen (width w)
              (height h)
              (S s ...)
              (B b ...))
      (ca-simulation w h '(s ...) '(b ...) 2))))

 )

