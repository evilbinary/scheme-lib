;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui graphic)
	 (gui duck)
	 (gui stb) (gles gles1)
	 (cffi cffi)
	 (gui video)
	 (utils libutil) (utils macro) )


(define window '() )
;;资源文件目录设置
(define res-dir 
  (case (machine-type)
    ((arm32le) "/data/data/org.evilbinary.chez/files/")
    (else "")
    ))

(define mouse-x 0.0)
(define mouse-y 0.0)


(define para "如果我们将我们所有的物体导入到程序当中，
它们有可能会全挤在世界的原点(0, 0, 0)上，这并不是我们想要的结果
。我们想为每一个物体定义一个位置，从而能在更大的世界当中放置它们。
世界空间中的坐标正如其名：是指顶点相对于（游戏）世界的坐标。
如果你希望将物体分散在世界上摆放（特别是非常真实的那样）
，这就是你希望物体变换到的空间。物体的坐标将会从局部变换到世界空间；
该变换是由模型矩阵(Model Matrix)实现的。")

(define (draw-large mx my  text-id)
  (let loop ((i 0)
	     (x 0)
	     (y 0))

    (if (< i  100)
	(begin
	  (graphic-draw-texture-quad (+ mx x) (+ y my)
				     (+ x mx 60.0) (+ y my 60.0)
				     0.0 0.0 1.0 1.0 text-id)
	  (loop (+ i 1) (random 400) (random 400)))))
   )




(define (test-multi-dialog)
  (let loop ((i 0))
    (if (< i 20)
	(begin
	  (let ((p (dialog 100.0 80.0 300.0 200.0 "3windows"))
		(button1 (button 120.0 30.0 "button"))
		(button2 (button 120.0 30.0 "button2"))
		(button3 (button 120.0 30.0 "button3"))
		(button4 (button 120.0 30.0 "button4"))
		)
	    (widget-set-margin button1 10.0 20.0 0.0 20.0)
	    (widget-set-margin button2 10.0 20.0 0.0 20.0)
	    (widget-set-margin button3 10.0 20.0 0.0 20.0)
	    
	    (widget-add p button1)
	    (widget-add p button2)
	    (widget-add p button3)
	    (widget-add p button4)

	    (widget-add p (button 120.0 30.0 "button5")))
	  
	  (loop (+ i 1)))
	)))


(define (test-mutil-widget)
 (let loop ((i 0))
    (if (< i 20)
	(begin
	  (draw-dialog (+ i  mouse-x) (+ i mouse-y) 200.0 200.0)
	  (loop (+ i 1)))
	)))

(define (test-graphic)
  
  ;;(graphic-draw-line 0.0 0.0 234.0 256.0 255.0 0.0 0.0 0.0 )
  (draw-line 0.0 12.0 34.0 56.0 255.0 0.0 0.0 0.0 )

  ;;(graphic-draw-solid-quad  10.0 10.0 mouse-x mouse-y 255.0  0.0 0.0 0.0)
  ;;(graphic-draw-solid-quad 10.0 10.0 80.0 40.0  55.0 67.0 65.0  0.0)

  ;;(graphic-draw-solid-quad 10.0 10.0 80.0 40.0   128.0 30.0 34.0 0.5)


  
  ;; (draw-dialog mouse-x mouse-y 200.0 200.0 "窗体")

  ;; (draw-button 100.0 200.0 100.0 90.0 "按钮")
  
  ;; (graphic-draw-texture-quad mouse-x mouse-y
  ;; 		      (+ mouse-x 260.0) (+ mouse-y 260.0)
  ;; 		      0.0 0.0 1.0 1.0 text-id)

  ;; (graphic-draw-texture-quad mouse-x mouse-y
  ;; 			      (+ mouse-x 260.0) (+ mouse-y 260.0)
  ;; 			      0.0 0.0 1.0 1.0 aw)
  
  ;;(draw-large  mouse-x mouse-y  text-id)
  )

(define (test-mobile-ui)
  (let ((mobile-pic (load-texture "mobile.png"))
	(button1 (button 120.0 30.0 "按钮1"))
	(p (scroll 244.0 420.0))
	(img (image 180.0 180.0 "./duck.png"))
	(icon (load-texture "face.png"))
	(e (edit 260.0 120.0 "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
QQ群：Lisp兴趣小组239401374 啊哈哈"))
	(d (dialog 40.0 40.0 300.0 600.0 "窗体啦啦~")))
    (widget-set-draw
     d
     (lambda (widget p)
       (let ((x  (vector-ref  widget %x))
	     (y  (vector-ref widget %y))
	     (w  (vector-ref  widget %w))
	     (h  (vector-ref  widget %h))
	     (draw (widget-get-draw widget))
	     )
       ;;(draw-image (+ 6.0 x) (+ y 6.0) w h mobile-pic)
       (graphic-draw-solid-quad (+ x 20.0) (+ y 40.0 ) (+ x w -20.0) (+ y h -40.0) 255.0 255.0 255.0 1.0)
       (graphic-draw-texture-quad
	x y
	(+ x w) (+ y h)
	0.0 0.0 (/ 787 2370.0) 1.0 mobile-pic)

       ;;(draw-widget-rect widget)
       (vector-set! widget %gx x)
       (vector-set! widget %gy y)
       
       (let loop ((child (widget-get-child widget)))
	 (if (pair? child)
	     (begin
	       ((widget-get-draw (car child)) (car child)  widget)
	       (loop (cdr child)))
	     ))
	 
       )))
    (widget-set-padding d 30.0 30.0 90.0 40.0)

    (widget-add d p)
    (widget-add p img)
    (widget-add p button1)

    (widget-add p (image 180.0 180.0 "test1.jpg"))
    (widget-add p (image 180.0 180.0 "gaga.jpg"))
    (widget-add p (image 180.0 180.0 "duck.png"))
    (widget-add p (image 180.0 180.0 "face.png"))
    (widget-add p (button 120.0 30.0 "按钮"))
    (widget-add p e)
  ))

  
(define width 800)
(define height 700)

(define w  (cffi-alloc 8) )
(define h (cffi-alloc 8))

(define cursorx (cffi-alloc 8))
(define cursory (cffi-alloc 8))

(define  my-edit 0)
(define count 0)

;;(cffi-log #t)


(define (glfw-test)
  (glfw-init)
  (set! window (glfw-create-window width  height  "测试"   0  0) )
  
  (glfw-window-hint GLFW_DEPTH_BITS 16);
  ;; (glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 1);
  ;; (glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);

  (glfw-make-context-current window);
  (glad-load-gles2-loader  (get-glfw-get-proc-address) )

  (glfw-get-framebuffer-size window w h)

  (printf "~a ,~a\n" (cffi-get-int w) (cffi-get-int h))
  
  (glfw-swap-interval 1)
  ;;(glfw-set-input-mode window GLFW_CURSOR GLFW_CURSOR_HIDDEN)

  
  (widget-init width height)
  
  (glfw-set-cursor-pos-callback
   window 
   (lambda (w x y)
     ;;(display (format "w=~x ~x ~a,~a\n" w window x y ))
     (glfw-post-empty-event)
     (set! mouse-x x)
     (set! mouse-y y)
     (widget-event 1 (vector x y))
     
     ))
  
  (glfw-set-key-callback
   window 
   (lambda (w k s a m)
     (widget-event 2 (vector k s a m))
     ;;(display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))

     (gl-edit-key-event my-edit k s a m)
     
     ))
  
  ;;(display (format "procedure?=~a" (procedure? mouse-callback) ) )
  (glfw-set-mouse-button-callback
   window
   (lambda (w button action mods)
     ;;(printf "w=~x button=~a action=~a mods=~a\n" w button action mods)
     (widget-mouse-button-event  (vector button action mods mouse-x mouse-y) )
     ))

  (glfw-set-scroll-callback
   window
   (lambda (w x y)
     ;;(printf "w=~x x=~a y=~a\n" w x y)
     (widget-scroll-event (vector x y mouse-x mouse-y))
     ))

  


  (set! my-edit (graphic-new-edit 300.0 300.0))
  
  (let ((p (dialog 400.0 0.0 300.0 400.0 "窗体啦啦~"))
  	(button1 (button 120.0 30.0 "窗体调大"))
  	(button2 (button 120.0 30.0 "窗体调小"))
  	(button3 (button 120.0 30.0 "按钮3"))
  	(button4 (button 120.0 30.0 "按钮"))
  	(img (image 80.0 80.0 "./duck.png"))
	(icon (load-texture "face.png"))
  	)
    (widget-set-margin button1 10.0 20.0 0.0 20.0)
    (widget-set-margin button2 10.0 20.0 0.0 20.0)
    (widget-set-margin button3 10.0 20.0 0.0 20.0)
    (widget-set-margin img 10.0 10.0 10.0 20.0)
    (widget-add-event
     button1
     (lambda (w p t d)
       (widget-resize p (+ (vector-ref p %w) 10) (+ (vector-ref p %h) 10))
       (printf "button1 event type ~a ~a\n" t d)))

     (widget-add-event
      button2
      (lambda (w p t d)
	(widget-resize p (- (vector-ref p %w) 10) (- (vector-ref p %h) 10))
	(printf "button2 event type ~a ~a\n" t d)))

    
     (widget-add-draw
      button1
      (lambda (w p)
	(let ((x (vector-ref w %gx))
	      (y (vector-ref w %gy)))
	  (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon))))
     
    (widget-add p button1)
    (widget-add p button2)
    (widget-add p button3)
    (widget-add p button4)
    (widget-add p img)
   
    (widget-add p (button 120.0 30.0 "button5"))
    (widget-add p (text 120.0 30.0 "总结:妮妮喜欢很大很大的"))
    (widget-add p (edit 280.0 120.0 "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
QQ群：Lisp兴趣小组239401374 啊哈哈"))
    
    )

  ;; (fork-thread
  ;;  (lambda ()
  ;;    (let loop ()
       
  ;;      (dialog 120.0 40.0 300.0 400.0 "测试scroll~")
  ;;      (sleep (make-time 'time-duration 100000 0))
  ;;      (glfw-post-empty-event)
  ;;      (loop))
  ;;    ))
  
  ;;test scroll
  (let ((d (dialog 20.0 80.0 300.0 400.0 "测试scroll~"))
	(p (scroll 280.0 360.0))
	;;(v (video 280.0 250.0  "/Users/evil/Downloads/WeChatSight513.mp4"))
	)
    ;; (widget-add-draw
    ;;  v
    ;;  (lambda (w p)
    ;;    (glfw-post-empty-event)
    ;;    ))
    (widget-add-event
     p
     (lambda (w p t d)
       (printf "scroll event type ~a ~a\n" t d)))
    
    ;;(widget-add p v)
    (widget-add p (image 180.0 180.0 "test1.jpg"))
    (widget-add p (image 180.0 180.0 "gaga.jpg"))
    (widget-add p (image 180.0 180.0 "duck.png"))
    (widget-add p (image 180.0 180.0 "face.png"))
    (widget-add p (button 120.0 30.0 "按钮"))

    (widget-add p (edit 260.0 120.0 "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
QQ群：Lisp兴趣小组239401374 啊哈哈"))
		
    (widget-add d p)
    ;;(widget-add dialog)
    )


  ;;测试在线视频

  ;; (let ((p (dialog 120.0 220.0 400.0 350.0 "在线视频播放测试~")))
        
  ;;   ;; (widget-add p (video 360.0 280.0  "http://221.228.226.5/14/z/w/y/y/zwyyobhyqvmwslabxyoaixvyubmekc/sh.yinyuetai.com/4599015ED06F94848EBF877EAAE13886.mp4"))

  ;;      ;; (widget-add p (video 360.0 280.0  "http://221.228.226.5/15/t/s/h/v/tshvhsxwkbjlipfohhamjkraxuknsc/sh.yinyuetai.com/88DC015DB03C829C2126EEBBB5A887CB.mp4"))

  ;;   )


    
  (let ((p (dialog 120.0 520.0 300.0 1298.0 "灯测试~")))
    (widget-add p (image 168.0 1298.0 "test.png")))


  ;; (let ((b (button 120.0 30.0 "buttonhaha")))
  ;;   (widget-set-xy b 100.0 100.0)
  ;;   (widget-add  b))
  
  ;;(test-multi-dialog)
  ;;(widget-layout)
  (test-mobile-ui)
  
  (let (
	(text-id (load-texture  "./duck.png"))
	(aw (load-texture  "./aw.png"))
	(rotation 2.0)
	(markup  (graphic-new-markup "Roboto-Regular.ttf" 25.0))
	;;(v (video-new "/Users/evil/Downloads/WeChatSight513.mp4" width height))
	)

    (glEnable GL_BLEND)
    (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
    ;;(glEnable GL_DEPTH_TEST)

    ;;(dialog 100.0 100.0 200.0 200.0 "1啊哈哈")
    ;; (dialog 150.0 120.0 200.0 200.0 "2gaga")
    ;; (dialog 10.0 80.0 200.0 200.0 "3windows")

    ;; (dialog 0.0 80.0 200.0 200.0 "3windows")
    ;; (dialog 20.0 10.0 200.0 200.0 "3windows")
    ;; (dialog 90.0 0.0 200.0 200.0 "3windows")
    ;;(dialog 110.0 180.0 200.0 200.0 "3windows")

   (graphic-edit-add-text my-edit "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
QQ群：Lisp兴趣小组239401374 啊哈哈" markup)
    
    (while (= (glfw-window-should-close window) 0)
	   ;;(glClearColor 1.0  0.0  0.0  1.0 )

	   
	   (glClearColor 0.3 0.3 0.32 1.0 )
	   (glClear (+   GL_COLOR_BUFFER_BIT )) ;;
     
	   ;;(graphic-draw-text mouse-x mouse-y para)
	   ;;(graphic-draw-edit  my-edit mouse-x mouse-y)
	   ;;(graphic-draw-solid-quad 20.0 20.0  300.0 300.0 255.0 0.0 0.0 0.5)

	   ;;(glfw-get-cursor-pos window cursorx cursory)
	   ;;(widget-event 1 (vector (cffi-get-double cursorx ) (cffi-get-double cursory )))
	   (graphic-draw-text 0.0 20.0 (format "fps=~a\n" (graphic-get-fps) ))

	   ;;(if (> (graphic-get-fps) 30)
	   
	   
	   ;;(video-render v)
	  		 
	   ;; (if (> count 2)
	   ;;     (begin
	   
	   ;; (let l ((i 3))
	   ;;   (if (> i 0)
	   ;; 	 (begin
	   ;; 	   (video-render v 0.0 0.0 200.0 200.0)
	   ;; 	   (l (- i 1))
	   ;; 	   )))
		 
	   ;; 	 (set! count 0)
	   ;; 	 ))
	   ;; (set! count (+ count 1))
	   (glfw-wait-events)
	   (widget-render)
	   ;;(glfw-poll-events)
	   (glfw-swap-buffers window)

	   ;; (if(>  (graphic-get-fps) 120)
	   ;;(sleep (make-time 'time-duration (* (graphic-get-fps) 1000 1000) (flonum->fixnum (/   (graphic-get-fps) 120.0))))
	   
	   ))
  (graphic-destroy)
  (glfw-destroy-window window);
  (glfw-terminate)

  )

(glfw-test)


