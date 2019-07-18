;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 10/20/18.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui graphic)
	 (gui duck)
   (gui draw)
	 (gui stb)
	 (gles gles1)
	 (gui window)
	 (gui layout)
	 (gui widget)
	 (cffi cffi)
	 (gui video)
	 (utils libutil) (utils macro) )

(define window '() )
(define width 900)
(define height 700)
;;(cffi-log #t)

(define avatar-demo '())
(define icon-people '())


(define (chat-item w h name tip time)
  (let ((it (view w h))
	)
    (widget-add-draw
     it
     (lambda (w p)
       (let ((x (vector-ref w %gx))
	     (y (vector-ref w %gy)))
	 (draw-text (+ x 68.0) (+ y 16) name #xff4a4a4a)
	 (draw-text (+ x 68.0) (+ y 40.0) tip #xffb0b0b0)
	 (draw-text (+ x 220.0) (+ y 16.0) time #xffbababa)
	 (draw-line (+ x) (+ y ) (+ x 266.0) (+ y ) #xf2f2f2)
	 (draw-line (+ x 266.0) (+ y ) (+ x 266.0 ) (+ y 76.0) #xf2f2f2)
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
  (set! avatar-demo (load-texture "res/duck.png"))
  (set! icon-people (load-texture "res/pepole.png"))
  ;;widget add here
  (let ((main (view (* 1.0 width) %match-parent))
	(left (view 70.0 %match-parent ))
	(mid (view 266.0 %match-parent))
	(right (view 500.0 %match-parent ))
	(avatar (image 46.0 46.0 "res/duck.png"))
	(chat-img (image 32.0 32.0 "res/chat.png"))
	(contact (image 26.0 26.0 "res/contact.png"))
	(collect (image 26.0 26.0 "res/collect.png"))
	(setting (image 26.0 26.0 "res/setting.png"))
	(wechat (image 70.0 70.0 "res/wechat.png"))
	(chat (view 570.0 %match-parent))
	(chat-head (view 570.0 60.0))
	(chat-content (view 570.0 436.0))
	(chat-input (edit 570.0 160.0 ""))
	(chat-op (view 570.0 46.0))

	(face (image 22.0 22.0 "res/smail.png"))
	(file (image 22.0 22.0 "res/file.png"))
	(shot (image 22.0 22.0 "res/shot.png"))
	(history (image 20.0 22.0 "res/history.png"))

	)
    (widget-set-layout right frame-layout)
    
    (widget-add main left)
    (widget-add main mid)
    (widget-add main right)

    (widget-set-margin avatar 10.0 10.0 40.0 40.0)
    (widget-set-margin chat-img 18.0 10.0 40.0 40.0) 
    (widget-set-margin contact 20.0 10.0 40.0 40.0) 
    (widget-set-margin collect 20.0 10.0 40.0 40.0) 
    (widget-set-margin setting 20.0 10.0 340.0 40.0) 

    (widget-set-margin wechat 200.0 200.0 280.0 40.0) 

    (widget-set-attrs left  'background #x262626)
    (widget-set-attrs right 'background #xffffff)

    (widget-set-attrs chat-head 'background #xf2f2f2)
    (widget-set-attrs chat-content 'background #xf2f2f2)
    (widget-set-attrs chat-op 'background #xf2f2f2)
    (widget-set-attrs chat-input 'background #xf2f2f2)
    (widget-set-attrs chat 'background #xf2f2f2)
    (widget-set-attrs chat-input 'color #xff000000)

     
    (widget-add left avatar)
    (widget-add left chat-img)
    (widget-add left contact)
    (widget-add left collect)
    (widget-add left setting)
    (widget-add right wechat)
    (widget-add right chat)
    (widget-add chat chat-head)
    (widget-add chat chat-content)
    (widget-add chat chat-op)
    (widget-add chat chat-input)

    (widget-set-margin face 20.0 0.0 15.0 15.0) 
    (widget-set-margin file 20.0 0.0 15.0 15.0) 
    (widget-set-margin shot 20.0 0.0 15.0 15.0) 
    (widget-set-margin history 20.0 0.0 15.0 15.0) 
    (widget-set-margin chat-input 20.0 0.0 5.0 5.0) 

    (widget-add chat-op face)
    (widget-add chat-op file)
    (widget-add chat-op shot)
    (widget-add chat-op history)
    
    (widget-set-attr chat %text "chat")
    (widget-set-attr chat-input %text "我是一段文字输入，哈哈逗逼")

    (widget-add-draw
     chat-op
     (lambda (w p)
       (let ((x (vector-ref w %gx))
	     (y (vector-ref w %gy)))
	 (draw-line (+ x ) (+ y ) (+ x (widget-get-attr w %w)) (+ y ) #xe5e5e5)
	 (draw-line (+ x ) (+ y 1) (+ x (widget-get-attr w %w)) (+ y ) #xe5e5e5)

	 )))

    (widget-add-draw
     chat-head
     (lambda (w p)
       (let ((x (vector-ref w %gx))
	     (y (vector-ref w %gy)))
	 (draw-line (+ x ) (+ y 59.0) (+ x (widget-get-attr w %w)) (+ y 59.0) #xe5e5e5)
	 (draw-line (+ x ) (+ y 58.0) (+ x (widget-get-attr w %w)) (+ y 58.0) #xe5e5e5)
	 (draw-text (+ x 20.0) (+ y 18.0)  "Lisp兴趣项目测试组" #xff000000)
	 (draw-image (+ x 530.0) (+ y 20.0)  24.0 24.0  icon-people)
	 )))
    
    (let loop
	((i 0)
	 (item (chat-item %match-parent 70.0 "鸭子" "哇哈哈" "12:02")))
	 (if (< i 40)
	     (begin
	       (widget-set-attrs item 'background #xfdfdfd)
	       (widget-add mid item)
	       (loop (+ i 1)  (chat-item %match-parent 70.0 "Lisp兴趣小组" "测试消息" "12:02")))
	     ))

   
    (widget-add main)    
    )
  
  ;;run
  (window-loop window)
  (window-destroy window)
  )

(wechat-app)


