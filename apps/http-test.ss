;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-08-31 23:54:31.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;http例子

(import (net curl-ffi) (cffi cffi) )

;;(cffi-log #t)

(define curl (cffi-alloc 1024))

(curl-global-init 3)
(set! curl (curl-easy-init))
(curl-easy-setopt curl 10002 "http://evilbinary.org/")
(define res (curl-easy-perform curl))

(if (= 0 res)
    (display "ok\n")
    (display (format "curl-easy-perform failed ~s\n"  (curl-easy-strerror res))))

(curl-easy-cleanup curl)
(curl-global-cleanup)



