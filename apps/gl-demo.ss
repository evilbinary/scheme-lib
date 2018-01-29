;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;author:evilbinary on 12/24/16.
;email:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (glut glut) (gles gles1))
;opengles1.x 例子
(define (gl-demo)
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


                 ;(display "glut-display=====\n")    
                 ;(format #t "display\n")

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
                 (glMatrixMode GL_PROJECTION);
                 (glLoadIdentity );
                 (set! rotation (+ rotation 1.0))
                 ;(glut-test)
                 ;;(glut-test-rotatef rotation 0.0 0.0 0.1)
                 (glRotatef rotation 0.0 0.0 0.1)
                 (glVertexPointer 2  GL_FLOAT  0  squareVertices);
                 (glEnableClientState GL_VERTEX_ARRAY);
                 (glColorPointer 4  GL_UNSIGNED_BYTE  0 squareColors);
                 (glEnableClientState GL_COLOR_ARRAY);
                 (glDrawArrays GL_TRIANGLE_STRIP  0 4);
                 (glDisableClientState GL_VERTEX_ARRAY)
                 (glDisableClientState GL_COLOR_ARRAY)
                 
                 ;(format #t "3\n")


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
               ;(glViewport 0 0 w h)
               (glMatrixMode GL_PROJECTION)
               (glLoadIdentity)
               ;(glutPrespective 45.0 (* 1.0 (/ w h)) 0.1 100.0)
               ;(gl-color-texture-reset)
               ;(glOrthof   0.0 0.0 w  h -1.0 1.0)
               ;(glMatrixMode GL_MODELVIEW)
               ;(glLoadIdentity)
               ;(glEnable GL_LINE_SMOOTH)
               ))
           (glut-main-loop)
           ;(glut-exit)
           )
(gl-demo)