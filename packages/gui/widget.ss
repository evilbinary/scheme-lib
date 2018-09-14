;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui widget)
  (export
   widget-init
   widget-window-resize
   widget-add
   widget-destroy
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
   widget-get-attrs
   widget-set-attrs
   widget-disable-cursor
   widget-set-cursor
   widget-new
   widget-copy
   widget-set-text-font-size
   widget-set-text-font-color
   widget-set-edit-font
   widget-get-events
   widget-set-events
   widget-get-root
   widget-layout-update
   widget-set-child
   widget-get-window-width
   widget-get-window-height
   widget-update-pos
   widget-child-update-pos
   widget-draw-child
   widget-draw-rect-child
   widget-child-rect-event
   is-in-widget-top
   widget-child-rect-event-mouse-button
   widget-child-key-event
   in-rect
   widget-set-child-attr
   widget-child-rect-event-scroll
   widget-active
   widget-event
   
   %status-active
   %event
   %event-char
   %event-scroll
   %child
   %status
   %gx
   %gy
   %w
   %h
   %x
   %y
   %text
   %parent
   %layout
   %top
   %left
   %right
   %bottom
   %margin-top
   %margin-left
   %margin-right
   %margin-bottom
   %draw
   %event-mouse-button
   %last-common-attr
   %event-key
   

   
   )
  (import (scheme) (gui graphic) (gui stb))
  
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
  (define %type 21)
  (define %attrs 22)
  (define %events 23)
  
  (define %last-common-attr 24)
 

    
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


  (define cursor-x 0)
  (define cursor-y 0)
  (define cursor-arrow 0)
  
  (define default-layout '() )


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
      ;;((vector-ref p %layout) p)
      w]
     [(p w layout)
      (vector-set! w %parent p)
      (vector-set! p %child (append! (vector-ref p %child) (list w)))
      ;;((vector-ref p %layout) p layout)
      w
      ]
     ))

  
  (define (is-in-widget-top widget mx my)    
    (let ((x1  (vector-ref  widget %gx))
	  (y1  (vector-ref widget %gy))
	  (w1  (vector-ref  widget %w))
	  ;;(h1  (vector-ref  widget %h))
	  (h1  (vector-ref  widget %top))
	  (parent (vector-ref widget %parent))
	  )

      ;;(graphic-draw-solid-quad x1 y1 (+ x1 w1 ) (+ y1 h1)  0.0 255.0 0.0 0.1)
      ;;(graphic-draw-solid-quad x2 y2 (+ x2 w2 ) (+ y2 h2)  0.0  0.0 255.0 0.5)
      
      (in-rect x1
	       y1
	       (+ w1)
	       (+ h1)
	       mx my )
      )
    )
  
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
	  (mx (vector-ref data 0))
	  (my (vector-ref data 1))
	  )
      (if (null? parent)
	  (in-rect x y w h  mx my)
	  (begin
	    (in-rect  x
		      y 
		      w
		      h
		      mx my)))))

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
	  (is-in-rect 0  0
		      w1  h1
		      x2 y2 w2 h2 )
	  (is-in-rect (+ x1 (vector-ref parent %left))
		      (+ y1 (vector-ref parent %top))
		      (- w1 (vector-ref parent %right))
		      (- h1 (vector-ref parent %bottom))
		      x2 y2 w2 h2 )
	  )
      ;;(printf "~a == ~a\n" (list x y w h) data)
      ))

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

  (define widget-set-edit-font
    (case-lambda
     [(widget name size)
      (let ((ed (widget-get-attrs widget '%edit))
	    (markup  (graphic-new-markup name size)))
	(gl-edit-set-markup ed markup 0)
	(gl-free-markup markup))
      ]
     [(widget size)
      (let ((ed (widget-get-attrs widget '%edit) )
	    (markup  (graphic-new-markup "Roboto-Regular.ttf" size)))
	(gl-edit-set-markup ed markup 0)
	(gl-free-markup markup))
      ]
     [(widget size r g b a)
      (let ((ed (widget-get-attrs widget '%edit) )
	    (markup  (graphic-new-markup "Roboto-Regular.ttf" size)))
	(gl-markup-set-foreground markup r g b a)
	(gl-edit-set-markup ed markup 0)
	;;(graphic-edit-add-text ed "hahah")
	(gl-free-markup markup)
	)
      ]
     [(widget name size r g b a)
      (let ((ed (widget-get-attrs widget '%edit) )
	    (markup  (graphic-new-markup name size)))
	(gl-markup-set-foreground markup r g b a)
	(gl-edit-set-markup ed markup 0)
	(gl-free-markup markup))
      ]

     ))

  (define (widget-child-rect-event-scroll widget type data)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (if (and (is-in-widget widget (car child));;在父亲矩形内
		     (is-in (car child) (vector (vector-ref data 2) (vector-ref data 3) )  );;鼠标在区域内
		     )
		(begin
		  ;;(printf "is in-widget ~a\n" data)
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

  (define (widget-update-pos ww)
    (let ((x  (vector-ref  ww %x))
	  (y  (vector-ref ww %y))
	  (w  (vector-ref  ww %w))
	  (h  (vector-ref  ww %h))
	  (parent (widget-get-attr ww %parent))
	  (draw (vector-ref ww %draw)))

      (if (null? parent)
	  (let ((gx (+ (vector-ref ww %x)))
		(gy (+ (vector-ref ww %y))))
	    (vector-set! ww %gx gx)
	    (vector-set! ww %gy gy)
	    )
	  (let ((gx  (+ (vector-ref parent %gx) (vector-ref ww %x)))
		(gy   (+ (vector-ref parent %gy) (vector-ref ww %y))))
	    (vector-set! ww %gx gx)
	    (vector-set! ww %gy gy)
	    ))
      )
    )

  (define (widget-child-update-pos widget)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (let ((ww (car child))
		(parent (widget-get-attr (car child) %parent)))
	    
	    (let ((x  (vector-ref  ww %x))
		  (y  (vector-ref ww %y))
		  (w  (vector-ref  ww %w))
		  (h  (vector-ref  ww %h))
		  (draw (vector-ref ww %draw)))

	      (if (null? parent)
		  (let ((gx (+ (vector-ref ww %x)))
			(gy (+ (vector-ref ww %y))))
		    (vector-set! ww %gx gx)
		    (vector-set! ww %gy gy)
		    )
		  (let ((gx  (+ (vector-ref parent %gx) (vector-ref ww %x)))
			(gy   (+ (vector-ref parent %gy) (vector-ref ww %y))))
		    (vector-set! ww %gx gx)
		    (vector-set! ww %gy gy)
		    ))
	      (widget-child-update-pos ww)
	      )
	    (loop (cdr child)))
	  )))

  (define (widget-copy widget)
    (vector-copy widget))



  (define (widget-get-attrs widget name)
    (let ((h (vector-ref widget %attrs )))
      (hashtable-ref h name '() )))

  (define (widget-set-attrs widget name value)
    (let ((h (vector-ref widget %attrs )))
      (hashtable-set! h name value)))



  (define (widget-get-events widget name)
    (let ((h (vector-ref widget  %events )))
      (hashtable-ref h name '() )))

  (define (widget-set-events widget name value)
    (let ((h (vector-ref widget %events )))
      (hashtable-set! h name value)))


  (define (widget-new x y w h text)
    (let ((offset (vector 0 0))
	  (active 0)
	  (resize-status 0)
	  (resize-pos (vector 0 0))
	  (nw '())
	  )
      (set! nw (vector x y
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
		       0   ;;status
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
		       '()  ;;
		       (make-hashtable equal-hash equal?)  ;;attrs
		       (make-hashtable equal-hash equal?)  ;events
		       '()
		       '()
		       '()
		       '()
		       '()
		       '()
		       '()
		       '()
		       '()
		       
		       
		       ))
      (widget-set-attrs nw '%w w) 
      (widget-set-attrs nw '%h h) 
      nw
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
    (vector-set! widget index value)
    (if (not (null? (widget-get-attrs widget (format "%event-~a" index))))
	((widget-get-attrs widget (format "%event-~a" index)) widget value))
    
    )

  (define (widget-set-child-attr widget index value)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (widget-set-attr (car child) index value)
	    ;;(printf "=====>set child ~a ~a\n" (widget-get-attr (car child) %text) (widget-get-attr (car child) %status))
	    (loop (cdr child)))
	  )))


  ;; (define (widget-set-child widget index value)
  ;;   (let loop ((child (vector-ref widget %child)))
  ;;     (if (pair? child)
  ;; 	  (begin
  ;; 	    (vector-set! (car child) index value)
  ;; 	    (loop (cdr child)))
  ;; 	  )))

  (define (widget-set-child widget value)
    (vector-set! widget %child value))

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
					(- mx (vector-ref widget %gx))
					(- my (vector-ref widget %gy) )  ))
		    (begin
		      ;;(draw-widget-rect (car child) 255.0 0.0 0.0 1.0)
		      ;;(printf "in here ~a\n" (widget-get-attr (car child) %text)  )
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
    ;;(if (> cursor-arrow 0)
    ;;   (draw-image cursor-x cursor-y 22.0 24.0 cursor-arrow))
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
  (define (widget-get-window-width)
    window-width)

  (define (widget-get-window-height)
    window-height)
  
  (define (widget-window-resize w h)
    (set! window-width w)
    (set! window-height h)
    (graphic-resize w h)
    (widget-layout)
    )

  (define (widget-get-root widget)
    (let loop ((p (widget-get-attr widget %parent))
	       (last '() ))
      (if (not (null? p))
	  (begin
	    (set! last p)
	    (loop (widget-get-attr p %parent) last ))
	  last
	  )))

  (define (widget-layout-update widget)
    ((widget-get-attr widget %layout) widget))



  (define (widget-layout)
    (let loop ((w $widgets))
      (if (pair? w)
	  (let ((layout (vector-ref (car w) %layout)))
	    (if (procedure? layout)
		(layout (car w) ))
	    (loop (cdr w))))))

  (define (widget-destroy)
    (graphic-destroy)
    )


  (define (widget-set-text-font-size widget size)
    ;;(graphic-set-text-font-size (vector-ref widget %text) size)
    '()
    )

  (define (widget-set-text-font-color widget r g b a)
    '()
    )


  
(define draw-widget-rect
  (case-lambda
   [(widget)
    (let ((x  (vector-ref  widget %gx))
	(y  (vector-ref widget %gy))
	(w  (vector-ref  widget 2))
	(h  (vector-ref  widget 3)))
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  128.0 30.0 34.0 0.5)
    )]
    [(widget r g b a)
    (let ((x  (vector-ref  widget %gx))
	(y  (vector-ref widget %gy))
	(w  (vector-ref  widget 2))
	(h  (vector-ref  widget 3)))
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  r g b a)
    )]))

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
  
  )
