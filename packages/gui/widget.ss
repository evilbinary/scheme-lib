;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui widget)
  (export widget-init widget-window-resize widget-add
   widget-destroy widget-render widget-event
   widget-mouse-button-event widget-scroll-event widget-layout
   widget-set-layout widget-set-margin widget-set-xy
   draw-widget-child-rect draw-widget-rect widget-add-draw
   widget-set-draw widget-get-draw widget-set-event
   widget-get-event widget-add-event widget-get-child
   widget-get-parent widget-set-padding widget-resize
   widget-get-attr widget-set-attr widget-get-attrs
   widget-set-attrs widget-disable-custom-cursor
   widget-set-custom-cursor widget-new widget-copy
   widget-get-events widget-set-events widget-get-root
   widget-layout-update widget-set-child
   widget-get-window-width widget-get-window-height
   widget-update-pos widget-child-update-pos widget-draw-child
   widget-draw-rect-child widget-child-rect-event
   widget-find-child-focus widget-child-focus-event
   widget-get-global-center-xy widget-print widget-in-parent-gx
   widget-in-parent-gy widget-add-new-event
   widget-get-short-text widget-child-rect-event-mouse-button
   widget-child-rect-event-mouse-motion
   widget-child-rect-key-event widget-child-key-event
   widget-layout-event widget-get-parent-cond widget-rect-fun
   in-rect is-in is-in-widget-top is-in-child-widget
   widget-set-child-attr widget-set-child-attrs
   widget-set-child-status widget-clear-child-status
   widget-child-rect-event-scroll widget-active widget-event
   widget-attrs widget-status-is-set widget-set-status
   widget-clear-status plus-child-y-offset is-in-widget
   widget-is-in-widget widget-init-cursor widget-set-cursor
   widget-remove %status-active %status-default %status-hover
   %status-focus %event %event-char %event-scroll %event-layout
   %child %status %visible %gx %gy %w %h %x %y %text %parent
   %layout %top %left %right %bottom %margin-top %margin-left
   %margin-right %margin-bottom %draw %attrs
   %event-mouse-button %last-common-attr %event-key
   %event-motion %event-motion-out %event-active
   %event-deactive %event-button-down %event-button-up)
  (import (scheme) (gui keys) (gui graphic) (gui stb)
    (gui utils))
  (define %draw 5)
  (define %x 0)
  (define %y 1)
  (define %w 2)
  (define %h 3)
  (define %layout 4)
  (define %event 6)
  (define %child 7)
  (define %status 8)
  (define %top 9)
  (define %bottom 10)
  (define %left 11)
  (define %right 12)
  (define %margin-top 13)
  (define %margin-bottom 14)
  (define %margin-left 15)
  (define %margin-right 16)
  (define %parent 17)
  (define %gx 18)
  (define %gy 19)
  (define %text 20)
  (define %type 21)
  (define %attrs 22)
  (define %events 23)
  (define %visible 24)
  (define %focus 25)
  (define %focusable 26)
  (define %data 27)
  (define %last-common-attr 28)
  (define %status-default 0)
  (define %status-active 1)
  (define %status-hover 2)
  (define %status-focus 4)
  (define %status-drag 8)
  (define %status-resize 16)
  (define window-width 0)
  (define window-height 0)
  (define %event-scroll 4)
  (define %event-key 2)
  (define %event-char 5)
  (define %event-mouse-button 3)
  (define %event-motion 1)
  (define %event-resize 6)
  (define %event-layout 7)
  (define %event-motion-out 8)
  (define %event-motion-in 9)
  (define %event-focus-in 10)
  (define %event-focus-out 11)
  (define %event-active 9)
  (define %event-deactive 10)
  (define %event-button-down 1)
  (define %event-button-up 0)
  (define cursor-x 0)
  (define cursor-y 0)
  (define cursor-arrow 0)
  (define default-widget-new-events '())
  (define default-layout '())
  (define default-cursor '())
  (define default-cursor-mode '())
  (define $last-hover '())
  (define $widgets (list))
  (define (widget-init-cursor cursor)
    (set! default-cursor cursor))
  (define (widget-set-cursor mod)
    (if (procedure? default-cursor)
        (if (equal? default-cursor-mode mod)
            '()
            (begin
              (set! default-cursor-mode mod)
              (default-cursor mod)))))
  (define (widget-init-key-map)
    (let loop ([l default-key-maps])
      (if (pair? l)
          (begin
            (set-default-key-map (cadar l) (caar l))
            (set-default-key-map (caar l) (cadar l))
            (loop (cdr l))))))
  (define (plus-child-y-offset widget offsety)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (vector-set!
              (car child)
              %y
              (- (vector-ref (car child) %y) offsety))
            (loop (cdr child))))))
  (define (widget-set-margin widget left right top bottom)
    (vector-set! widget %margin-left left)
    (vector-set! widget %margin-right right)
    (vector-set! widget %margin-top top)
    (vector-set! widget %margin-bottom bottom))
  (define (widget-set-padding widget left right top bottom)
    (vector-set! widget %left left)
    (vector-set! widget %right right)
    (vector-set! widget %top top)
    (vector-set! widget %bottom bottom))
  (define (widget-set-xy widget x y)
    (vector-set! widget %x x)
    (vector-set! widget %y y))
  (define (widget-set-layout widget layout)
    (vector-set! widget %layout layout))
  (define widget-add
    (case-lambda
      [(p)
       (set! $widgets (append! $widgets (list p)))
       (if (procedure? (vector-ref p %layout))
           ((vector-ref p %layout) p))
       p]
      [(p w)
       (vector-set! w %parent p)
       (vector-set!
         p
         %child
         (append! (vector-ref p %child) (list w)))
       w]
      [(p w layout)
       (vector-set! w %parent p)
       (vector-set!
         p
         %child
         (append! (vector-ref p %child) (list w)))
       w]))
  (define (is-in-widget widget lmx lmy)
    (let ([x1 (vector-ref widget %x)]
          [y1 (vector-ref widget %y)]
          [w1 (vector-ref widget %w)]
          [h1 (vector-ref widget %h)]
          [parent (vector-ref widget %parent)])
      (in-rect x1 y1 (+ w1) (+ h1) lmx lmy)))
  (define (is-in-widget-top widget lmx lmy)
    (let ([x1 (vector-ref widget %x)]
          [y1 (vector-ref widget %y)]
          [w1 (vector-ref widget %w)]
          [h1 (vector-ref widget %top)]
          [parent (vector-ref widget %parent)])
      (in-rect x1 y1 (+ w1) (+ h1) lmx lmy)))
  (define (in-rect x y w h mx my)
    (and (> mx x) (< mx (+ x w)) (> my y) (< my (+ y h))))
  (define (is-in-rect x1 y1 w1 h1 x2 y2 w2 h2)
    (not (or (> x1 (+ x2 w2))
             (< (+ x1 w1) x2)
             (< (+ y1 h1) y2)
             (> y1 (+ y2 h2)))))
  (define (is-in widget data)
    (let ([x (vector-ref widget %x)]
          [y (vector-ref widget %y)]
          [w (vector-ref widget %w)]
          [h (vector-ref widget %h)]
          [parent (vector-ref widget %parent)]
          [lmx (vector-ref data 0)]
          [lmy (vector-ref data 1)])
      (if (null? parent)
          (in-rect x y w h lmx lmy)
          (begin (in-rect x y w h lmx lmy)))))
  (define (widget-is-in-widget widget widget2)
    (let ([x1 (vector-ref widget %x)]
          [y1 (vector-ref widget %y)]
          [w1 (vector-ref widget %w)]
          [h1 (vector-ref widget %h)]
          [x2 (vector-ref widget2 %x)]
          [y2 (vector-ref widget2 %y)]
          [w2 (vector-ref widget2 %w)]
          [h2 (vector-ref widget2 %h)]
          [gx2 (vector-ref widget2 %gx)]
          [gy2 (vector-ref widget2 %gy)]
          [parent (vector-ref widget2 %parent)])
      (if (null? parent)
          (is-in-rect 0 0 w1 h1 x2 y2 w2 h2)
          (begin
            (is-in-rect (+ x1 (vector-ref widget %left))
              (+ y1 (vector-ref widget %top))
              (- w1 (vector-ref widget %right) (vector-ref widget %left))
              (- h1 (vector-ref widget %bottom) (vector-ref widget %top))
              (+ x2 (vector-ref parent %x)) (+ y2 (vector-ref parent %y))
              w2 h2)))))
  (define (widget-get-global-center-xy widget)
    (list
      (+ (widget-get-attr widget %gx)
         (/ (widget-get-attr widget %w) 2))
      (+ (widget-get-attr widget %gy)
         (/ (widget-get-attr widget %h) 2))))
  (define (widget-in-parent-gx widget parent)
    (if (null? parent)
        (vector-ref widget %x)
        (+ (vector-ref parent %gx) (vector-ref widget %x))))
  (define (widget-in-parent-gy widget parent)
    (if (null? parent)
        (vector-ref widget %y)
        (+ (vector-ref parent %gy) (vector-ref widget %y))))
  (define (far gx gy a b)
    (+ (* (- gx a) (- gx a)) (* (- gy b) (- gy b))))
  (define (widget-find-child-focus widget direct gx gy)
    (let ([ret (list)])
      (let loop ([child (vector-ref widget %child)])
        (if (pair? child)
            (let ([cx (+ (widget-get-attr (car child) %gx)
                         (/ (widget-get-attr (car child) %w) 2))]
                  [cy (+ (widget-get-attr (car child) %gy)
                         (/ (widget-get-attr (car child) %h) 2))])
              (case direct
                [(quote right)
                 (if (> cx gx) (set! ret (append ret (list (car child)))))]
                [(quote left)
                 (if (< cx gx) (set! ret (append ret (list (car child)))))]
                [(quote up)
                 (if (< cy gy) (set! ret (append ret (list (car child)))))]
                [(quote down)
                 (if (> cy gy) (set! ret (append ret (list (car child)))))]
                [(quote next)
                 (if (> cx gx)
                     (set! ret (append ret (list (car child))))
                     (if (> cy gy)
                         (set! ret (append ret (list (car child))))))]
                [(quote prev)
                 (if (< cx gx)
                     (set! ret (append ret (list (car child))))
                     (if (< cy gy)
                         (set! ret (append ret (list (car child))))))])
              (loop (cdr child)))))
      (set! ret
        (list-sort
          (lambda (wa wb)
            (let ([wax (widget-get-attr wa %gx)]
                  [way (widget-get-attr wa %gy)]
                  [wbx (widget-get-attr wb %gx)]
                  [wby (widget-get-attr wb %gy)])
              (< (far gx gy wax way) (far gx gy wbx wby))))
          ret))
      ret))
  (define (widget-child-focus-event widget type data)
    (if (= (vector-ref data 2) 1)
        (let ([focus-child (widget-get-attrs widget 'focus-child)]
              [focus-key-map-fun (widget-get-attrs
                                   widget
                                   'focus-key-map-fun
                                   get-default-key-map)])
          (if (> (length (widget-get-child widget)) 0)
              (let ([ret '()])
                (if (null? focus-child)
                    (begin
                      (set! focus-child
                        (list-ref (widget-get-child widget) 0))
                      (set! ret (widget-get-child widget)))
                    (let ([gxy (widget-get-global-center-xy focus-child)])
                      (set! ret
                        (widget-find-child-focus
                          widget
                          (focus-key-map-fun (vector-ref data 0))
                          (list-ref gxy 0)
                          (list-ref gxy 1)))))
                (if (> (length ret) 0)
                    (begin
                      (widget-set-attr focus-child %status %status-default)
                      (widget-set-attrs
                        widget
                        'focus-child
                        (list-ref ret 0))
                      (widget-set-status (list-ref ret 0) %status-focus)
                      (widget-set-status
                        (list-ref ret 0)
                        %status-hover))))))))
  (define (set-status status flag) (bitwise-ior status flag))
  (define (clear-status status flag)
    (bitwise-and status (bitwise-not flag)))
  (define (is-set-status status flag)
    (= 0 (bitwise-xor (bitwise-and status flag) flag)))
  (define (widget-set-status widget status)
    (let ([s (widget-get-attr widget %status)])
      (widget-set-attr widget %status (set-status s status))))
  (define (widget-clear-status widget status)
    (let ([s (widget-get-attr widget %status)])
      (widget-set-attr widget %status (clear-status s status))))
  (define (widget-set-child-status widget status)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (widget-set-status (car child) status)
            (widget-set-child-status (car child) status)
            (loop (cdr child))))))
  (define (widget-clear-child-status widget status)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (widget-clear-status (car child) status)
            (widget-clear-child-status (car child) status)
            (loop (cdr child))))))
  (define (widget-status-is-set widget status)
    (let ([s (widget-get-attr widget %status)])
      (= 0 (bitwise-xor (bitwise-and s status) status))))
  (define (widget-child-key-event widget type data)
    (if (and (= type %event-key))
        (widget-child-focus-event widget type data))
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (if (or (widget-status-is-set (car child) %status-focus))
                (begin
                  ((vector-ref (car child) %event)
                    (car child)
                    widget
                    type
                    data)))
            (loop (cdr child))))))
  (define (widget-child-rect-key-event widget type data) '())
  (define (widget-child-rect-event widget type data)
    (let* ([lmx (vector-ref data 3)]
           [lmy (vector-ref data 4)]
           [data2 (vector (vector-ref data 0) (vector-ref data 1)
                    (vector-ref data 2) (- lmx (vector-ref widget %gx))
                    (- lmy (vector-ref widget %gy)) lmx lmy)])
      (let loop ([child (vector-ref widget %child)])
        (if (pair? child)
            (begin
              (if (is-in-widget
                    (car child)
                    (- lmx (vector-ref widget %gx))
                    (- lmy (vector-ref widget %gy)))
                  (begin
                    ((vector-ref (car child) %event)
                      (car child)
                      widget
                      type
                      data2)))
              (loop (cdr child)))))))
  (define (widget-child-rect-event-scroll widget type data)
    (let* ([mx (vector-ref data 2)]
           [my (vector-ref data 3)]
           [lmx (- mx (vector-ref widget %gx))]
           [lmy (- my (vector-ref widget %gy))]
           [data2 (vector (vector-ref data 0) (vector-ref data 1)
                    (vector-ref data 2) lmx lmy mx my)])
      (let loop ([child (vector-ref widget %child)])
        (if (pair? child)
            (begin
              (if (and (widget-is-in-widget widget (car child))
                       (is-in-widget (car child) lmx lmy))
                  (begin
                    ((vector-ref (car child) %event)
                      (car child)
                      widget
                      type
                      data2)))
              (loop (cdr child)))))))
  (define (widget-draw-rect-child widget)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (if (widget-is-in-widget widget (car child))
                (let ([draw (vector-ref (car child) %draw)])
                  (if (procedure? draw)
                      (if (widget-get-attr (car child) %visible)
                          (draw (car child) widget)))))
            (loop (cdr child))))))
  (define (widget-draw-child widget)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (if (widget-get-attr (car child) %visible)
                ((vector-ref (car child) %draw) (car child) widget))
            (loop (cdr child))))))
  (define (widget-update-pos ww)
    (let ([x (vector-ref ww %x)]
          [y (vector-ref ww %y)]
          [w (vector-ref ww %w)]
          [h (vector-ref ww %h)]
          [parent (widget-get-attr ww %parent)]
          [draw (vector-ref ww %draw)])
      (if (null? parent)
          (let ([gx (+ (vector-ref ww %x))]
                [gy (+ (vector-ref ww %y))])
            (vector-set! ww %gx gx)
            (vector-set! ww %gy gy))
          (let ([gx (+ (vector-ref parent %gx) (vector-ref ww %x))]
                [gy (+ (vector-ref parent %gy) (vector-ref ww %y))])
            (vector-set! ww %gx gx)
            (vector-set! ww %gy gy)))))
  (define (widget-child-update-pos widget)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (let ([ww (car child)]
                [parent (widget-get-attr (car child) %parent)])
            (let ([x (vector-ref ww %x)]
                  [y (vector-ref ww %y)]
                  [w (vector-ref ww %w)]
                  [h (vector-ref ww %h)]
                  [draw (vector-ref ww %draw)])
              (if (null? parent)
                  (let ([gx (+ (vector-ref ww %x))]
                        [gy (+ (vector-ref ww %y))])
                    (vector-set! ww %gx gx)
                    (vector-set! ww %gy gy))
                  (let ([gx (+ (vector-ref parent %gx) (vector-ref ww %x))]
                        [gy (+ (vector-ref parent %gy)
                               (vector-ref ww %y))])
                    (vector-set! ww %gx gx)
                    (vector-set! ww %gy gy)))
              (widget-child-update-pos ww))
            (loop (cdr child))))))
  (define (widget-copy widget) (vector-copy widget))
  (define widget-get-attrs
    (case-lambda
      [(widget name)
       (let ([h (vector-ref widget %attrs)])
         (let ([hook (hashtable-ref
                       h
                       (format "%event-get-~a-hook" name)
                       '())])
           (if (procedure? hook)
               (hook widget name)
               (hashtable-ref h name '()))))]
      [(widget name default)
       (let ([h (vector-ref widget %attrs)])
         (let ([hook (hashtable-ref
                       h
                       (format "%event-get-~a-hook" name)
                       '())])
           (if (procedure? hook)
               (hook widget name default)
               (let ([val (hashtable-ref h name default)])
                 (if (null? val) default val)))))]))
  (define (widget-attrs widget) (vector-ref widget %attrs))
  (define (widget-set-attrs widget name value)
    (let ([h (vector-ref widget %attrs)])
      (hashtable-set! h name value)
      (let ([hook (hashtable-ref
                    h
                    (format "%event-~a-hook" name)
                    '())])
        (if (procedure? hook) (hook widget name value)))))
  (define (widget-get-events widget name)
    (let ([h (vector-ref widget %events)])
      (hashtable-ref h name '())))
  (define (widget-set-events widget name value)
    (let ([h (vector-ref widget %events)])
      (hashtable-set! h name value)))
  (define (widget-new x y w h text)
    (let ([offset (vector 0 0)]
          [active 0]
          [resize-pos (vector 0 0)]
          [nw '()])
      (set! nw
        (vector x y w h default-layout
         (lambda (widget parent)
           (let ([x (vector-ref widget %x)]
                 [y (vector-ref widget %y)]
                 [w (vector-ref widget %w)]
                 [h (vector-ref widget %h)]
                 [draw (vector-ref widget %draw)])
             (vector-set! widget %gx x)
             (vector-set! widget %gy y)))
         (lambda (widget parent type data)
           (if (= type %event-mouse-button)
               (let ([xx (vector-ref widget %x)]
                     [yy (vector-ref widget %y)]
                     [ww (vector-ref widget %w)]
                     [hh (vector-ref widget %h)])
                 (if (= (vector-ref data 1) %event-button-down)
                     (let ([mx (vector-ref data 3)]
                           [my (vector-ref data 4)])
                       (if (in-rect xx yy ww (widget-get-attr widget %top)
                             mx my)
                           (widget-set-status widget %status-drag))
                       (if (or (in-rect (+ xx ww -20.0) (+ yy) 20.0 hh mx
                                 my)
                               (in-rect (+ xx) (+ yy hh -20.0) ww 20.0 mx
                                 my))
                           (begin
                             (widget-set-status widget %status-resize)))
                       (set! resize-pos (vector mx my))
                       (set! offset
                         (vector
                           (- (vector-ref widget %x) mx)
                           (- (vector-ref widget %y) my)))
                       (widget-child-rect-event-mouse-button
                         widget
                         type
                         data)
                       (if (not (widget-get-attr widget %visible))
                           (begin
                             (widget-clear-status widget %status-drag)))))
                 (if (= (vector-ref data 1) %event-button-up)
                     (begin
                       (widget-clear-status widget %status-drag)
                       (widget-clear-status widget %status-resize)))))
           (if (= type %event-motion)
               (begin
                 (if (or (widget-status-is-set widget %status-resize)
                         (widget-status-is-set widget %status-drag))
                     (let ()
                       (if (widget-status-is-set widget %status-resize)
                           (let ([mx (vector-ref data 0)]
                                 [my (vector-ref data 1)]
                                 [w (vector-ref widget %w)]
                                 [h (vector-ref widget %h)]
                                 [x (vector-ref widget %x)]
                                 [y (vector-ref widget %y)])
                             (widget-resize
                               widget
                               (+ w (- mx (vector-ref resize-pos 0)))
                               (+ h (- my (vector-ref resize-pos 1))))
                             (set! resize-pos (vector mx my)))
                           (begin
                             (vector-set!
                               widget
                               %x
                               (+ (vector-ref data 0)
                                  (vector-ref offset 0)))
                             (vector-set!
                               widget
                               %y
                               (+ (vector-ref data 1)
                                  (vector-ref offset 1)))))))))
           (if (= type %event-scroll)
               (begin (widget-child-rect-event-scroll widget type data)))
           (if (= type %event-layout)
               (begin (widget-child-rect-event-layout widget type data)))
           (if (and (or (= type %event-char) (= type %event-key))
                    (widget-status-is-set widget %status-active))
               (begin (widget-child-key-event widget type data))))
         (list) 0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 '() 0.0 0.0 text
         'widget (make-hashtable equal-hash equal?)
         (make-hashtable equal-hash equal?) #t '() #f '() '() '() '()
         '() '() '() '()))
      (widget-set-attrs nw '%w w)
      (widget-set-attrs nw '%h h)
      (loop-event default-widget-new-events nw)
      nw))
  (define (widget-add-new-event proc)
    (add-event default-widget-new-events proc))
  (define (widget-resize widget w h)
    (vector-set! widget %w w)
    (vector-set! widget %h h)
    ((vector-ref widget %layout) widget))
  (define (widget-at widget)
    (let loop ([w $widgets] [index 0])
      (if (pair? w)
          (begin
            (if (eqv? (car w) widget)
                index
                (loop (cdr w) (+ index 1)))))))
  (define (widget-active widget)
    (set! $widgets (remove! widget $widgets))
    (set! $widgets (append $widgets (list widget))))
  (define (widget-remove-child parent child)
    (let ([childs (vector->list
                    (widget-get-attr parent %child))])
      (set! childs (remove! child childs))
      (widget-set-attr parent %child (list->vector childs))))
  (define widget-print
    (case-lambda
      [(widget)
       (let loop ([w widget] [index 0])
         (if (pair? w)
             (begin
               (printf
                 "widgets[~a]=>~a "
                 index
                 (substring
                   (widget-get-attr (car w) %text)
                   0
                   (min 12
                        (string-length (widget-get-attr (car w) %text)))))
               (loop (cdr w) (+ index 1)))))
       (printf "\n")]
      [(widget call)
       (let loop ([w widget] [index 0])
         (if (pair? w)
             (begin
               (if (procedure? call) (call (car w)))
               (loop (cdr w) (+ index 1)))))
       (printf "\n")]))
  (define (widget-remove w)
    (let ([parent (widget-get-attr w %parent)])
      (if (null? parent)
          (begin
            (widget-print $widgets)
            (set! $widgets (remove! w $widgets))
            (widget-print $widgets))
          (widget-remove-child parent w))))
  (define (widget-get-attr widget index)
    (vector-ref widget index))
  (define (widget-set-attr widget index value)
    (vector-set! widget index value)
    (if (not (null?
               (widget-get-attrs widget (format "%event-~a" index))))
        ((widget-get-attrs widget (format "%event-~a" index))
          widget
          value)))
  (define (widget-set-child-attr widget index value)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (widget-set-attr (car child) index value)
            (widget-set-child-attr (car child) index value)
            (loop (cdr child))))))
  (define (widget-set-child-attrs widget index value)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (widget-set-attrs (car child) index value)
            (widget-set-child-attrs (car child) index value)
            (loop (cdr child))))))
  (define (widget-set-child widget value)
    (vector-set! widget %child value))
  (define (widget-get-child widget)
    (vector-ref widget %child))
  (define (widget-get-parent widget)
    (vector-ref widget %parent))
  (define (widget-set-draw widget event)
    (vector-set! widget %draw event))
  (define (widget-get-draw widget) (vector-ref widget %draw))
  (define (widget-set-event widget event)
    (vector-set! widget %event event))
  (define (widget-get-event widget)
    (vector-ref widget %event))
  (define (widget-add-event widget event)
    (let ([e (vector-ref widget %event)])
      (vector-set!
        widget
        %event
        (lambda (w p t d)
          (let ([ret (event w p t d)])
            (if (or (equal? ret #t) (null? ret) (equal? ret (void)))
                (e w p t d)))))))
  (define (widget-add-draw widget event)
    (let ([draw (vector-ref widget %draw)])
      (vector-set!
        widget
        %draw
        (lambda (widget parent)
          (draw widget parent)
          (event widget parent)))))
  (define (widget-event type data)
    (if (= type %event-motion)
        (begin
          (set! cursor-x (vector-ref data 0))
          (set! cursor-y (vector-ref data 1))))
    (let l ([w $widgets])
      (if (pair? w)
          (begin
            (let ([fun (widget-get-attrs
                         (car w)
                         '%event-rect-function)])
              (if (procedure? fun)
                  (if (fun (car w) cursor-x cursor-y)
                      (let ([event (vector-ref (car w) %event)])
                        (event (car w) '() type data))
                      (let ([event (vector-ref (car w) %event)])
                        (event (car w) '() %event-motion-out data)))))
            (l (cdr w)))))
    (let loop ([len (- (length $widgets) 1)])
      (if (>= len 0)
          (let ([w (list-ref $widgets len)])
            (if (and (widget-get-attr w %visible)
                     (or (widget-status-is-set w %status-drag)
                         (widget-status-is-set w %status-resize)
                         (is-in-widget w cursor-x cursor-y)))
                (let ([event (vector-ref w %event)])
                  (event w '() type data)
                  (set! $last-hover w))
                (let ([event (vector-ref w %event)])
                  (if (not (null? $last-hover))
                      (begin
                        (event $last-hover '() %event-motion-out data)
                        (set! $last-hover '())))))
            (loop (- len 1))))))
  (define (widget-mouse-button-event data)
    (let ([have-event #f])
      (let l ([w $widgets])
        (if (pair? w)
            (begin
              (widget-set-status (car w) %status-default)
              (let ([fun (widget-get-attrs
                           (car w)
                           '%event-rect-function)])
                (if (procedure? fun)
                    (if (and (widget-status-is-set (car w) %status-active)
                             (widget-get-attr (car w) %visible)
                             (fun (car w)
                                  (vector-ref data 3)
                                  (vector-ref data 4)))
                        (begin
                          (set! have-event #t)
                          ((vector-ref (car w) %event)
                            (car w)
                            '()
                            %event-mouse-button
                            data))
                        (l (cdr w)))
                    (l (cdr w)))))))
      (if (not have-event)
          (let loop ([len (- (length $widgets) 1)])
            (if (>= len 0)
                (let ([w (list-ref $widgets len)])
                  (if (and (widget-get-attr w %visible)
                           (is-in-widget
                             w
                             (vector-ref data 3)
                             (vector-ref data 4)))
                      (begin
                        (widget-set-status w %status-active)
                        ((vector-ref w %event)
                          w
                          '()
                          %event-mouse-button
                          data))
                      (loop (- len 1)))))))))
  (define (widget-scroll-event data)
    (let loop ([len (- (length $widgets) 1)])
      (if (>= len 0)
          (let ([w (list-ref $widgets len)])
            (if (and (widget-get-attr w %visible)
                     (is-in-widget
                       w
                       (vector-ref data 2)
                       (vector-ref data 3)))
                (begin ((vector-ref w %event) w '() %event-scroll data))
                (loop (- len 1)))))))
  (define (widget-rect-fun widget lmx lmy)
    (let ([fun (widget-get-attrs widget '%event-rect-function)])
      (if (procedure? fun)
          (begin (fun widget lmx lmy))
          (begin (is-in-widget widget lmx lmy)))))
  (define (is-in-child-widget widget mx my)
    (let ([count 0]
          [lmx (- mx (vector-ref widget %x))]
          [lmy (- my (vector-ref widget %y))])
      (let loop ([child (vector-ref widget %child)])
        (if (pair? child)
            (begin
              (if (is-in-widget (car child) lmx lmy)
                  (begin (set! count (+ count 1)))
                  (loop (cdr child))))))
      (if (> count 0) #t #f)))
  (define (widget-to-local-mouse widget data)
    (vector-set!
      data
      0
      (- (vector-ref data 0) (vector-ref widget %gx)))
    (vector-set!
      data
      1
      (- (vector-ref data 1) (vector-ref widget %gy))))
  (define widget-child-rect-event-mouse-motion
    (case-lambda
      [(widget type data)
       (let* ([mx (vector-ref data 0)]
              [my (vector-ref data 1)]
              [lmx (- mx (vector-ref widget %x))]
              [lmy (- my (vector-ref widget %y))]
              [data2 (vector lmx lmy mx my)]
              [last-child-hover '()])
         (let loop ([child (vector-ref widget %child)])
           (if (pair? child)
               (begin
                 (if (widget-rect-fun (car child) lmx lmy)
                     (begin
                       (widget-set-status (car child) %status-hover)
                       ((vector-ref (car child) %event)
                         (car child)
                         widget
                         type
                         data2)
                       (set! last-child-hover (car child))))
                 (loop (cdr child)))))
         (let ([last-hover (widget-get-attrs
                             widget
                             'last-child-hover)])
           (if (and (not (equal? last-child-hover last-hover)))
               (begin
                 (if (not (null? last-hover))
                     (begin
                       (widget-clear-status last-hover %status-hover)
                       ((vector-ref last-hover %event)
                         last-hover
                         '()
                         %event-motion-out
                         data2)))
                 (widget-set-attrs
                   widget
                   'last-child-hover
                   last-child-hover)))))]
      [(widget type data fun)
       (let* ([mx (vector-ref data 0)]
              [my (vector-ref data 1)]
              [lmx (- mx (vector-ref widget %x))]
              [lmy (- my (vector-ref widget %y))]
              [data2 (vector lmx lmy mx my)]
              [last-child-hover '()])
         (let loop ([child (vector-ref widget %child)])
           (if (pair? child)
               (begin
                 (if (fun (car child) lmx lmy)
                     (begin
                       ((vector-ref (car child) %event)
                         (car child)
                         widget
                         type
                         data2)
                       (set! last-child-hover (car child))))
                 (loop (cdr child)))))
         (let ([last-hover (widget-get-attrs
                             widget
                             'last-child-hover)])
           (if (and (not (equal? last-child-hover last-hover)))
               (begin
                 (if (not (null? last-hover))
                     ((vector-ref last-hover %event)
                       last-hover
                       '()
                       %event-motion-out
                       data2))
                 (widget-set-attrs
                   widget
                   'last-child-hover
                   last-child-hover)))))]))
  (define (widget-get-short-text widget)
    (substring
      (widget-get-attr widget %text)
      0
      (min 12 (string-length (widget-get-attr widget %text)))))
  (define widget-child-rect-event-mouse-button
    (case-lambda
      [(widget type data)
       (let* ([mx (vector-ref data 3)]
              [my (vector-ref data 4)]
              [lmx (- mx (vector-ref widget %x))]
              [lmy (- my (vector-ref widget %y))]
              [data2 (vector (vector-ref data 0) (vector-ref data 1)
                       (vector-ref data 2) lmx lmy mx my)])
         (let loop ([child (vector-ref widget %child)])
           (if (pair? child)
               (begin
                 (if (widget-rect-fun (car child) lmx lmy)
                     (begin
                       (widget-set-status (car child) %status-focus)
                       ((vector-ref (car child) %event)
                         (car child)
                         widget
                         type
                         data2))
                     (begin
                       (widget-clear-status (car child) %status-focus)))
                 (loop (cdr child))))))]
      [(widget type data fun)
       (let* ([mx (vector-ref data 3)]
              [my (vector-ref data 4)]
              [lmx (- mx (vector-ref widget %x))]
              [lmy (- my (vector-ref widget %y))]
              [data2 (vector (vector-ref data 0) (vector-ref data 1)
                       (vector-ref data 2) lmx lmy mx my)])
         (let loop ([child (vector-ref widget %child)])
           (if (pair? child)
               (begin
                 (if (fun (car child) lmx lmy)
                     (begin
                       (widget-set-status (car child) %status-focus)
                       ((vector-ref (car child) %event)
                         (car child)
                         widget
                         type
                         data2))
                     (widget-clear-status (car child) %status-focus))
                 (loop (cdr child))))))]))
  (define (widget-render)
    (let loop ([w $widgets])
      (if (pair? w)
          (begin
            (if (widget-get-attr (car w) %visible)
                (let ([draw (vector-ref (car w) %draw)])
                  (draw (car w) '())))
            (loop (cdr w)))))
    (graphic-render))
  (define (widget-set-custom-cursor cursor)
    (set! cursor-arrow cursor))
  (define (widget-show-custom-cursor)
    (if (>= cursor-arrow 0)
        (set! cursor-arrow (load-texture "cursor.png"))))
  (define (widget-disable-custom-cursor)
    (set! cursor-arrow -1))
  (define widget-init
    (case-lambda
      [(w h)
       (set! window-width w)
       (set! window-height h)
       (graphic-init w h)
       (widget-init-key-map)]
      [(w h ratio)
       (set! window-width w)
       (set! window-height h)
       (graphic-set-ratio ratio)
       (graphic-init w h)
       (widget-init-key-map)]))
  (define (widget-get-window-width) window-width)
  (define (widget-get-window-height) window-height)
  (define (widget-window-resize w h)
    (set! window-width w)
    (set! window-height h)
    (graphic-resize w h)
    (widget-layout))
  (define (widget-get-root widget)
    (let loop ([p (widget-get-attr widget %parent)] [last '()])
      (if (not (null? p))
          (begin
            (set! last p)
            (loop (widget-get-attr p %parent) last))
          last)))
  (define (widget-get-parent-cond widget fun)
    (let loop ([p (widget-get-attr widget %parent)]
               [last widget])
      (if (not (null? p))
          (begin
            (if (equal? #t (fun p)) (begin (set! last p)))
            (loop (widget-get-attr p %parent) last))
          last)))
  (define (widget-layout-event widget)
    ((vector-ref widget %event) widget '() %event-layout 'end))
  (define (widget-child-rect-event-layout widget type data)
    (let loop ([child (vector-ref widget %child)])
      (if (pair? child)
          (begin
            (if (and (widget-is-in-widget widget (car child)))
                (begin
                  ((vector-ref (car child) %event)
                    (car child)
                    widget
                    type
                    data)))
            (loop (cdr child))))))
  (define (widget-layout-update widget)
    (if (not (null? widget))
        (let ([layout (widget-get-attr widget %layout)])
          (if (procedure? layout)
              (begin (layout widget) (widget-layout-event widget))))))
  (define (widget-layout)
    (let loop ([w $widgets])
      (if (pair? w)
          (let ([layout (vector-ref (car w) %layout)])
            (if (procedure? layout)
                (begin (layout (car w)) (widget-layout-event (car w))))
            (loop (cdr w))))))
  (define (widget-destroy) (graphic-destroy))
  (define draw-widget-rect
    (case-lambda
      [(widget)
       (let ([x (vector-ref widget %gx)]
             [y (vector-ref widget %gy)]
             [w (vector-ref widget 2)]
             [h (vector-ref widget 3)]
             [background (widget-get-attrs widget 'background)])
         (if (equal? '() background)
             (graphic-draw-solid-quad x y (+ x w) (+ y h) 128.0 30.0 34.0
               0.5)
             (graphic-draw-solid-quad x y (+ x w) (+ y h) background)))]
      [(widget r g b a)
       (let ([x (vector-ref widget %gx)]
             [y (vector-ref widget %gy)]
             [w (vector-ref widget 2)]
             [h (vector-ref widget 3)]
             [background (widget-get-attrs widget 'background)])
         (if (equal? '() background)
             (graphic-draw-solid-quad x y (+ x w) (+ y h) r g b a)
             (graphic-draw-solid-quad x y (+ x w) (+ y h)
               background)))]))
  (define (draw-widget-child-rect widget child)
    (if (null? widget)
        (draw-widget-rect child)
        (let ([x (vector-ref widget %gx)]
              [y (vector-ref widget %gy)]
              [w (vector-ref widget %w)]
              [h (vector-ref widget %h)]
              [cx (vector-ref child %gx)]
              [cy (vector-ref child %gy)]
              [cw (vector-ref child %w)]
              [ch (vector-ref child %h)]
              [background (widget-get-attrs widget 'background)])
          (if (equal? '() background)
              (graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch) 128.0
                30.0 34.0 0.5)
              (graphic-draw-solid-quad cx cy (+ cx cw) (+ cy ch)
                background))))))

