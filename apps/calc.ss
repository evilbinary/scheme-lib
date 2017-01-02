;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (gles1)  (glut) (imgui)  )
(define (app-calc)
      (glut-init)
      (imgui-init)
      ;(android)
      ;(imgui-scale (* 1.5 (android-get-density)) (* 1.5 (android-get-density)))
      (glut-touch-event (lambda (type x y)
          (imgui-touch-event type x y)

          ))
      (glut-mouse-event (lambda (button state)
        ;(glut-log "mouse-event")
          (imgui-mouse-event button state)))
      (glut-motion-event (lambda (x y)
            ;(glut-log "motion-event")
            (imgui-motion-event x y)
        ))
      (glut-key-event (lambda (event)
          (imgui-key-event
             (glut-event-get event 'type)
             (glut-event-get event 'keycode)
             (glut-event-get event 'char)
             (glut-event-get event 'chars))
           (if (= 4 (glut-event-get event 'keycode ))
             (begin (imgui-exit)
             (glut-exit)))
          ))

      (glut-display (lambda ()
              (imgui-render-start)
              ;(imgui-test)
              (imgui-set-next-window-size (imgui-make-vec2 210.0 230.0) 1)
              (imgui-begin "calculator" 0)
              (imgui-text "exp:")
              (imgui-separator)
              (if (imgui-button "7" (imgui-make-vec2 40.0 40.0) )
                1;
              )
              (imgui-same-line)
              (if (imgui-button "8" (imgui-make-vec2 40.0 40.0) )
                              1;
               )
               (imgui-same-line)
               (if (imgui-button "9" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )

               (if (imgui-button "4" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )
               (imgui-same-line)
               (if (imgui-button "5" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )
               (imgui-same-line)
               (if (imgui-button "6" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )

               (if (imgui-button "1" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )
               (imgui-same-line)
               (if (imgui-button "2" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )
               (imgui-same-line)
               (if (imgui-button "3" (imgui-make-vec2 40.0 40.0) )
                                             1;
                              )

               (if (imgui-button "0" (imgui-make-vec2 40.0 40.0) )
                                                            1;
                                             )
               (imgui-same-line)
               (if (imgui-button "." (imgui-make-vec2 40.0 40.0) )
                                                            1;
                                             )
               (imgui-same-line)
               (if (imgui-button "c" (imgui-make-vec2 40.0 40.0) )
                                                            1;
                                             )
               (imgui-same-line)
               (if (imgui-button "=" (imgui-make-vec2 40.0 40.0) )
                                                            1;
                                             )

              (imgui-end)
              (imgui-render-end)
          ))
      (glut-reshape (lambda(w h)
                    (imgui-resize w h)
                     ))
      (glut-main-loop)
      (imgui-exit)
      (glut-exit)
      )
 (app-calc)
