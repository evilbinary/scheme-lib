;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)  (glfw glfw) (gui imgui) (gles gles1) (glut glut) (nanovg nanovg) (utils libutil)  (utils macro) )

(define window '() )
;;资源文件目录设置
(define res-dir 
         (case (machine-type)
           ((arm32le) "/data/data/org.evilbinary.chez/files/")
           (else "")
            ))
(define vg '())
(define nil '())
(define font-normal nil)
(define font-emoji nil )
(define icons nil)

(define image1 nil)

(define pos-x 0.0)
(define pos-y 0.0)


(define (nanovg-init)
  (set! vg (nvg-create-gles2 (+ NVG_ANTIALIAS NVG_STENCIL_STROKES ) ))
  (set! font-normal (nvg-create-font vg  "sans" "Roboto-Regular.ttf") )
  (set! font-bold (nvg-create-font vg  "sans-bold" "Roboto-Bold.ttf") )
  (set! icons (nvg-create-font vg  "icons" "entypo.ttf") )
  (set! font-emoji (nvg-create-font vg  "emoji" "Roboto-Regular.ttf") )
  ;(nvg-add-fallback-font-id vg font-normal font-emoji )
  (set! image1 (nvg-create-image vg "test2.jpg" 0))
  )



;;draw-image
(define (draw-image vg image x y w h )

    (nvg-begin-path vg);
    (nvg-rounded-rect vg x y  w h 1.0 );
    (nvg-stroke-width vg 1.0)
    (nvg-stroke-color vg  (nvg-rgba 255 0 0 255))
    (nvg-fill-paint vg (nvg-image-pattern vg x y  w h 0.0 image 1.0) )
    (nvg-fill vg)
    (nvg-stroke vg)
  )

;;drawEditBoxBase
(define (draw-edit-box-base vg x y w h)

  (let ((bg (nvg-box-gradient vg (+ x 1.0) 
                              (+ y 1 1.5)  
                              (- w 2.0) 
                              (- h 2.0) 
                              3.0 4.0 
                              (nvg-rgba 255 255 255 32)  
                              (nvg-rgba 32 32 32 32))))
  (nvg-begin-path vg);
  (nvg-rounded-rect vg   (+ x 1.0) (+ y 1.0) (- w 2.0) (- h 2.0) (- 4.0 1.0));
  (nvg-fill-paint vg  bg);
  (nvg-fill vg);

  (nvg-begin-path vg);
  (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5)  (- w 1) (- h 1) (- 4 0.5) );
  (nvg-stroke-color vg  (nvg-rgba 0 0 0 48))
  (nvg-stroke vg);

  ))

;;draw editbox
(define (draw-edit-box vg text x y w h)
  (draw-edit-box-base vg x y w h)
  (nvg-font-size vg 20.0);
  (nvg-font-face vg "sans");
  (nvg-fill-color vg (nvg-rgba 255 255 255 64));
  (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE))
  (nvg-text vg (+ x (* h 0.3)) (+ y (* h 0.5)) text  NULL);
)
;;draw label
(define (draw-label  vg text x y w h)
  (nvg-font-size vg 18.0);
  (nvg-font-face vg "sans");
  (nvg-fill-color vg (nvg-rgba 255 255 255 128));
  (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE))
  (nvg-text vg  x (+ y (* h 0.5)) text NULL)
  )

(define (is-black col)
  (if (and (= 0 (NVGcolor-r col)) 
            (= 0 (NVGcolor-g col)) 
            (= 0 (NVGcolor-b col)) 
            (= 0 (NVGcolor-a col)) ) #t #f)
  )

(define (cpToUTF8 cp str)
  str
  )
;;draw button
(define (draw-button vg preicon text x y w h color)
  (let ((bg (nvg-linear-gradient vg 
               x y x (+ y h)
              (nvg-rgba 255 255 255 (if (is-black color) 16 32) )
               (nvg-rgba 0 0 0 (if (is-black color) 16 32))) )
      (cornerRadius 4.0)
      (tw 0.0)
      (iw 0.0)
      (icon "")
    )

  (nvg-begin-path vg)
  (nvg-rounded-rect vg (+ x 1) (+ y 1) (- w 2) (- h 2) (- cornerRadius 1) )
  (if (is-black color)
      (begin 
          (nvg-fill-color vg color)
          (nvg-fill vg)
        )
    )
  (nvg-fill-paint vg bg)
  (nvg-fill vg)


  (nvg-begin-path vg)
  (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5) (- w 1.0) (- h 1.0) (- cornerRadius 0.5) )
  (nvg-stroke-color vg (nvg-rgba 0 0 0 48))
  (nvg-stroke vg)

  (nvg-font-size vg 20.0)
  (nvg-font-face vg "sans-bold")
  (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))

  (if (not (= 0 preicon))
      (begin
        (nvg-font-size vg (* h 1.3))
        (nvg-font-face vg "icons")
        (set! iw (nvg-text-bounds vg 0.0 0.0  (cpToUTF8 preicon icon) NULL NULL))
        (set! iw (* h 0.15))
        )
    )

  (if (not (= 0 preicon))
      (begin 
        (nvg-font-size vg (* h 1.3))
        (nvg-font-face vg "icons")
        (nvg-fill-color vg (nvg-rgba 255 255 255 96))
        (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE) )
        (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5) ) (- (* iw 0.75))) (+ y (* h 0.5)) (cpToUTF8 preicon icon) NULL  )
        )
    )

  (nvg-font-size vg 20.0)
  (nvg-font-face vg "sans-bold")
  (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE) )
  (nvg-fill-color vg (nvg-rgba 0 0 0 160))
  (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25))  (+ y (* h 0.5) -1) text NULL )
  (nvg-fill-color vg (nvg-rgba 255 255 255 160))
  (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25)) (+ y (* h 0.5)) text NULL  )

  ))


