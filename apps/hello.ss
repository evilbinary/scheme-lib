;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 11/11/18.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui duck)
	 (gui window)
	 (gui widget)
	 )

(define window '() )
(define width 800)
(define height 700)

(define (duck-app)
  (set! window (window-create width height "hello鸭子"))

  (let ((d (dialog 100.0 80.0 300.0 200.0 "hello")))
	'()
	)
  ;;run
  (window-loop window)
  (window-destroy window)
  )

(duck-app)
