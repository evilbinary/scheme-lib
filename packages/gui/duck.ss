;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui duck)
  (export
   draw-image
   draw-dialog
   dialog
   button
   image
   text
   scroll
   edit
   video
   tab
   widget-init
   widget-add
   widget-render
   widget-event
   widget-mouse-button-event
   widget-scroll-event
   widget-layout
   widget-set-layout
   widget-set-margin
   widget-set-xy
   draw-widget-child-rect
   draw-widget-rect
   widget-add-draw
   widget-set-draw
   widget-get-draw
   widget-set-event
   widget-get-event
   widget-add-event
   widget-get-child
   widget-set-padding
   widget-resize
   widget-get-attr
   widget-set-attr
   widget-disable-cursor
   widget-set-cursor
   widget-new
   widget-copy
   widget-set-text-font-size
   widget-set-text-font-color
   flow-layout
   frame-layout
   %gx
   %gy
   %w
   %h
   %x
   %y
   )
  (import (scheme) (utils libutil) (gui graphic ) (gui video) (gui stb))

  ;;common
  (define %draw 5)
  (define %x 0)
  (define %y 1)
  (define %w 2)
  (define %h 3)
  (define %layout 4)
  (define %event 6)
  (define %child 7)
  (define %status 8)
  
  (define %top 9)
  (define %bottom 10)
  (define %left 11)
  (define %right 12)
  
  (define %margin-top 13)
  (define %margin-bottom 14)
  (define %margin-left 15)
  (define %margin-right 16)
  (define %parent 17)
  (define %gx 18)
  (define %gy 19)
  (define %text 20)
  (define %last-common-attr 21)
  ;;private
  (define %scroll-direction (+ %last-common-attr 0))
  (define %scroll-rate (+ %last-common-attr 1))
  (define %scroll-x (+ %last-common-attr 2))
  (define %scroll-y (+ %last-common-attr 3))
  (define %scroll-height (+ %last-common-attr 4))

  (define %status-active 1)
  (define %status-default 0)
  

  (define window-width 0)
  (define window-height 0)
  
  (define %event-scroll 4)
  (define %event-key 2)
  (define %event-char 5)
  (define %event-mouse-button 3)
  (define %event-motion 1)
  (define %event-resize 6)

  (define %match-parent -1)
  (define %wrap-conent 0)

  (define cursor-x 0)
  (define cursor-y 0)
  (define cursor-arrow 0)
  
  (define (draw-dialog x y w h title)

    (graphic-draw-solid-quad  x y
			      (+ x w) (+ y 30)
			      31.0 31.0 31.0 0.9)

    (graphic-draw-solid-quad  x y
			      (+ x w) (+ y h)
			      ;;255 255 255 8)
			      ;;46.0 55.0 53.0 255.0)
			      ;;255.0 255.0 255.0 0.2)
			      ;;28.0 30.0 34.0 0.4)
			      31.0 31.0 31.0 0.8)
    (graphic-draw-text (+ x 30) (+ y 20) title)
    
    )

  (define (draw-button x y w h text)
    (graphic-draw-solid-quad  x y
			      (+ x w) (+ y h)
			      31.0 31.0 31.0 0.9)
    (graphic-draw-text (+ x (/ w 2.0 ) -5)
		       (+ y (/ h 2.0) 5)
		       text)
    )

  (define (draw-image x y w h src)
    (graphic-draw-texture-quad
     x y
     (+ x w) (+ y h)
      0.0 0.0 1.0 1.0 src))

  (define (draw-text x y  text)
    (graphic-draw-text x y text )
    )

  (define (draw-rect x y w h)
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  128.0 30.0 34.0 0.5))
  
  (define (draw-video v x y w h )
    (let l ((i 3))
      (if (> i 0)
	  (begin
	    (video-render v x y (+ x w) (+ y h) )
	    (l (- i 1))
	    ))))

  (define (draw-tab x y w h active)
    (if active
	(graphic-draw-solid-quad
	 x y
	 (+ x w) (+ y h)
	 31.0 31.0 31.0 0.6)
	(graphic-draw-solid-quad
	 x y
	 (+ x w) (+ y h)
	 61.0 61.0 61.0 0.9))
    )
  
  (define (draw-scroll-bar x y w h pos scroll-h)
    (graphic-draw-solid-quad  x y
			      (+ x w) (+ y h)
			      31.0 31.0 31.0 0.6)

    ;;(printf "scroll-h ~a ~a\n" scroll-h (/  (* pos h) scroll-h))
    
    (graphic-draw-solid-quad  x (+ y (/ (* pos h) scroll-h ) )
    			      (+ x w) (+ y (/ (* pos h) scroll-h ) (/ scroll-h h 0.1 ))
    			     31.0 31.0 31.0 0.9)
    )

  
  
  ;;layout
  (define (grid row col )
    (lambda (widget row col)
      '()
      )
    )
  (define (widget-set-margin widget left right top bottom)
    (vector-set! widget %margin-left left)
    (vector-set! widget %margin-right right)
    (vector-set! widget %margin-top top)
    (vector-set! widget %margin-bottom bottom)
    )
  (define (widget-set-padding widget left right top bottom)
    (vector-set! widget %left left)
    (vector-set! widget %right right)
    (vector-set! widget %top top)
    (vector-set! widget %bottom bottom)
    )
  
  (define (widget-set-xy widget x y)
    (vector-set! widget %x x)
    (vector-set! widget %y y)
    )

  (define frame-layout
    (case-lambda
     [(widget)
      (let ((x  (vector-ref widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref widget %w))
	    (h  (vector-ref widget %h))
	    (top  (vector-ref widget %top))
	    (left  (vector-ref widget %left))
	    (right  (vector-ref widget %right))
	    (bottom  (vector-ref widget %bottom))
	    
	    (child (vector-ref widget %child))
	    )
	(let loop ((c child) )
	  (if (pair? c)
	      (begin
		(vector-set! (car c) %x left)
		(vector-set! (car c) %y top)
		
		((vector-ref (car c) %layout) (car c))
		(loop (cdr c) )
		)
	      ))
	)]
     [(widget layout-info)
      (let ((x  (vector-ref  widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref  widget %w))
	    (h  (vector-ref  widget %h)))
	'()
	)]
      
     ))
  
  
  (define flow-layout 
    (case-lambda
     [(widget)
      (let ((x  (vector-ref widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref widget %w))
	    (h  (vector-ref widget %h))
	    (top  (vector-ref widget %top))
	    (left  (vector-ref widget %left))
	    (right  (vector-ref widget %right))
	    (bottom  (vector-ref widget %bottom))
	    
	    (child (vector-ref widget %child))
	    )
	(let loop ((c child) (sx left) (sy top) (ww 0) )
	  (if (pair? c)
	      (begin
		(vector-set! (car c) %x sx)
		(vector-set! (car c) %y sy)
		
		(if (pair? (cdr c))
		    (set! ww (vector-ref (car (cdr c)) %w)))
		
 		(if (> (+ sx (vector-ref (car c) %w) ww ) w)
		    (begin
		      (set! sx left)
		      (set! sy (+ sy (vector-ref (car c) %h)
				  (vector-ref (car c) %margin-top)
				  (vector-ref (car c) %margin-bottom)
				  ))
		      )
		    (begin
		      (set! sx (+ sx (vector-ref (car c) %w)
				  (vector-ref (car c) %margin-left)
				  (vector-ref (car c) %margin-right)
				  ))
		      )
		    )
		((vector-ref (car c) %layout) (car c))
		(loop (cdr c) sx sy ww )
		)
	      ))
	)]
     [(widget layout-info)
      (let ((x  (vector-ref  widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref  widget %w))
	    (h  (vector-ref  widget %h)))
	'()
	)]
      
     ))
  (define default-layout flow-layout)
    
  (define (widget-set-layout widget layout)
    (vector-set! widget %layout layout))
  
  ;;widget x y w h layout draw event childs status top bottom left righ 
  (define $widgets (list ))

  (define widget-add
    (case-lambda
     [(p)
      (set! $widgets (append! $widgets (list p)))
      p]
     [(p w)
      (vector-set! w %parent p)
      (vector-set! p %child (append! (vector-ref p %child) (list w)))
      ((vector-ref p %layout) p)
      w]
     [(p w layout)
      (vector-set! w %parent p)
      (vector-set! p %child (append! (vector-ref p %child) (list w)))
      ((vector-ref p %layout) p layout)
      w
      ]
     ))

  (define (in-rect x y w h mx my)
    (and (> mx x) (< mx (+ x w)) (> my y) (< my (+ y h))))

  (define (is-in-rect x1 y1 w1 h1 x2 y2 w2 h2)
    (and  (< (abs (- x1 x2)) (/ (+ w1 w2) 2))  (< (abs (- y1 y2))  (/ (+ h1 h2) 2) )) )

  (define (is-in widget data)
    (let ((x  (vector-ref  widget 0))
	  (y  (vector-ref widget 1))
	  (w  (vector-ref  widget 2))
	  (h  (vector-ref  widget 3))
	  (parent (vector-ref widget %parent))
	  )
      (if (null? parent)
	  (in-rect x y w h (vector-ref data 0) (vector-ref data 1))
	  (begin
	    (in-rect  x
		      y 
		      w
		      h
		      (vector-ref data 0) (vector-ref data 1))))))

  (define (is-in-widget widget widget2)
    (let ((x1  (vector-ref  widget %x))
	  (y1  (vector-ref widget %y))
	  (w1  (vector-ref  widget %w))
	  (h1  (vector-ref  widget %h))
	  (x2  (vector-ref  widget2 %x))
	  (y2  (vector-ref widget2 %y))
	  (w2  (vector-ref  widget2 %w))
	  (h2  (vector-ref  widget2 %h))
	  (parent (vector-ref widget %parent))
	  )

      ;;(graphic-draw-solid-quad x1 y1 (+ x1 w1 ) (+ y1 h1)  0.0 255.0 0.0 0.1)
      ;;(graphic-draw-solid-quad x2 y2 (+ x2 w2 ) (+ y2 h2)  0.0  0.0 255.0 0.5)
      
      (if (null? parent)
	  (is-in-rect 0  0  w1  h1  x2 y2 w2 h2 )
	  (is-in-rect (+ x1 (vector-ref parent %left))
		      (+ y1 (vector-ref parent %top))
		      (+ w1 (vector-ref parent %right))
		      (+ h1 (vector-ref parent %bottom))
		      x2 y2 w2 h2 )
	  )
      ;;(printf "~a == ~a\n" (list x y w h) data)
     ))

  (define (calc-height widget)
    (let loop ((child (vector-ref widget %child))
	       (height 0.0))
      (if (pair? child)
	  (begin
	    (loop (cdr child) (+ height (vector-ref (car child) %h  )) ))
	  height)))
  
  (define (set-child-y-offset widget offsety)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (vector-set! (car child)
			 %y
			 (- (vector-ref (car child) %y)
			    offsety))
	    
	    (loop (cdr child)))
	  )))

  (define (widget-set-child widget index value)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (vector-set! (car child) index value)
	    (loop (cdr child)))
	  )))
  
  (define (widget-child-key-event widget type data)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    ;;(printf "in here\n")
	    ((vector-ref (car child) %event) (car child) widget  type data)
	    (loop (cdr child)))
	  )))
  
  (define (widget-child-rect-event widget type data)
    (let ((mx (vector-ref data 3))
	  (my (vector-ref data 4)))
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      ;; (printf "~a ~a\n"

	      ;; 	      (list  (vector-ref widget 0)
	      ;; 		     (vector-ref widget 1)
	      ;; 		     (vector-ref widget %w)
	      ;; 		     (vector-ref widget %h))
	      ;; 	      (vector
	      ;; 		  (- mx (vector-ref widget %gx))
	      ;; 		  (- my (vector-ref widget %gy) )  ))
	      (if (is-in (car child) 
			 (vector
			  (- mx (vector-ref widget %gx))
			  (- my (vector-ref widget %gy) )  ))
		  (begin
		    ;;(printf "in here\n")
		    ((vector-ref (car child) %event) (car child) widget  type data)))

	      (loop (cdr child)))
	    ))))

  (define (scroll w h)
    (let ((widget (widget-new 0.0 0.0 w h "")))
      (vector-set! widget %scroll-direction  1)
      (vector-set! widget %scroll-rate  8.1)
      (vector-set! widget %scroll-x  0.0)
      (vector-set! widget %scroll-y  0.0)
      (vector-set! widget %scroll-height  0.0)
      
      (widget-set-layout
       widget
       (lambda (widget . args)
	 (default-layout widget)
	 (vector-set! widget %scroll-height
		      (calc-height widget))
	 ))
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 (let ((x  (vector-ref  widget %x))
	       (y  (vector-ref widget %y))
	       (w  (vector-ref  widget %w))
	       (h  (vector-ref  widget %h))
	       (draw (vector-ref widget %draw)))

	   (if (null? parent)
	       (let ((gx (+ (vector-ref widget %x)))
		     (gy (+ (vector-ref widget %y))))
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)
		 
		 (graphic-sissor-begin gx gy w h)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 255.0 0.0 0.0 0.5)
		 )
	       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)

		 ;;(printf "~a,~a\n" (vector-ref widget %x) (vector-ref widget %y))
		 ;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 0.0 255.0 0.0 0.5)
		 
		 (graphic-sissor-begin gx gy  w  h )
		 (draw-scroll-bar (+ gx w -10.0 ) gy 10.0 h
				  (vector-ref widget %scroll-y)
				  (vector-ref widget %scroll-height)
				  )
		 ))
	   ;;(draw (vector-ref widget %draw))
	   ;;(draw-widget-rect widget)
	   (widget-draw-rect-child widget)
	   
	   (graphic-sissor-end)
	   )))
      (widget-set-event
       widget
       (lambda (widget parent type data);;event
	 (if (null? parent)
	     (begin
	       (if (= type 3)
		   (draw-widget-child-rect parent widget ))))
	 (begin
	   (if (= type %event-scroll)
	       (begin
		 ;;(printf "event ~a\n" type)
		 (vector-set! widget %scroll-height
			      (calc-height widget))

		 (let ((offsety (* -1.0 (vector-ref widget %scroll-rate)
				   (vector-ref data 1))))
		   
		   (if (and (<= (vector-ref widget %scroll-y) (vector-ref widget %scroll-height))
			    (>= (vector-ref widget %scroll-y) 0))
		       (begin 
			 (vector-set! widget %scroll-y
				      (+ (vector-ref widget %scroll-y)
					 offsety ))

			 )
		       (set! offsety 0.0)
		       )
		   (if (< (vector-ref widget %scroll-y) 0)
		       (begin
			 (set! offsety 0.0)
			 (vector-set! widget %scroll-y 0)))

		   (if (> (vector-ref widget %scroll-y) (vector-ref widget %scroll-height) )
		       (begin
			 (set! offsety 0.0)
			 (vector-set! widget %scroll-y (vector-ref widget %scroll-height) )))

		   (set-child-y-offset widget offsety)
		   ;;(printf "(set! offsety 0)=>~a\n" offsety)
		   ;;(printf "(calc-height widget)=>~a scroll-y=~a\n" (calc-height widget) (vector-ref widget %scroll-y))
		   ))	)
	   (if (= type %event-mouse-button)
	       (begin
		 (widget-child-rect-event widget type data)
		 ;;(printf "button click event ~a ~a ~a\n" type text data)
		 ;;(draw-widget-child-rect parent widget )
		 ))
	   (if (= type %event-key)
	       (begin
		 ;;(printf "scroll key event ~a ~a\n" type data)
		 (widget-child-key-event widget type data)
		 ;;(draw-widget-child-rect parent widget )
		 ))
	   (if (= type %event-char)
	       (begin
		 (widget-child-key-event widget type data)
		 ))
	   )
	 ))
      widget
      ))


  (define (edit w h text)
    (let ((widget (widget-new 0.0 0.0 w h text))
	  (ed (graphic-new-edit w h))
	  (markup  (graphic-new-markup "Roboto-Regular.ttf" 25.0))
	  )
      ;;(gl-markup-set-foreground markup 32.0 32.0 32.0 0.5)
      ;;(gl-edit-set-markup ed markup 0)
      (graphic-edit-add-text ed text markup)
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 
	 (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
	       (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
	   (vector-set! widget %gx gx)
	   (vector-set! widget %gy gy)
	   (graphic-draw-edit ed gx gy)
	   )))
      
      (widget-set-event
       widget
       (lambda (widget parent type data);;event
	 ;;(printf ">>>>>>>event ~a ~a\n" type data)
	 (if (= type %event-key)
	     (begin
	       (printf "edit key event ~a ~a\n" type data )
	       (gl-edit-key-event ed
				  (vector-ref data 0)
				  (vector-ref data 1)
				  (vector-ref data 2)
				  (vector-ref data 3) )
	       ))
	 (if (= type %event-char)
	     (begin
	       (printf ">edit char event ~a ~a\n" type data )
	       (gl-edit-char-event ed
				   (vector-ref data 0)
				   (vector-ref data 1)
				   )
	       ))
	 (if (null? parent)
	     (begin
	       (if (= type 3)
		   (draw-widget-child-rect parent widget )))
	     )
	 (begin
	   (if (= type 3)
	       (begin
		 ;;(printf "button click event ~a ~a ~a\n" type text data)
		 (draw-widget-child-rect parent widget )
		 )))
	 ))
      
      widget
	    
      ))

  (define (tab w h names)
    (let ((widget (widget-new 0.0 0.0 w h "")))
      (widget-set-layout
       widget
       (lambda (widget . args)
	 (frame-layout  widget)
	 (let ((child (widget-get-child widget))
	       (count 0))
	   (let loop ((c child))
	     (if (pair? c)
		 (begin
		   (if (= (widget-get-attr (car child) %status) 1)
		       (set! count (+ count 1)))
		   (loop (car c))
		       )))
	     
	     (if  (and (= count 0) (> (length child) 0) (= 0 (widget-get-attr (car child) %status)))
		  (widget-set-attr (car child) %status 1)) )   
	 ))
      
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 
	 (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
	       (gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
	       (segment (/ (vector-ref widget %w) (length (widget-get-child widget))))
	       )
	   (vector-set! widget %gx gx)
	   (vector-set! widget %gy gy)

	   ;;(printf "tab ~a,~a\n" (vector-ref widget %x) (vector-ref widget %y))
	   
	   (graphic-sissor-begin gx gy w h)
	   
	   ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 0.0  0.0 255.0 0.5)
	   ;;draw tab bar
	   (let loop ((child (widget-get-child widget))
		      (name names) (pos 0.0) )
	     (if (pair? child)
		 (begin
		   (draw-tab (+ gx pos ) gy (- segment 5.0) 30.0  (= 1 (widget-get-attr (car child) %status) ))
		   (draw-text (+ gx pos (/ segment 2.0) (- (* 4 (string-length (car name) ))))
			      (+ gy 20.0)
			      (car name) )
		   (loop (cdr child) (cdr name) (+ pos segment ))
		   )))
	   ;;draw select body
	   (let loop ((child (vector-ref widget %child)))
	     (if (pair? child)
		 (begin
		   (if (= (vector-ref (car child) %status ) 1)
		       ((vector-ref (car child) %draw) (car child)  widget))
		   (loop (cdr child)))
		 ))

	   (graphic-sissor-end)
	   
	   )))
      
      (widget-set-event
       widget
       (lambda (widget parent type data);;event
	 (if (null? parent)
	     (begin
	       (if (= type %event-mouse-button)
		   (draw-widget-child-rect parent widget )))
	     )
	 (begin
	   (if (= type %event-mouse-button)
	       
	       (let ((segment (/ (vector-ref widget %w) (length (widget-get-child widget))))
		     (mx (vector-ref data 3))
		     (my (vector-ref data 4))
		     (gx (vector-ref widget %gx))
		     (gy (vector-ref widget %gy))
		     )
	
		 ;;(printf "child count ~a\n" (length (widget-get-child widget)))
		 ;;tab bar click event
		 (let loop ((child (widget-get-child widget)) (pos 0.0))
		   (if (pair? child)
		       (begin
			 ;;(printf "tab child ~a\n" (vector-ref (car child) %status) )
			 (if  (in-rect (+ gx pos)
				      (+ gy )
				      (+ segment)
				      (+ 30.0)
				      mx
				      my)
			     (begin
			       (widget-set-child widget %status 0)
			       (vector-set! (car child) %status 1)
			       ((vector-ref (car child) %event) (car child) widget  type data))
			     )
			 
			 (loop (cdr child) (+ pos segment )))
		       
		       ))
		 ;;child event
		 (widget-child-rect-event-mouse-button
		  widget type data
		  (lambda(wid)		    
		    (= (widget-get-attr wid %status) 1)))
									  
		 ;;(printf "tab click event ~a ~a ~a\n" type text data)
		 ;;(draw-widget-child-rect parent widget )
		 ))
	   (if (= type %event-scroll)
	       (begin
		 (widget-child-rect-event-scroll widget type data)
		 ))	   
	   (if (= type %event-key)
	       (begin
		 ;;(printf "scroll key event ~a ~a\n" type data)
		 (widget-child-key-event widget type data)
		 ;;(draw-widget-child-rect parent widget )
		 ))
	   (if (= type %event-char)
	       (begin
		 (widget-child-key-event widget type data)
		 ))
	   
	   )
	 ))
      (widget-set-padding widget 10.0 10.0 40.0 10.0)
      widget
      ))

  (define (text w h text)
    (let ((widget (widget-new 0.0 0.0 w h text)))
      
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
	       (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
	   (vector-set! widget %gx gx)
	   (vector-set! widget %gy gy)

	   ;;(draw-rect gx gy w h)
	   ;;(draw-widget-rect widget)
	   
	   (draw-text gx
		      (+ (/ h 2) -4.0 gy)
		      text))))
      
      (widget-set-event
       widget
       (lambda (widget parent type data);;event
	 (if (null? parent)
	     (begin
	       (if (= type %event-mouse-button)
		   (draw-widget-child-rect parent widget )))
	     )
	 (begin
	   (if (= type %event-mouse-button)
	       (begin
		 ;;(printf "text click event ~a ~a ~a\n" type text data)
		 (draw-widget-child-rect parent widget )
		 )))
	 ))
      widget
      ))

