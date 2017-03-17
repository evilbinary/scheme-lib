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

 (agave demos springies)

 (export run-springies
         mass
         spng
         reset-nodes
         reset-springs
         set-time-slice
         gravity-on
         gravity-off
         vel!
         get-nodes)

 (import (rnrs)
         (surfage s26 cut)
         (agave geometry pt)
         (gl)
         (glut)
         (agave glamour frames-per-second))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (print . items)
   (for-each display items))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (uni f c)
   (lambda (x)
     (c (f x))))

 (define (uni2 f c)
   (lambda (x y)
     (c (f x y))))

 (define (bi f g c)
   (lambda (x)
     (c (f x)
        (g x))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define x pt-x)
 (define y pt-y)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (vector-nth i) (cut vector-ref <> i))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (scalar-projection a b)
   (/ (pt-dot a b)
      (pt-norm b)))

 (define (vector-projection a b)
   (pt*n (pt-normalize b)
         (scalar-projection a b)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (pt-sum-4 a b c d)
   (pt+ (pt+ (pt+ a b) c) d))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define nodes   #f)
 (define springs #f)

 (define (get-nodes) nodes)

 (define (reset-nodes)
   (set! nodes '()))

 (define (reset-springs)
   (set! springs '()))

 (define time-slice #f)

 (define (set-time-slice val)
   (set! time-slice val))

 (define gravity #t)

 (define (gravity-on)
   (set! gravity #t))

 (define (gravity-off)
   (set! gravity #f))

 (define world-width  500)
 (define world-height 500)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (node-id id)
   (list-ref nodes (- id 1)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (node pos vel mass elas)

   (let ((acc   (pt 0.0 0.0))
         
         (force (pt 0.0 0.0))

         (cur-pos #f)
         (cur-vel #f)
         (pos-k1  #f)
         (vel-k1  #f)
         (pos-k2  #f)
         (vel-k2  #f)
         (pos-k3  #f)
         (vel-k3  #f)
         (pos-k4  #f)
         (vel-k4  #f))

     (let ((apply-force
            (lambda (v)
              (set! force (pt+ force v))))

           (reset-force
            (lambda ()
              (set! force (pt 0 0))))

           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           (new-acc (lambda () (pt/n force mass)))

           (new-vel (lambda () (pt+ vel (pt*n acc time-slice))))
           (new-pos (lambda () (pt+ pos (pt*n vel time-slice))))

           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           (k1-step
            (lambda ()
              (set! cur-pos pos)
              (set! cur-vel vel)

              (set! pos-k1 (pt*n vel time-slice))
              (set! vel-k1 (pt*n acc time-slice))

              (set! pos (pt+ cur-pos (pt/n pos-k1 2.0)))
              (set! vel (pt+ cur-vel (pt/n vel-k1 2.0)))))

           (k2-step
            (lambda ()
              (set! pos-k2 (pt*n vel time-slice))
              (set! vel-k2 (pt*n acc time-slice))

              (set! pos (pt+ cur-pos (pt/n pos-k2 2.0)))
              (set! vel (pt+ cur-vel (pt/n vel-k2 2.0)))))

           (k3-step
            (lambda ()
              (set! pos-k3 (pt*n vel time-slice))
              (set! vel-k3 (pt*n acc time-slice))

              (set! pos (pt+ cur-pos pos-k3))
              (set! vel (pt+ cur-vel vel-k3))))

           (k4-step
            (lambda ()
              (set! pos-k4 (pt*n vel time-slice))
              (set! vel-k4 (pt*n acc time-slice))))

           (find-next-position

            (let ((handle-bounce

                   (let ((below? (lambda () (< (y pos) 0)))

                         (above? (lambda () (>= (y pos) world-height)))

                         (beyond-left? (lambda () (< (x pos) 0)))

                         (beyond-right? (lambda () (>= (x pos) world-width)))

                         (bounce-top
                          (lambda ()
                            (pt-y-set! pos (- world-height 1.0))
                            (pt-y-set! vel (- (* (y vel) elas)))))

                         (bounce-bottom
                          (lambda ()
                            (pt-y-set! pos 0.0)
                            (pt-y-set! vel (- (* (y vel) elas)))))

                         (bounce-left
                          (lambda ()
                            (pt-x-set! pos 0.0)
                            (pt-x-set! vel (- (* (x vel) elas)))))

                         (bounce-right
                          (lambda ()
                            (pt-x-set! pos (- world-width 1.0))
                            (pt-x-set! vel (- (* (x vel) elas))))))
                     
                     (lambda ()
                       (cond ((above?)        (bounce-top))
                             ((below?)        (bounce-bottom))
                             ((beyond-left?)  (bounce-left))
                             ((beyond-right?) (bounce-right))
                             (else 'ok))))))
              
              (lambda ()

                (set! pos (pt+ cur-pos
                               (pt/n (pt-sum-4 (pt/n pos-k1 2.0)
                                               pos-k2
                                               pos-k3
                                               (pt/n pos-k4 2.0))
                                     3.0)))

                (set! vel (pt+ cur-vel
                               (pt/n (pt-sum-4 (pt/n vel-k1 2.0)
                                               vel-k2
                                               vel-k3
                                               (pt/n vel-k4 2.0))
                                     3.0)))

                (handle-bounce)))))

       (let ((update-acceleration
              (lambda ()
                (set! acc (new-acc))
                (reset-force))))

         (vector 'node
                 (lambda () pos)
                 (lambda () vel)
                 apply-force
                 k1-step
                 k2-step
                 k3-step
                 k4-step
                 find-next-position
                 update-acceleration
                 (lambda (new) (set! vel new)))
         ))))

 (define (pos node) ((vector-ref node 1)))
 (define (vel node) ((vector-ref node 2)))

 (define (apply-force node v) ((vector-ref node 3) v))

 (define (k1-step node) ((vector-ref node 4)))
 (define (k2-step node) ((vector-ref node 5)))
 (define (k3-step node) ((vector-ref node 6)))
 (define (k4-step node) ((vector-ref node 7)))

 (define (find-next-position node) ((vector-ref node 8)))

 (define (update-acceleration node) ((vector-ref node 9)))

 (define (vel! node new) ((vector-ref node 10) new))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (apply-gravity node)
   (apply-force node (pt 0 -9.8)))

 (define (do-gravity)
   (if gravity
       (for-each apply-gravity nodes)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; spring
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (spring rest-length k damp node-a node-b)
   (vector 'spring rest-length k damp node-a node-b))

 (define rest-length (vector-nth 1))
 (define k           (vector-nth 2))
 (define damp        (vector-nth 3))
 (define node-a      (vector-nth 4))
 (define node-b      (vector-nth 5))

 (define (spring-length spr)
   (pt-norm (pt- (pos (node-b spr))
                 (pos (node-a spr)))))

 (define (stretch-length spr)
   (- (spring-length spr)
      (rest-length   spr)))

 (define (dir spr)
   (pt-normalize (pt- (pos (node-b spr))
                      (pos (node-a spr)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Hooke
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; 
 ;; F = -kx
 ;; 
 ;; k :: spring constant
 ;; x :: distance stretched beyond rest length
 ;; 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define hooke-force-mag (bi k stretch-length *)) ;; spring -- mag

 (define hooke-force (bi dir hooke-force-mag pt*n)) ;; spring -- force

 (define (act-on-nodes-hooke spr)

   (let ((F (hooke-force spr)))

     (apply-force (node-a spr)         F)
     (apply-force (node-b spr) (pt-neg F))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; damping
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; 
 ;; F = -bv
 ;; 
 ;; b :: Damping constant
 ;; v :: Velocity
 ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define relative-velocity-a (bi (uni node-a vel) (uni node-b vel) pt-))

 (define unit-vec-b->a (bi (uni node-a pos) (uni node-b pos) pt-))

 (define relative-velocity-along-spring-a ;; spring -- vel
   (bi relative-velocity-a unit-vec-b->a vector-projection))

 (define damping-force-a
   (bi relative-velocity-along-spring-a damp (uni2 pt*n pt-neg)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define relative-velocity-b (bi (uni node-b vel) (uni node-a vel) pt-))

 (define unit-vec-a->b (bi (uni node-b pos) (uni node-a pos) pt-))

 (define relative-velocity-along-spring-b ;; spring -- vel
   (bi relative-velocity-b unit-vec-a->b vector-projection))

 (define damping-force-b ;; spring -- vec
   (bi relative-velocity-along-spring-b damp (uni2 pt*n pt-neg)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (act-on-nodes-damping spr)
   (apply-force (node-a spr) (damping-force-a spr))
   (apply-force (node-b spr) (damping-force-b spr)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (act-on-nodes spr)
   (act-on-nodes-hooke   spr)
   (act-on-nodes-damping spr))

 (define (loop-over-springs)
   (for-each act-on-nodes springs))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (update-nodes-acceleration)
   (for-each update-acceleration nodes))

 (define (accumulate-acceleration)
   (do-gravity)
   (loop-over-springs)
   (update-nodes-acceleration))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (iterate-system-runge-kutta)

   (accumulate-acceleration) (for-each k1-step nodes)
   (accumulate-acceleration) (for-each k2-step nodes)
   (accumulate-acceleration) (for-each k3-step nodes)
   (accumulate-acceleration) (for-each k4-step nodes)

   (for-each find-next-position nodes))

 (define iterate-system iterate-system-runge-kutta)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (mass id x y x-vel y-vel mass elas)
   (set! nodes
     (append nodes
             (list
              (node (pt x y) (pt x-vel y-vel) mass elas)))))

 (define (spng id id-a id-b k damp rest-length)
   (set! springs
     (append springs
             (list
              (spring rest-length k damp (node-id id-a) (node-id id-b))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (pt-gl-vertex p) (glVertex2d (x p) (y p)))

 (define (draw-node node)

   (let ((pos (pos node)))

     (glBegin GL_LINE_LOOP)

     (pt-gl-vertex (pt+ pos (pt -5 -5)))
     (pt-gl-vertex (pt+ pos (pt  5 -5)))
     (pt-gl-vertex (pt+ pos (pt  5  5)))
     (pt-gl-vertex (pt+ pos (pt -5  5)))

     (glEnd)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (draw-spring spring)

   (glBegin GL_LINES)

   (pt-gl-vertex (pos (node-a spring)))
   (pt-gl-vertex (pos (node-b spring)))

   (glEnd))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (draw-nodes)   (for-each draw-node   nodes))
 (define (draw-springs) (for-each draw-spring springs))

 (define (display-system)

   (glClearColor 0.0 0.0 0.0 1.0)

   (glClear GL_COLOR_BUFFER_BIT)

   (draw-nodes)

   (draw-springs))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (run-springies)

   (glutInitDisplayMode GLUT_DOUBLE)

   (glutInit (vector 0) (vector ""))

   (glutInitWindowSize 500 500)

   (glutCreateWindow "Springies")

   (glutReshapeFunc
    (lambda (w h)

      (set! world-width  w)
      (set! world-height h)

      (glEnable GL_BLEND)
      (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
      (glViewport 0 0 w h)

      (glMatrixMode GL_PROJECTION)
      (glLoadIdentity)

      (glOrtho 0.0 (- world-width 1.0) 0.0 (- world-height 1.0) -1.0 1.0)))

   (glutDisplayFunc
    (lambda ()
      (glMatrixMode GL_MODELVIEW)
      (glLoadIdentity)
      (display-system)
      (glutSwapBuffers)))

   (glutIdleFunc
    (lambda ()
      (iterate-system)
      (glutPostRedisplay)))

   (glutKeyboardFunc
    (lambda (key x y)

      (let ((key (if (char? key) key (integer->char key))))

        (case key

          ((#\2)
           (set! time-slice (- time-slice 0.01))
           (print "time-slice is now " time-slice "\n"))

          ((#\3)
           (set! time-slice (+ time-slice 0.01))
           (print "time-slice is now " time-slice "\n"))))))

   (print "\n"
          "Menu\n"
          "2 - Decrease time-slice by 0.01\n"
          "3 - Increase time-slice by 0.01\n")

   (glutMainLoop))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 )