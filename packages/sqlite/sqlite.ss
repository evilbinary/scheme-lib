;;#Copyright 2016-2080 littleblue.
;;#作者:littleblue on 3/19/17.
;;#邮箱:1075112523@qq.com
;; int sqliteRun(char* , char*);

(library (sqlite sqlite)
   (export sqlite-run)
   (import (scheme) (cffi cffi))
  ;; (load-shared-object "libsqlite.so")
   (define lib (load-librarys "libsqlite.so"))
     (def-function sqlite-run
     "sqliteRun" (string string) int)
  ;; (define sqlite-run (foreign-procedure "sqliteRun" (string string) int))
)
