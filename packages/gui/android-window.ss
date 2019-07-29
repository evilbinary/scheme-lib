;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui android-window)
  (export window-create window-destroy window-loop
    window-get-mouse-pos window-get-mouse-x window-get-mouse-y
    window-show-fps window-post-empty-event window-set-fps-pos
    window-add-loop window-loop-one window-set-wait-mode
    window-set-size window-set-title window-set-input-mode)
  (import (scheme) (cffi cffi) (utils libutil) (gui android)
    (gui widget) (gles gles2) (gui graphic) (glut glut))
  (define mouse-x 0)
  (define mouse-y 0)
  (define is-show-fps #f)
  (define fps-x 0.0)
  (define fps-y 0.0)
  (define all-loops (list))
  (define event-wait-mode #t)
  (define ratio 1.0)
  (define cursors (make-hashtable equal-hash equal?))
  (define (window-set-input-mode window mode) '())
  (define (window-cursor-init) '())
  (define (window-set-cursor window mod) '())
  (define (window-post-empty-event) '())
  (define (window-set-title window title) '())
  (define (window-set-size window w h) '())
  (define (window-set-fps-pos x y)
    (set! fps-x x)
    (set! fps-y y))
  (define (window-show-fps t) (set! is-show-fps t))
  (define (window-get-mouse-x window) mouse-x)
  (define (window-get-mouse-y window) mouse-y)
  (define (window-set-wait-mode t) (set! event-wait-mode t))
  (define (window-get-mouse-pos window)
    (list mouse-x mouse-y))
  (define (window-event-init window)
    (glut-touch-event
      (lambda (type x y)
        (glut-log (format "type ~a ~a ~a" type x y))
        (set! mouse-x x)
        (set! mouse-y y)
        (widget-event 1 (vector x y))
        (case type
          [2 (widget-scroll-event (vector x y mouse-x mouse-y))]
          [0
           (widget-mouse-button-event (vector 0 1 0 mouse-x mouse-y))]
          [1
           (widget-mouse-button-event
             (vector 0 0 0 mouse-x mouse-y))])))
    (glut-motion-event
      (lambda (x y)
        (set! mouse-x x)
        (set! mouse-y y)
        (widget-event 1 (vector x y))
        (widget-scroll-event (vector x y mouse-x mouse-y))))
    (glut-mouse-event
      (lambda (button state)
        (glut-log (format "mouse-event ~a ~a" button state))
        (if (= state 0)
            (widget-mouse-button-event
              (vector button 1 0 mouse-x mouse-y))
            (widget-mouse-button-event
              (vector button 0 0 mouse-x mouse-y)))))
    (glut-key-event
      (lambda (event) (glut-log (format "event ~a" event))))
    '())
  (define (window-create width height title)
    (let ([window '()])
      (glut-log (format "window-create ~a ~a\n" width height))
      (glut-set-gl-version 2)
      (glut-init
        (lambda ()
          (glut-log (format "glut init finish callback"))
          (glut-display
            (lambda ()
              (glClearColor 0.3 0.3 0.32 1.0)
              (glClear (+ GL_COLOR_BUFFER_BIT))
              (if is-show-fps
                  (graphic-draw-text
                    fps-x
                    fps-y
                    (format "fps=~a\n" (graphic-get-fps))))
              (widget-render)
              (window-run-loop)))
          (glut-reshape
            (lambda (w h)
              (glut-log (format "reshape ~a ~a" w h))
              (glViewport
                0
                0
                (flonum->fixnum (* w ratio 1.0))
                (flonum->fixnum (* h ratio 1.0)))
              (glut-log (format "widget-window-resize"))
              (widget-window-resize w h)
              (glut-log (format "glClearColor"))
              (glClearColor 0.3 0.3 0.32 1.0)
              (glClear (+ GL_COLOR_BUFFER_BIT))
              (glut-log (format "widget-render"))
              (widget-render)
              (glut-log (format "reshape end"))))))
      (glut-log "glut-init lambda")
      (window-cursor-init)
      (widget-init-cursor (lambda (mod) '()))
      (widget-init width height ratio)
      (window-event-init '())
      (glut-log "window-create end")
      window))
  (define (window-add-loop fun)
    (set! all-loops (append all-loops (list fun))))
  (define (window-run-loop)
    (let loop ([l all-loops])
      (if (pair? l) (begin ((car l)) (loop (cdr l))))))
  (define (window-loop-one window)
    (glClearColor 0.3 0.3 0.32 1.0)
    (glClear (+ GL_COLOR_BUFFER_BIT))
    (if is-show-fps
        (graphic-draw-text
          fps-x
          fps-y
          (format "fps=~a\n" (graphic-get-fps))))
    (widget-render)
    (window-run-loop))
  (define (window-loop window)
    (glClearColor 0.3 0.3 0.32 1.0)
    (glClear (+ GL_COLOR_BUFFER_BIT))
    (glEnable GL_BLEND)
    (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
    (widget-layout)
    (glut-log (format "glut-main-loop start"))
    (glut-main-loop)
    (glut-log (format "glut-main-loop end")))
  (define (window-destroy window) '()))

