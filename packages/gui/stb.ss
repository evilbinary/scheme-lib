;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui stb)
    (export
     stbi-load
     load-texture
     )

    (import (scheme) (utils libutil) (cffi cffi) (gles gles1))
    (load-librarys  "libgui")

    (def-function stbi-load
      "stbi_load" (string void* void* void* int) void*)

    (define (load-texture file)
      (let ((w (cffi-alloc 4))
	    (h (cffi-alloc 4))
	    (data 0)
	    (id 0)
	    (text-id (cffi-alloc 4))
	    (chanel (cffi-alloc 4)))
	(set! data (stbi-load file
			      w h chanel 4))
	;;(printf "load=>~a ~a ~a chanel=>~a\n"
	;; data
	;; (cffi-get-int w)
	;; (cffi-get-int h)
	;; (cffi-get-int chanel))
	(glGenTextures 1 text-id)

	(glBindTexture GL_TEXTURE_2D (cffi-get-int text-id))
	(glTexImage2D GL_TEXTURE_2D
		      0 GL_RGBA
		      (cffi-get-int w )
		      (cffi-get-int h)
		      0
		      GL_RGBA
		      GL_UNSIGNED_BYTE
		      data)
	(glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT)
	(glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT)
	(glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST)
	(glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST)
	(set! id (cffi-get-int text-id))
	(cffi-free text-id)
	(cffi-free w)
	(cffi-free h)
	(cffi-free chanel) id))
)
