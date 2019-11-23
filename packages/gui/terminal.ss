;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui terminal)
    (export
        terminal-create
        terminal-render
        terminal-destroy
        terminal-key-event
        terminal-char-event
        terminal-resize
		terminal-set-mvp
        terminal
    )
    (import (scheme) (utils libutil) (cffi cffi) (gles gles2)
        (gui graphic) (gui widget) (gui layout)
        (gui draw)
         )
    (load-librarys "libterminal")

    (def-function terminal-create "terminal_create" (void* float float float) void*)
    (def-function terminal-render "terminal_render" (void* float float) void)
    (def-function terminal-destroy "terminal_destroy" (void*) void)
    (def-function terminal-key-event "terminal_key_event" (void* int int int int) void)
    (def-function terminal-char-event "terminal_char_event" (void* int int) void)
    (def-function terminal-resize "terminal_resize" (void* int int) void)
    (def-function terminal-set-mvp "terminal_set_mvp" (void* void* float float) void)

 	(define my-width 0)
    (define my-height 0)
    (define my-ratio 0)
    (define font-program 0)
	(define font-mvp 0)

 (define (terminal w h)
    (let ((widget (widget-new 0.0 0.0 w h ""))
	  	(term '()))
	  (set! term (terminal-create (widget-get-attrs widget 'font (graphic-get-font "RobotoMono-Regular.ttf")) (widget-get-attrs widget 'font-size  40.0)  w h))
	  (terminal-set-mvp term font-mvp my-width my-height)

	  (widget-set-attrs widget 'terminal  term)
      (widget-set-layout
       widget
       flow-layout
       )
      
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 (let ((x  (vector-ref  widget %x))
	       (y  (vector-ref widget %y))
	       (w  (vector-ref  widget %w))
	       (h  (vector-ref  widget %h))
	       (draw (vector-ref widget %draw))
		
		(top  (vector-ref widget %top))
	    (left  (vector-ref widget %left))
	    (right  (vector-ref widget %right))
	    (bottom  (vector-ref widget %bottom))

			(gx  (widget-in-parent-gx widget parent) )
			(gy  (widget-in-parent-gy widget parent) )
		   )

            (vector-set! widget %gx  gx )
            (vector-set! widget %gy gy )
            (graphic-sissor-begin gx gy w h)

            ; (if (equal? '() background)
            ;     (draw-panel gx gy w h '())
            ;     (draw-panel gx gy w h '() background))
            (terminal-render term (+ left gx) (+ top gy) )
		 
	   
	   (widget-draw-child widget)
	   
	   (graphic-sissor-end)
	   
	   )))

      (widget-set-event
       widget
       (lambda (widget parent type data)
		(if (and (= type %event-mouse-button) )
			(begin
			;;(widget-active widget)	       
			(widget-child-rect-event-mouse-button widget type data)
			;    (printf "view click event ~a ~a ~a\n" type (widget-get-attr widget %text) data)
			;;(draw-widget-child-rect parent widget )
			))
		(if (= type %event-scroll)
			(begin
			(widget-child-rect-event-scroll widget type data)
			))
		(if (and (or (= type %event-char) (= type %event-key))  ) ;;(=  (vector-ref widget %status) %status-active)
			(begin
			;;(printf "\nview ~a key event ~a ~a status=~a\n" (widget-get-attr widget %text)  type  data (vector-ref widget %status) )
			(widget-child-key-event widget type data)
			 (if (= type %event-key)
				(terminal-key-event term
									(vector-ref data 0)
									(vector-ref data 1)
									(vector-ref data 2)
									(vector-ref data 3) ))
			(if (= type %event-char) 
				(begin 
					(terminal-char-event term 
							(vector-ref data 0)
							(vector-ref data 1) ) )
				)
			;;(draw-widget-child-rect parent widget )
			))
		(if (= type %event-motion)
			(widget-child-rect-event-mouse-motion widget type data))
	 ))
      widget))


	(graphic-add-init-event (lambda (g w h)
		(set! my-width w)
		(set! my-height h)
		(set! font-program (hashtable-ref g 'font-program '()))
		(set! my-ratio (hashtable-ref g 'ratio 1.0))
		(set! font-mvp (hashtable-ref g 'font-mvp '()))
	))

)