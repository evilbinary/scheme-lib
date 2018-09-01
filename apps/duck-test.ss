;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui graphic)
	 (gui duck)
	 (gui stb)
	 (gles gles1)
	 (gui window)
	 (cffi cffi)
	 (gui video)
	 (utils libutil) (utils macro) )


(define window '() )
(define width 800)
(define height 700)
;;(cffi-log #t)

(define para "如果我们将我们所有的物体导入到程序当中，
它们有可能会全挤在世界的原点(0, 0, 0)上，这并不是我们想要的结果
。我们想为每一个物体定义一个位置，从而能在更大的世界当中放置它们。
世界空间中的坐标正如其名：是指顶点相对于（游戏）世界的坐标。
如果你希望将物体分散在世界上摆放（特别是非常真实的那样）
，这就是你希望物体变换到的空间。物体的坐标将会从局部变换到世界空间；
该变换是由模型矩阵(Model Matrix)实现的。")


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
	  (dialog  (+ i  100.0) (+ i 100.0) 300.0 200.0 (format "dialog~a" i) )
	  (loop (+ i 1)))
	)))

(define (test-video)
 (let ((d (dialog 20.0 80.0 300.0 400.0 "测试scroll~"))
	(p (scroll 280.0 360.0))
	(v (video 280.0 250.0  "/Users/evil/Downloads/WeChatSight513.mp4"))
	)
   (widget-add-draw
    v
    (lambda (w p)
      (window-post-empty-event)
      ))
   (widget-add p v)
   (widget-add d p)
   ))
   
(define (test-scroll)
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
    ))

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

(define (test-multi-widget)

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
       ;;(printf "button1 event type ~a ~a\n" t d)
       ))

     (widget-add-event
      button2
      (lambda (w p t d)
	(widget-resize p (- (vector-ref p %w) 10) (- (vector-ref p %h) 10))
	;;(printf "button2 event type ~a ~a\n" t d)
	))

    
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
    (widget-add p (text 120.0 30.0 "总结:喜欢很大很大的"))
    (widget-add p (edit 280.0 120.0 "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
QQ群：Lisp兴趣小组239401374 啊哈哈"))
    
    ))

(define (test-editor)
  (let ((p (scroll 280.0 360.0))
	(editor (edit 200.0 400.0 "hello，world")))
    (widget-add p)
    (widget-add p editor))
  )

(define (test-tab)
  (let ((p (dialog 40.0 20.0 500.0 400.0 "tab窗体啦啦~"))
	(t (tab 450.0 300.0 (list "标签1" "标签2" "标签3" )))
	(tab1 (scroll 400.0 280.0)))

    (let ((button1 (button 120.0 30.0 "窗体调大"))
	  (button2 (button 120.0 30.0 "窗体调小"))
	  (button3 (button 120.0 30.0 "按钮3"))
	  (button4 (button 120.0 30.0 "按钮"))
	  (img (image 180.0 180.0 "./duck.png"))
	  (icon (image 180.0 180.0 "face.png")))

      (widget-add-event
       button1
       (lambda (w p t d)
	 (widget-resize p (+ (vector-ref p %w) 10) (+ (vector-ref p %h) 10))
	 (printf "button1 event type ~a ~a\n" t d)
	 ))

     
       (widget-add tab1 img)
       (widget-add tab1 icon)
       (widget-add tab1 button1)
       (widget-add tab1 button2)
       (widget-add tab1 button3)
       (widget-add tab1 button4)
       (widget-add tab1 (text 140.0 30.0 "文本内容"))
      )
    
    (widget-add t (edit 280.0 120.0 "scheme-lib 是一个scheme使用的库。目前支持android mac linux windows，其它平台在规划中。官方主页啦啦啦啦gagaga：http://scheme-lib.evilbinary.org/ 
 ;;QQ群：Lisp兴趣小组239401374 啊哈哈"))
		
    ;;(widget-add t (text 20.0 30.0 "标签2:我是内容哈啦啦啦啦"))
    (widget-add t (text 20.0 30.0 "标签3:金发拉数据大幅标"))
    (widget-add t  tab1)

    (widget-add p t)
    ))

(define (duck-test)
  (set! window (window-create width height "鸭子gui"))
  (window-set-fps-pos 750.0 0.0)
  ;;(window-set-fps-pos  20.0  20.0)
  (window-show-fps #t)
  
  ;;widget add here
  ;;(test-mobile-ui)
  ;;(test-scroll)
  ;;(test-multi-dialog)
  ;;(test-multi-widget)
  ;;(test-video)
  ;;(test-editor)
  (test-tab)
  
  ;;run
  (window-loop window)
  (window-destroy window)
  )

(duck-test)


