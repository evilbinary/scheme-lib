;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui syntax)
  (export parse-syntax parse-syntax2 init-syntax add-keyword
    add-keywords add-identify add-color)
  (import (scheme) (utils libutil) (cffi cffi) (utils macro))
  (define (is-operator c)
    (or (char=? c #\()
        (char=? c #\))
        (char=? c #\])
        (char=? c #\])
        (char=? c #\()
        (char=? c #\=)
        (char=? c #\*)
        (char=? c #\+)
        (char=? c #\/)
        (char=? c #\<)
        (char=? c #\>)))
  (define (is-comment c) (char=? c #\;))
  (define (is-nl c)
    (or (= (char->integer c) 13) (= (char->integer c) 10)))
  (define (is-delimiter c)
    (or (is-operator c)
        (is-comment c)
        (is-nl c)
        (char=? c #\space)
        (char=? c #\")))
  (define (get-next-token text i)
    (let loop ([len (- (string-length text) 0)]
               [s i]
               [c (string-ref text i)])
      (if (< s len)
          (if (is-delimiter c)
              s
              (begin (set! s (+ s 1)) (loop len s (string-ref text s))))
          s)))
  (define (eat-nl text i)
    (if (< i (string-length text))
        (let ([ii i] [c (string-ref text i)])
          (if (= (char->integer c) 13)
              (begin
                (set! ii (+ ii 1))
                (set! c (string-ref text ii))
                (if (and (< ii (string-length text))
                         (= (char->integer c) 10))
                    (set! ii (+ ii 1)))))
          ii)
        i))
  (define (eat-space text i)
    (let loop ([len (string-length text)]
               [s i]
               [c (string-ref text i)])
      (if (< s len)
          (if (equal? #\space c)
              (begin (set! s (+ s 1)) (loop len s (string-ref text s)))
              (begin s))
          s)))
  (define (parse-string text i)
    (let loop ([len (string-length text)]
               [s i]
               [c (string-ref text i)])
      (if (< s len)
          (if (or (equal? #\" c) (equal? #\newline c))
              (begin (+ s 1))
              (begin (set! s (+ s 1)) (loop len s (string-ref text s))))
          s)))
  (define (is-number str)
    (not (equal? #f (string->number str))))
  (define (init-syntax)
    (vector
      (make-hashtable equal-hash equal?)
      (make-hashtable equal-hash equal?)
      (make-hashtable equal-hash equal?)))
  (define (add-color syntax name color)
    (hashtable-set! (vector-ref syntax 2) name color))
  (define (get-color syntax name)
    (hashtable-ref (vector-ref syntax 2) name 4294967295))
  (define (add-keyword syntax name)
    (hashtable-set! (vector-ref syntax 0) name #t))
  (define (add-keywords syntax names)
    (let loop ([name names])
      (if (pair? name)
          (begin (add-keyword syntax (car name)) (loop (cdr name))))))
  (define (add-identify syntax name)
    (hashtable-set! (vector-ref syntax 1) name #t))
  (define (is-keyword keywords str)
    (let ([ret (hashtable-ref keywords str '())])
      (if (null? ret) #f #t)))
  (define (is-identifier identifiers str)
    (let ([ret (hashtable-ref identifiers str '())])
      (if (null? ret) #f #t)))
  (define (parse-number text i)
    (let loop ([len (string-length text)]
               [s i]
               [c (string-ref text i)])
      (if (< s len)
          (if (is-number c)
              (begin (set! s (+ s 1)) (loop len s (string-ref text s)))
              (begin s)))))
  (define (parse-comment text i)
    (let loop ([len (string-length text)]
               [s i]
               [c (string-ref text i)])
      (if (< s len)
          (if (not (is-nl c))
              (begin (set! s (+ s 1)) (loop len s (string-ref text s)))
              (begin s)))))
  (define (set-color colored start count color text)
    (let loop ([i 0])
      (if (< i count)
          (begin
            (cffi-set-int (+ colored (* (+ start i) 4)) color)
            (loop (+ i 1))))))
  (define (parse-syntax syntax colored text)
    (try (if (> (string-length text) 0)
             (let ([keywords (vector-ref syntax 0)]
                   [identifies (vector-ref syntax 1)]
                   [comment-color (get-color syntax 'comment)]
                   [string-color (get-color syntax 'string)]
                   [operator-color (get-color syntax 'operator)]
                   [normal-color (get-color syntax 'normal)]
                   [number-color (get-color syntax 'number)]
                   [keyword-color (get-color syntax 'keyword)]
                   [identify-color (get-color syntax 'identify)])
               (let loop ([i 0]
                          [index 0]
                          [len (- (string-length text) 0)]
                          [c (string-ref text 0)])
                 (if (< i len)
                     (let ([token-len 0] [text-color '()])
                       (cond
                         [(is-delimiter c)
                          (cond
                            [(equal? #\space c)
                             (let ([ni (eat-space text (+ i 1))])
                               (set! token-len (- ni i))
                               (set! text-color normal-color))]
                            [(equal? #\" c)
                             (let ([ni (parse-string text (+ i 1))])
                               (set! token-len (- ni i))
                               (set! text-color string-color))]
                            [(is-operator c)
                             (begin
                               (set! token-len 1)
                               (set! text-color operator-color))]
                            [(is-comment c)
                             (let ([ni (parse-comment text (+ i 1))])
                               (set! token-len (- ni i))
                               (set! text-color comment-color))]
                            [(is-nl c)
                             (let ([ni (eat-nl text (+ i 1))])
                               (set! token-len (- ni i)))]
                            [else
                             (set! token-len 1)
                             (set! text-color normal-color)])]
                         [else
                          (let* ([ni (get-next-token text i)]
                                 [token (substring text i ni)])
                            (cond
                              [(is-number token)
                               (set! text-color number-color)]
                              [(is-keyword keywords token)
                               (set! text-color keyword-color)]
                              [(is-identifier identifies token)
                               (set! text-color identify-color)]
                              [else (set! text-color normal-color)])
                            (set! token-len (- ni i)))])
                       (if (< i 220) '())
                       (if (not (null? text-color))
                           (begin
                             (set-color colored index token-len text-color
                               text)
                             (set! index (+ index token-len))))
                       (set! i (+ i token-len))
                       (if (< i len)
                           (loop i index len (string-ref text i)))))
                 colored)))
         (catch (lambda (x) (display-condition x)))))
  (define (parse-syntax2 syntax text)
    (let ([keywords (vector-ref syntax 0)]
          [identifies (vector-ref syntax 1)])
      (let ([colored (make-vector (string-length text))]
            [index 0])
        (let loop ([i 0]
                   [len (- (string-length text) 2)]
                   [c (string-ref text 0)])
          (if (< i len)
              (begin
                (cond
                  [(is-delimiter c)
                   (cond
                     [(equal? #\space c)
                      (let ([ni (eat-space text (+ i 1))])
                        (vector-set!
                          colored
                          index
                          (cons (substring text i ni) 4291611852))
                        (set! index (+ index 1))
                        (set! i ni))]
                     [(equal? #\" c)
                      (let ([ni (parse-string text (+ i 1))])
                        (vector-set!
                          colored
                          index
                          (cons (substring text i ni) 4293319540))
                        (set! index (+ index 1))
                        (set! i ni))]
                     [(is-operator c)
                      (begin
                        (vector-set!
                          colored
                          index
                          (cons (format "~a" c) 4294506738))
                        (set! index (+ index 1))
                        (set! i (+ i 1)))]
                     [(is-comment c)
                      (let ([ni (parse-comment text (+ i 1))])
                        (vector-set!
                          colored
                          index
                          (cons (substring text i ni) 4285886814))
                        (set! index (+ index 1))
                        (set! i ni))]
                     [(is-nl c)
                      (begin
                        (vector-set!
                          colored
                          index
                          (cons (format "~a" c) 4278255360))
                        (set! index (+ index 1))
                        (set! i (eat-nl text (+ i 1))))]
                     [else (set! i (+ i 1))])]
                  [else
                   (let* ([ti (get-next-token text i)]
                          [token (substring text i ti)])
                     (cond
                       [(is-number token)
                        (vector-set! colored index (cons token 4289626623))
                        (set! index (+ index 1))]
                       [(is-keyword keywords token)
                        (vector-set! colored index (cons token 4284930543))
                        (set! index (+ index 1))]
                       [(is-identifier identifies token)
                        (vector-set! colored index (cons token 4288016487))
                        (set! index (+ index 1))]
                       [else
                        (vector-set! colored index (cons token 4278242304))
                        (set! index (+ index 1))])
                     (set! i ti))])
                (if (< i len) (loop i len (string-ref text i))))))
        (list colored index)))))

