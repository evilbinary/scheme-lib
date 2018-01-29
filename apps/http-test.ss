;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;author:evilbinary on 2017-08-31 23:54:31.
;email:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;http例子

(import (net curl-ffi) (cffi cffi) )

;;(cffi-log #t)

(define curl (cffi-alloc 1024))



(def-function-callback
  make-write-callback
  (void* int int void*) int)

(curl-global-init 3)
(set! curl (curl-easy-init))
(curl-easy-setopt curl 10002 "http://evilbinary.org/")
(curl-easy-setopt curl 20011
		  (make-write-callback
		   (lambda (ptr size nmemb stream)
		     (display (cffi-string ptr))
		     (display (format "callback ~a ~a ~a ~a\n" ptr size nmemb stream))
		     (* size nmemb))))

(define res (curl-easy-perform curl))

(if (= 0 res)
    (display "ok\n")
    (display (format "curl-easy-perform failed ~s\n"  (curl-easy-strerror res))))

(curl-easy-cleanup curl)
(curl-global-cleanup)



