;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "../packages/slib/slib.ss")
(import (net socket) (net socket-ffi ) (cffi cffi) )

(require 'http)
(require 'cgi)
(require 'array)

(define port 8080)
(define socket (make-socket AF_INET SOCK_STREAM port ))

(socket:bind socket)
(socket:listen socket)

(define serve-proc
  (lambda (request-line query-string header)
    (printf "HTTP=>%a\n" request-line)
    (printf "path=%a\n" (cadr request-line))
    
    (string-append
		 (http:content
		  '(("Content-Type" . "text/html"))
		  (html:head "hello" "")
		  "<div >test</div>"
		  "<input type='button' text='butt'>button</input>"
		  (apply html:body
			(list (sprintf #f "hello")))))
    )
   
  )


(let loop ((port (socket:accept socket) ) )
  (if (>= port 0)
      (begin 
	(let ((iport (make-fd-input-port port))
	      (oport (make-fd-output-port port)))
	  (http:serve-query serve-proc iport oport)
	  (close-port iport)
	  (close-port oport)
	  (close port)
	  )
	(loop  (socket:accept socket))
	))
  )

(socket:close socket)

;;(printf "hello,world\n")
