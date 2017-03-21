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

(library (box2d-lite contact)

  (export make-contact

	  is-contact
	  import-contact

	  contact-position
	  contact-normal
	  contact-r1
	  contact-r2
	  contact-separation
	  contact-pn
	  contact-pt
	  contact-pnb
	  contact-mass-normal
	  contact-mass-tangent
	  contact-bias
	  contact-feature

	  contact-position-set!
	  contact-normal-set!
	  contact-r1-set!
	  contact-r2-set!
	  contact-separation-set!
	  contact-pn-set!
	  contact-pt-set!
	  contact-pnb-set!
	  contact-mass-normal-set!
	  contact-mass-tangent-set!
	  contact-bias-set!
	  contact-feature-set!

	  create-contact)

  (import (rnrs)
	  (box2d-lite util define-record-type)
	  (box2d-lite vec)
	  (box2d-lite edges))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ contact
    is-contact
    import-contact
    (fields (mutable position)
	    (mutable normal)
	    (mutable r1)
	    (mutable r2)
	    (mutable separation)
	    (mutable pn)
	    (mutable pt)
	    (mutable pnb)
	    (mutable mass-normal)
	    (mutable mass-tangent)
	    (mutable bias)
	    (mutable feature))
    (methods))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (create-contact)
    (make-contact (make-vec 0 0)
		  (make-vec 0 0)
		  (make-vec 0 0)
		  (make-vec 0 0)
		  0 0.0 0.0 0.0 0 0 0
                  (create-edges)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )
    