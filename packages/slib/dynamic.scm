; "dynamic.scm", DYNAMIC data type for Scheme
; Copyright 1992 Andrew Wilcox.
;
; You may freely copy, redistribute and modify this package.

(require 'record)
(require 'dynamic-wind)

(define dynamic-environment-rtd
  (make-record-type "dynamic environment" '(dynamic value parent)))
(define make-dynamic-environment
  (record-constructor dynamic-environment-rtd '(dynamic value parent)))
(define dynamic-environment:dynamic
  (record-accessor dynamic-environment-rtd 'dynamic))
(define dynamic-environment:value
  (record-accessor dynamic-environment-rtd 'value))
(define dynamic-environment:set-value!
  (record-modifier dynamic-environment-rtd 'value))
(define dynamic-environment:parent
  (record-accessor dynamic-environment-rtd 'parent))

(define *current-dynamic-environment* #f)
(define (extend-current-dynamic-environment dynamic obj)
  (set! *current-dynamic-environment*
	(make-dynamic-environment dynamic obj
				  *current-dynamic-environment*)))

(define dynamic-rtd (make-record-type "dynamic" '()))
;@
(define make-dynamic
  (let ((dynamic-constructor (record-constructor dynamic-rtd '())))
    (lambda (obj)
      (let ((dynamic (dynamic-constructor)))
	(extend-current-dynamic-environment dynamic obj)
	dynamic))))
;@
(define dynamic? (record-predicate dynamic-rtd))

(define (guarantee-dynamic dynamic)
  (or (dynamic? dynamic)
      (slib:error "Not a dynamic" dynamic)))

(define dynamic:errmsg
  "No value defined for this dynamic in the current dynamic environment")
;@
(define (dynamic-ref dynamic)
  (guarantee-dynamic dynamic)
  (let loop ((env *current-dynamic-environment*))
    (cond ((not env)
	   (slib:error dynamic:errmsg dynamic))
	  ((eq? (dynamic-environment:dynamic env) dynamic)
	   (dynamic-environment:value env))
	  (else
	   (loop (dynamic-environment:parent env))))))
;@
(define (dynamic-set! dynamic obj)
  (guarantee-dynamic dynamic)
  (let loop ((env *current-dynamic-environment*))
    (cond ((not env)
	   (slib:error dynamic:errmsg dynamic))
	  ((eq? (dynamic-environment:dynamic env) dynamic)
	   (dynamic-environment:set-value! env obj))
	  (else
	   (loop (dynamic-environment:parent env))))))
;@
(define (call-with-dynamic-binding dynamic obj thunk)
  (let ((out-thunk-env #f)
	(in-thunk-env (make-dynamic-environment
		       dynamic obj
		       *current-dynamic-environment*)))
    (dynamic-wind (lambda ()
		    (set! out-thunk-env *current-dynamic-environment*)
		    (set! *current-dynamic-environment* in-thunk-env))
		  thunk
		  (lambda ()
		    (set! in-thunk-env *current-dynamic-environment*)
		    (set! *current-dynamic-environment* out-thunk-env)))))
