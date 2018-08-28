;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui duck)
  (export
   dialog
   button
   image
   text
   scroll
   edit
   video
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

  ;;private
  (define %scroll-direction 20)
  (define %scroll-rate 21)
  (define %scroll-x 22)
  (define %scroll-y 23)
  (define %scroll-height 24)

  (define %status-active 1)
  (define %status-default 0)
  

  (define window-width 0)
  (define window-height 0)
  
  (define %event-scroll 4)
  (define %event-key 2)
  (define %event-mouse-button 3)
  (define %event-motion 1)
  
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
    (graphic-draw-text (- (+ x (/ w 2.0 ))
			  20.5)
		       (+ y 20) text)
    )

  (define (draw-image x y w h src)
    (graphic-draw-texture-quad
     x y
     (+ x w) (+ y h)
      0.0 0.0 1.0 1.0 src))

  (define (draw-text x y  text)
    (graphic-draw-text
     x y
      text))

  (define (draw-video v x y w h )
    (let l ((i 3))
      (if (> i 0)
	  (begin
	    (video-render v x y (+ x w) (+ y h) )
	    (l (- i 1))
	    ))))
  
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
  
  (define (widget-set-xy widget x y)
    (vector-set! widget %x x)
    (vector-set! widget %y y)
    )
  
  (define default-layout
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
	    ;; (printf "~a == ~a  ~a\n" (list x y w h) data (list (+ x (vector-ref parent %gx))
	    ;; 						       (+ y (vector-ref parent %gy)))  )
	    ;; (printf "in rect=>~a\n" (in-rect  x
	    ;; 	      y 
	    ;; 	      w
	    ;; 	      h
	    ;; 	      (vector-ref data 0) (vector-ref data 1)))
	    (in-rect  x
		      y 
		      w
		      h
		      (vector-ref data 0) (vector-ref data 1)))))
    )

  
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


  (define (widget-child-key-event widget type data)
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      ;;(printf "in here\n")
	      ((vector-ref (car child) %event) (car child) widget  type data)
	      (loop (cdr child)))
	    )))
  
  (define (widget-child-event widget type data)
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
    (vector 0.0 0.0 w h
	    (lambda (widget . args)
	      (default-layout widget)
	      (vector-set! widget %scroll-height
				   (calc-height widget))
	      )
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
		      (graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 255.0 0.0 0.0 0.5)
		      )
		    (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
			  (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		      (vector-set! widget %gx gx)
		      (vector-set! widget %gy gy)
		    
		      ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 0.0 255.0 0.0 0.5)
		      (graphic-sissor-begin gx gy  w  h )
		      ;;(printf "~a,~a  ~a ~a\n" gx gy w h)
		      ;;(graphic-draw-solid-quad 0.0 0.0 800.0 600.0 255.0 0.0 0.0 0.5)

		      (draw-scroll-bar (+ gx w -20.0 ) gy 20.0 h
				       (vector-ref widget %scroll-y)
				       (vector-ref widget %scroll-height)
				       )
		      ))
		
		;;(draw (vector-ref widget %draw))
		;;(draw-widget-rect widget)
		
		
		(let loop ((child (vector-ref widget %child)))
		  (if (pair? child)
		      (begin
			;;(printf "draw button\n")
			(if (is-in-widget widget (car child) )
			    (begin
			      ((vector-ref (car child) %draw) (car child)  widget)))
			
			(loop (cdr child)))
		      ))
		(graphic-sissor-end)
		))	    
	    (lambda (widget parent type data);;event
	      (if (null? parent)
		  (begin
		    (if (= type 3)
			(draw-widget-child-rect parent widget )))
		  )
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
		     
		      (widget-child-event widget type data)
		      ;;(printf "button click event ~a ~a ~a\n" type text data)
		      ;;(draw-widget-child-rect parent widget )
		      ))
		(if (= type %event-key)
		    (begin
		      ;;(printf "scroll key event ~a ~a\n" type data)
		      (widget-child-key-event widget type data)
		      ;;(draw-widget-child-rect parent widget )
		      ))
		
		)
	      )
	    (list);;child
	    0;;status
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

	    1
	    8.1
	    0.0 ;;scroll x
	    0.0 ;;scroll y
	    0.0 ;;scroll height
	    ))


  (define (edit w h text)
    (let ((ed (graphic-new-edit w h))
	  (markup  (graphic-new-markup "Roboto-Regular.ttf" 25.0))
	  )
      (graphic-edit-add-text ed text markup)
    (vector 0.0 0.0 w h
	    (lambda (x)
	      '())
	    (lambda (widget parent);;draw
	      
	      (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		    (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		(vector-set! widget %gx gx)
		(vector-set! widget %gy gy)
		(graphic-draw-edit ed gx gy)
		)
	     
	      ;;(printf "draw button end\n")
	      )
	    (lambda (widget parent type data);;event
	      (if (= type %event-key)
		  (begin
		    (printf "edit key event ~a\n" type)
		    (gl-edit-key-event ed
				       (vector-ref data 0)
				       (vector-ref data 1)
				       (vector-ref data 2)
				       (vector-ref data 3) )
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
	      )
	    (list);;child
	    0;;status
	    
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
	    
	    )))
    
  (define (text w h text)
    (vector 0.0 0.0 w h
	    (lambda (x)
	      '())
	    (lambda (widget parent);;draw
	      
	      (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		    (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		(vector-set! widget %gx gx)
		(vector-set! widget %gy gy)
		(draw-text gx
			   gy
			    text)
		)
	      ;;(printf "draw button end\n")
	      )
	    (lambda (widget parent type data);;event
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
	      )
	    (list);;child
	    0;;status
	    
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
	    
	    ))

(define (video w h src)
    (let ((vv (video-new src window-width window-height )))
    (vector 0.0 0.0 w h
	    (lambda (x)
	      '())
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
			))
	      ;;(printf "draw button end\n")
	      )
	    (lambda (widget parent type data);;event
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
	      )
	    (list);;child
	    0;;status

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
	    
	    )))
  
  (define (image w h src)
    (let ((id (load-texture src)))
    (vector 0.0 0.0 w h
	    (lambda (x)
	      '())
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
				    w h id)))
	      ;;(printf "draw button end\n")
	      )
	    (lambda (widget parent type data);;event
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
	      )
	    (list);;child
	    0;;status

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
	    
	    )))
  
  (define (button w h text)
    (vector 0.0 0.0 w h
	    (lambda (x)
	      '())
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
		)
	      )
	    (lambda (widget parent type data);;event
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
	      )
	    (list);;child
	    0;;status
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
	    ))

  (define (dialog x y w h title)
    (let ((offset vector)
	  (active 0)
	  )
      (widget-add
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
		   
		   (draw-dialog x y w h title)
		   ;;(draw-text x y  (format "status =>~a" (vector-ref widget %status)))
		   
		   ;;(printf "status ~a\n" (vector-ref widget %status))
		   ;;(printf "widget ~a %child=>~a\n" widget (vector-ref widget %child))
		   
		   (let loop ((child (vector-ref widget %child)))
		     (if (pair? child)
			 (begin
			   ;;(printf "draw button\n")
			   ((vector-ref (car child) %draw) (car child)  widget)
			   (loop (cdr child)))
			 ))
		   ))
	       (lambda (widget parent type data)
		 (if (= type %event-mouse-button)
		     (begin
		       ;;(printf "dialog status ~a\n" (vector-ref widget %status))
		       (set! active (vector-ref data 1))))
		 
		 (if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
		     (let ((mx (vector-ref data 3))
			   (my (vector-ref data 4)))
		       (set! offset
			     (vector
			      (- (vector-ref widget 0) mx)
			      (- (vector-ref widget 1) my)))

		       ;;child event
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
			     ))
		       ))
		 (if (= type %event-motion)
		     (begin
		       (if (= active %status-active)
			   (let ()
			     ;;(printf "sel ~a ~a ==  ~a ~a \n" (vector-ref data 0) (vector-ref data 1)  xx yy)
			     (vector-set! widget  %x  (+ (vector-ref data 0) (vector-ref offset 0)  ) )
			     (vector-set! widget  %y  (+ (vector-ref data 1) (vector-ref offset 1)  ) )
			     '()
			     ))
		       )
		     )
		 (if (= type %event-scroll)
		     (begin
		       (let loop ((child (vector-ref widget %child)))
			 (if (pair? child)
			     (begin
			       (if (is-in-widget widget (car child))
				   (begin
				     ((vector-ref (car child) %event) (car child)  widget type data )))
			       (loop (cdr child)))
			     ))	       
		       ))
		 
		 (if (and (= type %event-key) (=  (vector-ref widget %status) %status-active) )
		     (begin
		       ;;(printf "\ndialog key event ~a ~a status=~a\n" type  data (vector-ref widget %status) )
		       (widget-child-key-event widget type data)
		       ;;(draw-widget-child-rect parent widget )
		       ))
		 )
	       (list )
	       0.0
	       40.0 ;;top
	       40.0 ;;bottom
	       10.0 ;;left
	       10.0 ;;right
	       
	       0.0 ;;top
	       0.0 ;;bottom
	       0.0 ;;left
	       0.0 ;;right
	       
	       '() ;;parent
	       0.0 ;;gx
	       0.0 ;;gy
	       )
       )))

  (define (widget-active widget)
    '())
 
  (define (widget-event type data )
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
	  '()
	  ;;(graphic-draw-solid-quad (+ x cx) (+ y cy) (+ x cx cw) (+ y cy  ch)  128.0 30.0 34.0 0.5)
	  (graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch)  128.0 30.0 34.0 0.5)
	  )))
  
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
		  )))))

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
