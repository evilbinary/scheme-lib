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
      (if (and (>= x px) (<= x (+ px w)) (>= y py) (<= y (+ py h)))
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
   ;; (display (format "window-mouse-event ~a ~a\n" button action ))
    (if (and (= 0 button ) (= 1 action))
	(begin
	  (set! $active-view (find-view $root-view $cursor-x $cursor-y))
	  (set! $last-focus $active-view)
	  ((view-mouse-event $active-view) $active-view button action mods)
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
			#f
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
			#f
			0.0 0.0 0.0 0.0 ) )
	   (if  (null? p)
		nil
		(begin 
					;(view-calc-layout v)
		  (view-childs-set! p (append (view-childs p )  (list v) )  ))) v)]))))


  (define (layout-views view)
    ((view-layout view ) view)
    (let loop ((childs (view-childs view)))
      (if (pair? childs)
	  (begin
	    (layout-views (car childs))
	    (loop (cdr childs))))))

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
	(display "---->default\n")
	(view-x-set! view (+ p-x x) )
	(view-x-set! view (+ p-y y) )]
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
	(display "---->else")])
      ;; (view-x-set! view (+ ml (view-x view) ))
      ;; (view-x-set! view (+ ml (view-x view) ))
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

  
  (define (edit-key-event view keycode scancode action modifier )
    (display (format "   keycode=~a action=~a\n" keycode action))
    (let ((row (view-attrib-ref view 'cursor-row nil))
	  (col (view-attrib-ref view 'cursor-col nil))
	   (x (view-x view))
	   (y (view-y view))
	  (cursor-cols (view-attrib-ref view 'cursor-cols nil))
	  (cx (view-attrib-ref view 'cursor-x nil))
	  (cy (view-attrib-ref view 'cursor-y nil))
	  (text (view-attrib-ref view 'text "")))
      (display (format "cols=~a\n" cursor-cols ))
      (cond 
	[(= keycode GLFW_KEY_RIGHT)  (view-calc-cursor-pos view (+ x cx 10.0) (+ y cy)) ]
	[(= keycode GLFW_KEY_LEFT)   (view-calc-cursor-pos view (+ x cx -10.0) (+ y cy)) ]
	[(= keycode GLFW_KEY_DOWN)  (display "abc\n") (view-calc-cursor-pos view (+ x cx ) (+ y cy 25.0)) ]
	[(= keycode GLFW_KEY_UP)   (view-calc-cursor-pos view (+ x cx ) (+ y cy -10.0)) ]
	
	[(= keycode GLFW_KEY_BACKSPACE)
	 (set! text (string-delete text (+ cursor-cols -1 )  ))
	 (view-attrib-set! view 'text text)
	 (view-calc-cursor-pos view (+ x cx ) (+ y cy 0.0)) ]
	
	[(= keycode GLFW_KEY_SPACE)
	 (set! text (string-insert text (+ cursor-cols ) " " ))
	 (view-attrib-set! view 'text text)
	 (view-calc-cursor-pos view (+ x cx) (+ y cy)) ]
	
	[(= keycode GLFW_KEY_ENTER)
	 (set! text (string-insert text (+ cursor-cols ) "\n" ))
	 (view-attrib-set! view 'text text)
	 (view-calc-cursor-pos view (+ x cx) (+ y cy)) ]
	[else
	 (if (number? cursor-cols)
	     (begin
	       (set! text (string-insert text (+ cursor-cols ) (format "~a" (integer->char keycode ))  ))
	       (view-attrib-set! view 'text text)
	       (view-calc-cursor-pos view (+ x cx 10.0) (+ y cy))
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
	  (view-calc-cursor-pos view $cursor-x $cursor-y)
	  )
     
      ;;(nvg-fill-paint vg bg)
      ;;(nvg-fill vg)
      (if (procedure? click)
	  (click view action))))

  (define (view-calc-cursor-pos view mx my)
    (let ( (x (view-x view))
	   (y (view-y view))
	   (text (view-attrib-ref view 'text ""))
	   (w (view-width view))
	   (h (view-height view))
	   (cy (cffi-alloc 64))
	   (cx (cffi-alloc 64))
	   (crow (cffi-alloc 64))
	   (ccol (cffi-alloc 64))
	   (rows (cffi-alloc 64))
	   (ccols (cffi-alloc 64)))
      ;;(cffi-log #t)
      (calc-cursor-pos vg x y w h mx my text cx cy crow ccol rows ccols)
      ;;(display (format "cursor-cols=~a\n" (cffi-get-int ccols)))
      (cffi-log #f)
      (view-attrib-set! view 'cursor-x  (-  (cffi-get-float cx) x) )
      (view-attrib-set! view 'cursor-y  (-  (cffi-get-float cy) y)  )
      (view-attrib-set! view 'cursor-row (cffi-get-int crow) )
      (view-attrib-set! view 'cursor-col (cffi-get-int ccol) )
      (view-attrib-set! view 'rows (cffi-get-int rows) )
      (view-attrib-set! view 'cursor-cols (cffi-get-int ccols) )
      (cffi-free cx)
      (cffi-free cy)
      (cffi-free crow)
      (cffi-free ccol)
      (cffi-free rows)
      (cffi-free ccols)
    ))
  
  ;;position-cussor-index todo
  (define (position-cussor-index pos-x pos-y string)
    (let* ((len (string-length string))
	   (glyphs (cffi-alloc (* len (* 64 4 ))))
	   (caretx 0.0)
	   (cur-id 0)
	   (nglyphs (nvg-text-glyph-positions vg pos-x pos-y string NULL glyphs len )))
      
      (set! caretx (cffi-get-float (+ glyphs (* 0 64 ) 64 )))
      (let loop ((i 1))
	(if (<  i nglyphs)
	    (begin
	      (display (format " caretx=~a glyphs[~a].x=~a\n" caretx  i (cffi-get-float (+ glyphs (* i 64) )) ))

	      (if (> (abs (- caretx pos-x )) (abs (- (cffi-get-float (+ glyphs (* i 64 ) 64 )) pos-x )) )
		  (begin
		    (set! cur-id i)
		    (set! caretx (cffi-get-float (+ glyphs (* cur-id 64 ) 64 )))
		    ))
	      (display (format " caretx=~a ~a\n" caretx cur-id ))
	      
	      (loop (+ i 1) )
	      )))

      (cffi-free glyphs)
      nglyphs
      ))
  
  ;;grapic op
  (def-function draw-paragraph "drawParagraph"
    (void* float float float float float float string)
    void)
  (def-function calc-cursor-pos "calcCursorPos"
    (void* float float float float float float string void* void* void* void*  void* void*)
    void
    )
  (define (draw-views view)
    ((view-draw view ) view)
    (let loop ((childs (view-childs view)))
      (if (pair? childs)
	  (begin 
	    (draw-views (car childs))
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
	   (x (view-x view))
	   (y (view-y view))
	   (w (view-width view))
	   (h (view-height view)))

      ;;(cffi-log #t)
      (if (number? cursor-x)
	  (begin 
	    (nvg-begin-path vg)
	    (nvg-move-to vg (+ x cursor-x) (+ y cursor-y) )
	    (nvg-line-to vg (+ x cursor-x) (+  y cursor-y 20.0) )
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
   
      (draw-paragraph vg x y w h   $cursor-x $cursor-y text)
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

  (define (is-black col)
    (if (and (= 0 (NVGcolor-r col)) 
	     (= 0 (NVGcolor-g col)) 
	     (= 0 (NVGcolor-b col)) 
	     (= 0 (NVGcolor-a col)) ) #t #f))

  (define (cpToUTF8 cp str)
    str)
  
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
	    (set! iw (nvg-text-bounds vg 0.0 0.0  (cpToUTF8 preicon icon) NULL NULL))
	    (set! iw (* h 0.15))))

      (if (not (= 0 preicon))
	  (begin 
	    (nvg-font-size vg (* h 1.3))
	    (nvg-font-face vg "icons")
	    (nvg-fill-color vg (nvg-rgba 255 255 255 96))
	    (nvg-text-align vg (+ NVG_ALIGN_LEFT NVG_ALIGN_MIDDLE) )
	    (nvg-text vg (+ x (* w 0.5) (- (* tw 0.5) ) (- (* iw 0.75))) (+ y (* h 0.5)) (cpToUTF8 preicon icon) NULL  )))

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
