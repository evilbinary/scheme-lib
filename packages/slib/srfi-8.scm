;;"srfi-8.scm": RECEIVE: Binding to multiple values

(require 'values)

;;@code{(require 'srfi-8)}
;;@ftindex srfi-8

;;@body
;;@url{http://srfi.schemers.org/srfi-8/srfi-8.html}
(define-syntax receive
  (syntax-rules ()
    ((receive formals expression body ...)
     (call-with-values (lambda () expression)
       (lambda formals body ...)))))
