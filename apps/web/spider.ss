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

;; 获取id列表
(define (html->ids html)
	(define pattern "<dd><a target.+?www.mm131.com/\\w+?/(\\d+?).html\">[^>]+?>(.+?)</a>")
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

;; 获取某id图片页码
(define (id->page id type path)
	(define rst (sqlite-exec (string-append "select * from ImageInfo where id=" id)))
	(define max-page (if (null? rst) 0 (string->number (cadr (car rst)))))
	(display id)
	(if (= max-page 0)
		(begin
			(set! max-page (get-max-page (url->html (string-append "http://www.mm131.com/" type "/" id ".html"))))
			(if (not (file-exists? (string-append path "/content/images/mm/" id "-1.jpg")))
				(url->file 
					(string-append "http://img1.mm131.com/pic/" id "/1.jpg")
					(string-append path "/content/images/mm/" id "-1.jpg")))
			(if (> max-page 0)
				(sqlite-exec (string-append "INSERT INTO ImageInfo VALUES (" id "," (number->string max-page) ");")))
		)
	)
    max-page
)

;; 通过url获取页面图片的id及其页码
(define (url->id/page url type path)
    (define html (get-images-html (url->html url)))
	(define infos (make-hashtable string-hash string=?))
    (if (string=? html "")
        #f
        (begin
            (map 
				(lambda (id) (hashtable-set! infos id (id->page id type path))) 
				(html->ids html))
            infos
        )
    )
)

;; 下载此id全部图片
(define (id/page->load id page path)
	(set! page (string->number page))
	(let loop [(index 1)
			   (file-path (string-append path "/content/images/mm/" id "-1.jpg"))]
		(if (and (<= index page))
			(begin
				(if (not (file-exists? file-path))
					(url->file 
						(string-append "http://img1.mm131.com/pic/" id "/" (number->string index) ".jpg")
						file-path))
				(loop (+ 1 index) (string-append path "/content/images/mm/" id "-" (number->string (+ 1 index)) ".jpg"))
			)
		)
	)
)