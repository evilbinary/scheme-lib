;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui utils)
  (export
    add-event
    loop-event)

  (import (scheme))

  (define-syntax add-event
    (syntax-rules ()
      ((_ events args ...)
      (set! events (append events (list args ...)))
      )))

  (define-syntax loop-event
     (syntax-rules ()
      ((_ events args ...)
        (let loop ((e events))
          (if (pair? e)
            (begin 
              (if (procedure? (car e))
                ((car e )  args ...))
              (loop (cdr e)) )
          ))
      )))
  
)