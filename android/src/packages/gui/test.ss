;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (test)
         (export
          gl-test-function
          gl-test-demo1
          gl-test-demo2
          gl-test-demo3
          imgui-test-hello-world
          )
         (import  (scheme) (gles1)  (glut) (imgui)  )
         
         (define PI 3.1415)
         (define (glutPrespective fovy aspect zNear zFar)
           (let* ((top (* zNear (tan (* fovy (/ PI 360.0)))))
                  (bottom (- top))
                  (left (* bottom aspect))
                  (right (* top aspect)))
             (glFrustumf left right bottom top zNear zFar)
             ))

         (define (gl-test-function)
            (glut-test-rotatef 20.1 4.3 0.0 1.2))

         ;imgui hello,world
         (define (imgui-test-hello-world)
                  (glut-init)
                  (imgui-init)
                  (imgui-scale 2.5 2.5)
                  (glut-touch-event (lambda (type x y)
                      (imgui-touch-event type x y)
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
                          (imgui-set-next-window-size (imgui-make-vec2 200.0 140.0) 0)
                          (imgui-begin "evilbinary" 0)
                          (imgui-text "hello,world")
                          (imgui-end)
                          (imgui-render-end)
                      ))
                  (glut-reshape (lambda(w h)
                                (imgui-resize w h)
                                 ))
                  (glut-main-loop)
                  (imgui-exit))
         ;imgui例子
         (define (gl-test-demo3)
                 (glut-init)
                 (imgui-init)
                 (imgui-scale 2.5 2.5)
                 (glut-touch-event (lambda (type x y)
                     (imgui-touch-event type x y)
                     ))
                 (glut-key-event (lambda (event)
                     ;(glut-log (format "event=~a" event))
                     (glut-log (format "event=~a" (glut-event-get event 'keycode ) ))

                     (imgui-key-event
                        (glut-event-get event 'type)
                        (glut-event-get event 'keycode)
                        (glut-event-get event 'char)
                        (glut-event-get event 'chars))
                      (if (= 4 (glut-event-get event 'keycode ))
                        (begin (imgui-exit)
                        (glut-exit)))
                     ))
                 (let ((click 0) (f #f))
                     (glut-display (lambda ()
                             (imgui-render-start)

                             ;(imgui-test)
                             ;(imgui-text "hello,world")
                             ;(imgui-color-edit3 "color" (imgui-get-default-color))

                             (imgui-set-next-window-size (imgui-make-vec2 200.0 140.0) 0)
                             (imgui-begin "gaga" 0)

                             (if (imgui-button "button" (imgui-make-vec2 80.0 20.0) )
                                (set! click (logxor click 1))
                                )
                             (if (= 1 click)
                                (begin
                                    (imgui-checkbox "checkbox" (make-bytevector 1 0) )
                                    (imgui-text "click")))
                             (imgui-text "hello,world!")

                             (imgui-end)

                             (imgui-set-next-window-size (imgui-make-vec2 400.0 240.0) 0)
                             (imgui-set-next-window-pos (imgui-make-vec2 200.0 200.0) 0)
                             (imgui-begin "gaga0" 0)
                             (imgui-text "hello,world!")


                             (if (imgui-input-text-multiline "##source" "tttt" 160
                                   (+ (<< 1 5)  (<< 1 8))
                                   (imgui-make-text-edit-callback
                                       (lambda (x)
                                           (glut-log (format "xxxx=~a" x))
                                           (+ 1 2) ) )
                                   0
                                   (imgui-make-vec2 200.0 140.0)
                                   )
                                (glut-log (format "focus on multiline text"))
                             )

                              (if (= 1 (imgui-get-mouse-cursor))
                                  (glut-show-soft-input)
                                  (glut-hide-soft-input)
                                   )

                             (if (imgui-input-text "#test" "aaa"  10 0
                                (imgui-make-text-edit-callback 0) 0)
                                (glut-set-soft-input-mode 1 0))
                             (imgui-end)

                             ;(imgui-get-io)
                             (imgui-render-end)
                         )))
                 (glut-reshape (lambda(w h)
                               (imgui-resize w h)
                                ))
                 (glut-main-loop)
                 (imgui-exit)
                 )
         ;opengles1.x 例子
         (define (gl-test-demo2)
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
            (let ((points (glut-vector 'float (vector -0.2 -0.2 0.0  0.2 -0.2 0.0   -0.2 0.2 0.0 )))
                  (rotation 0.0)
                    )

                (glut-display (lambda ()

                        (glClear (and GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT) )
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
                        (glDrawArrays GL_POINTS  0  1);
                        (glDisableClientState GL_VERTEX_ARRAY)

                    )))



            (glut-reshape (lambda(w h)
                           (glClearColor 0.0 0.0 0.0 0.0 )
                           (glViewport 0 0 w h)
                           (glMatrixMode GL_PROJECTION)
                           (glLoadIdentity) ))
            (glut-main-loop))

         (define (gl-test-demo1)
           (define  rotation 0.0)
           (glut-init)
           (glut-touch-event (lambda (type x y)
                         (format #t "~a ~a ~a\n" type x y)
                         (glut-log "test log...")
                         ))
           (glut-display (lambda()
                           (let (

                                 (squareVertices (glut-vector 'float (vector -0.2 -0.2
                                                                      0.2 -0.2
                                                                      -0.2 0.2
                                                                      0.2 0.2)))
                                 (squareColors (glut-vector 'unsigned-8 (vector 255 255 0 255
                                                                    0 255 255 255
                                                                    0 0 0 0
                                                                    255 0 255 255)))
                                 (gVerticesSquare (glut-vector 'float (vector -0.2  -0.2  0.0   
                                                                       0.2  -0.2  0.0   
                                                                       -0.2  0.2  0.0    
                                                                       0.2  0.2  0.0    )))
                                 (gcolors (glut-vector 'float (vector  1.0 0.0 0.0  1.0  0.0  1.0  0.0 1.0   0.0 0.0 1.0  1.0 )))
                                 (points (glut-vector 'float (vector -0.2 -0.2 0.0  0.2 -0.2 0.0   -0.2 0.2 0.0 )))
                                 (trangle-point (glut-vector 'float (vector -0.2 -0.2 0.0  0.2 -0.2 0.0   -0.2 0.2 0.0   0.2 1.0 0.0 ) ))
                                 )


                             (display "glut-display=====\n")    
                             
                             (format #t "display\n")

                             ;(glClear (and GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT) )
                             ;(glClearColor 0.0 0.0 0.0 0.0 )
                             ;(glLoadIdentity)

                             (glClearColor 0.5  0.5  0.5  1.0 );
                             (glClear GL_COLOR_BUFFER_BIT);
                             ;(format #t "1\n")
                             


                             ;;绘制点
                             ;(glFrontFace GL_CW)
                             ;(glClearColor 0.5  0.5  0.5  1.0 );
                             ;(glClear GL_COLOR_BUFFER_BIT);
                             ;(glColor4f 1.0  0.0 0.0 1.0)
                             (glPointSize 20.0)
                             ;(glLoadIdentity)
                             ;(glTranslatef 0.0  0.0 -4.0)
                             (glEnableClientState GL_VERTEX_ARRAY)
                             (glVertexPointer 3 GL_FLOAT 0 points)
                             (glDrawArrays GL_POINTS 0 3 )
                             (glDisableClientState GL_VERTEX_ARRAY)

                             ;绘制三角形
                             ;(glClearColor 0.5  0.5  0.5  1.0 );
                             ;(glClear GL_COLOR_BUFFER_BIT);
                             ;(glColor4f 0.0  1.0 0.0 1.0)
                             ;(glTranslatef 0.0 0.5 0.0)
                             ;(glEnableClientState GL_COLOR_ARRAY)
                             ;(glColorPointer 4 GL_FLOAT 0 gcolors)
                             ;;(glRotatef rotation 1.0 1.0 0.0 )
                             ;(glEnableClientState GL_VERTEX_ARRAY);
                             ;(glVertexPointer 3 GL_FLOAT 0 trangle-point)
                             ;(glDrawArrays GL_TRIANGLES 0 3 )
;
                             ;;;绘制正方形
                             ;(glTranslatef 0.5 0.0 0.0);                      // 设置正方形位置
                             ;(glColor4f 1.0 0.0 0.0 1.0);                  // 设置颜色为红色
                             ;(glVertexPointer 3 GL_FLOAT  0  gVerticesSquare);   // 指定顶点数组
                             ;(glEnableClientState GL_VERTEX_ARRAY);
                             ;(glDrawArrays GL_TRIANGLE_STRIP  0  4);              // 绘制正方形
                             ;(glDisableClientState GL_VERTEX_ARRAY)
;
                             ;;;绘制矩形
                             ;(glMatrixMode GL_PROJECTION);
                             ;(glLoadIdentity );
                             ;(set! rotation (+ rotation 1.0))
                             ;;(glut-test)
                             ;;;(glut-test-rotatef rotation 0.0 0.0 0.1)
                             ;(glRotatef rotation 0.0 0.0 0.1)
                             ;(glVertexPointer 2  GL_FLOAT  0  squareVertices);
                             ;(glEnableClientState GL_VERTEX_ARRAY);
                             ;(glColorPointer 4  GL_UNSIGNED_BYTE  0 squareColors);
                             ;(glEnableClientState GL_COLOR_ARRAY);
                             ;(glDrawArrays GL_TRIANGLE_STRIP  0 4);
                             ;(glDisableClientState GL_VERTEX_ARRAY)
                             ;(glDisableClientState GL_COLOR_ARRAY)
                             
                             ;(format #t "3\n")


                             ;(gl-test-c1)
                             (glut-unvector gVerticesSquare)
                             (glut-unvector squareVertices)
                             (glut-unvector squareColors)
                             (glut-unvector gcolors)
                             (glut-unvector points)
                             (glut-unvector trangle-point)
                             )
                           ))
           (glut-reshape (lambda(w h)
                           ;(gl-test-reshape w h)
                           ;(format #t "reshape\n")
                           ;(gl-disable GL-BLEND)
                           ;(gl-disable GL-CULL-FACE)
                           ;(gl-disable GL-DEPTH-TEST)
                           (glClearDepthf 1.0)
                           (glClearColor 0.0 0.0 0.0 0.0 )
                           (glViewport 0 0 w h)
                           (glMatrixMode GL_PROJECTION)
                           (glLoadIdentity)
                           ;(glutPrespective 45.0 (* 1.0 (/ w h)) 0.1 100.0)
                           ;(gl-color-texture-reset)
                           ;(glOrthof   0.0 0.0 480.0  480.0  -1.0 1.0)
                           ;(glMatrixMode GL_MODELVIEW)
                           ;(glLoadIdentity)
                           ;(glEnable GL_LINE_SMOOTH)
                           
                           ))
           (glut-main-loop)
           ;(glut-exit)
           )
         )