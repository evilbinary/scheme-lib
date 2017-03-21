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

(library (dharmalab combinators macros)

  (export identity
          constant
          compose
          ifte
          cleave
          spread
          nary@)

  (import (rnrs))

  (define (identity x) x)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax constant

    (syntax-rules ()

      ( (constant x args)

        (let ((x* x))

          (lambda args

            x*)) )

      ( (constant x)
        (constant x (y)) )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax compose

    (syntax-rules (<=>)

      ( (compose (f) (x ...))
        (lambda (x ...)
          (f x ...)) )

      ( (compose (f g ...) (x ...))
        (lambda (x ...)
          (f ((compose (g ...) (x ...)) x ...))) )

      ( (compose (f ...))
        (compose (f ...) (x)) )

      ( (compose (f) <=>) f )

      ( (compose (f g ...) <=>)
        (lambda args
          (call-with-values
              (lambda ()
                (apply (compose (g ...) <=>) args))
            f)) )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-syntax ifte

  ;;   (syntax-rules ()

  ;;     ( (ifte f g h (x ...))

  ;;       (lambda (x ...)
  ;;         (if (f x ...)
  ;;             (g x ...)
  ;;             (h x ...))) )

  ;;     ( (ifte f g h)

  ;;       (ifte f g h (x)) )

  ;;     ( (ifte f g h args)

  ;;       (lambda args
  ;;         (if (apply f args)
  ;;             (apply g args)
  ;;             (apply h args))) )

  ;;     ))

  (define-syntax ifte
    (syntax-rules ()
      ( (ifte f g h (x ...))

        (let ((f* f)
              (g* g)
              (h* h))
          
          (lambda (x ...)
            (if (f* x ...)
                (g* x ...)
                (h* x ...)))) )
      
      ( (ifte f g h)
        (ifte f g h (x)) )

      ( (ifte f g h args)

        (let ((f* f)
              (g* g)
              (h* h))

          (lambda args
            (if (apply f args)
                (apply g args)
                (apply h args)))) )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; (define-syntax cleave

  ;;   (syntax-rules ()

  ;;     ( (cleave (f ...) c (x ...))
  ;;       (lambda (x ...)
  ;;         (c (f x ...)
  ;;            ...)) )

  ;;     ( (cleave (f ...) c)
  ;;       (cleave (f ...) c (x)) )))

  (define-syntax cleave

    (syntax-rules ()

      ( (cleave (f ...) (x ...) c)
        (lambda (x ...)
          (c (f x ...)
             ...)) )

      ( (cleave (f ...) c)
        (cleave (f ...) (x) c) )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax spread
    (lambda (stx)
      (syntax-case stx ()
        ( (spread (f ...) c)
          (with-syntax ( ( (x ...) (generate-temporaries (syntax (f ...))) ) )
            (syntax
             (lambda (x ...)
               (c (f x)
                  ...)))) ))))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define-syntax nary@
    (syntax-rules ()
      ( (nary@ f (x ...) c)
        (lambda (x ...)
          (c (f x)
             ...)) )))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )