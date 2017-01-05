;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (imgui)
         (export
            imgui-init
            imgui-exit
            imgui-test

            imgui-touch-event
            imgui-key-event
            imgui-motion-event
            imgui-mouse-event

            imgui-resize
            imgui-scale
            imgui-render-start
            imgui-render-end
            imgui-disable-default-color
            imgui-get-default-color
            imgui-make-vec2
            imgui-make-text-edit-callback
            imgui-load-texture
            imgui-pvec2
            imgui-uvec2

            imgui-load-style 
            imgui-save-style 
            imgui-reset-style

            imgui-get-io
            imgui-text
            imgui-new-frame
            imgui-render
            imgui-color-edit3
            imgui-set-next-window-size
            imgui-set-next-window-pos
            imgui-begin
            imgui-end
            imgui-button
            imgui-small-button
            imgui-input-text
            imgui-input-text-multiline
            imgui-checkbox
            imgui-get-text-line-height
            imgui-get-mouse-cursor
            imgui-is-mouse-clicked
            imgui-is-mouse-down
            imgui-image
            imgui-tree-node
            imgui-tree-pop

            ;consts
            imgui-set-cond-always
            imgui-set-cond-once
            imgui-set-cond-first-use-ever
            imgui-set-cond-appearing

            <<
            >>
            imgui-begin-group
            imgui-end-group
            imgui-same-line
            imgui-separator
          )

        (import  (scheme) (utils libutil) )

        (define lib-name
           (case (machine-type)
             ((arm32le) "libimgui.so")
             ((a6nt i3nt)  "libimgui.dll")
             ((a6osx i3osx)  "libimgui.so")
             ((a6le i3le) "libimgui.so")))
         (define lib (load-lib lib-name))
         ;(define lib (load-shared-object lib-name))

         (define-syntax define-imgui
                    (syntax-rules ()
                      ((_ ret name args)
                       (define name
                         (foreign-procedure (lower-camel-case (string-split (symbol->string 'name) #\- )) args ret)))))


         (define-ftype imgui-vec2 (struct [x float] [y float]))

         (define-c-function void imgui-init () )
         (define-c-function void imgui-exit () )
         (define-c-function void imgui-test () )

         (define-c-function void imgui-motion-event (int int) )
         (define-c-function void imgui-mouse-event (int int) )

         (define-c-function void imgui-touch-event (int int int) )
         (define-c-function void imgui-key-event (int int int string) )

         (define-c-function void imgui-resize (int int) )
         (define-c-function void imgui-scale (float float) )
         (define-c-function void imgui-render-start () )
         (define-c-function void imgui-render-end () )
         (define-c-function void imgui-disable-default-color () )
         (define-c-function void* imgui-get-default-color () )
         (define-c-function void* imgui-make-vec2 (float float))
         (define-c-function void* imgui-make-vec4 (float float float float))
         (define-c-function void* imgui-make-text-edit-callback (scheme-object))
         (define-c-function void* imgui-load-texture (string))

        (define-c-function void* imgui-pvec2 (float float) )
        (define-c-function void imgui-uvec2 (void*) )

        ;;样式加载和修改
        (define-c-function boolean imgui-load-style (string) )
        (define-c-function boolean imgui-save-style (string) )
        (define-c-function boolean imgui-reset-style (int) )

         (define-imgui void* imgui-get-io () )
         (define-imgui void imgui-render () )
         (define-imgui void imgui-text (string) )
         (define-imgui void imgui-new-frame () )
         (define-imgui void imgui-color-edit3 (string void*) )
         (define-imgui void imgui-set-next-window-size (void* int) )
         (define-imgui void imgui-set-next-window-pos (void* int) )

         (define-imgui void imgui-begin (string int) )
         (define-imgui void imgui-end () )
         (define-imgui boolean imgui-button (string void*) )
         (define-imgui boolean imgui-small-button (string void*) )
         (define-imgui boolean imgui-checkbox (string u8*) )
         (define-imgui boolean imgui-tree-node (string) )
         (define-imgui void imgui-tree-pop () )


         (define-imgui boolean imgui-input-text (string string int int void* void*))
         (define-imgui boolean imgui-input-text-multiline (string string int int void* void* void* ) )
         (define-imgui float imgui-get-text-line-height () )
         (define-imgui int imgui-get-mouse-cursor () )
         (define-imgui boolean imgui-is-mouse-clicked (int boolean) )
         (define-imgui boolean imgui-is-mouse-down (int) )
         (define-imgui void imgui-image (void* void* void* void*) )



        (define imgui-set-cond-always 0)
        (define imgui-set-cond-once 2)
        (define imgui-set-cond-first-use-ever 4)
        (define imgui-set-cond-appearing 8)

        (define << fxarithmetic-shift-left)
        (define >> fxarithmetic-shift-right)
        (define-imgui void imgui-begin-group () )
        (define-imgui void imgui-end-group () )
        (define-imgui void imgui-same-line () )
        (define-imgui void imgui-separator () )



          )