;;draw window
(define (draw-window vg title x y w h)
    (let ((cornerRadius 3.0)
          (shadowPaint nil)
          (headerPaint nil)

        )
      (nvg-save vg)

      ;(drawWindow vg "test" 20.0 10.0 200.0 150.0)


      ;window
      (nvg-begin-path vg)
      (nvg-rounded-rect vg x y w h cornerRadius)
      (nvg-fill-color vg (nvg-rgba 28 30 34 192))
      (nvg-fill vg)


      ;Drop shadow
      (set! shadowPaint (nvg-box-gradient vg x (+ y 2.0) w h (* cornerRadius 2.0) 10.0
         (nvg-rgba  0  0  0 128 ) (nvg-rgba 0 0 0 0 ) ))
      ;(display (format "shadowPaint=~a\n" shadowPaint) )

      (nvg-begin-path vg)
      (nvg-rect vg (- x 10 ) (- y 10) (+ w 20) (+ w 30))
      (nvg-rounded-rect vg x y w h cornerRadius)
      (nvg-path-winding vg NVG_HOLE)
      (nvg-fill-paint vg shadowPaint)
      (nvg-fill vg)

      ; ;header
      (set! headerPaint (nvg-linear-gradient vg x y x (+ y 15) 
        (nvg-rgba 255 255 255 8)
        (nvg-rgba 0 0 0 16)
        ))
      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 1) (+ y 1) (- w 2) 30.0 (- cornerRadius 1) )
      (nvg-fill-paint vg headerPaint)
      (nvg-fill vg)

      (nvg-begin-path vg)
      (nvg-move-to vg (+ x 0.5) (+ y 0.5 30.0) )
      (nvg-line-to vg (+ x 0.5 w -1) (+ y 0.5 30.0) )
      (nvg-stroke-color vg (nvg-rgba 0  0 0 32 ))
      (nvg-stroke vg)

      (nvg-font-size vg 18.0)
      (nvg-font-face vg "sans")
      (nvg-text-align vg (+ NVG_ALIGN_CENTER NVG_ALIGN_MIDDLE))

      (nvg-font-blur vg 2.0)
      (nvg-fill-color vg (nvg-rgba 0 0 0 128))
      (nvg-text vg (+ x (/ w 2))  (+ y 16 1) title NULL)
      (nvg-font-blur vg 0.0)
      (nvg-fill-color vg (nvg-rgba 220 220 220 160))
      (nvg-text vg (+ x (/ w 2)) (+ y 16) title NULL )

      (nvg-restore vg)


    )
  )


(define (login-window)
    ;(draw-window vg "test" 10.0 10.0 300.0 250.0)
    
    ;(draw-label vg "login" 40.0 80.0 100.0 10.0)
     (draw-edit-box vg "name" 40.0 100.0 200.0 34.0)
    ; (draw-edit-box vg "password" 40.0 150.0 200.0 34.0)
    ;(draw-button vg  1 "login" 140.0 200.0 100.0 34.0 (nvg-rgba 255 0 0 0) )

    ; (draw-button vg  1 "delete" 440.0 200.0 100.0 34.0 (nvg-rgba 128 16 8 255) )

  )


(define (glfw-test)
	(glfw-init)
	(set! window (glfw-create-window 640  480  "Simple example"   0  0) )
	(glfw-window-hint GLFW_DEPTH_BITS 16);
	 ; (glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 1);
	 ; (glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);

	(glfw-make-context-current window);

 (glad-load-gl-loader  (get-glfw-get-proc-address))
  (glad-load-gles1-loader  (get-glfw-get-proc-address))
  (glad-load-gles2-loader  (get-glfw-get-proc-address))

  
	(glfw-swap-interval 1);

  (glfw-set-cursor-pos-callback window 
        (lambda (w x y)
          (display (format "w=~x ~x ~a,~a\n" w window x y ))
      ))

  (glfw-set-key-callback window 
        (lambda (w k s a m)
            (display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))
          )
      )
    (nanovg-init)

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

      (nvg-begin-frame vg 640 480 2.0)
      (login-window)

       (nvg-end-frame vg)

		(glfw-swap-buffers window)
		(glfw-poll-events)
		))
	(glfw-destroy-window window);
    (glfw-terminate)

	)

(glfw-test)
