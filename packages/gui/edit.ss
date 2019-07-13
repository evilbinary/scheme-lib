;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui edit)
    (export
        edit-set-foreground
        edit-set-background
        edit-set-font-size
        edit-set-font-name
        edit-set-font
        edit-get-height
        edit-set-highlight
        edit-get-highlight
        edit-update-highlight
        edit-char-event
        edit-get-text
        edit-set-font
        edit-mouse-event
        edit-key-event
        edit-set-scroll
        edit-mouse-motion-event
        edit-set-select-color
        edit-set-cursor-color
        edit-set-font-line-height
        edit-set-show-no
        edit-set-lineno-color
        edit-get-selection
        edit-set-selection
        edit-get-line-count
        edit-get-row-count
        edit-get-cursor-x
        edit-get-cursor-y
        edit-measure-text
        edit-get-font
        edit-get-text-range
        edit-get-selection-row-start
        edit-get-selection-row-end
        edit-get-selection-col-start
        edit-get-selection-col-end
        edit-insert-text-at
        edit-set-cursor
        edit-get-text-length

        edit-new
        new-edit
        draw-edit
        edit-add-text
        edit-set-text
        edit-set-color
    )

    (import (scheme) (utils libutil) (cffi cffi) (gles gles2) (gui graphic) )
    (load-librarys "libgui")

    (def-function edit-set-foreground "edit_set_foreground" (void* int) void)
    (def-function edit-set-background "edit_set_background" (void* int) void)
    (def-function edit-set-font-size "edit_set_font_size" (void* float) void)
    (def-function edit-set-font-name "edit_set_font_name" (void* string) void)
    (def-function edit-set-color "edit_set_color" (void*  int) void)
    (def-function edit-set-font "edit_set_font" (void* string float) void)
    (def-function edit-set-font-line-height "edit_set_font_line_height" (void* float) void)

    (def-function edit-set-editable "edit_set_editable" (void*  int) void)
    (def-function edit-set-show-no "edit_set_show_no" (void*  int) void)
    (def-function edit-set-lineno-color "edit_set_lineno_color" (void*  int) void)
    (def-function edit-get-selection "edit_get_selection" (void* ) string)
    (def-function edit-set-selection "edit_set_selection" (void*  int int int int) void)
    (def-function edit-get-text-range "edit_get_text_range" (void*  int int int int) string)
    (def-function edit-get-selection-row-start "edit_get_select_row_start" (void*) int)
    (def-function edit-get-selection-row-end "edit_get_select_row_end" (void*) int)
    (def-function edit-get-selection-col-start "edit_get_select_col_start" (void*) int)
    (def-function edit-get-selection-col-end "edit_get_select_col_end" (void*) int)

    (def-function edit-get-line-count "edit_get_line_count" (void* ) int)
    (def-function edit-get-row-count "edit_get_row_count" (void* int) int)
    (def-function edit-get-cursor-x "edit_get_cursor_x" (void*) float)
    (def-function edit-get-cursor-y "edit_get_cursor_y" (void*) float)
    (def-function edit-insert-text-at "edit_insert_text_at" (void* int int string) void)
    (def-function edit-set-cursor "edit_set_cursor" (void* int int) void)
    (def-function edit-get-text-length "get_edit_text_len" (void*) int)

    (def-function new-edit "new_edit" (int void* float float float float float float) void*)
    (def-function edit-add-text "add_edit_text" (void*  string ) void)
    (def-function edit-set-text  "set_edit_text" (void*  string ) void)
    (def-function edit-get-text  "get_edit_text" (void* ) string)
    (def-function edit-get-height  "get_edit_height" (void* ) float)
    (def-function edit-measure-text  "edit_measure_text" (void*) float)
    
    (def-function render-edit "render_edit" ( void* float float) void)
    (def-function render-edit-once "render_edit_once" ( void* float float string int) void)

    (def-function edit-key-event "edit_key_event" ( void* int int int int) void)
    (def-function edit-char-event "edit_char_event" ( void* int int) void)
    (def-function edit-mouse-event "edit_mouse_event" ( void* int float float) void)
    (def-function edit-set-scroll "edit_set_scroll" ( void*  float float) void)
    (def-function edit-mouse-motion-event "edit_mouse_motion_event" ( void* float float) void)
    
    (def-function edit-set-select-color "edit_set_select_color" ( void* int) void)
    (def-function edit-set-cursor-color "edit_set_cursor_color" ( void* int) void)
    (def-function edit-get-font "edit_get_font" ( void*) void*)
    (def-function resize-edit-window "resize_edit_window" (void* float float ) void)
    (def-function edit-set-highlight "edit_set_highlight" (void* void*) void)
    (def-function edit-get-highlight "edit_get_highlight" (void*) void*)
    (def-function edit-update-highlight "edit_update_highlight" (void*) void)


    (define my-width 0)
    (define my-height 0)
    (define my-ratio 0)
    (define all-edit-cache (make-hashtable equal-hash eqv?) )
    (define font-program 0)

    (define (edit-new font font-size w h)
      (let ((ed (new-edit font-program font (* my-ratio font-size) my-ratio w h my-width my-height) ))
        (hashtable-set! all-edit-cache ed  ed)
        ed
        ))
    
    (define (draw-edit edit x y)
      (render-edit edit x y))

    (graphic-add-init-event (lambda (g w h)
        (set! my-width w)
        (set! my-height h)
        (set! font-program (hashtable-ref g 'font-program '()))
        (set! my-ratio (hashtable-ref g 'ratio 1.0))
    ))

    (graphic-add-resize-event (lambda (g width height)
        ;(resize-edit-window gtext width height)
        (let ((eds (vector->list (hashtable-values all-edit-cache))))
        (let loop ((ed eds))
          (if (pair? ed)
              (begin
          (resize-edit-window (car ed) width height)
          (loop (cdr ed))))))
    ))

    

    )