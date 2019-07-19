;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui duck)
  (export dialog button image text scroll edit video tab tree
    view pop progress)
  (import (scheme) (utils libutil) (gui video) (gui edit)
    (gui widget) (gui draw) (gui graphic) (gui layout) (gui stb)
    (gui syntax))
  (define (default-attrs widget)
    (let* ([text (widget-get-attr widget %text)]
           [font-name (widget-get-attrs widget 'font-name '())]
           [font-size 20.0]
           [font (graphic-get-font font-name font-size)]
           [text (widget-get-attr widget %text)])
      (widget-set-attrs widget 'font font)
      (widget-set-attrs widget 'font-size font-size)
      (widget-set-attrs
        widget
        'line-height
        (draw-get-text-lineh font font-size))
      (widget-set-attrs
        widget
        'text-width
        (draw-get-text-width font font-size text))
      (widget-set-attrs widget 'text-align 'center)
      (widget-set-attrs
        widget
        'text-height
        (draw-get-text-height font font-size))
      (widget-set-attrs
        widget
        "%event-font-size-hook"
        (lambda (ww name value)
          (let ([font-name (widget-get-attrs widget 'font-name '())])
            (graphic-get-font font-name value)
            (hashtable-set! (vector-ref widget %attrs) 'font-size value)
            (widget-set-attrs widget 'font font)
            (widget-set-attrs
              widget
              'line-height
              (draw-get-text-lineh font value)))))))
  (define default-new-event
    (widget-add-new-event default-attrs))
  (define (progress w h percent)
    (let ([widget (widget-new 0.0 0.0 w h "")])
      (widget-set-attrs widget 'color 1157562368)
      (widget-set-attrs widget 'background 1145587784)
      (widget-set-attrs widget 'percent percent)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([gx (+ (vector-ref parent %gx)
                       (vector-ref widget %x))]
                [gy (+ (vector-ref parent %gy) (vector-ref widget %y))]
                [background (widget-get-attrs widget 'background)]
                [color (widget-get-attrs widget 'color)]
                [percent (widget-get-attrs widget 'percent)])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (draw-rect gx gy w h background)
            (draw-rect (+ gx) (+ gy) (* percent w) h color))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-mouse-button)
                (begin
                  (if (procedure? (widget-get-events widget 'click))
                      ((widget-get-events widget 'click)
                        widget
                        parent
                        type
                        data)))))))
      widget))
  (define (pop w h text)
    (let ([widget (widget-new 0.0 0.0 w h text)])
      (widget-set-padding widget 20.0 0.0 20.0 0.0)
      (widget-set-layout
        widget
        (lambda (widget . args) (pop-layout widget)))
      (widget-set-attrs
        widget
        '%event-rect-function
        (lambda (ww mx my)
          (let ([in #f]
                [lmx (- mx (vector-ref widget %x))]
                [lmy (- my (vector-ref widget %y))])
            (if (is-in widget (vector mx my)) (set! in #t))
            (let loop ([c (widget-get-child ww)])
              (if (pair? c)
                  (begin
                    (if (widget-rect-fun (car c) lmx lmy)
                        (begin (set! in #t))
                        (loop (cdr c))))))
            in)))
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([x (vector-ref widget %x)]
                [y (vector-ref widget %y)]
                [w (vector-ref widget %w)]
                [h (vector-ref widget %h)]
                [draw (vector-ref widget %draw)]
                [gx (widget-in-parent-gx widget parent)]
                [gy (widget-in-parent-gy widget parent)]
                [color (widget-get-attrs widget 'color)]
                [background (widget-get-attrs widget 'background)]
                [hover-background (widget-get-attrs
                                    widget
                                    'hover-background)])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (draw-item-bg gx gy w h background)
            (if (= (widget-get-attr widget %status) %status-active)
                (draw-hover gx gy (widget-get-attr widget %w)
                  (widget-get-attr widget %h) hover-background))
            (draw-widget-text widget))
          (if (equal? #t (widget-get-attrs widget 'static))
              (widget-set-attr widget %status %status-active))
          (if (= (widget-get-attr widget %status) %status-active)
              (widget-draw-child widget))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-motion)
                (begin
                  (widget-set-cursor 'arrow)
                  (if (is-in widget data)
                      (begin
                        (if (= %status-default
                               (widget-get-attr widget %status))
                            (begin
                              (if (not (null?
                                         (widget-get-attr widget %parent)))
                                  (begin
                                    (widget-set-child-attr
                                      (widget-get-attr widget %parent)
                                      %status
                                      %status-default)))
                              (widget-set-attr
                                widget
                                %status
                                %status-active))))
                      (begin
                        (if (= %status-default
                               (widget-get-attr widget %status))
                            (widget-set-child-attr
                              widget
                              %status
                              %status-default))))
                  (if (= (widget-get-attr widget %status) %status-active)
                      (widget-child-rect-event-mouse-motion
                        widget
                        type
                        data))))
            (if (= type %event-motion-out)
                (begin
                  (widget-set-attr widget %status %status-default)
                  (widget-set-child-attr widget %status %status-default)))
            (if (and (= type %event-mouse-button)
                     (= (vector-ref data 1) 1))
                (begin
                  (if (is-in-widget
                        widget
                        (vector-ref data 3)
                        (vector-ref data 4))
                      (let ()
                        (if (= 0 (widget-get-attr widget %status))
                            (begin
                              (if (not (null?
                                         (widget-get-attr widget %parent)))
                                  (begin
                                    (widget-set-child-attr
                                      (widget-get-attr widget %parent)
                                      %status
                                      %status-default))))
                            (begin
                              (let ([proot (widget-get-parent-cond
                                             widget
                                             (lambda (p)
                                               (widget-get-attrs
                                                 p
                                                 'root)))])
                                (widget-set-attr
                                  proot
                                  %status
                                  %status-default)
                                (widget-set-child-attr
                                  proot
                                  %status
                                  %status-default))))
                        (widget-layout-update (widget-get-root widget))
                        (if (and (procedure?
                                   (widget-get-events widget 'click))
                                 (equal?
                                   %status-active
                                   (widget-get-attr widget %status)))
                            (begin
                              ((widget-get-events widget 'click)
                                widget
                                parent
                                type
                                data)
                              (widget-set-attr
                                widget
                                %status
                                %status-default)))))
                  (let ([ret (widget-child-rect-event-mouse-button
                               widget
                               type
                               data)])
                    '()))))
          #t))
      widget))
  (define (tree w h text)
    (let ([widget (widget-new 0.0 0.0 w h text)])
      (widget-set-attrs widget 'text-align 'left-top)
      (widget-set-padding widget 20.0 0.0 20.0 0.0)
      (widget-set-layout
        widget
        (lambda (widget . args) (linear-layout widget)))
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([x (vector-ref widget %x)]
                [y (vector-ref widget %y)]
                [w (vector-ref widget %w)]
                [h (vector-ref widget %h)]
                [draw (vector-ref widget %draw)])
            (if (null? parent)
                (let ([gx (+ (vector-ref widget %x))]
                      [gy (+ (vector-ref widget %y))])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy))
                (let ([gx (+ (vector-ref parent %gx)
                             (vector-ref widget %x))]
                      [gy (+ (vector-ref parent %gy)
                             (vector-ref widget %y))])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy)
                  (draw-widget-text widget)))
            (if (= (widget-get-attr widget %status) 1)
                (widget-draw-child widget)))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (widget-set-cursor 'hand)
            (if (and (= type %event-mouse-button)
                     (= (vector-ref data 1) 1))
                (begin
                  (if (is-in-widget-top
                        widget
                        (vector-ref data 3)
                        (vector-ref data 4))
                      (let ()
                        (if (= 0 (widget-get-attr widget %status))
                            (widget-set-attr widget %status 1)
                            (widget-set-attr widget %status 0))
                        (widget-layout-update (widget-get-root widget))
                        (if (procedure? (widget-get-events widget 'click))
                            ((widget-get-events widget 'click)
                              widget
                              parent
                              type
                              data)))
                      (widget-child-rect-event-mouse-button
                        widget
                        type
                        data)))))
          #t))
      widget))
  (define (scroll w h)
    (let ([widget (widget-new 0.0 0.0 w h "")])
      (widget-set-attrs widget 'direction 1)
      (widget-set-attrs widget 'rate 50.0)
      (widget-set-attrs widget 'scroll-x 0.0)
      (widget-set-attrs widget 'scroll-y 0.0)
      (widget-set-attrs widget 'scroll-height 0.0)
      (widget-set-attrs widget 'show-scroll #t)
      (widget-set-layout
        widget
        (lambda (widget . args)
          (flow-layout widget)
          (widget-set-attrs
            widget
            'scroll-height
            (calc-child-height widget))
          (widget-set-attrs widget 'scroll-y 0.0)))
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([x (vector-ref widget %x)]
                [y (vector-ref widget %y)]
                [w (vector-ref widget %w)]
                [h (vector-ref widget %h)]
                [draw (vector-ref widget %draw)])
            (if (null? parent)
                (let ([gx (+ (vector-ref widget %x))]
                      [gy (+ (vector-ref widget %y))]
                      [background (widget-get-attrs widget 'background)])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy)
                  (graphic-sissor-begin gx gy w h)
                  (if (equal? '() background)
                      '()
                      (draw-panel gx gy w h '() background)))
                (let ([gx (+ (vector-ref parent %gx)
                             (vector-ref widget %x))]
                      [gy (+ (vector-ref parent %gy)
                             (vector-ref widget %y))]
                      [background (widget-get-attrs widget 'background)])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy)
                  (graphic-sissor-begin gx gy w h)
                  (if (equal? '() background)
                      '()
                      (draw-panel gx gy w h '() background))
                  (if (equal? #t (widget-get-attrs widget 'show-scroll))
                      (draw-scroll-bar (+ gx w -10.0) gy 10.0 h
                        (widget-get-attrs widget 'scroll-y)
                        (+ (widget-get-attrs widget 'scroll-height)
                           -40.0)))))
            (widget-draw-rect-child widget)
            (graphic-sissor-end))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type 3) (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-scroll)
                (begin
                  (widget-set-attrs
                    widget
                    'scroll-height
                    (calc-child-height widget))
                  (let ([offsety (* -1.0
                                    (widget-get-attrs widget 'rate)
                                    (vector-ref data 1))])
                    (if (< (+ (widget-get-attrs widget 'scroll-y) offsety)
                           0)
                        (begin
                          (set! offsety 0.0)
                          (widget-layout-update widget)
                          (widget-set-attrs widget 'scroll-y 0.0))
                        (if (> (+ (widget-get-attrs widget 'scroll-y)
                                  offsety)
                               (widget-get-attrs widget 'scroll-height))
                            (begin
                              (set! offsety 0.0)
                              (widget-set-attrs
                                widget
                                'scroll-y
                                (widget-get-attrs widget 'scroll-height)))
                            (begin
                              (widget-set-attrs
                                widget
                                'scroll-y
                                (+ (widget-get-attrs widget 'scroll-y)
                                   offsety))
                              (plus-child-y-offset widget offsety))))
                    (widget-child-rect-event-scroll widget type data))))
            (if (= type %event-mouse-button)
                (begin
                  (widget-child-rect-event-mouse-button widget type data)))
            (if (= type %event-key)
                (begin (widget-child-key-event widget type data)))
            (if (= type %event-char)
                (begin (widget-child-key-event widget type data)))
            (if (= type %event-motion)
                (begin
                  (widget-child-rect-event-mouse-motion
                    widget
                    type
                    data))))))
      widget))
  (define (edit w h text)
    (let* ([widget (widget-new 0.0 0.0 w h text)]
           [ed (edit-new
                 (widget-get-attrs widget 'font)
                 (widget-get-attrs widget 'font-size)
                 w
                 h)])
      (widget-set-attrs widget '%edit ed)
      (widget-set-attrs
        widget
        (format "%event-~a" %text)
        (lambda (ww text)
          (edit-set-text (widget-get-attrs ww '%edit) text)
          (widget-set-attr widget %h (edit-get-height ed))
          (widget-layout-event widget)
          (if (equal? #t (widget-get-attrs ww 'syntax-on))
              (let ([syntax-cache (edit-get-highlight ed)]
                    [syn (widget-get-attrs widget 'syntax)]
                    [params (edit-get-text ed)])
                (printf "re render syntax ~a\n" syntax-cache)
                (parse-syntax syn syntax-cache params)
                (edit-update-highlight ed)))))
      (widget-set-attrs
        widget
        "%event-color-hook"
        (lambda (ww name color)
          (edit-set-color (widget-get-attrs ww '%edit) color)))
      (widget-set-attrs
        widget
        "%event-cursor-color-hook"
        (lambda (ww name color)
          (edit-set-cursor-color (widget-get-attrs ww '%edit) color)))
      (widget-set-attrs
        widget
        "%event-font-line-height-hook"
        (lambda (ww name val)
          (edit-set-font-line-height (widget-get-attrs ww '%edit) val)
          (widget-layout-event widget)))
      (widget-set-attrs
        widget
        "%event-select-color-hook"
        (lambda (ww name color)
          (edit-set-select-color (widget-get-attrs ww '%edit) color)))
      (widget-set-attrs
        widget
        "%event-font-hook"
        (lambda (ww name value)
          (edit-set-font (widget-get-attrs ww '%edit) value -1)
          (widget-layout-event widget)))
      (widget-set-attrs
        widget
        "%event-font-size-hook"
        (lambda (ww name value)
          (edit-set-font (widget-get-attrs ww '%edit) 0 value)
          (widget-layout-event widget)))
      (widget-set-attrs
        widget
        "%event-show-no-hook"
        (lambda (ww name value)
          (edit-set-show-no (widget-get-attrs ww '%edit) value)
          (widget-layout-event widget)))
      (widget-set-attrs
        widget
        "%event-lineno-color-hook"
        (lambda (ww name value)
          (edit-set-lineno-color (widget-get-attrs ww '%edit) value)))
      (widget-set-attrs
        widget
        "%event-insert-text-at-hook"
        (lambda (ww name value)
          (edit-insert-text-at
            (widget-get-attrs ww '%edit)
            (list-ref value 0)
            (list-ref value 1)
            (list-ref value 2))
          (if (equal? #t (widget-get-attrs widget 'syntax-on))
              (let* ([ed (widget-get-attrs ww '%edit)]
                     [syntax-cache (edit-get-highlight ed)]
                     [syn (widget-get-attrs widget 'syntax)])
                (widget-set-attrs widget 'syntax-cache syntax-cache)
                (printf "text ==>~a\n" (edit-get-text ed))
                (edit-update-highlight ed)))))
      (widget-set-attrs
        widget
        "%event-get-selection-hook"
        (lambda (ww name)
          (edit-get-selection (widget-get-attrs ww '%edit))))
      (widget-set-attrs
        widget
        "%event-get-selection-hook"
        (lambda (ww name)
          (edit-get-selection (widget-get-attrs ww '%edit))))
      (widget-set-attrs
        widget
        "%event-get-line-count-hook"
        (lambda (ww name)
          (edit-get-line-count (widget-get-attrs ww '%edit))))
      (widget-set-attrs
        widget
        "%event-get-cursor-x-hook"
        (lambda (ww name)
          (edit-get-cursor-x (widget-get-attrs ww '%edit))))
      (widget-set-attrs
        widget
        "%event-get-cursor-y-hook"
        (lambda (ww name)
          (edit-get-cursor-y (widget-get-attrs ww '%edit))))
      (widget-set-attrs
        widget
        "%event-get-cursor-xy-hook"
        (lambda (ww name)
          (list
            (edit-get-cursor-x (widget-get-attrs ww '%edit))
            (edit-get-cursor-y (widget-get-attrs ww '%edit)))))
      (widget-set-attrs
        widget
        "%event-get-last-row-count-hook"
        (lambda (ww name)
          (edit-get-row-count
            (widget-get-attrs ww '%edit)
            (- (edit-get-line-count (widget-get-attrs ww '%edit)) 1))))
      (widget-set-attrs
        widget
        "%event-selection-hook"
        (lambda (ww name val)
          (edit-set-selection (widget-get-attrs ww '%edit) (list-ref val 0)
            (list-ref val 1) (list-ref val 2) (list-ref val 3))))
      (widget-set-attrs
        widget
        "%event-get-text-range-hook"
        (lambda (ww name val)
          (edit-get-text-range (widget-get-attrs ww '%edit) (list-ref val 0)
            (list-ref val 1) (list-ref val 2) (list-ref val 3))))
      (widget-set-attrs
        widget
        "%event-get-current-line-text-hook"
        (lambda (ww name)
          (let* ([ed (widget-get-attrs ww '%edit)]
                 [current-row (edit-get-selection-row-start ed)]
                 [row-count (edit-get-row-count ed current-row)])
            (edit-get-text-range ed current-row 0 current-row
              row-count))))
      (widget-set-attrs
        widget
        "%event-syntax-on-hook"
        (lambda (ww name val)
          (if (equal? #t (widget-get-attrs widget 'syntax-on))
              (let ([syntax-cache (edit-get-highlight ed)]
                    [syn (widget-get-attrs widget 'syntax)])
                (widget-set-attrs widget 'syntax syn)
                (widget-set-attrs widget 'syntax-cache syntax-cache)
                (parse-syntax syn syntax-cache (edit-get-text ed))
                (edit-update-highlight ed)
                (widget-set-attr widget %h (edit-get-height ed))))))
      (edit-set-text ed text)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([gx (widget-in-parent-gx widget parent)]
                [gy (widget-in-parent-gy widget parent)]
                [background (widget-get-attrs widget 'background)]
                [border (widget-get-attrs widget 'border)]
                [ww (vector-ref widget %w)]
                [hh (vector-ref widget %h)])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (if (equal? '() background)
                '()
                (draw-panel gx gy ww hh '() background))
            (if (number? border) (draw-border gx gy ww hh border))
            (draw-edit ed gx gy))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (= type %event-key)
              (begin
                (edit-key-event ed (vector-ref data 0) (vector-ref data 1)
                  (vector-ref data 2) (vector-ref data 3))
                (if (equal? #t (widget-get-attrs widget 'syntax-on))
                    (let ([syntax-cache (edit-get-highlight ed)]
                          [params '()]
                          [syn (widget-get-attrs widget 'syntax)])
                      '()
                      (set! params (edit-get-text ed))
                      (parse-syntax syn syntax-cache params)
                      (edit-update-highlight ed)))))
          (if (= type %event-char)
              (begin
                (edit-char-event
                  ed
                  (vector-ref data 0)
                  (vector-ref data 1))
                (vector-set! widget %text (edit-get-text ed))
                (if (equal? #t (widget-get-attrs widget 'syntax-on))
                    (let ([syntax-cache (edit-get-highlight ed)]
                          [params '()]
                          [syn (widget-get-attrs widget 'syntax)])
                      (set! params (edit-get-text ed))))))
          (if (= type %event-motion)
              (begin
                (widget-set-cursor 'ibeam)
                (edit-mouse-motion-event
                  ed
                  (vector-ref data 0)
                  (vector-ref data 1))))
          (if (= type %event-layout)
              (begin
                '()
                (widget-set-attr widget %h (edit-get-height ed))))
          (if (= type %event-scroll)
              (begin
                (edit-set-scroll
                  ed
                  (widget-get-attr widget %x)
                  (widget-get-attr widget %y))))
          (if (= type %event-mouse-button)
              (begin
                (edit-mouse-event
                  ed
                  (vector-ref data 1)
                  (vector-ref data 3)
                  (vector-ref data 4))))))
      widget))
  (define (tab w h names)
    (let ([widget (widget-new 0.0 0.0 w h "")])
      (widget-set-layout
        widget
        (lambda (widget . args)
          (frame-layout widget)
          (let ([child (widget-get-child widget)] [count 0])
            (let loop ([c child])
              (if (pair? c)
                  (begin
                    (if (= (widget-get-attr (car child) %status) 1)
                        (set! count (+ count 1)))
                    (loop (car c)))))
            (if (and (= count 0)
                     (> (length child) 0)
                     (= 0 (widget-get-attr (car child) %status)))
                (widget-set-attr (car child) %status 1)))))
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([gx (+ (vector-ref parent %gx)
                       (vector-ref widget %x))]
                [gy (+ (vector-ref parent %gy) (vector-ref widget %y))]
                [segment (/ (vector-ref widget %w)
                            (length (widget-get-child widget)))]
                [font (widget-get-attrs widget 'font)]
                [font-size (widget-get-attrs widget 'font-size)])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (graphic-sissor-begin gx gy w h)
            (let loop ([child (widget-get-child widget)]
                       [name names]
                       [pos 0.0])
              (if (pair? child)
                  (begin
                    (draw-tab (+ gx pos) gy (- segment 5.0) 30.0
                      (= 1 (widget-get-attr (car child) %status)))
                    (draw-text font font-size
                      (+ gx
                         pos
                         (/ segment 2.0)
                         (- (* 4 (string-length (car name)))))
                      (+ gy 1.0) (car name))
                    (loop (cdr child) (cdr name) (+ pos segment)))))
            (let loop ([child (vector-ref widget %child)])
              (if (pair? child)
                  (begin
                    (if (= (vector-ref (car child) %status) 1)
                        ((vector-ref (car child) %draw)
                          (car child)
                          widget))
                    (loop (cdr child)))))
            (graphic-sissor-end))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-mouse-button)
                (let ([segment (/ (vector-ref widget %w)
                                  (length (widget-get-child widget)))]
                      [lmx (vector-ref data 3)]
                      [lmy (vector-ref data 4)]
                      [lx (vector-ref widget %x)]
                      [ly (vector-ref widget %y)])
                  (let loop ([child (widget-get-child widget)] [pos 0.0])
                    (if (pair? child)
                        (begin
                          (if (in-rect (+ lx pos) (+ ly) (+ segment)
                                (+ 30.0) lmx lmy)
                              (begin
                                (widget-set-child-attr widget %status 0)
                                (vector-set! (car child) %status 1)
                                ((vector-ref (car child) %event)
                                  (car child)
                                  widget
                                  type
                                  data)))
                          (loop (cdr child) (+ pos segment)))))
                  (widget-child-rect-event-mouse-button
                    widget
                    type
                    data
                    (lambda (wid lmx lmy)
                      (and (is-in-widget wid lmx lmy)
                           (= (widget-get-attr wid %status) 1))))))
            (if (= type %event-scroll)
                (begin (widget-child-rect-event-scroll widget type data)))
            (if (= type %event-key)
                (begin (widget-child-key-event widget type data)))
            (if (= type %event-char)
                (begin (widget-child-key-event widget type data))))))
      (widget-set-padding widget 10.0 10.0 40.0 10.0)
      widget))
  (define (text w h text)
    (let ([widget (widget-new 0.0 0.0 w h text)])
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([gx (+ (vector-ref parent %gx)
                       (vector-ref widget %x))]
                [gy (+ (vector-ref parent %gy) (vector-ref widget %y))])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (draw-widget-text widget))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-mouse-button)
                (begin (draw-widget-child-rect parent widget))))))
      widget))
  (define (video w h src)
    (let ([widget (widget-new 0.0 0.0 w h src)]
          [vv (video-new
                src
                (widget-get-window-width)
                (widget-get-window-height))])
      (widget-set-attrs widget 'video vv)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (if (null? parent)
              (let ([gx (+ (vector-ref widget %x))]
                    [gy (+ (vector-ref widget %y))])
                (vector-set! widget %gx gx)
                (vector-set! widget %gy gy)
                (draw-video vv gx gy w h))
              (let ([gx (+ (vector-ref parent %gx)
                           (vector-ref widget %x))]
                    [gy (+ (vector-ref parent %gy)
                           (vector-ref widget %y))])
                (vector-set! widget %gx gx)
                (vector-set! widget %gy gy)
                (draw-video vv gx gy w h)))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-mouse-button)
                (begin (draw-widget-child-rect parent widget))))))
      widget))
  (define (image w h src)
    (let* ([widget (widget-new 0.0 0.0 w h src)]
           [attrs (widget-attrs widget)]
           [id (load-texture src attrs)])
      (widget-set-attrs widget 'src src)
      (widget-set-attrs widget 'src-id id)
      (widget-set-attrs widget 'load #t)
      (widget-set-attrs widget 'mode 'fix-xy)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (if (equal? #f (widget-get-attrs widget 'load))
              (let ([res (load-texture
                           (widget-get-attrs widget 'src)
                           attrs)])
                (widget-set-attrs widget 'src-id res)
                (widget-set-attrs widget 'load #t)))
          (if (null? parent)
              (let ([gx (+ (vector-ref widget %x))]
                    [gy (+ (vector-ref widget %y))])
                (vector-set! widget %gx gx)
                (vector-set! widget %gy gy)
                (draw-image gx gy w h id attrs))
              (let ([gx (+ (vector-ref parent %gx)
                           (vector-ref widget %x))]
                    [gy (+ (vector-ref parent %gy) (vector-ref widget %y))]
                    [id (widget-get-attrs widget 'src-id)])
                (vector-set! widget %gx gx)
                (vector-set! widget %gy gy)
                (draw-image gx gy w h id attrs)))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-mouse-button)
                (begin
                  (if (procedure? (widget-get-events widget 'click))
                      ((widget-get-events widget 'click)
                        widget
                        parent
                        type
                        data))
                  (draw-widget-child-rect parent widget))))))
      widget))
  (define (view w h)
    (let ([widget (widget-new 0.0 0.0 w h "")])
      (widget-set-layout widget flow-layout)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([x (vector-ref widget %x)]
                [y (vector-ref widget %y)]
                [w (vector-ref widget %w)]
                [h (vector-ref widget %h)]
                [draw (vector-ref widget %draw)])
            (if (null? parent)
                (let ([gx (+ (vector-ref widget %x))]
                      [gy (+ (vector-ref widget %y))]
                      [background (widget-get-attrs widget 'background)])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy)
                  (graphic-sissor-begin gx gy w h)
                  (if (equal? '() background)
                      (draw-panel gx gy w h '())
                      (draw-panel gx gy w h '() background)))
                (let ([gx (+ (vector-ref parent %gx)
                             (vector-ref widget %x))]
                      [gy (+ (vector-ref parent %gy)
                             (vector-ref widget %y))]
                      [background (widget-get-attrs widget 'background)])
                  (vector-set! widget %gx gx)
                  (vector-set! widget %gy gy)
                  (graphic-sissor-begin gx gy w h)
                  (if (equal? '() background)
                      (draw-panel gx gy w h '())
                      (draw-panel gx gy w h '() background))))
            (widget-draw-child widget)
            (graphic-sissor-end))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (and (= type %event-mouse-button))
              (begin
                (widget-child-rect-event-mouse-button widget type data)))
          (if (= type %event-scroll)
              (begin (widget-child-rect-event-scroll widget type data)))
          (if (and (or (= type %event-char) (= type %event-key)))
              (begin
                (widget-child-key-event widget type data)
                (if (= type %event-key)
                    (widget-child-focus-event widget type data))))
          (if (= type %event-motion)
              (widget-child-rect-event-mouse-motion widget type data))))
      widget))
  (define (button w h text)
    (let ([widget (widget-new 0.0 0.0 w h text)])
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([gx (+ (vector-ref parent %gx)
                       (vector-ref widget %x))]
                [gy (+ (vector-ref parent %gy) (vector-ref widget %y))]
                [background (widget-get-attrs widget 'background)]
                [hover-background (widget-get-attrs
                                    widget
                                    'hover-background)])
            (vector-set! widget %gx gx)
            (vector-set! widget %gy gy)
            (draw-item-bg gx gy w h background)
            (if (widget-status-is-set widget %status-hover)
                (draw-hover gx gy (widget-get-attr widget %w)
                  (widget-get-attr widget %h) hover-background))
            (draw-widget-text widget))))
      (widget-set-event
        widget
        (lambda (widget parent type data)
          (if (null? parent)
              (begin
                (if (= type %event-mouse-button)
                    (draw-widget-child-rect parent widget))))
          (begin
            (if (= type %event-motion)
                (begin (widget-set-status widget %status-hover)))
            (if (= type %event-motion-out)
                (begin (widget-set-attr widget %status %status-default)))
            (if (= type %event-mouse-button)
                (begin
                  (if (procedure? (widget-get-events widget 'click))
                      ((widget-get-events widget 'click)
                        widget
                        parent
                        type
                        data)))))))
      widget))
  (define (dialog x y w h title)
    (let ([widget (widget-new x y w h title)])
      (widget-set-attrs widget 'head-height 30.0)
      (widget-set-layout widget flow-layout)
      (widget-set-draw
        widget
        (lambda (widget parent)
          (let ([x (vector-ref widget %x)]
                [y (vector-ref widget %y)]
                [w (vector-ref widget %w)]
                [h (vector-ref widget %h)]
                [draw (vector-ref widget %draw)])
            (vector-set! widget %gx x)
            (vector-set! widget %gy y)
            (graphic-sissor-begin x y w h)
            (draw-dialog widget)
            (let loop ([child (vector-ref widget %child)])
              (if (pair? child)
                  (begin
                    ((vector-ref (car child) %draw) (car child) widget)
                    (loop (cdr child)))))
            (graphic-sissor-end))))
      (widget-add-event
        widget
        (lambda (widget parent type data)
          (if (= type %event-scroll)
              (begin (widget-child-rect-event-scroll widget type data)))
          (if (and (or (= type %event-char) (= type %event-key)))
              (begin
                (widget-child-key-event widget type data)
                (if (= type %event-key)
                    (widget-child-focus-event widget type data))))
          (if (= type %event-motion)
              (begin
                (widget-child-rect-event-mouse-motion widget type data)))
          (if (= type %event-motion-out)
              (begin
                (widget-child-rect-event-mouse-motion widget type data)))
          (if (and (= type %event-mouse-button)
                   (= (vector-ref data 1) 1))
              (if (equal? #t (widget-get-attrs widget 'disable-active))
                  '()
                  (widget-active widget))
              #t)))
      (widget-set-padding widget 10.0 10.0 40.0 40.0)
      (widget-add widget)
      widget)))

