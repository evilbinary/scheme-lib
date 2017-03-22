
;;(load-shared-object "sqlite.so")
;;(define ww (foreign-procedure "sqlRun" (string string) int)))
;;(ww "wa.db" "")
(import (sqlite sqlite))
(time(sqlite-run "wang.db" ""))
(sqlite-run "wang.db" "create table users(userid varchar(20) PRIMARY KEY, age int, birthday datetime);")
(sqlite-run "wang.db" "insert into users values('张三',20,'2017-7-23');")
