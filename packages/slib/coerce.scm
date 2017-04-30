;;"coerce.scm" Scheme Implementation of COMMON-LISP COERCE and TYPE-OF.
; Copyright (C) 1995, 2001 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require-if 'compiling 'array)

;;@body
;;Returns a symbol name for the type of @1.
(define (type-of obj)
  (cond
   ((boolean? obj)	'boolean)
   ((char? obj)		'char)
   ((number? obj)	'number)
   ((string? obj)	'string)
   ((symbol? obj)	'symbol)
   ((input-port? obj)	'port)
   ((output-port? obj)	'port)
   ((procedure? obj)	'procedure)
   ((eof-object? obj)	'eof-object)
   ((list? obj)		'list)
   ((pair? obj)		'pair)
   ((vector? obj)	'vector)
   ((and (provided? 'array) (array? obj))	'array)
   (else		'?)))

;;@body
;;Converts and returns @1 of type @code{char}, @code{number},
;;@code{string}, @code{symbol}, @code{list}, or @code{vector} to
;;@2 (which must be one of these symbols).
(define (coerce obj result-type)
  (define (err) (slib:error 'coerce 'not obj '-> result-type))
  (define obj-type (type-of obj))
  (cond
   ((eq? obj-type result-type) obj)
   (else
    (case obj-type
      ((char)   (case result-type
		  ((number integer) (char->integer obj))
		  ((string) (string obj))
		  ((symbol) (string->symbol (string obj)))
		  ((list)   (list obj))
		  ((vector) (vector obj))
		  (else     (err))))
      ((number) (case result-type
		  ((char)   (integer->char obj))
		  ((atom)   obj)
		  ((integer) obj)
		  ((string) (number->string obj))
		  ((symbol) (string->symbol (number->string obj)))
		  ((list)   (string->list (number->string obj)))
		  ((vector) (list->vector (string->list (number->string obj))))
		  (else     (err))))
      ((string) (case result-type
		  ((char)   (if (= 1 (string-length obj)) (string-ref obj 0)
				(err)))
		  ((atom)   (or (string->number obj) (string->symbol obj)))
		  ((number integer) (or (string->number obj) (err)))
		  ((symbol) (string->symbol obj))
		  ((list)   (string->list obj))
		  ((vector) (list->vector (string->list obj)))
		  (else     (err))))
      ((symbol) (case result-type
		  ((char)   (coerce (symbol->string obj) 'char))
		  ((number integer) (coerce (symbol->string obj) 'number))
		  ((string) (symbol->string obj))
		  ((atom)   obj)
		  ((list)   (string->list (symbol->string obj)))
		  ((vector) (list->vector (string->list (symbol->string obj))))
		  (else     (err))))
      ((list)   (case result-type
		  ((char)   (if (and (= 1 (length obj))
				     (char? (car obj)))
				(car obj)
				(err)))
		  ((number integer)
		   (or (string->number (list->string obj)) (err)))
		  ((string) (list->string obj))
		  ((symbol) (string->symbol (list->string obj)))
		  ((vector) (list->vector obj))
		  (else     (err))))
      ((vector) (case result-type
		  ((char)   (if (and (= 1 (vector-length obj))
				     (char? (vector-ref obj 0)))
				(vector-ref obj 0)
				(err)))
		  ((number integer)
		   (or (string->number (coerce obj string)) (err)))
		  ((string) (list->string (vector->list obj)))
		  ((symbol) (string->symbol (coerce obj string)))
		  ((list)   (list->vector obj))
		  (else     (err))))
      (else (err))))))
