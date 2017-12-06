;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 2017-12-06 23:06:57.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (termios termios )
  (export cfgetospeed
  cfgetispeed
  cfsetospeed
  cfsetispeed
  tcgetattr
  tcsetattr
  tcsendbreak
  tcdrain
  tcflush
  tcflow)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libtermios.so")
   ((a6nt i3nt ta6nt ti3nt) "libtermios.dll")
   ((a6osx i3osx ta6osx ti3osx)  "libtermios.so")
   ((a6le i3le ta6le ti3le) "libtermios.so")))
 (define lib (load-librarys  lib-name ))

;;speed_t cfgetospeed(struct termios* __termios_p)
(def-function cfgetospeed
             "cfgetospeed" (void*) int)

;;speed_t cfgetispeed(struct termios* __termios_p)
(def-function cfgetispeed
             "cfgetispeed" (void*) int)

;;int cfsetospeed(struct termios* __termios_p ,speed_t __speed)
(def-function cfsetospeed
             "cfsetospeed" (void* int) int)

;;int cfsetispeed(struct termios* __termios_p ,speed_t __speed)
(def-function cfsetispeed
             "cfsetispeed" (void* int) int)

;;int tcgetattr(int __fd ,struct termios* __termios_p)
(def-function tcgetattr
             "tcgetattr" (int void*) int)

;;int tcsetattr(int __fd ,int __optional_actions ,struct termios* __termios_p)
(def-function tcsetattr
             "tcsetattr" (int int void*) int)

;;int tcsendbreak(int __fd ,int __duration)
(def-function tcsendbreak
             "tcsendbreak" (int int) int)

;;int tcdrain(int __fd)
(def-function tcdrain
             "tcdrain" (int) int)

;;int tcflush(int __fd ,int __queue_selector)
(def-function tcflush
             "tcflush" (int int) int)

;;int tcflow(int __fd ,int __action)
(def-function tcflow
             "tcflow" (int int) int)


)
