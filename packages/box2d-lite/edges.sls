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

(library (box2d-lite edges)

  (export make-edges

	  edges-in-edge-1  edges-in-edge-1-set!
	  edges-out-edge-1 edges-out-edge-1-set!
	  edges-in-edge-2  edges-in-edge-2-set!
	  edges-out-edge-2 edges-out-edge-2-set!

	  is-edges
	  import-edges

	  create-edges

	  edges-equal?

	  flip)

  (import (rnrs)
	  (box2d-lite util define-record-type)
	  (box2d-lite edge-numbers))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ edges
    is-edges
    import-edges
    (fields (mutable in-edge-1)
	    (mutable out-edge-1)
	    (mutable in-edge-2)
	    (mutable out-edge-2))
    (methods))

  (define (create-edges)
    (make-edges NO-EDGE NO-EDGE NO-EDGE NO-EDGE))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (edges-equal? a b)

    (is-edges a)
    (is-edges b)

    (and (equal? a.in-edge-1  b.in-edge-1)
	 (equal? a.out-edge-1 b.out-edge-1)
	 (equal? a.in-edge-2  b.in-edge-2)
	 (equal? a.out-edge-2 b.out-edge-2)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (flip e)

    (is-edges e)

    (let ((tmp e.in-edge-1))

      (e.in-edge-1! e.in-edge-2)

      (e.in-edge-2! tmp))

    (let ((tmp e.out-edge-1))

      (e.out-edge-1! e.out-edge-2)

      (e.out-edge-2! tmp)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )