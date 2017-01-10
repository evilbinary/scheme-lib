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
#!r6rs

(library (dharmalab records define-record-type)

  (export define-record-type++)

  (import (rnrs)
          (for (dharmalab misc gen-id) (meta 1)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; define-is-type-syntax
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-get-field-syntax p0 point x)
  ;;
  ;; establishes identifier syntax p0.x
  ;;
  ;; which expands to (point-x p0)

  (define-syntax define-get-field-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var type field)
	 (with-syntax ((var.field (gen-id #'var #'var  "." #'field))
		       (getter    (gen-id #'var #'type "-" #'field)))
	   #'(define-syntax var.field
	       (identifier-syntax
		(getter var))))))))

  ;; (define-set-field-syntax p0 point x)
  ;;
  ;; establishes syntax (p0.x! val)
  ;;
  ;; which expands to (point-x-set! p0 val)

  (define-syntax define-set-field-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var type field)
	 (with-syntax ((var.field! (gen-id #'var #'var  "." #'field "!"))
		       (setter     (gen-id #'var #'type "-" #'field "-set!")))
	   #'(define-syntax var.field!
	       (syntax-rules ()
		 ((var.field! val)
		  (setter var val)))))))))

  ;; (define-typed-field-syntax ship spaceship pos is-point)
  ;;
  ;; establishes syntax
  ;;
  ;;   ship.pos.x
  ;;   ship.pos.y

  (define-syntax define-typed-field-syntax
    (lambda (stx)
      (syntax-case stx ()
        ((_ var type field is-field-type)
         (with-syntax ((var.field (gen-id #'var #'var "." #'field)))
           (syntax
            (is-field-type var.field)))))))

  ;; (define-field-syntax p0 point x)
  
  ;; (define-field-syntax ship spaceship (pos is-point)

  (define-syntax define-field-syntax
    (syntax-rules ()
      ((define-field-syntax var type (field field-type))
       (begin
         (define-get-field-syntax   var type field)
         (define-typed-field-syntax var type field field-type)
         (define-set-field-syntax   var type field)))
      ((define-field-syntax var type field)
       (begin
	 (define-get-field-syntax var type field)
	 (define-set-field-syntax var type field)))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-record-method-syntax p0 neg point::neg)
  ;;
  ;; establishes syntax (p0.neg)
  ;;
  ;; which expands to (point::neg p0)

  (define-syntax define-record-method-syntax
    (lambda (stx)
      (syntax-case stx ()
	((_ var name proc)
	 (with-syntax ((var.name (gen-id #'var #'var "." #'name)))
	   (syntax
	    (define-syntax var.name
	      (syntax-rules ()
		((var.name arg (... ...))
		 (proc var arg (... ...)))))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-is-type-syntax point (fields x y) (methods (neg point::neg)))
  ;;
  ;; establishes syntax (is-point var)
  ;;
  ;; which expands to
  ;;
  ;;   (define-field-syntax var point x) ...
  ;;
  ;;   (define-record-method-syntax var neg point::neg) ...

  (define-syntax define-is-type-syntax

    (lambda (stx)

      (syntax-case stx (fields methods)

        ((_ type #f (fields field ...) (methods (name proc) ...))
         (with-syntax ((is-type (gen-id #'type "is-" #'type)))
           (syntax
            (define-syntax is-type
              (syntax-rules ()
                ((is-type var)
                 (begin
                   (define-field-syntax var type field)
                   ...
                   (define-record-method-syntax var name proc)
                   ...)))))))

        ((_ type parent-type (fields field ...) (methods (name proc) ...))
         (with-syntax ((is-type (gen-id #'type "is-" #'type))
                       (is-parent-type (gen-id #'type "is-" #'parent-type)))
           (syntax
            (define-syntax is-type
              (syntax-rules ()
                ((is-type var)
                 (begin
                   (is-parent-type var)
                   (define-field-syntax var type field)
                   ...
                   (define-record-method-syntax var name proc)
                   ...)))))))

        ;; ((_ type parent-type (fields field ...) (methods (name proc) ...))
        ;;  (with-syntax ((is-type (gen-id #'type "is-" #'type))
        ;;                (is-parent-type (gen-id #'type "is-" #'parent-type)))
        ;;    (syntax
        
        ;;     (define-syntax is-type
        ;;       (lambda (stx)
        ;;         (syntax-case stx ()
        ;;           ((is-type var)
        ;;            (with-syntax ((is-parent-type (gen-id #'var "is-" #'parent-type)))
        ;;              (syntax
        ;;               (begin
        ;;                 (is-parent-type var)
        ;;                 (define-field-syntax var type field)
        ;;                 ...
        ;;                 (define-record-method-syntax var name proc)
        ;;                 ...))))))))))

        )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; define-import-type-syntax
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

  (define-syntax define-imported-typed-field-syntax
    (lambda (stx)
      (syntax-case stx ()
        ((_ var type field is-field-type)
         (with-syntax ((id (gen-id #'var #'field)))
           (syntax
            (is-field-type id)))))))

  ;; (define-syntax define-imported-typed-field-syntax
  ;;   (syntax-rules ()
  ;;     ((_ var type field is-field-type)
  ;;      (is-field-type field))))

  ;; (define-syntax define-imported-field-syntax
  ;;   (syntax-rules ()
  ;;     ((define-imported-field-syntax var type field)
  ;;      (begin
  ;;        (define-imported-get-field-syntax var type field)
  ;;        (define-imported-set-field-syntax var type field)))))

  (define-syntax define-imported-field-syntax
    (syntax-rules ()
      
      ((define-imported-field-syntax var type (field is-field-type))
       (begin
	 (define-imported-get-field-syntax   var type field)
         (define-imported-typed-field-syntax var type field is-field-type)
	 (define-imported-set-field-syntax   var type field)))
      
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
    (lambda (stx)
      (syntax-case stx (fields methods)

        ((_ type #f (fields field ...) (methods (name proc) ...))
         (with-syntax ((import-type (gen-id #'type "import-" #'type)))
           (syntax
            (define-syntax import-type
              (syntax-rules ()
                ((import-type var)
                 (begin
                   (define-imported-field-syntax var type field)
                   ...
                   (define-imported-record-method-syntax var name proc)
                   ...)))))))

        ((_ type parent-type (fields field ...) (methods (name proc) ...))
         (with-syntax ((import-type        (gen-id #'type "import-" #'type))
                       (import-parent-type (gen-id #'type "import-" #'parent-type)))
           (syntax
            (define-syntax import-type
              (syntax-rules ()
                ((import-type var)
                 (begin
                   (import-parent-type var)
                   (define-imported-field-syntax var type field)
                   ...
                   (define-imported-record-method-syntax var name proc)
                   ...)))))))

        )))
  
  

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax define-record-type++

    (lambda (stx)

      (syntax-case stx ()

        ((_ name-spec extended-clause ...)

         (let loop ((extended-clauses    #'(extended-clause ...))
                    (parent-type          #f)
                    (field-specs          '())  ;; non-standard specs
                    (method-specs         '())  ;; non-standard specs
                    (record-clauses-accum '())) ;; standard record clauses
           
           (if (null? extended-clauses)

               (with-syntax ((parent-type parent-type)
                             ((field-spec  ...)   field-specs)
                             ((method-spec ...)   method-specs)
                             ((record-clause ...) (reverse record-clauses-accum))
                             (type-name (syntax-case #'name-spec ()
                                          ((record-name constructor predicate)
                                           #'record-name)
                                          (record-name #'record-name))))
                 
                 (syntax

                  (begin

                    (define-record-type name-spec record-clause ...)

                    (define-is-type-syntax
                      type-name
                      parent-type
                      (fields field-spec ...)
                      (methods method-spec ...))

                    ;; (define-is-type-syntax
                    ;;   type-name
                    ;;   #f
                    ;;   (fields field-spec ...)
                    ;;   (methods method-spec ...))

                    (define-import-type-syntax
                      type-name
                      parent-type
                      (fields field-spec ...)
                      (methods method-spec ...)))))
               
               (syntax-case (car extended-clauses) (parent fields methods)

                 ((parent type)
                  (loop (cdr extended-clauses)
                        #'type
                        field-specs
                        method-specs
                        (cons (car extended-clauses) record-clauses-accum)))

                 ((fields field-spec ...)
                  (loop (cdr extended-clauses)
                        parent-type
                        ;; prepare extended field specs
                        (map (lambda (x)
                               (syntax-case x (mutable)
                                 ( (mutable field-name field-type) #'(field-name field-type) )
                                 ( (mutable field-name)            #'field-name              )
                                 ( (field-name field-type)         #'(field-name field-type) )
                                 ( _                               x                         )))
                             #'(field-spec ...))
                        method-specs
                        ;; prepare standard fields clause
                        (cons (map (lambda (x)
                                     (syntax-case x (mutable)
                                       ( (mutable field-name field-type) #'(mutable field-name) )
                                       ( (mutable field-name)            #'(mutable field-name) )
                                       ( (field-name field-type)         #'field-name           )
                                       ( _                               x                      )))
                                   #'(fields field-spec ...))
                              record-clauses-accum)))
                 
                 ((methods method-spec ...)
                  (loop (cdr extended-clauses)
                        parent-type
                        field-specs
                        #'(method-spec ...)
                        record-clauses-accum))
                 
                 (_
                  (loop (cdr extended-clauses)
                        parent-type
                        field-specs
                        method-specs
                        (cons (car extended-clauses) record-clauses-accum)
                        )))))))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )

