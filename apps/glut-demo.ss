;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (glut) (gles1) )
(define (glut-demo)
      (glut-init)

      (glut-touch-event (lambda (type x y)
          (glut-log (format "type ~a ~a ~a" type x y ))
          ))
      (glut-key-event (lambda (event)
          (glut-log (format "event ~a" event))
            
          ))

      (glut-display (lambda ()
              (glut-log (format "display"))
              (glClear GL_COLOR_BUFFER_BIT);
          ))
      (glut-reshape (lambda(w h)
                    (glut-log (format "reshape"))
                     ))
      (glut-main-loop)
      (glut-exit)
      )

(glut-demo)
