(import (web libra)
		(sqlite sqlite))
(using "spider.ss")

(sqlite-name! (string-append (get-option "app-path") "/spider.db"))
(sqlite-exec "create table if not exists ImageInfo (id int primary key not null, page int);")

(get! "/"
	 (lambda (p) (view "index")))

(get! "/spider" 
	(lambda (p)
		(define url (hashtable-ref p "key" "http://www.mm131.com/xinggan"))
		(if (eq? #f (string-index url #\_))
			(set! url (string-append url "/")))
		(default-make-json (url->id/page url (get-option "app-path")))))

(run 8080)







