;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net socket-ffi)
  (export SOCK_STREAM SOCK_DGRAM SOCK_RAW SOCK_RDM
   SOCK_SEQPACKET SOCK_PACKET AF_INET INADDR_ANY SOL_SOCKET
   SO_REUSEADDR SO_REUSEPORT SO_SNDBUF SO_RCVBUF SO_SNDLOWAT
   SO_RCVLOWAT SO_SNDTIMEO SO_RCVTIMEO SO_ERROR SO_TYPE
   make-sockaddr-in cfdopen cread cwrite cstrlen cwrite-all
   inet-addr ntohl close socket bind connect listen accept
   getsockname getpeername socketpair shutdown setsockopt
   getsockopt sendmsg recvmsg send recv sendto recvfrom)
  (import (scheme) (utils libutil) (cffi cffi))
  (load-librarys "libsocket")
  (define AF_INET 2)
  (define SOCK_STREAM 1)
  (define SOCK_DGRAM 2)
  (define SOCK_RAW 3)
  (define SOCK_RDM 4)
  (define SOCK_SEQPACKET 5)
  (define SOCK_PACKET 10)
  (define INADDR_ANY 0)
  (define SOL_SOCKET 0)
  (define SO_REUSEADDR 4)
  (define SO_REUSEPORT 512)
  (define SO_SNDBUF 4097)
  (define SO_RCVBUF 4098)
  (define SO_SNDLOWAT 4099)
  (define SO_RCVLOWAT 4100)
  (define SO_SNDTIMEO 4101)
  (define SO_RCVTIMEO 4102)
  (define SO_ERROR 4103)
  (define SO_TYPE 4104)
  (def-function ntohl "_ntohl" (uint) uint)
  (def-function inet-addr "_inet_addr" (string) int)
  (def-function
    make-sockaddr-in
    "make_sockaddr_in"
    (int int int)
    void*)
  (def-function close "_close" (int) int)
  (def-function cstrlen "_strlen" (void*) int)
  (def-function cfdopen "_fdopen" (int string) int)
  (def-function cread "_read" (int void* int) int)
  (def-function cwrite "_write" (int void* int) int)
  (def-function cwrite-all "_write_all" (int void* int) int)
  (def-function socket "_socket" (int int int) int)
  (def-function bind "_bind" (int void* int) int)
  (def-function connect "_connect" (int void* int) int)
  (def-function listen "_listen" (int int) int)
  (def-function accept "_accept" (int void* void*) int)
  (def-function
    getsockname
    "_getsockname"
    (int void* void*)
    int)
  (def-function
    getpeername
    "_getpeername"
    (int void* void*)
    int)
  (def-function
    socketpair
    "_socketpair"
    (int int int void*)
    int)
  (def-function shutdown "_shutdown" (int int) int)
  (def-function
    setsockopt
    "_setsockopt"
    (int int int void* int)
    int)
  (def-function
    getsockopt
    "_getsockopt"
    (int int int void* void*)
    int)
  (def-function sendmsg "_sendmsg" (int void* int) int)
  (def-function recvmsg "_recvmsg" (int void* int) int)
  (def-function send "_send" (int void* int int) int)
  (def-function recv "_recv" (int void* int int) int)
  (def-function
    sendto
    "_sendto"
    (int void* int int void* socklen_t)
    int)
  (def-function
    recvfrom
    "_recvfrom"
    (int void* int int void* void*)
    int))

