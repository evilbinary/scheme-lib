;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui pc-window)
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
   window-add-loop
   window-loop-one
   window-set-wait-mode
   window-set-size
   window-set-title
   window-set-input-mode
   )

  (import (scheme)
	  (gui widget)
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
  (define all-loops (list))
  (define event-wait-mode #t)

  (define fb-width  (cffi-alloc 8) )
  (define fb-height (cffi-alloc 8))
  (define ratio 1)
  (define cursors (make-hashtable equal-hash equal?))

  (define (window-set-input-mode window mode)
    (cond
      [(eq? mode 'normal)  
        (glfw-set-input-mode window GLFW_CURSOR GLFW_CURSOR_NORMAL)]
      [(eq? mode 'hidden)  
        (glfw-set-input-mode window GLFW_CURSOR GLFW_CURSOR_HIDDEN)]
      [(eq? mode 'disable)  
        (glfw-set-input-mode window GLFW_CURSOR GLFW_CURSOR_DISABLED)]
    )
  )

  (define (window-cursor-init)
   (hashtable-set! cursors 'arrow (glfw-create-standard-cursor GLFW_ARROW_CURSOR))
   (hashtable-set! cursors 'hand (glfw-create-standard-cursor GLFW_HAND_CURSOR))
   (hashtable-set! cursors 'ibeam (glfw-create-standard-cursor GLFW_IBEAM_CURSOR))
   (hashtable-set! cursors 'crosshair (glfw-create-standard-cursor GLFW_CROSSHAIR_CURSOR ))
   (hashtable-set! cursors 'hresize (glfw-create-standard-cursor GLFW_HRESIZE_CURSOR ))
   (hashtable-set! cursors 'vresize (glfw-create-standard-cursor GLFW_VRESIZE_CURSOR))   
  )
  
  (define (window-set-cursor window mod)
    (glfw-set-cursor window (hashtable-ref cursors mod '()) ))

  (define (window-post-empty-event)
    (glfw-post-empty-event)
    )

  (define (window-set-title window title)
    (glfw-set-window-title window title))
  
  (define (window-set-size window w h)
    (glfw-set-window-size window w h))

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

  (define (window-set-wait-mode t)
    (set! event-wait-mode t))
  
  (define (window-get-mouse-pos window)
    (list mouse-x mouse-y))
  
  (define (window-event-init window)
    (glfw-set-cursor-pos-callback
     window 
     (lambda (w x y)
       ;;(display (format "w=~x ~x ~a,~a\n" w window x y ))
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
       (glViewport 0 0 (* width ratio) (* height ratio))
       (widget-window-resize width height)
       (glClearColor 0.3 0.3 0.32 1.0 )
       (glClear (+   GL_COLOR_BUFFER_BIT ))
       (widget-render)
       (glfw-swap-buffers window)
       ;;(printf "resize ~a ~a\n" width height)
       )
     )
    
    )

  (define (collect-thread)
    (if (and (procedure? (top-level-value 'fork-thread)) (threaded? ))
     (try
      ((top-level-value 'fork-thread)
      (lambda ()
        (let loop ()
          (collect)
          (printf "tid=~a\n" (get-thread-id))
          (sleep (make-time 'time-duration 0 1))
          (loop))))
      (catch (lambda (x) 
		    (display-condition x) 
		  )))
    ))
  
  (define (window-create width height title)
    (let ((window '()))
      (glfw-init)
      (set! window (glfw-create-window width  height  title   0  0) )
      ;;(glfw-window-hint GLFW_DEPTH_BITS 16)
      ;;(glfw-window-hint 0 GLFW_TRUE)
      ;(glfw-window-hint #x0002000A GLFW_TRUE);
      ;;(glfw-window-hint #x00020005 GLFW_FALSE)

      (glfw-make-context-current window);
      (glad-load-gles2-loader  (get-glfw-get-proc-address) )
      (glfw-get-framebuffer-size window fb-width fb-height)
      (printf "~a ,~a ~a,~a\n" (cffi-get-int fb-width) (cffi-get-int fb-height) width height)
      (glfw-swap-interval 1)
      (set! ratio  (/ (cffi-get-int fb-width) width) )
      (window-cursor-init)
      (widget-init-cursor (lambda (mod)
        (window-set-cursor window mod)
        ))
      (widget-init width height (/  (cffi-get-int fb-width) width) )
      (window-event-init window)
      ;;(collect-thread)

      (glEnable GL_BLEND)
      (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
      
      window
      ))

  (define (window-add-loop fun)
    (set! all-loops (append all-loops (list fun)))
    )

  (define (window-run-loop)
    (let loop ((l all-loops))
      (if (pair? l)
	  (begin
	    ((car l))
	    (loop (cdr l))
	    )))
    )

  (define (window-loop-one window)
    (glClearColor 0.3 0.3 0.32 1.0 )
    (glClear (+   GL_COLOR_BUFFER_BIT ))
    ;;(if is-show-fps
	  ;;(graphic-draw-text-immediate fps-x fps-y (format "fps=~a\n" (graphic-get-fps) )))
    (if event-wait-mode
	(glfw-wait-events)
	(glfw-poll-events))
    (widget-render)
    (window-run-loop)
    (glfw-swap-buffers window))

  (define (window-loop window)
    (glEnable GL_BLEND)
    (glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA)
    (widget-layout)
    (while (= (glfw-window-should-close window) 0)
	   ;;(glClearColor 1.0  0.0  0.0  1.0 )
	   (glClearColor 0.3 0.3 0.32 1.0 )
	   (glClear (+   GL_COLOR_BUFFER_BIT ))
	   ;;(if is-show-fps
	       ;;(graphic-draw-text-immediate fps-x fps-y (format "fps=~a\n" (graphic-get-fps) )))

	   (if event-wait-mode
	       (glfw-wait-events)
	       (glfw-poll-events))
	   
	   (widget-render)
	   (window-run-loop)
	   
	   (glfw-swap-buffers window)
	   ;;(collect)
	   ))
  
  (define (window-destroy window)
    (widget-destroy)
    (glfw-destroy-window window);
    (glfw-terminate))
  )
