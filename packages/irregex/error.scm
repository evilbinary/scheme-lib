
(define (error msg . args)
  (display msg)
  (for-each (lambda (x) (display " ") (write x)) args)
  (newline)
  (0))

