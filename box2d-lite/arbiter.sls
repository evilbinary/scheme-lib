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

(library (box2d-lite arbiter)

  (export make-arbiter

	  arbiter-contacts
	  arbiter-num-contacts
	  arbiter-body-1
	  arbiter-body-2
	  arbiter-friction

	  arbiter-contacts-set!
	  arbiter-num-contacts-set!
	  arbiter-body-1-set!
	  arbiter-body-2-set!
	  arbiter-friction-set!
	  
	  is-arbiter
	  import-arbiter

	  create-arbiter
	  arbiter::pre-step
	  arbiter::apply-impulse

	  )

  (import (rnrs)
	  (surfage s27 random-bits)
	  (gles1)
	  (agave glamour misc)
	  (dharmalab misc is-vector)
	  (box2d-lite util define-record-type)
	  (box2d-lite util say)
	  (box2d-lite util math)
	  (box2d-lite vec)
	  (box2d-lite body)
	  (box2d-lite edges)
	  (box2d-lite contact)
	  (box2d-lite collide)
	  (box2d-lite world-parameters))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define MAX-POINTS 2)

  (define-record-type++ arbiter
    is-arbiter
    import-arbiter
    (fields (mutable contacts)
	    (mutable num-contacts)
	    (mutable body-1)
	    (mutable body-2)
	    (mutable friction))
    (methods (update arbiter::update)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (create-arbiter b1 b2)

    (let ((arb (make-arbiter (vector (create-contact)
				     (create-contact))
			     0 0 0 0)))
      
      (import-arbiter arb)

      (is-body body-1)
      (is-body body-2)

      (body-1! b1)
      (body-2! b2)

      (num-contacts! (collide contacts body-1 body-2))

      (friction! (sqrt (* body-1.friction body-2.friction)))

      (glPointSize 4.0)

      (glColor4f 1.0 0.0 0.0 0.0)

      (gl-begin GL_POINTS

	(do ((i 0 (+ i 1)))
	    ((>= i num-contacts))

	  (let ()

	    (is-vector  contacts i)
	    (is-contact contacts.i)
	    (is-vec     contacts.i.position)
	    ;;todo
	    1
	    ;(glVertex2f contacts.i.position.x contacts.i.position.y)
	    )))

      (glPointSize 1.0)

      arb))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (arbiter::update arb new-contacts num-new-contacts)

    (import-arbiter arb)

    (let ((merged-contacts (make-vector 2)))

      (do ((i 0 (+ i 1)))
	  ((>= i num-new-contacts))

	(let ()

	  (is-vector  new-contacts i)
	  (is-contact new-contacts.i)
          (is-edges   new-contacts.i.feature)

	  (is-vector  merged-contacts i)
	  (is-contact merged-contacts.i)

	  (let ((k -1))

	    (is-vector  contacts k)
	    (is-contact contacts.k)

	    (do ((j 0 (+ j 1))
		 (stop #f))
		((or (>= j num-contacts) stop))

	      (let ()

		(is-vector  contacts j)
		(is-contact contacts.j)
                (is-edges   contacts.j.feature)

		(if (edges-equal? new-contacts.i.feature contacts.j.feature)
		    (begin
		      (set! k j)
		      (set! stop #t)))))

	    (cond ((> k -1)
		   (merged-contacts.i! new-contacts.i)
		   (cond ((warm-starting)
			  (merged-contacts.i.pn!  contacts.k.pn)
			  (merged-contacts.i.pt!  contacts.k.pt)
			  (merged-contacts.i.pnb! contacts.k.pnb))
			 (else
			  (merged-contacts.i.pn!  0.0)
			  (merged-contacts.i.pt!  0.0)
			  (merged-contacts.i.pnb! 0.0))))
		  (else
		   (merged-contacts.i! new-contacts.i))))))

      (do ((i 0 (+ i 1)))
	  ((>= i num-new-contacts))

	(let ()

	  (is-vector contacts i)
	  (is-vector merged-contacts i)
	
	  (contacts.i! merged-contacts.i)))

      (num-contacts! num-new-contacts)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (arbiter::pre-step arb inv-dt)
    (import-arbiter arb)

    (is-body body-1)
    (is-body body-2)

    (let ((k-allowed-penetration 0.01)
	  (k-bias-factor (if (position-correction) 0.2 0.0)))

      (do ((i 0 (+ i 1)))
	  ((>= i num-contacts))

	(let ()

	  (is-vector contacts i)

	  (let ((c contacts.i))

	    (is-contact c)

	    (let ((r1 (v- c.position body-1.position))
		  (r2 (v- c.position body-2.position)))

	      (let ((rn1 (vec-dot r1 c.normal))
		    (rn2 (vec-dot r2 c.normal)))

		(let ((k-normal (+ body-1.inv-mass
				   body-2.inv-mass
				   (* body-1.inv-i (- (vec-dot r1 r1) (* rn1 rn1)))
				   (* body-2.inv-i (- (vec-dot r2 r2) (* rn2 rn2))))))

		  (c.mass-normal! (/ 1.0 k-normal))

		  (let ((tangent (vxn c.normal 1.0)))

		    (let ((rt1 (vec-dot r1 tangent))
			  (rt2 (vec-dot r2 tangent)))
		      
		      (let ((k-tangent
			     (+ body-1.inv-mass
				body-2.inv-mass
				(* body-1.inv-i (- (vec-dot r1 r1) (* rt1 rt1)))
				(* body-2.inv-i (- (vec-dot r2 r2) (* rt2 rt2))))))

			(c.mass-tangent! (/ 1.0 k-tangent))

			(c.bias! (* -1
				    k-bias-factor
				    inv-dt
				    (min 0.0 (+ c.separation k-allowed-penetration))))

			(if (accumulate-impulses)
			    
			    (let ((p (v+ (n*v c.pn c.normal) (n*v c.pt tangent))))

			      ;; (say body-1.velocity)
			      ;; (say body-2.velocity)

			      (body-1.velocity!
			       (v- body-1.velocity (n*v body-1.inv-mass p)))

			      (body-1.angular-velocity!
			       (- body-1.angular-velocity (* body-1.inv-i (vxv r1 p))))

			      (body-2.velocity!
			       (v+ body-2.velocity (n*v body-2.inv-mass p)))

			      (body-2.angular-velocity!
			       (+ body-2.angular-velocity (* body-2.inv-i (vxv r2 p))))
			      )))))))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (arbiter::apply-impulse arb)

    (import-arbiter arb)

    (let ((b1 body-1)
	  (b2 body-2))

      (is-body b1)
      (is-body b2)

      ;; (say-expr b2.velocity)

      ;; (if (> (abs (vec-y b2.velocity)) 0.001)
      ;; 	  (say-expr (vec-y b2.velocity)))

      ;; (if (> (abs (vec-y b2.velocity)) 0.001)
      ;; 	  (say-expr b2.velocity))

      (do ((i 0 (+ i (+ i 1))))
	  ((>= i num-contacts))

	(let ((c (vector-ref contacts i)))

	  (is-contact c)

	  (c.r1! (v- c.position b1.position))
	  (c.r2! (v- c.position b2.position))

	  (let ((dv (v- (v- (v+ b2.velocity (nxv b2.angular-velocity c.r2))
			    b1.velocity)
			(nxv b1.angular-velocity c.r1))))

	    ;; (say-expr b2.velocity)
	    
	    ;; (say-expr b2.angular-velocity)
	    
	    ;; (say "c.r2		" c.r2)

	    (let ((vn (vec-dot dv c.normal)))

	      (let ((dpn (* c.mass-normal (+ (- vn) c.bias))))

		;; (say "c.mass-normal		" c.mass-normal)

		;; (say "vn		" vn)

		;; (say "dpn		" dpn)

		(if (accumulate-impulses)
		    (let ((pn0 c.pn))
		      (c.pn! (max (+ pn0 dpn) 0.0))
		      (set! dpn (- c.pn pn0))

		      ;; (say "c.pn		" c.pn)

		      )
		    (set! dpn (max dpn 0.0)))

		(let ((pn (n*v dpn c.normal)))

		  (b1.velocity! (v- b1.velocity (n*v b1.inv-mass pn)))

		  (b1.angular-velocity!
		   (- b1.angular-velocity (* b1.inv-i (vxv c.r1 pn))))

		  (b2.velocity! (v+ b2.velocity (n*v b2.inv-mass pn)))

		  (b2.angular-velocity!
		   (+ b2.angular-velocity (* b2.inv-i (vxv c.r2 pn))))

		  (set! dv (v- (v- (v+ b2.velocity
				       (nxv b2.angular-velocity c.r2))
				   b1.velocity)
			       (nxv b1.angular-velocity c.r1)))
		  
		  (let ((tangent (vxn c.normal 1.0)))

		    (let ((vt (vec-dot dv tangent)))

		      (let ((dpt (* c.mass-tangent (- vt))))

			;; (say-expr dpt)

			(if (accumulate-impulses)

			    (let ((max-pt (* friction c.pn))
				  (old-tangent-impulse c.pt))

			      ;; (say-expr max-pt)

			      (c.pt!
			       (clamp (+ old-tangent-impulse dpt) (- max-pt) max-pt))

			      (set! dpt (- c.pt old-tangent-impulse))

			      ;; (say-expr c.pt)
			      )

			    (let ((max-pt (* friction dpn)))

			      (set! dpt (clamp dpt (- max-pt) max-pt))))

			(let ((pt (n*v dpt tangent)))

			  (b1.velocity! (v- b1.velocity (n*v b1.inv-mass pt)))
			  (b1.angular-velocity!
			   (- b1.angular-velocity (* b1.inv-i (vxv c.r1 pt))))

			  (b2.velocity! (v+ b2.velocity (n*v b2.inv-mass pt)))
			  (b2.angular-velocity!
			   (+ b2.angular-velocity (* b2.inv-i (vxv c.r2 pt))))

			  ))))))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )
    