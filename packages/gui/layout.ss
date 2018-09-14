;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui layout)
  (export
   linear-layout
   frame-layout
   flow-layout
   grid-layout
   
   %match-parent
   %wrap-conent
   )
  (import (scheme)
	  (utils libutil)
	  (gui widget)
	  (cffi cffi))

  (define %match-parent -1.0)
  (define %wrap-conent 0)

  ;;layout
  (define (grid-layout row col )
    (lambda (widget row col)
      '()
      )
    )

  (define (process-match-parent c )
    ;;match-parent attrib
    (let ((parent (vector-ref  c %parent))
	  (window-width (widget-get-window-width))
	  (window-height (widget-get-window-height))
	  )
      (if (= (widget-get-attrs  c '%w ) %match-parent)
	  (if (null? parent)
	      (begin
		(widget-set-attr c %w (* 1.0 window-width) ))
	      (begin
		(widget-set-attr c %w (widget-get-attr parent %w)  )))
	  )
      (if (= (widget-get-attrs  c '%h ) %match-parent)
	  (if (null? parent)
	      (begin
		(widget-set-attr c %h  (* 1.0 window-height)))
	      (widget-set-attr c %h (widget-get-attr parent %h)))
	  )))


  (define linear-layout
    (case-lambda
     [(widget)
      (process-match-parent widget)
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
	(if (= (widget-get-attr widget %status) 1)
	    (let loop ((c child) (px left) (py top) )
	      (if (pair? c)
		  (begin
		    ;;(printf "               ********* ~a               py=~a\n" (widget-get-attr (car c) %text)  py)
		    (process-match-parent (car c))
		    (vector-set! (car c) %x px)
		    (vector-set! (car c) %y py)
		    (if (= (widget-get-attr (car c) %status) 1)
			(begin
			  (if (procedure? (vector-ref (car c) %layout))
			      ((vector-ref (car c) %layout) (car c)))
			  
			  ;; (printf "               >>>>>>>>~a child total height=~a  py=~a\n"
			  ;; 	  (widget-get-attr (car c ) %text)
			  ;; 	  (calc-all-child-line-height (car c) 40.0)
			  ;; 	  py
			  ;; 	  )
			  
			  (set! py (+ py
				      (widget-get-attr (car c) %h)
				        ))
			  )
			(begin
			  (widget-set-attr (car c) %h  (widget-get-attr (car c ) %top)  )		
			  (set! py (+ py (widget-get-attr (car c ) %top) ))
			  )
			)

		    ;; (printf " ~a  status=>~a height=~a  x=~a y=~a\n"
		    ;; 	    (widget-get-attr (car c) %text)
		    ;; 	    (widget-get-attr (car c) %status)
		    ;; 	    (widget-get-attr (car c) %h)
		    ;; 	    (widget-get-attr (car c) %x)
		    ;; 	    (widget-get-attr (car c) %y)
		    ;; 	    )
	        
		   
		    ;;(printf "~a    pos=~a,~a  h=~a\n" (widget-get-attr (car child) %text) px py (vector-ref (car child) %h))
		    (loop (cdr c) px py )
		    )
		  (widget-set-attr widget %h py)
		  ;;(widget-set-attr widget %h (+ top (calc-all-child-line-height widget ) bottom) )
		  )
	      ;;(widget-set-attr widget %h py)
	      )
	    (widget-set-attr widget %h  (widget-get-attr widget %top) )
	    
	    )
	(widget-update-pos widget)
	(widget-child-update-pos widget)
	
	)]
     [(widget layout-info)
      (let ((x  (vector-ref  widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref  widget %w))
	    (h  (vector-ref  widget %h)))
	'()
	)]
     ))

(define frame-layout
    (case-lambda
     [(widget)
      (process-match-parent widget)
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
		(process-match-parent (car c))

		(vector-set! (car c) %x left)
		(vector-set! (car c) %y top)
		(if (procedure? (vector-ref (car c) %layout))
		    ((vector-ref (car c) %layout) (car c)))
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
      (process-match-parent widget)
      (let ((x  (vector-ref widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref widget %w))
	    (h  (vector-ref widget %h))
	    (top  (vector-ref widget %top))
	    (left  (vector-ref widget %left))
	    (right  (vector-ref widget %right))
	    (bottom  (vector-ref widget %bottom))
	    (parent (vector-ref widget %parent))
	    (child (vector-ref widget %child))
	    )
	(let loop ((c child) (sx left) (sy top) (ww 0) )
	  (if (pair? c)
	      (begin
		(vector-set! (car c) %status 1);;force visible may change
		(process-match-parent (car c))
		(vector-set! (car c) %x sx)
		(vector-set! (car c) %y sy)
		
		(if (pair? (cdr c))
		    (set! ww (vector-ref (car (cdr c)) %w)))
		
 		(if (> (+ sx (vector-ref (car c) %w) ww ) (- w right) )
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
		(if (procedure? (vector-ref (car c) %layout))
		    ((vector-ref (car c) %layout) (car c)))
		
		(loop (cdr c) sx sy ww )
		)
	      ))

	)]
     [(widget layout-info)
      (let ((x  (vector-ref  widget %x))
	    (y  (vector-ref widget %y))
	    (w  (vector-ref  widget %w))
	    (h  (vector-ref  widget %h)))
	(process-match-parent widget)
	)]
      
     ))
  
  
)
