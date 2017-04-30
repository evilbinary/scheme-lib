;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-04-29 00:03:30.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net socket-ffi ) 
  (export
   SOCK_STREAM     
   SOCK_DGRAM      
   SOCK_RAW      
   SOCK_RDM        
   SOCK_SEQPACKET
   SOCK_PACKET
   AF_INET
   INADDR_ANY
   SOL_SOCKET
   SO_REUSEADDR
   make-sockaddr-in

   cfdopen
   cread
   cwrite
   cstrlen
   cwrite-all
   
   close
   socket
   bind
   connect
   listen
   accept
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
   recvfrom)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libsocket.so")
   ((a6nt i3nt) "libsocket.dll")
   ((a6osx i3osx)  "libsocket.so")
   ((a6le i3le) "libsocket.so")))
 (define lib (load-librarys  lib-name ))


 (define AF_INET 2 )

 (define SOCK_STREAM      1)
 (define SOCK_DGRAM       2)
 (define SOCK_RAW         3)
 (define SOCK_RDM         4)
 (define SOCK_SEQPACKET   5)
 (define SOCK_PACKET      10)
 (define INADDR_ANY 0)

 (define SOL_SOCKET 0 )
 (define SO_REUSEADDR   #x0004)

 (def-function make-sockaddr-in
   "make_sockaddr_in" (int int int) void*)

 (def-function close
   "_close" (int) int)

  (def-function cstrlen
   "_strlen" (void*) int)


 (def-function cfdopen
    "_fdopen" (int string) int)
  
 (def-function cread
   "_read" (int void* int) int)

  (def-function cwrite
    "_write" (int void* int) int)

  (def-function cwrite-all
    "_write_all" (int void*) int)
    
;;int socket(int  ,int  ,int )
(def-function socket
             "_socket" (int int int) int)

;;int bind(int  ,struct sockaddr*  ,int )
(def-function bind
             "_bind" (int void* int) int)

;;int connect(int  ,struct sockaddr*  ,socklen_t )
(def-function connect
             "_connect" (int void* socklen_t) int)

;;int listen(int  ,int )
(def-function listen
             "_listen" (int int) int)

;;int accept(int  ,struct sockaddr*  ,socklen_t* )
(def-function accept
             "_accept" (int void* void*) int)

;;int getsockname(int  ,struct sockaddr*  ,socklen_t* )
(def-function getsockname
             "_getsockname" (int void* void*) int)

;;int getpeername(int  ,struct sockaddr*  ,socklen_t* )
(def-function getpeername
             "_getpeername" (int void* void*) int)

;;int socketpair(int  ,int  ,int  ,int* )
(def-function socketpair
             "_socketpair" (int int int void*) int)

;;int shutdown(int  ,int )
(def-function shutdown
             "_shutdown" (int int) int)

;;int setsockopt(int  ,int  ,int  ,void*  ,socklen_t )
(def-function setsockopt
             "_setsockopt" (int int int void* int) int)

;;int getsockopt(int  ,int  ,int  ,void*  ,socklen_t* )
(def-function getsockopt
             "_getsockopt" (int int int void* void*) int)

;;int sendmsg(int  ,struct msghdr*  ,unsigned int )
(def-function sendmsg
             "_sendmsg" (int void* int) int)

;;int recvmsg(int  ,struct msghdr*  ,unsigned int )
(def-function recvmsg
             "_recvmsg" (int void* int) int)

;;ssize_t send(int  ,void*  ,size_t  ,unsigned int )
(def-function send
             "_send" (int void* int int) int)

;;ssize_t recv(int  ,void*  ,size_t  ,unsigned int )
(def-function recv
             "_recv" (int void* int int) int)

;;ssize_t sendto(int  ,void*  ,size_t  ,int  ,struct sockaddr*  ,socklen_t )
(def-function sendto
             "_sendto" (int void* int int void* socklen_t) int)

;;ssize_t recvfrom(int  ,void*  ,size_t  ,unsigned int  ,struct sockaddr*  ,socklen_t* )
(def-function recvfrom
             "_recvfrom" (int void* int int void* void*) int)


)
