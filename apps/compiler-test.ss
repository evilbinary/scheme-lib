;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import  (scheme) (nanopass))
;;(display "compiler\n")


(define primitive?
  (lambda (x)
    (memq x
	  '(cons make-vector box car cdr vector-ref vector-length unbox
		 + - * / pair? null? boolean? vector? box? = < <= > >= eq?
		 vector-set! set-box!))))

(define target-fixnum?
  (lambda (x)
    (and (and (integer? x) (exact? x))
         (<= (- (expt 2 60)) x (- (expt 2 60) 1)))))
(define constant?
  (lambda (x)
    (or (target-fixnum? x) (boolean? x) (null? x))))


(define datum?
  (lambda (x)
    (or (constant? x)
        (and (box? x) (datum? (unbox x)))
        (and (pair? x) (datum? (car x)) (datum? (cdr x)))
        (and (vector? x)
             (let loop ([i (vector-length x)])
               (or (fx=? i 0) (let ([i (fx- i 1)])
                     (and (datum? (vector-ref x i))
                          (loop i)))))))))

(define-language Lsrc
  (terminals
   (symbol (x))
   (primitive (pr))
   (constant (c))
   (datum (d)))
  (Expr (e body)
	pr
	x
	c
	(quote d)
	(if e0 e1)
	(if e0 e1 e2)
	(or e* ...)
	(and e* ...)
	(not e)
	(begin e* ... e)
	(lambda (x* ...) body* ... body)
	(let ([x* e*] ...) body* ... body)
	(letrec ([x* e*] ...) body* ... body)
	(set! x e)
	(e e* ...)))



(define-language L1
  (extends Lsrc)
  (entry Expr)
  (terminals
   (- (primitive (pr)))
   (+ (primitive (pr))))
  (Expr (e body)
	(- (if e0 e1))))

(pretty-print (diff-languages Lsrc L1))


(trace-define-pass remove-implicit-begin
  : Lsrc (ir) -> L1 ()
  (process-expr-expr : Expr (ir) -> Expr ()
		     [(lambda (,x ...) ,[body1] ... ,[body2])
		      `(lambda (,x ...) (begin ,body1 ... ,body2))]
		     [(let ((,x ,[e]) ...) ,[body1] ... ,[body2])
		      `(let ((,x ,e) ...) (begin ,body1 ... ,body2))]
		     [(letrec ((,x ,[e]) ...) ,[body1] ... ,[body2])
		      `(letrec ((,x ,e) ...) (begin ,body1 ... ,body2))]))


(pretty-print
 (unparse-L1
  (remove-implicit-begin
   (with-output-language
    (Lsrc Expr)
    `(let ([x (quote 1)]
	   [y (quote 2)])
       (+ (var x)
	  (var y)))))))


 ;;(pretty-print		  
 ;; (unparse-L1
 ;;  (with-output-language
 ;;   L1
 ;;   (in-context
 ;;    Expr `(let ([x (quote 1)]
 ;; 		[y (quote 2)])
 ;; 	    (primapp + (var x)
 ;; 		     (var y)))))))
;;(pretty-print (language->s-expression L0))
