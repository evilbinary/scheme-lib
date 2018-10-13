;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/17.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui syntax)
  (export
   parse-syntax
   parse-syntax2
   init-syntax
   )
  
  (import (scheme) (utils libutil) (cffi cffi) )


  (define (is-operator c)
    (or (char=? c #\()
	(char=? c #\))
	(char=? c #\])
	(char=? c #\])
	(char=? c #\()
	(char=? c #\=)
	(char=? c #\*)
	(char=? c #\+)
	(char=? c #\/)
	(char=? c #\<)
	(char=? c #\>)
	))
  (define (is-comment c)
    (char=? c #\;))

  (define (is-nl c)
    (or (= (char->integer c) #x0d)
	(= (char->integer c) #x0a)))

  (define (is-delimiter c)
    (or (is-operator c)
	(is-comment c)
	(is-nl c)
	(char=? c #\space)
	(char=? c #\")

	))

  (define (get-next-token text i)
    (let loop ((len  (- (string-length text) 0))
	       (s i)
	       (c (string-ref text i)))
      (if (< s len)
	  (if (is-delimiter  c);;end
	      s
	      (begin
		(set! s (+ s 1))
		(loop len s (string-ref text s) ) ) )
	  s )
      )
    )

  (define (eat-nl text i)
    (let loop ((len (- (string-length text) 1))
	       (s i)
	       (c (string-ref text i))
	       )
      (if (< s len)
	  (if (is-nl c)
	      (begin
		(set! s (+ s 1))
		(loop len s (string-ref text s)))
	      (begin
		s)
	      )
	  s
	  )))

  (define (eat-space text i)
    (let loop ((len (string-length text))
	       (s i)
	       (c (string-ref text i))
	       )
      (if (< s len)
	  (if (equal? #\space c )
	      (begin
		(set! s (+ s 1))
		(loop len s (string-ref text s)))
	      (begin
		s)
	      )
	  s
	  )))
  

  (define (parse-string text i)
    (let loop ((len  (string-length text))
	       (s i)
	       (c (string-ref text i)))
      (if (< s len)
	  (if (equal? #\" c);;end char "
	      (begin
		(+ s   1)
		)
	      (begin
		(set! s (+ s 1))
		(loop len s (string-ref text s) ) ) )   s )))

  (define (is-number str)
    (not (equal? #f (string->number str))))


  (define keywords (make-hashtable equal-hash equal?))
  (define identifiers (make-hashtable equal-hash equal?))

  (define (init-syntax)
    (hashtable-set! keywords "if" #t)
    (hashtable-set! keywords "define" #t)
    (hashtable-set! keywords "import" #t)
    (hashtable-set! keywords "display" #t)
    (hashtable-set! keywords "set!" #t)
    (hashtable-set! keywords "def-function-callback" #t)
    (hashtable-set! keywords "display" #t)

    )

  (define (is-keyword str)
    (let ((ret (hashtable-ref keywords str '())))
      (if (null? ret)
	  #f
	  #t)))

  (define (is-identifier str)
    (let ((ret (hashtable-ref identifiers str '())))
      (if (null? ret)
	  #f
	  #t)))

  (define (parse-number text i)
    (let loop ((len (string-length text))
	       (s i)
	       (c (string-ref text i))
	       )
      (if (< s len)
	  (if (is-number c)
	      (begin

		(set! s (+ s 1))
		(loop len s (string-ref text s)))
	      (begin
		s)
	      ))))


  (define (parse-comment text i)
    (let loop ((len (string-length text))
	       (s i)
	       (c (string-ref text i))
	       )
      ;;(printf "~a ~a ~a\n" c (char->integer c) (is-nl c))

      (if (< s len)
	  (if (not (is-nl c ))
	      (begin
		(set! s (+ s 1))
		(loop len s (string-ref text s)))
	      (begin
		;;(printf "<===========>\n")
		s )
	      ))))


  (define (set-color colored start count color text)
    (let loop ((i 0))
      (if (< i count)
	  (begin
	    ;;(printf "~a ~a  ~x\n"  (+ start i) (string-ref text (+ start i)) color)
	    ;;(cffi-set-int (cffi-get-addr colored (* (+ start i) 4))  color)
	    (cffi-set-int  (+ colored (* (+ start i) 4)) color)
	    (loop (+ i 1))
	    ))
      )
    )


  (define (parse-syntax colored text)
    ;;(cffi-set colored  #xffffffff (string-length text))
    (let loop ((i 0) (len (- (string-length text) 2) ) (c (string-ref text 0)) )
      (if (< i len)
	  (begin
	    (cond
	     [(is-delimiter c)
	      (cond
	       [(equal? #\space c)
		(let ((ni (eat-space text (+ i 1) )))
		  (set-color colored i (- ni i) #xffcccccc text)
		  (set! i ni)
		  )]
	       [(equal? #\" c)
		(let ((ni (parse-string text (+ i 1)) ))
		  ;;(printf "string=> ~a\n" (substring text i (parse-string text (+ i 1))))
		  (set-color colored i (- ni i) #xffE6DB74 text)

		  (set! i ni ))]
	       [(is-operator c)
		(begin
		  ;;(printf "operator=> ~a\n" c)
		  (set-color colored i 1 #xffF8F8F2 text) ;;F8F8F2
		  (set! i (+  i 1))
		  )]
	       [(is-comment c)
		(let ((ni (parse-comment text (+ i 1))))
		  ;;(printf "comment=> ~a\n" (substring text i (parse-comment text (+ i 1) )))
		  (set-color colored  i (- ni i) #xff75715E text)
		  (set! i ni)
		  )]
	       [(is-nl c);;\n\r
		(begin
		  (set-color colored i 1 #xffff0000 text)
		  (set! i (eat-nl text (+ i 1)))
		  )]
	       [else
		;;(printf "=============================\n")
		(set! i (+ i 1))
		]
	       )
	      ]
	     [else
	      (let* ((ni (get-next-token text i ))
		     (token (substring text i ni)))
		;;(printf "token=> ~a\n" token)
		(cond 
		 [(is-number token)
		  ;;(printf "number=> ~a\n" (string->number token))
		  (set-color colored i (- ni i) #xffAE81FF text)
		  ]
		 [(is-keyword token)
		  ;;(printf "keyword=> ~a\n"  token)
		  (set-color colored i (- ni i) #xff66D9EF text)
		  ]
		 [(is-identifier token)
		  ;;(printf "identifier=> ~a\n"  token)
		  (set-color colored i (- ni i)  #xff95f067 text)
		  ]
		 [else
		  ;;(printf "token=> ~a\n" token)
		  (set-color colored i (- ni i)  #xff00cc00 text)
		  ]
		 )
		(set! i ni ))]
	     )
	    ;;(printf "colored ~a\n" colored)
	    
	    (if (< i len)
		(loop i len (string-ref text i) ))
	    ))
      colored
      ))


  (define (parse-syntax2 text)
    (let ((colored (make-vector (string-length text) ))
	  (index 0)
	  )
      (let loop ((i 0) (len (- (string-length text) 2) ) (c (string-ref text 0)) )
	(if (< i len)
	    (begin
	      (cond
	       [(is-delimiter c)
		(cond
		 [(equal? #\space c)
		  (let ((ni (eat-space text (+ i 1) )))
		    (vector-set! colored index (cons (substring text i ni) #xffcccccc) )
		    (set! index (+ index 1))
		    (set! i ni)
		    )]
		 [(equal? #\" c)
		  (let ((ni (parse-string text (+ i 1)) ))
		    ;;(printf "string=> ~a\n" (substring text i (parse-string text (+ i 1))))
		    (vector-set! colored index (cons (substring text i ni) #xffE6DB74))
		    (set! index (+ index 1))

		    (set! i ni ))]
		 [(is-operator c)
		  (begin
		    ;;(printf "operator=> ~a\n" c)
		    (vector-set! colored index  (cons (format "~a" c) #xffF8F8F2))
		    (set! index (+ index 1))
		    (set! i (+  i 1))
		    )]
		 [(is-comment c)
		  (let ((ni (parse-comment text (+ i 1))))
		    ;;(printf "comment=> ~a\n" (substring text i (parse-comment text (+ i 1) )))
		    (vector-set! colored index (cons (substring text i ni) #xff75715E))
		    (set! index (+ index 1))
		    (set! i ni)
		    )]
		 [(is-nl c);;\n\r
		  (begin
		    (vector-set! colored index (cons (format "~a" c) #xff00ff00))
		    (set! index (+ index 1))
		    
		    (set! i (eat-nl text (+ i 1)))
		    )]
		 [else 
		  (set! i (+ i 1))
		  ]
		 )
		]
	       [else
		(let* ((ti (get-next-token text i ))
		       (token (substring text i ti)))
		  ;;(printf "token=> ~a\n" token)
		  (cond 
		   [(is-number token)
		    ;;(printf "number=> ~a\n" (string->number token))
		    (vector-set! colored index (cons token #xffAE81FF))
		    (set! index (+ index 1))
		    ]
		   [(is-keyword token)
		    ;;(printf "keyword=> ~a\n"  token)
		    (vector-set! colored index (cons token #xff66D9EF))
		    (set! index (+ index 1))
		    ]
		   [(is-identifier token)
		    ;;(printf "identifier=> ~a\n"  token)
		    (vector-set! colored index (cons token #xff95f067))
		    (set! index (+ index 1))
		    ]
		   [else
		    ;;(printf "token=> ~a\n" token)
		    (vector-set! colored index  (cons token #xff00cc00))
		    (set! index (+ index 1))
		    ]
		   )
		  (set! i ti ))]
	       )
	      ;;(printf "colored ~a\n" colored)
	      
	      (if (< i len)
		  (loop i len (string-ref text i) ))
	      )))
      (list colored index)
      ))


  )
