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

(import (rnrs)
	(gles1)
	(glut)
  (dharmalab misc limit-call-rate)
	(agave glamour misc)
	(agave glamour window)
	(box2d-lite util math)
	(box2d-lite vec)
	(box2d-lite mat)
	(box2d-lite body)
	(box2d-lite joint)
	(box2d-lite world)
  (surfage s27 random-bits))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(initialize-glut)

(window
  (size 600 600)
	(title "Box2d Lite - Dominos")
	(reshape (width height)
		 (lambda (w h)
       (glViewport 0 0  w  h)
		   (glMatrixMode GL_PROJECTION)
       (glLoadIdentity)
       (glScalef 0.1 0.1 1.0)
       (glTranslatef 0.0 -6.0 0.0)
		   (glOrthof -1100.1 0.001 -0.1 0.1 -0.1 1000.0)
       ;(glOrthof -100.0 10.0 -5.0 15.0 -1000.0 1000.0)
      ))
  )

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(random-source-randomize! default-random-source)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define time-step 0.008)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define world (make-world #f #f #f (make-vec 0.0 -10.0) 10))

(is-world world)

(world.clear)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define bomb #f)

(is-body bomb)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (launch-bomb)

  (if (not bomb)
      
      (begin

	(set! bomb (create-body))

	(bomb.set (make-vec 1.0 1.0) 50.0)

	(bomb.friction! 0.2)

	(world.add-body bomb)
	))

  (bomb.position! (make-vec (+ -15.0 (* (random-real) 30.0))
			    15.0))

  (bomb.rotation! (+ -1.5 (* (random-real) 3.0)))

  (bomb.velocity! (n*v -1.5 bomb.position))

  (bomb.angular-velocity! (+ -20.0 (* (random-real) 40.0))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (draw-body body)
  (is-body body)

  (let ((R (angle->mat body.rotation))
	(x body.position)
	(h (n*v 0.5 body.width)))

   (is-vec h)

   (let ((v1 (v+ x (m*v R (make-vec (- h.x) (- h.y)))))
	 (v2 (v+ x (m*v R (make-vec    h.x  (- h.y)))))
	 (v3 (v+ x (m*v R (make-vec    h.x     h.y ))))
	 (v4 (v+ x (m*v R (make-vec (- h.x)    h.y )))))

     (is-vec v1)
     (is-vec v2)
     (is-vec v3)
     (is-vec v4)

     (if (eq? body bomb)
      (glColor4f 0.4 0.9 0.4 1.0)
      (glColor4f 0.8 0.8 0.9 1.0)
   )
    (let ((p (glut-vector 'float (vector v1.x v1.y
                         v2.x v2.y
                         v3.x v3.y
                         v4.x v4.y)) ))
       (glVertexPointer 2  GL_FLOAT  0  p);
       (glEnableClientState GL_VERTEX_ARRAY);
       (glDrawArrays GL_LINE_LOOP  0 4);
       (glDisableClientState GL_VERTEX_ARRAY)
       (glut-unvector p) )

  ))
  )

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (draw-joint joint)

  (is-joint joint)

  (let ((b1 joint.body-1)
	(b2 joint.body-2))

    (is-body b1)
    (is-body b2)

    (let ((x1 b1.position)
	  (x2 b2.position))

      (is-vec x1)
      (is-vec x2)
      
      (let ((p1 (v+ x1 (m*v (angle->mat b1.rotation) joint.local-anchor-1)))
	    (p2 (v+ x2 (m*v (angle->mat b2.rotation) joint.local-anchor-2))))

	(is-vec p1)
	(is-vec p2)

	;(glColor3f 0.5 0.5 0.8)
  (glColor4f 0.5 0.5 0.8 1.0)

  (let ((p (glut-vector 'float (vector 
                          x1.x x1.y
                          p1.x p1.y
                          x2.x x2.y
                          p2.x p2.y)) ))
        (glVertexPointer 2  GL_FLOAT  0  p);
        (glEnableClientState GL_VERTEX_ARRAY);
        (glDrawArrays GL_LINES  0 4);
        (glDisableClientState GL_VERTEX_ARRAY)
        (glut-unvector p) )
  ))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define b1 #f)
(define b2 #f)
(define b3 #f)
(define b4 #f)
(define b5 #f)
(define b6 #f)

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b1 b)

  (b.set (make-vec 100.0 20.0) FLT-MAX)
  
  (b.position! (make-vec 0.0 -10.0))

  (world.add-body b))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (b.set (make-vec 12.0 0.5) FLT-MAX)
  
  (b.position! (make-vec -1.5 10.0))

  (world.add-body b))

(do ((i 0 (+ i 1)))
    ((>= i 10))

  (let ((b (create-body)))

    (is-body b)
    (is-vec  b.width)

    (b.set (make-vec 0.2 2.0) 10.0)

    (b.position! (make-vec (+ -6.0 (* 1.0 i)) 11.3))

    (b.friction! 0.1)

    (world.add-body b)))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (b.set (make-vec 14.0 0.5) FLT-MAX)

  (b.position! (make-vec 1.0 6.0))

  (b.rotation! 0.3)

  (world.add-body b))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b2 b)

  (b.set (make-vec 0.5 3.0) FLT-MAX)
  
  (b.position! (make-vec -7.0 4.0))

  (world.add-body b))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b3 b)

  (b.set (make-vec 12.0 0.25) 20.0)
  
  (b.position! (make-vec -0.9 1.0))

  (world.add-body b))

(let ((j (create-joint)))

  (is-joint j)

  (j.set b1 b3 (make-vec -2.0 1.0))

  (world.add-joint j))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b4 b)

  (b.set (make-vec 0.5 0.5) 10.0)
  
  (b.position! (make-vec -10.0 15.0))

  (world.add-body b))

(let ((j (create-joint)))

  (is-joint j)

  (j.set b2 b4 (make-vec -7.0 15.0))

  (world.add-joint j))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b5 b)

  (b.set (make-vec 2.0 2.0) 20.0)
  
  (b.position! (make-vec 6.0 2.5))

  (b.rotation! -0.01)

  (b.friction! 0.1)

  (world.add-body b))

(let ((j (create-joint)))

  (is-joint j)

  (j.set b1 b5 (make-vec 6.0 2.6))

  (world.add-joint j))

(let ((b (create-body)))

  (is-body b)
  (is-vec  b.width)

  (set! b6 b)

  (b.set (make-vec 2.0 0.2) 10.0)
  
  (b.position! (make-vec 6.0 3.6))

  (world.add-body b))

(let ((j (create-joint)))

  (is-joint j)

  (j.set b5 b6 (make-vec 7.0 3.5))

  (world.add-joint j))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure
 (lambda ()
   (background 0.0)
   (world.step time-step)
   (for-each draw-body  world.bodies)
   (for-each draw-joint world.joints)
   (collect)

   ))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(glut-idle (lambda () 
  ;(display "glut-idle\n")
  ;(limit-call-rate 160 (collect))
;  ) )

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(glutKeyboardFunc
; (lambda (key x y)
;   (case (integer->char key)
;     ((#\space) (launch-bomb)))))

(glut-key-event
 (lambda (event)
   ;(case (glut-event-get event 'keycode)
     ;((#\space) (launch-bomb)))
     (launch-bomb)
     ))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "Press <space> to throw the bomb\n")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glut-main-loop)
