;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui duck)
  (export
   draw-image
   draw-dialog
   draw-text
   dialog
   button
   image
   text
   scroll
   edit
   video
   tab
   tree
   view
   pop
   
   )
  (import (scheme)
	  (utils libutil)
	  (gui graphic )
	  (gui video)
	  (gui widget)
	  (gui layout)
	  (gui syntax)
	  (cffi cffi)
	  (gui stb))


  ;;private
  (define %scroll-direction (+ %last-common-attr 0))
  (define %scroll-rate (+ %last-common-attr 1))
  (define %scroll-x (+ %last-common-attr 2))
  (define %scroll-y (+ %last-common-attr 3))
  (define %scroll-height (+ %last-common-attr 4))


  
  (define (draw-dialog  x y w h title)
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
    (graphic-draw-text (+ x 30) (+ y 0) title)
    )

  (define draw-panel
    (case-lambda
     [(x y w h text)
      (graphic-draw-solid-quad  x y
			      (+ x w) (+ y h)
			      81.0 81.0 90.0 1.0)
     (if (not (null? text))
	 (graphic-draw-text (+ x 30) (+ y 0) text))]
     [(x y w h text color)

      ;;(printf "color ~x\n" (bitwise-bit-field color 24 32))
      (graphic-draw-solid-quad  x y
				(+ x w) (+ y h)
				(fixnum->flonum  (bitwise-bit-field color 16 24))
				(fixnum->flonum  (bitwise-bit-field color 8 16))
				(fixnum->flonum  (bitwise-bit-field color 0 8))
				(/ (fixnum->flonum  (if (= 0 (bitwise-bit-field color 24 32))
						        255
							(bitwise-bit-field color 24 32)
							)) 255.0)
				)
      (if (not (null? text))
	  (graphic-draw-text (+ x 30) (+ y 0) text))]
     ))
 

  (define (draw-button x y w h text)
    (graphic-draw-solid-quad  x y
			      (+ x w) (+ y h)
			      31.0 31.0 31.0 0.9)
    (graphic-draw-text (+ x (/ w 2.0 ) -8)
		       (+ y (/ h 2.0) -12 )
		       text)
    )

  (define (draw-image x y w h src)
    (graphic-draw-texture-quad
     x y
     (+ x w) (+ y h)
     0.0 0.0 1.0 1.0 src))

  (define draw-text
     (case-lambda
      [(x y text)
      (graphic-draw-text x y text )]
      [(x y text color)
       (graphic-draw-text x y text color)
       ])
    )

  (define (draw-rect x y w h)
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  128.0 30.0 34.0 0.5))


  (define (draw-item x y w h text)
    (graphic-draw-solid-quad x y (+ x w) (+ y  h)  61.0 61.0 61.0 0.9 )
    (graphic-draw-text (+ x (/ w 2.0 ) -8)
		       (+ y (/ h 2.0) -12 )
		       text)
    )
  
  
  (define (draw-video v x y w h )
    (video-render v x y (+ x w) (+ y h) )
    )
  
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

  (define (pop  w h text)
    (let ((widget (widget-new 0.0 0.0 w h text)))
      ;;(vector-set! widget %type type)
      (widget-set-padding widget 20.0 0.0 20.0 0.0)
      (widget-set-layout
       widget
       (lambda (widget . args)
	 (pop-layout widget)
	 ))
      (widget-set-attrs widget
       '%event-rect-function
       (lambda (ww mx my)
	 (let loop ((c (widget-get-child ww)))
	   (if (pair? c)
	       (begin
		 ;; (printf "->>> ~a,~a===~a,~a\n" mx my
		 ;; 	 (widget-get-attr (car c ) %x)
		 ;; 	 (widget-get-attr (car c ) %y)
		 ;; 	 )
		 (if (is-in (car c) (vector
				     mx
				     my ))
		     (begin
		       ;;(printf "true  ~a\n" (widget-get-attr (car c) %text ))
		       ;;(draw-widget-rect (car c) 255.0 0.0 0.0 1.0)
		       #t)
		     (loop (cdr c))
		     ))))
	 
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
		 
		 ;;(graphic-sissor-begin gx gy w h)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 255.0 0.0 0.0 0.5)
		 (draw-item gx gy w h text)
		 )
	       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)
		 ;;(printf "~a,~a\n" (vector-ref widget %x) (vector-ref widget %y))
		 ;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
		 
		 ;;(graphic-sissor-begin gx gy  w  h )

		 ;;(if (eqv? 'tree-item (vector-ref widget %type))
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -1.0) 0.0 255.0 0.0 0.3)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -10.0) (random 255.0)  0.0  0.0 0.5)
		 ;;   )
		 (draw-item gx gy w h text)
		 ;;hover
		 (if  (= (widget-get-attr widget %status) %status-active)
		     (draw-rect gx
				gy
				(widget-get-attr widget %w)
				(widget-get-attr widget %h)
				))
		 
		 ))
	   
	   (if (equal? #t (widget-get-attrs widget 'static))
	       (widget-set-attr widget %status 1))
	   
	   (if  (= (widget-get-attr widget %status) 1)
	       (widget-draw-child widget)
	       )
	   
	   ;;(graphic-sissor-end)
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
	   (if (= type %event-motion)
	       (begin
		 ;;(printf "motion ~a\n" (widget-get-attr widget %text))
		 (if (is-in widget data)
		     (begin
		       ;;(printf "motion ~a\n" (widget-get-attr widget %text))
		       (if (= 0 (widget-get-attr widget %status) )
			   (begin 
			     (if (not (null? (widget-get-attr widget %parent)))
				 (begin
				   (widget-set-child-attr (widget-get-attr widget %parent) %status 0)
				   ))
			     (widget-set-attr widget %status 1)
			     )))
		     (begin
		       (if (= 0 (widget-get-attr widget %status))
			   (widget-set-child-attr  widget  %status 0)
			   )))
		 (widget-child-rect-event-mouse-motion widget type data) ))
	   (if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
	       (begin
		 ;;(printf "pop click event ~a\n"  text)
		 ;;click widget
		 (if (is-in-widget widget (vector-ref data 3) (vector-ref data 4))
		     (let ()
		      
		       (if (= 0 (widget-get-attr widget %status) )
			   (begin 
			     (if (not (null? (widget-get-attr widget %parent)))
				 (begin
				   (widget-set-child-attr (widget-get-attr widget %parent) %status 0)
				   ))
			     (widget-set-attr widget %status 1)
			     )
			   (begin ;;get root-pop hide
			     (let ((proot (widget-get-parent-cond
					   widget
					   (lambda (p)
					     ;;(printf " ~a ~a\n" (widget-get-attr p %text) (widget-get-attrs p 'is-root) )
					     (widget-get-attrs p 'root)
					     )
					   )))
			       ;;(printf " ee=~a ~a \n" (widget-get-attr proot %text) (widget-get-attr proot %status) )
			       ;;(draw-widget-rect proot)
			       
			       (widget-set-attr proot %status 0)
			       (widget-set-child-attr proot %status 0)

			       ))
			   )
		       ;;(widget-set-child-attr widget %status (widget-get-attr widget %status))
		       (widget-layout-update (widget-get-root widget))


		       ;;(printf "click ->~a ~a\n" (widget-get-events widget 'click) (widget-get-attr widget %text))
		       (if (procedure? (widget-get-events widget 'click))
			   ((widget-get-events widget 'click) widget parent type data)
			   )
		       ;;(widget-child-rect-event-mouse-button widget type data)
		       
		       ;; (printf "### ~a status=~a  ~a\n\n" (widget-get-attr (widget-get-root widget ) %text)
		       ;; 	       (widget-get-attr widget %status)
		       ;; 	       (widget-get-attr widget %h) )
		       )
		     )

		 (let ((ret (widget-child-rect-event-mouse-button widget type data)))
		   ;;(printf "child event ret ~a\n" ret )
		   '()
		   )
		 ))
	   
	   )
	 #t
	 ))
      widget
      ))
    
  (define (tree  w h text)
    (let ((widget (widget-new 0.0 0.0 w h text)))
      ;;(vector-set! widget %type type)
      (widget-set-padding widget 20.0 0.0 20.0 0.0)
      (widget-set-layout
       widget
       (lambda (widget . args)
	 (linear-layout widget)
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
		 
		 ;;(graphic-sissor-begin gx gy w h)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 255.0 0.0 0.0 0.5)
		 )
	       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y))))
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)
		 ;;(printf "~a,~a\n" (vector-ref widget %x) (vector-ref widget %y))
		 ;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
		 
		 ;;(graphic-sissor-begin gx gy  w  h )

		 ;;(if (eqv? 'tree-item (vector-ref widget %type))
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -1.0) (random 255.0) 255.0 0.0 0.3)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -10.0) (random 255.0)  0.0  0.0 0.5)
		 ;;   )
		 (draw-text gx
		 	    (+ gy)
		 	    text)

		 ))
	   
	   (if (= (widget-get-attr widget %status) 1)
	       (widget-draw-child widget)
	       )
	   
	   ;;(graphic-sissor-end)
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
	   (if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
	       (begin
		 ;;(printf "tree click event ~a ~a ~a\n" type text data)
		 ;;click head
		 (if (is-in-widget-top widget
				        (vector-ref data 3)
					(vector-ref data 4) )
		     (let ()
		       (if (= 0 (widget-get-attr widget %status) )
			   (widget-set-attr widget %status 1)
			   (widget-set-attr widget %status 0))
		       
		       ;;(widget-set-child-attr widget %status (widget-get-attr widget %status))
		       (widget-layout-update (widget-get-root widget))
		       (if (procedure? (widget-get-events widget 'click))
			   ((widget-get-events widget 'click) widget parent type data)
			   )
		       ;; (printf "### ~a status=~a  ~a\n\n" (widget-get-attr  widget  %text)
		       ;; 	       (widget-get-attr widget %status)
		       ;; 	       (widget-get-attr widget %h) )
		       )
		     )
		 ;;(draw-widget-child-rect parent widget )
		 ;;(widget-child-rect-event widget type data)

		 ;;(draw-widget-rect widget  (random 255.0) 0.0 0.0 1.0)
		 (widget-child-rect-event-mouse-button widget type data)
		 
		)))
	 #t
	 ))
      widget
      ))
  
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
	 (flow-layout widget)
	 (vector-set! widget %scroll-height
		      (calc-child-height widget))
	 ;;(printf "all child height ~a\n" (calc-child-height widget))
	 ;;(printf "widget ~a,~a\n" (widget-get-attr widget %w)  (widget-get-attr widget %h))
	 (vector-set! widget %scroll-y 0.0)
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

		 ;;(printf "~a,~a   ~a,~a\n"  gx gy  (vector-ref widget %x)  (vector-ref widget %y) )
		 ;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 0.0 255.0 0.0 0.5)
		 
		 (graphic-sissor-begin gx gy  w  h )
		 (draw-scroll-bar (+ gx w -10.0 ) gy 10.0 h
				  (vector-ref widget %scroll-y)
				  (+ (vector-ref widget %scroll-height) -40.0)
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
		 ;;(printf "event scroll ~a\n" type)
		 (vector-set! widget %scroll-height
			      (calc-child-height widget))

		 (let ((offsety (* -1.0 (vector-ref widget %scroll-rate)
				   (vector-ref data 1))))

		   ;;over top
		   (if (< (+ (vector-ref widget %scroll-y) offsety) 0)
		       (begin
			 (set! offsety 0.0)
			 (widget-layout-update widget);;may change
			 (vector-set! widget %scroll-y 0.0)
			 )
		       ;;over height
		       (if (> (+ (vector-ref widget %scroll-y) offsety) (vector-ref widget %scroll-height)  )
			   (begin
			     (set! offsety 0.0)
			     (vector-set! widget %scroll-y (vector-ref widget %scroll-height))
			     )
			   (begin
			     (vector-set! widget %scroll-y
					  (+ (vector-ref widget %scroll-y)
					     offsety ))
			     (plus-child-y-offset widget offsety)
			     )))
		   
		   ;;(printf "(set! offsety 0)=>~a\n" offsety)
		   ;; (printf "(calc-height widget)=>~a scroll-y=~a offsety=~a\n"
		   ;; 	   (calc-child-height widget)
		   ;; 	   (vector-ref widget %scroll-y)
		   ;; 	   offsety
		   ;; 	   )
		   ))	)
	   (if (= type %event-mouse-button)
	       (begin
		 (widget-child-rect-event-mouse-button widget type data)
		 ;;(printf "scroll click event ~a ~a ~a\n" type text data)
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
	   (if (= type %event-motion)
	       (begin
		  (widget-child-rect-event-mouse-motion widget type data)
		 ;;(printf "motion ~a ~a\n" type data)
		 ))
	   )
	 ))
      widget
      ))


  
  (define (edit w h text)
    (let ((widget (widget-new 0.0 0.0 w h text))
	  (ed (graphic-new-edit w h))
	  )
      
      (widget-set-attrs widget '%edit ed)
      (widget-set-attrs
       widget
       (format "%event-~a" %text)
       (lambda (ww text)
	 (graphic-edit-set-text  (widget-get-attrs ww '%editor) text)
	
	 ))

      (widget-set-attrs
       widget
       "%event-syntax-on-hook"
       (lambda (ww)
	 (if (equal? #t (widget-get-attrs widget 'syntax-on))
	     (let ((syntax-cache (cffi-alloc (* 64 (string-length text)))))
	       (init-syntax)
	       (widget-set-attrs widget 'syntax-cache syntax-cache)
	       (parse-syntax syntax-cache text)		
	       (gl-edit-set-highlight ed syntax-cache)
	       ))))
      
      (graphic-edit-add-text ed text)

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
	       (if (equal? #t (widget-get-attrs widget 'syntax-on))
		   (parse-syntax (widget-get-attrs widget 'syntax-cache) text)
		   )
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
			      (+ gy 1.0)
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
		     (lmx (vector-ref data 3))
		     (lmy (vector-ref data 4))
		     (lx (vector-ref widget %x))
		     (ly (vector-ref widget %y))
		     )
		 
		 ;;(printf "child count ~a\n" (length (widget-get-child widget)))
		 ;;tab bar click event
		 (let loop ((child (widget-get-child widget)) (pos 0.0))
		   (if (pair? child)
		       (begin
			 ;;(printf "tab child ~a\n" (vector-ref (car child) %status) )
			 (if  (in-rect (+ lx pos)
				       (+ ly )
				       (+ segment)
				       (+ 30.0)
				       lmx
				       lmy)
			      (begin
				(widget-set-child-attr widget %status 0)
				(vector-set! (car child) %status 1)
				((vector-ref (car child) %event) (car child) widget  type data))
			      )
			 
			 (loop (cdr child) (+ pos segment )))
		       
		       ))
		 ;;child event
		 (widget-child-rect-event-mouse-button
		  widget type data
		  (lambda(wid lmx lmy)		    
		    (and (is-in-widget wid
				 lmx lmy)
			 (= (widget-get-attr wid %status) 1))))
		 
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
	  (vv (video-new src (widget-get-window-width) (widget-get-window-height) )))
      (widget-set-attrs widget 'video vv)
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


  (define (view w h)
    (let ((widget (widget-new 0.0 0.0 w h ""))
	  )
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
	       (draw (vector-ref widget %draw)))

	   (if (null? parent)
	       (let ((gx (+ (vector-ref widget %x)))
		     (gy (+ (vector-ref widget %y)))
		     (background (widget-get-attrs  widget 'background ))
		     )
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)		 
		 (graphic-sissor-begin gx gy w h)

		 (if (equal? '() background)
		     (draw-panel gx gy w h '())
		     (draw-panel gx gy w h '() background))

		 )
	       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
		     (background (widget-get-attrs  widget 'background ))
		     )
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)
		 (graphic-sissor-begin gx gy w h)

		 (if (equal? '() background)
		     (draw-panel gx gy w h '())
		     (draw-panel gx gy w h '() background))

		 ;; (draw-button gx
		 ;; 	      gy
		 ;; 	      w h text)
		 ))
	   
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
	       ;;(printf "view click event ~a ~a ~a\n" type text data)
	       ;;(draw-widget-child-rect parent widget )
	       ))
	 (if (= type %event-scroll)
	     (begin
	       (widget-child-rect-event-scroll widget type data)
	       ))
	 (if (and (or (= type %event-char) (= type %event-key)) (=  (vector-ref widget %status) %status-active) )
	     (begin
	       ;;(printf "\nview key event ~a ~a status=~a\n" type  data (vector-ref widget %status) )
	       (widget-child-key-event widget type data)
	       ;;(draw-widget-child-rect parent widget )
	       ))
	 (if (= type %event-motion)
	     (widget-child-rect-event-mouse-motion widget type data))
	 ))
      
      widget))

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
		 (if (procedure? (widget-get-events widget 'click))
		     ((widget-get-events widget 'click) widget parent type data)
		     )
		 ;;(printf "button click event ~a ~a ~a\n" type text data)
		 ;;(draw-widget-child-rect parent widget )
		 )))
	 ))
      widget))

  (define (dialog x y w h title)
    (let ((widget (widget-new x y w h title))
	  )
      
      (widget-set-layout
       widget
       flow-layout)
      
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
	     (widget-active widget)
	     #t
	     )))
      
      (widget-set-padding widget 10.0 10.0 40.0 40.0)

      (widget-add widget)
      widget
      ))





  )
