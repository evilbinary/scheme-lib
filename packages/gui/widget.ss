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
   widget-disable-custom-cursor
   widget-set-custom-cursor
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
   is-in-child-widget
   widget-child-rect-event-mouse-button
   widget-child-rect-event-mouse-motion
   widget-child-rect-key-event
   widget-child-key-event
   widget-layout-event
   widget-get-parent-cond
   widget-rect-fun
   in-rect
   is-in
   widget-set-child-attr
   widget-set-child-attrs
   widget-child-rect-event-scroll
   widget-active
   widget-event
   widget-attrs
   plus-child-y-offset
   is-in-widget
   widget-is-in-widget
   widget-init-cursor
   widget-set-cursor
   widget-remove
   %status-active
   %status-default
   %event
   %event-char
   %event-scroll
   %event-layout
   %child
   %status
   %visible
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
   %event-motion
   %event-motion-out
   
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
  (define %visible 24)
  
  (define %last-common-attr 25)
 

    
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
  (define %event-layout 7)
  (define %event-motion-out 8)	 

  (define cursor-x 0)
  (define cursor-y 0)
  (define cursor-arrow 0)
  
  (define default-layout '() )
  (define default-cursor '() )

 ;;widget x y w h layout draw event childs status top bottom left righ 
  (define $widgets (list ))

  (define (widget-init-cursor cursor)
	(set! default-cursor cursor))

  (define (widget-set-cursor mod)
	(if (procedure? default-cursor)
		(default-cursor mod)))


  (define (plus-child-y-offset widget offsety)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (vector-set! (car child)
			 %y
			 (- (vector-ref (car child) %y)
			    offsety))
	    (loop (cdr child)))
	  )))
  
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
  

  (define widget-add
    (case-lambda
     [(p)
      (set! $widgets (append! $widgets (list p)))
	  ((vector-ref p %layout) p)
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

  
  (define (is-in-widget widget lmx lmy)    
    (let ((x1  (vector-ref  widget %x))
	  (y1  (vector-ref widget %y))
	  (w1  (vector-ref  widget %w))
	  (h1  (vector-ref  widget %h))
	  (parent (vector-ref widget %parent))
	  )

      ;;(graphic-draw-solid-quad x1 y1 (+ x1 w1 ) (+ y1 h1)  255.0 0.0 0.0 0.4)
      ;;(graphic-draw-solid-quad lmx lmy (+ lmx 10.0 ) (+ lmy 10.0)  0.0  0.0 255.0 0.5)
      
      (in-rect x1
	       y1
	       (+ w1)
	       (+ h1)
	       lmx lmy )
      )
    )
   
  (define (is-in-widget-top widget lmx lmy)    
    (let ((x1  (vector-ref  widget %x))
	  (y1  (vector-ref widget %y))
	  (w1  (vector-ref  widget %w))
	  ;;(h1  (vector-ref  widget %h))
	  (h1  (vector-ref  widget %top))
	  (parent (vector-ref widget %parent))
	  )
      ;;(printf "text ~a\n" (widget-get-attr widget %text))
      ;;(graphic-draw-solid-quad x1 y1 (+ x1 w1 ) (+ y1 h1)  0.0 255.0 0.0 0.1)
      ;;(graphic-draw-solid-quad lmx lmy (+ lmx 5.0 ) (+ lmy 5.0)  0.0  0.0 255.0 0.8)
      ;;(printf " ~a,~a ~a ~a  ~a,~a \n" x1 y1 w1 h1 lmx lmy)
      (in-rect x1
	       y1
	       (+ w1)
	       (+ h1)
	       lmx lmy )
      )
    )
  
  (define (in-rect x y w h mx my)
    (and (> mx x) (< mx (+ x w)) (> my y) (< my (+ y h))))

  (define (is-in-rect x1 y1 w1 h1 x2 y2 w2 h2)
    (not (or (> x1 (+ x2 w2)) (< (+ x1 w1) x2) (< (+ y1 h1) y2) (> y1 (+ y2 h2)))))

  (define (is-in widget data)
    (let ((x  (vector-ref  widget %x))
	  (y  (vector-ref widget %y))
	  (w  (vector-ref  widget %w))
	  (h  (vector-ref  widget %h))
	  (parent (vector-ref widget %parent))
	  (lmx (vector-ref data 0))
	  (lmy (vector-ref data 1))
	  )
      ;;(printf " ~a,~a  ~a,~a\n" x y lmx lmy)
      (if (null? parent)
	  (in-rect x y w h  lmx lmy)
	  (begin
	    (in-rect  x
		      y 
		      w
		      h
		      lmx lmy)))))

  (define (widget-is-in-widget widget widget2)
    (let ((x1  (vector-ref  widget %x))
	  (y1  (vector-ref widget %y))
	  (w1  (vector-ref  widget %w))
	  (h1  (vector-ref  widget %h))
	  (x2  (vector-ref  widget2 %x))
	  (y2  (vector-ref widget2 %y))
	  (w2  (vector-ref  widget2 %w))
	  (h2  (vector-ref  widget2 %h))

	  (gx2  (vector-ref  widget2 %gx))
	  (gy2  (vector-ref widget2 %gy))
	  (parent (vector-ref widget2 %parent))
	  )

      ;;(graphic-draw-solid-quad x1 y1 (+ x1 w1 ) (+ y1 h1)  0.0 255.0 0.0 0.2)
      ;;(graphic-draw-solid-quad gx2 gy2 (+ gx2 w2 ) (+ gy2 h2)  0.0  0.0 255.0 0.8)
      
      (if (null? parent)
	  (is-in-rect 0  0
		      w1  h1
		      x2 y2 w2 h2 )
	  (begin
	    (is-in-rect
	     (+ x1 (vector-ref widget %left))
	     (+ y1 (vector-ref widget %top))
	     (- w1 (vector-ref widget %right) (vector-ref widget %left))
	     (- h1 (vector-ref widget %bottom) (vector-ref widget %top))
	     (+ x2 (vector-ref parent %x))
	     (+ y2  (vector-ref parent %y))
	     w2 h2 )
	  ))
      ;;(printf "~a == ~a\n" (list x y w h) data)
      ))

  (define (widget-child-key-event widget type data)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    ;;(printf "in here ~a\n" (widget-get-attr (car child) %text))
	    ((vector-ref (car child) %event) (car child) widget  type data)
	    (loop (cdr child)))
	  )))

	(define (widget-child-rect-key-event widget type data)
		'()
	)
  
  (define (widget-child-rect-event widget type data)
    (let* ((lmx (vector-ref data 3))
	  (lmy (vector-ref data 4))
	   (data2 (vector
		   (vector-ref data 0)
		   (vector-ref data 1)
		   (vector-ref data 2)
		   (- lmx (vector-ref widget %gx))
		   (- lmy (vector-ref widget %gy) )
		   lmx lmy))
	  )
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
	      (if (is-in-widget (car child)
				(- lmx (vector-ref widget %gx))
				(- lmy (vector-ref widget %gy) ))
		  (begin
		    ;;(printf "in here\n")
		    ((vector-ref (car child) %event) (car child) widget  type data2)))

	      (loop (cdr child)))
	    ))))

  (define widget-set-edit-font
    (case-lambda
     [(widget name size)
      (let ((ed (widget-get-attrs widget '%edit)))
			(gl-edit-set-font-name ed name)
			(gl-edit-set-font-size ed size))
      ]
     [(widget size)
      (let ((ed (widget-get-attrs widget '%edit) ))
				(gl-edit-set-font-size ed size))
      ]
     [(widget name size color)
      (let ((ed (widget-get-attrs widget '%edit) ))
				(gl-edit-set-font-name ed name)
				(gl-edit-set-foreground ed color)
				(gl-edit-set-font-size ed size))
      ]
     ))

  (define (widget-child-rect-event-scroll widget type data)
    (let* ((mx (vector-ref data 2))
	   (my (vector-ref data 3))
	   (lmx (- mx (vector-ref widget %gx)))
	   (lmy (- my (vector-ref widget %gy) ))
	   (data2 (vector
		   (vector-ref data 0)
		   (vector-ref data 1)
		   (vector-ref data 2)
		   lmx lmy
		   mx my)))
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      (if (and (widget-is-in-widget widget (car child));;在父亲矩形内
		       (is-in-widget(car child) lmx  lmy  );;鼠标在区域内
		       )
		  (begin
		    ;;(printf "is in-widget ~a\n" data)
		    ((vector-ref (car child) %event) (car child)  widget type data2 )))
	      (loop (cdr child)))
	    ))))

  (define (widget-draw-rect-child widget)
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    ;;(printf "draw button\n")
	    (if (widget-is-in-widget widget (car child) )
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

  (define (widget-attrs widget)
    (vector-ref widget %attrs))

  (define (widget-set-attrs widget name value)
    (let ((h (vector-ref widget %attrs )))
      (hashtable-set! h name value)
      (let ((hook (hashtable-ref h (format "%event-~a-hook" name) '())))
	(if (procedure? hook)
	    (hook widget name value)))
      ))

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
		       default-layout ;;layout
		       (lambda (widget parent);;draw
			 (let ((x  (vector-ref  widget %x))
			       (y  (vector-ref widget %y))
			       (w  (vector-ref  widget %w))
			       (h  (vector-ref  widget %h))
			       (draw (vector-ref widget %draw)))
			   ;;(draw-widget-rect widget)
			   (vector-set! widget %gx x)
			   (vector-set! widget %gy y)

			   ;;(graphic-sissor-begin x y w h)
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
			       ;;(printf "widget status ~a\n" (vector-ref widget %status))
			       (if (in-rect (+ xx ww -20.0) (+ yy hh -20.0);;resize area
					    (+ xx ww) (+ yy hh)
					    (vector-ref data 3)
					    (vector-ref data 4))
				   (begin
				     ;;(printf "==> ~a ~a\n" type data)
				     (set! resize-status (vector-ref data 1) )))
			       (if (and (= (vector-ref data 1) 0) (= resize-status 1)) ;;rlease mouse
				   (set! resize-status 0))

		        
			       (set! active (vector-ref data 1))
			       (widget-set-attrs widget '%drag 1)
				   
			       
			       ))
			 
			 (if (and  (= type %event-mouse-button) (= (vector-ref data 1) 1) ) ;;click down
			     (let ((mx (vector-ref data 3))
				   (my (vector-ref data 4)))
			       ;;(printf "haha\n")
			       (set! resize-pos (vector mx my))
			       (set! offset
				     (vector
				      (- (vector-ref widget %x) mx)
				      (- (vector-ref widget %y) my)))

			       ;;child event
			       (widget-child-rect-event-mouse-button widget type data)

			       ;;process child event after unvisible
			       (if (not  (widget-get-attr widget %visible))
				   (begin
				     (widget-set-attrs widget '%drag 0)
				     ))
			       
			       ))
			 (if (= type %event-motion)
			     (begin
			       (if (and (= active %status-active) (= (widget-get-attrs widget '%drag) 1) );;dragging
				   (let ()
				     ;;(printf "drag ~a\n" (widget-get-attrs widget '%drag))
				     ;;(printf " ~a ~a == \n" (vector-ref data 0) (vector-ref data 1) )
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
			       ;;mouse motion btn
			       ;;(widget-child-rect-event-mouse-motion widget type data)
			       
			       )
			     )
			 (if (= type %event-scroll)
			     (begin
			       ;;(printf "event scroll\n")
			       (widget-child-rect-event-scroll widget type data)
			       ))
			 (if (= type %event-layout)
			     (begin
			       ;;(printf "event layout\n")
			       (widget-child-rect-event-layout widget type data)
			       ))
			 (if (and (or (= type %event-char) (= type %event-key)) ;;key press
				  (=  (vector-ref widget %status) %status-active) ) ;;widget is active
			     (begin
			       ;;(printf "\nwidget key event ~a ~a status=~a\n" type  data (vector-ref widget %status) )
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
		       #t ;;visible
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

  (define (widget-remove-child parent child)
	(let ((childs (vector->list (widget-get-attr parent %child))))
		;;(printf "before childs=>~a" childs)
		(set! childs (remove! child childs))
		;;(printf "childs=>~a" childs)
		(widget-set-attr parent %child (list->vector childs)))
  )

  (define (widget-print widget)
    (let loop ((w $widgets) (index 0) )
      (if (pair? w)
	  (begin
	    (printf "widgets[~a]=>~a " index (widget-get-attr (car w) %text) )
		(loop (cdr w) (+ index 1))
		))
		)
		(printf "\n")
		)

  (define (widget-remove w)
	(let ((parent (widget-get-attr w %parent)))
		(if (null? parent )
			(begin
				(widget-print $widgets)
				;;(set-top-level-value! '$widgets  (remove! w $widgets ))
				(set! $widgets (remove! w $widgets ))
				(widget-print $widgets)
				)
			(widget-remove-child parent w))
		))

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

  (define (widget-set-child-attrs widget index value)
  	;;(printf "widget-set-child-attrs ~a\n" (vector-ref widget %child) )
    (let loop ((child (vector-ref widget %child)))
      (if (pair? child)
	  (begin
	    (widget-set-attrs (car child) index value)
	    ;;(printf "=====>set child ~a ~a\n" (widget-get-attr (car child) %text) (widget-get-attrs (car child) index))
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
		     ;;(event widget  parent )
		     (draw widget parent)
		     (event widget  parent )
		     ))))
  
  ;;mouse motion key char
  (define (widget-event type data )
    (if (= type %event-motion)
	(begin
	  (set! cursor-x (vector-ref data 0))
	  (set! cursor-y (vector-ref data 1))
	  (widget-set-cursor 'arrow)
	  ))
    ;;process virtual rect
    (let l ((w $widgets))
      (if (pair? w)
	  (begin
	    ;;(widget-set-attr (car w) %status %status-default)
	    (let ((fun (widget-get-attrs  (car w) '%event-rect-function)))
	      (if (procedure? fun)
			(if (fun (car w)  cursor-x cursor-y)
				(let ((event (vector-ref  (car w) %event)))
					(event  (car w) '() type data)
					)
				(let ((event (vector-ref  (car w) %event)))
					(event  (car w) '() %event-motion-out data)
					)
					)))
	    (l (cdr w)))
	  ))
    (let loop ((len (- (length $widgets) 1) ))
      (if (>= len 0)
	  (let ((w (list-ref $widgets  len)))
	    ;;(printf "~a  ~a\n" len (list-ref $widgets len))
	    (if (and (widget-get-attr w %visible)
		     (or (equal? %status-active  (widget-get-attrs w '%drag))
			 (is-in-widget w cursor-x cursor-y )))
		(let ((event (vector-ref w %event)))
		  (event w '() type data)
		  )
		(loop  (- len 1))))
	  )))

  (define (widget-mouse-button-event data )
    (let l ((w $widgets))
      (if (pair? w)
	  (begin
	    (vector-set! (car w) %status %status-default)
	    
	    (let ((fun (widget-get-attrs (car w) '%event-rect-function)))
	      (if (procedure? fun)
		  (if  (and (widget-get-attr (car w) %visible) (fun (car w)  (vector-ref data 3) (vector-ref data 4) ))
		      ((vector-ref (car w) %event) (car w) '() %event-mouse-button data))))
	    
	    (l (cdr w)))
	  ))
    (let loop ((len (- (length $widgets) 1) ))
      (if (>= len 0)
	  (let ((w (list-ref $widgets  len)))
	    ;;(draw-widget-rect w)
	    (if (and (widget-get-attr w %visible) (is-in-widget w  (vector-ref data 3) (vector-ref data 4) ))
		(begin
		  ;;(draw-widget-rect w)
		  (vector-set! w %status %status-active);;status
		  ;;(printf "=get visible=>~a status=~a ~a\n" (widget-get-attr w %visible) (widget-get-attr w %status)   (widget-get-attr  w %text))
		  ((vector-ref w %event) w '() %event-mouse-button data))
		(loop  (- len 1)))
	    )
	  
	  )
      ))

  (define (widget-scroll-event data )
    (let loop ((len (- (length $widgets) 1) ))
      (if (>= len 0)
	  (let ((w (list-ref $widgets  len)))
	    (if (and (widget-get-attr  w %visible)
		     (is-in-widget w  (vector-ref data 2) (vector-ref data 3) ))
		(begin
		  ;;(printf "scroll event data=>~a\n"  data)
		  ;;(draw-widget-rect w)
		  ;;(vector-set! w %status (vector-ref data 1 ));;status
		  ((vector-ref w %event) w '() %event-scroll data))
		(loop  (- len 1)))
	    )
	  )))

  ;;鼠标区域事件位置处理函数
  (define (widget-rect-fun widget lmx lmy)
    (let ((fun (widget-get-attrs widget '%event-rect-function)))
      (if (procedure? fun)
	  (begin
	    (fun widget lmx lmy))
	  (begin
	    (is-in-widget widget 
			   lmx
			   lmy ) ))
      ))

  (define (is-in-child-widget widget mx my)
    (let ((count 0)
	  (lmx (- mx (vector-ref widget %x)))
	  (lmy (- my (vector-ref widget %y) ))
	  )
      (let loop ((child (vector-ref widget %child)))
	(if (pair? child)
	    (begin
	      (if (is-in-widget (car child) lmx lmy)
		  (begin
		    (set! count (+ count 1))
		    )
		  (loop (cdr child)))
	      )))
      (if (> count 0)
	  #t
	  #f)
      ))
    
  (define (widget-to-local-mouse widget data)
    (vector-set! data 0 (- (vector-ref data 0)   (vector-ref widget %gx) ))
    (vector-set! data 1 (- (vector-ref data 1)   (vector-ref widget %gy) ))
    )
  
  (define widget-child-rect-event-mouse-motion
    (case-lambda
     [(widget type data)
      (let* ((mx (vector-ref data 0))
	     (my (vector-ref data 1))
	     (lmx (- mx (vector-ref widget %x)))
	     (lmy (- my (vector-ref widget %y) ))
	    (data2
	     (vector 
	      lmx
	      lmy
	      mx my))
	    )
	(let loop ((child (vector-ref widget %child)))
	  (if (pair? child)
	      (begin
			(if (widget-rect-fun (car child) lmx lmy)
				(begin
				;;(draw-widget-rect (car child) 255.0 0.0 0.0 1.0)
				;;(printf "in here ~a\n" (widget-get-attr (car child) %text))
				;;(widget-to-local-mouse widget data)
				((vector-ref (car child) %event)
				(car child)
				widget
				type
				data2
				)))
		
		(loop (cdr child)))
	      )))]
     [(widget type data fun)
      (let* ((mx (vector-ref data 0))
	     (my (vector-ref data 1))
	     (lmx  (- mx (vector-ref widget %x)))
	     (lmy  (- my (vector-ref widget %y) ))
	     (data2
	      (vector 
	       lmx
	       lmy
	       mx my))
	    )
	(let loop ((child (vector-ref widget %child)))
	  (if (pair? child)
	      (begin
		(if (fun (car child) lmx lmy )
		    (begin
		      
		      ((vector-ref (car child) %event) (car child) widget  type
		       data2
		       )))
		
		(loop (cdr child)))
	      )))]))
  
  (define widget-child-rect-event-mouse-button
    (case-lambda
     [(widget type data)
      (let* ((mx (vector-ref data 3))
	     (my (vector-ref data 4))
	     (lmx (- mx (vector-ref widget %x)  ));;(vector-ref widget %left)
	     (lmy (- my (vector-ref widget %y)  )) ;;  (vector-ref widget %top)
	    (data2 (vector
			(vector-ref data 0)
			(vector-ref data 1)
			(vector-ref data 2)
			lmx
			lmy
			mx my))
	    )
	
	(let loop ((child (vector-ref widget %child)))
	  (if (pair? child)
	      (begin
		;;(printf "data->~a\n" data)
		;; (printf "~a ~a\n" (car child) (vector
		;; 			       (- mx (vector-ref widget 0))
		;; 			       (- my (vector-ref widget 1) )  ) )
		(if (widget-rect-fun (car child) lmx lmy)
		    (begin      
		      ;;(printf "in here ~a\n" (widget-get-attr (car child) %text)  )
		      ((vector-ref (car child) %event) (car child) widget  type  data2 )))
		(loop (cdr child)))
	      )))]
     [(widget type data fun)
      (let* ((mx (vector-ref data 3))
	     (my (vector-ref data 4))
	     (lmx (- mx (vector-ref widget %x)))
	     (lmy (- my (vector-ref widget %y) ))
	     (data2 (vector
			(vector-ref data 0)
			(vector-ref data 1)
			(vector-ref data 2)
			lmx
			lmy
			mx my))
	     )
	(let loop ((child (vector-ref widget %child)))
	  (if (pair? child)
	      (begin
		(if (fun (car child)
			 lmx
			 lmy )       
		    (begin
		      ;;(printf "in here\n")
		      ((vector-ref (car child) %event) (car child) widget  type
		       data2 )))
		
		(loop (cdr child)))
	      )))]
     ))

  (define (widget-render)
    (let loop ((w $widgets))
      (if (pair? w)
	  (begin
	    ;;(printf "~a ~a\n" (widget-get-attr (car w) %text) (widget-get-attr (car w) %visible))
	    (if (widget-get-attr (car w) %visible)
		(let ((draw (vector-ref (car w) %draw)))
		  (draw (car w) '() )))
	    (loop (cdr w))
	    )))
    ;;(graphic-draw-solid-quad cursor-x cursor-y (+ cursor-x 10.0) (+ cursor-y 10.0) 255.0 0.0 0.0 0.5)
    ;;(if (> cursor-arrow 0)
    ;;   (draw-image cursor-x cursor-y 22.0 24.0 cursor-arrow))
    (graphic-render)
    )

  (define (widget-set-custom-cursor cursor)
    (set! cursor-arrow cursor))

  (define (widget-show-custom-cursor)
    (if (>= cursor-arrow 0)
	(set! cursor-arrow (load-texture "cursor.png"))))

  (define (widget-disable-custom-cursor)
    (set! cursor-arrow -1))

  (define widget-init
    (case-lambda
     [(w h)
      (set! window-width w)
      (set! window-height h)
      (graphic-init w h)]
     [(w h ratio)
      (set! window-width w)
      (set! window-height h)
      (graphic-set-ratio ratio)
      (graphic-init w h)]
     ))
  
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

  (define (widget-get-parent-cond widget fun)
    (let loop ((p (widget-get-attr widget %parent))
	       (last widget ))
      (if (not (null? p))
	  (begin
	    (if (equal? #t (fun p))
		(begin
		  ;;(printf " here ~a ~a\n"  (widget-get-attr p %text) (widget-get-attrs p 'is-root) )
		  (set! last p)))
	    (loop (widget-get-attr p %parent) last ))
	  last
	  )))

	(define (widget-layout-event widget)
		((vector-ref widget %event) widget '() %event-layout 'end ))

  (define (widget-child-rect-event-layout widget type data)
   (let loop ((child (vector-ref widget %child)))
		(if (pair? child)
	    (begin
	      (if (and (widget-is-in-widget widget (car child));;在父亲矩形内
		       )
		  	(begin
		    ;;(printf "is in-widget laoyt ~a\n" data)
		    ((vector-ref (car child) %event) (car child)  widget type data )))
	      (loop (cdr child)))
	    )))
			
  (define (widget-layout-update widget)
    (if (not (null? widget))
	(let ((layout (widget-get-attr widget %layout)))
	  (if (procedure? layout)
				(begin 
	      	(layout widget)
					(widget-layout-event widget)
					 ))))
    )

  (define (widget-layout)
    (let loop ((w $widgets))
      (if (pair? w)
	  (let ((layout (vector-ref (car w) %layout)))
	    (if (procedure? layout)
				(begin 
					(layout (car w) )
					(widget-layout-event (car w))
					))
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
	(h  (vector-ref  widget 3))
	(background (widget-get-attrs  widget 'background ))
	)
      (if (equal? '() background)
	  (graphic-draw-solid-quad x y (+ x w) (+ y  h)  128.0 30.0 34.0 0.5)
	  (graphic-draw-solid-quad x y (+ x w) (+ y  h)  background))
    )]
    [(widget r g b a)
    (let ((x  (vector-ref  widget %gx))
	(y  (vector-ref widget %gy))
	(w  (vector-ref  widget 2))
	(h  (vector-ref  widget 3))
	(background (widget-get-attrs  widget 'background )))
      (if (equal? '() background)
	  (graphic-draw-solid-quad x y (+ x w) (+ y  h)  r g b a)
	  (graphic-draw-solid-quad x y (+ x w) (+ y  h)  background))
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
	    (background (widget-get-attrs  widget 'background ))
	    )
	
	;;(graphic-draw-solid-quad (+ x cx) (+ y cy) (+ x cx cw) (+ y cy  ch)  128.0 30.0 34.0 0.5)
	
	;;(printf "draw child rect\n")
	(if (equal? '() background)
	    (graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch)  128.0 30.0 34.0 0.5)
	    (graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch) background)
	    )
	)))
  
  )
