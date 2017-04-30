;"pp.scm" Pretty-Print
(require 'generic-write)
;@
(define (pretty-print obj . opt)
  (let ((port (if (pair? opt) (car opt) (current-output-port))))
    (generic-write obj #f (output-port-width port)
		   (lambda (s) (display s port) #t))))
;@
(define (pretty-print->string obj . width)
  (define result '())
  (generic-write obj #f (if (null? width) (output-port-width) (car width))
		 (lambda (str) (set! result (cons str result)) #t))
  (reverse-string-append result))
