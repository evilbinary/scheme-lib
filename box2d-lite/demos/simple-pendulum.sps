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
	(gl)
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

(window (size 800 800)
	(title "Box2d Lite - Simple Pendulum")
	(reshape (width height)
		 (lambda (w h)
		   (glMatrixMode GL_PROJECTION)
		   (glLoadIdentity)
		   (glOrtho -20.0 20.0 -20.0 20.0 -1000.0 1000.0))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(random-source-randomize! default-random-source)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define bodies '())

(define joints '())

(define time-step 0.008)

(define world (make-world #f #f #f (make-vec 0.0 -10.0) 10))

(is-world world)

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

	(set! bodies (cons bomb bodies))

	))

  (bomb.position! (make-vec (+ -15.0 (* (random-real) 30.0))
			    15.0))

  (bomb.rotation! (+ -1.5 (* (random-real) 3.0)))

  (bomb.velocity! (n*v -1.5 bomb.position))

  (bomb.angular-velocity! (+ -20.0 (* (random-real) 40.0))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define draw-body-print-data? #f)

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
	  (glColor3f 0.4 0.9 0.4)
	  (glColor3f 0.8 0.8 0.9))

      (gl-begin GL_LINE_LOOP
	(glVertex2d v1.x v1.y)
	(glVertex2d v2.x v2.y)
	(glVertex2d v3.x v3.y)
	(glVertex2d v4.x v4.y)))))

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

	(glColor3f 0.5 0.5 0.8)

	(gl-begin GL_LINES

	  (glVertex2d x1.x x1.y)
	  (glVertex2d p1.x p1.y)
	  (glVertex2d x2.x x2.y)
	  (glVertex2d p2.x p2.y))))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(world.clear)

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define b1 (create-body))

(is-body b1)

(b1.set (make-vec 100.0 20.0) FLT-MAX)

(b1.friction! 0.2)

(b1.position! (make-vec 0.0 -10.0))

(b1.rotation! 0.0)

(world.add-body b1)

(set! bodies (append bodies (list b1)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define b2 (create-body))

(is-body b2)

(b2.set (make-vec 1.0 1.0) 100.0)

(b2.friction! 0.2)

(b2.position! (make-vec 9.0 11.0))

(b2.rotation! 0.0)

(world.add-body b2)

(set! bodies (append bodies (list b2)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let ((j (create-joint)))

  (is-joint j)

  (j.set b1 b2 (make-vec 0.0 11.0))

  (world.add-joint j)

  (set! joints (append joints (list j))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(buffered-display-procedure
 (lambda ()
   (background 0.0)
   (world.step time-step)
   (for-each draw-body  bodies)
   (for-each draw-joint joints)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutIdleFunc (limit-call-rate 60 (glutPostRedisplay)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutKeyboardFunc
 (lambda (key x y)
   (case (integer->char key)
     ((#\space) (launch-bomb)))))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "Press <space> to throw the bomb\n")

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(glutMainLoop)
