;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui window)
  (export
   window-create
   window-destroy
   window-loop
   window-get-mouse-pos
   window-get-mouse-x
   window-get-mouse-y
   window-show-fps
   window-post-empty-event
   window-set-fps-pos
   )

  (import (scheme)
	  (gui duck)
	  (cffi cffi)
	  (glfw glfw)
	  (gui graphic)
	  (utils libutil)
	  (utils macro)
	  (gles gles1))

  (define mouse-x 0)
  (define mouse-y 0)
  (define is-show-fps #f)
  (define fps-x 0.0)
  (define fps-y 0.0)
  

  (define fb-width  (cffi-alloc 8) )
  (define fb-height (cffi-alloc 8))

  (define (window-post-empty-event)
    (glfw-post-empty-event))

  (define (window-set-fps-pos x y)
    (set! fps-x x)
    (set! fps-y y))
  
  (define (window-show-fps t)
    (set! is-show-fps t)
    )

  (define (window-get-mouse-x window)
    mouse-x)
  
  (define (window-get-mouse-y window)
    mouse-y)
  
  (define (window-get-mouse-pos window)
    (list mouse-x mouse-y))
  
  (define (window-event-init window)
    (glfw-set-cursor-pos-callback
     window 
     (lambda (w x y)
       ;;(display (format "w=~x ~x ~a,~a\n" w window x y ))
       (glfw-post-empty-event)
       (set! mouse-x x)
       (set! mouse-y y)
       (widget-event 1 (vector x y))
       
       ))

    (glfw-set-char-mods-callback
     window
     (lambda (w char mods)
       ;;(printf "char ~a ~a\n" char mods)
       (widget-event 5 (vector char mods))
       ))
    
    (glfw-set-mouse-button-callback
     window
     (lambda (w button action mods)
       ;;(printf "w=~x button=~a action=~a mods=~a\n" w button action mods)
       (widget-mouse-button-event  (vector button action mods mouse-x mouse-y) )
       ))

    (glfw-set-key-callback
     window 
     (lambda (w k s a m)
       (widget-event 2 (vector k s a m))
       ;;(display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))
       ))
    (glfw-set-scroll-callback
     window
     (lambda (w x y)
       ;;(printf "w=~x x=~a y=~a\n" w x y)
       (widget-scroll-event (vector x y mouse-x mouse-y))
       ))
    (glfw-set-window-size-callback
     window
     (lambda (w width height)
       (widget-window-resize width height)
       ;;(printf "resize ~a ~a\n" width height)
       )
     )
    
    )

  (define (collect-thread)
    (if (threaded?)
	(fork-thread
	 (lambda ()
	   (let loop ()
	     (collect)
	     (printf "tid=~a\n" (get-thread-id))
	     (sleep (make-time 'time-duration 0 1))
	     (loop))))))
  
  (define (window-create width height title)
    (let ((window '()))
      (glfw-init)
      (set! window (glfw-create-window width  height  title   0  0) )
      (glfw-window-hint GLFW_DEPTH_BITS 16);
      (glfw-make-context-current window);
      (glad-load-gles2-loader  (get-glfw-get-proc-address) )
      (glfw-get-framebuffer-size window fb-width fb-height)
      (printf "~a ,~a\n" (cffi-get-int fb-width) (cffi-get-int fb-height))
      (glfw-swap-interval 1)
      
      (widget-init width height)
      (window-event-init window)
      ;;(collect-thread)
      
      window
      ))

  (define (window-loop window)
    (glEnable GL_BLEND)
    (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
    (widget-layout)
    (while (= (glfw-window-should-close window) 0)
	   ;;(glClearColor 1.0  0.0  0.0  1.0 )
	   (glClearColor 0.3 0.3 0.32 1.0 )
	   (glClear (+   GL_COLOR_BUFFER_BIT ))
	   ;;(if is-show-fps
	       ;;(graphic-draw-text fps-x fps-y (format "fps=~a\n" (graphic-get-fps) )))
	   (glfw-wait-events)
	   (widget-render)
	   ;;(glfw-poll-events)
	   (glfw-swap-buffers window)
	   (collect)
	   ))
  
  (define (window-destroy window)
    (widget-destroy)
    (glfw-destroy-window window);
    (glfw-terminate))
   

  )
