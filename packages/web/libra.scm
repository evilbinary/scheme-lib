;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; web Lib 
;; created by : 1481892212@qq.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(load "../packages/slib/slib.ss")
(import (scheme)
		(except (surfage s13 strings)
				string-for-each string-fill! string-copy 
				string->list string-copy! string-titlecase 
				string-upcase string-downcase string-hash)
		(cffi cffi) 
		(net socket) (net socket-ffi ) 
		(regex regex-ffi))
;; slib feature
(require 'http)
(require 'cgi)
(require 'array)


;; 定义http方法函数
(define (get! url handler) (router! "get" url handler))
(define (post! url handler) (router! "post" url handler))
;; (define (put! url handler) (route! 'put url handler))
;; (define (delete! url handler) (route! 'delete url handler))


;; 定义web服务器启动函数
(define (run lisen-port)
	(let [(server (make-socket AF_INET SOCK_STREAM lisen-port))]
		(socket:bind server)
		(socket:listen server)
		(printf "Start Libra Web App\n")
		(let loop ((port (socket:accept server)))
			(if (>= port 0)
				(begin
					(let ((iport (make-fd-input-port port)) 
							(oport (make-fd-output-port port)))
						;; 指定框架入口 serve-proc
						(http:serve-query serve-proc iport oport)
						(close-port iport)
						(close-port oport)
						(close port))
					(loop (socket:accept server)))))
		(socket:close server)))


;; http response maker
(define (default-make-response html)
	(http:content
		'(("Content-Type" . "text/html"))
			html))

;; 路由哈希表
(define router-handler (make-hashtable string-hash string=?))

;; 定义路由函数
(define (router! method url handler)
	;; url 转化成 regex和key-list
	(define keys/reg (cons #f url))
	(if (number? (string-index url #\:))
		(set! keys/reg (url->keys/reg url)))
	(hashtable-set! router-handler (string-append method " " (cdr keys/reg)) (cons (car keys/reg) handler))
)

;; 从请求参数字符串中获取参数
;; 无则返回#f
(define (query->key query-string key)
	(if (not (string? query-string))
		#f
		(let [(index (string-contains query-string (string-append key "=")))]
			(if (eq? #f index)
				#f
				(let [(str (substring query-string 
								(+ (string-length key) 1 index) 
								(string-length query-string)))]
					(if (eq? #f (string-index str #\&))
						str
						(substring str 0 (string-index str #\&))))))))

;; 从 hashtable 中获取对应keys/handlder
(define (request->keys/handler request-line query-string)
	(let  [(method (car request-line)) (router (url->router (cadr request-line)))]
		(if (eq? #f router)
			(cons #f #f)
			(router->keys/handler (string-append (symbol->string method) " " router) query-string)))
)  

;; 从request中找到纯净的路由
(define (url->router url)
	(if (string? url)
		(if (eq? #f (string-index url #\?))
			url
			(substring url 0 (string-index url #\?)))
		#f))

;; 分析url, 获取路由正则和参数名称list
(define (url->keys/reg url)
	(libra-regex-path url))

;; 遍历路由表，获取对应的路由的keys/handler, 默认 '(#f . #f)
(define (router->keys/handler router query)
	(define router-vector (hashtable-keys router-handler))
	(define router-length (vector-length router-vector))
	(define keys/handler (cons #f #f))
	(define keys (libra-regex-query query))
	(let loop ((index 0))
		(begin
			(let [(reg-router (vector-ref router-vector index))]
				;; (printf (format "~a\n" reg-router))
				(if (number? (string-index reg-router #\?))
					(begin
						(let ((values (libra-regex-router reg-router router)))
							(if (not (null? values))
								(begin
									(let ((names/handler (hashtable-ref router-handler reg-router '(#f . #f))))
										(map (lambda (name value) (hashtable-set! keys name value)) (car names/handler) values)
										(set! keys/handler (cons keys (cdr names/handler)))
									)
								)
							)
						)
					)
					(if (equal? router reg-router)
						(set! keys/handler (cons keys (cdr (hashtable-ref router-handler router '(#f . #f))))))))
			(if (and (< index (- router-length 1)) (equal? keys/handler '(#f . #f)))
				(loop (+ 1 index))
			)
		)
	)
	keys/handler
)

;; 匹配路由和动态里路，返回参数列表
(define (libra-regex-router router-reg str)
	(define reg (cffi-alloc 100))
	(define pmatch (cffi-alloc 100))
	(define err 0)
	(define err-buf (cffi-alloc 1024))
	(define pattern router-reg)
	(define nmatch (+ (string-count router-reg #\?) 1))
	(define result '())
	;;(cffi-log #t)
	(if (< (regcomp reg pattern REG_EXTENDED) 0)
		(begin
			(regerror err reg err-buf 1024)
			(display (format "error ~a\n" (cffi-string err-buf)))
		)       
		(begin
			(set! err (regexec reg str nmatch pmatch 0))
			(if (not (= REG_NOMATCH err))
				(if (not (= 0 err))
					(begin (display (format "error ~a\n" err)))
					(let loop ((index 1))
						;; (+ pmatch (* 结构体大小/8  index) 结构体偏移/4)
						;; (printf "so1:~d, eo2:~d, str: ~a  \n" (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4)) (substring str (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4))))
						(let ((start (cffi-get-int (+ pmatch (* 8 index)))) 
								(end (cffi-get-int (+ pmatch (* 8 index) 4))))
							(set! result (cons (substring str start end) result))
						)
						(if (< index (- nmatch 1))
							(loop (+ 1 index))
						)
					)
				)
			)
		)
	)
	(regfree reg)
	(cffi-free pmatch)
	(reverse result) 
)

;; 获取动态路由的参数列表和正则表示
(define (libra-regex-path str)
	(define reg (cffi-alloc 100))
	(define pmatch (cffi-alloc 100))
	(define err 0)
	(define err-buf (cffi-alloc 1024))
	(define pattern "/:([^\\/]+)")
	(define nmatch (+ (string-count str #\:) 1))
	(define result '())
	(define replace-reg "([^/?]+)")
	;;(cffi-log #t)
	(if (< (regcomp reg pattern REG_EXTENDED) 0)
		(begin
			(regerror err reg err-buf 1024)
			(display (format "error ~a\n" (cffi-string err-buf))))       
		(begin
			(let loop ((max-match 0))
				(set! err (regexec reg str nmatch pmatch 0))
				(if (= REG_NOMATCH err)
					(begin (display "router no match\n"))
					(if (not (= 0 err))
						(begin (display (format "error ~a\n" err)))
						(begin
							(if (and (< 1 nmatch) (>= (cffi-get-int (+ pmatch 8)) 0))
								(begin
									;; (+ pmatch (* 结构体大小/8  index) 结构体偏移/4)
									;; (printf "so1:~d, eo2:~d, str: ~a  \n" (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4)) (substring str (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4))))
									(let ((start (cffi-get-int (+ pmatch 8))) 
											(end (cffi-get-int (+ pmatch 8 4))))
										; (printf "~a\n" str)
										(set! result (cons (substring str start end) result))
										(set! str (string-replace str replace-reg (- start 1) end))
									)
								)
							)
						)
					)
				)
				(if (< max-match (- nmatch 2))
					(begin 
						(loop (+ max-match 1))
					)
				)
			)
		)
	)
	(regfree reg)
	(cffi-free pmatch)
	(cons 
		(reverse result) 
		(string-append 
			;"^"
			str
			;"(?:$|\\?)"
			)
	)
)

;; 获取url参数hashtable
(define (libra-regex-query query)
	(define keys (make-hashtable string-hash string=?))
	(define reg (cffi-alloc 100))
	(define pmatch (cffi-alloc 100))
	(define err 0)
	(define err-buf (cffi-alloc 1024))
	(define pattern "([^\\/=&]+)=([^\\/=&]*)")
	(define nmatch (if (or (not (string? query)) (string=? query "") (eq? #f (string-index query #\=))) 
						0 
						(+ (string-count query #\=) 1)))
	(if (= nmatch 0)
		keys
		(begin
			;;(cffi-log #t)
			(if (< (regcomp reg pattern REG_EXTENDED) 0)
				(begin
					(regerror err reg err-buf 1024)
					(display (format "error ~a\n" (cffi-string err-buf))))       
				(begin
					(let loop ((max-match 0))
						(set! err (regexec reg query nmatch pmatch 0))
						(if (not (= REG_NOMATCH err))
							(if (not (= 0 err))
								(begin (display (format "error ~a\n" err)))
								(begin
									(if (and (< 1 nmatch) (>= (cffi-get-int (+ pmatch 8)) 0))
										(begin
											;; (+ pmatch (* 结构体大小/8  index) 结构体偏移/4)
											;; (printf "name: ~a  \n" (substring query (cffi-get-int (+ pmatch (* 8 1))) (cffi-get-int (+ pmatch (* 8 1) 4))))
											;; (printf "word: ~a  \n" (substring query (cffi-get-int (+ pmatch (* 8 2))) (cffi-get-int (+ pmatch (* 8 2) 4))))
											(hashtable-set! keys (substring query (cffi-get-int (+ pmatch (* 8 1))) (cffi-get-int (+ pmatch (* 8 1) 4))) (substring query (cffi-get-int (+ pmatch (* 8 2))) (cffi-get-int (+ pmatch (* 8 2) 4))))
											(set! query (string-replace query "" (cffi-get-int (+ pmatch (* 8 0))) (cffi-get-int (+ pmatch (* 8 0) 4))))
										)
									)
								)
							)
						)
						(if (< max-match (- nmatch 2))
							(begin 
								(loop (+ max-match 1))
							)
						)
					)
				)
			)
			(regfree reg)
			(cffi-free pmatch)
			keys
		)
	)
)

;; 读取文件
(define read-file
	(lambda (file-name)
		(let ((p (open-input-file file-name)))
			(let loop ((lst '()) (c (read-char p)))
			(if (eof-object? c)
				(begin 
					(close-input-port p)
					(list->string (reverse lst)))
				(loop (cons c lst) (read-char p)))))))

;; 返回视图函数
(define view
	(lambda (file-name)
		(default-make-response (read-file file-name))))

(define (default-make-json data)
	(http:content
		'(("Content-Type" . "application/json"))
			data))


;; 服务器处理 入口
;; 路由定义
;; 一级重要
(define serve-proc
	(lambda (request-line query-string header)
		;; show msg on server
		(printf "HTTP=>%a\n" request-line)
		(let [(keys/handler (request->keys/handler request-line query-string))]
			(if (procedure? (cdr keys/handler))
				((cdr keys/handler) (car keys/handler))
				(default-make-response "404")))))
