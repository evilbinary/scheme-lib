;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (glut glut)
  (export glut-init glut-main-loop glut-exit glut-sleep
   glut-display glut-event glut-touch-event glut-motion-event
   glut-mouse-event glut-key-event glut-reshape glut-idle
   glut-vector glut-unvector glut-sleep glut-test glut-log
   glut-test-rotatef glut-set-gl-version
   glut-set-soft-input-mode glut-show-soft-input
   glut-hide-soft-input glut-event-get glut-init-window-size
   glut-init-window-position glut-set-window-title
   glut-init-callback glut-on-key-event-callback
   glut-on-touch-event-callback glut-on-display-callback
   glut-on-reshape-callback glut-on-mouse-event-callback
   glut-on-motion-event-callback glut-on-idle-callback)
  (import (scheme) (utils libutil))
  (define lib-name
    (case (machine-type)
      [(arm32le) "libglut.so"]
      [(a6nt i3nt ta6nt ti3nt)
       (load-lib "glut32.dll")
       "libglut.dll"]
      [(a6osx i3osx ta6osx ti3osx) "libglut.so"]
      [(a6le i3le ta6le ti3le) "libglut.so"]))
  (define lib (load-lib lib-name))
  (define-syntax define-glut
    (syntax-rules ()
      [(_ ret name args)
       (define name
         (foreign-procedure (lower-camel-case
                              (string-split (symbol->string 'name) #\-)) args
           ret))]))
  (define glut-init-proc '())
  (define glut-idle-proc '())
  (define glut-display-proc '())
  (define glut-reshape-proc '())
  (define glut-touch-event-proc '())
  (define glut-key-event-proc '())
  (define glut-motion-event-proc '())
  (define glut-mouse-event-proc '())
  (define glut-init-op
    (foreign-procedure "glut_init" () void))
  (define (glut-init . args)
    (if (= 0 (length args))
        (glut-init-op)
        (if (procedure? (car args))
            (begin (set! glut-init-proc (car args)) (glut-init-op)))))
  (define glut-sleep
    (foreign-procedure "glut_sleep" (int) void))
  (define glut-main-loop
    (foreign-procedure "glut_main_loop" () void))
  (define glut-exit (foreign-procedure "glut_exit" () void))
  (define glut-test (foreign-procedure "glut_test" () void))
  (define glut-log
    (foreign-procedure "glut_log" (string) void))
  (define glut-test-rotatef
    (foreign-procedure "glut_test_rotatef"
      (float float float float)
      void))
  (define glut-set-gl-version
    (foreign-procedure "glut_set_gl_version" (int) void))
  (define glut-set-soft-input-mode
    (foreign-procedure "glut_set_soft_input_mode"
      (int int)
      void))
  (define-glut void glut-init-window-size (int int))
  (define-glut void glut-init-window-position (int int))
  (define-glut void glut-set-window-title (string))
  (define is-soft-input-show #f)
  (define glut-show-soft-input
    (lambda ()
      (if (not is-soft-input-show)
          (begin
            (glut-set-soft-input-mode 1 0)
            (set! is-soft-input-show #t)))))
  (define glut-hide-soft-input
    (lambda ()
      (if is-soft-input-show
          (begin
            (glut-set-soft-input-mode 0 1)
            (set! is-soft-input-show #f)))))
  (define (glut-init-callback)
    (glut-log "glut-init-proc")
    (if (procedure? glut-init-proc) (glut-init-proc)))
  (define (glut-on-key-event-callback . args)
    (if (procedure? glut-key-event-proc)
        (if (= 2 (length args))
            (glut-key-event-proc (car args) (cadr args))
            (glut-key-event-proc args))))
  (define (glut-on-touch-event-callback type x y)
    (if (procedure? glut-touch-event-proc)
        (glut-touch-event-proc type x y)))
  (define (glut-on-mouse-event-callback button state)
    (if (procedure? glut-mouse-event-proc)
        (glut-mouse-event-proc button state)))
  (define (glut-on-motion-event-callback x y)
    (if (procedure? glut-motion-event-proc)
        (glut-motion-event-proc x y)))
  (define (glut-on-display-callback)
    (if (procedure? glut-display-proc) (glut-display-proc)))
  (define (glut-on-reshape-callback w h)
    (if (procedure? glut-reshape-proc) (glut-reshape-proc w h)))
  (define (glut-on-idle-callback)
    (if (procedure? glut-idle-proc) (glut-idle-proc)))
  (define (glut-event proc) (set! glut-touch-event-proc proc))
  (define (glut-touch-event proc)
    (set! glut-touch-event-proc proc))
  (define (glut-key-event proc)
    (set! glut-key-event-proc proc))
  (define (glut-motion-event proc)
    (set! glut-motion-event-proc proc))
  (define (glut-mouse-event proc)
    (set! glut-mouse-event-proc proc))
  (define (glut-display proc) (set! glut-display-proc proc))
  (define (glut-reshape proc) (set! glut-reshape-proc proc))
  (define (glut-idle proc) (set! glut-idle-proc proc))
  (define (glut-event-get event name)
    (cond
      [(equal? name 'type) (list-ref event 0)]
      [(equal? name 'keycode) (list-ref event 1)]
      [(equal? name 'char) (list-ref event 2)]
      [(equal? name 'chars) (list-ref event 3)]
      [else (void)]))
  (define (glut-vector type vec)
    (if (list? vec) (set! vec (list->vector vec)))
    (let* ([len (vector-length vec)]
           [size (foreign-sizeof type)]
           [data (foreign-alloc (* len size))])
      (let loop ([i 0])
        (if (< i len)
            (let ([v (vector-ref vec i)])
              (cond
                [(flonum? v) (foreign-set! type data (* i size) v)]
                [(fixnum? v) (foreign-set! type data (* i size) v)])
              (loop (+ i 1)))))
      data))
  (define (glut-unvector vec) (foreign-free vec)))

