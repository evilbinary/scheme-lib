;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui layout)
  (export linear-layout frame-layout flow-layout grid-layout
    pop-layout free-layout calc-child-height
    calc-all-child-line-height %match-parent %wrap-content
    %fill-rest)
  (import (scheme) (utils libutil) (gui widget) (cffi cffi))
  (define %match-parent -1.0)
  (define %wrap-content 0)
  (define %fill-rest -2.0)
  (define (grid-layout row col) (lambda (widget row col) '()))
  (define (free-layout widget)
    (let ([x (vector-ref widget %x)]
          [y (vector-ref widget %y)]
          [w (vector-ref widget %w)]
          [h (vector-ref widget %h)]
          [top (vector-ref widget %top)]
          [left (vector-ref widget %left)]
          [right (vector-ref widget %right)]
          [bottom (vector-ref widget %bottom)]
          [child (vector-ref widget %child)])
      (let loop ([c child])
        (if (pair? c)
            (begin
              (process-match-parent (car c))
              (if (procedure? (vector-ref (car c) %layout))
                  ((vector-ref (car c) %layout) (car c)))
              (loop (cdr c))))))
    (widget-child-update-pos widget))
  (define pop-layout
    (case-lambda
      [(widget)
       (process-match-parent widget)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)]
             [top (vector-ref widget %top)]
             [left (vector-ref widget %left)]
             [right (vector-ref widget %right)]
             [bottom (vector-ref widget %bottom)]
             [sx 0.0]
             [sy 0.0]
             [child (vector-ref widget %child)])
         (begin
           (if (equal? #t (widget-get-attrs widget 'root))
               (begin
                 (widget-set-attr widget %status 0)
                 (set! sy h)
                 (set! sx 0.0))
               (begin (set! sy 0.0) (set! sx w)))
           (if (equal? #t (widget-get-attrs widget 'center))
               (begin (set! sy 0.0) (set! sx 0.0))))
         (let loop ([c child] [px sx] [py sy])
           (if (pair? c)
               (begin
                 (if (procedure? (vector-ref (car c) %layout))
                     ((vector-ref (car c) %layout) (car c)))
                 (vector-set! (car c) %x px)
                 (vector-set! (car c) %y py)
                 (if (equal? #t (widget-get-attrs widget 'center))
                     (set! px (+ px (widget-get-attr (car c) %w)))
                     (set! py (+ py (widget-get-attr (car c) %h))))
                 (loop (cdr c) px py)))))]
      [(widget layout-info)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)])
         '())]))
  (define (process-match-parent c)
    (let ([parent (vector-ref c %parent)]
          [window-width (widget-get-window-width)]
          [window-height (widget-get-window-height)])
      (if (= (widget-get-attrs c '%w) %match-parent)
          (if (null? parent)
              (begin (widget-set-attr c %w (* 1.0 window-width)))
              (begin (widget-set-attr c %w (widget-get-attr parent %w)))))
      (if (= (widget-get-attrs c '%h) %match-parent)
          (if (null? parent)
              (begin (widget-set-attr c %h (* 1.0 window-height)))
              (widget-set-attr c %h (widget-get-attr parent %h))))))
  (define linear-layout
    (case-lambda
      [(widget)
       (process-match-parent widget)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)]
             [top (vector-ref widget %top)]
             [left (vector-ref widget %left)]
             [right (vector-ref widget %right)]
             [bottom (vector-ref widget %bottom)]
             [child (vector-ref widget %child)])
         (if (widget-get-attr widget %visible)
             (let loop ([c child] [px left] [py top])
               (if (pair? c)
                   (begin
                     (process-match-parent (car c))
                     (vector-set! (car c) %x px)
                     (vector-set! (car c) %y py)
                     (if (widget-get-attr (car c) %visible)
                         (begin
                           (if (procedure? (vector-ref (car c) %layout))
                               ((vector-ref (car c) %layout) (car c)))
                           (set! py (+ py (widget-get-attr (car c) %h))))
                         (begin
                           (widget-set-attr
                             (car c)
                             %h
                             (widget-get-attr (car c) %top))
                           (set! py
                             (+ py (widget-get-attr (car c) %top)))))
                     (loop (cdr c) px py))
                   (widget-set-attr widget %h py)))
             (widget-set-attr widget %h (widget-get-attr widget %top)))
         (widget-update-pos widget)
         (widget-child-update-pos widget))]
      [(widget layout-info)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)])
         '())]))
  (define frame-layout
    (case-lambda
      [(widget)
       (process-match-parent widget)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)]
             [top (vector-ref widget %top)]
             [left (vector-ref widget %left)]
             [right (vector-ref widget %right)]
             [bottom (vector-ref widget %bottom)]
             [child (vector-ref widget %child)])
         (let loop ([c child])
           (if (pair? c)
               (begin
                 (process-match-parent (car c))
                 (vector-set! (car c) %x left)
                 (vector-set! (car c) %y top)
                 (if (procedure? (vector-ref (car c) %layout))
                     ((vector-ref (car c) %layout) (car c)))
                 (loop (cdr c))))))]
      [(widget layout-info)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)])
         '())]))
  (define flow-layout
    (case-lambda
      [(widget)
       (process-match-parent widget)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)]
             [top (vector-ref widget %top)]
             [left (vector-ref widget %left)]
             [right (vector-ref widget %right)]
             [bottom (vector-ref widget %bottom)]
             [parent (vector-ref widget %parent)]
             [child (vector-ref widget %child)])
         (let loop ([c child] [sx left] [sy top] [ww 0])
           (if (pair? c)
               (begin
                 (process-match-parent (car c))
                 (vector-set!
                   (car c)
                   %x
                   (+ sx (vector-ref (car c) %margin-left)))
                 (vector-set!
                   (car c)
                   %y
                   (+ sy (vector-ref (car c) %margin-top)))
                 (if (= %fill-rest (widget-get-attrs (car c) '%w))
                     (begin
                       (vector-set!
                         (car c)
                         %w
                         (- w sx right (vector-ref (car c) %margin-right)
                            (vector-ref (car c) %margin-left)))))
                 (if (pair? (cdr c))
                     (begin
                       (if (= %fill-rest
                              (widget-get-attrs (car (cdr c)) '%w))
                           (begin (set! ww 0))
                           (set! ww (vector-ref (car (cdr c)) %w)))))
                 (if (> (+ sx (vector-ref (car c) %w) ww)
                        (- w
                           right
                           (vector-ref (car c) %margin-right)
                           (vector-ref (car c) %margin-left)))
                     (begin
                       (set! sx left)
                       (set! sy
                         (+ sy
                            (vector-ref (car c) %h)
                            (vector-ref (car c) %margin-bottom))))
                     (begin
                       (set! sx
                         (+ sx
                            (vector-ref (car c) %w)
                            (vector-ref (car c) %margin-left)
                            (vector-ref (car c) %margin-right)))))
                 (if (procedure? (vector-ref (car c) %layout))
                     ((vector-ref (car c) %layout) (car c)))
                 (loop (cdr c) sx sy ww)))))]
      [(widget layout-info)
       (let ([x (vector-ref widget %x)]
             [y (vector-ref widget %y)]
             [w (vector-ref widget %w)]
             [h (vector-ref widget %h)])
         (process-match-parent widget))]))
  (define calc-all-child-line-height
    (case-lambda
      [(widget height)
       (let loop ([child (vector-ref widget %child)] [h 0.0])
         (if (pair? child)
             (begin
               (if (= 0 (widget-get-attr (car child) %status))
                   (set! h (+ h height))
                   (begin
                     (set! h
                       (+ h
                          (calc-all-child-line-height
                            (car child)
                            height)))))
               (loop (cdr child) h))
             h))]
      [(widget)
       (let loop ([child (vector-ref widget %child)] [h 0.0])
         (if (pair? child)
             (begin (loop (cdr child) (+ h (vector-ref (car child) %h))))
             h))]))
  (define (calc-child-height widget)
    (let loop ([child (vector-ref widget %child)] [height 0.0])
      (if (pair? child)
          (begin
            (if (widget-get-attr (car child) %visible)
                (set! height (+ height (vector-ref (car child) %h))))
            (loop (cdr child) height))
          height))))

