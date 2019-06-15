;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui draw)
    (export
        draw-image
        draw-dialog
        draw-text
        draw-line
        draw-rect
        draw-panel
        draw-button
        draw-item
        draw-video
        draw-tab
        draw-scroll-bar
        draw-hover
        draw-item-bg
        draw-border
    )

    (import (scheme)
	  (utils libutil)
	  (gui graphic )
	  (gui video)
	  (gui stb))

  (define (draw-button x y w h text)
      (graphic-draw-solid-quad  x y
              (+ x w) (+ y h)
              31.0 31.0 31.0 0.9)
      (graphic-draw-text (+ x (/ w 2.0 ) -8)
            (+ y (/ h 2.0) -12 )
            text)
      )

  (define (draw-item-bg x y w h color)
    (if (null? color )
        (graphic-draw-solid-quad x y (+ x w) (+ y  h)  61.0 61.0 61.0 0.9 )
        (graphic-draw-solid-quad x y (+ x w) (+ y  h)  color)
    ))

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
			      61.0 61.0 61.0 0.6)
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
				color
				)
      (if (not (null? text))
	  (graphic-draw-text (+ x 30) (+ y 0) text))]
     ))

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

    (define (draw-line x1 y1 x2 y2 color)
        (graphic-draw-line x1 y1 x2 y2
		       color))

    (define draw-text
        (case-lambda
        [(x y text)
        (graphic-draw-text x y text )]
        [(x y text color)
        (graphic-draw-text x y text color)
        ]
        [(x y w h text)
        (graphic-draw-text (+ x (/ w 2.0 ) -8)
		       (+ y (/ h 2.0) -12 )
		       text)
        ]
        )
        )
  (define (draw-hover x y w h)
    (draw-rect x y w h))

  (define (draw-border x y w h color)
    (graphic-draw-line-strip 
      (list  x  y
            (+ x  w) y
            (+ x w ) (+ y h) 
            (+ x ) (+ y h)
             x  y
             ) color)
  )

  (define draw-rect
     (case-lambda
      [( x y w h)
       (graphic-draw-solid-quad x y (+ x w) (+ y  h)  31.0 31.0 31.0 0.4)]
      [( x y w h color)
       (graphic-draw-solid-quad x y (+ x w) (+ y  h)  color)]))

  (define draw-image
    (case-lambda
     [(x y w h src)
      (graphic-draw-texture-quad
       x y
       (+ x w) (+ y h)
       0.0 0.0 1.0 1.0 src)
      ]
     [(x y w h src attrs)
      (if (equal? (hashtable-ref attrs 'mode '()) 'fix-xy)
		  (graphic-draw-texture-quad
		   x y
		   (+ x w) (+ y h)
		   0.0 0.0 1.0 1.0 src))
      (if (equal? (hashtable-ref attrs 'mode '()) 'center-crop)
        (let ((h1 (hashtable-ref attrs 'height h))
          (w1 (hashtable-ref attrs 'width w)))
          (if (> h1 w1)
            (graphic-draw-texture-quad
            x y
            (+ x w) (+ y h)
            0.0
            (/ (/ (- h1 h) 2) h1)
            1.0
            1.0
            src)
            (graphic-draw-texture-quad
            x y
            (+ x w) (+ y h)
            (/ (/ (- w1 w) 2) w1 )
            0.0
            1.0
            1.0
            src)
          )
          ))
      ]
     ))


)