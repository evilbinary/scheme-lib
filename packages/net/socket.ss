;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-04-29 00:03:30.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net socket) 
  (export
   SOCK_STREAM     
   SOCK_DGRAM      
   SOCK_RAW      
   SOCK_RDM        
   SOCK_SEQPACKET
   SOCK_PACKET
   AF_INET
   INADDR_ANY
   make-sockaddr-in
   
   close
   socket:bind
   socket:close
   bind
   connect
   listen
   accept
   socket:listen
   socket:accept
   getsockname
   getpeername
   socketpair
   shutdown
   setsockopt
   getsockopt
   sendmsg
   recvmsg
   send
   recv
   sendto
   recvfrom
   inet-addr
   ntohl
   make-socket
   make-fd-input-port
   make-fd-output-port
   
   )

 (import (scheme) (utils libutil) (cffi cffi) (net socket-ffi) )



 (define (make-fd-input-port fd)
  (let ((buf (cffi-alloc 8)))
    (make-input-port (lambda (msg . args)
		     (record-case
		      (cons msg args)
		      [block-read (p s n) (block-read fd s n)]
		      [read-char (p)
				 (let* ((c (cread fd buf 1))
					(char (cffi-get-char buf)))
				   (if (> c -1 )
				       (if (= 0 c)
					   (and  (close fd) char)
					   char)
				       (eof-object)
				       ))
				 ]
		      [close-port (p)
				  (close fd)
				  (mark-port-closed! p)
				  (cffi-free buf)
				  ]
		      [else (assertion-violationf 'make-fd-input-port
						  "operation ~s not handled"
						  msg)]
		      ))
		     "")))


 ;; (define (make-fd-output-port fd)      
 ;;   (make-custom-binary-output-port
 ;;      "fd-output-port"
 ;;      (lambda (bv start n)
 ;; 	(display bv)
 ;; 	(display " n=")
 ;; 	(display n)
 ;; 	(display " b=>")
 ;; 	(display (cstrlen bv))
	
 ;;        (cwrite fd bv  (cstrlen bv) )
 ;; 	n
 ;; 	)
 ;;      #f #f
 ;;      (lambda ()
 ;; 	(display "close--->")
 ;;        (close fd)
 ;; 	)
 ;;      )
  
 ;;   )
 
  (define (make-fd-output-port fd)
  (let ((buf (cffi-alloc 8)))
    (make-output-port (lambda (msg . args)
		     ;;(printf "msg=~a args=~a\n" msg args)
  		     (record-case
  		      (cons msg args)
  		      [block-write (p s n)
				   (let ((len (bytevector-length (string->utf8 s))))
				     ;;(printf "size=~a len=~a fd=~a \n" n len fd)
				     (cwrite-all fd s len)
				     n
				   )
  				   ]
  		      [write-char (c p)
				  ;;(printf "c=~a p=~a ~x\n" c p (char->integer c))
				  (cffi-set-char buf c)
				  (cwrite fd buf 1)
  				 ]
  		      [close-port (p)
				  ;;(printf "close fd =~a\n" fd )
				  (close fd)
				  (cffi-free buf)
				  (set-port-output-size! p 0)
				  (mark-port-closed! p)
				  ]
  		      [else (assertion-violationf 'make-fd-output-port
  						  "operation ~s not handled"
  						  msg)]
  		      )  
  		     )
  		   "")))
 
  (define-syntax make-socket
    (syntax-rules ()
      [(_ family type port)
       (let* ((socket-fd (socket family type 0))
	      (server-addr (make-sockaddr-in family INADDR_ANY port ))
	      (i (cffi-alloc 32)))
	 ;;(setsockopt socket-fd SOL_SOCKET SO_REUSEPORT i 32)
	 (cffi-free i)
	 (list socket-fd server-addr))]
      [(_ family type port addr)
       (let* ((socket-fd (socket family type 0))
	      (server-addr (make-sockaddr-in family addr port ))
	      (i (cffi-alloc 32)))
	 ;;(setsockopt socket-fd SOL_SOCKET SO_REUSEPORT i 32)
	 (cffi-free i)
	 (list socket-fd server-addr))]
     ))
     
 (define-syntax socket:accept
   (syntax-rules ()
     [(_ socket addr addr-len)
      (accept (car socket) addr addr-len)]
     [(_ socket )
      (let ((ret (accept (car socket) 0 0)))
	ret)
		]))

  (define-syntax socket:bind
    (syntax-rules ()
      [(_ socket)
       (bind (car socket) (car (cdr socket)) 16 ) ]))


  (define-syntax socket:listen
    (syntax-rules ()
      [(_ socket )
       (listen (car socket)  10)]
      [(_ socket back-log)
       (listen (car socket) back-log)]
      ))
 
  (define (socket:close socket)
    (close (car socket) ))
  
)
