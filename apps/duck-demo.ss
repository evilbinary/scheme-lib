;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui duck)
	 (gui draw)
	 (gui window)
     (glut glut)
     (gui stb)
     (net curl)
     (gui video)
	 (gui widget))


(define window '() )
(define width 1000)
(define height 700)

(define (checkbox w h t)
    (let ((box (text w h t))
        (icon-check (load-texture "check.png"))
        (icon-checked (load-texture "checked.png"))
        )
        (widget-set-events box 'click (lambda (w p type data)
                (if (eq? #t (widget-get-attrs w 'checked))
                    (widget-set-attrs w 'checked #f)
                    (widget-set-attrs w 'checked #t)
                )))
        (widget-add-draw
            box
            (lambda (w p)
            (let ((x (widget-get-attr w %gx))
                    (y (widget-get-attr w %gy))
                    (checked (widget-get-attrs w 'checked))
                    )
                    (if (eq? #t checked)
                        (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon-checked)
                        (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon-check)
                        ))))
     box
    )
)

(define (radio-group w h )
    '()
)

(define (radio w h t)
    (let ((box (text w h t))
        (icon-check (load-texture "radio.png"))
        (icon-checked (load-texture "radio-active.png"))
        )
        (widget-set-events box 'click (lambda (w p type data)
                (if (eq? #t (widget-get-attrs w 'checked))
                    (widget-set-attrs w 'checked #f)
                    (widget-set-attrs w 'checked #t)
                )))
        (widget-add-draw
            box
            (lambda (w p)
            (let ((x (widget-get-attr w %gx))
                    (y (widget-get-attr w %gy))
                    (checked (widget-get-attrs w 'checked))
                    )
                    (if (eq? #t checked)
                        (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon-checked)
                        (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon-check)
                        ))))
     box
    )
)
(define (image-net w h src)
  (let ((img (image w h src))
	(file-name (format  "~a.jpg" (string-hash src))))
    ;; (if (not (file-exists? "download"))
    ;; 	(create
    (widget-set-attrs img 'mode 'center-crop)
    (if (file-exists? file-name)
	(begin
	  (widget-set-attrs img 'src file-name)
	  (widget-set-attrs img 'load #f))
	(fork-thread
	 (lambda ()
	   (let ((file (url->file file-name src) ))
	     (if (file-exists? file)
		 (begin 
		   (widget-set-attrs img 'src file-name)
		   (widget-set-attrs img 'load #f)
		   (window-post-empty-event)
		   ))
	     )
	   )))
    img
    ))

(define (icon-tree w h text)
        (let ((it (tree w h text))
            (file-icon (load-texture "file-text.png"))
            (dir-icon (load-texture "folder.png"))
            )
            (widget-add-draw
            it
            (lambda (w p)
            (let ((x (vector-ref w %gx))
                (y (vector-ref w %gy)))
                (if (or (null? (widget-get-attrs w 'dir)) (<= (length (widget-get-child w) ) 0))
                    (draw-image (+  -20.0 x) (+ y 4.0) 15.0 15.0 dir-icon)
                    (draw-image (+ -20.0 x) (+ y 4.0) 15.0 15.0 dir-icon))
                )
            ))
            (widget-set-padding it 15.0 20.0 20.0 20.0)
            it
            ))


(define (button-demo)
    (let ((p (dialog 10.0 10.0 200.0 600.0 "按钮demo"))
		(button1 (button 120.0 30.0 "主要"))
		(button2 (button 120.0 30.0 "默认"))
		(button3 (button 120.0 30.0 "图标"))
		(button4 (button 120.0 30.0 "危险"))
        (icon (load-texture "duck.png"))

        (normal-tip (text 120.0 30.0 "普通按钮"))
        (checkbox-tip (text 120.0 30.0 "多选框"))
        (radio-tip (text 120.0 30.0 "单选框"))
        (box (checkbox 120.0 30.0 "多选框"))
        (radio (radio 120.0 30.0 "单选框"))
        )

	    (widget-set-margin button1 10.0 20.0 0.0 20.0)
        (widget-set-attrs button1 'background #xff1890ff)
	    (widget-set-margin button2 10.0 20.0 0.0 20.0)
	    (widget-set-margin button3 10.0 20.0 0.0 20.0)
        (widget-set-margin button4 10.0 20.0 0.0 20.0)
        (widget-set-attrs button4 'color #xfff5222d)
        (widget-set-attrs button4 'hover-background #xfff5222d)
        (widget-set-attrs button4 'hover-color #xffffffff)
        (widget-set-attrs normal-tip 'text-align 'left)

        (widget-add p normal-tip)
	    (widget-add p button1)
	    (widget-add p button2)
	    (widget-add p button3)
	    (widget-add p button4)

        (widget-add-draw
            button3
            (lambda (w p)
            (let ((x (widget-get-attr w %gx))
                    (y (widget-get-attr w %gy)))
                    (draw-image (+ 6.0 x) (+ y 6.0) 20.0 20.0 icon))))
        
        (widget-set-attrs checkbox-tip 'text-align 'left)
        (widget-add p checkbox-tip)
        (widget-add p box)

        (widget-set-attrs radio-tip 'text-align 'left)
        (widget-add p radio)
        ))


(define (image-demo)
    (let ((p (dialog 220.0 10.0 200.0 600.0 "图片demo"))
        (icon (load-texture "duck.png"))
        (normal-tip (text 120.0 30.0 "本地加载"))
        (test1 (image 180.0 180.0 "duck.png"))
        (net-tip (text 120.0 30.0 "网络加载"))
        (test2 (image-net 180.0 180.0 "http://www.cosplayjia.com/up/spw/img/171220/1712200840035a39b16346c5a/5a39b1646c7ff.jpg"))
        )

        (widget-set-attrs normal-tip 'text-align 'left)
        (widget-add p normal-tip)
        (widget-add p test1)
        (widget-set-attrs net-tip 'text-align 'left)
        (widget-add p net-tip)
        (widget-add p test2)
        ))

(define (video-demo)
    (let ((p (dialog 430.0 10.0 230.0 600.0 "视频demo"))
        (icon (load-texture "duck.png"))
        (normal-tip (text 120.0 30.0 "本地播放"))
        (test1 (video (/ 400.0 2.0) (/ 600.0 2.0) "/Users/evil/Downloads/0E40154524ECB7665EF37D8505DC857A.mp4"))
        (net-tip (text 120.0 30.0 "网络播放"))
        (progress (progress 200.0 10.0 20.0))
        (test2 (video (/ 640.0 3.0) (/ 360.0 3) "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"))
        )

        (widget-set-attrs normal-tip 'text-align 'left)
        (widget-add p normal-tip)
        (widget-add p test1)

        (widget-add-draw
            test1
            (lambda (widget parent)
            (let ((fps (video-get-fps (widget-get-attrs widget 'video)))
                (duration (video-get-duration (widget-get-attrs widget 'video)))
                (current-duration (video-get-current-duration (widget-get-attrs widget 'video)))
                    (gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
                    (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
                (draw-text (+ gx )
                        (+ gy)
                        (format "fps ~a ~a/~a"
                        fps
                        (flonum->fixnum current-duration)
                        (flonum->fixnum duration)))
            (widget-set-attrs progress 'percent (/ current-duration duration))
            )
            (window-post-empty-event)
            '()
            ))

        (widget-set-attrs net-tip 'text-align 'left)
        (widget-add p progress)

        (widget-set-events
            test1
            'click
            (lambda (widget p type data)
                (printf "click play\n")
                (video-set-pause (widget-get-attrs widget 'video) 0)
                ))

        (widget-set-events
            test2
            'click
            (lambda (widget p type data)
                (printf "click 2 play\n")
                (video-set-pause (widget-get-attrs widget 'video) 0)
                ))


        (widget-add p net-tip)
        (widget-add p test2)
        ))

(define (tree-demo)
  (let ((d (dialog 670.0 10.0 250.0 600.0 "树demo"))
	(t (tree 200.0 2500.0 "根节点")))
    (let loop ((i 0))
      (if (< i 8)
	  (let ((v (icon-tree  200.0 200.0  (format "节点~a\n" i)) ))
	    (widget-set-margin v 4.0 4.0 4.0 4.0)
	    (widget-add t v)
	    (let loop2 ((j 0))
	      (if (< j 3)
		  (let ((vv (icon-tree  120.0 40.0 (format " 节点~a ~a\n" i j))))
		    ;;(widget-add v (view 120.0 40.0 (format "text ~a ~a\n" i j)))
		     (widget-add v vv)
		    (let loop3 ((k 0))
		      (if (< k 4)
			  (let ((vvv (icon-tree  120.0 40.0 (format "  节点~a ~a ~a\n" i j k))))
			    (widget-add vv vvv )
			    (let loop4 ((l 0))
			      (if (< l 4 )
				  (let ()
				    (widget-add vvv (tree 120.0 40.0 (format "   ~a ~a ~a ~a\n" i j k l)))
				    ;;(widget-add vvv (view 0.0 40.0 (format "text ~a ~a ~a ~a\n" i j k l )))
				    ;;(widget-add vvv (button 120.0 40.0 (format "text ~a ~a ~a ~a\n" i j k l )))
				    (loop4 (+ l 1)))
				    ))
			    (loop3 (+ k 1))
			    )))
		    (loop2 (+ j 1))
		    )))
	    (loop (+ i 1))
	    )
	  ))
    (widget-add d t)
    ))

(define (duck-demo)
  (set! window (window-create width height "鸭子gui demo"))
  (window-set-fps-pos 750.0 0.0)
  (window-show-fps #t)
  ;;widget add here
  (button-demo)
  (image-demo)
  (video-demo)
  (tree-demo)


  ;;run
  (window-loop window)
  (window-destroy window)
  )

(duck-demo)

     