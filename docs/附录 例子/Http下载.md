Http下载

```scheme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-08-31 23:54:31.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;http例子

(import (net curl-ffi) (cffi cffi) (c c-ffi) )

;;(cffi-log #t)

(define curl (cffi-alloc 1024))



(def-function-callback
  make-write-callback
  (void* int int void*) int)

(curl-global-init CURL_GLOBAL_ALL)
(set! curl (curl-easy-init))
(define my-file (c-fopen "download.jpg" "wb"))

(curl-easy-setopt curl 10002 "https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/game-demo.png")
(curl-easy-setopt curl 20011
		  (make-write-callback
		   (lambda (ptr size nmemb stream)
		  
		     (display (format "callback ~a size=~a nmemb=~a stream=~a\n" ptr size nmemb stream))
		     (c-fwrite  ptr size nmemb my-file)

		     (* size nmemb))))

(define res (curl-easy-perform curl))

(if (= 0 res)
    (display "ok\n")
    (display (format "curl-easy-perform failed ~s\n"  (curl-easy-strerror res))))
(c-fclose my-file)

(curl-easy-cleanup curl)
(curl-global-cleanup)