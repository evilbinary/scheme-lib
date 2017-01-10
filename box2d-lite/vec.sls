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

(library (box2d-lite vec)

  (export make-vec is-vec import-vec
	  
	  vec-x vec-x-set!
	  vec-y vec-y-set!
	  
	  vec::set vec::length vec::abs vec::neg

	  v+ v- v* v/  v+n v-n v*n v/n  n+v n-v n*v n/v

	  vec-dot  vxv vxn nxv  v-v)

  (import (rnrs) (box2d-lite util define-record-type))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-record-type++ vec is-vec import-vec

    (fields (mutable x)
	    (mutable y))
    
    (methods (set    vec::set)
	     (length vec::length)
	     (abs    vec::abs)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (vec::set v new-x new-y)
    (import-vec v)
    (x! new-x)
    (y! new-y))

  (define (vec::length v)
    (import-vec v)
    (sqrt (+ (* x x) (* y y))))

  (define (vec::abs v)
    (is-vec v)
    (make-vec (abs v.x) (abs v.y)))

  (define (vec::neg v)
    (is-vec v)
    (make-vec (- v.x) (- v.y)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (v-op-v op)
    (lambda (a b)
      (is-vec a)
      (is-vec b)
      (make-vec (op a.x b.x)
		(op a.y b.y))))

  (define v+ (v-op-v +))
  (define v- (v-op-v -))
  (define v* (v-op-v *))
  (define v/ (v-op-v /))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (v-op-n op)
    (lambda (v n)
      (is-vec v)
      (make-vec (op v.x n)
		(op v.y n))))

  (define v+n (v-op-n +))
  (define v-n (v-op-n -))
  (define v*n (v-op-n *))
  (define v/n (v-op-n /))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (n-op-v op)
    (lambda (n v)
      (is-vec v)
      (make-vec (op n v.x)
		(op n v.y))))

  (define n+v (n-op-v +))
  (define n-v (n-op-v -))
  (define n*v (n-op-v *))
  (define n/v (n-op-v /))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (vec-dot a b)
    (is-vec a)
    (is-vec b)
    (+ (* a.x b.x)
       (* a.y b.y)))

  (define (vxv a b)
    (is-vec a)
    (is-vec b)
    (- (* a.x b.y)
       (* a.y b.x)))

  (define (vxn v n)
    (is-vec v)
    (make-vec (*    n  v.y)
	      (* (- n) v.x)))

  (define (nxv n v)
    (is-vec v)
    (make-vec (* (- n) v.y)
	      (*    n  v.x)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax v-v
    (syntax-rules ()
      ((v-v a b)
       (v- a b))
      ((v-v a b c ...)
       (v-v (v- a b) c ...))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )