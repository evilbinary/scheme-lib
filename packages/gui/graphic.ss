;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui graphic)
    (export
     graphic-init
     graphic-resize
     graphic-draw-text
     graphic-draw-line
     graphic-draw-solid-quad
     graphic-draw-texture-quad
     graphic-draw-line-strip
     graphic-render
     graphic-destroy
     graphic-sissor-begin
     graphic-sissor-end
     graphic-draw-round-rect

     graphic-new-edit
     graphic-draw-edit
     graphic-edit-add-text
     graphic-edit-set-text
     graphic-draw-string
     graphic-get-font
     graphic-draw-string-prepare
     graphic-draw-string-end
     graphic-draw-string-colors
     graphic-edit-set-color
     graphic-get-fps
     graphic-set-ratio

     load-shader
     
     gl-edit-set-foreground
     gl-edit-set-background
     gl-edit-set-font-size
     gl-edit-set-font-name
     gl-edit-set-font
     gl-edit-get-height

     gl-edit-set-highlight
     gl-edit-get-highlight
     gl-edit-update-highlight
     gl-edit-char-event
     gl-edit-get-text
     gl-edit-set-font
     gl-edit-mouse-event
     gl-edit-key-event
     gl-edit-set-scroll
     gl-edit-mouse-motion-event
     gl-edit-set-select-color
     gl-edit-set-cursor-color
     gl-edit-set-font-line-height
     
     )
    (import (scheme) (utils libutil) (cffi cffi) (gles gles2) )


    (load-librarys "libgui")
    
    (def-function glShaderSource2 "glShaderSource2" (int int string void*) void)
    (def-function shader-load-from-string "shader_load_from_string" (string string) int)
    (def-function shader-load "shader_load" (string string) int)
   
   
    (def-function gl-resize-edit-window "gl_resize_edit_window" (void* float float ) void)
    (def-function gl-edit-set-foreground "gl_edit_set_foreground" (void* int) void)
    (def-function gl-edit-set-background "gl_edit_set_background" (void* int) void)
    (def-function gl-edit-set-font-size "gl_edit_set_font_size" (void* float) void)
    (def-function gl-edit-set-font-name "gl_edit_set_font_name" (void* string) void)
    (def-function gl-edit-set-color "gl_edit_set_color" (void*  int) void)
    (def-function gl-edit-set-font "gl_edit_set_font" (void* string float) void)
    (def-function gl-edit-set-font-line-height "gl_edit_set_font_line_height" (void* float) void)

    (def-function gl-edit-set-editable "gl_edit_set_editable" (void*  int) void)


    (def-function gl-new-edit "gl_new_edit" (int float float float float) void*)
    (def-function gl-edit-add-text "gl_add_edit_text" (void*  string ) void)
    (def-function gl-edit-set-text  "gl_set_edit_text" (void*  string ) void)
    (def-function gl-edit-get-text  "gl_get_edit_text" (void* ) string)
    (def-function gl-edit-get-height  "gl_get_edit_height" (void* ) float)


    
    
    (def-function gl-render-edit "gl_render_edit" ( void* float float) void)
    (def-function gl-render-edit-once "gl_render_edit_once" ( void* float float string int) void)

    
    (def-function gl-edit-key-event "gl_edit_key_event" ( void* int int int int) void)
    (def-function gl-edit-char-event "gl_edit_char_event" ( void* int int) void)
    (def-function gl-edit-mouse-event "gl_edit_mouse_event" ( void* int float float) void)
    (def-function gl-edit-set-scroll "gl_edit_set_scroll" ( void*  float float) void)
    (def-function gl-edit-mouse-motion-event "gl_edit_mouse_motion_event" ( void* float float) void)
    
    (def-function gl-edit-set-select-color "gl_edit_set_select_color" ( void* int) void)
    (def-function gl-edit-set-cursor-color "gl_edit_set_cursor_color" ( void* int) void)


   
    
    (def-function graphic-get-fps "get_fps" (void) int)

    (def-function sth-create "sth_create" (int int) void*)
    (def-function sth-add-font "sth_add_font" (void* string) void*)
    (def-function mvp-create "mvp_create" (int int int) void*)
    (def-function mvp-set-mvp "mvp_set_mvp" (void*) void)
    (def-function mvp-get-projection "mvp_get_projection" (void*) void*)
    (def-function mat4-set-orthographic "mat4_set_orthographic" (void* float float float float float float) void)
    (def-function mvp-set-orthographic "mvp_set_orthographic" (void* float float float float float float) void)
   
    (def-function font-create "font_create" (string) void*)

    (def-function gl-render-string "gl_render_string" ( void* float string
							     float float
							     void* void* int) void)

    (def-function gl-render-string-colors "gl_render_string_colors" (void*
								     float 
								     float float
								     string
								     void*
								     float) void)
    
    (def-function gl-render-prepare-string "gl_render_prepare_string" (void* void*) void)
    (def-function gl-render-end-string "gl_render_end_string" (void*) void)
    (def-function gl-edit-set-highlight "gl_edit_set_highlight" (void* void*) void)
    (def-function gl-edit-get-highlight "gl_edit_get_highlight" (void*) void*)
    (def-function gl-edit-update-highlight "gl_edit_update_highlight" (void*) void)
   
    
    (define default-program 0)
    (define font-program 0)
    
    (define uniform-default-texture 0)
    (define uniform-default-model 0)
    (define uniform-default-view 0)
    (define uniform-default-projection 0)
    (define uniform-default-type 0)
    (define uniform-default-color 0)


    (define uniform-font-texture 0)
    (define uniform-font-model 0)
    (define uniform-font-view 0)
    (define uniform-font-projection 0)


    (define my-width 0)
    (define my-height 0)
    (define graphic-ratio 1.0)

    (define font-string-cache (make-hashtable equal-hash eqv?) )
    (define gtext 0)
    (define all-edit-cache (make-hashtable equal-hash eqv?) )
    (define all-font-cache (make-hashtable equal-hash eqv?))
    (define font-mvp 0)
    (define default-mvp 0)

    
    (define v-shader-str
      "uniform mat4 model;
      uniform mat4 view;
      uniform mat4 projection;
      uniform vec4 color;
      attribute vec3 vertex;
      attribute vec2 tex_coord;
      varying vec2 v_tex_coord;
      varying vec4 v_color;
      void main()
      {
        v_tex_coord=tex_coord;
        v_color=color;
        gl_Position=projection*view*model*vec4(vertex,1.0);
      }")

    (define f-shader-str 
      "uniform sampler2D texture;
      varying vec2 v_tex_coord;
      varying vec4 v_color;
      uniform int type;
      void main() 
      { 
        if( type==0 ){ 
           gl_FragColor = v_color;
        } else if(type==1){
          gl_FragColor = texture2D(texture, v_tex_coord); 
        } else{
          gl_FragColor =vec4(v_color.rgb,texture2D(texture, v_tex_coord ).a*v_color.a );
        }
      }")
          
    (define v-font-shader-str
      "uniform mat4 model;
      uniform mat4 view;
      uniform mat4 projection;
      attribute vec3 vertex;
      attribute vec2 tex_coord;
      attribute vec4 color;
      varying vec2 v_tex_coord;
      varying vec4 v_color; 
      void main()
      {
       v_tex_coord=tex_coord;
       v_color=color;
       gl_Position =projection*view*model*vec4(vertex,1.0);
       }"
      )
    
    (define f-font-shader-str
      "uniform sampler2D texture;
       varying vec2 v_tex_coord; 
       varying vec4 v_color;
       uniform int type;
       void main()
      {
        if( type==1 ){ 
           gl_FragColor = v_color;
        }else{
          gl_FragColor =vec4(v_color.rgb,texture2D(texture, v_tex_coord ).a*v_color.a );
        }
    }")

    (define (graphic-set-ratio ratio)
      (set! graphic-ratio ratio))

    (define (graphic-resize width height)
      (set! my-width  width)
      (set! my-height height)
      ;;(printf "resize ~a,~a\n" width height)
      (mvp-set-orthographic default-mvp 0.0 (* 1.0 my-width) (* 1.0 my-height) 0.0 1.0 -1.0 )
       
      (gl-resize-edit-window gtext width height)
      (let ((eds (vector->list (hashtable-values all-edit-cache))))
        (let loop ((ed eds))
          (if (pair? ed)
              (begin
          (gl-resize-edit-window (car ed) width height)
          (loop (cdr ed))))))
      )
    
    (define (graphic-init width height)
      (set! my-width width)
      (set! my-height height)
      (printf "init ~a,~a\n" width height)

      ;;default shader
      (set! default-program (load-shader v-shader-str f-shader-str '()))

      (set! uniform-default-texture (glGetUniformLocation default-program "texture"))
      (set! uniform-default-model (glGetUniformLocation default-program "model"))
      (set! uniform-default-view (glGetUniformLocation default-program "view"))
      (set! uniform-default-projection (glGetUniformLocation default-program "projection"))
      (set! uniform-default-color (glGetUniformLocation default-program "color"))
      (set! uniform-default-type (glGetUniformLocation default-program "type"))

      (set! default-mvp (mvp-create default-program my-width my-height ))
      (mvp-set-mvp default-mvp)

      ;;font shader
      (set! font-program (load-shader
			  v-font-shader-str
			  f-font-shader-str
			  (lambda (program)
			    (glBindAttribLocation program 0 "vertex")
			    (glBindAttribLocation program 1 "tex_coord")
			    (glBindAttribLocation program 2 "color")
			    )
			  ))
      ;;(set! font-program (shader-load-from-string v-font-shader-str f-font-shader-str))
      ;;(set! font-program (shader-load  "shaders/v3f-t2f-c4f.vert" "shaders/v3f-t2f-c4f.frag"))
      (set! uniform-font-texture (glGetUniformLocation font-program "texture"))
      (set! uniform-font-model (glGetUniformLocation font-program "model"))
      (set! uniform-font-view (glGetUniformLocation font-program "view"))
      (set! uniform-font-projection (glGetUniformLocation font-program "projection"))

      ;;editor
      (set! gtext (gl-new-edit font-program my-width my-height my-width my-height))
      (gl-edit-set-editable gtext 0)
      (set! font-mvp (mvp-create font-program my-width my-height ) )
      
      )

    
    (define (load-shader v-str f-str bind)
      (let ((vert-shader -1)
	    (program -1)
	    (frag-shader -1)
	    )
      (set! vert-shader (glCreateShader GL_VERTEX_SHADER))
      (glShaderSource2  vert-shader 1 v-str  0 )
      (glCompileShader vert-shader)
      (set! frag-shader (glCreateShader GL_FRAGMENT_SHADER))
      (glShaderSource2  frag-shader 1 f-str  0 )
      (glCompileShader frag-shader)
      (set! program (glCreateProgram))
      ;;(printf "vert-shader ~a frag-shader ~a program ~a\n" vert-shader frag-shader program)
      (glAttachShader program vert-shader)
      (glAttachShader program frag-shader)
      (if (procedure? bind)
          (bind program)
          (begin 
            (glBindAttribLocation program 0 "vertex")
            (glBindAttribLocation program 1 "tex_coord")
            (glBindAttribLocation program 2 "color"))
            )

      (glLinkProgram program)
      (glUseProgram program)
      ;;(set! uniform-round-color (glGetUniformLocation round-program "color"))
      ;;(set! uniform-round-screen-size (glGetUniformLocation round-program "screenSize"))
      program)
      )
     
    (define (graphic-new-edit w h)
      (let ((ed (gl-new-edit font-program w h my-width my-height) ))
        (hashtable-set! all-edit-cache ed  ed)
        ed
        ))

    (define (graphic-draw-edit edit x y)
      (gl-render-edit edit x   y))

    (define (graphic-edit-add-text edit text)
      (gl-edit-add-text edit text))

    (define (graphic-edit-set-text edit text)
      (gl-edit-set-text edit text))

    (define (graphic-edit-set-color edit color)
      (gl-edit-set-color edit color))

    (define graphic-draw-text
      (case-lambda
       [(x y  text)
	      (gl-render-edit-once gtext x  y text #xffffffff)]
       [(x y text color)
	      (gl-render-edit-once gtext x  y text color)]
      ))

    (define (graphic-get-font name)
      (let ((font (hashtable-ref all-font-cache name '())))
        (if (null? font)
            (begin 
              (set! font  (font-create name))
              (hashtable-set! all-font-cache name font)
              font)
            font
            )))
    
    (define (graphic-new-mvp)
      (mvp-create default-program my-width my-height ))

    (define (graphic-draw-string-prepare  font)
      (gl-render-prepare-string  font-mvp font)
      )

    (define (graphic-draw-string-end font)
      (gl-render-end-string font)
      )

    (define cache-dx (cffi-alloc 8))
    (define cache-dy (cffi-alloc 8))
    
    (define (graphic-draw-string font size color x y text )
      (let ((ret '()))
        ;;(printf "font=~a\n" font)
        (gl-render-string font size text x y cache-dx cache-dy color ) ;;(- (* graphic-ratio my-height) y)
        (set! ret (list (cffi-get-float cache-dx) (cffi-get-float cache-dy)))
        ret
        ))

    (define (graphic-draw-string-colors font size x y text colors width)
      (gl-render-string-colors font size  x y text colors width) ) ;;(- (* graphic-ratio my-height) y)
    
    (define graphic-draw-line
      (case-lambda
       [( x1 y1 x2 y2 r g b a)
        (let ((vertices (v 'float (list x1 y1 x2 y2))))
          (glUseProgram default-program)
          (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
          (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
          (glEnableVertexAttribArray 0)
          (glDrawArrays GL_LINE_STRIP 0 2)
          (glUseProgram 0)
          (uv vertices)
          )]
        [( x1 y1 x2 y2 color)
        (let ((vertices (v 'float (list x1 y1 x2 y2)))
              (r (fixnum->flonum  (bitwise-bit-field color 16 24)))
              (g (fixnum->flonum  (bitwise-bit-field color 8 16)))
              (b (fixnum->flonum  (bitwise-bit-field color 0 8)))
              (a  (/ (fixnum->flonum  (if (= 0 (bitwise-bit-field color 24 32))
                  255
                  (bitwise-bit-field color 24 32)
                  )) 255.0)) )
              
          (glUseProgram default-program)
          (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
          (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
          (glEnableVertexAttribArray 0)
          (glDrawArrays GL_LINE_STRIP 0 2)
          (glUseProgram 0)
          (uv vertices)
          )]
	    ))

    (define (graphic-draw-line-strip lines r g b a)
      (let ((vertices (v 'float lines)))
        (glUseProgram default-program)
        (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
        (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
        (glEnableVertexAttribArray 0)
        (glDrawArrays GL_LINE_STRIP 0 2)
        (glUseProgram 0)
        (uv vertices)
        ))

    (define graphic-draw-round-rect
          (case-lambda
          [(x1 y1 x2 y2  r g b a)
            (let ((vertices (v 'float (list x1 y2
                    x1 y1
                    x2 y2 x2 y1))))
              (glUseProgram default-program)
              ;;(glUniform4f uniform-round-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
              (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
              (glEnableVertexAttribArray 0)
              (glDrawArrays GL_TRIANGLE_STRIP 0 4)
              (glUseProgram 0)
              (uv vertices)
              )]
          [(x1 y1 x2 y2  color)
            (let ((vertices (v 'float (list x1 y2
                    x1 y1
                    x2 y2 x2 y1)))
                  (r (fixnum->flonum  (bitwise-bit-field color 16 24)))
                  (g (fixnum->flonum  (bitwise-bit-field color 8 16)))
                  (b (fixnum->flonum  (bitwise-bit-field color 0 8)))
                  (a  (/ (fixnum->flonum  (if (= 0 (bitwise-bit-field color 24 32))
                      255
                      (bitwise-bit-field color 24 32)
                      )) 255.0)) )
              
              (glUseProgram default-program)
              ;;(glUniform4f uniform-round-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
              (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
              (glEnableVertexAttribArray 0)
              (glDrawArrays GL_TRIANGLE_STRIP 0 4)
              (glUseProgram 0)
              (uv vertices)
              )]
          ))

    (define graphic-draw-solid-quad
      (case-lambda
       [(x1 y1 x2 y2  r g b a)
        (let ((vertices (v 'float (list x1 y2
                x1 y1
                x2 y2 x2 y1))))
          (glUseProgram default-program)
          (glUniform1i uniform-default-type 0)
          (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
          (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
          (glEnableVertexAttribArray 0)
          (glDrawArrays GL_TRIANGLE_STRIP 0 4)
          (glUseProgram 0)
          (uv vertices)
          )]
       [(x1 y1 x2 y2  color)
        (let ((vertices (v 'float (list x1 y2
                x1 y1
                x2 y2 x2 y1)))
              (r (fixnum->flonum  (bitwise-bit-field color 16 24)))
              (g (fixnum->flonum  (bitwise-bit-field color 8 16)))
              (b (fixnum->flonum  (bitwise-bit-field color 0 8)))
              (a  (/ (fixnum->flonum  (if (= 0 (bitwise-bit-field color 24 32))
                      255
                      (bitwise-bit-field color 24 32)
                      )) 255.0)) )
                      
          (glUseProgram default-program)
          (glUniform1i uniform-default-type 0)
          (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
          (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
          (glEnableVertexAttribArray 0)
          (glDrawArrays GL_TRIANGLE_STRIP 0 4)
          (glUseProgram 0)
          (uv vertices)
          )]
      ))


    (define (graphic-draw-texture-quad x1 y1 x2 y2 tx1 ty1 tx2 ty2 texture-id)
      
       (let ((vertices (v 'float (list x1 y2
				      x1 y1
				      x2 y2
				      x2 y1)))
	     (text-coords (v 'float (list
				     tx1 ty2
				     tx1 ty1
				     tx2 ty2
				     tx2 ty1)))
	     )
	
      (glUseProgram default-program)
      (glActiveTexture GL_TEXTURE0)
      (glBindTexture GL_TEXTURE_2D texture-id)
      (glEnable GL_TEXTURE_2D);
      (glUniform1i uniform-default-texture 0)
      (glUniform1i uniform-default-type 1)
      (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
      (glEnableVertexAttribArray 0)
      (glVertexAttribPointer 1 2 GL_FLOAT GL_FALSE 0 text-coords)
      (glEnableVertexAttribArray 1)
      (glDrawArrays GL_TRIANGLE_STRIP 0 4)
      (glUseProgram 0)
      (uv vertices)
      (uv text-coords)
      ))
      
    (define (graphic-sissor-begin x y width height)
       (glEnable GL_SCISSOR_TEST)
       (glScissor 
          (flonum->fixnum  (* graphic-ratio x ))
          (flonum->fixnum (* graphic-ratio (- my-height y height) ) )
          (flonum->fixnum (* graphic-ratio width ))
          (flonum->fixnum (* graphic-ratio height) ))
      ;;(glScissor 0 0 800 600)
    )

    (define (graphic-sissor-end )
       (glDisable GL_SCISSOR_TEST)
    )

    (define (graphic-render)
      '()
    )
    (define (graphic-destroy )
     '())

    (define (v type vec )
      (if (list? vec)
          (set! vec (list->vector vec)))
      (let* ((len (vector-length vec))
             (size (foreign-sizeof type))
            (data (foreign-alloc (*  len size)))
            )
        (let loop ((i  0))
          (if (< i len)
              (let ((v (vector-ref vec i)))
                (cond
                  ((flonum? v) (foreign-set! type data (* i size) v))
                  ((fixnum? v) (foreign-set! type data (* i size) v)))
                     (loop (+ i 1)
                           )
                     )))
        data))
    (define (uv vec)
      (foreign-free vec))

)
