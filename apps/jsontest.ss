;;#Copyright 2016-2080 littleblue.
;;#作者:littleblue on 3/19/17.
;;#邮箱:1075112523@qq.com

(import (json json))
(scm->json (json (array 1 2 3)))
(define values '(2 3))
(scm->json (json (array 1 ,@values 4)))
(scm->json (json (object ("project" "foo")
  ("author" "bar"))))
(scm->json (json (object ("values" (array 234 98.56)))))
(define values '(234 98.56))
(scm->json (json (object ("values" ,values))))
