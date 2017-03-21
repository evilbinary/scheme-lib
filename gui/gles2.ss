;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gles2)
         (export
            GL_ES_VERSION_2_0

            ; ClearBufferMask
            GL_DEPTH_BUFFER_BIT
            GL_STENCIL_BUFFER_BIT
            GL_COLOR_BUFFER_BIT

            ; Boolean
            GL_FALSE
            GL_TRUE

            ; BeginMode
            GL_POINTS
            GL_LINES
            GL_LINE_LOOP
            GL_LINE_STRIP
            GL_TRIANGLES
            GL_TRIANGLE_STRIP
            GL_TRIANGLE_FAN

            ; AlphaFunction (not supported in ES
            ;      GL_NEVER
            ;      GL_LESS
            ;      GL_EQUAL
            ;      GL_LEQUAL
            ;      GL_GREATER
            ;      GL_NOTEQUAL
            ;      GL_GEQUAL
            ;      GL_ALWAYS

            ; BlendingFactorDest
            GL_ZERO
            GL_ONE
            GL_SRC_COLOR
            GL_ONE_MINUS_SRC_COLOR
            GL_SRC_ALPHA
            GL_ONE_MINUS_SRC_ALPHA
            GL_DST_ALPHA
            GL_ONE_MINUS_DST_ALPHA

            ; BlendingFactorSrc
            ;      GL_ZERO
            ;      GL_ONE
            GL_DST_COLOR
            GL_ONE_MINUS_DST_COLOR
            GL_SRC_ALPHA_SATURATE
            ;      GL_SRC_ALPHA
            ;      GL_ONE_MINUS_SRC_ALPHA
            ;      GL_DST_ALPHA
            ;      GL_ONE_MINUS_DST_ALPHA

            ; BlendEquationSeparate
            GL_FUNC_ADD
            GL_BLEND_EQUATION
            GL_BLEND_EQUATION_RGB                 ; same as BLEND_EQUATION
            GL_BLEND_EQUATION_ALPHA

            ; BlendSubtract
            GL_FUNC_SUBTRACT
            GL_FUNC_REVERSE_SUBTRACT

            ; Separate Blend Functions
            GL_BLEND_DST_RGB
            GL_BLEND_SRC_RGB
            GL_BLEND_DST_ALPHA
            GL_BLEND_SRC_ALPHA
            GL_CONSTANT_COLOR
            GL_ONE_MINUS_CONSTANT_COLOR
            GL_CONSTANT_ALPHA
            GL_ONE_MINUS_CONSTANT_ALPHA
            GL_BLEND_COLOR

            ; Buffer Objects
            GL_ARRAY_BUFFER
            GL_ELEMENT_ARRAY_BUFFER
            GL_ARRAY_BUFFER_BINDING
            GL_ELEMENT_ARRAY_BUFFER_BINDING

            GL_STREAM_DRAW
            GL_STATIC_DRAW
            GL_DYNAMIC_DRAW

            GL_BUFFER_SIZE
            GL_BUFFER_USAGE

            GL_CURRENT_VERTEX_ATTRIB

            ; CullFaceMode
            GL_FRONT
            GL_BACK
            GL_FRONT_AND_BACK

            ; DepthFunction
            ;      GL_NEVER
            ;      GL_LESS
            ;      GL_EQUAL
            ;      GL_LEQUAL
            ;      GL_GREATER
            ;      GL_NOTEQUAL
            ;      GL_GEQUAL
            ;      GL_ALWAYS

            ; EnableCap
            GL_TEXTURE_2D
            GL_CULL_FACE
            GL_BLEND
            GL_DITHER
            GL_STENCIL_TEST
            GL_DEPTH_TEST
            GL_SCISSOR_TEST
            GL_POLYGON_OFFSET_FILL
            GL_SAMPLE_ALPHA_TO_COVERAGE
            GL_SAMPLE_COVERAGE

            ; ErrorCode
            GL_NO_ERROR
            GL_INVALID_ENUM
            GL_INVALID_VALUE
            GL_INVALID_OPERATION
            GL_OUT_OF_MEMORY

            ; FrontFaceDirection
            GL_CW
            GL_CCW

            ; GetPName
            GL_LINE_WIDTH
            GL_ALIASED_POINT_SIZE_RANGE
            GL_ALIASED_LINE_WIDTH_RANGE
            GL_CULL_FACE_MODE
            GL_FRONT_FACE
            GL_DEPTH_RANGE
            GL_DEPTH_WRITEMASK
            GL_DEPTH_CLEAR_VALUE
            GL_DEPTH_FUNC
            GL_STENCIL_CLEAR_VALUE
            GL_STENCIL_FUNC
            GL_STENCIL_FAIL
            GL_STENCIL_PASS_DEPTH_FAIL
            GL_STENCIL_PASS_DEPTH_PASS
            GL_STENCIL_REF
            GL_STENCIL_VALUE_MASK
            GL_STENCIL_WRITEMASK
            GL_STENCIL_BACK_FUNC
            GL_STENCIL_BACK_FAIL
            GL_STENCIL_BACK_PASS_DEPTH_FAIL
            GL_STENCIL_BACK_PASS_DEPTH_PASS
            GL_STENCIL_BACK_REF
            GL_STENCIL_BACK_VALUE_MASK
            GL_STENCIL_BACK_WRITEMASK
            GL_VIEWPORT
            GL_SCISSOR_BOX
            ;      GL_SCISSOR_TEST
            GL_COLOR_CLEAR_VALUE
            GL_COLOR_WRITEMASK
            GL_UNPACK_ALIGNMENT
            GL_PACK_ALIGNMENT
            GL_MAX_TEXTURE_SIZE
            GL_MAX_VIEWPORT_DIMS
            GL_SUBPIXEL_BITS
            GL_RED_BITS
            GL_GREEN_BITS
            GL_BLUE_BITS
            GL_ALPHA_BITS
            GL_DEPTH_BITS
            GL_STENCIL_BITS
            GL_POLYGON_OFFSET_UNITS
            ;      GL_POLYGON_OFFSET_FILL
            GL_POLYGON_OFFSET_FACTOR
            GL_TEXTURE_BINDING_2D
            GL_SAMPLE_BUFFERS
            GL_SAMPLES
            GL_SAMPLE_COVERAGE_VALUE
            GL_SAMPLE_COVERAGE_INVERT

            ; GetTextureParameter
            ;      GL_TEXTURE_MAG_FILTER
            ;      GL_TEXTURE_MIN_FILTER
            ;      GL_TEXTURE_WRAP_S
            ;      GL_TEXTURE_WRAP_T

            GL_NUM_COMPRESSED_TEXTURE_FORMATS
            GL_COMPRESSED_TEXTURE_FORMATS

            ; HintMode
            GL_DONT_CARE
            GL_FASTEST
            GL_NICEST

            ; HintTarget
            GL_GENERATE_MIPMAP_HINT

            ; DataType
            GL_BYTE
            GL_UNSIGNED_BYTE
            GL_SHORT
            GL_UNSIGNED_SHORT
            GL_INT
            GL_UNSIGNED_INT
            GL_FLOAT
            GL_FIXED

            ; PixelFormat
            GL_DEPTH_COMPONENT
            GL_ALPHA
            GL_RGB
            GL_RGBA
            GL_LUMINANCE
            GL_LUMINANCE_ALPHA

            ; PixelType
            ;      GL_UNSIGNED_BYTE
            GL_UNSIGNED_SHORT_4_4_4_4
            GL_UNSIGNED_SHORT_5_5_5_1
            GL_UNSIGNED_SHORT_5_6_5

            ; Shaders
            GL_FRAGMENT_SHADER
            GL_VERTEX_SHADER
            GL_MAX_VERTEX_ATTRIBS
            GL_MAX_VERTEX_UNIFORM_VECTORS
            GL_MAX_VARYING_VECTORS
            GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS
            GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS
            GL_MAX_TEXTURE_IMAGE_UNITS
            GL_MAX_FRAGMENT_UNIFORM_VECTORS
            GL_SHADER_TYPE
            GL_DELETE_STATUS
            GL_LINK_STATUS
            GL_VALIDATE_STATUS
            GL_ATTACHED_SHADERS
            GL_ACTIVE_UNIFORMS
            GL_ACTIVE_UNIFORM_MAX_LENGTH
            GL_ACTIVE_ATTRIBUTES
            GL_ACTIVE_ATTRIBUTE_MAX_LENGTH
            GL_SHADING_LANGUAGE_VERSION
            GL_CURRENT_PROGRAM

            ; StencilFunction
            GL_NEVER
            GL_LESS
            GL_EQUAL
            GL_LEQUAL
            GL_GREATER
            GL_NOTEQUAL
            GL_GEQUAL
            GL_ALWAYS

            ; StencilOp
            ;      GL_ZERO
            GL_KEEP
            GL_REPLACE
            GL_INCR
            GL_DECR
            GL_INVERT
            GL_INCR_WRAP
            GL_DECR_WRAP

            ; StringName
            GL_VENDOR
            GL_RENDERER
            GL_VERSION
            GL_EXTENSIONS

            ; TextureMagFilter
            GL_NEAREST
            GL_LINEAR

            ; TextureMinFilter
            ;      GL_NEAREST
            ;      GL_LINEAR
            GL_NEAREST_MIPMAP_NEAREST
            GL_LINEAR_MIPMAP_NEAREST
            GL_NEAREST_MIPMAP_LINEAR
            GL_LINEAR_MIPMAP_LINEAR

            ; TextureParameterName
            GL_TEXTURE_MAG_FILTER
            GL_TEXTURE_MIN_FILTER
            GL_TEXTURE_WRAP_S
            GL_TEXTURE_WRAP_T

            ; TextureTarget
            ;      GL_TEXTURE_2D
            GL_TEXTURE

            GL_TEXTURE_CUBE_MAP
            GL_TEXTURE_BINDING_CUBE_MAP
            GL_TEXTURE_CUBE_MAP_POSITIVE_X
            GL_TEXTURE_CUBE_MAP_NEGATIVE_X
            GL_TEXTURE_CUBE_MAP_POSITIVE_Y
            GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
            GL_TEXTURE_CUBE_MAP_POSITIVE_Z
            GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
            GL_MAX_CUBE_MAP_TEXTURE_SIZE

            ; TextureUnit
            GL_TEXTURE0
            GL_TEXTURE1
            GL_TEXTURE2
            GL_TEXTURE3
            GL_TEXTURE4
            GL_TEXTURE5
            GL_TEXTURE6
            GL_TEXTURE7
            GL_TEXTURE8
            GL_TEXTURE9
            GL_TEXTURE10
            GL_TEXTURE11
            GL_TEXTURE12
            GL_TEXTURE13
            GL_TEXTURE14
            GL_TEXTURE15
            GL_TEXTURE16
            GL_TEXTURE17
            GL_TEXTURE18
            GL_TEXTURE19
            GL_TEXTURE20
            GL_TEXTURE21
            GL_TEXTURE22
            GL_TEXTURE23
            GL_TEXTURE24
            GL_TEXTURE25
            GL_TEXTURE26
            GL_TEXTURE27
            GL_TEXTURE28
            GL_TEXTURE29
            GL_TEXTURE30
            GL_TEXTURE31
            GL_ACTIVE_TEXTURE

            ; TextureWrapMode
            GL_REPEAT
            GL_CLAMP_TO_EDGE
            GL_MIRRORED_REPEAT

            ; Uniform Types
            GL_FLOAT_VEC2
            GL_FLOAT_VEC3
            GL_FLOAT_VEC4
            GL_INT_VEC2
            GL_INT_VEC3
            GL_INT_VEC4
            GL_BOOL
            GL_BOOL_VEC2
            GL_BOOL_VEC3
            GL_BOOL_VEC4
            GL_FLOAT_MAT2
            GL_FLOAT_MAT3
            GL_FLOAT_MAT4
            GL_SAMPLER_2D
            GL_SAMPLER_CUBE

            ; Vertex Arrays
            GL_VERTEX_ATTRIB_ARRAY_ENABLED
            GL_VERTEX_ATTRIB_ARRAY_SIZE
            GL_VERTEX_ATTRIB_ARRAY_STRIDE
            GL_VERTEX_ATTRIB_ARRAY_TYPE
            GL_VERTEX_ATTRIB_ARRAY_NORMALIZED
            GL_VERTEX_ATTRIB_ARRAY_POINTER
            GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING

            ; Read Format
            GL_IMPLEMENTATION_COLOR_READ_TYPE
            GL_IMPLEMENTATION_COLOR_READ_FORMAT

            ; Shader Source
            GL_COMPILE_STATUS
            GL_INFO_LOG_LENGTH
            GL_SHADER_SOURCE_LENGTH
            GL_SHADER_COMPILER

            ; Shader Binary
            GL_SHADER_BINARY_FORMATS
            GL_NUM_SHADER_BINARY_FORMATS

            ; Shader Precision-Specified Types
            GL_LOW_FLOAT
            GL_MEDIUM_FLOAT
            GL_HIGH_FLOAT
            GL_LOW_INT
            GL_MEDIUM_INT
            GL_HIGH_INT

            ; Framebuffer Object.
            GL_FRAMEBUFFER
            GL_RENDERBUFFER

            GL_RGBA4
            GL_RGB5_A1
            GL_RGB565
            GL_DEPTH_COMPONENT16
            GL_STENCIL_INDEX
            GL_STENCIL_INDEX8

            GL_RENDERBUFFER_WIDTH
            GL_RENDERBUFFER_HEIGHT
            GL_RENDERBUFFER_INTERNAL_FORMAT
            GL_RENDERBUFFER_RED_SIZE
            GL_RENDERBUFFER_GREEN_SIZE
            GL_RENDERBUFFER_BLUE_SIZE
            GL_RENDERBUFFER_ALPHA_SIZE
            GL_RENDERBUFFER_DEPTH_SIZE
            GL_RENDERBUFFER_STENCIL_SIZE

            GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE
            GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME
            GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL
            GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE

            GL_COLOR_ATTACHMENT0
            GL_DEPTH_ATTACHMENT
            GL_STENCIL_ATTACHMENT

            GL_NONE

            GL_FRAMEBUFFER_COMPLETE
            GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
            GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
            GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS
            GL_FRAMEBUFFER_UNSUPPORTED

            GL_FRAMEBUFFER_BINDING
            GL_RENDERBUFFER_BINDING
            GL_MAX_RENDERBUFFER_SIZE

            GL_INVALID_FRAMEBUFFER_OPERATION


            ;;function begin
            /*-------------------------------------------------------------------------
             * GL core functions.
             *-----------------------------------------------------------------------*/

            glActiveTexture
            glAttachShader
            glBindAttribLocation
            glBindBuffer
            glBindFramebuffer
            glBindRenderbuffer
            glBindTexture
            glBlendColor
            glBlendEquation
            glBlendEquationSeparate
            glBlendFunc
            glBlendFuncSeparate
            glBufferData
            glBufferSubData
            glCheckFramebufferStatus
            glClear
            glClearColor
            glClearDepthf
            glClearStencil
            glColorMask
            glCompileShader
            glCompressedTexImage2D
            glCompressedTexSubImage2D
            glCopyTexImage2D
            glCopyTexSubImage2D
            glCreateProgram
            glCreateShader
            glCullFace
            glDeleteBuffers
            glDeleteFramebuffers
            glDeleteProgram
            glDeleteRenderbuffers
            glDeleteShader
            glDeleteTextures
            glDepthFunc
            glDepthMask
            glDepthRangef
            glDetachShader
            glDisable
            glDisableVertexAttribArray
            glDrawArrays
            glDrawElements
            glEnable
            glEnableVertexAttribArray
            glFinish
            glFlush
            glFramebufferRenderbuffer
            glFramebufferTexture2D
            glFrontFace
            glGenBuffers
            glGenerateMipmap
            glGenFramebuffers
            glGenRenderbuffers
            glGenTextures
            glGetActiveAttrib
            glGetActiveUniform
            glGetAttachedShaders
            glGetAttribLocation
            glGetBooleanv
            glGetBufferParameteriv
            glGetError
            glGetFloatv
            glGetFramebufferAttachmentParameteriv
            glGetIntegerv
            glGetProgramiv
            glGetProgramInfoLog
            glGetRenderbufferParameteriv
            glGetShaderiv
            glGetShaderInfoLog
            glGetShaderPrecisionFormat
            glGetShaderSource
            glGetString
            glGetTexParameterfv
            glGetTexParameteriv
            glGetUniformfv
            glGetUniformiv
            glGetUniformLocation
            glGetVertexAttribfv
            glGetVertexAttribiv
            glGetVertexAttribPointerv
            glHint
            glIsBuffer
            glIsEnabled
            glIsFramebuffer
            glIsProgram
            glIsRenderbuffer
            glIsShader
            glIsTexture
            glLineWidth
            glLinkProgram
            glPixelStorei
            glPolygonOffset
            glReadPixels
            glReleaseShaderCompiler
            glRenderbufferStorage
            glSampleCoverage
            glScissor
            glShaderBinary
            glShaderSource
            glStencilFunc
            glStencilFuncSeparate
            glStencilMask
            glStencilMaskSeparate
            glStencilOp
            glStencilOpSeparate
            glTexImage2D
            glTexParameterf
            glTexParameterfv
            glTexParameteri
            glTexParameteriv
            glTexSubImage2D
            glUniform1f
            glUniform1fv
            glUniform1i
            glUniform1iv
            glUniform2f
            glUniform2fv
            glUniform2i
            glUniform2iv
            glUniform3f
            glUniform3fv
            glUniform3i
            glUniform3iv
            glUniform4f
            glUniform4fv
            glUniform4i
            glUniform4iv
            glUniformMatrix2fv
            glUniformMatrix3fv
            glUniformMatrix4fv
            glUseProgram
            glValidateProgram
            glVertexAttrib1f
            glVertexAttrib1fv
            glVertexAttrib2f
            glVertexAttrib2fv
            glVertexAttrib3f
            glVertexAttrib3fv
            glVertexAttrib4f
            glVertexAttrib4fv
            glVertexAttribPointer
            glViewport


         )
        (import  (scheme) (utils libutil))


         (define lib-name
           (case (machine-type)
             ((arm32le) "libglut.so")
             ((a6nt i3nt)  "libglut.dll")
             ((a6osx i3osx)  "libglut.so")
             ((a6le i3le) "libglut.so")))

         (define lib (load-lib lib-name))

         ;; (define-syntax define-function
         ;;   (syntax-rules ()
         ;;     ((_ ret name args)
         ;;      (define name (c-function lib lib-name ret __stdcall name args)))))

         (define-syntax define-function
           (syntax-rules ()
             ((_ ret name args)
              (define name
                (foreign-procedure (string-append "_" (symbol->string 'name) ) args ret)))))

        (define GL_ES_VERSION_2_0                 1)

        ; ClearBufferMask 
        (define GL_DEPTH_BUFFER_BIT               #x00000100)
        (define GL_STENCIL_BUFFER_BIT             #x00000400)
        (define GL_COLOR_BUFFER_BIT               #x00004000)

        ; Boolean 
        (define GL_FALSE                          0)
        (define GL_TRUE                           1)

        ; BeginMode 
        (define GL_POINTS                         #x0000)
        (define GL_LINES                          #x0001)
        (define GL_LINE_LOOP                      #x0002)
        (define GL_LINE_STRIP                     #x0003)
        (define GL_TRIANGLES                      #x0004)
        (define GL_TRIANGLE_STRIP                 #x0005)
        (define GL_TRIANGLE_FAN                   #x0006)

        ; AlphaFunction (not supported in ES20) 
        ;      GL_NEVER 
        ;      GL_LESS 
        ;      GL_EQUAL 
        ;      GL_LEQUAL 
        ;      GL_GREATER 
        ;      GL_NOTEQUAL 
        ;      GL_GEQUAL 
        ;      GL_ALWAYS 

        ; BlendingFactorDest 
        (define GL_ZERO                           0)
        (define GL_ONE                            1)
        (define GL_SRC_COLOR                      #x0300)
        (define GL_ONE_MINUS_SRC_COLOR            #x0301)
        (define GL_SRC_ALPHA                      #x0302)
        (define GL_ONE_MINUS_SRC_ALPHA            #x0303)
        (define GL_DST_ALPHA                      #x0304)
        (define GL_ONE_MINUS_DST_ALPHA            #x0305)

        ; BlendingFactorSrc 
        ;      GL_ZERO 
        ;      GL_ONE 
        (define GL_DST_COLOR                      #x0306)
        (define GL_ONE_MINUS_DST_COLOR            #x0307)
        (define GL_SRC_ALPHA_SATURATE             #x0308)
        ;      GL_SRC_ALPHA 
        ;      GL_ONE_MINUS_SRC_ALPHA 
        ;      GL_DST_ALPHA 
        ;      GL_ONE_MINUS_DST_ALPHA 

        ; BlendEquationSeparate 
        (define GL_FUNC_ADD                       #x8006)
        (define GL_BLEND_EQUATION                 #x8009)
        (define GL_BLEND_EQUATION_RGB             #x8009)    ; same as BLEND_EQUATION 
        (define GL_BLEND_EQUATION_ALPHA           #x883D)

        ; BlendSubtract 
        (define GL_FUNC_SUBTRACT                  #x800A)
        (define GL_FUNC_REVERSE_SUBTRACT          #x800B)

        ; Separate Blend Functions 
        (define GL_BLEND_DST_RGB                  #x80C8)
        (define GL_BLEND_SRC_RGB                  #x80C9)
        (define GL_BLEND_DST_ALPHA                #x80CA)
        (define GL_BLEND_SRC_ALPHA                #x80CB)
        (define GL_CONSTANT_COLOR                 #x8001)
        (define GL_ONE_MINUS_CONSTANT_COLOR       #x8002)
        (define GL_CONSTANT_ALPHA                 #x8003)
        (define GL_ONE_MINUS_CONSTANT_ALPHA       #x8004)
        (define GL_BLEND_COLOR                    #x8005)

        ; Buffer Objects 
        (define GL_ARRAY_BUFFER                   #x8892)
        (define GL_ELEMENT_ARRAY_BUFFER           #x8893)
        (define GL_ARRAY_BUFFER_BINDING           #x8894)
        (define GL_ELEMENT_ARRAY_BUFFER_BINDING   #x8895)

        (define GL_STREAM_DRAW                    #x88E0)
        (define GL_STATIC_DRAW                    #x88E4)
        (define GL_DYNAMIC_DRAW                   #x88E8)

        (define GL_BUFFER_SIZE                    #x8764)
        (define GL_BUFFER_USAGE                   #x8765)

        (define GL_CURRENT_VERTEX_ATTRIB          #x8626)

        ; CullFaceMode 
        (define GL_FRONT                          #x0404)
        (define GL_BACK                           #x0405)
        (define GL_FRONT_AND_BACK                 #x0408)

        ; DepthFunction 
        ;      GL_NEVER 
        ;      GL_LESS 
        ;      GL_EQUAL 
        ;      GL_LEQUAL 
        ;      GL_GREATER 
        ;      GL_NOTEQUAL 
        ;      GL_GEQUAL 
        ;      GL_ALWAYS 

        ; EnableCap 
        (define GL_TEXTURE_2D                     #x0DE1)
        (define GL_CULL_FACE                      #x0B44)
        (define GL_BLEND                          #x0BE2)
        (define GL_DITHER                         #x0BD0)
        (define GL_STENCIL_TEST                   #x0B90)
        (define GL_DEPTH_TEST                     #x0B71)
        (define GL_SCISSOR_TEST                   #x0C11)
        (define GL_POLYGON_OFFSET_FILL            #x8037)
        (define GL_SAMPLE_ALPHA_TO_COVERAGE       #x809E)
        (define GL_SAMPLE_COVERAGE                #x80A0)

        ; ErrorCode 
        (define GL_NO_ERROR                       0)
        (define GL_INVALID_ENUM                   #x0500)
        (define GL_INVALID_VALUE                  #x0501)
        (define GL_INVALID_OPERATION              #x0502)
        (define GL_OUT_OF_MEMORY                  #x0505)

        ; FrontFaceDirection 
        (define GL_CW                             #x0900)
        (define GL_CCW                            #x0901)

        ; GetPName 
        (define GL_LINE_WIDTH                     #x0B21)
        (define GL_ALIASED_POINT_SIZE_RANGE       #x846D)
        (define GL_ALIASED_LINE_WIDTH_RANGE       #x846E)
        (define GL_CULL_FACE_MODE                 #x0B45)
        (define GL_FRONT_FACE                     #x0B46)
        (define GL_DEPTH_RANGE                    #x0B70)
        (define GL_DEPTH_WRITEMASK                #x0B72)
        (define GL_DEPTH_CLEAR_VALUE              #x0B73)
        (define GL_DEPTH_FUNC                     #x0B74)
        (define GL_STENCIL_CLEAR_VALUE            #x0B91)
        (define GL_STENCIL_FUNC                   #x0B92)
        (define GL_STENCIL_FAIL                   #x0B94)
        (define GL_STENCIL_PASS_DEPTH_FAIL        #x0B95)
        (define GL_STENCIL_PASS_DEPTH_PASS        #x0B96)
        (define GL_STENCIL_REF                    #x0B97)
        (define GL_STENCIL_VALUE_MASK             #x0B93)
        (define GL_STENCIL_WRITEMASK              #x0B98)
        (define GL_STENCIL_BACK_FUNC              #x8800)
        (define GL_STENCIL_BACK_FAIL              #x8801)
        (define GL_STENCIL_BACK_PASS_DEPTH_FAIL   #x8802)
        (define GL_STENCIL_BACK_PASS_DEPTH_PASS   #x8803)
        (define GL_STENCIL_BACK_REF               #x8CA3)
        (define GL_STENCIL_BACK_VALUE_MASK        #x8CA4)
        (define GL_STENCIL_BACK_WRITEMASK         #x8CA5)
        (define GL_VIEWPORT                       #x0BA2)
        (define GL_SCISSOR_BOX                    #x0C10)
        ;      GL_SCISSOR_TEST 
        (define GL_COLOR_CLEAR_VALUE              #x0C22)
        (define GL_COLOR_WRITEMASK                #x0C23)
        (define GL_UNPACK_ALIGNMENT               #x0CF5)
        (define GL_PACK_ALIGNMENT                 #x0D05)
        (define GL_MAX_TEXTURE_SIZE               #x0D33)
        (define GL_MAX_VIEWPORT_DIMS              #x0D3A)
        (define GL_SUBPIXEL_BITS                  #x0D50)
        (define GL_RED_BITS                       #x0D52)
        (define GL_GREEN_BITS                     #x0D53)
        (define GL_BLUE_BITS                      #x0D54)
        (define GL_ALPHA_BITS                     #x0D55)
        (define GL_DEPTH_BITS                     #x0D56)
        (define GL_STENCIL_BITS                   #x0D57)
        (define GL_POLYGON_OFFSET_UNITS           #x2A00)
        ;      GL_POLYGON_OFFSET_FILL 
        (define GL_POLYGON_OFFSET_FACTOR          #x8038)
        (define GL_TEXTURE_BINDING_2D             #x8069)
        (define GL_SAMPLE_BUFFERS                 #x80A8)
        (define GL_SAMPLES                        #x80A9)
        (define GL_SAMPLE_COVERAGE_VALUE          #x80AA)
        (define GL_SAMPLE_COVERAGE_INVERT         #x80AB)

        ; GetTextureParameter 
        ;      GL_TEXTURE_MAG_FILTER 
        ;      GL_TEXTURE_MIN_FILTER 
        ;      GL_TEXTURE_WRAP_S 
        ;      GL_TEXTURE_WRAP_T 

        (define GL_NUM_COMPRESSED_TEXTURE_FORMATS #x86A2)
        (define GL_COMPRESSED_TEXTURE_FORMATS     #x86A3)

        ; HintMode 
        (define GL_DONT_CARE                      #x1100)
        (define GL_FASTEST                        #x1101)
        (define GL_NICEST                         #x1102)

        ; HintTarget 
        (define GL_GENERATE_MIPMAP_HINT            #x8192)

        ; DataType 
        (define GL_BYTE                           #x1400)
        (define GL_UNSIGNED_BYTE                  #x1401)
        (define GL_SHORT                          #x1402)
        (define GL_UNSIGNED_SHORT                 #x1403)
        (define GL_INT                            #x1404)
        (define GL_UNSIGNED_INT                   #x1405)
        (define GL_FLOAT                          #x1406)
        (define GL_FIXED                          #x140C)

        ; PixelFormat 
        (define GL_DEPTH_COMPONENT                #x1902)
        (define GL_ALPHA                          #x1906)
        (define GL_RGB                            #x1907)
        (define GL_RGBA                           #x1908)
        (define GL_LUMINANCE                      #x1909)
        (define GL_LUMINANCE_ALPHA                #x190A)

        ; PixelType 
        ;      GL_UNSIGNED_BYTE 
        (define GL_UNSIGNED_SHORT_4_4_4_4         #x8033)
        (define GL_UNSIGNED_SHORT_5_5_5_1         #x8034)
        (define GL_UNSIGNED_SHORT_5_6_5           #x8363)

        ; Shaders 
        (define GL_FRAGMENT_SHADER                  #x8B30)
        (define GL_VERTEX_SHADER                    #x8B31)
        (define GL_MAX_VERTEX_ATTRIBS               #x8869)
        (define GL_MAX_VERTEX_UNIFORM_VECTORS       #x8DFB)
        (define GL_MAX_VARYING_VECTORS              #x8DFC)
        (define GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS #x8B4D)
        (define GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS   #x8B4C)
        (define GL_MAX_TEXTURE_IMAGE_UNITS          #x8872)
        (define GL_MAX_FRAGMENT_UNIFORM_VECTORS     #x8DFD)
        (define GL_SHADER_TYPE                      #x8B4F)
        (define GL_DELETE_STATUS                    #x8B80)
        (define GL_LINK_STATUS                      #x8B82)
        (define GL_VALIDATE_STATUS                  #x8B83)
        (define GL_ATTACHED_SHADERS                 #x8B85)
        (define GL_ACTIVE_UNIFORMS                  #x8B86)
        (define GL_ACTIVE_UNIFORM_MAX_LENGTH        #x8B87)
        (define GL_ACTIVE_ATTRIBUTES                #x8B89)
        (define GL_ACTIVE_ATTRIBUTE_MAX_LENGTH      #x8B8A)
        (define GL_SHADING_LANGUAGE_VERSION         #x8B8C)
        (define GL_CURRENT_PROGRAM                  #x8B8D)

        ; StencilFunction 
        (define GL_NEVER                          #x0200)
        (define GL_LESS                           #x0201)
        (define GL_EQUAL                          #x0202)
        (define GL_LEQUAL                         #x0203)
        (define GL_GREATER                        #x0204)
        (define GL_NOTEQUAL                       #x0205)
        (define GL_GEQUAL                         #x0206)
        (define GL_ALWAYS                         #x0207)

        ; StencilOp 
        ;      GL_ZERO 
        (define GL_KEEP                           #x1E00)
        (define GL_REPLACE                        #x1E01)
        (define GL_INCR                           #x1E02)
        (define GL_DECR                           #x1E03)
        (define GL_INVERT                         #x150A)
        (define GL_INCR_WRAP                      #x8507)
        (define GL_DECR_WRAP                      #x8508)

        ; StringName 
        (define GL_VENDOR                         #x1F00)
        (define GL_RENDERER                       #x1F01)
        (define GL_VERSION                        #x1F02)
        (define GL_EXTENSIONS                     #x1F03)

        ; TextureMagFilter 
        (define GL_NEAREST                        #x2600)
        (define GL_LINEAR                         #x2601)

        ; TextureMinFilter 
        ;      GL_NEAREST 
        ;      GL_LINEAR 
        (define GL_NEAREST_MIPMAP_NEAREST         #x2700)
        (define GL_LINEAR_MIPMAP_NEAREST          #x2701)
        (define GL_NEAREST_MIPMAP_LINEAR          #x2702)
        (define GL_LINEAR_MIPMAP_LINEAR           #x2703)

        ; TextureParameterName 
        (define GL_TEXTURE_MAG_FILTER             #x2800)
        (define GL_TEXTURE_MIN_FILTER             #x2801)
        (define GL_TEXTURE_WRAP_S                 #x2802)
        (define GL_TEXTURE_WRAP_T                 #x2803)

        ; TextureTarget 
        ;      GL_TEXTURE_2D 
        (define GL_TEXTURE                        #x1702)

        (define GL_TEXTURE_CUBE_MAP               #x8513)
        (define GL_TEXTURE_BINDING_CUBE_MAP       #x8514)
        (define GL_TEXTURE_CUBE_MAP_POSITIVE_X    #x8515)
        (define GL_TEXTURE_CUBE_MAP_NEGATIVE_X    #x8516)
        (define GL_TEXTURE_CUBE_MAP_POSITIVE_Y    #x8517)
        (define GL_TEXTURE_CUBE_MAP_NEGATIVE_Y    #x8518)
        (define GL_TEXTURE_CUBE_MAP_POSITIVE_Z    #x8519)
        (define GL_TEXTURE_CUBE_MAP_NEGATIVE_Z    #x851A)
        (define GL_MAX_CUBE_MAP_TEXTURE_SIZE      #x851C)

        ; TextureUnit 
        (define GL_TEXTURE0                       #x84C0)
        (define GL_TEXTURE1                       #x84C1)
        (define GL_TEXTURE2                       #x84C2)
        (define GL_TEXTURE3                       #x84C3)
        (define GL_TEXTURE4                       #x84C4)
        (define GL_TEXTURE5                       #x84C5)
        (define GL_TEXTURE6                       #x84C6)
        (define GL_TEXTURE7                       #x84C7)
        (define GL_TEXTURE8                       #x84C8)
        (define GL_TEXTURE9                       #x84C9)
        (define GL_TEXTURE10                      #x84CA)
        (define GL_TEXTURE11                      #x84CB)
        (define GL_TEXTURE12                      #x84CC)
        (define GL_TEXTURE13                      #x84CD)
        (define GL_TEXTURE14                      #x84CE)
        (define GL_TEXTURE15                      #x84CF)
        (define GL_TEXTURE16                      #x84D0)
        (define GL_TEXTURE17                      #x84D1)
        (define GL_TEXTURE18                      #x84D2)
        (define GL_TEXTURE19                      #x84D3)
        (define GL_TEXTURE20                      #x84D4)
        (define GL_TEXTURE21                      #x84D5)
        (define GL_TEXTURE22                      #x84D6)
        (define GL_TEXTURE23                      #x84D7)
        (define GL_TEXTURE24                      #x84D8)
        (define GL_TEXTURE25                      #x84D9)
        (define GL_TEXTURE26                      #x84DA)
        (define GL_TEXTURE27                      #x84DB)
        (define GL_TEXTURE28                      #x84DC)
        (define GL_TEXTURE29                      #x84DD)
        (define GL_TEXTURE30                      #x84DE)
        (define GL_TEXTURE31                      #x84DF)
        (define GL_ACTIVE_TEXTURE                 #x84E0)

        ; TextureWrapMode 
        (define GL_REPEAT                         #x2901)
        (define GL_CLAMP_TO_EDGE                  #x812F)
        (define GL_MIRRORED_REPEAT                #x8370)

        ; Uniform Types 
        (define GL_FLOAT_VEC2                     #x8B50)
        (define GL_FLOAT_VEC3                     #x8B51)
        (define GL_FLOAT_VEC4                     #x8B52)
        (define GL_INT_VEC2                       #x8B53)
        (define GL_INT_VEC3                       #x8B54)
        (define GL_INT_VEC4                       #x8B55)
        (define GL_BOOL                           #x8B56)
        (define GL_BOOL_VEC2                      #x8B57)
        (define GL_BOOL_VEC3                      #x8B58)
        (define GL_BOOL_VEC4                      #x8B59)
        (define GL_FLOAT_MAT2                     #x8B5A)
        (define GL_FLOAT_MAT3                     #x8B5B)
        (define GL_FLOAT_MAT4                     #x8B5C)
        (define GL_SAMPLER_2D                     #x8B5E)
        (define GL_SAMPLER_CUBE                   #x8B60)

        ; Vertex Arrays 
        (define GL_VERTEX_ATTRIB_ARRAY_ENABLED        #x8622)
        (define GL_VERTEX_ATTRIB_ARRAY_SIZE           #x8623)
        (define GL_VERTEX_ATTRIB_ARRAY_STRIDE         #x8624)
        (define GL_VERTEX_ATTRIB_ARRAY_TYPE           #x8625)
        (define GL_VERTEX_ATTRIB_ARRAY_NORMALIZED     #x886A)
        (define GL_VERTEX_ATTRIB_ARRAY_POINTER        #x8645)
        (define GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING #x889F)

        ; Read Format 
        (define GL_IMPLEMENTATION_COLOR_READ_TYPE   #x8B9A)
        (define GL_IMPLEMENTATION_COLOR_READ_FORMAT #x8B9B)

        ; Shader Source 
        (define GL_COMPILE_STATUS                 #x8B81)
        (define GL_INFO_LOG_LENGTH                #x8B84)
        (define GL_SHADER_SOURCE_LENGTH           #x8B88)
        (define GL_SHADER_COMPILER                #x8DFA)

        ; Shader Binary 
        (define GL_SHADER_BINARY_FORMATS          #x8DF8)
        (define GL_NUM_SHADER_BINARY_FORMATS      #x8DF9)

        ; Shader Precision-Specified Types 
        (define GL_LOW_FLOAT                      #x8DF0)
        (define GL_MEDIUM_FLOAT                   #x8DF1)
        (define GL_HIGH_FLOAT                     #x8DF2)
        (define GL_LOW_INT                        #x8DF3)
        (define GL_MEDIUM_INT                     #x8DF4)
        (define GL_HIGH_INT                       #x8DF5)

        ; Framebuffer Object. 
        (define GL_FRAMEBUFFER                    #x8D40)
        (define GL_RENDERBUFFER                   #x8D41)

        (define GL_RGBA4                          #x8056)
        (define GL_RGB5_A1                        #x8057)
        (define GL_RGB565                         #x8D62)
        (define GL_DEPTH_COMPONENT16              #x81A5)
        (define GL_STENCIL_INDEX                  #x1901)
        (define GL_STENCIL_INDEX8                 #x8D48)

        (define GL_RENDERBUFFER_WIDTH             #x8D42)
        (define GL_RENDERBUFFER_HEIGHT            #x8D43)
        (define GL_RENDERBUFFER_INTERNAL_FORMAT   #x8D44)
        (define GL_RENDERBUFFER_RED_SIZE          #x8D50)
        (define GL_RENDERBUFFER_GREEN_SIZE        #x8D51)
        (define GL_RENDERBUFFER_BLUE_SIZE         #x8D52)
        (define GL_RENDERBUFFER_ALPHA_SIZE        #x8D53)
        (define GL_RENDERBUFFER_DEPTH_SIZE        #x8D54)
        (define GL_RENDERBUFFER_STENCIL_SIZE      #x8D55)

        (define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE           #x8CD0)
        (define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME           #x8CD1)
        (define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL         #x8CD2)
        (define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE #x8CD3)

        (define GL_COLOR_ATTACHMENT0              #x8CE0)
        (define GL_DEPTH_ATTACHMENT               #x8D00)
        (define GL_STENCIL_ATTACHMENT             #x8D20)

        (define GL_NONE                           0)

        (define GL_FRAMEBUFFER_COMPLETE                      #x8CD5)
        (define GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT         #x8CD6)
        (define GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT #x8CD7)
        (define GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS         #x8CD9)
        (define GL_FRAMEBUFFER_UNSUPPORTED                   #x8CDD)

        (define GL_FRAMEBUFFER_BINDING            #x8CA6)
        (define GL_RENDERBUFFER_BINDING           #x8CA7)
        (define GL_MAX_RENDERBUFFER_SIZE          #x84E8)

        (define GL_INVALID_FRAMEBUFFER_OPERATION  #x0506)


        /*-------------------------------------------------------------------------
                 * GL core functions.
                 *-----------------------------------------------------------------------*/

                (define-function void         glActiveTexture (int))
                (define-function void         glAttachShader (int  int))
                (define-function void         glBindAttribLocation (int  int  string))
                (define-function void         glBindBuffer (int  int))
                (define-function void         glBindFramebuffer (int  int))
                (define-function void         glBindRenderbuffer (int  int))
                (define-function void         glBindTexture (int  int))
                (define-function void         glBlendColor (float  float  float  float))
                (define-function void         glBlendEquation ( int ))
                (define-function void         glBlendEquationSeparate (int  int))
                (define-function void         glBlendFunc (int  int))
                (define-function void         glBlendFuncSeparate (int  int  int  int))
                (define-function void         glBufferData (int  int   void*  int))
                (define-function void         glBufferSubData (int  int  int   void*))
                (define-function int      glCheckFramebufferStatus (int))
                (define-function void         glClear (int))
                (define-function void         glClearColor (float  float  float  float))
                (define-function void         glClearDepthf (float))
                (define-function void         glClearStencil (int))
                (define-function void         glColorMask (int  int  int  int))
                (define-function void         glCompileShader (int))
                (define-function void         glCompressedTexImage2D (int  int  int  int  int  int  int   void*))
                (define-function void         glCompressedTexSubImage2D (int  int  int  int  int  int  int  int   void*))
                (define-function void         glCopyTexImage2D (int  int  int  int  int  int  int  int))
                (define-function void         glCopyTexSubImage2D (int  int  int  int  int  int  int  int))
                (define-function int      glCreateProgram (void))
                (define-function int      glCreateShader (int))
                (define-function void         glCullFace (int))
                (define-function void         glDeleteBuffers (int   void*))
                (define-function void         glDeleteFramebuffers (int   void*))
                (define-function void         glDeleteProgram (int))
                (define-function void         glDeleteRenderbuffers (int   void*))
                (define-function void         glDeleteShader (int))
                (define-function void         glDeleteTextures (int   void*))
                (define-function void         glDepthFunc (int))
                (define-function void         glDepthMask (int))
                (define-function void         glDepthRangef (float  float))
                (define-function void         glDetachShader (int  int))
                (define-function void         glDisable (int))
                (define-function void         glDisableVertexAttribArray (int))
                (define-function void         glDrawArrays (int  int  int))
                (define-function void         glDrawElements (int  int  int   void*))
                (define-function void         glEnable (int))
                (define-function void         glEnableVertexAttribArray (int))
                (define-function void         glFinish (void))
                (define-function void         glFlush (void))
                (define-function void         glFramebufferRenderbuffer (int  int  int  int))
                (define-function void         glFramebufferTexture2D (int  int  int  int  int))
                (define-function void         glFrontFace (int))
                (define-function void         glGenBuffers (int   void*))
                (define-function void         glGenerateMipmap (int))
                (define-function void         glGenFramebuffers (int   void*))
                (define-function void         glGenRenderbuffers (int   void*))
                (define-function void         glGenTextures (int   void*))
                (define-function void         glGetActiveAttrib (int  int  int   void*   void*   void*  string))
                (define-function void         glGetActiveUniform (int  int  int   void*   void*   void*  string))
                (define-function void         glGetAttachedShaders (int  int   void*   void*))
                (define-function int       glGetAttribLocation (int  string))
                (define-function void         glGetBooleanv (int   void*))
                (define-function void         glGetBufferParameteriv (int  int   void*))
                (define-function int      glGetError (void))
                (define-function void         glGetFloatv (int   void*))
                (define-function void         glGetFramebufferAttachmentParameteriv (int  int  int   void*))
                (define-function void         glGetIntegerv (int   void*))
                (define-function void         glGetProgramiv (int  int   void*))
                (define-function void         glGetProgramInfoLog (int  int   void*  string))
                (define-function void         glGetRenderbufferParameteriv (int  int   void*))
                (define-function void         glGetShaderiv (int  int   void*))
                (define-function void         glGetShaderInfoLog (int  int   void*  string))
                (define-function void         glGetShaderPrecisionFormat (int  int   void*   void*))
                (define-function void         glGetShaderSource (int  int   void*  string))
                (define-function  void* glGetString (int))
                (define-function void         glGetTexParameterfv (int  int   void*))
                (define-function void         glGetTexParameteriv (int  int   void*))
                (define-function void         glGetUniformfv (int  int   void*))
                (define-function void         glGetUniformiv (int  int   void*))
                (define-function int       glGetUniformLocation (int  string))
                (define-function void         glGetVertexAttribfv (int  int   void*))
                (define-function void         glGetVertexAttribiv (int  int   void*))
                (define-function void         glGetVertexAttribPointerv (int  int  void** ))
                (define-function void         glHint (int  int))
                (define-function int   glIsBuffer (int))
                (define-function int   glIsEnabled (int))
                (define-function int   glIsFramebuffer (int))
                (define-function int   glIsProgram (int))
                (define-function int   glIsRenderbuffer (int))
                (define-function int   glIsShader (int))
                (define-function int   glIsTexture (int))
                (define-function void         glLineWidth (float))
                (define-function void         glLinkProgram (int))
                (define-function void         glPixelStorei (int  int))
                (define-function void         glPolygonOffset (float  float))
                (define-function void         glReadPixels (int  int  int  int  int  int  void*))
                (define-function void         glReleaseShaderCompiler (void))
                (define-function void         glRenderbufferStorage (int  int  int  int))
                (define-function void         glSampleCoverage (float  int))
                (define-function void         glScissor (int  int  int  int))
                (define-function void         glShaderBinary (int   void*  int   void*  int))
                (define-function void         glShaderSource (int  int  void**   void*))
                (define-function void         glStencilFunc (int  int  int))
                (define-function void         glStencilFuncSeparate (int  int  int  int))
                (define-function void         glStencilMask (int))
                (define-function void         glStencilMaskSeparate (int  int))
                (define-function void         glStencilOp (int  int  int))
                (define-function void         glStencilOpSeparate (int  int  int  int))
                (define-function void         glTexImage2D (int  int  int  int  int  int  int  int   void*))
                (define-function void         glTexParameterf (int  int  float))
                (define-function void         glTexParameterfv (int  int   void*))
                (define-function void         glTexParameteri (int  int  int))
                (define-function void         glTexParameteriv (int  int   void*))
                (define-function void         glTexSubImage2D (int  int  int  int  int  int  int  int   void*))
                (define-function void         glUniform1f (int  float))
                (define-function void         glUniform1fv (int  int   void*))
                (define-function void         glUniform1i (int  int))
                (define-function void         glUniform1iv (int  int   void*))
                (define-function void         glUniform2f (int  float  float))
                (define-function void         glUniform2fv (int  int   void*))
                (define-function void         glUniform2i (int  int  int))
                (define-function void         glUniform2iv (int  int   void*))
                (define-function void         glUniform3f (int  float  float  float))
                (define-function void         glUniform3fv (int  int   void*))
                (define-function void         glUniform3i (int  int  int  int))
                (define-function void         glUniform3iv (int  int   void*))
                (define-function void         glUniform4f (int  float  float  float  float))
                (define-function void         glUniform4fv (int  int   void*))
                (define-function void         glUniform4i (int  int  int  int  int))
                (define-function void         glUniform4iv (int  int   void*))
                (define-function void         glUniformMatrix2fv (int  int  int   void*))
                (define-function void         glUniformMatrix3fv (int  int  int   void*))
                (define-function void         glUniformMatrix4fv (int  int  int   void*))
                (define-function void         glUseProgram (int))
                (define-function void         glValidateProgram (int))
                (define-function void         glVertexAttrib1f (int  float))
                (define-function void         glVertexAttrib1fv (int   void*))
                (define-function void         glVertexAttrib2f (int  float  float))
                (define-function void         glVertexAttrib2fv (int   void*))
                (define-function void         glVertexAttrib3f (int  float  float  float))
                (define-function void         glVertexAttrib3fv (int   void*))
                (define-function void         glVertexAttrib4f (int  float  float  float  float))
                (define-function void         glVertexAttrib4fv (int   void*))
                (define-function void         glVertexAttribPointer (int  int  int  int  int   void*))
                (define-function void         glViewport (int  int  int  int))

)