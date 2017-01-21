;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) 
  (gui gles1)
  (gui glut)
  (gui imgui)
  (utils libutil) 
  (box2d-lite util math)
  (box2d-lite vec)
  (box2d-lite world)
  (box2d-lite mat)
  (box2d-lite body)
  (box2d-lite joint)
  (box2d-lite arbiter)
  (dharmalab misc is-vector)
  (box2d-lite contact)


)

(define x 0.0)
(define y -0.8)
(define deltax 0.0)
(define deltay 0.0)
(define bgpos 2.0)
(define world (make-world #f #f #f (make-vec 0.0 0.0) 10))
(is-world world)
(world.clear)

(define time-step 0.008)
(define rotation 0.2)

(define bg '())
(define me '())
(define p1 '())
(define p2 '())
(define p3 '())
(define shot '())
(define objects '()) 
(define mplay '()) 
(define objects-hash (make-eq-hashtable) )
;;资源文件目录设置
(define res-dir 
         (case (machine-type)
           ((arm32le) "/data/data/org.evilbinary.chez/files/")
           (else "./")
            ))

(define (draw-img texture-id vec)
  (let ((texture-array (glut-vector 'float 
          (vector 
          0.0 1.0 
          1.0 1.0  
          0.0 0.0 
          1.0 0.0) ))
      (square-vertices (glut-vector 'float 
          vec))
  )
   (glEnable GL_TEXTURE_2D);                       // 启用纹理映射 
   (glBindTexture GL_TEXTURE_2D texture-id);
   (glEnableClientState GL_TEXTURE_COORD_ARRAY); 
   (glEnableClientState GL_VERTEX_ARRAY);
   (glVertexPointer 2  GL_FLOAT  0  square-vertices);
   (glTexCoordPointer 2 GL_FLOAT 0 texture-array);
   (glDrawArrays GL_TRIANGLE_STRIP  0 4);
   (glDisableClientState GL_VERTEX_ARRAY)
   (glDisable GL_TEXTURE_2D)
   (glDisable GL_TEXTURE_COORD_ARRAY)
   (glut-unvector texture-array)
   (glut-unvector square-vertices)

  ))

(define (draw-life x y l)
  (let* ( (life (/ l 1000.0))
          (p (glut-vector 'float 
                (vector (- 0.104) (- 0.2) 
                    (+ 0.0 life) (- 0.2) 
                    ))))
      (glPushMatrix)
      (glPointSize 20.0)
      ;(glClear (+ GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT) )
      ;(color '( 1.0 0.0 0.0 1.0) )
      (glTranslatef (+ x 0.1) (+ y 0.4) 0.0)
      (glVertexPointer 2  GL_FLOAT  0  p);
      (glEnableClientState GL_VERTEX_ARRAY);
      (glDrawArrays GL_LINES  0 2);
      (glDisableClientState GL_VERTEX_ARRAY)
      (glut-unvector p) )
      (glPopMatrix)
  )

(define (draw-objects objects)
  (let loop ((p objects))
    (if (pair? p)
        (begin
           (glPushMatrix)
            (let ((body (cadar p)))
            (is-body  body)

            (let ((R (angle->mat body.rotation))
                  (x body.position)
                  (h (n*v 0.5 body.width)))

            (is-vec h)
            ;(display (format "width=~a h.x=~a h.y~a \n" body.width h.x h.y ) )

            (let ((v1 (v+ x (m*v R (make-vec (- h.x) (- h.y)))))
              (v2 (v+ x (m*v R (make-vec    h.x  (- h.y)))))
              (v3 (v+ x (m*v R (make-vec    h.x     h.y ))))
              (v4 (v+ x (m*v R (make-vec (- h.x)    h.y )))))

              (is-vec v1)
              (is-vec v2)
              (is-vec v3)
              (is-vec v4)
            
              
              (if  (>  (list-ref (car p) 2) 0 )
                (begin 
                (draw-img (caar p) 
                  (vector v1.x v1.y
                       v2.x v2.y
                       v4.x v4.y
                       v3.x v3.y
                       ) )
                ;(draw-life v1.x v1.y (list-ref (car p) 2) )
                        )
                ;remove body,draw bomb
                (world.remove-body body)
                ) ) )
           )
           (glPopMatrix) 
           ;(set-car! (cdr (car p) ) (+ (cadr (car p) ) 0.01 )) ;x
           ;(set-car! (cddr (car p) ) (- (caddr (car p) ) (cadddr (car p) ) )) ;y
           (loop (cdr p))
           )
        )
    )
  )

(define (draw-joint joint)

  (is-joint joint)

  (let ((b1 joint.body-1)
  (b2 joint.body-2))

    (is-body b1)
    (is-body b2)

    (let ((x1 b1.position)
    (x2 b2.position))

      (is-vec x1)
      (is-vec x2)
      
      (let ((p1 (v+ x1 (m*v (angle->mat b1.rotation) joint.local-anchor-1)))
      (p2 (v+ x2 (m*v (angle->mat b2.rotation) joint.local-anchor-2))))

  (is-vec p1)
  (is-vec p2)

  ;(glColor3f 0.5 0.5 0.8)
  (glColor4f 0.5 0.5 0.8 1.0)

  (let ((p (glut-vector 'float (vector 
                          x1.x x1.y
                          p1.x p1.y
                          x2.x x2.y
                          p2.x p2.y)) ))
        (glVertexPointer 2  GL_FLOAT  0  p);
        (glEnableClientState GL_VERTEX_ARRAY);
        (glDrawArrays GL_LINES  0 4);
        (glDisableClientState GL_VERTEX_ARRAY)
        (glut-unvector p) )
  ))))
(define (color l)
    (if (= (length l) 4)
      (begin 
        (glColor4f (car l) (cadr l) (caddr l) (cadddr l)) )
      )
  )
(define (list-set! l k obj) 
  (cond  ((or (< k 0) (null? l)) #f)
         ((= k 0) (set-car! l obj))   
         (else  (list-set! (cdr l) (- k 1) obj))))


(define (draw-body . args)
 (let ((body (car args)))
  (is-body body)

  (let ((R (angle->mat body.rotation))
        (x body.position)
        (h (n*v 0.5 body.width)))

  (is-vec h)
  ;(display (format "width=~a h.x=~a h.y~a \n" body.width h.x h.y ) )

  (let ((v1 (v+ x (m*v R (make-vec (- h.x) (- h.y)))))
    (v2 (v+ x (m*v R (make-vec    h.x  (- h.y)))))
    (v3 (v+ x (m*v R (make-vec    h.x     h.y ))))
    (v4 (v+ x (m*v R (make-vec (- h.x)    h.y )))))

    (is-vec v1)
    (is-vec v2)
    (is-vec v3)
    (is-vec v4)
    (if (= (length args) 2)
      (color (cadr args) ))

    ; (display (vector v1.x v1.y
    ;                    v2.x v2.y
    ;                    v3.x v3.y
    ;                    v4.x v4.y) )
    ; (newline)

    (let ((p (glut-vector 'float (vector v1.x v1.y
                       v2.x v2.y
                       v3.x v3.y
                       v4.x v4.y)) ))
     ;(glPushMatrix)
     (glVertexPointer 2  GL_FLOAT  0  p);
     (glEnableClientState GL_VERTEX_ARRAY);
     (glDrawArrays GL_LINE_LOOP  0 4);
     (glDisableClientState GL_VERTEX_ARRAY)
     ;(glPopMatrix) 
     (glut-unvector p) )

  )))
)

(define (draw-arbiter arbite)
    (is-arbiter arbite)
    ;(display (format "~a num=~a\n" arbite.body-1 arbite.num-contacts ) )
    (let* ((v (list ))
           (t '())
           (number arbite.num-contacts)
          )

    (do ((i 0 (+ i 1)))
        ((>= i arbite.num-contacts))

      (let ()

        (is-vector  arbite.contacts i)
        (is-contact arbite.contacts.i)
        (is-vec     arbite.contacts.i.position)
        (set! v (append v (list arbite.contacts.i.position.x arbite.contacts.i.position.y ) ) )
        )
      )
     (if (= number 1)
      (set! number (+ 1 number))
      (set! v (append v v))
      )
      (if (> number 0)
        (begin
          (glPushMatrix)
          ;(glColor4f 1.0 0.0 0.0 1.0)
 
          (set! t (glut-vector 'float v ))
          (glVertexPointer number GL_FLOAT  0 t  );
          (glEnableClientState GL_VERTEX_ARRAY);
          (glPointSize 10.0)
          (glDrawArrays GL_POINTS  0  number )
          (glDisableClientState GL_VERTEX_ARRAY)
          (glut-unvector t) 
          (glPopMatrix)

          )
        )
     )
    (let ((l (hashtable-ref objects-hash arbite.body-1 '() ))
          (l2 (hashtable-ref objects-hash arbite.body-2 '() ))
        )
      (if (pair? l)
          (begin
            (list-set! l 2 (- (list-ref l 2) 10))
            ;(glClear (+ GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT) )
            ;(draw-body arbite.body-1 (list 0.1 1.0 0.0 0.1) ) 
            )
        )
      (if (pair? l2)
          (begin
            (list-set! l2 2 (- (list-ref l2 2) 10))
            ;(display l2)(newline)
            ;(glClear (+ GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT) )
            ;(draw-body arbite.body-1 (list 0.1 1.0 0.0 0.1) ) 
            )
        )
    )

  )

(define (create-plane x y v m p l)

  (let ((b (create-body))
        (plane '())
        )
    (is-body b)
    (is-vec  b.width)
    (b.set (make-vec 0.24 0.2) m )
    (b.position! (make-vec x y))
    ;(b.rotation! 0.2 )
    (b.velocity! (make-vec 0.0 v))
    (b.angular-velocity! 0.0)
    (b.friction! 0.0 )
    (b.torque! 0.0)
    ;(b.force! (make-vec 10.0 10.0))
    (world.add-body b)
    (set! plane (list p b l ) )
    (hashtable-set! objects-hash b plane )
    plane
    )
)

(define (create-bullet x y v m p l)
  (let ((b (create-body))
    (bullet '()) )
    (is-body b)
    (is-vec  b.width)
    (b.set (make-vec 0.03 0.03) m )
    (b.position! (make-vec x y))
    ;(b.rotation! 0.2 )
    (b.velocity! (make-vec 0.0 v))
    (b.angular-velocity! 0.0)
    (b.friction! 0.0 )
    (b.torque! 0.0)
    ;(b.inv-mass! 0.1)
    ;(b.force! (make-vec 10.0 10.0))
    (world.add-body b)
    (set! bullet (list p b l ) )
    (hashtable-set! objects-hash b bullet )
    bullet
    )
  )

(define (init)
  (imgui-init)
  (imgui-reset-style 11)
  (imgui-disable-default-color)

  (set! bg (imgui-load-texture (string-append res-dir "images/bg2.jpg")))
  (set! me (imgui-load-texture (string-append res-dir "images/me.png")))
  (set! p1 (imgui-load-texture (string-append res-dir "images/e1.png") ))
  (set! p2 (imgui-load-texture (string-append res-dir "images/e2.png") ))
  (set! p3 (imgui-load-texture (string-append res-dir "images/e3.png") ))
  (set! shot (imgui-load-texture (string-append res-dir "images/eshot.png") ))
  (set! mplay (create-plane 0.0 -0.9 0.0 0.9 me 100 ) )
  (set! objects (list 
         mplay
         (create-plane 0.0 0.0 -0.3 0.9 p1 100 ) ;image,body,life,   
         (create-plane 0.3 0.0 -0.2 0.9 p2 100 )
         ;(create-bullet 0.0 0.6 -1.10 0.1 shot 1)   
         ; (list p3 (create-plane 0.0 0.0 0.0 0.9) )
         ; (list p2 (create-plane 0.0 0.0 0.0 0.9) )
         ))

)

(define (game)
      (glut-init (lambda()
        (glut-init-window-size 600 600)
        (init)
      ))
      (glut-set-window-title "game")
      
    
      ;(imgui-scale 1.5 1.5)
      (glut-touch-event (lambda (type x y)
          (imgui-touch-event type x y)

          ))
      (glut-mouse-event (lambda (button state)
        ;(glut-log "mouse-event")
          (imgui-mouse-event button state)))
      (glut-motion-event (lambda (x y)
            ;(glut-log "motion-event")
            (imgui-motion-event x y)
        ))
      (glut-key-event (lambda (event)
          (imgui-key-event
             (glut-event-get event 'type)
             (glut-event-get event 'keycode)
             (glut-event-get event 'char)
             (glut-event-get event 'chars))
           (if (= 4 (glut-event-get event 'keycode ))
             (begin (imgui-exit)
             (glut-exit)))
         

          (glut-log (format "event ~a" event))
          (if (= (glut-event-get event 'type) 0)
            (case (glut-event-get event 'keycode) 
              (97 (set! deltax  -0.01))
              (100 (set! deltax 0.01))
              (119 (set! deltay 0.01))
              (115 (set! deltay -0.01))
              (100 (set! deltax 0.01))
              (119 (set! deltay 0.01))
              (115 (set! deltay -0.01))
              (32  (let ((l (create-bullet x (+ y 0.12) 2.0 0.0003 shot 1)))
                      (append! objects (list l) )
                  ))
              )
            (begin 
              (set! deltax 0.0)
              (set! deltay 0.0)
              )
          ) )
      )

      (glut-display (lambda ()
         (collect)
             (imgui-render-start)

                 (glClearColor 1.0  1.0  1.0  1.0 );
                 (glClear GL_COLOR_BUFFER_BIT);
                 (set! x (+ x deltax))
                 (set! y (+ y deltay))

              

              (glPushMatrix)
                 ;(glRotatef rotation 0.0 0.0 0.1)
                 (glTranslatef 0.0 bgpos 0.0)
                 (draw-img bg (vector 
                    -1.0 -3.0
                    1.0 -3.0                              
                    -1.0 3.0
                    1.0 3.0
                  ))
                 (set! bgpos (- bgpos 0.003))
                 ;(display (format "~a\n" bgpos))
                 (if (<= bgpos -2.0)
                    (set! bgpos 2.0)
                  )
                 (glPopMatrix)

             
                ;(imgui-test)
                (imgui-set-next-window-size (imgui-make-vec2 200.0 140.0) 0)
                (imgui-begin "evilbinary" 0)
                (imgui-text (format "objects:~a" (length objects) ) )
                (imgui-text (format "my life:~a" (list-ref mplay 2) ) )
                (if (imgui-button "random" (imgui-pvec2 50.0 60.0) )
                    (append! objects (list (create-plane -0.1 0.2 -0.3 0.9 p1 100 ) 
                      (create-plane 0.2 0.4 -0.3 0.9 p2 100 ) ))
                    )
                (imgui-end)
                
                 

                 (draw-objects objects)

                 (let ((body (cadr mplay) ))
                    (is-body body)
                    ; (body.torque! 0.0)
                    ;(body.angular-velocity! 0.0)
                    (body.position! (make-vec x y))
                  )
  

                 ;(glPushMatrix)
                 (for-each draw-arbiter world.arbiters)
                 ;(glPopMatrix)


                 
                 (world.step time-step)
                 (glPushMatrix)
                 (for-each draw-body  world.bodies)
                 (for-each draw-joint world.joints)
                 (glPopMatrix)

                 

              (imgui-render-end)

          ))

      (glut-reshape (lambda(w h)
                    (imgui-resize w h)
                    (glut-log (format "reshape"))
                    (glClearDepthf 1.0)
                    (glClearColor 0.0 0.0 0.0 0.0 )
                    (glFrontFace GL_CCW);
                    (glEnable GL_BLEND);
                    (glBlendFunc GL_SRC_ALPHA  GL_ONE_MINUS_SRC_ALPHA);
                    (glViewport 0 0 w h)
                    (glMatrixMode GL_PROJECTION)
                    (glLoadIdentity)
                     ))
      (glut-main-loop)
      (imgui-exit)
      (glut-exit)
      )

(game)
