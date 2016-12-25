;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (glut)
    (export glut-init
            glut-main-loop
            glut-exit
            glut-display
            glut-event
            glut-touch-event
            glut-key-event
            glut-reshape

            glut-vector
            glut-unvector

            glut-test
            glut-log
            glut-test-rotatef
            glut-set-gl-version
            glut-set-soft-input-mode
            glut-show-soft-input
            glut-hide-soft-input
            glut-event-get

            glut-init-callback
            glut-on-key-event-callback
            glut-on-touch-event-callback
            glut-on-display-callback
            glut-on-reshape-callback
            )
    (import (scheme) (utils libutil) )
    (define lib-name
     (case (machine-type)
       ((arm32le) "libglut.so")
       ((i3osx)  "OpenGLES1.framework/OpenGLES1")))

    (define lib (load-lib lib-name))


    (define glut-display-proc '())
    (define glut-reshape-proc '())
    (define glut-touch-event-proc '())
    (define glut-key-event-proc '())

    (define glut-init
      (foreign-procedure "glut_init" () void))
    
    (define glut-main-loop
      (foreign-procedure "glut_main_loop" () void))

    (define glut-exit
      (foreign-procedure "glut_exit" () void))

    (define glut-test
      (foreign-procedure "glut_test" () void))
    
    (define glut-log
      (foreign-procedure "glut_log" (string) void))

    (define glut-test-rotatef
       (foreign-procedure "glut_test_rotatef" (float float float float) void))
    (define glut-set-gl-version
           (foreign-procedure "glut_set_gl_version" (int) void))
    (define glut-set-soft-input-mode
                      (foreign-procedure "glut_set_soft_input_mode" (int int) void))

    (define is-soft-input-show #f)
    (define glut-show-soft-input (lambda ()
        (if (not is-soft-input-show)
            (begin
                (glut-set-soft-input-mode 1 0)
                (set! is-soft-input-show #t)))
        ))
    (define glut-hide-soft-input (lambda ()
            (if  is-soft-input-show
                (begin
                    (glut-set-soft-input-mode 0 1)
                    (set! is-soft-input-show #f)))
            ))

    (define (glut-init-callback)
      1
    )

    (define (glut-on-key-event-callback . args)
          (if (procedure? glut-key-event-proc)
              (if (= 2 (length args) )
                ;(glut-log "on-key-event callback arg==2")
                (glut-key-event-proc (car args) (cadr args))
                (glut-key-event-proc (car args) )
                )
              )
          )
    (define (glut-on-touch-event-callback type x y)
          ;(display "glut-on-event-callback")
          ;(display type)
          ;(display x)
          ;(display y)
          (if (procedure? glut-touch-event-proc)
              (glut-touch-event-proc type x y)
              )
          )

    (define (glut-on-display-callback)
      ;(display "glut-on-display-callback")
      (if (procedure? glut-display-proc)
          (glut-display-proc))
      )


     (define (glut-on-reshape-callback w h)
      ;(display "glut-on-reshape-callback")
      (if (procedure? glut-reshape-proc)
          (glut-reshape-proc w h))
      )
    
    (define (glut-event proc)
      ;(display "glut-event")
      (set! glut-touch-event-proc proc)
      )
    (define (glut-touch-event proc)
          ;(display "glut-event")
          (set! glut-touch-event-proc proc)
          )
    (define (glut-key-event proc)
          ;(display "glut-event")
          (set! glut-key-event-proc proc)
          )

    (define (glut-display proc)
      (set! glut-display-proc proc))

    (define (glut-reshape proc)
      (set! glut-reshape-proc proc))

    (define (glut-event-get event name)
        (if (eq? name 'chars)
            (hashtable-ref event name "")
            (hashtable-ref event name 0)))


    (define (glut-vector type vec )
      (if (list? vec)
          (set! vec (list->vector vec)))
      (let* ((len (vector-length vec))
             (size (foreign-sizeof type))
            (data (foreign-alloc (*  len size)))
            )
        (let loop ((i  0)) 
          (if (< i len)
              (let ((v (vector-ref vec i)))
                (cond
                  ((flonum? v) (foreign-set! type data (* i size) v))
                  ((fixnum? v) (foreign-set! type data (* i size) v)))
                     (loop (+ i 1)
                           )
                     )))
        data))
    (define (glut-unvector vec)
      (foreign-free vec))

   
    
)