(define (video w h src)
  (let ((widget (widget-new 0.0 0.0 w h src))
	(vv (video-new src window-width window-height )))
    (widget-set-draw
     widget
     (lambda (widget parent);;draw
       (if (null? parent)
	   (let ((gx (+ (vector-ref widget %x)))
		 (gy (+ (vector-ref widget %y))))
	     (vector-set! widget %gx gx)
	     (vector-set! widget %gy gy)
	     (draw-video vv gx gy
			 w h ))
	   (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		 (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
	     (vector-set! widget %gx gx)
	     (vector-set! widget %gy gy)
	     (draw-video vv gx
			 gy
			 w  h)
	     ))))
     
     (widget-set-event
      widget
      (lambda (widget parent type data);;event
	(if (null? parent)
	    (begin
	      (if (= type %event-mouse-button)
		  (draw-widget-child-rect parent widget )))
	    )
	(begin
	  (if (= type %event-mouse-button)
	      (begin
		;;(printf "button click event ~a ~a ~a\n" type text data)
		(draw-widget-child-rect parent widget )
		)))
	))
     widget	    
     ))
  
(define (image w h src)
  (let ((widget (widget-new 0.0 0.0 w h text))
	(id (load-texture src)))
    
    (widget-set-draw
     widget
     (lambda (widget parent);;draw
       (if (null? parent)
	   (let ((gx (+ (vector-ref widget %x)))
		 (gy (+ (vector-ref widget %y))))
	     (vector-set! widget %gx gx)
	     (vector-set! widget %gy gy)
	     (draw-image gx gy
			 w h id))
	   (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		 (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
	     (vector-set! widget %gx gx)
	     (vector-set! widget %gy gy)
	     (draw-image gx
			 gy
			 w h id))) ))
    
    (widget-set-event
     widget
     (lambda (widget parent type data);;event
       (if (null? parent)
	   (begin
	     (if (= type %event-mouse-button)
		 (draw-widget-child-rect parent widget )))
	   )
       (begin
	 (if (= type %event-mouse-button)
	     (begin
	       ;;(printf "button click event ~a ~a ~a\n" type text data)
	       (draw-widget-child-rect parent widget )
	       )))
       ))
      widget
      ))

(define (widget-set-text-font-size widget size)
  (graphic-set-text-font-size (vector-ref widget %text) size)
  )
(define (widget-set-text-font-color widget r g b a)
 (graphic-set-text-font-color (vector-ref widget %text) r g b a ) )

(define (button w h text)
  (let ((widget (widget-new 0.0 0.0 w h text)))
    (widget-set-draw
     widget
     (lambda (widget parent);;draw
       ;;(printf "draw button ~a ~a\n" (vector-ref widget %x) (vector-ref widget %y))
       ;;(printf "     ~a ~a\n" w h)
       ;;(vector-set! widget %x (+ (vector-ref parent %x) 0))
       ;;(vector-set! widget %y (+ (vector-ref parent %y) 0))
      
       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
	     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
	 (vector-set! widget %gx gx)
	 (vector-set! widget %gy gy)
	 (draw-button gx
		      gy
		      w h text)
	 )))
    (widget-set-event
     widget
     (lambda (widget parent type data);;event	      	      		     
       (if (null? parent)
	   (begin
	     (if (= type %event-mouse-button)
		 (draw-widget-child-rect parent widget ))) )
       (begin
	 (if (= type %event-mouse-button)
	     (begin
	       ;;(printf "button click event ~a ~a ~a\n" type text data)
	       (draw-widget-child-rect parent widget )
	       )))
       ))
    widget))

(define (dialog x y w h title)
  (let ((widget (widget-new x y w h title)))
    (widget-set-draw;;draw event
     widget
     (lambda (widget parent);;draw
       (let ((x  (vector-ref  widget %x))
    	     (y  (vector-ref widget %y))
    	     (w  (vector-ref  widget %w))
    	     (h  (vector-ref  widget %h))
    	     (draw (vector-ref widget %draw)))
    	 ;;(draw-widget-rect widget)
    	 (vector-set! widget %gx x)
    	 (vector-set! widget %gy y)
	 
    	 (graphic-sissor-begin x y w h)
    	 (draw-dialog x y w h title)
	 
    	 (let loop ((child (vector-ref widget %child)))
    	   (if (pair? child)
    	       (begin
    		 ((vector-ref (car child) %draw) (car child)  widget)
    		 (loop (cdr child)))
    	       ))
	 (graphic-sissor-end)
    	 )))

    (widget-add-event
     widget
     (lambda (widget parent type data)
       (if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
	   (widget-active widget))))
    
    (widget-set-padding widget 10.0 10.0 40.0 40.0)

    (widget-add widget)
    widget
    ))

(define (widget-child-rect-event-scroll widget type data)
  (let loop ((child (vector-ref widget %child)))
    (if (pair? child)
	(begin
	  (if (is-in-widget widget (car child))
	      (begin
		((vector-ref (car child) %event) (car child)  widget type data )))
	  (loop (cdr child)))
	)))

(define (widget-draw-rect-child widget)
  (let loop ((child (vector-ref widget %child)))
    (if (pair? child)
	(begin
	  ;;(printf "draw button\n")
	  (if (is-in-widget widget (car child) )
	      (begin
		((vector-ref (car child) %draw) (car child)  widget)))
	  
	  (loop (cdr child)))
	)))

(define (widget-draw-child widget)
  (let loop ((child (vector-ref widget %child)))
    (if (pair? child)
	(begin
	  ;;(printf "draw button\n")
	  ((vector-ref (car child) %draw) (car child)  widget)
	  (loop (cdr child)))
	)))

(define (widget-copy widget)
  (vector-copy widget))

(define (widget-new x y w h text)
  (let ((offset (vector 0 0))
	(active 0)
	(resize-status 0)
	(resize-pos (vector 0 0))
	)
    (vector x y
	    w h
	    default-layout
	    (lambda (widget parent);;draw
	      (let ((x  (vector-ref  widget %x))
		    (y  (vector-ref widget %y))
		    (w  (vector-ref  widget %w))
		    (h  (vector-ref  widget %h))
		    (draw (vector-ref widget %draw)))
		;;(draw-widget-rect widget)
		(vector-set! widget %gx x)
		(vector-set! widget %gy y)

		;(graphic-sissor-begin x y w h)
		;;(draw-dialog x y w h text)
		;;(draw-text x y  (format "status =>~a" (vector-ref widget %status)))
		;;(widget-draw-child widget)
		;;(graphic-sissor-end)
		))
	    (lambda (widget parent type data);;event
	      (if (= type %event-mouse-button)
		  (let ((xx (vector-ref widget %x))
			(yy (vector-ref widget %y))
			(ww (vector-ref widget %w))
			(hh (vector-ref widget %h)))
		    ;;(printf "type ~a ~a\n" type data)
		    ;;(printf "dialog status ~a\n" (vector-ref widget %status))
		    (if (in-rect (+ xx ww -20.0) (+ yy hh -20.0)
				 (+ xx ww) (+ yy hh)
				 (vector-ref data 3)
				 (vector-ref data 4))
			(begin
			  (printf "==> ~a ~a\n" type data)
			  (set! resize-status (vector-ref data 1) )))
		    (if (and (= (vector-ref data 1) 0) (= resize-status 1)) ;;rlease mouse
			(set! resize-status 0))
		    
		    (set! active (vector-ref data 1))))
	      
	      (if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
		  (let ((mx (vector-ref data 3))
			(my (vector-ref data 4)))

		    (set! resize-pos (vector mx my))
		    (set! offset
			  (vector
			   (- (vector-ref widget %x) mx)
			   (- (vector-ref widget %y) my)))

		    ;;child event
		    (widget-child-rect-event-mouse-button widget type data)
	
		    ))
	      (if (= type %event-motion)
		  (begin
		    (if (= active %status-active)
			(let ()
			  ;;(printf "sel ~a ~a ==  ~a ~a \n" (vector-ref data 0) (vector-ref data 1)  xx yy)
			  (if (= 1 resize-status)
			      (let ((mx (vector-ref data 0))
				    (my (vector-ref data 1))
				    (w (vector-ref widget %w))
				    (h (vector-ref widget %h))
				    (x (vector-ref widget %x))
				    (y (vector-ref widget %y))
				    )
				;;(printf "resize mouse offset ~a ~a\n" (vector-ref offset 0) (vector-ref offset 1)  )
				(widget-resize widget
					       (+ w (- mx (vector-ref resize-pos 0)))
					       (+ h (- my (vector-ref resize-pos 1))))
				(set! resize-pos (vector mx my))
				)
			      (begin
				(vector-set! widget  %x  (+ (vector-ref data 0) (vector-ref offset 0)  ) )
				(vector-set! widget  %y  (+ (vector-ref data 1) (vector-ref offset 1)  ) )))
			  ))
		    )
		  )
	      (if (= type %event-scroll)
		  (begin
		    (widget-child-rect-event-scroll widget type data)
		    ))
	      
	      (if (and (or (= type %event-char) (= type %event-key)) (=  (vector-ref widget %status) %status-active) )
		  (begin
		    ;;(printf "\ndialog key event ~a ~a status=~a\n" type  data (vector-ref widget %status) )
		    (widget-child-key-event widget type data)
		    ;;(draw-widget-child-rect parent widget )
		    ))
	      )
	    (list )
	    0.0
	    0.0 ;;top
	    0.0 ;;bottom
	    0.0 ;;left
	    0.0 ;;right
	    
	    0.0 ;;top
	    0.0 ;;bottom
	    0.0 ;;left
	    0.0 ;;right
	    
	    '() ;;parent
	    0.0 ;;gx
	    0.0 ;;gy
	    text  ;;text
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    '()
	    
	    )
    ))


  
(define (widget-resize widget w h)
  (vector-set! widget %w w)
  (vector-set! widget %h h)
  ((vector-ref widget %layout) widget)
  )
  

(define (widget-at widget)
  (let loop ((w $widgets) (index 0) )
    (if (pair? w)
	(begin
	  (if (eqv? (car w) widget)
	      index
	      (loop (cdr w) (+ index 1))
		)))))

(define (widget-active widget)
    (set! $widgets (remove! widget $widgets ))
    (set! $widgets (append $widgets (list  widget))) )

(define (widget-get-attr widget index)
  (vector-ref widget index))

(define (widget-set-attr widget index value)
  (vector-set! widget index value))


(define (widget-get-child widget)
  (vector-ref widget %child))

(define (widget-set-draw widget event)
  (vector-set! widget %draw event))

(define (widget-get-draw widget)
  (vector-ref widget %draw))

(define (widget-set-event widget event)
  (vector-set! widget %event event))

(define (widget-get-event widget)
  (vector-ref widget %event))

(define (widget-add-event widget event)
  (let ((e (vector-ref widget %event)))
    (vector-set! widget %event
		 (lambda (w p t d)
		   (e w p t d)
		   (event w p t d)))))

(define (widget-add-draw widget event)
  (let ((draw (vector-ref widget %draw)))
    (vector-set! widget %draw
		 (lambda (widget parent)
		   (event widget  parent )
		   (draw widget parent)
		   (event widget  parent )
		   ))))

(define (widget-event type data )
  (if (= type %event-motion)
      (begin
	(set! cursor-x (vector-ref data 0))
	(set! cursor-y (vector-ref data 1))
	))
  (let loop ((len (- (length $widgets) 1) ))
    (if (>= len 0)
	(let ((w (list-ref $widgets  len)))
	  ;;(printf "~a  ~a\n" len (list-ref $widgets len))
	  (let ((event (vector-ref w %event)))
	    (event w '() type data)
	    )
	  (loop  (- len 1)))
	)))


(define (draw-widget-rect widget)
  (let ((x  (vector-ref  widget %gx))
	(y  (vector-ref widget %gy))
	(w  (vector-ref  widget 2))
	(h  (vector-ref  widget 3)))
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  128.0 30.0 34.0 0.5)
    ))

(define (draw-widget-child-rect widget child)
  (if (null? widget)
      (draw-widget-rect child)
      (let ((x  (vector-ref  widget %gx))
	    (y  (vector-ref widget %gy))
	    (w  (vector-ref  widget %w))
	    (h  (vector-ref  widget %h))
	    (cx  (vector-ref  child %gx))
	    (cy  (vector-ref  child %gy))
	    (cw  (vector-ref  child %w))
	    (ch  (vector-ref  child %h))
	    )
	
	;;(graphic-draw-solid-quad (+ x cx) (+ y cy) (+ x cx cw) (+ y cy  ch)  128.0 30.0 34.0 0.5)
	
	;;(printf "draw child rect\n")
	(graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch)  128.0 30.0 34.0 0.5)

	)))

