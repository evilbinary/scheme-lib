(require 'record)
(define-syntax define-record-field
  (syntax-rules ()
    ((define-record-field type field-tag accessor)
     (define accessor (record-accessor type 'field-tag)))
    ((define-record-field type field-tag accessor modifier)
     (begin (define accessor (record-accessor type 'field-tag))
	    (define modifier (record-modifier type 'field-tag))))))
;@
(define-syntax define-record-type
  (syntax-rules ()
    ((define-record-type type (constructor constructor-tag ...) predicate (field-tag accessor . more) ...)
     (begin (define type (make-record-type 'type '(field-tag ...)))
	    (define constructor (record-constructor type '(constructor-tag ...)))
	    (define predicate (record-predicate type))
	    (define-record-field type field-tag accessor . more) ...))))
