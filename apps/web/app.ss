(import (web libra)
		(sqlite sqlite))
(using "spider.ss")

(sqlite-name! (string-append (get-option "app-path") "/spider.db"))
(sqlite-exec "create table if not exists ImageInfo (id int primary key not null, page int);")

(get! "/"
	 (lambda (p) 
	 	(if (and (hashtable-contains? p "id") (hashtable-contains? p "page"))
		 	(id/page->load (hashtable-ref p "id" "0") (hashtable-ref p "page" "-1") (get-option "app-path")))
	 	(view "index")))

(get! "/spider" 
	(lambda (p)
		(define url (hashtable-ref p "key" "http://www.mm131.com/xinggan"))
		(if (eq? #f (string-index url #\_))
			(set! url (string-append url "/")))
		(default-make-json (url->id/page url (get-option "app-path")))))

(run 8080)







