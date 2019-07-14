;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)
	 (glfw glfw)
	 (gui duck)
	 (gui draw)
	 (gui window)
	 (gui widget))
(define (infix-prefix lst)
  (if (list? lst)
      (if (null? (cdr lst))
          (car lst)
          (list (cadr lst)
                (infix-prefix (car lst))
                (infix-prefix (cddr lst))))
      lst))
(define exp-result 0)
(define exp "")
(define clear #t)

(define (app-calc)
  (set! window (window-create 600 420 "鸭子gui"))
  (let ((d (dialog 40.0 20.0 250.0 380.0 "计算器"))
	(result (button 224.0 60.0 ""))
    (cls  (button 108.0 50.0 "清除"))
    (percent  (button 50.0 50.0 " % "))
    (div  (button 50.0 50.0 " / "))
	(num7  (button 50.0 50.0 "7"))
	(num8  (button 50.0 50.0 "8"))
	(num9  (button 50.0 50.0 "9"))
	(num6  (button 50.0 50.0 "6"))
	(num5  (button 50.0 50.0 "5"))
	(num4  (button 50.0 50.0 "4"))
	(num3  (button 50.0 50.0 "3"))
	(num2  (button 50.0 50.0 "2"))
	(num1  (button 50.0 50.0 "1"))
	(num0  (button 108.0 50.0 "0"))
	(mul  (button 50.0 50.0 " * "))
	(sub  (button 50.0 50.0 " - "))
	(add  (button 50.0 50.0 " + "))
	(ret  (button 50.0 50.0 " = "))
	(dot  (button 50.0 50.0 ".")))
    (widget-set-attrs sub 'background #xfff79231)
    (widget-set-attrs mul 'background #xfff79231)
    (widget-set-attrs add 'background #xfff79231)
    (widget-set-attrs ret 'background #xfff79231)
    (widget-set-attrs div 'background #xfff79231)
    (let loop ((btn (list result
              cls percent div
              num7 num8 num9 mul
			  num4  num5 num6 sub
			  num1 num2  num3 add
			  num0  dot ret)))
      (if (pair? btn)
	  (begin
	  	(widget-set-attrs (car btn) 'text-align 'center)
	    (widget-set-margin (car btn) 4.0 4.0 4.0 4.0)
        (widget-set-attrs (car btn) 'font-size 24.0)
        (widget-set-events
            (car btn)
            'click
            (lambda (widget p type data)
                (let ((text (widget-get-attr widget %text)))
                (case text
                  [" = " 
                    (if (and (> (string-length exp) 0) clear) 
                      (begin 
                       (printf "exp:~a\n" (format "(~a)" exp) )
                        (set! exp-result 
                         (eval (infix-prefix
                           (read (open-input-string
                            (format "( ~a )" exp))))))
                        (set! exp (format "~a" exp-result ))
                        (widget-set-attr result %text exp)
                        (set! clear #f))
                    )]
                  ["清除"
                    (set! exp "")
                    (set! exp-result "")
                    (set! clear #t)
                    (widget-set-attr result %text exp)
                  ]
                  [else
                    (set! exp (string-append exp (format "~a" text) ))
                    (widget-set-attr result %text exp)
                    ])
                
                )))
	    (widget-add d (car btn))
	    (loop (cdr btn))
	    )))
    (widget-set-attrs result 'text-align 'left)
    (widget-set-attrs result 'background #x66cccccc)
    (widget-set-attrs result 'font-size 50.0)
    )
  (window-loop window)
  (window-destroy window))
 (app-calc)