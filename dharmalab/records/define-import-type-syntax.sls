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

(library (dharmalab records define-import-type-syntax)

  (export define-import-type-syntax)

  (import (rnrs)
          (for (dharmalab misc gen-id) (meta 1)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax define-imported-get-field-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var type field)
	 (with-syntax ((name   (gen-id #'var #'field))
		       (getter (gen-id #'var #'type "-" #'field)))
	   #'(define-syntax name
	       (identifier-syntax
		(getter var))))))))

  (define-syntax define-imported-set-field-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var type field)
	 (with-syntax ((name!  (gen-id #'var #'field "!"))
		       (setter (gen-id #'var #'type "-" #'field "-set!")))
	   #'(define-syntax name!
	       (syntax-rules ()
		 ((name! val)
		  (setter var val)))))))))

  (define-syntax define-imported-field-syntax
    (syntax-rules ()
      ((define-imported-field-syntax var type field)
       (begin
	 (define-imported-get-field-syntax var type field)
	 (define-imported-set-field-syntax var type field)))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax define-imported-record-method-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var name proc)
	 (with-syntax ((met (gen-id #'var #'name)))
	   #'(define-syntax met
	       (syntax-rules ()
		 ((met arg (... ...))
		  (proc var arg (... ...))))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax define-import-type-syntax
    (syntax-rules (fields methods)
      ((_ import-type type (fields field ...) (methods (name proc) ...))
       (define-syntax import-type
	 (syntax-rules ()
	   ((import-type var)
	    (begin
	      (define-imported-field-syntax var type field)
	      ...
	      (define-imported-record-method-syntax var name proc)
	      ...)))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )