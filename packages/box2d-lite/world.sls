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

(library (box2d-lite world)

  (export make-world is-world import-world
	  world-bodies
	  world-joints
	  world-arbiters
	  world::step)

  (import (except (rnrs) remove)
	  (only (surfage s1 lists) remove)
	  (box2d-lite util define-record-type)
	  (box2d-lite util say)
	  (box2d-lite vec)
	  (box2d-lite body)
	  (box2d-lite joint)
	  (box2d-lite arbiter))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define (say-vec v) (say (vec-x v) "	" (vec-y v)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ world is-world import-world
    
    (fields (mutable bodies)
	    (mutable joints)
	    (mutable arbiters)
	    (mutable gravity)
	    (mutable iterations))
    
    (methods (add-body  world::add-body)
	     (add-joint world::add-joint)
	     (remove-body world::remove-body)
	     (clear     world::clear)
	     (step      world::step)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (world::add-body w body)
    (is-world w)
    (w.bodies! (append w.bodies (list body))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (world::add-joint w joint)
    (is-world w)
    (w.joints! (append w.joints (list joint))))
  
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (world::clear w)
    (is-world w)
    (w.bodies!   '())
    (w.joints!   '())
    (w.arbiters! '()))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (world::remove-body w body)
 	(is-world w)
 	(w.arbiters!
	  (remove
	   (lambda (arbiter)
	     (is-arbiter arbiter)
	      (or (eq? body arbiter.body-1)
	 	      (eq? body arbiter.body-2))
	     )
	   w.arbiters))
	(w.bodies!
	  (remove
	   (lambda (b)
	     (is-body b)
	      (eq? body b))
	   w.bodies))
 )

  (define (world::broad-phase w)
    (import-world w)
    (do ((bodies bodies (cdr bodies)))
		((null? bodies))
    	(let ((bi (car bodies)))
			(is-body bi)
			(do ((bodies (cdr bodies) (cdr bodies)))
			    ((null? bodies))
			  (let ((bj (car bodies)))
			    (is-body bj)
			    (if (and (= bi.inv-mass 0.0) (= bj.inv-mass 0.0))
					#t
				(let ((new-arb (create-arbiter bi bj)))
				  (is-arbiter new-arb)
				  (if (> new-arb.num-contacts 0)
				    (let ((arbiter (find    
					  (lambda (arbiter)
						(is-arbiter arbiter)
						(or (and (eq? bi arbiter.body-1)
							 (eq? bj arbiter.body-2))
						    (and (eq? bi arbiter.body-2)
							 (eq? bj arbiter.body-1)))
						)
					      arbiters)))
						(is-arbiter arbiter)
						(if arbiter
						    (arbiter.update new-arb.contacts
								    new-arb.num-contacts)
						    (arbiters! (append arbiters (list new-arb)))
					  ))
					    (begin
						 (arbiters!
						  (remove
						   (lambda (arbiter)
						     (is-arbiter arbiter)
						      (or (and (eq? bi arbiter.body-1)
						 	      (eq? bj arbiter.body-2))
						 	 (and (eq? bi arbiter.body-2)
						 	      (eq? bj arbiter.body-1)))
						     )
						   arbiters))
						 )
				    )
					)

				      )
				    )
			)
		)
	)
)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (world::step w dt)

    (import-world w)

    ;; (say "world::step  "
    ;; 	 "bodies: " (length (world-bodies   w)) "  "
    ;; 	 "joints: " (length (world-joints   w)) "  "
    ;; 	 "arbiters: " (length (world-arbiters w)))

    (let ((inv-dt (if (> dt 0.0) (/ 1.0 dt) 0.0)))
      (world::broad-phase w)

     (for-each
      (lambda (b)
		 (is-body b)
		 (if (= b.inv-mass 0.0)
		     #t
		     (begin
		       (b.velocity!
			(v+ b.velocity (n*v dt (v+ gravity (n*v b.inv-mass b.force)))))
		       (b.angular-velocity!
			(+ b.angular-velocity (* dt b.inv-i b.torque))))))
	      bodies)

      (for-each (lambda (arbiter) (arbiter::pre-step arbiter inv-dt)) arbiters)
      (for-each (lambda (joint)   (joint::pre-step   joint   inv-dt)) joints)

     (do ((i 0 (+ i 1)))
	 	((>= i iterations))
		(for-each arbiter::apply-impulse arbiters)
		(for-each joint::apply-impulse   joints))
     (for-each
      	(lambda (b)
		 (is-body b)
		 (b.position! (v+ b.position (n*v dt b.velocity)))
		 (b.rotation! (+  b.rotation (*   dt b.angular-velocity)))
		 (vec::set b.force 0.0 0.0)
		 (b.torque! 0.0))
	   bodies)
     )

	)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )
	    
