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

(library (box2d-lite clip-vertex)

  (export make-clip-vertex

	  clip-vertex-v
	  ;; clip-vertex-fp
          clip-vertex-e

	  clip-vertex-v-set!
	  ;; clip-vertex-fp-set!
          clip-vertex-e-set!

	  is-clip-vertex
	  import-clip-vertex

	  create-clip-vertex
	  )

  (import (rnrs)
	  (box2d-lite util define-record-type)
	  (box2d-lite vec)
	  (box2d-lite edges)
	  )

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-record-type++ clip-vertex
  ;;   is-clip-vertex
  ;;   import-clip-vertex
  ;;   (fields (mutable v)
  ;;           (mutable fp))
  ;;   (methods))

  (define-record-type++ clip-vertex
    is-clip-vertex
    import-clip-vertex
    (fields (mutable v)
	    (mutable e))
    (methods))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (create-clip-vertex)
    (make-clip-vertex
     (make-vec 0.0 0.0)
     (create-edges)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )
     