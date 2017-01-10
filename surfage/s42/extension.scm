; <PLAINTEXT>
; Examples for Application Specific Extensions of Eager Comprehensions
; ====================================================================
;
; sebastian.egner@philips.com, Eindhoven, The Netherlands, Feb-2003.
; Scheme R5RS (incl. macros), SRFI-23 (error).
; 
; Running the extensions in Scheme48 (version 0.57):
;   ; load "examples.scm" as described there
;   ,load extension.scm
;
; Running the extensions in PLT (version 202):
;   ; load "examples.scm" as described there
;   (load "extension.scm")
;
; Running the extensions in SCM (version 5d7):
;   ; load "examples.scm" as described there
;   (load "extension.scm")

; reset SRFI

(set! :-dispatch (make-initial-:-dispatch))

(define my-check-correct 0)
(define my-check-wrong   0)


; ==========================================================================
; Extending the predefined dispatching generator
; ==========================================================================

; example from SRFI document (for :dispatch)

(define (example-dispatch args)
  (cond
   ((null? args)
    'example )
   ((and (= (length args) 1) (symbol? (car args)) )
    (:generator-proc (:string (symbol->string (car args)))) )
   (else
    #f )))

(:-dispatch-set! (dispatch-union (:-dispatch-ref) example-dispatch))

; run the example

(my-check (list-ec (: c 'abc) c) => '(#\a #\b #\c))


; ==========================================================================
; Adding an application specific dispatching generator
; ==========================================================================

; example from SRFI document (for :dispatch)

(define (:my-dispatch args)
  (case (length args)
    ((0) 'example)
    ((1) (let ((a1 (car args)))
           (cond
            ((list? a1)
             (:generator-proc (:list a1)) )
            ((string? a1)
             (:generator-proc (:string a1)) )
;           ...more unary cases...
            (else
             #f ))))
    ((2) (let ((a1 (car args)) (a2 (cadr args)))
           (cond
            ((and (list? a1) (list? a2))
             (:generator-proc (:list a1 a2)) )
;           ...more binary cases...
            (else
             #f ))))
;   ...more arity cases...
    (else
     (cond
      ((every?-ec (:list a args) (list? a))
       (:generator-proc (:list (apply append args))) )
;     ...more large variable arity cases...
      (else
       #f )))))

(define-syntax :my
  (syntax-rules (index)
    ((:my cc var (index i) arg1 arg ...)
     (:dispatched cc var (index i) :my-dispatch arg1 arg ...) )
    ((:my cc var arg1 arg ...)
     (:dispatched cc var :my-dispatch arg1 arg ...) )))

; run the example

(my-check (list-ec (:my x "abc") x) => '(#\a #\b #\c))

(my-check (list-ec (:my x '(1) '(2) '(3)) x) => '(1 2 3))

(my-check 
  (list-ec (:my x (index i) "abc") (list x i)) 
  => '((#\a 0) (#\b 1) (#\c 2)) )


; ==========================================================================
; Adding an application specific typed generator
; ==========================================================================

; example from SRFI document

(define-syntax :mygen
  (syntax-rules ()
    ((:mygen cc var arg)
     (:list cc var (reverse arg)) )))

; run the example

(my-check (list-ec (:mygen x '(1 2 3)) x) => '(3 2 1))


; ==========================================================================
; Adding application specific comprehensions
; ==========================================================================

; example from SRFI document

(define-syntax new-list-ec
  (syntax-rules ()
    ((new-list-ec etc1 etc ...)
     (reverse (fold-ec '() etc1 etc ... cons)) )))

(define-syntax new-min-ec
  (syntax-rules ()
    ((new-min-ec etc1 etc ...)
     (fold3-ec (min) etc1 etc ... min min) )))

(define-syntax new-fold3-ec
  (syntax-rules (nested)
    ((new-fold3-ec x0 (nested q1 ...) q etc1 etc2 etc3 etc ...)
     (new-fold3-ec x0 (nested q1 ... q) etc1 etc2 etc3 etc ...) )
    ((new-fold3-ec x0 q1 q2 etc1 etc2 etc3 etc ...)
     (new-fold3-ec x0 (nested q1 q2) etc1 etc2 etc3 etc ...) )
    ((new-fold3-ec x0 expression f1 f2)
     (new-fold3-ec x0 (nested) expression f1 f2) )

    ((new-fold3-ec x0 qualifier expression f1 f2)
     (let ((result #f) (empty #t))
       (do-ec qualifier
              (let ((value expression)) ; don't duplicate
                (if empty
                    (begin (set! result (f1 value))
                           (set! empty #f) )
                    (set! result (f2 value result)) )))
       (if empty x0 result) ))))

; run the example

(my-check (new-list-ec (: i 5) i) => '(0 1 2 3 4))

(my-check (new-min-ec (: i 5) i) => 0)

(my-check 
 (let ((f1 (lambda (x) (list 'f1 x)))
       (f2 (lambda (x result) (list 'f2 x result))) )
   (new-fold3-ec (error "bad") (: i 5) i f1 f2) )
 => '(f2 4 (f2 3 (f2 2 (f2 1 (f1 0))))) )


; ==========================================================================
; Summary
; ==========================================================================

(begin
  (newline)
  (newline)
  (display "correct examples : ")
  (display my-check-correct)
  (newline)
  (display "wrong examples   : ")
  (display my-check-wrong)
  (newline)
  (newline) )

