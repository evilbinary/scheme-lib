;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (gui gui) )

(define (test1)
  (window "test gui" 800 800 
	  (let (
		(win4 (window '() "win4" 400 200 :left))
		(win3 (window '() "win3" 300 200 :left))
		(win2 (window '() "win2" 200 200 :left) )
		(win (window '() "win" 200 200 :right) )
		(view (make-view '() 280 280 :center)))
	    ;; (button view "gaga" 80 80 :fill (color-rgba 255 0 0 25) (color-rgba 255 0 0 25))
	    
	    (button view "0" 40 40 :center)
	    (button view "1" 40 40 :top-left)
	    (button view "2" 40 40 :top-right)
	    (button view "3" 40 40 :bottom-left)
	    (button view "4" 60 60 :bottom-right)

	    (button win "11" 40 40 :left (color-rgba 255 0 0 255))
	    (button win "12" 40 40 :right (color-rgba 255 0 0 255))
	    ;; (button dialog "13" 40 40 :top)
	    (button win "14" 60 60 :bottom (color-rgba  0 255 0 255) )

	    (button win2 "1" 40 40 :left (color-rgba 255 0 0 255))
	    (button win2 "2" 40 40 :right (color-rgba 255 0 0 255))
	    ;; (button dialog "13" 40 40 :top)
	    (button win2 "3" 20 20 :bottom (color-rgba 255 0 0 255) )
	    
	    (label win2 "label" 40 30 :center )	)))


(define (test-win-order)
  (window "gaga" 800 800
	  (let (
		(win1 (window '() "win1" 400 200 :top))
		(win2  (window '() "win2" 300 200 :right))
		(win3  (window '() "win3" 200 200 :bottom))
		)
	    (button win1 "win1" 80 40 :bottom (color-rgba  0 255 0 255) (color-rgba 255 0 0 255 ))
	    (button win2 "win2" 80 40 :bottom (color-rgba  0 255 0 255) )
	    (button win3 "win3" 80 40 :bottom (color-rgba  0 255 0 255) )
	    (button win3 "win3-4" 80 40 :left (color-rgba  0 255 0 255) )
	    (label win2 "hello" 40 30 :center )
	    (button '() "button" 40 40 :center) ) ))

(define (test-label)
  (window "test-label" 200 200
	  (let ((a  (label '() "11" 40 40 :center  (color-rgba 255 255 255 255 )  (color-rgba 23 134 201 255 ) ))
		(b (label '() "22" 40 40 :top (color-rgba 255 255 255 255 )  (color-rgba 113 158 36 255 ) ))
		(c (label '() "33" 40 40 :bottom (color-rgba 255 255 255 255 )  (color-rgba  223 160 59 255 ) ))
		)
	    (view-attrib-set! a 'text-align 'left)
	    (view-attrib-set! b 'text-align 'center) 
	    (view-attrib-set! c 'text-align 'right) )))			     

(define (test-corner-view)
  (window "test-corner-view" 800 800
	  (let ((view (make-view '() 150 150 :center))
		)
	    
	    (view-backgroud-set! view (color-rgba 222 48 4 255))
	    (label view "4" 40 40 :bottom-right  (color-rgba 255 255 255 255 )  (color-rgba 23 134 201 255 ) )
	    (label view "3" 40 40 :bottom-left  (color-rgba 255 255 255 255 )  (color-rgba 223 160 59 255 ) )
	    (label view "2" 40 40 :top-right (color-rgba 255 255 255 255 )  (color-rgba 113 158 36 255 ) )
	    (label view "1" 40 40 :top-left (color-rgba 255 255 255 255 )  (color-rgba 61 82 113 255 ) )
	    )
	  ))

(define (test-edge-view)
  (window "test-edge-view" 800 800
	  (let ((view (make-view '() 150 150 :center)))
	    
	    (view-backgroud-set! view (color-rgba 222 48 4 255))
	    (label view "4" 40 40 :bottom  (color-rgba 255 255 255 255 )  (color-rgba 23 134 201 255 ) )
	    (label view "3" 40 40 :top  (color-rgba 255 255 255 255 )  (color-rgba 223 160 59 255 ) )
	    (label view "2" 40 40 :right (color-rgba 255 255 255 255 )  (color-rgba 113 158 36 255 ) )
	    (label view "1" 40 40 :left (color-rgba 255 255 255 255 )  (color-rgba 61 82 113 255 ) )) ))



(define (test-win-label)
  (window "gaga" 800 800
	  (let* (
		(win1 (window '() "win1" 300 300 :top-right))
		(win2 (window '() "win2" 300 200 :right))
		(win3 (window '() "evilbinary test editor" 300 300 :center))
		(win4 (window '() "win4" 300 300 :bottom-right))
		
		(view (make-view win1 150 150 :center))
		(button1   (button win1 "click me" 80 40 :bottom (color-rgba  0 255 0 255) (color-rgba 255 0 0 255 )))
		)

	    (view-onclick-set! button1 (lambda (view action)
					 (if (= 1 action)
					     (view-backgroud-set! button1  (color-rgba 23 134 201 255 ))
					     (view-backgroud-set! button1  (color-rgba 255 0 0 255 )))
					 (display (format "onclick action=~a\n" action))))
	    
	    (button win2 "win2" 80 40 :bottom (color-rgba  0 255 0 255) )
	    (edit win3 "Failure is probably the fortification in your pole. It is like a peek your wallet as the thief, when you are thinking how to spend several hard-won lepta, when you are wondering whether new money, it has laid background. Because of you, then at the heart of the most lax, alert, and most low awareness, and left it godsend failed." 290 240 :center  )
	    ;;(button win3 "win3-4" 80 40 :left (color-rgba  0 255 0 255) )
	    
	    (label win2 "hello\ntest" 40 30 :center )
	    (button '() "button" 80 40 :top-left)

	    (edit win4 "testafasfa" 80 40 :center)

	    (view-backgroud-set! view (color-rgba 222 48 4 255))
	    (label view "4" 40 40 :bottom-right  (color-rgba 255 255 255 255 )  (color-rgba 23 134 201 255 ) )
	    (label view "3" 40 40 :bottom-left  (color-rgba 255 255 255 255 )  (color-rgba 223 160 59 255 ) )
	    (label view "2" 40 40 :top-right (color-rgba 255 255 255 255 )  (color-rgba 113 158 36 255 ) )
	    (label view "1" 40 40 :top-left (color-rgba 255 255 255 255 )  (color-rgba 61 82 113 255 ) )

	    (label win4 "4" 40 40 :fill-right  (color-rgba 255 255 255 255 )  (color-rgba 23 134 201 255 ) )
	    (label win4 "3" 40 40 :fill-left  (color-rgba 255 255 255 255 )  (color-rgba 223 160 59 255 ) )
	    (label win4 "2" 40 40 :fill-top (color-rgba 255 255 255 255 )  (color-rgba 113 158 36 255 ) )
	    (label win4 "1" 40 40 :fill-bottom (color-rgba 255 255 255 255 )  (color-rgba 61 82 113 255 ) ) 

	    ) ))


(define (test-image)
  (window "test-image" 600 600
	  (let* ((win1 (window '() "win1" 300 300 :center))
		 (a  (image win1 "./test2.jpg" 80 80 :center ))
		 (b  (image win1 "./face.png" 80 80 :left ))
		 (c  (image win1 "./test2.jpg" 80 80 :right ))
	        )
	    '()
	    (let loop ((i 0))
	      (if (< i 1)
		  (begin
		    (button '() "menu" 80 40 :top-left)
		    ;(image win1 "./test2.jpg" 80 80 :bottom )
		    (loop (+ i 1)))))
	  )))			     

;;(test-win-order)
;;(test-corner-view)
;;(test-edge-view)
;;(test-label)
 (test-win-label)
;;(test-image)
