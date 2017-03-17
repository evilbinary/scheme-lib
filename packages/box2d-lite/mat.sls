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

(library (box2d-lite mat)

  (export make-mat

	  mat-col-1
	  mat-col-2

	  mat-col-1-set!
	  mat-col-2-set!

	  is-mat
	  import-mat

	  mat::abs
	  mat::transpose
	  mat::invert

	  m+
	  m*
	  
	  m*v

	  mat-by-rows
	  m+m
	  angle->mat
	  )

  (import (rnrs)

	  (box2d-lite util define-record-type)
	  
	  (box2d-lite vec))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ mat
    is-mat
    import-mat
    (fields (mutable col-1)
	    (mutable col-2))
    (methods (transpose mat::transpose)
	     (invert    mat::invert)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (mat::abs m)
    (is-mat m)
    (make-mat (vec::abs m.col-1)
	      (vec::abs m.col-2)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (mat::transpose m)

    (import-mat m)

    (is-vec col-1)
    (is-vec col-2)

    (make-mat (make-vec col-1.x col-2.x)
	      (make-vec col-1.y col-2.y)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (mat::invert m)

    (import-mat m)

    (is-vec col-1)
    (is-vec col-2)

    (let ((a col-1.x) (b col-2.x) (c col-1.y) (d col-2.y))

      (let ((det (/ 1.0 (- (* a d) (* b c)))))

	(mat-by-rows (* det d   ) (* det b -1)
		     (* det c -1) (* det a   )))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (m+ a b)

    (is-mat a)
    (is-mat b)

    (make-mat (v+ a.col-1 b.col-1)
	      (v+ a.col-2 b.col-2)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (m*v m v)

    (is-mat m)
    (is-vec v)

    (is-vec m.col-1)
    (is-vec m.col-2)

    (make-vec (+ (* m.col-1.x v.x)
		 (* m.col-2.x v.y))
	      (+ (* m.col-1.y v.x)
		 (* m.col-2.y v.y))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (m* a b)

    (is-mat a)
    (is-mat b)

    (make-mat (m*v a b.col-1)
	      (m*v a b.col-2)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax mat-by-rows
    (syntax-rules ()
      ((_ (a b) (c d))
       (make-mat (make-vec a c)
		 (make-vec b d)))
      ((_ a b c d)
       (mat-by-rows (a b)
		    (c d)))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax m+m
    (syntax-rules ()
      ((m+m a b) (m+ a b))
      ((m+m a b c ...)
       (m+m (m+ a b) c ...))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (angle->mat angle)

    (let ((c (cos angle))
	  (s (sin angle)))

      (mat-by-rows c (- s)
		   s    c)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )
	    