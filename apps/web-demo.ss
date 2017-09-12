(load "../packages/web/libra.scm")

(get! "/"
	 (lambda (p) (view "../apps/index.html")))

(post! "/" 
	(lambda (p) (default-make-response "POST request")))

(get! "/blog/:user/:age" 
	(lambda (p)
		(define content (string-append "p是储存所有参数(路由/get请求)的hashtable\n" "User " (hashtable-ref p "user" "") ";Ages " (hashtable-ref p "age" "")))
		(hashtable-set! p "content" content)
		(default-make-json p)))

(run 8080)
