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

(library (box2d-lite clip-segment-to-line)

  (export clip-segment-to-line)

  (import (rnrs)
	  (dharmalab misc is-vector)
	  (box2d-lite util say)
	  (box2d-lite vec)
	  (box2d-lite edge-numbers)
	  (box2d-lite clip-vertex)
	  (box2d-lite edges))

  (define (clip-segment-to-line v-out v-in normal offset clip-edge)

    (define num-out 0)

    (is-vector      v-out num-out)
    (is-clip-vertex v-out.num-out)
    (is-edges       v-out.num-out.e)

    (define-syntax v-in.0 (identifier-syntax (vector-ref v-in 0)))
    (define-syntax v-in.1 (identifier-syntax (vector-ref v-in 1)))

    (is-clip-vertex v-in.0)
    (is-clip-vertex v-in.1)

    (let ((distance-0 (- (vec-dot normal v-in.0.v) offset))
	  (distance-1 (- (vec-dot normal v-in.1.v) offset)))

      (if (<= distance-0 0.0)
	  (begin (v-out.num-out! v-in.0) (set! num-out (+ num-out 1))))
      
      (if (<= distance-1 0.0)
	  (begin (v-out.num-out! v-in.1) (set! num-out (+ num-out 1))))

      (if (< (* distance-0 distance-1) 0.0)
	  
	  (let ((interp (/ distance-0 (- distance-0 distance-1))))

	    (v-out.num-out.v! (v+ v-in.0.v (n*v interp (v- v-in.1.v v-in.0.v))))

	    (cond ((> distance-0 0.0)
		   (v-out.num-out.e!           v-in.0.e)
		   (v-out.num-out.e.in-edge-1! clip-edge)
		   (v-out.num-out.e.in-edge-2! NO-EDGE))

		  (else
		   (v-out.num-out.e!            v-in.1.e)
		   (v-out.num-out.e.out-edge-1! clip-edge)
		   (v-out.num-out.e.out-edge-2! NO-EDGE)))

	    (set! num-out (+ num-out 1)))))

    num-out)

  )