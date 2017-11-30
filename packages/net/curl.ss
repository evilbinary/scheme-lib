;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; created by : 1481892212@qq.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net curl)
    (export
        url->html
        url->file)
    (import (scheme)
    		(cffi cffi)
            (net curl-ffi)
            (c c-ffi)
            (regex regex))

    (def-function-callback
        make-write-callback
            (void* int int void*) 
            int)

    ;; 返回html字符串
    (define (url->html url)
        (define curl #f)
        (define content "")
        (define res -1)
        (when (regex-match? "^http.+?" url)
            (set! curl (cffi-alloc 1024))
            (curl-global-init 3)
            (set! curl (curl-easy-init))
            (curl-easy-setopt curl 10002 url)
            (curl-easy-setopt curl 20011
                (make-write-callback
                    (lambda (ptr size nmemb stream)
                        (set! content (string-append content (cffi-string ptr)))
                        ;(display (format "callback ~a ~a ~a ~a\n" ptr size nmemb stream))
                        (* size nmemb))))
            (set! res (curl-easy-perform curl))
            (if (not (= 0 res))
                (display (format "curl-easy-perform failed ~s\n"  (curl-easy-strerror res))))
            (curl-easy-cleanup curl)
            (curl-global-cleanup)
            ;(cffi-free curl) 防止内存二次释放
        )
        content
    )

    ;; 保存为文件
    (define (url->file url file-name . header)
        (define curl #f)
        (define my-file #f)
        (define res -1)
        (define rst #f)
        (define slist #f)
        (when (regex-match? "^http.+?" url)
            (set! curl (cffi-alloc 1024))
            (set! my-file (c-fopen file-name "wb"))
            (curl-global-init CURL_GLOBAL_ALL)
            (set! curl (curl-easy-init))
            (curl-easy-setopt curl 10002 url)
            (unless (null? header)
                (set! slist (curl-slist-append 0 (car header)))
                (curl-easy-setopt curl CURLOPT_HTTPHEADER slist))
            (curl-easy-setopt curl 20011
                (make-write-callback
                    (lambda (ptr size nmemb stream)
                        (c-fwrite ptr size nmemb my-file)
                        (* size nmemb))))
            (set! res (curl-easy-perform curl))
            (if (= 0 res)
                (set! rst #t)
                (display (format "curl-easy-perform failed ~s\n" (curl-easy-strerror res))))
            (c-fclose my-file)
            (curl-easy-cleanup curl)
            (curl-global-cleanup)
            ;(cffi-free curl) 防止内存二次释放
        )
        rst
    )
)