;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-08-31 23:54:31.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;sqlite 连接例子

(import (sqlite sqlite3-ffi) (cffi cffi) )

;;(cffi-log #t)

(define db-name "./test.db")
(define db (cffi-alloc 1024))
(define sql "create table healthinfo ( 
           sid int primary key not null,
           name text not null,
           ishealth char(4) not null);")

(define errmsg (cffi-alloc 32))

(if (= 1 (sqlite3-open db-name db))
    (display (format "open erro ~a\n" (sqlite3-errmsg db))))
(define dbo (cffi-get-pointer db))

(if (= 1 (sqlite3-exec dbo sql 0 0  errmsg))
    (display (format "exec erro=~a\n" (cffi-string  (cffi-get-pointer errmsg)))))


(define sql2  "insert into healthinfo (sid, name, ishealth) values (201601001, 'xiaowang', 'yes');")

(if (= 1 (sqlite3-exec dbo sql2 0 0  errmsg))
    (display (format "exec erro=~a\n" (cffi-string  (cffi-get-pointer errmsg)))))


(sqlite3-close dbo)


