;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/16.
;;邮箱:rootdebug@163.com
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
   tab
   tree
   view
   pop
   progress
   )
  (import (scheme)
	  (utils libutil)
	  (gui video)
	  (gui widget)
	  (gui draw)
	  (gui graphic )
	  (gui layout)
	  (gui stb)
	  (gui syntax))


   (define (progress w h percent)
     (let ((widget (widget-new 0.0 0.0 w h "")))
       (widget-set-attrs widget 'color #x44ff0000)
       (widget-set-attrs widget 'background #x44484848)
       (widget-set-attrs widget 'percent percent)

      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
	       (gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
	       (background (widget-get-attrs  widget 'background ))
	       (color (widget-get-attrs  widget 'color ))
	       (percent (widget-get-attrs  widget 'percent ))
	       )
	   (vector-set! widget %gx gx)
	   (vector-set! widget %gy gy)
	   ;;(printf "percent ~a\n" percent)
	   
	   (draw-rect gx  gy
		      w
		      h background)
	   (draw-rect (+ gx ) (+ gy)
		      (* percent w)
		      h color)
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
			(let ((in #f)
				(lmx (- mx (vector-ref widget %x)  ));;(vector-ref widget %left)
	     		(lmy (- my (vector-ref widget %y)  ))
			)
				(if (is-in widget (vector
									mx
									my ))
					(set! in #t ))				
				(let loop ((c (widget-get-child ww)))
					(if (pair? c)
						(begin
						; (printf "->>> ~a,~a===~a,~a\n" mx my
						; 	 (widget-get-attr (car c ) %x)
						; 	 (widget-get-attr (car c ) %y)
						; 	 )
						(if (widget-rect-fun (car c) lmx lmy)
						; (if (is-in (car c) (vector
						; 			mx
						; 			my ))
							(begin
								;;(printf "true  ~a\n" (widget-get-attr (car c) %text ))
								;;(draw-widget-rect (car c) 255.0 0.0 0.0 1.0)
								(set! in #t ))
							(loop (cdr c))
							))))
						;;(printf "widget-rect fun=~a ~a\n" (widget-get-attr widget %text ) in )
						in)
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
				(gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
				(color (widget-get-attrs widget 'color))
				(background (widget-get-attrs  widget 'background ))
				)
				(vector-set! widget %gx gx)
				(vector-set! widget %gy gy)
			;;(printf "~a,~a\n" (vector-ref widget %x) (vector-ref widget %y))
			;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
			
			;;(graphic-sissor-begin gx gy  w  h )

			;;(if (eqv? 'tree-item (vector-ref widget %type))
			;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -1.0) 0.0 255.0 0.0 0.3)
			;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h -10.0) (random 255.0)  0.0  0.0 0.5)
			;;   )
			(draw-item-bg gx gy w h background)
			;;hover
			(if  (= (widget-get-attr widget %status) %status-active)
				(draw-hover gx
					gy
					(widget-get-attr widget %w)
					(widget-get-attr widget %h)
					))
			;;(draw-text gx gy w h text)
			(if (null? color)
				(draw-text gx gy w h
						(widget-get-attr widget %text ) )
				(draw-text gx gy w h
						(widget-get-attr widget %text) color))
			))
		
		(if (equal? #t (widget-get-attrs widget 'static))
			(widget-set-attr widget %status %status-active))
		;;(printf "%status=>~a ~a\n" (widget-get-attr widget %status) (widget-get-attr widget %text))
		(if (= (widget-get-attr widget %status) %status-active)
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
				(widget-set-cursor 'arrow)
				;;(equal? (widget-get-attrs widget 'root ) #f)
					;;(printf "motion ~a\n" (widget-get-attr widget %text))
					(if (is-in widget data)
						(begin  ;;(equal? '() (widget-get-attrs widget 'root))
						;;(printf "motion ~a ~a\n" (widget-get-attr widget %text) (widget-get-attr widget %status) )
						
						(if (= %status-default (widget-get-attr widget %status) )
							(begin 
								(if (not (null? (widget-get-attr widget %parent)))
								(begin
								(widget-set-child-attr (widget-get-attr widget %parent) %status %status-default)
								))
								(widget-set-attr widget %status %status-active)
								)))
							(begin
								(if (= %status-default (widget-get-attr widget %status))
									(widget-set-child-attr  widget  %status %status-default)
									)))
				(if (= (widget-get-attr widget %status) %status-active)
					(widget-child-rect-event-mouse-motion widget type data))
				;;(printf "=>motion ~a ~a\n" (widget-get-attr widget %text) (widget-get-attr widget %status) )

				))
			(if (= type %event-motion-out)
				(begin
					;;(printf "moution out ~a\n" text)
					(widget-set-attr widget %status %status-default)
					(widget-set-child-attr  widget  %status %status-default)
				))
			(if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
				(begin
					;;(printf "pop click  name=~a status ~a\n"  text (widget-get-attr widget %status))	
					;;click widget
					(if (is-in-widget widget (vector-ref data 3) (vector-ref data 4))
						(let ()
						
					  (if (= 0 (widget-get-attr widget %status) )
						(begin 
							(if (not (null? (widget-get-attr widget %parent)))
							(begin
							(widget-set-child-attr (widget-get-attr widget %parent) %status %status-default)
							))
							;;(widget-set-attr widget %visible #t)
							;;(widget-set-attr widget %status 1)
							;;(widget-set-child-attr widget %status 1)
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
							
							(widget-set-attr proot %status %status-default)
							(widget-set-child-attr proot %status %status-default)

							))
						) 						
						;;(widget-set-child-attr widget %status (widget-get-attr widget %status))
						(widget-layout-update (widget-get-root widget))

						;; (printf "click ->~a ~a status=~a\n"
						;; 	       (widget-get-events widget 'click)
						;; 	       (widget-get-attr widget %text)
						;; 	       (widget-get-attr widget %status)
						;; 	       )
						(if (and (procedure? (widget-get-events widget 'click))
								;;(equal? #t (widget-get-attr widget %visible))
								(equal? %status-active (widget-get-attr widget %status) ))
							(begin
								((widget-get-events widget 'click) widget parent type data)
								(widget-set-attr widget %status %status-default)

								))
						;;(widget-set-child-attr widget %status %status-active)
						
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
			)
			(let ((gx (+ (vector-ref parent %gx) (vector-ref widget %x)))
				(gy (+ (vector-ref parent %gy) (vector-ref widget %y)))
				(color (widget-get-attrs  widget 'color ))
				)
				(vector-set! widget %gx gx)
				(vector-set! widget %gy gy)
				(if (null? color)
					(draw-text gx
							(+ gy)
							(widget-get-attr widget %text ) )
					(draw-text gx
							(+ gy)
							(widget-get-attr widget %text) color))
			))
		(if (= (widget-get-attr widget %status) 1)
			(widget-draw-child widget)
			)
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
		(widget-set-cursor 'hand )
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
				))
			(widget-child-rect-event-mouse-button widget type data) )
			)))
	 	#t
	 ))
      widget
    ))
  
  (define (scroll w h)
    (let ((widget (widget-new 0.0 0.0 w h "")))
      (widget-set-attrs widget 'direction  1)
      (widget-set-attrs widget 'rate  50.0)
      (widget-set-attrs widget 'scroll-x  0.0)
      (widget-set-attrs widget 'scroll-y  0.0)
      (widget-set-attrs widget 'scroll-height  0.0)
      (widget-set-attrs widget 'show-scroll #t)
      (widget-set-layout
       widget
       (lambda (widget . args)
				(flow-layout widget)
				(widget-set-attrs widget 'scroll-height
								(calc-child-height widget))
				;;(printf "all child height ~a\n" (calc-child-height widget))
				;;(printf "widget ~a,~a\n" (widget-get-attr widget %w)  (widget-get-attr widget %h))
				(widget-set-attrs widget 'scroll-y 0.0)
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
		     (gy (+ (vector-ref widget %y)))
		     (background (widget-get-attrs  widget 'background ))
		     )
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)
		 
		 (graphic-sissor-begin gx gy w h)
		 (if (equal? '() background)
		     '()
		     (draw-panel gx gy w h '() background))
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 255.0 0.0 0.0 0.5)
		 )
	       (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		     (gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
		     (background (widget-get-attrs  widget 'background ))
		     )
		 (vector-set! widget %gx gx)
		 (vector-set! widget %gy gy)

		 ;;(printf "~a,~a   ~a,~a\n"  gx gy  (vector-ref widget %x)  (vector-ref widget %y) )
		 ;;(graphic-draw-solid-quad x y (+ x w) (+ y h) 0.0 255.0 0.0 0.2)
		 ;;(graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 0.0 255.0 0.0 0.5)
		 
		 (graphic-sissor-begin gx gy  w  h )

		 (if (equal? '() background)
		     '()
		     (draw-panel gx gy w h '() background))
		 (if (equal? #t (widget-get-attrs widget 'show-scroll))
			(draw-scroll-bar (+ gx w -10.0 ) gy 10.0 h
					(widget-get-attrs widget 'scroll-y)
					(+ (widget-get-attrs widget 'scroll-height) -40.0)
					))
		 ))
	   ;;(draw (vector-ref widget %draw))
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
				(widget-set-attrs widget 'scroll-height
								(calc-child-height widget))

				(let ((offsety (* -1.0 (widget-get-attrs widget 'rate)
							(vector-ref data 1))))

					;;over top
					(if (< (+ (widget-get-attrs widget 'scroll-y) offsety) 0)
							(begin
					(set! offsety 0.0)
					(widget-layout-update widget);;may change
					(widget-set-attrs widget 'scroll-y 0.0)
					)
					;;over height
					(if (> (+ (widget-get-attrs widget 'scroll-y) offsety) (widget-get-attrs widget 'scroll-height)  )
						(begin
							(set! offsety 0.0)
							(widget-set-attrs widget 'scroll-y (widget-get-attrs widget 'scroll-height))
							)
						(begin
							(widget-set-attrs widget 'scroll-y
								(+ (widget-get-attrs widget 'scroll-y)
									offsety ))
							(plus-child-y-offset widget offsety)
							)))
					(widget-child-rect-event-scroll widget type data)
					;;(printf "(set! offsety 0)=>~a\n" offsety)
					; (printf "(calc-height widget)=>~a scroll-y=~a offsety=~a\n"
					; 	   (calc-child-height widget)
					; 	   (widget-get-attrs widget 'scroll-y)
					; 	   offsety
					; 	   )
					)))
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
	 			(graphic-edit-set-text  (widget-get-attrs ww '%edit) text)
				(widget-set-attr widget %h (gl-edit-get-height ed))
				;;(printf "event ====> ~a ~a\n" (format "%event-~a" %text) (widget-get-attr widget %h) )
				(widget-layout-event widget)
				(if (equal? #t (widget-get-attrs ww 'syntax-on))
						(let ((syntax-cache (gl-edit-get-highlight ed))
								(syn (widget-get-attrs widget 'syntax))
								(params (gl-edit-get-text ed))
						)	
							(printf "re render syntax ~a\n" syntax-cache )
							(parse-syntax syn syntax-cache params)
							(gl-edit-update-highlight ed)
							)
						)
				))
      
      (widget-set-attrs
       widget
       "%event-color-hook"
       (lambda (ww name color)
	 			(graphic-edit-set-color (widget-get-attrs ww '%edit) color)
	 			))

	   (widget-set-attrs
       widget
       "%event-cursor-color-hook"
       (lambda (ww name color)
	 			(gl-edit-set-cursor-color (widget-get-attrs ww '%edit) color)
	 		))

		(widget-set-attrs
			widget
			"%event-font-line-height-hook"
			(lambda (ww name val)
				( gl-edit-set-font-line-height (widget-get-attrs ww '%edit) val)
				(widget-layout-event widget)
			))


		(widget-set-attrs
			widget
			"%event-select-color-hook"
				(lambda (ww name color)
				(gl-edit-set-select-color (widget-get-attrs ww '%edit) color)
			))

      (widget-set-attrs
       widget
       "%event-font-hook"
       (lambda (ww name value) 
				(gl-edit-set-font (widget-get-attrs ww '%edit) value -1)
				(widget-layout-event widget)
	 			))

       (widget-set-attrs
       widget
       "%event-font-size-hook"
       (lambda (ww name value)
	 			(gl-edit-set-font (widget-get-attrs ww '%edit) 0 value)
				(widget-layout-event widget)
	 			))
	(widget-set-attrs
		widget
		"%event-show-no-hook"
		(lambda (ww name value)
					(gl-edit-set-show-no (widget-get-attrs ww '%edit) value)
					(widget-layout-event widget)
					))
	(widget-set-attrs
		widget
		"%event-lineno-color-hook"
		(lambda (ww name value)
					(gl-edit-set-lineno-color (widget-get-attrs ww '%edit) value)
					))	
	
	(widget-set-attrs
		widget
		"%event-get-selection-hook"
		(lambda (ww name)
					(gl-edit-get-selection (widget-get-attrs ww '%edit))
					))

	(widget-set-attrs
		widget
		"%event-get-selection-hook"
		(lambda (ww name)
					(gl-edit-get-selection (widget-get-attrs ww '%edit))
					))

	(widget-set-attrs
		widget
		"%event-get-line-count-hook"
		(lambda (ww name)
					(gl-edit-get-line-count (widget-get-attrs ww '%edit))
					))
	(widget-set-attrs
		widget
		"%event-get-cursor-x-hook"
		(lambda (ww name)
					(gl-edit-get-cursor-x (widget-get-attrs ww '%edit))
					))

	(widget-set-attrs
		widget
		"%event-get-cursor-y-hook"
		(lambda (ww name)
					(gl-edit-get-cursor-y (widget-get-attrs ww '%edit))
					))
	
	(widget-set-attrs
		widget
		"%event-get-cursor-xy-hook"
		(lambda (ww name)
					(list (gl-edit-get-cursor-x (widget-get-attrs ww '%edit))
						(gl-edit-get-cursor-y (widget-get-attrs ww '%edit)))
					))

	(widget-set-attrs
		widget
		"%event-get-last-row-count-hook"
		(lambda (ww name)
					(gl-edit-get-row-count (widget-get-attrs ww '%edit) 
						(- (gl-edit-get-line-count (widget-get-attrs ww '%edit)) 1))
					))

	(widget-set-attrs
		widget
		"%event-selection-hook"
		(lambda (ww name val)
					(gl-edit-set-selection (widget-get-attrs ww '%edit) 
						(list-ref val 0)
						(list-ref val 1)
						(list-ref val 2)
						(list-ref val 3)
						 )
					))
	(widget-set-attrs
		widget
		"%event-get-text-range-hook"
		(lambda (ww name val)
					(gl-edit-get-text-range (widget-get-attrs ww '%edit) 
						(list-ref val 0)
						(list-ref val 1)
						(list-ref val 2)
						(list-ref val 3)
						 )
					))
	(widget-set-attrs
		widget
		"%event-get-current-line-text-hook"
		(lambda (ww name)
			(let* ( (ed (widget-get-attrs ww '%edit))
					(current-row (gl-edit-get-selection-row-start ed))
					(row-count (gl-edit-get-row-count ed current-row))
					)
					(gl-edit-get-text-range  ed
						current-row
						0
						current-row
						row-count
						 )
					)))

      (widget-set-attrs
       widget
       "%event-syntax-on-hook"
       (lambda (ww name val)
				(if (equal? #t (widget-get-attrs widget 'syntax-on))
						(let ((syntax-cache (gl-edit-get-highlight ed))
						(syn (widget-get-attrs widget 'syntax)) )
							(widget-set-attrs widget 'syntax syn)
							(widget-set-attrs widget 'syntax-cache syntax-cache)
							(parse-syntax syn syntax-cache (gl-edit-get-text ed))	
							(gl-edit-update-highlight ed)
							(widget-set-attr widget %h (gl-edit-get-height ed))
							))))

			; (widget-set-attrs
      ;  (widget-get-attr widget %parent)
      ;  "%event-offsety-hook"
      ;  (lambda (ww name val)
			;  		;;(printf "offsety=~a ~a\n" val   (widget-get-attr ww %y ) )
			; 		(gl-edit-set-scroll ed (widget-get-attr ww %x ) (widget-get-attr ww %y) )
			; 	))		
      
      (graphic-edit-set-text ed text)

      (widget-set-draw
       widget
       (lambda (widget parent);;draw
		(let ((gx  (widget-in-parent-gx widget parent))
			(gy   (widget-in-parent-gy widget parent) )
			(background (widget-get-attrs  widget 'background ))
			(border (widget-get-attrs widget 'border))
			(ww  (vector-ref  widget %w))
			(hh  (vector-ref  widget %h))
			)
						(vector-set! widget %gx gx)
						(vector-set! widget %gy gy)

						(if (equal? '() background)
								'()
								(draw-panel gx gy ww hh '() background))
						(if (number? border)
							(draw-border gx gy ww hh border))
						(graphic-draw-edit ed gx gy)
						)))
      
      (widget-set-event
       widget
       (lambda (widget parent type data);;event
	 			;;(printf ">>>>>>>event ~a ~a\n" type data)
				(if (= type %event-key)
						(begin
							;;(printf "edit key event ~a ~a\n" type data )
							(gl-edit-key-event ed
								(vector-ref data 0)
								(vector-ref data 1)
								(vector-ref data 2)
								(vector-ref data 3) )
							(if (equal? #t (widget-get-attrs widget 'syntax-on))
								(let ((syntax-cache (gl-edit-get-highlight ed) )
											(params '())
											(syn (widget-get-attrs widget 'syntax)) )
											'()
											(set! params (gl-edit-get-text ed))
											;;(printf "re render syntax ~a ~a\n" syntax-cache params)
											(parse-syntax syn syntax-cache params)
											(gl-edit-update-highlight ed)
									))
							))
				(if (= type %event-char)
						(begin
							;;(printf ">edit char event ~a ~a\n" type data )
							(gl-edit-char-event ed
								(vector-ref data 0)
								(vector-ref data 1)
								)
							(vector-set! widget %text (gl-edit-get-text ed))
							(if (equal? #t (widget-get-attrs widget 'syntax-on))
						(let ((syntax-cache (gl-edit-get-highlight ed) )
						(params '())
						(syn (widget-get-attrs widget 'syntax))
						)
							(set! params (gl-edit-get-text ed))
							;;(printf "params ~a\n" params)
							;;(vector-set! widget %text params)
							;;(printf "re render syntax ~a ~a\n" syntax-cache params)
							;;(parse-syntax syn syntax-cache params)
							;;(gl-edit-update-highlight ed)
							)
						)
							))
				(if (= type %event-motion)
						(begin
							(widget-set-cursor 'ibeam)
							(gl-edit-mouse-motion-event ed
												(vector-ref data 0)
												(vector-ref data 1))
							))
					(if (= type %event-layout)
						(begin
								'()
								(widget-set-attr widget %h (gl-edit-get-height ed))
								;;(printf "event layout ~a edit height ~a ~a\n" data (gl-edit-get-height ed) (widget-get-attr widget %h ) )
								;;(graphic-edit-set-text ed (gl-edit-get-text ed))
								;;(printf "event layout\n")
							))
					(if (= type %event-scroll)
						(begin
								; (printf "edit height ~a\n" (gl-edit-get-height ed) )
								; (printf "event scroll ~a ~a\n" (widget-get-attr widget %x ) (widget-get-attr widget %y))
								(gl-edit-set-scroll ed (widget-get-attr widget %x ) (widget-get-attr widget %y) )
							))
				(if (= type %event-mouse-button )
						(begin
							(gl-edit-mouse-event ed
									(vector-ref data 1)
									(vector-ref data 3)
									(vector-ref data 4))
							;;(printf "button click event ~a ~a ~a\n" type text data)
							;;(draw-widget-child-rect parent widget )
							))
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
    (let* ((widget (widget-new 0.0 0.0 w h text))
	   (attrs (widget-attrs widget))
	   (id (load-texture src attrs)))
      (widget-set-attrs widget 'src src)
      (widget-set-attrs widget 'src-id id)
      (widget-set-attrs widget 'load #t)
      (widget-set-attrs widget 'mode 'fix-xy)
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
	 (if (equal? #f (widget-get-attrs widget 'load ))
	     (let ((res (load-texture (widget-get-attrs widget 'src) attrs)))
	       ;;(printf "reload image ~a ~a\n" src res)
	       (widget-set-attrs widget 'src-id res)
	       (widget-set-attrs widget 'load #t)
	       ))
	 (if (null? parent)
	     (let ((gx (+ (vector-ref widget %x)))
		   (gy (+ (vector-ref widget %y))))
	       (vector-set! widget %gx gx)
	       (vector-set! widget %gy gy)
	       (draw-image gx gy
			   w h id attrs ))
	     (let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
		   (gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
		   (id (widget-get-attrs widget 'src-id))
		   )
	       (vector-set! widget %gx gx)
	       (vector-set! widget %gy gy)
	       (draw-image gx
			   gy
			   w h id attrs))) ))
      
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
		 (if (procedure? (widget-get-events widget 'click))
		     ((widget-get-events widget 'click) widget parent type data)
		     )
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
	 (if (and (or (= type %event-char) (= type %event-key))  ) ;;(=  (vector-ref widget %status) %status-active)
	     (begin
	       ;;(printf "\nview ~a key event ~a ~a status=~a\n" (widget-get-attr widget %text)  type  data (vector-ref widget %status) )
	       (widget-child-key-event widget type data)
		   (if (= type %event-key)
					(widget-child-focus-event widget type data))
	       ;;(draw-widget-child-rect parent widget )
	       ))
	 (if (= type %event-motion)
	     (widget-child-rect-event-mouse-motion widget type data))
	 ))
      
      widget))

  (define (button w h text)
    (let ((widget (widget-new 0.0 0.0 w h text)))
	  (widget-set-attrs widget 'text-width (draw-get-text-width text))
      (widget-set-draw
       widget
       (lambda (widget parent);;draw
			(let ((gx  (+ (vector-ref parent %gx) (vector-ref widget %x)))
				(gy   (+ (vector-ref parent %gy) (vector-ref widget %y)))
				(background (widget-get-attrs  widget 'background )))
				(vector-set! widget %gx gx)
				(vector-set! widget %gy gy)

				(draw-item-bg gx gy w h background)
				;;hover
				(if  (widget-status-is-set widget %status-hover)
					(draw-hover gx
						gy
						(widget-get-attr widget %w)
						(widget-get-attr widget %h)
						))
				;;(printf "tw=>~a\n" tw)
				(draw-widget-text widget)

			)))
      (widget-set-event
       widget
       (lambda (widget parent type data);;event	      	      		     
		(if (null? parent)
		  (begin
			(if (= type %event-mouse-button)
				(draw-widget-child-rect parent widget ))) )
		(begin
		  	(if (= type %event-motion)
			  (begin
			  	;;(printf "mouse motion in ~a\n" text )
				  (widget-set-status widget  %status-hover)
			  	)
			  )
			(if (= type %event-motion-out)
			  (begin
			  	;;(printf "mouse motion out ~a\n" text)
				(widget-set-attr widget %status %status-default)
			  ))
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
		(if (= type %event-scroll)
	     (begin
	       (widget-child-rect-event-scroll widget type data)
	       ))
		(if (and (or (= type %event-char) (= type %event-key))  ) ;;(=  (vector-ref widget %status) %status-active)
			(begin 
				(widget-child-key-event widget type data)
				(if (= type %event-key)
					(widget-child-focus-event widget type data))
			 ))
		(if (= type %event-motion)
			(begin
				(widget-child-rect-event-mouse-motion widget type data)))
		(if (= type %event-motion-out)
			(begin
				;;(printf "motion out\n")
				(widget-child-rect-event-mouse-motion widget type data)))
		(if (and (= type %event-mouse-button) (= (vector-ref data 1) 1) )
			(if (equal? #t (widget-get-attrs widget 'disable-active))
			'()
			(widget-active widget))
			#t
			)))

      (widget-set-padding widget 10.0 10.0 40.0 40.0)

      (widget-add widget)
      widget
      ))




  )
