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

(library (box2d-lite compute-incident-edge)

  (export compute-incident-edge)

  (import (rnrs)
	  (dharmalab misc is-vector)
	  (box2d-lite util say)
	  (box2d-lite util define-record-type)
	  (box2d-lite util math)
	  (box2d-lite vec)
	  (box2d-lite mat)
	  (box2d-lite clip-vertex)
	  (box2d-lite edges)
	  (box2d-lite edge-numbers))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (compute-incident-edge h pos rot normal)

    (is-vec h)

    (let ((n (vec::neg (m*v (mat::transpose rot) normal))))

      (let ((n-abs (vec::abs n)))
        
        (is-vec n)
        (is-vec n-abs)

        (define (make-incident-vertex x y in-edge-2 out-edge-2)
          (make-clip-vertex (v+ pos (m*v rot (make-vec x y)))
                            (make-edges NO-EDGE NO-EDGE in-edge-2 out-edge-2)))

        (if (> n-abs.x n-abs.y)

            (if (> (sign n.x) 0.0)

                (vector (make-incident-vertex    h.x  (- h.y) EDGE3 EDGE4)
                        (make-incident-vertex    h.x     h.y  EDGE4 EDGE1))

                (vector (make-incident-vertex (- h.x)    h.y  EDGE1 EDGE2)
                        (make-incident-vertex (- h.x) (- h.y) EDGE2 EDGE3)))

            (if (> (sign n.y) 0.0)

                (vector (make-incident-vertex    h.x     h.y  EDGE4 EDGE1)
                        (make-incident-vertex (- h.x)    h.y  EDGE1 EDGE2))

                (vector (make-incident-vertex (- h.x) (- h.y) EDGE2 EDGE3)
                        (make-incident-vertex    h.x  (- h.y) EDGE3 EDGE4)))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )