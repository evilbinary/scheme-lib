;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-08-31 23:54:31.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;mysql 连接例子

(import (mysql mysql-ffi) (cffi cffi) )
;;(cffi-log #t)

(define host "127.0.0.1")
(define user "root")
(define password "root")
(define db "mysql")
(define res '())
(define row '())


(let ((con (mysql-init 0)))
  (set! con (mysql-real-connect con host user password db 3306 0 0))
  (mysql-query con "select host,user from user")
  (set! res (mysql-use-result con))
  (set! row (mysql-fetch-row res))
  (display (format "host=>~a  user=>~a\n" (cffi-get-string row) (cffi-get-string (+ row 8) )))
  (mysql-free-result res)
  (mysql-close con))
  

