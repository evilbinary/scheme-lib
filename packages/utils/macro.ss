;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (utils macro)
         (export
        while
        for
        dotimes
        defun
        try
         	)
 (import  (scheme))

; (define-syntax when
;   (syntax-rules ()
;     ((_ test body ...)
;      (if test
;          (begin body ...)))))

; (define-syntax unless
;   (syntax-rules ()
;     ((_ test body ...)
;      (if (not test)
;          (begin body ...)))))


(define-syntax while
  (syntax-rules ()
    ((_ test body ...)
     (let loop ()
       (when test
             body ...
             (loop))))))

(define-syntax for
  (syntax-rules (to)
    ;; loop in sequence
    ;; (for i (0 to 10) do something...)
    ((_ i  (from to end) body ...)
     (let loop ((i from))
       (when (< i end)
             body ...
             (loop (+ i 1)))))
    ;; loop in list
    ;; (for i in '(a b c) do something...)
    ((_ i in lst body ...)
     (let loop ((l lst))
       (unless (null? l)
               (let ((i (car l)))
                 body ...
                 (loop (cdr l))))))))

;; Lisp style loop
(define-syntax dotimes
  (syntax-rules ()
    ((_ (i end) body ...)
     (let loop ((i 0))
       (when (< i end)
             body ...
             (loop (+ i 1)))))))

;; Lisp style defun
(define-syntax defun
  (syntax-rules ()
    ((_ proc args ...)
     (define proc
       (lambda args ...)))))

(define-syntax try 
  (syntax-rules (catch) 
    ((_ body (catch catcher)) 
     (call-with-current-continuation 
      (lambda (exit) 
	(with-exception-handler 
	 (lambda (condition) 
	   (catcher condition) 
	   (exit condition)) 
	 (lambda () body)))))))
   
)
