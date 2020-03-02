;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;其中 scanf 由 yupengkun 友情贡献
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (io scanf)
  (export
    scanf)
  (import (scheme))
    (define (scanf fmt . var)
    (define (sf-f c str)
      (do ([n 0 (+ 1 n)]) ((equal? c (string-ref str n)) n)))
    (define c (list #\d string->number #\s eval))
    (set! fmt (string-append fmt "\r"))
    (let foo ([i 0] [tar (get-line (current-input-port))])
      (when (<= (+ i 3) (string-length fmt))
        (let ([f (string-ref fmt i)]
              [m (string-ref fmt (+ i 1))]
              [l (string-ref fmt (+ i 2))])
          (cond
            [(and (eq? f #\~) (or (eq? m #\d) (eq? m #\s)))
            (set! temp (+ (sf-f l tar) 1))
            (set-box!
              (car var)
              ((cadr (memv m c)) (substring tar 0 (- temp 1))))
            (set! var (cdr var))
            (foo (+ i 3) (substring tar temp (string-length tar)))]
            [else
            (foo (+ 1 i) (substring tar 1 (string-length tar)))])))))
)
