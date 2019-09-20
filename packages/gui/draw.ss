;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui draw)
  (export draw-image draw-dialog draw-text draw-line draw-rect
    draw-panel draw-button draw-item draw-video draw-tab
    draw-scroll-bar draw-hover draw-item-bg draw-border
    draw-get-text-width draw-widget-text draw-get-text-lineh
    draw-get-text-height)
  (import (scheme) (utils libutil) (gui graphic) (gui widget)
    (gui video) (gui stb))
  (define (draw-get-text-width font font-size text)
    (graphic-measure-text font font-size text))
  (define (draw-get-text-lineh font size)
    (graphic-get-font-lineh font size))
  (define (draw-get-text-height font size)
    (graphic-get-font-height font size))
  (define (draw-button x y w h text)
    (graphic-draw-solid-quad x y (+ x w) (+ y h) 31.0 31.0 31.0
      0.9))
  (define (draw-item-bg x y w h color)
    (if (null? color)
        (graphic-draw-solid-quad x y (+ x w) (+ y h) 61.0 61.0 61.0
          0.9)
        (graphic-draw-solid-quad x y (+ x w) (+ y h) color)))
  (define (draw-item x y w h)
    (graphic-draw-solid-quad x y (+ x w) (+ y h) 61.0 61.0 61.0
      0.9))
  (define (draw-video v x y w h)
    (video-render v x y (+ x w) (+ y h)))
  (define (draw-tab x y w h active)
    (if active
        (graphic-draw-solid-quad x y (+ x w) (+ y h) 31.0 31.0 31.0
          0.6)
        (graphic-draw-solid-quad x y (+ x w) (+ y h) 61.0 61.0 61.0
          0.9)))
  (define (draw-scroll-bar x y w h pos scroll-h)
    (graphic-draw-solid-quad x y (+ x w) (+ y h) 31.0 31.0 31.0
      0.6)
    (graphic-draw-solid-quad x (+ y (/ (* pos h) scroll-h)) (+ x w)
      (+ y (/ (* pos h) scroll-h) (* (/ h scroll-h) 100.0)) 61.0
      61.0 61.0 0.6))
  (define draw-panel
    (case-lambda
      [(x y w h text)
       (graphic-draw-solid-quad x y (+ x w) (+ y h) 81.0 81.0 90.0
         1.0)]
      [(x y w h text color)
       (graphic-draw-solid-quad x y (+ x w) (+ y h) color)]))
  (define (draw-dialog widget)
    (let* ([color (widget-get-attrs widget 'color 0)]
           [parent (widget-get-attr widget %parent)]
           [gx (widget-in-parent-gx widget parent)]
           [gy (widget-in-parent-gy widget parent)]
           [w (widget-get-attr widget %w)]
           [h (widget-get-attr widget %h)]
           [text (widget-get-attr widget %text)]
           [font (widget-get-attrs widget 'font)]
           [font-size (widget-get-attrs widget 'font-size)]
           [lineh (widget-get-attrs widget 'line-height)]
           [header-height (widget-get-attrs widget 'head-height 30.0)])
      (graphic-draw-solid-quad gx gy (+ gx w) (+ gy header-height)
        31.0 31.0 31.0 0.9)
      (graphic-draw-solid-quad gx gy (+ gx w) (+ gy h) 31.0 31.0
        31.0 0.8)
      (draw-text font font-size (+ gx 10.0)
        (+ gy (/ (- header-height lineh) 2.0)) text)))
  (define (draw-line x1 y1 x2 y2 color)
    (graphic-draw-line x1 y1 x2 y2 color))
  (define (draw-widget-text widget)
    (let* ([color (widget-get-attrs widget 'color 4294967295)]
           [parent (widget-get-attr widget %parent)]
           [tw (widget-get-attrs widget 'text-width 0.0)]
           [th (widget-get-attrs widget 'text-height 0.0)]
           [ta (widget-get-attrs widget 'text-align 'center)]
           [lineh (widget-get-attrs widget 'line-height)]
           [padding-left (widget-get-attrs widget 'padding-left 0.0)]
           [padding-right (widget-get-attrs widget 'padding-right 0.0)]
           [padding-top (widget-get-attrs widget 'padding-top 0.0)]
           [padding-bottom (widget-get-attrs
                             widget
                             'padding-bottom
                             0.0)]
           [gx (widget-in-parent-gx widget parent)]
           [gy (widget-in-parent-gy widget parent)]
           [w (widget-get-attr widget %w)]
           [h (widget-get-attr widget %h)]
           [text (widget-get-attr widget %text)]
           [font (widget-get-attrs widget 'font)]
           [font-size (widget-get-attrs widget 'font-size)])
      (if (widget-status-is-set widget %status-hover)
          (set! color
            (widget-get-attrs widget 'hover-color 4294967295)))
      (case ta
        [(quote left)
         (draw-text font font-size (+ gx padding-left)
           (+ gy (/ (- h lineh) 2.0) padding-top) text color)]
        [(quote left-top)
         (draw-text font font-size (+ gx padding-left)
           (+ gy padding-top) text color)]
        [(quote right)
         (draw-text font font-size (+ gx padding-left)
           (+ gy (/ h 2.0)) text color)]
        [(quote center)
         (if (> tw w)
             (draw-text font font-size (+ gx padding-left)
               (+ gy (/ (- h lineh) 2.0)) text color)
             (draw-text font font-size
               (+ gx (/ (- w tw) 2.0) padding-left)
               (+ gy (/ (- h lineh) 2.0)) text color))]
        [else
         (draw-text font font-size (+ gx (- w tw) padding-left)
           (+ gy) text color)])))
  (define draw-text
    (case-lambda
      [(x y text) (graphic-draw-text-immediate x y text)]
      [(x y text color)
       (graphic-draw-text-immediate x y text color)]
      [(font size x y text)
       (graphic-draw-text-immediate font size x y text 4294967295)]
      [(font size x y text color)
       (graphic-draw-text-immediate font size x y text color)]))
  (define (draw-hover x y w h color)
    (if (null? color)
        (draw-rect x y w h)
        (draw-rect x y w h color)))
  (define (draw-border x y w h color)
    (graphic-draw-line-strip
      (list x y (+ x w) y (+ x w) (+ y h) (+ x) (+ y h) x y)
      color))
  (define draw-rect
    (case-lambda
      [(x y w h)
       (graphic-draw-solid-quad x y (+ x w) (+ y h) 31.0 31.0 31.0
         0.4)]
      [(x y w h color)
       (graphic-draw-solid-quad x y (+ x w) (+ y h) color)]))
  (define draw-image
    (case-lambda
      [(x y w h src)
       (graphic-draw-texture-quad x y (+ x w) (+ y h) 0.0 0.0 1.0
         1.0 src)]
      [(x y w h src attrs)
       (if (equal? (hashtable-ref attrs 'mode '()) 'fix-xy)
           (graphic-draw-texture-quad x y (+ x w) (+ y h) 0.0 0.0 1.0
             1.0 src))
       (if (equal? (hashtable-ref attrs 'mode '()) 'center-crop)
           (let ([h1 (hashtable-ref attrs 'height h)]
                 [w1 (hashtable-ref attrs 'width w)])
             (if (> h1 w1)
                 (graphic-draw-texture-quad x y (+ x w) (+ y h) 0.0
                   (/ (/ (- h1 h) 2) h1) 1.0 1.0 src)
                 (graphic-draw-texture-quad x y (+ x w) (+ y h)
                   (/ (/ (- w1 w) 2) w1) 0.0 1.0 1.0 src))))])))

