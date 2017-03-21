;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (gles gles1)  (glut glut) (gui imgui)    )
(define (gl-draw-point)
        (define gx 0)
        (define gy 0)
        (define gtype 0)
        (glut-init)

        (glut-touch-event (lambda (type x y)
           (glut-log "glut-event")
            (set! gx x)
            (set! gy y)
            (set! gtype type)
            ))
        (glut-key-event (lambda (event)
               (glut-log (format "glut-key-event=~a" (glut-event-get event 'keycode )) )
               (if (= 4 (glut-event-get event 'keycode ))
                 (glut-exit)))
              )
        (let ((points (glut-vector 'float (vector -0.2 -0.2 0.0  0.2 -0.2 0.0   -0.2 0.2 0.0 )))
              (rotation 0.0)
                )

            (glut-display (lambda ()

                    (glClear (+ GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT) )
                    (glClearColor 0.0 0.0 0.0 0.0 )
                    (glLoadIdentity)


                    (glColor4f 1.0 0.0 0.0 1.0);
                    (glVertexPointer 3 GL_FLOAT  0  points);
                    (glMatrixMode GL_PROJECTION);
                    (glLoadIdentity)

                    (glTranslatef (/ gx 1536.0) (/ gy 2048.0) 0.0 )
                    ;(set! rotation (+ rotation 1.5))
                    ;(glRotatef rotation 0.0 1.0 0.0 )
                    (glPointSize 20.0)
                    (glEnableClientState GL_VERTEX_ARRAY);
                    (glDrawArrays GL_POINTS  0  3);
                    (glDisableClientState GL_VERTEX_ARRAY)

                )))
            (glut-reshape (lambda(w h)
                           (glClearColor 0.0 0.0 0.0 0.0 )
                           (glViewport 0 0 w h)
                           (glMatrixMode GL_PROJECTION)
                           (glLoadIdentity) ))
            (glut-main-loop))
(gl-draw-point)