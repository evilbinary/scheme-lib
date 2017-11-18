(import (net curl)
		(irregex irregex)
		(sqlite sqlite))

;; 获取图片列表html
(define (get-images-html html)
	(define pattern "dl[\\s\\S]*?dl")
	(define match (irregex-search pattern html))
	(if match
		(substring html (vector-ref match 4) (vector-ref match 6))
		""
	)
)

;; 获取id列表
(define (html->ids html)
	(define pattern "<img.+?pic.(\\d+?)...jpg")
	(define len (string-length html))
	(define ids '())
	(let loop ([match (irregex-search pattern html 0 len)])
		(when match
			(set! ids (cons (substring html (vector-ref match 8) (vector-ref match 10)) ids))
			(loop (irregex-search pattern html (vector-ref match 6)))
		)
	)
	(reverse ids)
)

;; 获取一组图片数目
(define (get-max-page html)
	(define pattern "page-ch[^\\d]+?(\\d*?)[^\\d]+?span")
	(define match (irregex-search pattern html))
	(if match
		(string->number (substring html (vector-ref match 8) (vector-ref match 10)))
		0)
)

;; 获取某id图片页码
(define (id->page id type path)
	(define rst (sqlite-exec (string-append "select * from ImageInfo where id=" id)))
	(define max-page (if (null? rst) 0 (string->number (cadr (car rst)))))
	(if (= max-page 0)
		(begin
			(set! max-page (get-max-page (url->html (string-append "http://www.mm131.com/" type "/" id ".html"))))
			(if (> max-page 0)
				(sqlite-exec (string-append "INSERT INTO ImageInfo VALUES (" id "," (number->string max-page) ");")))
		)
	)
	(unless (file-exists? (string-append path "/content/images/mm/" id "-1.jpg"))
		(url->file 
			(string-append "http://img1.mm131.me/pic/" id "/1.jpg")
			(string-append path "/content/images/mm/" id "-1.jpg")))
	(display (string-append "http://img1.mm131.me/pic/" id "/1.jpg"))
	(newline)
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
						(string-append "http://img1.mm131.me/pic/" id "/" (number->string index) ".jpg")
						file-path))
				(loop (+ 1 index) (string-append path "/content/images/mm/" id "-" (number->string (+ 1 index)) ".jpg"))
			)
		)
	)
)