;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage private include)
  (export 
    include/resolve)
  (import 
    (rnrs) 
    (for (surfage private include compat) expand))
  
  (define-syntax include/resolve
    (lambda (stx)
      (define (include/lexical-context ctxt filename)
        (with-exception-handler
          (lambda (ex)
            (raise
             (condition
              (make-error)
              (make-who-condition 'include/resolve)
              (make-message-condition "error while trying to include")
              (make-irritants-condition (list filename))
              (if (condition? ex) ex (make-irritants-condition (list ex))))))
          (lambda ()
            (call-with-input-file filename
              (lambda (fip)
                (let loop ([a '()])
                  (let ([x (read fip)])
                    (if (eof-object? x)
                      (cons #'begin (datum->syntax ctxt (reverse a)))
                      (loop (cons x a))))))))))
      (syntax-case stx ()
        [(ctxt (lib-path* ...) file-path)
         (for-all (lambda (s) (and (string? s) (positive? (string-length s)))) 
                  (syntax->datum #'(lib-path* ... file-path)))
         (let ([p (apply string-append 
                         (map (lambda (ps) (string-append "/" ps)) 
                              (syntax->datum #'(lib-path* ... file-path))))]
               [sp (search-paths)])
           (let loop ([search sp])
             (if (null? search)
               (error 'include/resolve "cannot find file in search paths"
                      (substring p 1 (string-length p)) sp)
               (let ([full (string-append (car search) p)])
                 (if (file-exists? full)
                   (include/lexical-context #'ctxt full)
                   (loop (cdr search)))))))])))
)
