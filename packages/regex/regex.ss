;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; created by : 1481892212@qq.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (regex regex)
    (export
        regex-match?
        regex-match
        regex-match-count
        regex-matches
        regex-search
        regex-spilt
        regex-replace
        regex-replace-all
        )
    (import (scheme)
            (cffi cffi)
            (regex regex-ffi)
            (except (surfage s13 strings)
				string-for-each string-fill! string-copy 
				string->list string-copy! string-titlecase 
				string-upcase string-downcase string-hash))

    ;; 32位: 4字节; 64位: 8字节
    (define bytes 
        (case (machine-type)
            ((arm32le i3nt i3osx i3le a6le) 4)
            ((a6nt a6osx) 8)
            (else 4)))

    ;; 2 bytes为1组
    (define group (* 2 bytes))

    ;; 判断是否存在匹配内容
    (define (regex-match? pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch 1)
        (define rst #f)
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (set! err (regexec reg str nmatch pmatch 0))
                (if (not (= REG_NOMATCH err))
                    (if (not (= 0 err))
                        (begin (display (format "error ~a\n" err)))
                        (set! rst #t)
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        rst
    )

    ;; 获取最先匹配的内容列表
    ;; 正则库将表达式中的长度(如 .{3})匹配为字节长度, 所以要避免用长度来匹配中文
    (define (regex-match pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define lst '())
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (set! err (regexec reg str nmatch pmatch 0))
                (if (not (= REG_NOMATCH err))
                    (if (not (= 0 err))
                        (begin (display (format "error ~a\n" err)))
                        (let loop [(index 0)]
                            (if (>= (cffi-get-int (+ pmatch (* group index))) 0)
                                (begin
                                    (let* [ (start (cffi-get-int (+ pmatch (* group index))))
                                            (end (cffi-get-int (+ pmatch (* group index) bytes)))
                                            (bv (string->utf8 str))
                                            (len (- end start))
                                            (buff (make-bytevector len))]
                                        (bytevector-copy! bv start buff 0 len)
                                        (set! lst (cons (utf8->string buff) lst))
                                    )
                                    (if (< (+ 1 index) nmatch)
                                        (loop (+ index 1))
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        (reverse lst)
    )

    ;; 获取内容匹配数量
    (define (regex-match-count pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define rst 0)
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (let loop [(text str)]
                    (set! err (regexec reg text nmatch pmatch 0))
                    (if (not (= REG_NOMATCH err))
                        (if (not (= 0 err))
                            (begin (display (format "error ~a\n" err)))
                            (begin
                                (set! rst (+ 1 rst))
                                (let* [ (end (cffi-get-int (+ pmatch (* group 0) bytes)))
                                        (bv (string->utf8 text))
                                        (len (- (bytevector-length bv) end))
                                        (buff (make-bytevector len))]
                                    (bytevector-copy! bv end buff 0 len)
                                    (loop (utf8->string buff))
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        rst
    )

    ;; 获取全部匹配列表
    (define (regex-matches pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define lst '())
        (define rst '())
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (let loop [(text str)]
                    (set! err (regexec reg text nmatch pmatch 0))
                    (if (not (= REG_NOMATCH err))
                        (if (not (= 0 err))
                            (begin (display (format "error ~a\n" err)))
                            (begin
                                (let lp [(index 0)]
                                    (if (>= (cffi-get-int (+ pmatch (* group index))) 0)
                                        (begin
                                            (let* [ (start (cffi-get-int (+ pmatch (* group index))))
                                                    (end (cffi-get-int (+ pmatch (* group index) bytes)))
                                                    (bv (string->utf8 text))
                                                    (len (- end start))
                                                    (buff (make-bytevector len)) ]
                                                (bytevector-copy! bv start buff 0 len)
                                                (set! lst (cons (utf8->string buff) lst))
                                            )
                                            (if (< (+ 1 index) nmatch)
                                                (lp (+ index 1))
                                            )
                                        )
                                    )
                                )
                                (set! rst (cons (reverse lst) rst))
                                (set! lst '())
                                (let* [ (end (cffi-get-int (+ pmatch (* group 0) bytes)))
                                        (bv (string->utf8 text))
                                        (len (- (bytevector-length bv) end))
                                        (buff (make-bytevector len)) ]
                                    (bytevector-copy! bv end buff 0 len)
                                    (loop (utf8->string buff))
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        (reverse rst)
    )

    ;; 获取匹配内容的起止位置
    ;; 无匹配返回#f
    ;; 中文则返回的字节下标
    (define (regex-search pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define rst #f)
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (set! err (regexec reg str nmatch pmatch 0))
                (if (not (= REG_NOMATCH err))
                    (if (not (= 0 err))
                        (begin (display (format "error ~a\n" err)))
                        (if (>= (cffi-get-int (+ pmatch (* group 0))) 0)
                            (begin
                                (let [(start (cffi-get-int (+ pmatch (* group 0))))
                                        (end (cffi-get-int (+ pmatch (* group 0) bytes)))]
                                    (set! rst (cons start end))
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        rst
    )

    ;; 切割字符串
    (define (regex-spilt pattern str)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define lst '())
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (let loop [(text str)]
                    (set! err (regexec reg text nmatch pmatch 0))
                    (if (not (= REG_NOMATCH err))
                        (if (not (= 0 err))
                            (begin (display (format "error ~a\n" err)))
                            (if (>= (cffi-get-int (+ pmatch (* group 0))) 0)
                                (begin
                                    (let* [ (start (cffi-get-int (+ pmatch (* group 0))))
                                            (end (cffi-get-int (+ pmatch (* group 0) bytes)))
                                            (bv (string->utf8 text))
                                            (len1 (- start 0))
                                            (len2 (- (bytevector-length bv) end))
                                            (buff1 (make-bytevector len1))
                                            (buff2 (make-bytevector len2)) ]
                                        (bytevector-copy! bv 0 buff1 0 len1)
                                        (bytevector-copy! bv end buff2 0 len2)
                                        (set! lst (cons (utf8->string buff1) lst))
                                        (loop (utf8->string buff2))
                                    )
                                )
                            )
                        )
                        (set! lst (cons text lst))
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        (reverse lst)
    )

    ;; 替换第一个匹配项
    (define (regex-replace pattern str rep)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define rst str)
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (set! err (regexec reg str nmatch pmatch 0))
                (if (not (= REG_NOMATCH err))
                    (if (not (= 0 err))
                        (begin (display (format "error ~a\n" err)))
                        (if (>= (cffi-get-int (+ pmatch (* group 0))) 0)
                            (begin
                                (let* [ (start (cffi-get-int (+ pmatch (* group 0))))
                                        (end (cffi-get-int (+ pmatch (* group 0) bytes)))
                                        (bv (string->utf8 str))
                                        (len1 (- start 0))
                                        (len2 (- (bytevector-length bv) end))
                                        (buff1 (make-bytevector len1))
                                        (buff2 (make-bytevector len2)) ]
                                    (bytevector-copy! bv 0 buff1 0 len1)
                                    (bytevector-copy! bv end buff2 0 len2)
                                    (set! rst (string-append (utf8->string buff1) rep (utf8->string buff2)))
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        rst
    )

    ;; 替换所有匹配项
    ;; 如果rep也符合pattern, 则无法返回正常对象
    (define (regex-replace-all pattern str rep)
        (define reg (cffi-alloc 100))
        (define pmatch (cffi-alloc 100))
        (define err 0)
        (define err-buf (cffi-alloc 1024))
        (define nmatch (+ 1 
                          (min (if (number? (string-count pattern #\()) (string-count pattern #\() 0)
                               (if (number? (string-count pattern #\))) (string-count pattern #\)) 0))))
        (define rst str)
        (if (< (regcomp reg pattern REG_EXTENDED) 0)
            (begin
                (regerror err reg err-buf 1024)
                (display (format "error ~a\n" (cffi-string err-buf))))       
            (begin
                (let loop [(text rst)]
                    (set! err (regexec reg text nmatch pmatch 0))
                    (if (not (= REG_NOMATCH err))
                        (if (not (= 0 err))
                            (begin (display (format "error ~a\n" err)))
                            (if (>= (cffi-get-int (+ pmatch (* group 0))) 0)
                                (begin
                                    (let* [ (start (cffi-get-int (+ pmatch (* group 0))))
                                            (end (cffi-get-int (+ pmatch (* group 0) bytes)))
                                            (bv (string->utf8 text))
                                            (len1 (- start 0))
                                            (len2 (- (bytevector-length bv) end))
                                            (buff1 (make-bytevector len1))
                                            (buff2 (make-bytevector len2)) ]
                                        (bytevector-copy! bv 0 buff1 0 len1)
                                        (bytevector-copy! bv end buff2 0 len2)
                                        (set! rst (string-append (utf8->string buff1) rep (utf8->string buff2)))
                                    )
                                    (loop rst)
                                )
                            )
                        )
                    )
                )
            )
        )
        (regfree reg)
        (cffi-free reg)
        (cffi-free pmatch)
        (cffi-free err-buf)
        rst
    )
)