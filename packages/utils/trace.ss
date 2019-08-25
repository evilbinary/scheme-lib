;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (utils trace)
  (export
    print-stack-trace
    stack-trace-exception
    stack-trace
    print-lambda)
  (import (scheme))
  (define (print-stack-trace e)
    (define (get-func c)
      (let ([cc ((c 'code) 'name)]) (if cc cc "--main--")))
    (display-condition e)
    (newline)
    (let p ([t (inspect/object (condition-continuation e))])
      (call/cc
        (lambda (ret)
          (if (> (t 'depth) 1)
              (begin
                (call-with-values
                  (lambda () (t 'source-path))
                  (case-lambda
                    [(file line column)
                     (printf "\tat ~a (~a:~a,~a)\n" (get-func t) file line
                       column)]
                    [else (ret)]))
                (p (t 'link)))))))
    (exit))
  (define (stack-trace-exception)
    (base-exception-handler print-stack-trace))
  (define (stack-trace obj)
    (call/cc
      (lambda (k)
        (printf "backtrace of [~a] as following:\n" obj)
        (let loop ([cur (inspect/object k)] [i 0])
          (if (and (> (cur 'depth) 1))
              (begin
                (call-with-values
                  (lambda () (cur 'source-path))
                  (case-lambda
                    [(file line char)
                     (printf
                       "\tat ~a (~a:~a)\n"
                       ((cur 'code) 'name)
                       file
                       line)]
                    [(file line)
                     (printf
                       "\tat ~a (~a:~a)\n"
                       ((cur 'code) 'name)
                       file
                       line)]
                    [else (k)]))
                (loop (cur 'link) (+ i 1))))))))
  (define (print-lambda fun)
    (printf "lambda of [~a] as following:\n" fun)
    (pretty-print
      ((((inspect/object fun) 'code) 'source) 'value))))

