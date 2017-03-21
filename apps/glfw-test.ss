;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)  (glfw glfw) (gui imgui) (gles gles1) (glut glut) (utils libutil)  (utils macro) )

(define window '() )
;;资源文件目录设置
(define res-dir 
         (case (machine-type)
           ((arm32le) "/data/data/org.evilbinary.chez/files/")
           (else "")
            ))


(define (glfw-test)
	(glfw-init)
	(set! window (glfw-create-window 640  480  "Simple example"   0  0) )
	(glfw-window-hint GLFW_DEPTH_BITS 16);
	 ; (glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 1);
	 ; (glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);

	(glfw-make-context-current window);

  (display (glad-load-gles1-loader  (get-glfw-get-proc-address) ) )

	(glfw-swap-interval 1);

  (glfw-set-cursor-pos-callback window 
    (glfw-make-cursor-pos-callback 
        (lambda (w x y)
          (display (format "w=~x ~x ~a,~a\n" w window x y ))
        ;(glfw-swap-buffers w)
        )
      ))

  (glfw-set-key-callback window 
    (glfw-make-key-callback 
        (lambda (w k s a m)
            (display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))
          )
      ))


  ;(display (format "procedure?=~a" (procedure? mouse-callback) ) )

	(let (
			(rotation 2.0)
			(texture-id (imgui-load-texture  (string-append res-dir "number.png")))
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
		(while (= (glfw-window-should-close window) 0)
		 ;(glClearColor 1.0  0.0  0.0  1.0 )

         (glClear (+  GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT))
 
 (glRotatef rotation 0.0 0.0 0.1)
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


		(glfw-swap-buffers window)
		(glfw-poll-events)
		))
	(glfw-destroy-window window);
    (glfw-terminate)

	)

(glfw-test)
