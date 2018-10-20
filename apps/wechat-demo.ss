;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 10/20/18.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui graphic)
	 (gui duck)
	 (gui stb)
	 (gles gles1)
	 (gui window)
	 (gui layout)
	 (gui widget)
	 (cffi cffi)
	 (gui video)
	 (utils libutil) (utils macro) )

(define window '() )
(define width 840)
(define height 700)
;;(cffi-log #t)

(define avatar-demo '())

(define (chat-item w h name tip time)
  (let ((it (view w h))
	)
    (widget-add-draw
     it
     (lambda (w p)
       (let ((x (vector-ref w %gx))
	     (y (vector-ref w %gy)))
	 (draw-text (+ x 68.0) (+ y 16) name #x4a4a4a)
	 (draw-text (+ x 68.0) (+ y 40.0) tip #xb0b0b0)
	 (draw-text (+ x 220.0) (+ y 16.0) time #xbababa)

	 (draw-image (+ x 12.0) (+ y 16.0) 48.0 48.0 avatar-demo)
	 )
       ))
    (widget-set-padding it 15.0 20.0 20.0 20.0)
    it
    ))

(define (wechat-app)
  (set! window (window-create width height "微信"))
  (window-set-fps-pos 750.0 0.0)
  ;;(window-set-fps-pos  0.0  0.0)
  (window-show-fps #t)
  ;;init res
  (set! avatar-demo (load-texture "duck.png"))
  
  ;;widget add here
  (let ((main (view (* 1.0 width) %match-parent))
	(left (view 70.0 %match-parent ))
	(mid (view 266.0 %match-parent))
	(right (view 500.0 %match-parent ))
	(avatar (image 46.0 46.0 "duck.png"))
	(chat (image 32.0 32.0 "chat.png"))
	(contact (image 26.0 26.0 "contact.png"))
	(collect (image 26.0 26.0 "collect.png"))
	(setting (image 26.0 26.0 "setting.png"))
	(wechat (image 70.0 70.0 "wechat.png"))

	)
    
    (widget-add main left)
    (widget-add main mid)
    (widget-add main right)

    (widget-set-margin avatar 10.0 10.0 40.0 40.0)
    (widget-set-margin chat 18.0 10.0 40.0 40.0) 
    (widget-set-margin contact 20.0 10.0 40.0 40.0) 
    (widget-set-margin collect 20.0 10.0 40.0 40.0) 
    (widget-set-margin setting 20.0 10.0 340.0 40.0) 

    (widget-set-margin wechat 200.0 200.0 280.0 40.0) 

    (widget-add left avatar)
    (widget-add left chat)
    (widget-add left contact)
    (widget-add left collect)
    (widget-add left setting)
    (widget-add right wechat)

    (let loop
	((i 0)
	 (item (chat-item %match-parent 70.0 "鸭子" "哇哈哈" "12:02")))
	 (if (< i 40)
	     (begin
	       (widget-set-attrs item 'background #xf3f3f3)
	       (widget-add mid item)
	       (loop (+ i 1)  (chat-item %match-parent 70.0 "Lisp兴趣小组" "测试消息" "12:02")))
	     ))

    (widget-set-attrs left  'background #x262626)
    (widget-set-attrs right 'background #x00ffffff)
    (widget-add main)    
    )
  
  ;;run
  (window-loop window)
  (window-destroy window)
  )

(wechat-app)


