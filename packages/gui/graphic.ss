;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui graphic)
    (export
     graphic-init
     graphic-resize
     graphic-draw-text
     graphic-draw-text-immediate
     graphic-draw-line
     graphic-draw-solid-quad
     graphic-draw-texture-quad
     graphic-draw-line-strip
     graphic-render
     graphic-destroy
     graphic-sissor-begin
     graphic-sissor-end
     graphic-draw-round-rect
     graphic-draw-string
     graphic-draw-string-immediate
     graphic-draw-string-prepare
     graphic-draw-string-end
     graphic-draw-string-colors
     graphic-get-font
     graphic-get-fps
     graphic-set-ratio
     graphic-measure-text
     graphic-get-font-lineh
     graphic-get-font-height
     load-shader
     graphic-add-init-event
     graphic-add-resize-event
    
     )
    (import (scheme) (utils libutil) (cffi cffi) (gles gles2) (gui utils) )


    (load-librarys "libgui")
    
    (def-function glShaderSource2 "glShaderSource2" (int int string void*) void)
    (def-function shader-load-from-string "shader_load_from_string" (string string) int)
    (def-function shader-load "shader_load" (string string) int)
       
    
    (def-function graphic-get-fps "get_fps" (void) int)

    (def-function sth-create "sth_create" (int int) void*)
    (def-function sth-add-font "sth_add_font" (void* string) void*)
    (def-function mvp-create "mvp_create" (int int int) void*)
    (def-function mvp-set-mvp "mvp_set_mvp" (void*) void)
    (def-function mvp-get-projection "mvp_get_projection" (void*) void*)
    (def-function mat4-set-orthographic "mat4_set_orthographic" (void* float float float float float float) void)
    (def-function mvp-set-orthographic "mvp_set_orthographic" (void* float float float float float float) void)
   
    (def-function font-new "new_font" (string float) void*)
    (def-function font-copy "copy_font" (void* float) void*)

    (def-function measure-text "measure_text" (void* float string int) float)

    (def-function graphic-new "graphic_new" (int int  int float) void*)
    (def-function graphic-get-font-line-height "graphic_get_font_lineh" (void*  float) float)
    (def-function graphic-get-font-h "graphic_get_font_height" (void*  float) float)


   
    (def-function graphic-render-string-immediate "graphic_render_string_immediate" (void* void*
                   float
							     float float
                   string
							     void* void* int) void)
    (def-function graphic-render-string "graphic_render_string" (void*
                   float
							     float float
                   string
							     void* void* int) void)
    (def-function graphic-render-string-colors "graphic_render_string_colors" (void*
								     float float
								     string
								     void*
								     float) void)
    (def-function graphic-render-prepare-string "graphic_render_prepare_string" (void* void*) void)
    (def-function graphic-render-end-string "graphic_render_end_string" (void*) void)

   
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

    (define all-font-cache (make-hashtable equal-hash eqv?))
    (define font-mvp 0)
    (define default-mvp 0)
    (define default-font-name "Roboto-Regular.ttf")
    (define default-font-size 18.0)
    (define graphic-init-events '())
    (define graphic-resize-events '())
    (define graphic-vars (make-hashtable equal-hash eqv?) )

    
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
      (mvp-set-orthographic default-mvp 0.0 my-width my-height 0.0 1.0 -1.0 )
      (mvp-set-orthographic font-mvp 0.0  (* graphic-ratio my-width)  (* graphic-ratio my-height) 0.0 1.0 -1.0)

      (loop-event graphic-resize-events graphic-vars width height)
      )
    
    (define (graphic-add-init-event proc)
      (add-event graphic-init-events proc)
      )

    (define (graphic-add-resize-event proc)
      (add-event graphic-resize-events proc)
      )

    (define (graphic-init width height)
      (set! my-width width)
      (set! my-height height)

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

      (set! font-mvp (mvp-create font-program  (* graphic-ratio my-width)   (* graphic-ratio  my-height))  )

      ;;set graphic vars
      (hashtable-set! graphic-vars 'font-program font-program)
      (hashtable-set! graphic-vars 'font-mvp  font-mvp)
      (hashtable-set! graphic-vars 'my-width  my-width)
      (hashtable-set! graphic-vars 'my-height  my-height)
      (hashtable-set! graphic-vars 'ratio  graphic-ratio)

      
      ;;init event
      (loop-event graphic-init-events graphic-vars my-width my-height)
      
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

    (define graphic-draw-text-immediate
      (case-lambda
       [(x y  text)
        (graphic-draw-string-immediate font-mvp (graphic-get-font default-font-name) -1.0 #xffffffff x  y  text)
        ]
       [(x y text color)
        (graphic-draw-string-immediate font-mvp (graphic-get-font default-font-name) -1.0 color x  y  text)
        ]
      [(font x y text color)
        (graphic-draw-string-immediate font-mvp font -1.0 color x  y  text)
        ]
      [(font size x y text color)
        (graphic-draw-string-immediate font-mvp font size color x  y  text)
        ]
      ))

    (define graphic-draw-text
      (case-lambda
       [(x y  text)
        (graphic-draw-string (graphic-get-font default-font-name) -1.0 #xffffffff x  y  text)
        ]
       [(x y text color)
        (graphic-draw-string (graphic-get-font default-font-name) -1.0 color x  y  text)
        ]
      [(font x y  text color)
        (graphic-draw-string font -1.0 color x  y  text)
        ]
      [(font size x y text color)
        (graphic-draw-string font size color x  y  text)
        ]
      ))

    (define (graphic-measure-text font size text)
      ;;(/ (measure-text font size text -1) graphic-ratio)
      (measure-text font size text -1)
    
    )
    (define (graphic-get-font-lineh font size)
       ;;(/  (graphic-get-font-line-height font  size  )  graphic-ratio)
        (graphic-get-font-line-height font  size  )
    )

    (define (graphic-get-font-height font size)
      ;;(/ (graphic-get-font-h font  size ) graphic-ratio)
      (graphic-get-font-h font  size )
    )

    (define graphic-get-font 
      (case-lambda
      [(name)
      (if (null? name)
        (set! name default-font-name))
        (let ((font (hashtable-ref all-font-cache name '())))
          (if (null? font)
              (begin 
                (set! font  (font-new name  (*  graphic-ratio default-font-size)))
                (hashtable-set! all-font-cache name font)
                font)
              font
              ))]
      [(name size)
      (if (null? name)
        (set! name default-font-name))
        (let ((font (hashtable-ref all-font-cache name '())))
          (if (null? font)
              (begin 
                (set! font  (font-new name (* size graphic-ratio)))
                (hashtable-set! all-font-cache name font)
                font)
              (font-copy font (* size graphic-ratio))
              ))]
        )
    )
      
    
    (define (graphic-new-mvp)
      (mvp-create default-program my-width my-height ))

    (define (graphic-draw-string-prepare  font)
      (graphic-render-prepare-string  font-mvp font)
      )

    (define (graphic-draw-string-end font)
      (graphic-render-end-string font)
      )

    (define cache-dx (cffi-alloc 8))
    (define cache-dy (cffi-alloc 8))
    
    (define graphic-draw-string 
      (case-lambda
      [(font size color x y text )
        (let ((ret '()))
          (graphic-render-string font (* size graphic-ratio) (* graphic-ratio x)  (* graphic-ratio y) text cache-dx cache-dy color ) ;;(- (* graphic-ratio my-height) y)
          (set! ret (list (cffi-get-float cache-dx) (cffi-get-float cache-dy)))
          ret
          )]
      [(font color x y text )
        (let ((ret '()))
          (graphic-render-string font -1.0 (* graphic-ratio x)  (* graphic-ratio y) text cache-dx cache-dy color ) ;;(- (* graphic-ratio my-height) y)
          (set! ret (list (cffi-get-float cache-dx) (cffi-get-float cache-dy)))
          ret
          )]
         ))

    (define graphic-draw-string-immediate
      (case-lambda
      [(mvp font size color x y text )
        (let ((ret '()))
          (graphic-render-string-immediate mvp font (* size graphic-ratio) (* graphic-ratio x)  (* graphic-ratio y) text cache-dx cache-dy color ) ;;(- (* graphic-ratio my-height) y)
          (set! ret (list (cffi-get-float cache-dx) (cffi-get-float cache-dy)))
          ret
          )]
      [(mvp font color x y text )
        (let ((ret '()))
          (graphic-render-string-immediate mvp font -1.0 (* graphic-ratio x)  (* graphic-ratio y) text cache-dx cache-dy color ) ;;(- (* graphic-ratio my-height) y)
          (set! ret (list (cffi-get-float cache-dx) (cffi-get-float cache-dy)))
          ret
          )]
         ))

    (define (graphic-draw-string-colors font x y text colors width)
      (graphic-render-string-colors font  x y text colors width) ) ;;(- (* graphic-ratio my-height) y)
    
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

    (define graphic-draw-line-strip 
       (case-lambda 
       [(lines r g b a)
        (let ((vertices (v 'float lines)))
          (glUseProgram default-program)
          (glUniform4f uniform-default-color (/ r 255.0) (/ g 255.0) (/ b 255.0) (* a 1.0))
          (glVertexAttribPointer 0 2 GL_FLOAT GL_FALSE 0 vertices)
          (glEnableVertexAttribArray 0)
          (glDrawArrays GL_LINE_STRIP 0 (/ (length lines ) 2))
          (glUseProgram 0)
          (uv vertices)
        )]

        [(lines color)
        (let ((vertices (v 'float lines))
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
          (glDrawArrays GL_LINE_STRIP 0 (/ (length lines ) 2))
          (glUseProgram 0)
          (uv vertices)
        )]
        
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
        (let ((vertices (v 'float (list 
                x1 y2
                x1 y1
                x2 y2 
                x2 y1 
                ))))
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
