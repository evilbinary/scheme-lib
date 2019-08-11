;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net curl)
  (export url->html url->file)
  (import (scheme) (cffi cffi) (net curl-ffi) (c c-ffi)
    (regex regex))
  (def-function-callback
    make-write-callback
    (void* int int void*)
    int)
  (define (url->html url)
    (define curl #f)
    (define content "")
    (define res -1)
    (when (regex-match? "^http.+?" url)
      (set! curl (cffi-alloc 1024))
      (curl-global-init 3)
      (set! curl (curl-easy-init))
      (curl-easy-setopt curl 10002 url)
      (curl-easy-setopt
        curl
        20011
        (make-write-callback
          (lambda (ptr size nmemb stream)
            (set! content (string-append content (cffi-string ptr)))
            (* size nmemb))))
      (set! res (curl-easy-perform curl))
      (if (not (= 0 res))
          (display
            (format
              "curl-easy-perform failed ~s\n"
              (curl-easy-strerror res))))
      (curl-easy-cleanup curl)
      (curl-global-cleanup))
    content)
  (define (url->file path-name url)
    (printf "url->file ~a\n" url)
    (let ([my-file (c-fopen path-name "wb")]
          [curl (curl-easy-init)]
          [res -1]
          [len 0])
      (curl-easy-setopt curl 10002 url)
      (curl-easy-setopt
        curl
        20011
        (make-write-callback
          (lambda (ptr size nmemb stream)
            (set! len (+ len size))
            (c-fwrite ptr size nmemb my-file)
            (* size nmemb))))
      (set! res (curl-easy-perform curl))
      (if (= 0 res)
          (printf "down  finish ~a\n" url)
          (display
            (format
              "curl-easy-perform failed ~s\n"
              (curl-easy-strerror res))))
      (c-fclose my-file)
      (if (<= len 0)
          (begin
            (printf "download fail ~a remove it\n" url)
            (c-remove path-name)
            (curl-easy-cleanup curl)
            "")
          (begin (curl-easy-cleanup curl) path-name)))))

