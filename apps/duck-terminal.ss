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
   (gui terminal)
   (gui graphic)
	 )

(define window '() )
(define width 800)
(define height 700)


(define (terminal-app)
   (let ((term (terminal (* height 1.0) (* width 1.0) )))
    (widget-set-padding term 4.0 0.0 0.0 10.0)
    (widget-add term)
  )
)

(define (duck-app)
  (set! window (window-create width height "鸭子termnial"))
  (terminal-app)
  (window-set-wait-mode #f)
  ;;run
  (window-loop window)
  (window-destroy window)
  )

(duck-app)
