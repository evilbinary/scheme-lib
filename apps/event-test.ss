;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import (net socket-ffi) (cffi cffi) (net event2-ffi) )
;;(cffi-log #t)

(define socket-fd 0)
(define n 0)
(define buff (cffi-alloc 4096))

(define base (cffi-alloc 4))
(define listener (cffi-alloc 4))

(set! base (event-base-new))

(define sockaddr  (make-sockaddr-in AF_INET INADDR_ANY 8080 ))

(def-function-callback
  make-listener-cb
  (void* int void* int void*) void)

(def-function-callback
  make-write-cb
  (void*  void*) void)


(def-function-callback
  make-read-cb
  (void*  void*) void)

(def-function-callback
  make-conn-cb
  (void* int void*) void)


(define read-cb (make-read-cb
		  (lambda (bev user-data)
		    (let ((input (bufferevent-get-input bev))
			  (len 0))
		      (set! len (evbuffer-get-length input))
		      (display (format "inputlen ~a\n"  len))
		      (display (format "~s\n" (cffi-string (evbuffer-pullup input len) )))
		      ;;(bufferevent-free bev)
		      ))))
		    

(define write-cb (make-write-cb
		  (lambda (bev user-data)
		    (let ((output (bufferevent-get-output bev)))
		      (if (= 0 (evbuffer-get-length output))
			  (display "replay\n")
			  (bufferevent-free bev)))
		    )))


(define conn-cb (make-write-cb
		  (lambda (bev event user-data)
		    (display (format "event=~a\n" event))
		    (bufferevent-free bev)
		    )))
		

(define listener-cb (make-listener-cb
		     (lambda (listener-ptr fd sockaddr-ptr socklen ptr)
		       (let ((bev (bufferevent-socket-new base fd 1)))
			 (bufferevent-setcb bev read-cb write-cb conn-cb 0)
			 (bufferevent-enable bev 4)
			 (bufferevent-enable bev 2)
			 (bufferevent-write bev "hello" 5)
			 (display "listener\n"))
		       )))


(set! listener (evconnlistener-new-bind  base listener-cb base 10 -1 sockaddr 16))
(if (= 0 listener )
    (display (format "erro Could not create a listener!\n")))
;;(define signal-event (evsignal-new base SIGINT signal-cb base ))
(event-base-dispatch base)
(evconnlistener-free listener)
(event-base-free base)






