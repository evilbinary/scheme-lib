(import (net curl)
		(regex regex)
		(sqlite sqlite))

;; 获取图片列表html
(define (get-images-html html)
	(define pattern "<(dl*)\\b[^>]*>(.*?)</dl>")
	(define rst (regex-match pattern html))
	(if (null? rst)
		""
		(car rst))
)

;; 获取名称/id
(define (html->ids html)
	(define pattern "<dd><a target.+?xinggan/(\\d+?).html\">[^>]+?>(.+?)</a>")
	(define rst (regex-matches pattern html))
	(define ids '())
	(map (lambda (lst)
			(set! ids (cons (cadr lst) ids))) 
		rst)
	(reverse ids)
)

;; 获取一组图片数目
(define (get-max-page html)
	(define pattern "<span class=\"page-ch\">.+?(\\d+).+?</span>")
	(define rst (regex-match pattern html))
	(if (null? rst)
		0
		(string->number (cadr rst)))
)

;; 下载某组图片所有地址
(define (id->page id path)
	(define rst (sqlite-exec (string-append "select * from ImageInfo where id=" id)))
	
	(define max-page (if (null? rst) 0 (string->number (cadr (car rst)))))
	(if (= max-page 0)
		(begin
			(set! max-page (get-max-page (url->html (string-append "http://www.mm131.com/xinggan/" id ".html"))))
			(let loop [(index 1)]
				(if (<= index max-page)
					(begin
						(url->file 
							(string-append "http://img1.mm131.com/pic/" id "/" (number->string index) ".jpg")
							(string-append path "/content/images/mm/" id "-" (number->string index) ".jpg"))
						(loop (+ 1 index))
					)
				)
			)
			(sqlite-exec (string-append "INSERT INTO ImageInfo VALUES (" id "," (number->string max-page) ");"))
		)
	)
    max-page
)

;; 方法组合
(define (url->id/page url path)
    (define html (get-images-html (url->html url)))
	(define infos (make-hashtable string-hash string=?))
    (if (string=? html "")
        #f
        (begin
            (map 
				(lambda (id) (hashtable-set! infos id (id->page id path))) 
				(html->ids html))
            infos
        )
    )
)