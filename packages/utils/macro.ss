;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (utils macro)
  (export while for dotimes defun try)
  (import (scheme))
  (define-syntax while
    (syntax-rules ()
      [(_ test body ...)
       (let loop () (when test body ... (loop)))]))
  (define-syntax for
    (syntax-rules (to)
      [(_ i (from to end) body ...)
       (let loop ([i from])
         (when (< i end) body ... (loop (+ i 1))))]
      [(_ i in lst body ...)
       (let loop ([l lst])
         (unless (null? l)
           (let ([i (car l)]) body ... (loop (cdr l)))))]))
  (define-syntax dotimes
    (syntax-rules ()
      [(_ (i end) body ...)
       (let loop ([i 0])
         (when (< i end) body ... (loop (+ i 1))))]))
  (define-syntax defun
    (syntax-rules ()
      [(_ proc args ...) (define proc (lambda args ...))]))
  (define-syntax try
    (syntax-rules (catch)
      [(_ body (catch catcher))
       (call-with-current-continuation
         (lambda (exit)
           (with-exception-handler
             (lambda (condition) (catcher condition) (exit condition))
             (lambda () body))))])))

