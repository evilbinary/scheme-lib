(import (web libra)
		(sqlite sqlite))
(using "spider.ss")

(sqlite-name! (string-append (get-option "app-path") "/spider.db"))
(sqlite-exec "create table if not exists ImageInfo (id int primary key not null, page int);")

(get! "/"
	 (lambda (p) 
	 	(if (and (params-ref p "id") (params-ref p "page"))
		 	(id/page->load (params-ref p "id") (params-ref p "page") (get-option "app-path")))
	 	(view "index")))

(get! "/spider" 
	(lambda (p)
		(define url (params-ref p "key" "http://www.mm131.com/xinggan"))
		(define type (params-ref p "type" "xinggan"))
		(if (eq? #f (string-index url #\_))
			(set! url (string-append url "/")))
		(default-make-json (url->id/page url type (get-option "app-path")))))

(run 8080)







