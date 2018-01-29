;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;author:evilbinary on 12/24/16.
;email:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import (net socket-ffi) (cffi cffi) (net event2-ffi) )
;;(cffi-log #t)

(define n 0)
(define buff (cffi-alloc 4096))
(define listen-event (cffi-alloc 16))

(define base (cffi-alloc 8))
(define sockaddr  (make-sockaddr-in AF_INET INADDR_ANY 8080 ))


(def-function-callback
  make-read-cb
  (int int void*) void)

(def-function-callback
  make-accept-cb
  (int int void*) void)


(define read-cb (make-read-cb
		 (lambda (fd events arg)
		   (let (( n (recv fd buff 4096 0)))
		     (if (<= n 0)
			 (begin 
			   (event-free arg)
			   (close fd))
			 (begin
			   (display (format "fd=~a msg=~a" fd (cffi-string buff)))
			   (send fd buff (cstrlen  buff) 0)
			   (cffi-set buff 0 4096)))))))

(define accept-cb (make-accept-cb
		     (lambda (sock-fd event arg-ptr)
		       (let ((client-sockaddr (cffi-alloc 16))
			     (fd 0)
			     (base arg-ptr)
			     (ev (event-new 0 -1 0 0 0)))
			 (set! fd (accept sock-fd (cffi-get-pointer client-sockaddr) 16))
			 (display (format "accept fd= ~a\n" fd))
			 (evutil-make-socket-nonblocking fd)
			 (event-assign ev base fd (+ 2 #x10) read-cb ev)
			 (event-add ev 0) ))))


(define socket-fd (socket AF_INET SOCK_STREAM 0))
(evutil-make-listen-socket-reuseable socket-fd)
(define bind-ret (bind socket-fd sockaddr 16))
(define listen-ret (listen socket-fd 100))
(if (< 0 listen-ret )
    (display (format "erro Could not create a listener!\n")))

(evutil-make-socket-nonblocking socket-fd)

(set! base (event-base-new))
(set! listen-event (event-new base socket-fd (+ 2 #x10) accept-cb base))
(event-add listen-event 0)

(event-base-dispatch base)
(event-base-free base)






