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

(library (box2d-lite body)

  (export make-body

	  body-position
	  body-rotation
	  body-velocity
	  body-angular-velocity
	  body-force
	  body-torque
	  body-width
	  body-friction
	  body-mass
	  body-inv-mass
	  body-i
	  body-inv-i

	  body-position-set!
	  body-rotation-set!
	  body-velocity-set!
	  body-angular-velocity-set!
	  body-force-set!
	  body-torque-set!
	  body-width-set!
	  body-friction-set!
	  body-mass-set!
	  body-inv-mass-set!
	  body-i-set!
	  body-inv-i-set!

	  is-body
	  import-body

	  create-body
	  ;; body::set
	  )

  (import (rnrs)
	  (box2d-lite util define-record-type)
	  (box2d-lite util math)
	  (box2d-lite vec))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ body
    is-body
    import-body
    (fields (mutable position)
	    (mutable rotation)
	    (mutable velocity)
	    (mutable angular-velocity)
	    (mutable force)
	    (mutable torque)
	    (mutable width)
	    (mutable friction)
	    (mutable mass)
	    (mutable inv-mass)
	    (mutable i)
	    (mutable inv-i))
    (methods (set body::set)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (create-body)

    (let ((b (make-body #f #f #f #f #f #f #f #f #f #f #f #f)))

      (import-body b)

      (position! (make-vec 0.0 0.0))
      (rotation! 0.0)
      (velocity! (make-vec 0.0 0.0))
      (angular-velocity! 0.0)
      (force! (make-vec 0.0 0.0))
      (torque! 0.0)
      (friction! 0.2)

      (width! (make-vec 1.0 1.0))
      (mass! FLT-MAX)
      (inv-mass! 0.0)
      (i! FLT-MAX)
      (inv-i! 0.0)

      b))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (body::set b w m)

    (import-body b)

    (is-vec width)

    (position! (make-vec 0.0 0.0))
    (rotation! 0.0)
    (velocity! (make-vec 0.0 0.0))
    (angular-velocity! 0.0)
    (force! (make-vec 0.0 0.0))
    (torque! 0.0)
    (friction! 0.2)

    (width! w)
    (mass!  m)

    (if (< mass FLT-MAX)
	
	(begin
	  
	  (inv-mass! (/ 1.0 mass))

	  (i! (/ (* mass (+ (* width.x width.x) (* width.y width.y))) 12.0))

	  (inv-i! (/ 1.0 i)))

	(begin

	  (inv-mass! 0.0)

	  (i! FLT-MAX)

	  (inv-i! 0.0)))

    b)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )