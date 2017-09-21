;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; created by : 1481892212@qq.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (sqlite sqlite)
    (export 
        sqlite-name!
        sqlite-exec)
    (import (scheme)
            (cffi cffi)
            (sqlite sqlite3-ffi))

    (def-function-callback make-sql-callback (void* int void* void*) int)
    
    (define db-name "")
    
    (define (sqlite-name! name)
        (set! db-name name))

    (define bytes 
        (case (machine-type)
            ((arm32le i3nt i3osx i3le) 4)
            ((a6nt a6osx a6le) 8)
            (else 4)))

    ;; select: 返回为row的list
    ;; 其他sql: '()
    (define (sqlite-exec sql)
        (define db (cffi-alloc 1024))
        (define errmsg (cffi-alloc 32))
        (define result '())
        (if (= 1 (sqlite3-open db-name db))
            (display (format "open erro ~a\n" (sqlite3-errmsg db)))
            (begin
                (let [(dbo (cffi-get-pointer db))]
                    (if (=  1 
                            (sqlite3-exec 
                                dbo
                                sql 
                                (make-sql-callback
                                    (lambda (pro size row col)
                                        (define lst '())
                                        (let loop [(index 0)]
                                            (set! lst (cons (cffi-get-string (+ row (* bytes index))) lst))
                                            (if (< (+ 1 index) size)
                                                (loop (+ 1 index))))
                                        (set! result (cons (reverse lst) result))
                                        0
                                    )
                                )
                                0
                                errmsg))
                        (display (format "exec erro=~a\n" (cffi-string  (cffi-get-pointer errmsg))))
                    )
                    (sqlite3-close dbo)
                )
            )
        )
        (cffi-free db)
        (cffi-free errmsg)
        (reverse result)
    )
)