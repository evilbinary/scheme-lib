(import (web libra))

(get! "/"
	 (lambda (p) (default-make-response "GET request")))

(post! "/" 
	(lambda (p) (default-make-response "POST request")))

(get! "/blog/:user/:age" 
	(lambda (p)
		(define content (string-append "p是储存所有参数(路由/请求)的关联表; " "User: " (params-ref p "user" "") ",Ages: " (params-ref p "age" "")))
		(default-make-json (cons (cons "content" content) p))))

(run 8080)
