;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui gui)
  (export 
   window
   button
   label
   image
   edit
   tab
   tab-titles
   stack
   stack-titles
   
   make-view
   window-root-view
   view-onclick-set!
   
   make-NVGcolor 
   make-NVGpaint
   make-array6
   make-array2
   color-rgba
   view-backgroud-set!
   view-attrib-set!
   view-attrib-ref
   view-add
   view-visible-set!
   view-visible
   
   :fill 		
   :center 	
   :top-left
   :top-right   
   :bottom-left 
   :bottom-right
   :left 	
   :right 
   :top 	
   :bottom
   :fill-left
   :fill-right
   :fill-top
   :fill-bottom

   )
  
  (import  (scheme)  
	   (glfw glfw) 
	   (nanovg nanovg) 
	   (gles gles1)  
	   (utils macro)
	   (cffi cffi)
	   (utils strings)
	   )

   (define lib-name
     (case (machine-type)
       ((arm32le) "libgui.so")
       ((a6nt i3nt) "libgui.dll")
       ((a6osx i3osx)  "libgui.so")
       ((a6le i3le) "libgui.so")))
   (define lib (load-librarys  lib-name))
  
  (define nil '())

  (define $root-view nil )
  (define $window nil)
  (define $current nil)
  (define $last-focus nil)

  (define (window-get-native)
    $window)
  
  (define vg '())
  (define font-normal nil)
  (define font-emoji nil )
  (define font-bold nil)
  (define icons nil)

  (define $window-x 0.0)
  (define $window-y 0.0)

  (define $cursor-x 0.0)
  (define $cursor-y 0.0)
  (define $mouse-button nil)
  (define $mouse-action nil)
  (define $mouse-mods nil)
  (define $active-view nil)
  
  (define $window-width 640 )
  (define $window-height  480)
  (define $window-title  "")
  (define $window-cursors nil)
  
  (define :view-group 0)
  (define :window 1)
  (define :view 2)

  (define :fill 	#b00000000000000000000001)
  (define :center 	#b00000000000000000000010)
  (define :top-left	#b00000000000000000000100)
  (define :top-right    #b00000000000000000001000)
  (define :bottom-left 	#b00000000000000000010000)
  (define :bottom-right #b00000000000000000100000)
  (define :left 	#b00000000000000001000000)
  (define :right 	#b00000000000000010000000)
  (define :top 		#b00000000000000100000000)
  (define :bottom 	#b00000000000010000000000)
  (define :fill-left 	#b00000000000100000000000)
  (define :fill-right 	#b00000000001000000000000)
  (define :fill-top 	#b00000000010000000000000)
  (define :fill-bottom 	#b00000000100000000000000)
  
  (define (window-root-view )
    $root-view)
  (define-syntax window
    (syntax-rules ()   	
      [(_ e0 e1 e2 proc ...) 
       (if (null? (window-get-native) )
	   (begin
	     (window-init e0 e1 e2)
	     proc ...
	     (window-loop) )
	   (begin 
	     (window-box e0 e1 e2 proc ...)))]))
  
  ;;(window-update)
  (define (window-update)
    (draw-views $root-view))

  ;;title set
  (define (window-set-title title)
    (set! $window-title title))

  ;;window init
  (define (window-init title width height)
    ;;(cffi-log #t)
    (set! $window-title title)
    (set! $window-width width)
    (set! $window-height height)
    
    (glfw-init)

    (set! $window (glfw-create-window $window-width  $window-height  $window-title   0  0) )
    (glfw-window-hint GLFW_DEPTH_BITS 16);

    (glfw-window-hint GLFW_CLIENT_API GLFW_OPENGL_ES_API);
    (glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 2);
    (glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);

    ;; (glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 1);
    ;; (glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);

    (glfw-make-context-current $window);

    (glad-load-gl-loader  (get-glfw-get-proc-address))
    (glad-load-gles1-loader  (get-glfw-get-proc-address))
    (glad-load-gles2-loader  (get-glfw-get-proc-address))
    (glfw-swap-interval 1)

    (set! vg (nvg-create-gles2 (+ NVG_ANTIALIAS NVG_STENCIL_STROKES ) ))
    (set! font-normal (nvg-create-font vg  "sans" "Roboto-Regular.ttf") )
    (set! font-bold (nvg-create-font vg  "sans-bold" "Roboto-Bold.ttf") )
    (set! icons (nvg-create-font vg  "icons" "entypo.ttf") )
    (set! font-emoji (nvg-create-font vg  "emoji" "Roboto-Regular.ttf") )
    ;;(nvg-add-fallback-font-id vg font-normal font-emoji )
    ;;(set! image1 (nvg-create-image vg "test2.jpg" 0))
    ;;init view
    ;;init cursors herer
    (let loop ((i 0))
      (if (< i 6)
	  (begin
	    (set! $window-cursors
		  (append $window-cursors
			  (list (glfw-create-standard-cursor (+ i GLFW_ARROW_CURSOR)))))
	    (loop (+ i 1)))))
    
    (set! $root-view (make-view $root-view $window-width $window-height ))
    (glfw-set-cursor-pos-callback $window 
				  (lambda (w x y)
				    (window-motion-event x y)
				    ))

    (glfw-set-key-callback $window
			   (lambda (w k s a m)
			     (window-key-event k s a m)
			    ) )
    (glfw-set-window-size-callback $window
				   (lambda (w width height)
				     (set! $window-width width)
				     (set! $window-height height) ))
    (glfw-set-mouse-button-callback $window
				    (lambda (w button action mods)
				      (set! $mouse-button button)
				      (set! $mouse-action action)
				      (set! $mouse-mods mods)
				      (window-mouse-event button action mods))))
  
  ;;window end
  (define (window-end)
    nil)
  
  ;;window layout
  (define (window-layout)
    (let loop ((childs (view-childs $root-view)))
      (if (pair? childs)
	  (begin
	    (layout-views (car childs))
	    (loop (cdr childs))))))

  (define (contais view x y)
    (let ((px (view-x  view))
	  (w  (view-width view))
	  (h  (view-height view))
	  (py (view-y  view )))
      (if (and (view-visible view) (>= x px) (<= x (+ px w)) (>= y py) (<= y (+ py h)))
	  #t #f)))

  (define (find-view view x y)
    (let loop  ((len  (length (view-childs view))))
      (if (zero? len)
	  (if (contais view x y) view nil)
	  (begin
	    (if (contais (list-ref (view-childs view) (- len 1) ) x y)
		(find-view (list-ref (view-childs view) (- len 1)) x y)
		(loop (- len 1))))
	  )))
  
  ;;window event
  (define (window-motion-event x y )
    ;;(display (format "window-motion-event ~a,~a\n" x y))
    (if  (not (null? $active-view)) 
	 ((view-drag-event $active-view) $active-view (- x $cursor-x) (- y $cursor-y))
	 (let ((view  (find-view $root-view x y)))
	   (if (not (null? view))
	       (glfw-set-cursor $window (list-ref $window-cursors (view-attrib-ref view 'cursor 0))))))
    (set! $cursor-y y)
    (set! $cursor-x x)
    )

  (define (window-key-event keycode scancode action modifier )
    ;;(display (format "key=~a scancode=~a action=~a mods=~a\n"  keycode scancode action modifier))
    (if (= action 1)
	(if (not (null? $last-focus))
	    ((view-key-event $last-focus) $last-focus keycode scancode action modifier)))
    nil)

  (define (window-mouse-event button action mods )
   ;;(display (format "window-mouse-event ~a ~a\n" button action ))
    (if (and (= 0 button ) (= 1 action))
	(begin
	  (set! $active-view (find-view $root-view $cursor-x $cursor-y))
	  (set! $last-focus $active-view)
	  ;;(display  (format "window-mouse-event ~a\n" (view-y $active-view) ))
	  ;;(draw-button $active-view)
	  (if (not (null? $active-view))
	      ((view-mouse-event $active-view) $active-view button action mods))
	  )
	(let ((view (find-view $root-view $cursor-x $cursor-y)))
	  (if (not (null? view))
	      ((view-mouse-event view) view button action mods))
	  (set! $active-view nil)))
    )
  
  ;;window op
  (define (window-loop)
    (let ()
      (window-layout)
      (while (= (glfw-window-should-close $window) 0)
	     ;; (glfw-poll-events)
	     (glfw-wait-events)
	     (glClearColor 1.0  1.0  1.0  1.0 )
	     (glClearColor 0.3  0.3  0.32  1.0);
	     (glClear (+  GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT))
	     (nvg-begin-frame vg $window-width $window-height 2.0)
	     (window-update)
	     (nvg-end-frame vg)
	     (glfw-swap-buffers $window)
	     ))
    (window-end)
    (glfw-destroy-window $window);
    (nvg-delete-gles2 vg)
    (glfw-terminate))
  
  ;;widget;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  (define-record-type view 
    (fields 
     (mutable parent)
     (mutable childs)
     (mutable x)
     (mutable y)
     (mutable width)
     (mutable height)
     (mutable context)
     (mutable draw)
     (mutable attribs)
     (mutable layout-attrib)
     (mutable layout)
     (mutable type) ;;0 view-group ,1 window 2 view
     (mutable mouse-event)
     (mutable motion-event)
     (mutable key-event)
     (mutable focus-event)
     (mutable drag-event)
     (mutable focus)
     (mutable visible)
     (mutable margin-left)
     (mutable margin-right)
     (mutable margin-top)
     (mutable margin-bottom))
    (protocol 
     (lambda (new) 
       (case-lambda
	[(parent width height) 
	 (let ((v nil)
	       (p (if (null? parent) $root-view parent) )
	       (c nil)
	       (w (if (fixnum? width) (fixnum->flonum width) width))
	       (h (if (fixnum? height) (fixnum->flonum height) height)))
	   (set! v (new p
			nil 0.0 0.0 
			w h vg
			draw-view 
			(make-eq-hashtable) 
			0
			view-calc-layout :view-group
			default-mouse-event default-motion-event default-key-event default-focus-event default-drag-event
			#f #t
			0.0 0.0 0.0 0.0) )
	   (if  (null? p)
		nil
		(begin 
		  (view-childs-set! p (append   (view-childs p) (list v)  )))) v )]	
	[(parent width height layout-attrib) 
	 (let ((v nil)
	       (p (if (null? parent) $root-view parent) )
	       (c nil)
	       (w (if (fixnum? width) (fixnum->flonum width) width))
	       (h (if (fixnum? height) (fixnum->flonum height) height)))
	   (set! v (new p
			nil 0.0 0.0 
			w h vg
			draw-view 
			(make-eq-hashtable)
			layout-attrib
			view-calc-layout :view-group
			default-mouse-event default-motion-event default-key-event default-focus-event default-drag-event
			#f #t
			0.0 0.0 0.0 0.0 ) )
	   (if  (null? p)
		nil
		(begin 
					;(view-calc-layout v)
		  (view-childs-set! p (append (view-childs p )  (list v) )  ))) v)]))))


  (define (layout-views view)
    (begin
      (if (procedure? (view-layout view))
	  ((view-layout view ) view))
      (let loop ((childs (view-childs view)))
	(if (pair? childs)
	    (begin
	      (layout-views (car childs))
	      (loop (cdr childs)))))) )

  (define (view-calc-layout view)
    (let* ((p (view-parent view))
	   (x (view-x view))
	   (y (view-y view))
	   (p-x (view-x p))
	   (p-y (view-y p))
	   (layout (view-layout-attrib view))
	   (w (view-width view))
	   (h (view-height view))
	   (p-w (view-width p) )
	   (p-h (view-height p))
	   (ml (view-margin-left view))
	   (mr (view-margin-right view))
	   (mt (view-margin-top view))
	   (mb (view-margin-bottom view)))
      (cond  
       [(= layout 0 )
	(display (format "---->default ~a ~a ~a ~a\n" p-x p-y x y))
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y) )]
       [(= :fill (logand layout :fill ) )
	(display "---->fill\n")
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y ) )
	(view-width-set! view p-w)
	(view-height-set! view p-h)]
       
       [(= :fill-left (logand layout :fill-left ) )
	(display "---->fill-left\n")
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y ) )
	(view-height-set! view p-h)]

       [(= :fill-right (logand layout :fill-right ) )
	(display "---->fill-right\n")
	(view-x-set! view (+ p-x x p-w (- w) ))
	(view-y-set! view (+ p-y y ) )
	(view-height-set! view p-h)]

       [(= :fill-top (logand layout :fill-top ) )
	(display "---->fill-top\n")
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y ) )
	(view-width-set! view p-w)
	]

       [(= :fill-bottom (logand layout :fill-bottom ) )
	(display "---->fill-bottom\n")
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y p-h (- h) ) )
	(view-width-set! view p-w)
	]
       
       
       [(= :center (logand layout :center ) )
	(display "---->center\n")
	(view-x-set! view (+ p-x x (/ p-w 2) (/ w -2)) )
	(view-y-set! view (+ p-y y (/ p-h 2) (/ h -2)) )]

       [(= :top-left (logand layout :top-left ) )
	(display "---->:top-left\n")
	(view-x-set! view (+ p-x x ) )
	(view-y-set! view (+ p-y y ) )]
       [(= :top-right (logand layout :top-right ) )
	(display "---->:top-right\n")
	(view-x-set! view (+ p-x x p-w (- w) ) )
	(view-y-set! view (+ p-y y ) )]
       [(= :bottom-left (logand layout :bottom-left ) )
	(display "---->:bottom-left\n")
	(view-x-set! view (+ p-x x  ) )
	(view-y-set! view (+ p-y y p-h (- h)  ) )]	
       [(= :bottom-right (logand layout :bottom-right ) )
	(display "---->:bottom-right\n")
	(view-x-set! view (+ p-x x  p-w (- w) )  )
	(view-y-set! view (+ p-y y p-h (- h) ) )]	

       [(= :left (logand layout :left ) )
	(display "---->:left\n")
	(view-x-set! view (+ p-x x )  )
	(view-y-set! view (+ p-y y (/ p-h 2) (/ h -2) ) )]
       [(= :right (logand layout :right ) )
	(display "---->:right\n")
	(view-x-set! view (+ p-x x  p-h (/ w -1) )  )
	(view-y-set! view (+ p-y y (/ p-h 2) (/ h -2)  ) )]
       [(= :top (logand layout :top ) )
	(display "---->:top\n")
	(view-x-set! view (+ p-x x  (/ p-w 2) (/ w -2 ) ) ) 
	(view-y-set! view (+ p-y y ) )]
       [(= :bottom (logand layout :bottom ) )
	(display "---->:bottom\n")
	(view-x-set! view (+ p-x x (/ p-w 2) (/ w -2 ) )  )
	(view-y-set! view (+ p-y y p-h (- h) ) )]
       [else
	(display "---->else")
	;; (view-x-set! view (+ ml (view-x view) ))
	;; (view-x-set! view (+ ml (view-x view) ))
	])
   
      ))
  
  
  (define (default-mouse-event view button action mods)
    ;;(display (format "  mouse-event ~a ~a\n" button action))
    (let ((click (view-attrib-ref view 'onclick nil)))
      (if (procedure? click)
	  (click view action)))
    nil)
  (define (default-motion-event view  x y)
    nil)

  (define (default-focus-event view focused)
    (display (format "focus ~a\n" focused))
    (view-focus-set! view focused)
    nil)

  (define (default-drag-event view dx dy)
    ;;(display (format "=drag ~a,~a\n" dx dy ))
    ;;(view-x-set! view (+ (view-x view) dx))
    ;;(view-y-set! view (+ (view-y view) dy))
    nil)

  (define (default-key-event view keycode scancode action modifier )
    nil)
  
  (define view-attrib-ref
    (case-lambda
     [(view attr) (hashtable-ref (view-attribs view) attr '())]
     [(view attr default) (hashtable-ref (view-attribs view) attr default )]))

  (define view-attrib-set!
    (case-lambda
     [(view attr val) (hashtable-set! (view-attribs view) attr val )]))

  (define (view-add parent view)
    (view-childs-set! parent (append (view-childs parent) (list view) )))

  (define (view-backgroud-set! view background-color)
    (view-attrib-set! view 'background-color background-color))
  
  (define (view-margin view left right top bottom)
    (view-margin-left-set! view left)
    (view-margin-right-set! view right)
    (view-margin-top-set! view top)
    (view-margin-bottom-set! view bottom))

  (define (view-onclick-set! view callback)
    (view-attrib-set!  view 'onclick callback))
  
  (define (color-rgba r g b a)
    (nvg-rgba r g b a))
  
  ;;button
  (define button
    (case-lambda
     [(parent text width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-button )
	(view-attrib-set! view 'onclick button-mouse-event)
	(view-attrib-set! view 'text text) view) ]
     [(parent text width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-button )
	(view-mouse-event-set! view button-mouse-event)
	(view-attrib-set! view 'text text)
	view)]
     [(parent text width height layout color)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-button )
	(view-attrib-set! view 'text text)
	(view-mouse-event-set! view button-mouse-event)
	(view-attrib-set! view 'color color)
	view)]
     [(parent text width height layout color background-color)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-button )
	(view-attrib-set! view 'text text)
	(view-mouse-event-set! view button-mouse-event)
	(view-attrib-set! view 'color color)
	(view-attrib-set! view 'background-color background-color)
	view)]
     [(text width height)
      (let ((view (make-view nil width height ) ))
	(view-draw-set! view draw-button )
	(view-mouse-event-set! view button-mouse-event)
	(view-attrib-set! view 'text text)
	view)]))

  (define (button-mouse-event view button action mods)
    (let* ((click (view-attrib-ref view 'onclick nil))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view))
	   (bg (nvg-linear-gradient vg 
				    x y x (+ y h)
				    (nvg-rgba 255 255 255 32) 
				    (nvg-rgba 0 0 0  32))))
      ;;(nvg-fill-paint vg bg)
      ;;(nvg-fill vg)
      (if (procedure? click)
	  (click view action))))


  ;;window-box mouse-event-process
  (define (window-box-mouse-event-process view button action mods)
    (display (format "    button=~a action=~a mods=~a\n" button action mods))
    (view-attrib-set! view 'action action))
  
  ;;window-box motion-process
  (define (window-box-motion-event-process view  x y)
    (display (format "    motion ~a,~a\n" x y))
    (let ((focused (view-focus view))
	  (vx (view-x view ))
	  (vy (view-y view)) )
      (if (and  focused (= 1 (view-attrib-ref view 'action)))
	  (begin
	    (view-x-set! view (+ vx (- x $cursor-x)))
	    (view-y-set! view (+ vy (- y $cursor-y)))))))

  ;;window-box focus-process
  (define (window-box-focus-event-process view  focused)
    (display (format "focus ~a\n" focused))
    (view-focus-set! view focused)
    (view-attrib-set! view 'active focused)
    nil)

  (define (window-box-child-drag view dx dy)
    (view-x-set! view (+ (view-x view) dx))
    (view-y-set! view (+ (view-y view) dy))
    (let loop ((childs (view-childs view)))
      (if (pair? childs)
	  (begin
	    (window-box-child-drag (car childs) dx dy)
	    (loop (cdr childs)))
	  ))
    )
  
  ;;window-box drag-process
  (define (window-box-drag-process view dx dy)
    ;;(display (format "    drag==> ~a,~a\n" dx dy))
    ;;(view-x-set! view (+ (view-x view) dx))
    ;;(view-y-set! view (+ (view-y view) dy))
    (window-box-child-drag view dx dy)
    )
  
  ;;window-box
  (define window-box
    (case-lambda
     [(parent text width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-window-box )
	(view-type-set! view :window)
	(view-mouse-event-set! view window-box-mouse-event-process)
	(view-motion-event-set! view window-box-motion-event-process)
	(view-focus-event-set! view window-box-focus-event-process)
	(view-drag-event-set! view window-box-drag-process)
	(view-attrib-set! view 'title text) view) ]
     [(parent text width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-window-box )
	(view-type-set! view :window)
	(view-mouse-event-set! view window-box-mouse-event-process)
	(view-motion-event-set! view window-box-motion-event-process)
	(view-focus-event-set! view window-box-focus-event-process)
	(view-drag-event-set! view window-box-drag-process)
	(view-attrib-set! view 'title text)
	view)]))

 (define (view-child-move view dx dy)
    (view-x-set! view (+ (view-x view) dx))
    (view-y-set! view (+ (view-y view) dy))
    (let loop ((childs (view-childs view)))
      (if (pair? childs)
	  (begin
	    (view-child-move (car childs) dx dy)
	    (loop (cdr childs)))
	  ))
    )
  
  
  ;;label
  (define label
    (case-lambda
     [(parent text width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-label )
	(view-attrib-set! view 'text text) view) ]
     [(parent text width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-label )
	(view-attrib-set! view 'text text)
	view)]
     [(parent text width height layout color bgcolor)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-label )
	(view-attrib-set! view 'text text)
	(view-attrib-set! view 'background-color bgcolor)
	(view-attrib-set! view 'color color)
	view)]))

  ;;image
  (define image
    (case-lambda
     [(parent src width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-image )
	(view-attrib-set! view 'src src) view) ]
     [(parent src width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-image )
	(view-attrib-set! view 'src src)
	view)]
     [(parent src width height layout color bgcolor)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-image )
	(view-attrib-set! view 'src src)
	(view-attrib-set! view 'background-color bgcolor)
	(view-attrib-set! view 'color color)
	view)]))

  ;;edit
  (define edit
    (case-lambda
     [(parent text width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-edit-box )
	(view-attrib-set! view 'text text)
	(view-attrib-set! view 'cursor 1)
	(view-mouse-event-set! view edit-mouse-event)
	(view-key-event-set! view edit-key-event)
	view) ]
     [(parent text width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-edit-box )
	(view-attrib-set! view 'text text)
	(view-attrib-set! view 'cursor 1)
	(view-mouse-event-set! view edit-mouse-event)
	(view-key-event-set! view edit-key-event)
	view)]
     [(parent text width height layout color bgcolor)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-edit-box )
	(view-attrib-set! view 'text text)
	(view-attrib-set! view 'background-color bgcolor)
	(view-attrib-set! view 'color color)
	(view-attrib-set! view 'cursor 1)
	(view-mouse-event-set! view edit-mouse-event)
	(view-key-event-set! view edit-key-event)
	view)]))
  ;;tab
  (define tab
    (case-lambda
     [(parent  width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-tab )
	(view-attrib-set! view 'bar-height 20.0)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view tab-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view) ]
     [(parent  width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-tab )
	(view-attrib-set! view 'bar-height 20.0)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view tab-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view)]
     [(parent  width height layout color bgcolor)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-tab )
	(view-attrib-set! view 'bar-height 20.0)
	(view-attrib-set! view 'background-color bgcolor)
	(view-attrib-set! view 'color color)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view tab-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view)]))
  ;;tab-titles
  (define tab-titles
    (case-lambda
     [(parent l)
      (view-attrib-set! parent 'titles l)]))


  ;;stack
  (define stack
    (case-lambda
     [(parent  width height)
      (let ((view (make-view parent  width height ) ))
	(view-draw-set! view draw-stack )
	(view-attrib-set! view 'bar-height 20.0)
	(view-layout-set! view stack-layout)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view stack-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view) ]
     [(parent  width height layout)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-stack )
	(view-attrib-set! view 'bar-height 20.0)
	(view-layout-set! view stack-layout)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view stack-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view)]
     [(parent  width height layout color bgcolor)
      (let ((view (make-view parent  width height layout) ))
	(view-draw-set! view draw-stack )
	(view-attrib-set! view 'bar-height 20.0)
	(view-layout-set! view stack-layout)
	(view-attrib-set! view 'background-color bgcolor)
	(view-attrib-set! view 'color color)
	;;(view-attrib-set! view 'cursor 0)
	(view-mouse-event-set! view stack-mouse-event)
	;;(view-key-event-set! view edit-key-event)
	view)]))
  
  ;;stack-titles
  (define stack-titles
    (case-lambda
     [(parent l)
      (view-attrib-set! parent 'titles l)]))
  
  (define (stack-layout view)
    (let* ((p (view-parent view))
	   (x (view-x view))
	   (y (view-y view))
	   (p-x (view-x p))
	   (p-y (view-y p))
	   (layout (view-layout-attrib view))
	   (childs (view-childs view))
	   (w (view-width view))
	   (h (view-height view))
	   (p-w (view-width p) )
	   (p-h (view-height p))
	   (bar-height (view-attrib-ref view 'bar-height))
	   (ml (view-margin-left view))
	   (mr (view-margin-right view))
	   (mt (view-margin-top view))
	   (mb (view-margin-bottom view)))
      (view-calc-layout view)
      
      (let loop ((child childs)
		 (i 0)
		 (offset 0.0))
	(if (pair? child)
	    (begin
	      ;;(cffi-log #t)
	     
	      (view-layout-set! (car child) nil)
	      (view-y-set! (car child) (+ bar-height  (view-y view ) offset) )
	      (view-x-set! (car child) (+ (view-x view ) ) )
	      ;;(layout-views (car child))
	     
	      (loop (cdr child ) (+ i 1)
		    (+ offset  bar-height  (if (view-visible (car child ) ) (view-height (car child))  0.0 ) ))
	      )))
      
      ))
  
  ;;edit-key-event
  (define (edit-key-event view keycode scancode action modifier )
    (display (format "   keycode=~a action=~a\n" keycode action))
    (let ((row (view-attrib-ref view 'cursor-row nil))
	  (col (view-attrib-ref view 'cursor-col nil))
	   (x (view-x view))
	   (y (view-y view))
	  (cursor-pos (view-attrib-ref view 'cursor-pos nil))
	  (cx (view-attrib-ref view 'cursor-x nil))
	  (cy (view-attrib-ref view 'cursor-y nil))
	  (text (view-attrib-ref view 'text "")))
      ;;(display (format "cols=~a\n" cursor-pos ))
      (cond 
       [(= keycode GLFW_KEY_RIGHT)  (cursor->position view (+ (view-attrib-ref view 'cursor-pos ) 1 )) ]
       [(= keycode GLFW_KEY_LEFT)   (cursor->position view (+ (view-attrib-ref view 'cursor-pos ) -1 )) ]
       [(= keycode GLFW_KEY_DOWN)  (cursor->down view) ]
       [(= keycode GLFW_KEY_UP)    (cursor->up view) ]
       
       [(= keycode GLFW_KEY_BACKSPACE)
	(set! text (string-delete text (+ cursor-pos -1)  ))
	(view-attrib-set! view 'text text)
	(cursor->position view (+ cursor-pos -1 ))
	]
       
       [(= keycode GLFW_KEY_SPACE)
	(set! text (string-insert text (+ cursor-pos ) " " ))
	(view-attrib-set! view 'text text)
	(cursor->position view (+ cursor-pos 1))
	]
       
       [(= keycode GLFW_KEY_ENTER)
	(set! text (string-insert text (+ cursor-pos 1) "\n" ))
	(view-attrib-set! view 'text text)
	(cursor->position view (+ cursor-pos 1))
	]
       [else
	(if (number? cursor-pos)
	    (begin
	      (set! text (string-insert text (+ cursor-pos ) (format "~a" (integer->char keycode ))  ))
	      (view-attrib-set! view 'text text)
	      (cursor->position view (+ cursor-pos 1))

	      )
	     )]))
    nil)
  
  (define (edit-mouse-event view button action mods)
    (let* ((click (view-attrib-ref view 'onclick nil))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view))
	   (text (view-attrib-ref view 'text ""))
	   (bg (nvg-linear-gradient vg 
				    x y x (+ y h)
				    (nvg-rgba 255 255 255 32) 
				    (nvg-rgba 0 0 0  32))))

      (if (= action 1)
	  (begin
	    (position->cursor view $cursor-x $cursor-y)
	    )
	  )
     
      ;;(nvg-fill-paint vg bg)
      ;;(nvg-fill vg)
      (if (procedure? click)
	  (click view action))))


  (define (tab-mouse-event view button action mods)
    (let* ((click (view-attrib-ref view 'onclick nil))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view))
	   (text (view-attrib-ref view 'text ""))
	   (bar-height (view-attrib-ref view 'bar-height))
	   (active-index (view-attrib-ref view 'active-index 0 ))
	   (child-count (view-childs-count view) )
	   (bg (nvg-linear-gradient vg 
				    x y x (+ y h)
				    (nvg-rgba 255 255 255 32) 
				    (nvg-rgba 0 0 0  32))))

      (if (= action 1)
	  (begin
	    (for i (0 to child-count)
		 (if (and (>= $cursor-x (+ x (* (/ w child-count) (+ i 0))))
			  (<= $cursor-x (+ x (* (/ w child-count) (+ i 1)) ))
			  (>= $cursor-y y)
			  (<= $cursor-y (+ y bar-height)))
		     (begin
		       (view-attrib-set! view 'active-index i )
		       ;;(display (format "active=~a\n" i))
		       )
		     ))
	    ;;(display "tab-mouse-event\n")
	    )
	  )
     
      ;;(nvg-fill-paint vg bg)
      ;;(nvg-fill vg)
      (if (procedure? click)
	  (click view action))))


    (define (stack-mouse-event view button action mods)
    (let* ((click (view-attrib-ref view 'onclick nil))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view))
	   (childs (view-childs view))
	   (text (view-attrib-ref view 'text ""))
	   (bar-height (view-attrib-ref view 'bar-height))
	   (active-index (view-attrib-ref view 'active-index 0 ))
	   (child-count (view-childs-count view) )
	   (bg (nvg-linear-gradient vg 
				    x y x (+ y h)
				    (nvg-rgba 255 255 255 32) 
				    (nvg-rgba 0 0 0  32))))
      ;;(display (format "stack-mouse-even\n"))
			
      (if (= action 1)
	  (let loop ((child childs)
		     (i 0)
		     (offset 0.0))
	    (if (pair? child)
		(begin
		  ;; (display (format "~a ~a ~a==~a ~a\n" x (+ y offset)
		  ;; 		   (+ y offset bar-height)
		  ;; 		   $cursor-x $cursor-y))

		  (if (and (>= $cursor-x (+ x ))
			   (<= $cursor-x (+ x w ))
			   (>= $cursor-y (+ y offset) )
			   (<= $cursor-y (+ y offset bar-height)))
		      (begin
			(if (view-visible (car child))
			    (begin
			      (view-visible-set! (car child) #f)
			      )
			    (begin
			      (view-visible-set! (car child) #t)
			      ))
			
			;;(display (format "stack index=~a\n" i))
			)
		      )
		  ;;moving child here
		  (view-child-move (car child) 0 (-  (+ bar-height  (view-y view ) offset)  (view-y (car child))  ) )

		  (view-y-set! (car child) (+ bar-height  (view-y view ) offset) )
		  (view-x-set! (car child) (+ (view-x view ) ) )
		  ;;(view-layout-set! (car child) nil)
		  
		  
		  (loop (cdr child ) (+ i 1)
			(+ offset  bar-height  (if (view-visible (car child ) ) (view-height (car child))  0.0 ) )))
		  )))
     
      ;;(nvg-fill-paint vg bg)
      ;;(nvg-fill vg)
      (if (procedure? click)
	  (click view action))))

  (define (position->cursor view mx my)
     (let ((rows (cffi-alloc (* 40  3 )))
	  (glyphs (cffi-alloc (* 20 100)))
	  (text (view-attrib-ref view 'text ))
	  (x (view-x view))
	  (y (view-y view))
	  (view-y (view-y view))
	  (width (view-width view))
	  (height (view-height view))
	  (start 0)
	  (end 0)
	  (nrows 0)
	  (i 0)
	  (j 0)
	  (text-padding-left (view-attrib-ref view 'text-padding-left 5.0))
	  (text-padding-right (view-attrib-ref view 'text-padding-right 5.0))
	  (nglyphs 0)
	  (lnum 0)
	  (lineh (cffi-alloc 8))
	  (caretx 0)
	  (px 0.0)
	  (bounds (cffi-alloc (* 64 4)))
	  (cx 0.0)
	  (cy 0.0)
	  (ccol -1)
	  (crow 0)
	  (crows 0)
	  (ccols 0)
	  (cpos 0)
	  (is-end #f)
	  (font-size (view-attrib-ref view 'font-size 20.0))
	  (font-face (view-attrib-ref view 'font-face "sans"))
	  (a 0.0))
     
      ;;(nvg-save vg)
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (nvg-text-align vg  (+ NVG_ALIGN_LEFT NVG_ALIGN_TOP))
      (nvg-text-metrics vg NULL NULL lineh)
      
      ;;(cffi-log #t)
      (set! start (cffi-string-pointer text))
      (set! end (+ start (string-length text ) ))
     
      (set! nrows (nvg-text-break-lines vg start NULL  (- width text-padding-left text-padding-right ) rows 3))
      (while (> nrows 0)
	     (for i (0 to nrows)
		  ;;(display (format "i=~a\n" i))
		
		  (set! nglyphs
			(nvg-text-glyph-positions
		  		 vg x y
		  		 (nvg-text-row-start rows i)
		  		 (nvg-text-row-end rows i)
		  		 glyphs 100)
			)

		  (if (and (> mx x )
		  	      (< mx (+ x width))
		  	      (>= my y)
		  	      (< my (+ y (cffi-get-float lineh))))
		      (begin
			(set! caretx (if (< $cursor-x
					    (+ x (/ (nvg-text-row-width rows i) 2)))
					 x (+ x (nvg-text-row-width rows i))))
			(set! px x)
			
			;; (display (format "\nhit nglyphs=~a cursor-x=~a row-width=~a row/2=~a caretx=~a x=~a\n"
			;; 		 nglyphs
			;; 		 $cursor-x
			;; 		 (nvg-text-row-width rows i)
			;; 		 (+ x (/ (nvg-text-row-width rows i) 2))
			;; 		 caretx
			;; 		 x))

			(for j (0 to nglyphs)
			     
			     (let* ((x0 (nvg-glyph-positions-x glyphs j))
				    (x1 (if (< (+ j 1) nglyphs)
					    (nvg-glyph-positions-x glyphs (+ j 1) )
					    (+ x (nvg-text-row-width rows i ))))
				    (gx (+ (* x0 0.3) (* x1 0.7))))
			       ;;(display (format "j=~a mx=~a x0=~a x1=~a gx=~a px=~a\n" j $cursor-x x0 x1 gx px))
			       (if (and (>= mx px) (< mx gx))
				   (begin
				     (set! caretx x0)
				     ;;(display (format "caretx=~a col=~a\n" x0 j))
				     (set! ccol j)
				     (set! ccols nglyphs)
				     ))
			       (set! px gx)
			       )
			     )
			(set! cx caretx)
			(set! cy y)
			;;(display (format " yy=~a\n" y))
			(set! crow lnum)
			(if (and (> crow 0) (< ccol 0 ))
			     (set! ccol nglyphs ))
			(set! is-end #t)
			)
		      )
		  
		  (if (not is-end) (set! cpos (+ cpos nglyphs 1) ) )		  
		  ;;(display (format "y=~a\n" y))
		  (set! lnum (+ lnum 1))
      	     	  (set! y (+ y (cffi-get-float lineh))) )
	     
	     (set! start  (nvg-text-row-next rows  (- nrows 1) ))
	     (set! nrows (nvg-text-break-lines vg start NULL width rows 3)) )
      (set! crows lnum)
      (cffi-free rows)
      (cffi-free glyphs)
      (cffi-free lineh)
      (cffi-free bounds)
      ;;(nvg-restore vg)

      (display (format "#cpos=~a crow=~a ccol=~a  ccols=~a crows=~a\n" cpos crow ccol ccols crows  ))

      (set! cpos (+ cpos ccol))
      (view-attrib-set! view 'cursor-x (- cx x))
      (view-attrib-set! view 'cursor-y (- cy view-y))
      (view-attrib-set! view 'cursor-row crow)
      (view-attrib-set! view 'cursor-col ccol)
      (view-attrib-set! view 'cursor-rows crows)
      (view-attrib-set! view 'cursor-cols ccols)	    
      (view-attrib-set! view 'cursor-pos cpos)
      
      ))

  ;;cursor->position
  (define (cursor->position view cursor-pos)
    (if (>= cursor-pos 0)
    (let ((rows (cffi-alloc (* 40  3 )))
	  (glyphs (cffi-alloc (* 20 100)))
	  (text (view-attrib-ref view 'text ))
	  (x (view-x view))
	  (y (view-y view))
	  (view-y (view-y view))
	  (width (view-width view))
	  (height (view-height view))
	  (start 0)
	  (end 0)
	  (nrows 0)
	  (i 0)
	  (j 0)
	  (nglyphs 0)
	  (lnum 0)
	  (lineh (cffi-alloc 8))
	  (caretx 0)
	  (px 0.0)
	  (cx 0.0)
	  (cy 0.0)
	  (ccol -1)
	  (crow 0)
	  (crows 0)
	  (ccols 0)
	  (cpos 0)
	  (text-padding-left (view-attrib-ref view 'text-padding-left 5.0))
	  (text-padding-right (view-attrib-ref view 'text-padding-right 5.0))
	  (font-size (view-attrib-ref view 'font-size 20.0))
	  (font-face (view-attrib-ref view 'font-face "sans"))
	  (is-end #f) )

      
      (nvg-save vg)
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (nvg-text-align vg  (+ NVG_ALIGN_LEFT NVG_ALIGN_TOP))
      (nvg-text-metrics vg NULL NULL lineh)
      
      (set! start (cffi-string-pointer text))
      (set! end (+ start (string-length text ) ))
      
      (display (format "cursor->position cpos=~a cursor-pos=~a\n" (view-attrib-ref view 'cursor-pos) cursor-pos))

      (set! nrows (nvg-text-break-lines vg start NULL  (- width text-padding-left text-padding-right) rows 3))
      (while (> nrows 0)
	     (for i (0 to nrows)
		  (set! nglyphs
			(nvg-text-glyph-positions
			 vg x y
			 (nvg-text-row-start rows i)
			 (nvg-text-row-end rows i)
			 glyphs 100))
		  (if (and (>= cursor-pos cpos) (<= cursor-pos (+ cpos nglyphs)))
		      (begin
			(set! caretx (if (< $cursor-x
					    (+ x (/ (nvg-text-row-width rows i) 2)))
					 x (+ x (nvg-text-row-width rows i))))
			(set! px x)
			(for j (0 to nglyphs)
			     (let* ((x0 (nvg-glyph-positions-x glyphs j))
				    (x1 (if (< (+ j 1) nglyphs)
					    (nvg-glyph-positions-x glyphs (+ j 1) )
					    (+ x (nvg-text-row-width rows i ))))
				    (gx (+ (* x0 0.3) (* x1 0.7))))
			       
			       (if (= (+ cpos j) cursor-pos )
				   (begin
				     (set! caretx x0)
				     (set! ccol j)
				     ;;(display (format "cpos=~a cursor-pos=~a\n" (+ cpos j) cursor-pos))
				     (if (not is-end)
					 (begin
					   (set! cx caretx)
					   (set! cy y)
					   (set! crow lnum)
					   (set! ccols nglyphs)
					   ;;(display (format " crow=~a\n" crow))
					   ))
				     (set! is-end #t)
				     ))
			       (set! px gx)
			       )
			     )
			
			
			(if (and (> crow 0) (< ccol 0 ))
			    (set! ccol nglyphs ))
			
			)
		      )
		  
		  (if (not is-end) (set! cpos (+ cpos nglyphs 1) ) )		  
		  (set! lnum (+ lnum 1))
		  (set! y (+ y (cffi-get-float lineh))) )
	     
	     (set! start  (nvg-text-row-next rows  (- nrows 1) ))
	     (set! nrows (nvg-text-break-lines vg start NULL width rows 3)) )
      (set! crows lnum)

      (cffi-free rows)
      (cffi-free glyphs)
      (cffi-free lineh)
      (nvg-restore vg)

      (display (format "cpos=~a crow=~a ccol=~a  ccols=~a crows=~a\n" cpos crow ccol ccols crows  ))
      (set! cpos (+ cpos ccol))
      (view-attrib-set! view 'cursor-x (- cx x))
      (view-attrib-set! view 'cursor-y (- cy view-y))
      (view-attrib-set! view 'cursor-row crow)
      (view-attrib-set! view 'cursor-cols ccols)
      (view-attrib-set! view 'cursor-rows crows)
      (view-attrib-set! view 'cursor-col ccol)
      (view-attrib-set! view 'cursor-pos cursor-pos))))

  (define (cursor->down view)
    (let ((font-size (view-attrib-ref view 'font-size 20.0))
	  (font-face (view-attrib-ref view 'font-face "sans"))
	  (lineh (cffi-alloc 8))
	  (cursor-x (view-attrib-ref view 'cursor-x))
	  (cursor-y (view-attrib-ref view 'cursor-y))
	  (x (view-x view))
	  (y (view-y view))
	  (rows (view-attrib-ref view 'cursor-rows ) )
	  (row (view-attrib-ref view 'cursor-row))

	  )
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (nvg-text-align vg  (+ NVG_ALIGN_LEFT NVG_ALIGN_TOP))
      (nvg-text-metrics vg NULL NULL lineh)
      ;;(display (format "row=~a rows=~a\n" row rows))
      
      (if (< row (- rows 1))
	  (position->cursor view (+ x cursor-x) (+ y cursor-y (cffi-get-float lineh) )))
      
      (cffi-free lineh)
      )
    )

   (define (cursor->up view)
    (let ((font-size (view-attrib-ref view 'font-size 20.0))
	  (font-face (view-attrib-ref view 'font-face "sans"))
	  (lineh (cffi-alloc 8))
	  (cursor-x (view-attrib-ref view 'cursor-x))
	  (cursor-y (view-attrib-ref view 'cursor-y))
	  (x (view-x view))
	  (y (view-y view))
	  )
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (nvg-text-align vg  (+ NVG_ALIGN_LEFT NVG_ALIGN_TOP))
      (nvg-text-metrics vg NULL NULL lineh)
      (if (>= cursor-y (cffi-get-float lineh))
	  (position->cursor view (+ x cursor-x) (+ y cursor-y (- (cffi-get-float lineh) ) )) )
      
      (cffi-free lineh)
      )
    )
  
  (define (draw-paragraph view)
    (let ((rows (cffi-alloc (* 40  3 )))
	  (glyphs (cffi-alloc (* 1 100)))
	  (text (view-attrib-ref view 'text ))
	  (x (view-x view))
	  (y (view-y view))
	  (width (view-width view))
	  (height (view-height view))
	  (start 0)
	  (end 0)
	  (nrows 0)
	  (i 0)
	  (j 0)
	  (nglyphs 0)
	  (text-padding-left (view-attrib-ref view 'text-padding-left 5.0))
	  (text-padding-right (view-attrib-ref view 'text-padding-right 5.0))

	  (lnum 0)
	  (lineh (cffi-alloc 8))
	  (caretx 0)
	  (px 0)
	  (bounds (cffi-alloc (* 64 4)))
	  (font-size (view-attrib-ref view 'font-size 20.0))
	  (font-face (view-attrib-ref view 'font-face "sans"))
	  (a 0.0))
      
      (nvg-save vg)
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (nvg-text-align vg  (+ NVG_ALIGN_LEFT NVG_ALIGN_TOP))
      (nvg-text-metrics vg NULL NULL lineh)
      
      (set! start (cffi-string-pointer text))
      (set! end (+ start (string-length text ) ))
      ;;(set! end (end-ptr text))

      (nvg-begin-path vg)
      
      (set! nrows (nvg-text-break-lines vg start NULL  (- width text-padding-left text-padding-right ) rows 3))
      (while (> nrows 0)
	     ;;(display (format "\n\nnrows=~a\n" nrows))
	     (for i (0 to nrows)
      	     	  (nvg-begin-path vg)
      	     	  (nvg-fill-color vg (nvg-rgba 255 255 255 255))
		  ;;(cffi-log #t)
		  (nvg-text vg (+ x text-padding-left ) y  (nvg-text-row-start rows i)
      	     		    (nvg-text-row-end rows i)  )
		  ;;(cffi-log #f)
		  
      	     	  ;;(display (format "start[~a]=~a end=~a\n" i (nvg-text-row-start rows i)
		  ;;(nvg-text-row-end rows i)))
		  
      	     	  (set! y (+ y (cffi-get-float lineh)))
      	     	  ;;(print-row (+ rows (* 40 i) ))
		  
      	     	  )
	     
	     (set! start  (nvg-text-row-next rows  (- nrows 1) ))
      	     ;;(print-row rows)
	     (set! nrows (nvg-text-break-lines vg start NULL width rows 3))
	     
      	     )
      
      (cffi-free rows)
      (cffi-free glyphs)
      (cffi-free lineh)
      (cffi-free bounds)
      
      (nvg-restore vg)
      
      ;;(display (format "pos-x=~a\n" (nvg-glyph-positions-x (get-glyph-position) 3)))
      
      ))

  ;;64bit define here
  (define (nvg-text-row-next rows i)
   (cffi-get-pointer (+ rows (* 40  i) (* 8 2 ))))

  (define (nvg-text-row-start rows i)
   (cffi-get-pointer (+ rows (* 40  i) (* 8 0))))

  (define (nvg-text-row-end rows i)
    (cffi-get-pointer (+ rows (* 40  i) (* 8 1))))

  (define (nvg-text-row-width rows i)
     (cffi-get-float (+ rows (* 40  i) (* 8 3))))

  (define (nvg-glyph-positions-x glyphs i)
    (cffi-get-float (+ glyphs (* 24 i) (* 8 1) )))  
  
  (define (draw-views view)
    ((view-draw view ) view)
    (let loop ((childs (view-childs view)))
      (if (pair? childs)
	  (begin
	    (if (view-visible (car childs))
		(draw-views (car childs)))
	    (loop (cdr childs)))
	  )))

  ;;draw-view
  (define (draw-view view)
    (let ( (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view)))
      
      
      ;;(nvg-stroke-width vg 10.0)
      ;;(nvg-stroke-color vg  (nvg-rgba 255 0 0 255))
      ;;(nvg-stroke vg)
      
      (if (not (null? bg-color))
	  (begin
	    (nvg-begin-path vg)
	    (nvg-fill-color vg bg-color)
	    (nvg-rounded-rect vg x y  w h 2.0)
	    (nvg-fill vg )))))
  
  ;;draw-circle
  (define (draw-circle vg x y r)
    ;;draw circle
    (nvg-begin-path vg)
    (nvg-circle vg x y r)
    (nvg-stroke vg)
    (nvg-fill vg))

  ;;draw-image
  (define (draw-image view )
    (let* ( (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	    (bg-color (view-attrib-ref view 'background-color nil ))
	    (src (view-attrib-ref view 'src nil))
	    (image (view-attrib-ref view src nil))
	    (x (view-x view))
	    (y (view-y view))
	    (w (view-width view))
	    (h (view-height view)))
      (nvg-begin-path vg);
      (nvg-rounded-rect vg x y  w h 1.0 )
      ;;(nvg-stroke-width vg 1.0)
      ;;(nvg-stroke-color vg  (nvg-rgba 255 0 0 255))
      ;;(nvg-stroke vg)
      (if (not (null? src))
	  (begin
	    (if (null? image)
		(set! image (nvg-create-image vg src 0)))
	    (nvg-fill-paint vg (nvg-image-pattern vg x y  w h 0.0 image 1.0) )
	    ))
      (nvg-fill vg)
      ;;(nvg-delete-image image)
      ))

  ;;drawEditBoxBase
  (define (draw-edit-box-base vg x y w h)
    (let ((bg (nvg-box-gradient vg (+ x 1.0) 
				(+ y 1 1.5)  
				(- w 2.0) 
				(- h 2.0) 
				3.0 4.0 
				(nvg-rgba 255 255 255 32)  
				(nvg-rgba 32 32 32 32))))
      (nvg-begin-path vg)
      (nvg-rounded-rect vg   (+ x 1.0) (+ y 1.0) (- w 2.0) (- h 2.0) (- 4.0 1.0));
      (nvg-fill-paint vg  bg)
      (nvg-fill vg)

      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5)  (- w 1) (- h 1) (- 4 0.5) );
      (nvg-stroke-color vg  (nvg-rgba 0 0 0 48))
      (nvg-stroke vg)))

  ;;draw editbox
  (define (draw-edit-box view)
    (let ( (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	   (cursor-color (view-attrib-ref view 'cursor-color (nvg-rgba 255 192 0 255 )))
	   (cursor-width (view-attrib-ref view 'cursor-width 1.0))
	   (cursor-x (view-attrib-ref view 'cursor-x nil))
	   (cursor-y (view-attrib-ref view 'cursor-y nil))
	   (bg-color (view-attrib-ref view 'background-color nil ))
	   (text (view-attrib-ref view 'text ""))
	   (font-size (view-attrib-ref view 'font-size 18.0))
	   (text-padding-left (view-attrib-ref view 'text-padding-left 5.0))
	   (text-padding-right (view-attrib-ref view 'text-padding-right 5.0))

	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view)))

      ;;(cffi-log #t)
      (if (and (number? cursor-x) (>= cursor-x  0))
	  (begin 
	    (nvg-begin-path vg)
	    (nvg-move-to vg (+ x text-padding-left cursor-x) (+ y cursor-y) )
	    (nvg-line-to vg (+ x text-padding-left cursor-x) (+  y cursor-y 20.0) )
	    (nvg-stroke-color vg cursor-color)
	    (nvg-stroke-width vg cursor-width)
	    (nvg-stroke vg)))
     
      
      (if (not (null? bg-color))
	  (begin
	    (nvg-begin-path vg)
	    (nvg-fill-color vg bg-color)
	    (nvg-rounded-rect vg x y  w h 2.0)
	    (nvg-fill vg )))
      (draw-edit-box-base vg x y w h)
      (nvg-intersect-scissor vg x y w h)

      (draw-paragraph view)
      ;;(draw-paragraph vg x y w h   $cursor-x $cursor-y text)
      ;; (nvg-font-size vg font-size)
      ;; (nvg-font-face vg "sans")
      ;; (nvg-fill-color vg (nvg-rgba 255 255 255 64));
      ;; (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE))
      ;; (nvg-text vg (+ x (* h 0.3)) (+ y (* h 0.5)) text  NULL)
      ) )
  
  ;;draw label
  (define (draw-label view)
    (let (  (vg (view-context view) )
	    (preicon 0)
	    (text (view-attrib-ref view 'text ""))
	    (tw 0.0)
	    (iw 0.0)
	    (x (view-x view))
	    (y (view-y view))
	    (w (view-width view))
	    (h (view-height view))
	    (text-align (view-attrib-ref view 'text-align 'center))
	    (radius (view-attrib-ref view 'corner-radius 0.0))
	    (font-size (view-attrib-ref view 'font-size 18.0))
	    (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	    (bg-color (view-attrib-ref view 'background-color nil )) )
      (nvg-font-size vg font-size)
      (nvg-font-face vg "sans");
      
      (if (not (null?  bg-color))
	  (begin
	    (nvg-begin-path vg)
	    (nvg-rounded-rect vg x y w h radius)
	    (nvg-fill-color vg bg-color)
	    (nvg-fill vg)))
      
      (nvg-fill-color vg color)
      (nvg-text-align vg (+ NVG_ALIGN_LEFT  NVG_ALIGN_MIDDLE))
      (case text-align
	[(left) 
	 (nvg-text vg  x (+ y (* h 0.5)) text NULL)]
	[(right)
	 (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
	 (nvg-text vg  (+ x w (- tw )) (+ y (* h 0.5)) text NULL)]
	[(center)
	 (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
	 (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25)) (+ y (* h 0.5)) text NULL  )])
      ))
  (define (view-childs-count view)
    (length (view-childs view)))

  ;;draw-stack
  (define (draw-stack view)
    (let (  (vg (view-context view) )
	    (preicon 0)
	    (text (view-attrib-ref view 'text ""))
	    (tw 0.0)
	    (iw 0.0)
	    (x (view-x view))
	    (y (view-y view))
	    (w (view-width view))
	    (h (view-height view))
	    (titles (view-attrib-ref view 'titles nil))
	    (childs (view-childs view))
	    (bar-height (view-attrib-ref view 'bar-height))
	    (bar-text-padding-left (view-attrib-ref view 'bar-text-padding-left 5.0))
	    (active-index (view-attrib-ref view 'active-index 0))
	    (child-count (view-childs-count view) )
	    (text-align (view-attrib-ref view 'text-align 'center))
	    (bar-text-align  (view-attrib-ref view 'bar-text-align 'left ))
	    (radius (view-attrib-ref view 'corner-radius 4.0))
	    (font-size (view-attrib-ref view 'font-size 18.0))
	    (font-face (view-attrib-ref view 'font-face "sans"))
	    (font-icon (view-attrib-ref view 'font-icon "icons"))
	    (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	    (bg-color (view-attrib-ref view 'background-color nil )) )
      
      (nvg-intersect-scissor vg x y w h)
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      (let loop ((child childs)
		 (i 0)
		 (offset 0.0))
	(if (pair? child)
	    (begin
	      
	      (nvg-begin-path vg)
	      (nvg-stroke-width vg 1.0)
	      (nvg-rounded-rect vg (+ x 0.5 ) (+ y  offset 1.5 )
				(+  w -2)  (+ bar-height 1.0)  radius)
	      (nvg-fill-color vg  (nvg-rgba  29 29 29 160 ) )
	      (nvg-fill vg)
	      (nvg-stroke-color vg (nvg-rgba 92 92 92 160))
	      (nvg-stroke vg)

	      (if (< i (length titles))
		  (begin
		    (nvg-font-face vg font-face)
		    (nvg-font-size vg font-size)
		    
		    (nvg-fill-color vg color)
		    (nvg-text-align vg (+ NVG_ALIGN_LEFT  NVG_ALIGN_MIDDLE))
		    (case bar-text-align
		      [(left) 
		       (nvg-text vg
				 (+ x 16.0 bar-text-padding-left)
				 (+ y  offset (/ bar-height 2) )
				 (list-ref titles i)  NULL)]
		      [(right)
		       (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
		       (nvg-text vg  (+ x w (- tw )) (+ y )  (list-ref titles i)  NULL)]
		      [(center)
		       (set! tw (nvg-text-bounds vg 0.0 0.0  (list-ref titles i) NULL NULL ))
		       (nvg-text vg
				 (+ x (+ (* tw 1)) (* iw 0.25))
				 (+ y offset (/ bar-height 2) )
				 (list-ref titles i) NULL )])
		    
		    (nvg-font-face vg font-icon)
		    (nvg-font-size vg 38.0)
		    (nvg-fill-color vg color)
		    (nvg-text-align vg (+ NVG_ALIGN_LEFT  NVG_ALIGN_MIDDLE))
		    (if (view-visible (car child))
			 (nvg-text vg  (+ x bar-text-padding-left (+ (* tw 1)) (* iw 0.25))
			      (+ y offset (/ bar-height 2) )  "▾" NULL)
			 (nvg-text vg  (+ x bar-text-padding-left (+ (* tw 1)) (* iw 0.25))
				   (+ y offset (/ bar-height 2) )  "▸" NULL))
		    
		    
		    ))
	      

	      
	      (loop (cdr child ) (+ i 1)
		    (+ offset  bar-height (if (view-visible (car child ) )  (view-height (car child))  0.0 ) ))
	      )))

      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5) (- w 1.0) (- h 1.0) radius  )
      (nvg-stroke-color vg (nvg-rgba  29 29 29 255 ))
      (nvg-stroke vg)
    
      ))
  
  ;;draw-tab
  (define (draw-tab view)
    (let (  (vg (view-context view) )
	    (preicon 0)
	    (text (view-attrib-ref view 'text ""))
	    (tw 0.0)
	    (iw 0.0)
	    (x (view-x view))
	    (y (view-y view))
	    (w (view-width view))
	    (h (view-height view))
	    (titles (view-attrib-ref view 'titles nil))
	    (childs (view-childs view))
	    (bar-height (view-attrib-ref view 'bar-height))
	    (bar-text-padding-left (view-attrib-ref view 'bar-text-padding-left 5.0))
	    (active-index (view-attrib-ref view 'active-index 0))
	    (child-count (view-childs-count view) )
	    (text-align (view-attrib-ref view 'text-align 'center))
	    (bar-text-align  (view-attrib-ref view 'bar-text-align 'left ))
	    (radius (view-attrib-ref view 'corner-radius 4.0))
	    (font-size (view-attrib-ref view 'font-size 18.0))
	    (font-face (view-attrib-ref view 'font-face "sans"))
	    (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	    (bg-color (view-attrib-ref view 'background-color nil )) )
      (nvg-font-size vg font-size)
      (nvg-font-face vg font-face)
      
      (if (not (null?  bg-color))
	  (begin
	    (nvg-begin-path vg)
	    (nvg-rounded-rect vg x y w h radius)
	    (nvg-fill-color vg bg-color)
	    (nvg-fill vg)))

      ;;(display (format "active-index=~a childs-count=~a\n" active-index (view-childs-count view) ))
      (let loop ((child childs)
		 (i 0))
	(if (pair? child)
	    (begin
	      ;;(display (format "child=~a\n" (car child) ))

	      (view-visible-set! (car child) #f)
	      (if (< i (length titles))
		  (begin
		    (nvg-fill-color vg color)
		    (nvg-text-align vg (+ NVG_ALIGN_LEFT  NVG_ALIGN_MIDDLE))
		    (case bar-text-align
		      [(left) 
		       (nvg-text vg
				 (+ x  (* (/ w child-count) i ) bar-text-padding-left)
				 (+ y (/ bar-height 2) )
				 (list-ref titles i)  NULL)]
		      [(right)
		       (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
		       (nvg-text vg  (+ x w (- tw )) (+ y )  (list-ref titles i)  NULL)]
		      [(center)
		       (set! tw (nvg-text-bounds vg 0.0 0.0  (list-ref titles i) NULL NULL ))
		       (nvg-text vg
				 (+ x  (* (/ w child-count) i ) (+ (* tw 1)) (* iw 0.25))
				 (+ y (/ bar-height 2) )
				 (list-ref titles i) NULL )])
		    ))
	      
	      (if (= i active-index)
		  (begin
		    (view-visible-set! (car child) #t)

		    (nvg-begin-path vg)
		    (nvg-line-join vg NVG_ROUND)
		    (nvg-move-to vg (+ x  (* (/ w child-count) i ) -2) (+ y bar-height ) )
		    (nvg-line-to vg (+ x  (* (/ w child-count) i  ) -2) (+ y ))
		    (nvg-line-to vg (+ x  (* (/ w child-count) (+ i 1 ) ) -2) (+ y) )
		    (nvg-line-to vg (+ x  (* (/ w child-count)  (+ i 1 ) ) -2) (+ y bar-height ))

		    (nvg-stroke-width vg 1.0)
		    (nvg-stroke-color vg (nvg-rgba 255 255 255 160))
		    (nvg-stroke vg) )
		  (begin

		    (nvg-begin-path vg)
		    (nvg-stroke-width vg 1.0)
		    (nvg-rounded-rect vg (+ x 0.5 (* (/ w child-count) i) ) (+ y 1.5)
				      (+ (/ w child-count) -2) (+ bar-height 1) radius)
		    (nvg-stroke-color vg (nvg-rgba 92 92 92 160))
		    (nvg-stroke vg)
		    
		    (nvg-begin-path vg)
		    (nvg-stroke-width vg 1.0)
		    (nvg-rounded-rect vg (+ x 0.5 (* (/ w child-count) i) ) (+ y 0.5)
		    (+ (/ w child-count) -2)  (+ 20.0 1) radius)
		    (nvg-stroke-color vg (nvg-rgba  29 29 29 255 ))
		    (nvg-stroke vg)
		    )
		  )
	      
	      (loop (cdr child ) (+ i 1) )) ))
      
      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 0.5) (+ y 1.5) (- w 1.0) (- h 1.0) radius  )
      (nvg-stroke-color vg (nvg-rgba 92 92 92 16 ))
      (nvg-stroke vg)

      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5) (- w 1.0) (- h 1.0) radius  )
      (nvg-stroke-color vg (nvg-rgba  29 29 29 255 ))
      (nvg-stroke vg)
      
      (nvg-fill-color vg color)
      (nvg-text-align vg (+ NVG_ALIGN_LEFT  NVG_ALIGN_MIDDLE))
      (case text-align
	[(left) 
	 (nvg-text vg  x (+ y (* h 0.5)) text NULL)]
	[(right)
	 (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
	 (nvg-text vg  (+ x w (- tw )) (+ y (* h 0.5)) text NULL)]
	[(center)
	 (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))
	 (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25)) (+ y (* h 0.5)) text NULL  )])
      ))


  
  (define (is-black col)
    (if (and (= 0 (NVGcolor-r col)) 
	     (= 0 (NVGcolor-g col)) 
	     (= 0 (NVGcolor-b col)) 
	     (= 0 (NVGcolor-a col)) ) #t #f))
  (define (cp2utf8 int string)
    string
    )

  ;;(def-function cp2utf8 "cpToUTF8" (int string) string )

  ;;draw button
  (define (draw-button view)
    (let* (
	   (vg (view-context view) )
	   (preicon 0)
	   (font-size (view-attrib-ref view 'font-size 18.0))
	   (text (view-attrib-ref view 'text ""))
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view))
	   (color (view-attrib-ref view 'color (nvg-rgba 255 255 255 160) ))
	   (bg-color (view-attrib-ref view 'background-color nil ))

	   (bg (nvg-linear-gradient vg 
				    x y x (+ y h)
				    (nvg-rgba 255 255 255 (if (is-black color) 16 32) )
				    (nvg-rgba 0 0 0 (if (is-black color) 16 32))) )
	   (cornerRadius 4.0)
	   (tw 0.0)
	   (iw 0.0)
	   (icon ""))
      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 1) (+ y 1) (- w 2) (- h 2) (- cornerRadius 1) )
      (if (or (is-black color) (not (null? bg-color )))
	  (begin 
	    (nvg-fill-color vg bg-color)
	    (nvg-fill vg)))
      (nvg-fill-paint vg bg)
      (nvg-fill vg)
      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 0.5) (+ y 0.5) (- w 1.0) (- h 1.0) (- cornerRadius 0.5) )
      (nvg-stroke-color vg (nvg-rgba 0 0 0 48))
      (nvg-stroke vg)
      (nvg-font-size vg font-size)
      (nvg-font-face vg "sans-bold")
      (set! tw (nvg-text-bounds vg 0.0 0.0 text NULL NULL ))

      (if (not (= 0 preicon))
	  (begin
	    (nvg-font-size vg (* h 1.3))
	    (nvg-font-face vg "icons")
	    (set! iw (nvg-text-bounds vg 0.0 0.0  (cp2utf8 preicon icon) NULL NULL))
	    (set! iw (* h 0.15))))

      (if (not (= 0 preicon))
	  (begin 
	    (nvg-font-size vg (* h 1.3))
	    (nvg-font-face vg "icons")
	    (nvg-fill-color vg (nvg-rgba 255 255 255 96))
	    (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE) )
	    (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5) ) (- (* iw 0.75))) (+ y (* h 0.5)) (cp2utf8 preicon icon) NULL  )))

      (nvg-font-size vg font-size)
      (nvg-font-face vg "sans-bold")
      (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE) )
      
      (nvg-fill-color vg (nvg-rgba 0 0 0 160))
      (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25))  (+ y (* h 0.5) -1) text NULL )
      (nvg-fill-color vg color )
      (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5)) (* iw 0.25)) (+ y (* h 0.5)) text NULL  )))

  ;;draw window-box
  (define (draw-window-box view)
    (let ((cornerRadius 3.0)
	  (shadowPaint nil)
	  (headerPaint nil)
	  (vg (view-context view))
	  (title (view-attrib-ref view 'title ""))
	  (active (view-attrib-ref view 'active #f))
	  (x (view-x view))
	  (y (view-y view))
	  (w (view-width view))
	  (h (view-height view)))
      (nvg-save vg)
      ;;(drawWindow vg "test" 20.0 10.0 200.0 150.0)

      ;;window
      (nvg-begin-path vg)
      (nvg-rounded-rect vg x y w h cornerRadius)
      (nvg-fill-color vg (nvg-rgba 28 30 34 192))
      (nvg-fill vg)

      ;;Drop shadow
      (set! shadowPaint (nvg-box-gradient vg x (+ y 2.0) w h (* cornerRadius 2.0) 10.0
					  (nvg-rgba  0  0  0 128 ) (nvg-rgba 0 0 0 0 ) ))
      ;;(display (format "shadowPaint=~a\n" shadowPaint) )

      (nvg-begin-path vg)
      (nvg-rect vg (- x 10 ) (- y 10) (+ w 20) (+ w 30))
      (nvg-rounded-rect vg x y w h cornerRadius)
      (nvg-path-winding vg NVG_HOLE)
      (nvg-fill-paint vg shadowPaint)
      (nvg-fill vg)

      ;;header
      (if active
	  (set! headerPaint (nvg-linear-gradient vg x y x (+ y 15) 
						 (nvg-rgba 255 255 255 8)
						 (nvg-rgba 255 255 255 16)))
	  (set! headerPaint (nvg-linear-gradient vg x y x (+ y 15) 
						 (nvg-rgba 255 255 255 8)
						 (nvg-rgba 0 0 0 16))))
      (nvg-begin-path vg)
      (nvg-rounded-rect vg (+ x 1) (+ y 1) (- w 2) 30.0 (- cornerRadius 1) )
      (nvg-fill-paint vg headerPaint)
      (nvg-fill vg)

      (nvg-begin-path vg)
      (nvg-move-to vg (+ x 0.5) (+ y 0.5 30.0) )
      (nvg-line-to vg (+ x 0.5 w -1) (+ y 0.5 30.0) )
      (nvg-stroke-color vg (nvg-rgba 0  0 0 32 ))
      (nvg-stroke vg)

      (nvg-font-size vg 18.0)
      (nvg-font-face vg "sans-bold")
      (nvg-text-align vg (+ NVG_ALIGN_CENTER NVG_ALIGN_MIDDLE))

      (nvg-font-blur vg 2.0)
      (nvg-fill-color vg (nvg-rgba 0 0 0 128))
      (nvg-text vg (+ x (/ w 2))  (+ y 16 1) title NULL)
      (nvg-font-blur vg 0.0)
      (nvg-fill-color vg (nvg-rgba 220 220 220 160))
      (nvg-text vg (+ x (/ w 2)) (+ y 16) title NULL )
      (nvg-restore vg))))
