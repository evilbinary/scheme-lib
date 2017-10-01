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
		(net socket) 
		(net socket-ffi) 
		(regex regex-ffi)
		(json json)
		(c c-ffi))
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
(define (run listen-port)
	(let [(server (make-socket AF_INET SOCK_STREAM listen-port))]
		(socket:bind server)
		(socket:listen server)
		(printf "Listening on %d\n" listen-port)
		(let loop ((port (socket:accept server)))
			(if (>= port 0)
				(begin
					(let ((iport (make-fd-input-port port)) 
							(oport (make-fd-output-port port)))
						;; 指定框架入口 serve-proc
						(http:serve-query 
							(lambda (request-line query-string header)
								(serve-proc request-line query-string header iport oport port))
							iport oport)
						(close-port iport)
						(close-port oport)
						(close port))
					(loop (socket:accept server)))))
		(socket:close server)))


;; http response maker
(define (default-make-response html)
	(http:content
		'(("Content-Type" . "text/html") ("Connection" . "close"))
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

;; 32位: 4字节; 64位: 8字节
(define bytes 
	(case (machine-type)
		((arm32le i3nt i3osx i3le a6le) 4)
		((a6nt a6osx) 8)
		(else 4)))

;; 2 bytes为1组
(define group (* 2 bytes))

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
						(let ((start (cffi-get-int (+ pmatch (* group index)))) 
								(end (cffi-get-int (+ pmatch (* group index) bytes))))
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
	(cffi-free reg)
	(cffi-free pmatch)
	(cffi-free err-buf)
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
							(if (and (< 1 nmatch) (>= (cffi-get-int (+ pmatch group)) 0))
								(begin
									;; (+ pmatch (* 结构体大小/8  index) 结构体偏移/4)
									;; (printf "so1:~d, eo2:~d, str: ~a  \n" (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4)) (substring str (cffi-get-int (+ pmatch (* 8 index))) (cffi-get-int (+ pmatch (* 8 index) 4))))
									(let ((start (cffi-get-int (+ pmatch group))) 
											(end (cffi-get-int (+ pmatch group bytes))))
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
	(cffi-free reg)
	(cffi-free pmatch)
	(cffi-free err-buf)
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
	(define pattern "([^\\/=&]+)=([^=&]*)")
	(define nmatch (if (or (not (string? query)) (string=? query "") (eq? #f (string-index query #\=))) 
						0 
						(+ (* 2 (string-count query #\=)) 1)))
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
									(if (and (< 1 nmatch) (>= (cffi-get-int (+ pmatch group)) 0))
										(begin
											;; (+ pmatch (* 结构体大小/8  index) 结构体偏移/4)
											;; (printf "name: ~a  \n" (substring query (cffi-get-int (+ pmatch (* 8 1))) (cffi-get-int (+ pmatch (* 8 1) 4))))
											;; (printf "word: ~a  \n" (substring query (cffi-get-int (+ pmatch (* 8 2))) (cffi-get-int (+ pmatch (* 8 2) 4))))
											(hashtable-set! keys (substring query (cffi-get-int (+ pmatch (* group 1))) (cffi-get-int (+ pmatch (* group 1) bytes)))
																 (substring query (cffi-get-int (+ pmatch (* group 2))) (cffi-get-int (+ pmatch (* group 2) bytes))))
											(set! query (string-replace query "" (cffi-get-int (+ pmatch (* group 0))) (cffi-get-int (+ pmatch (* group 0) bytes))))
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
			(cffi-free reg)
			(cffi-free pmatch)
			(cffi-free err-buf)
			keys
		)
	)
)

;; 读取文本文件
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
		(if (eq? #f (string-index file-name #\.))
			(set! file-name (string-append 
								(hashtable-ref libra-options "web-path" (get-app-path))
								"/"
								(hashtable-ref libra-options "view-path" "views")
								"/"
								file-name
								".html")))
		(default-make-response (read-file file-name))))

;; 默认json返回
(define (default-make-json data)
	(http:content
		'(("Content-Type" . "application/json; charset=utf-8") ("Connection" . "close"))
			(scm->json-string data)))

;; 判断资源文件
(define (resource? request)
	(define resource-types (vector->list (hashtable-keys content-types)))
	(if (eq? #f (string-index request #\.))
		#f
		(let ((type (string-downcase (substring request (+ 1 (string-index-right request #\.)) (string-length request)))))
			(exists (lambda (n) (string=? n type)) resource-types))))

;; 返回资源文件
(define (default-make-resource request port oport)
	(let ((file-path (get-file-path request)))
		(if (file-exists? file-path)
			(begin
				(display (string-append
							(http:status-line 200 "OK")
							(http:header
								(list
									(get-content-type (substring request (+ 1 (string-index-right request #\.)) (string-length request)))
									(cons "Content-Length" (number->string (get-file-length file-path)))
									(cons "Connection" "close")
								)
							)
						 ) 
					oport
				)
				(let ((f (c-fopen file-path "rb"))
					  (buf (cffi-alloc 1024)))
					(let loop ((len (c-fread buf 1 1024 f)))
						(if (> len 0)
							(begin	   
								(cwrite-all port buf len)
								(loop (c-fread buf 1 1024 f)))
							(c-fclose f)))
					(cffi-free buf)
				)
				'()
			)
			'(404 "Bad Request")
		)
	)
)

;; 获取文件长度
(define (get-file-length file-path)
	(define length 0)
	(let ([p (open-input-file file-path)])
 	 	(set! length (file-length p))
		(close-port p)
	)
	length
)

;; 获取执行文件文件夹地址
(define (get-app-path)
	(define script (car (command-line)))
	(define index-\\ (string-index-right script #\\))
	(define index-// (string-index-right script #\/))
	(substring script 0 (max (if (number? index-\\) index-\\ 0) (if (number? index-//) index-// 0))))

;; 配置字典
(define libra-options (make-hashtable string-hash string=?))
(define content-types (make-hashtable string-hash string=?))

;; 展示字典
(define (show-options)
	(vector-map (lambda (k) (display (string-append k ": " (hashtable-ref libra-options k ""))) (newline)) (hashtable-keys libra-options))
)

;; web根目录
(hashtable-set! libra-options "web-path" (get-app-path))
;; 视图文件夹名称
(hashtable-set! libra-options "view-path" "views")
;; 启动文件目录
(hashtable-set! libra-options "app-path" (get-app-path))
;; Content-Type
(hashtable-set! libra-options "content-type" content-types)

;; 默认content-type列表
(define type-pairs
	(list 
		 '("js" . "application/javascript")
		 '("css" . "text/css")
		 '("jpg" . "image/jpeg")
		 '("png" . "image/png")
		 '("gif" . "image/gif")
		 '("ico" . "image/x-icon")
	)
)
;; 初始化content-types
(map 
	(lambda (pair)
		(hashtable-set! content-types (car pair) (cdr pair)))
	type-pairs
)

;; 返回资源对应http头
(define (get-content-type type)
	(cons "Content-Type" (hashtable-ref content-types type "text/html"))
)

;; 获取web配置
(define (get-option key . rest)
	(define default (if (null? rest) #f (car rest)))
	(hashtable-ref libra-options key default))

;; 设置配置
(define (set-opiton! key value)
	(hashtable-set! libra-options key value))

;; 获取文件完整路径
(define (get-file-path file)
	(string-append (hashtable-ref libra-options "web-path" (get-app-path)) file))

;; 文件导入
(define (using file)
	(load (string-append (hashtable-ref libra-options "app-path" (get-app-path)) (string (directory-separator)) file)))


;; 服务器处理 入口
;; 路由定义
;; 一级重要
(define serve-proc
	(lambda (request-line query-string header iport oport port)
		;; show msg on server
		(printf "HTTP=>%a\n" request-line)
		(if (resource? (cadr request-line))
			(default-make-resource (cadr request-line) port oport)
			(let [(keys/handler (request->keys/handler request-line query-string))]
				(if (procedure? (cdr keys/handler))
					((cdr keys/handler) (car keys/handler))
					'(404 "Bad Request"))))))