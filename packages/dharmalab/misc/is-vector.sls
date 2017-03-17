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

(library (dharmalab misc is-vector)

  (export is-vector)

  (import (rnrs)
          (for (dharmalab misc gen-id) (meta 1))
          )

  ;; (define-syntax is-vector

  ;;   (lambda (stx)

  ;;     (syntax-case stx ()

  ;; 	((is-vector name)

  ;; 	 (with-syntax ( (name.ref      (gen-id #'name #'name ".ref"))
  ;; 			(name.set!     (gen-id #'name #'name ".set!"))
  ;; 			(name.length   (gen-id #'name #'name ".length"))
  ;; 			(name.map      (gen-id #'name #'name ".map"))
  ;; 			(name.for-each (gen-id #'name #'name ".for-each")) )

  ;; 	   #'(begin

  ;; 	       (define (name.ref i) (vector-ref name i))

  ;; 	       (define (name.set! i val) (vector-set! name i val))

  ;; 	       (define (name.length) (vector-length name))

  ;; 	       (define (name.map proc) (vector-map proc name))

  ;; 	       (define (name.for-each proc) (vector-for-each proc name))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax is-vector

    (lambda (stx)

      (syntax-case stx ()

	((is-vector name j ...)

	 (with-syntax ( (name.ref      (gen-id #'name #'name ".ref"))
			(name.set!     (gen-id #'name #'name ".set!"))
			(name.length   (gen-id #'name #'name ".length"))
			(name.map      (gen-id #'name #'name ".map"))
			(name.for-each (gen-id #'name #'name ".for-each"))

			((name.j ...)
			 (map (lambda (x)
				(gen-id x #'name "." x))
			      #'(j ...)))

			((name.j! ...)
			 (map (lambda (x)
				(gen-id x #'name "." x "!"))
			      #'(j ...)))
			
			)

	   #'(begin

	       (define (name.ref i) (vector-ref name i))

	       (define (name.set! i val) (vector-set! name i val))

	       (define (name.length) (vector-length name))

	       (define (name.map proc) (vector-map proc name))

	       (define (name.for-each proc) (vector-for-each proc name))

	       (define-syntax name.j
		 (identifier-syntax
		  (vector-ref name j)))
	       ...

	       (define (name.j! val)
		 (vector-set! name j val))
	       ...
	       ))))))

  )