(define widget-child-rect-event-mouse-button
  (case-lambda
   [(widget type data)
    (let ((mx (vector-ref data 3))
	  (my (vector-ref data 4)))
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      ;; (printf "~a ~a\n" (car child) (vector
	      ;; 			       (- mx (vector-ref widget 0))
	      ;; 			       (- my (vector-ref widget 1) )  ) )
	      
	      (if (is-in (car child) (vector
				      (- mx (vector-ref widget 0))
				      (- my (vector-ref widget 1) )  ))
		  (begin
		    ;;(printf "in here\n")
		    ((vector-ref (car child) %event) (car child) widget  type data)))
	      
	      (loop (cdr child)))
	    )))]
    [(widget type data fun)
    (let ((mx (vector-ref data 3))
	  (my (vector-ref data 4)))
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      (if (and (fun (car child)) (is-in (car child) (vector
				      (- mx (vector-ref widget 0))
				      (- my (vector-ref widget 1) )  )))
		  (begin
		    ;;(printf "in here\n")
		    ((vector-ref (car child) %event) (car child) widget  type data)))
	      
	      (loop (cdr child)))
	    )))]
  ))

(define (widget-mouse-button-event data )
    (let l ((w $widgets))
      (if (pair? w)
	  (begin
	    (vector-set! (car w) %status %status-default)
	    (l (cdr w)))
	    ))
    (let loop ((len (- (length $widgets) 1) ))
      (if (>= len 0)
	  (let ((w (list-ref $widgets  len)))
	    ;;(draw-widget-rect w)
	    (if (is-in w (vector (vector-ref data 3) (vector-ref data 4) ) )
		(begin
		  ;;(draw-widget-rect w)
		  (vector-set! w %status %status-active);;status
		  ((vector-ref w %event) w '() %event-mouse-button data))
		(loop  (- len 1)))
		)
	    
	    )
	  ))

    (define (widget-scroll-event data )
    (let loop ((len (- (length $widgets) 1) ))
      (if (>= len 0)
	  (let ((w (list-ref $widgets  len)))
	    (if (is-in w  (vector (vector-ref data 2) (vector-ref data 3) )  )
		(begin
		  ;;(printf "scroll event data=>~a\n"  data)
		  ;;(draw-widget-rect w)
		  ;;(vector-set! w %status (vector-ref data 1 ));;status
		  ((vector-ref w %event) w '() %event-scroll data))
		(loop  (- len 1)))
	    )
	  )))


(define (widget-render)
  ;;(printf "dialog=====>~a\n" $widgets)
  (let loop ((w $widgets))
    (if (pair? w)
	(begin
	  (let ((draw (vector-ref (car w) %draw)))	   
	    (draw (car w) '() ))
	  (loop (cdr w)
		))))
  ;;(graphic-draw-solid-quad cursor-x cursor-y (+ cursor-x 10.0) (+ cursor-y 10.0) 255.0 0.0 0.0 0.5)
  (if (> cursor-arrow 0)
      (draw-image cursor-x cursor-y 22.0 24.0 cursor-arrow))
  (graphic-render)
  )

(define (widget-set-cursor cursor)
  (set! cursor-arrow cursor))

(define (widget-show-cursor)
   (if (>= cursor-arrow 0)
       (set! cursor-arrow (load-texture "cursor.png"))))

(define (widget-disable-cursor)
  (set! cursor-arrow -1))

(define (widget-init w h)
  (set! window-width w)
  (set! window-height h)
  (graphic-init w h)
 
  
  )
  
(define (widget-layout)
  (let loop ((w $widgets))
    (if (pair? w)
	(begin
	  (let ((layout (vector-ref (car w) %layout)))
	    (layout (car w) ))
	  (loop (cdr w)
		)))))

  
  )
