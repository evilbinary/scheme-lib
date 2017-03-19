;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)  (glut glut) (utils libutil) )
(import (gui imgui))
; (load-lib "libimgui.so")
; ;;(define-c-function int test-main (int string) )
; ;(define-c-function void imgui-test2 (string string int int void* void* void*  ) )
; (define-c-function void imgui-test3 () )
; ;(define-c-function void imgui-render-start () )
; ;(define-c-function void* imgui-make-vec2 (float float))
; ;(define-c-function void imgui-render-end () )
; ;(define-c-function void imgui-init () )
; (define-c-function void test-texture (string void* void* void*) )
; (define-c-function void* imgui-pvec2 (float float) )
; (define-c-function void imgui-uvec2 (void*) )

; (define-c-function boolean imgui-load-style (string) )
; (define-c-function boolean imgui-save-style (string) )
; (define-c-function boolean imgui-reset-style (int) )



(define (imgui-test1)

  (glut-reshape (lambda(w h)
                    (imgui-resize w h)
                     ))
  (glut-touch-event (lambda (type x y)
          (imgui-touch-event type x y)))
  (glut-mouse-event (lambda (button state)
        ;(glut-log "mouse-event")
          (imgui-mouse-event button state)))
  (glut-motion-event (lambda (x y)
        ;(glut-log "motion-event")
        (imgui-motion-event x y)
    ))
  (glut-key-event (lambda (event)
      (glut-log (format "event===>~a"   event ) )
       (imgui-key-event
          (glut-event-get event 'type)
          (glut-event-get event 'keycode)
          (glut-event-get event 'char)
          (glut-event-get event 'chars))
       ; (if (= 4 (glut-event-get event 'keycode ))
       ;   (begin (imgui-exit)
       ;   (glut-exit)))
      ))
  (glut-init (lambda()
       (glut-init-window-size 670 600)
    ))
 
  (imgui-init)
  (imgui-reset-style 7)
  (let ((texture-id (imgui-load-texture "./number.png")))

      (glut-display (lambda ()
              (imgui-render-start)
              
              (imgui-test)
              ; ;(imgui-test3 )


              (imgui-set-next-window-size (imgui-make-vec2 200.0 240.0) 0)
              (imgui-begin "evilbinary" 0)
              (imgui-text "hello,world!")
              (if (imgui-tree-node "node")
                (begin 
                  (if (imgui-button "style6" (imgui-pvec2 50.0 60.0) )
                      (imgui-reset-style 1)
                    )
                  (imgui-same-line)
                  (if (imgui-button "style7" (imgui-pvec2 50.0 60.0) )
                    (imgui-reset-style 7)
                    )
                  (imgui-tree-pop) ))
              (imgui-end)


              ;loadimage
              ;(glut-log (format "texture-id=~a" texture-id))
              (imgui-set-next-window-size (imgui-make-vec2 200.0 180.0) 0)
              (imgui-begin "image" 0)
              (let ((size (imgui-pvec2 128.0 128.0))
                    (uv0 (imgui-pvec2 0.0 0.0))
                    (uv1 (imgui-pvec2 1.0 1.0)) 
                  )
                (imgui-image texture-id  size uv0 uv1 )
                (imgui-image texture-id  size uv0 uv1 )
                (imgui-image texture-id  size uv0 uv1 )
                ;(test-texture "./number.png" size uv0 uv1)
                (imgui-uvec2 uv0)
                (imgui-uvec2 uv1)
                (imgui-uvec2 size)
              )
              (imgui-end)

              (imgui-render-end)
          ))

    (glut-main-loop))
)
(imgui-test1)
