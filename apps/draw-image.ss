;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 01/08/17.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (glut) (gles1) (imgui) )
(define (draw-image)
      (glut-init)

      (glut-touch-event (lambda (type x y)
          (glut-log (format "type ~a ~a ~a" type x y ))
          ))
      (glut-key-event (lambda (event)
          (glut-log (format "event ~a" event))
            
          ))
     (let ((texture-id (imgui-load-texture "./number.png"))
     		(rotation 2.0)
     		(square-vertices (glut-vector 'float 
     			(vector 
     				-0.2 -0.2
                    0.2 -0.2                               
                  	-0.2 0.2
                  	0.2 0.2
                  )))
     		(texture-array (glut-vector 'float 
     			(vector 
     			0.0 1.0 
     			1.0 1.0  
     			0.0 0.0 
     			1.0 0.0) ))
     		)
	      (glut-display (lambda()
                 (glClearColor 0.5  0.5  0.5  1.0 );
                 (glClear GL_COLOR_BUFFER_BIT);
                 (glRotatef rotation 0.0 0.0 0.1)
                 ;;绘制矩形
                 (glEnable GL_TEXTURE_2D);                       // 启用纹理映射 
	             (glBindTexture GL_TEXTURE_2D texture-id);
                 (glEnableClientState GL_TEXTURE_COORD_ARRAY); 

                 (glEnableClientState GL_VERTEX_ARRAY);
                 (glVertexPointer 2  GL_FLOAT  0  square-vertices);
                 (glTexCoordPointer 2 GL_FLOAT 0 texture-array);
                 (glDrawArrays GL_TRIANGLE_STRIP  0 4);
                 (glDisableClientState GL_VERTEX_ARRAY)
                 (glDisable GL_TEXTURE_2D)
                 (glDisable GL_TEXTURE_COORD_ARRAY)

                 )
               )

       )
      (glut-reshape (lambda(w h)
	                   (glut-log (format "reshape"))
	                   (glClearDepthf 1.0)
		               (glClearColor 0.0 0.0 0.0 0.0 )
		               (glViewport 0 0 w h)
		               (glMatrixMode GL_PROJECTION)
		               (glLoadIdentity)

                   ))
      (glut-main-loop)
      (glut-exit)
      )

(draw-image)