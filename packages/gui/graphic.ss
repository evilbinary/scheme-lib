;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui graphic)
    (export
     graphic-init
     graphic-draw-line
     graphic-draw-solid-quad
     graphic-draw-texture-quad
     graphic-draw-line-strip
     graphic-draw-text
     graphic-render
     graphic-destroy
     graphic-set-text-font-size
     graphic-set-text-font-color
     graphic-sissor-begin
     graphic-sissor-end

     graphic-new-edit
     graphic-draw-edit
     graphic-edit-add-text
     graphic-new-markup
     gl-markup-set-foreground
     gl-markup-set-background
     gl-markup-set-font-size
     gl-edit-set-markup
     gl-edit-char-event
     
     graphic-get-fps
     gl-edit-key-event
     )
    (import (scheme) (utils libutil) (cffi cffi) (gles gles2) )


    (load-librarys "libgui")
    
    (def-function glShaderSource2 "glShaderSource2" (int int string void*) void)
    (def-function shader-load-from-string "shader_load_from_string" (string string) int)
    (def-function shader-load "shader_load" (string string) int)
   
    (def-function gl-render-text "gl_render_text" (void* float float) void)
    (def-function gl-update-text "gl_update_text" (void* string) void)
    (def-function gl-new-text "gl_new_text" (int float float) void*)
    (def-function gl-destroy-text "gl_destroy_text" (void*) void)
    (def-function gl-set-text-font-size "gl_set_text_font_size" (void* float) void)
    (def-function gl-set-text-font-color "gl_set_text_font_color" (void* float float float float) void)


    (def-function gl-new-markup "gl_new_markup" (string float) void*)
    (def-function gl-markup-set-foreground "gl_markup_set_foreground" (void* float float float float) void)
    (def-function gl-markup-set-background "gl_markup_set_background" (void* float float float float) void)
    (def-function gl-markup-set-font-size "gl_markup_set_font_size" (void* float) void)

    (def-function gl-edit-set-markup "gl_edit_set_markup" (void* void* int) void)
    (def-function gl-new-edit "gl_new_edit" (int float float float float) void*)
    (def-function gl-edit-add-text "gl_add_edit_text" (void*  string ) void)
    (def-function gl-render-edit "gl_render_edit" ( void* float float) void)
    (def-function gl-edit-key-event "gl_edit_key_event" ( void* int int int int) void)
    (def-function gl-edit-char-event "gl_edit_char_event" ( void* int int) void)

    (def-function graphic-get-fps "get_fps" (void) int)

    
    (define texture-vert-shader 0)
    (define texture-frag-shader 0)

   
    (define v-shader-str
      "attribute vec2 vPosition;   \n
      attribute vec2 vTexCoord;   \n
      varying vec2 v_TexCoordinate; \n
      uniform vec2 screenSize;    \n
      void main()                 \n
      {                           \n
        v_TexCoordinate = vTexCoord; \n
        gl_Position = vec4(vPosition.x * 2.0 / screenSize.x - 1.0, ( screenSize.y - vPosition.y) * 2.0 / screenSize.y - 1.0, 0.0, 1.0); \n
           }                       \n
      \n"
      )

    (define f-shader-str
      "                  \n
       uniform sampler2D u_Texture;               \n
       varying vec2 v_TexCoordinate;              \n
       void main()                                \n
       {                                          \n
             gl_FragColor = texture2D(u_Texture, v_TexCoordinate); \n
       }                                          \n")

    (define v-solid-shader-str
      "attribute vec2 vPosition;   \n
           uniform vec2 screenSize;    \n
           void main()                 \n
           {                           \n
              gl_Position = vec4(vPosition.x * 2.0 / screenSize.x - 1.0, ( screenSize.y - vPosition.y) * 2.0 / screenSize.y - 1.0, 0.0, 1.0); \n
           }                           \n"
	   )

    (define f-solid-shader-str
       "                  \n
        uniform vec4 color;                        \n
        void main()                                \n
        {                                          \n
          gl_FragColor = color;                    \n
        }                                          \n")

    
    (define texture-program 0)

    (define uniform-screen-size 0)
    (define uniform-texture 0)

    (define uniform-solid-color 0)
    (define uniform-solid-screen-size 0)

    (define solid-program 0)

    (define solid-vert-shader 0)
    (define solid-frag-shader 0)

    (define my-width 0)
    (define my-height 0)

    (define font-string-cache (make-hashtable equal-hash eqv?) )

    (define font-program 0)

    (define font-vert-shader 0)
    (define font-frag-shader 0)
    (define uniform-font-texture 0)
    (define  uniform-font-model 0)
    (define uniform-font-view 0)
    (define uniform-font-projection 0)
    
    (define f-font-shader-str
      "uniform sampler2D texture;
       void main()
      {
        float a = texture2D(texture,gl_TexCoord[0].xy).r;
        gl_FragColor = vec4(gl_Color.rgb, gl_Color.a*a);
    }")
    
    (define v-font-shader-str
      "uniform mat4 model;\n
      uniform mat4 view;\n
      uniform mat4 projection;\n
      attribute vec3 vertex;\n
      attribute vec2 tex_coord;\n
      attribute vec4 color;\n
      void main()\n
      {\n
       gl_TexCoord[0].xy = tex_coord;
       gl_FrontColor     = color;\n
       gl_Position      =projection*(view*(model*vec4(vertex,1.0)));\n
       }"
    )

    (define ptext 0)
    
    (define (graphic-init width height)
      (set! my-width width)
      (set! my-height height)
      
      (set! texture-vert-shader (glCreateShader GL_VERTEX_SHADER))
            
      (glShaderSource2 texture-vert-shader 1 v-shader-str 0 )
      (glCompileShader texture-vert-shader)


      (set! texture-frag-shader (glCreateShader GL_FRAGMENT_SHADER))
      (glShaderSource2 texture-frag-shader 1 f-shader-str 0 )
      (glCompileShader texture-frag-shader)

      
      (set! texture-program (glCreateProgram ))
      (glAttachShader texture-program texture-vert-shader)
      (glAttachShader texture-program texture-frag-shader)

      (glBindAttribLocation texture-program 0 "vPosition")
      (glBindAttribLocation texture-program 1 "vTexCoord")
      
      (glLinkProgram texture-program)
      (glUseProgram texture-program)

      (set! uniform-screen-size (glGetUniformLocation texture-program "screenSize"))
      (set! uniform-texture (glGetUniformLocation texture-program "u_Texture"))


      ;;solid shader
      (set! solid-vert-shader (glCreateShader GL_VERTEX_SHADER))
      (glShaderSource2  solid-vert-shader 1 v-solid-shader-str  0 )
      (glCompileShader solid-vert-shader)
      (set! solid-frag-shader (glCreateShader GL_FRAGMENT_SHADER))
      
      (glShaderSource2  solid-frag-shader 1 f-solid-shader-str  0 )
      (glCompileShader solid-frag-shader)
      
      (set! solid-program (glCreateProgram))
      (glAttachShader solid-program solid-vert-shader)
      (glAttachShader solid-program solid-frag-shader)
      (glBindAttribLocation solid-program 0 "vPosition")
      (glLinkProgram solid-program)
      (glUseProgram solid-program)

      (set! uniform-solid-color (glGetUniformLocation solid-program "color"))
      (set! uniform-solid-screen-size (glGetUniformLocation solid-program "screenSize"))

      ;;(draw-line solid-program uniform-solid-screen-size uniform-solid-color  0.0 0.0 200.0 200.0 255.0 0.0 0.0 0.0 )
      ;;(graphic-draw-line 0.0 12.0 34.0 56.0 255.0 0.0 0.0 0.0 )

      ;;font shader
      (set! font-vert-shader (glCreateShader GL_VERTEX_SHADER))
      (glShaderSource2  font-vert-shader 1 v-font-shader-str  0 )
      (glCompileShader font-vert-shader)
      (set! font-frag-shader (glCreateShader GL_FRAGMENT_SHADER))
      
      (glShaderSource2  font-frag-shader 1 f-font-shader-str  0 )
      (glCompileShader font-frag-shader)
      
      (set! font-program (glCreateProgram))
      (glAttachShader font-program font-vert-shader)
      (glAttachShader font-program font-frag-shader)
      
      (glLinkProgram font-program)
      (glUseProgram font-program)

      ;;(set! font-program (shader-load-from-string v-font-shader-str f-font-shader-str))
      ;;(set! font-program (shader-load  "shaders/v3f-t2f-c4f.vert" "shaders/v3f-t2f-c4f.frag"))
      
      (set! uniform-font-texture (glGetUniformLocation font-program "texture"))
      (set! uniform-font-model (glGetUniformLocation font-program "model"))
      (set! uniform-font-view (glGetUniformLocation font-program "view"))
      (set! uniform-font-projection (glGetUniformLocation font-program "projection"))

      
      ;;(set! ptext (gl-new-text font-program my-width my-height))

      )

    (define (graphic-new-edit w h)
      (gl-new-edit font-program w h my-width my-height)
      )

    (define (graphic-draw-edit edit x y)
      (gl-render-edit edit x  (-  my-height y)))

    (define (graphic-edit-add-text edit text markup)
       (gl-edit-add-text edit text))

    (define (graphic-new-markup name size)
      (gl-new-markup name size))
    

    (define (graphic-new-text text)
      (let ((t (gl-new-text font-program my-width my-height)))
      t))
    
    (define graphic-draw-text
      (case-lambda
       [(t x1 y1 t2)
        (gl-render-text t x1 y1)]
       [(x1 y1 text)
	(let ((p (hashtable-ref font-string-cache text '())))
	  (if (null? p)
	      (begin
		(set! p (graphic-new-text text))
		(gl-update-text p text)
		(hashtable-set! font-string-cache text  p)
		))
	  (gl-render-text p x1 (- my-height y1)))
	]
       ))

    (define (graphic-set-text-font-size text size)
      (let ((p (hashtable-ref font-string-cache text '())))
	(if (null? p)
	    (begin
	      (set! p (graphic-new-text text))
	      (gl-update-text p text)
	      (hashtable-set! font-string-cache text  p)
	      ))
	(gl-set-text-font-size p size)
	))

    (define (graphic-set-text-font-color text r g b a)
      (let ((p (hashtable-ref font-string-cache text '())))
	(if (null? p)
	    (begin
	      (set! p (graphic-new-text text))
	      (gl-update-text p text)
	      (hashtable-set! font-string-cache text  p)
	      ))
	(gl-set-text-font-color p r g b a)
	))

    (define (graphic-draw-line x1 y1 x2 y2 r g b a)
      (let ((vertices (v 'float (list x1 y1 x2 y2))))
	(glUseProgram solid-program)
	(glUniform2f uniform-solid-screen-size (* 1.0 my-width) (* 1.0 my-height))
	(glUniform4f uniform-solid-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
	(glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
	(glEnableVertexAttribArray 0)
	(glDrawArrays GL_LINE_STRIP 0 2)
	(glUseProgram 0)
	(uv vertices)
	))

    (define (graphic-draw-line-strip lines r g b a)
      (let ((vertices (v 'float lines)))
	(glUseProgram solid-program)
	(glUniform2f uniform-solid-screen-size (* 1.0 my-width) (* 1.0 my-height))
	(glUniform4f uniform-solid-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
	(glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
	(glEnableVertexAttribArray 0)
	(glDrawArrays GL_LINE_STRIP 0 2)
	(glUseProgram 0)
	(uv vertices)
	))

    (define (graphic-sissor-begin x y width height)
       (glEnable GL_SCISSOR_TEST)
       (glScissor (* 2 (flonum->fixnum x ))  (* 2 (- my-height (flonum->fixnum height) (flonum->fixnum y ) ))
          (* 2 (flonum->fixnum width ))
          (* 2 (flonum->fixnum height) ))
      ;;(glScissor 660 240 800 600)
    )
    (define (graphic-sissor-end )
       (glDisable GL_SCISSOR_TEST)
    )

    (define (graphic-draw-solid-quad x1 y1 x2 y2  r g b a)
      (let ((vertices (v 'float (list x1 y2
				      x1 y1
				      x2 y2 x2 y1))))
	(glUseProgram solid-program)
	(glUniform2f uniform-solid-screen-size (* 1.0 my-width) (* 1.0 my-height))
	(glUniform4f uniform-solid-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
	(glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
	(glEnableVertexAttribArray 0)
	(glDrawArrays GL_TRIANGLE_STRIP 0 4)
	(glUseProgram 0)
	(uv vertices)
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
	
	(glUseProgram texture-program)
	(glUniform2f uniform-solid-screen-size (* 1.0 my-width) (* 1.0 my-height))
	(glActiveTexture GL_TEXTURE0)
	(glBindTexture GL_TEXTURE_2D texture-id)
	(glUniform1i uniform-texture 0)
	
	;;(glUniform4f uniform-solid-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
	(glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
	(glEnableVertexAttribArray 0)
	(glVertexAttribPointer 1 2 GL_FLOAT GL_FALSE 0 text-coords)
	(glEnableVertexAttribArray 1)
	(glDrawArrays GL_TRIANGLE_STRIP 0 4)
	(glUseProgram 0)
	(uv vertices)
	(uv text-coords)
	))
      

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
