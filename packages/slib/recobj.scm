;;; "recobj.scm" Records implemented as objects.
;;; Author: Wade Humeniuk <humeniuw@cadvision.com>
;;;
;;; This code is in the public domain.

(require 'object)
(require 'common-list-functions)
(define field:position position)
;@
(define record-type-name (make-generic-method))
(define record-accessor (make-generic-method))
(define record-modifier (make-generic-method))
(define record? (make-generic-predicate))
(define record-constructor (make-generic-method))
;@
(define (make-record-type type-name field-names)
  (define self (make-object))

  (make-method! self record-type-name
		(lambda (self)
		  type-name))
  (make-method! self record-accessor
		(lambda (self field-name)
		  (let ((index (field:position field-name field-names)))
		    (if (not index)
			(slib:error "record-accessor: invalid field-name argument."
				    field-name))
		    (lambda (obj)
		      (record-accessor obj index)))))

  (make-method! self record-modifier
		(lambda (self field-name)
		  (let ((index (field:position field-name field-names)))
		    (if (not index)
			(slib:error "record-accessor: invalid field-name argument."
				    field-name))
		    (lambda (obj newval)
		      (record-modifier obj index newval)))))

  (make-method! self record? (lambda (self) #t))

  (make-method! self record-constructor
		(lambda (class . field-values)
		  (let ((values (apply vector field-values)))
		    (define self (make-object))
		    (make-method! self record-accessor
				  (lambda (self index)
				    (vector-ref values index)))
		    (make-method! self record-modifier
				  (lambda (self index newval)
				    (vector-set! values index newval)))
		    (make-method! self record-type-name
				  (lambda (self) (record-type-name class)))
		    self)))
  self)

(provide 'record-object)
(provide 'record)
