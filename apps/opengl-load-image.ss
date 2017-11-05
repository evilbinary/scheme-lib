
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;Copyright 2016-2080 evilbinary.
					;作者:evilbinary on 12/24/16.
					;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)  (glfw glfw)
	 (gui imgui)
	 (gles gles1)
	 (glut glut)
	 (cffi cffi)
	 (nanovg nanovg)
	 (gui stb)
	 (utils libutil)
	 (utils macro) )


(define file "number.png")

;;(cffi-log #t)

(if (> (length (command-line)) 1)
    (if (not (eq? "" (cadr (command-line))))
	(set! file  (cadr (command-line)))) )

(define (load-texture file)
  (let ((w (cffi-alloc 4))
	(h (cffi-alloc 4))
	(data 0)
	(id 0)
	(text-id (cffi-alloc 4))
	(chanel (cffi-alloc 4)))
    (set! data (stbi-load file
		       w h chanel 4))
    ;;(printf "load=>~a ~a ~a chanel=>~a\n"
	    ;; data
	    ;; (cffi-get-int w)
	    ;; (cffi-get-int h)
	    ;; (cffi-get-int chanel))
    (glGenTextures 1 text-id)

    (glBindTexture GL_TEXTURE_2D (cffi-get-int text-id))
    (glTexImage2D GL_TEXTURE_2D
		  0 GL_RGBA
		  (cffi-get-int w )
		  (cffi-get-int h)
		  0
		  GL_RGBA
		  GL_UNSIGNED_BYTE
		  data)
    (glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT)
    (glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT)
    (glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST)
    (glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST)
    (set! id (cffi-get-int text-id))
    (cffi-free text-id)
    (cffi-free w)
    (cffi-free h)
    (cffi-free chanel) id))




(define window '() )
(define res-dir 
  (case (machine-type)
    ((arm32le) "/data/data/org.evilbinary.chez/files/")
    (else "")
    ))

(define (opengl-test)
  (glfw-init)

  ;;(glfw-window-hint GLFW_DEPTH_BITS 16);
    ;;(glfw-window-hint GLFW_CLIENT_API  GLFW_OPENGL_ES_API);
    ;;(glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 2);
    ;;(glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);
  (glfw-window-hint GLFW_SAMPLES 4)
  (set! window (glfw-create-window 640  480  "测试例子"   0  0) )
  (glfw-make-context-current window);

  (glad-load-gl-loader  (get-glfw-get-proc-address))
  (glad-load-gles1-loader  (get-glfw-get-proc-address))
  (glad-load-gles2-loader  (get-glfw-get-proc-address))

  (glfw-swap-interval 1);

  ;; (glfw-set-cursor-pos-callback
  ;;  window
  ;;  (lambda (w x y)
  ;;    (display (format "w=~x ~x ~a,~a\n" w window x y )) ))

  (glfw-set-key-callback
   window
   (lambda (w k s a m)
     (display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))))
  
  (let (
	(rotation 2.0)
	(texture-id (load-texture  (string-append res-dir file)))
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
	(text-id (load-texture "test.jpg"))
	)

    (glMatrixMode GL_PROJECTION)
    
    (while (= (glfw-window-should-close window) 0)
	   (glEnable GL_MULTISAMPLE)
	   (glClearColor 0.0  0.0  0.0  1.0 )
	   (glClear (+  GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT))

	   (glLoadIdentity)
	     
	   (glRotatef rotation 0.0 1.0 0.0)
	  
	   
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

	   (set! rotation (+ rotation 0.8))

	   (glfw-swap-buffers window)
	   (glfw-poll-events)
	   ))
  (glfw-destroy-window window);
  (glfw-terminate)

  )

(opengl-test)
