;"values.scm" multiple values
;By david carlton, carlton@husc.harvard.edu.
;
;This code is in the public domain.

(require 'record)

(define values:*values-rtd*
  (make-record-type "values"
		    '(values)))
;@
(define values
  (let ((make-values (record-constructor values:*values-rtd* '(values))))
    (lambda x
      (if (and (not (null? x))
	       (null? (cdr x)))
	  (car x)
	  (make-values x)))))
;@
(define call-with-values
  (let ((access-values (record-accessor values:*values-rtd* 'values))
	(values-predicate? (record-predicate values:*values-rtd*)))
    (lambda (producer consumer)
      (let ((result (producer)))
	(if (values-predicate? result)
	    (apply consumer (access-values result))
	    (consumer result))))))
