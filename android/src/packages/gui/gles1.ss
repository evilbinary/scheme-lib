;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gles1)
         (export
          
          ;; OpenGL ES core versions 
          GL_VERSION_ES_CM_1_0              
          GL_VERSION_ES_CL_1_0              
          GL_VERSION_ES_CM_1_1              
          GL_VERSION_ES_CL_1_1              
          
          ;; Legacy core versions 
          GL_OES_VERSION_1_0                
          GL_OES_VERSION_1_1                
          
          ;; Extensions 
          GL_OES_byte_coordinates           
          GL_OES_compressed_paletted_texture 
          GL_OES_draw_texture               
          GL_OES_fixed_point                
          GL_OES_matrix_get                 
          GL_OES_matrix_palette             
          GL_OES_point_size_array           
          GL_OES_point_sprite               
          GL_OES_read_format                
          GL_OES_single_precision           
          
          ;; ClearBufferMask 
          GL_DEPTH_BUFFER_BIT               
          GL_STENCIL_BUFFER_BIT             
          GL_COLOR_BUFFER_BIT               
          
          ;; Boolean 
          GL_FALSE                          
          GL_TRUE                           
          
          ;; BeginMode 
          GL_POINTS                         
          GL_LINES                          
          GL_LINE_LOOP                      
          GL_LINE_STRIP                     
          GL_TRIANGLES                      
          GL_TRIANGLE_STRIP                 
          GL_TRIANGLE_FAN                   
          
          ;; AlphaFunction 
          GL_NEVER                          
          GL_LESS                           
          GL_EQUAL                          
          GL_LEQUAL                         
          GL_GREATER                        
          GL_NOTEQUAL                       
          GL_GEQUAL                         
          GL_ALWAYS                         
          
          ;; BlendingFactorDest 
          GL_ZERO                           
          GL_ONE                            
          GL_SRC_COLOR                      
          GL_ONE_MINUS_SRC_COLOR            
          GL_SRC_ALPHA                      
          GL_ONE_MINUS_SRC_ALPHA            
          GL_DST_ALPHA                      
          GL_ONE_MINUS_DST_ALPHA            
          
          ;; BlendingFactorSrc 
          ;;      GL_ZERO 
          ;;      GL_ONE 
          GL_DST_COLOR                      
          GL_ONE_MINUS_DST_COLOR            
          GL_SRC_ALPHA_SATURATE             
          ;;      GL_SRC_ALPHA 
          ;;      GL_ONE_MINUS_SRC_ALPHA 
          ;;      GL_DST_ALPHA 
          ;;      GL_ONE_MINUS_DST_ALPHA 
          
          ;; ClipPlaneName 
          GL_CLIP_PLANE0                    
          GL_CLIP_PLANE1                    
          GL_CLIP_PLANE2                    
          GL_CLIP_PLANE3                    
          GL_CLIP_PLANE4                    
          GL_CLIP_PLANE5                    
          
          ;; ColorMaterialFace 
          ;;      GL_FRONT_AND_BACK 
          
          ;; ColorMaterialParameter 
          ;;      GL_AMBIENT_AND_DIFFUSE 
          
          ;; ColorPointerType 
          ;;      GL_UNSIGNED_BYTE 
          ;;      GL_FLOAT 
          ;;      GL_FIXED 
          
          ;; CullFaceMode 
          GL_FRONT                          
          GL_BACK                           
          GL_FRONT_AND_BACK                 
          
          ;; DepthFunction 
          ;;      GL_NEVER 
          ;;      GL_LESS 
          ;;      GL_EQUAL 
          ;;      GL_LEQUAL 
          ;;      GL_GREATER 
          ;;      GL_NOTEQUAL 
          ;;      GL_GEQUAL 
          ;;      GL_ALWAYS 
          
          ;; EnableCap 
          GL_FOG                            
          GL_LIGHTING                       
          GL_TEXTURE_2D                     
          GL_CULL_FACE                      
          GL_ALPHA_TEST                     
          GL_BLEND                          
          GL_COLOR_LOGIC_OP                 
          GL_DITHER                         
          GL_STENCIL_TEST                   
          GL_DEPTH_TEST                     
          ;;      GL_LIGHT0 
          ;;      GL_LIGHT1 
          ;;      GL_LIGHT2 
          ;;      GL_LIGHT3 
          ;;      GL_LIGHT4 
          ;;      GL_LIGHT5 
          ;;      GL_LIGHT6 
          ;;      GL_LIGHT7 
          GL_POINT_SMOOTH                   
          GL_LINE_SMOOTH                    
          
          GL_COLOR_MATERIAL                 
          GL_NORMALIZE                      
          GL_RESCALE_NORMAL                         
          GL_VERTEX_ARRAY                   
          GL_NORMAL_ARRAY                   
          GL_COLOR_ARRAY                    
          GL_TEXTURE_COORD_ARRAY            
          GL_MULTISAMPLE                    
          GL_SAMPLE_ALPHA_TO_COVERAGE       
          GL_SAMPLE_ALPHA_TO_ONE            
          GL_SAMPLE_COVERAGE                
          
          ;; ErrorCode 
          GL_NO_ERROR                       
          GL_INVALID_ENUM                   
          GL_INVALID_VALUE                  
          GL_INVALID_OPERATION              
          GL_STACK_OVERFLOW                 
          GL_STACK_UNDERFLOW                
          GL_OUT_OF_MEMORY                  
          
          ;; FogMode 
          ;;      GL_LINEAR 
          GL_EXP                            
          GL_EXP2                           
          
          ;; FogParameter 
          GL_FOG_DENSITY                    
          GL_FOG_START                      
          GL_FOG_END                        
          GL_FOG_MODE                       
          GL_FOG_COLOR                      
          
          ;; FrontFaceDirection 
          GL_CW                             
          GL_CCW                            
          
          ;; GetPName 
          GL_CURRENT_COLOR                  
          GL_CURRENT_NORMAL                 
          GL_CURRENT_TEXTURE_COORDS         
          GL_POINT_SIZE                     
          GL_POINT_SIZE_MIN                 
          GL_POINT_SIZE_MAX                 
          GL_POINT_FADE_THRESHOLD_SIZE      
          GL_POINT_DISTANCE_ATTENUATION     
          GL_SMOOTH_POINT_SIZE_RANGE        
          GL_LINE_WIDTH                     
          GL_SMOOTH_LINE_WIDTH_RANGE        
          GL_ALIASED_POINT_SIZE_RANGE       
          GL_ALIASED_LINE_WIDTH_RANGE       
          GL_CULL_FACE_MODE                 
          GL_FRONT_FACE                     
          GL_SHADE_MODEL                    
          GL_DEPTH_RANGE                    
          GL_DEPTH_WRITEMASK                
          GL_DEPTH_CLEAR_VALUE              
          GL_DEPTH_FUNC                     
          GL_STENCIL_CLEAR_VALUE            
          GL_STENCIL_FUNC                   
          GL_STENCIL_VALUE_MASK             
          GL_STENCIL_FAIL                   
          GL_STENCIL_PASS_DEPTH_FAIL        
          GL_STENCIL_PASS_DEPTH_PASS        
          GL_STENCIL_REF                    
          GL_STENCIL_WRITEMASK              
          GL_MATRIX_MODE                    
          GL_VIEWPORT                       
          GL_MODELVIEW_STACK_DEPTH          
          GL_PROJECTION_STACK_DEPTH         
          GL_TEXTURE_STACK_DEPTH            
          GL_MODELVIEW_MATRIX               
          GL_PROJECTION_MATRIX              
          GL_TEXTURE_MATRIX                 
          GL_ALPHA_TEST_FUNC                
          GL_ALPHA_TEST_REF                 
          GL_BLEND_DST                      
          GL_BLEND_SRC                      
          GL_LOGIC_OP_MODE                  
          GL_SCISSOR_BOX                    
          GL_SCISSOR_TEST                   
          GL_COLOR_CLEAR_VALUE              
          GL_COLOR_WRITEMASK                
          
          
          GL_MAX_LIGHTS                     
          GL_MAX_CLIP_PLANES                
          GL_MAX_TEXTURE_SIZE               
          GL_MAX_MODELVIEW_STACK_DEPTH      
          GL_MAX_PROJECTION_STACK_DEPTH     
          GL_MAX_TEXTURE_STACK_DEPTH        
          GL_MAX_VIEWPORT_DIMS              
          GL_MAX_TEXTURE_UNITS              
          GL_SUBPIXEL_BITS                  
          GL_RED_BITS                       
          GL_GREEN_BITS                     
          GL_BLUE_BITS                      
          GL_ALPHA_BITS                     
          GL_DEPTH_BITS                     
          GL_STENCIL_BITS                   
          GL_POLYGON_OFFSET_UNITS           
          GL_POLYGON_OFFSET_FILL            
          GL_POLYGON_OFFSET_FACTOR          
          GL_TEXTURE_BINDING_2D             
          GL_VERTEX_ARRAY_SIZE              
          GL_VERTEX_ARRAY_TYPE              
          GL_VERTEX_ARRAY_STRIDE            
          GL_NORMAL_ARRAY_TYPE              
          GL_NORMAL_ARRAY_STRIDE            
          GL_COLOR_ARRAY_SIZE               
          GL_COLOR_ARRAY_TYPE               
          GL_COLOR_ARRAY_STRIDE             
          GL_TEXTURE_COORD_ARRAY_SIZE       
          GL_TEXTURE_COORD_ARRAY_TYPE       
          GL_TEXTURE_COORD_ARRAY_STRIDE     
          GL_VERTEX_ARRAY_POINTER           
          GL_NORMAL_ARRAY_POINTER           
          GL_COLOR_ARRAY_POINTER            
          GL_TEXTURE_COORD_ARRAY_POINTER    
          GL_SAMPLE_BUFFERS                 
          GL_SAMPLES                        
          GL_SAMPLE_COVERAGE_VALUE          
          GL_SAMPLE_COVERAGE_INVERT         
          
          ;; GetTextureParameter 
          ;;      GL_TEXTURE_MAG_FILTER 
          ;;      GL_TEXTURE_MIN_FILTER 
          ;;      GL_TEXTURE_WRAP_S 
          ;;      GL_TEXTURE_WRAP_T 
          
          GL_IMPLEMENTATION_COLOR_READ_TYPE_OES   
          GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES 
          GL_NUM_COMPRESSED_TEXTURE_FORMATS       
          GL_COMPRESSED_TEXTURE_FORMATS           
          
          ;; HintMode 
          GL_DONT_CARE                      
          GL_FASTEST                        
          GL_NICEST                         
          
          ;; HintTarget 
          GL_PERSPECTIVE_CORRECTION_HINT    
          GL_POINT_SMOOTH_HINT              
          GL_LINE_SMOOTH_HINT               
          GL_FOG_HINT                       
          GL_GENERATE_MIPMAP_HINT           
          
          ;; LightModelParameter 
          GL_LIGHT_MODEL_AMBIENT            
          GL_LIGHT_MODEL_TWO_SIDE           
          
          ;; LightParameter 
          GL_AMBIENT                        
          GL_DIFFUSE                        
          GL_SPECULAR                       
          GL_POSITION                       
          GL_SPOT_DIRECTION                 
          GL_SPOT_EXPONENT                  
          GL_SPOT_CUTOFF                    
          GL_CONSTANT_ATTENUATION           
          GL_LINEAR_ATTENUATION             
          GL_QUADRATIC_ATTENUATION          
          
          ;; DataType 
          GL_BYTE                           
          GL_UNSIGNED_BYTE                  
          GL_SHORT                          
          GL_UNSIGNED_SHORT                 
          GL_FLOAT                          
          GL_FIXED                          
          
          ;; LogicOp 
          GL_CLEAR                          
          GL_AND                            
          GL_AND_REVERSE                    
          GL_COPY                           
          GL_AND_INVERTED                   
          GL_NOOP                           
          GL_XOR                            
          GL_OR                             
          GL_NOR                            
          GL_EQUIV                          
          GL_INVERT                         
          GL_OR_REVERSE                     
          GL_COPY_INVERTED                  
          GL_OR_INVERTED                    
          GL_NAND                           
          GL_SET                            
          
          ;; MaterialFace 
          ;;      GL_FRONT_AND_BACK 
          
          ;; MaterialParameter 
          GL_EMISSION                       
          GL_SHININESS                      
          GL_AMBIENT_AND_DIFFUSE            
          ;;      GL_AMBIENT 
          ;;      GL_DIFFUSE 
          ;;      GL_SPECULAR 
          
          ;; MatrixMode 
          GL_MODELVIEW                      
          GL_PROJECTION                     
          GL_TEXTURE                        
          
          ;; NormalPointerType 
          ;;      GL_BYTE 
          ;;      GL_SHORT 
          ;;      GL_FLOAT 
          ;;      GL_FIXED 
          
          ;; PixelFormat 
          GL_ALPHA                          
          GL_RGB                            
          GL_RGBA                           
          GL_LUMINANCE                      
          GL_LUMINANCE_ALPHA                
          
          ;; PixelStoreParameter 
          GL_UNPACK_ALIGNMENT               
          GL_PACK_ALIGNMENT                 
          
          ;; PixelType 
          ;;      GL_UNSIGNED_BYTE 
          GL_UNSIGNED_SHORT_4_4_4_4         
          GL_UNSIGNED_SHORT_5_5_5_1         
          GL_UNSIGNED_SHORT_5_6_5           
          
          ;; ShadingModel 
          GL_FLAT                           
          GL_SMOOTH                         
          
          ;; StencilFunction 
          ;;      GL_NEVER 
          ;;      GL_LESS 
          ;;      GL_EQUAL 
          ;;      GL_LEQUAL 
          ;;      GL_GREATER 
          ;;      GL_NOTEQUAL 
          ;;      GL_GEQUAL 
          ;;      GL_ALWAYS 
          
          ;; StencilOp 
          ;;      GL_ZERO 
          GL_KEEP                           
          GL_REPLACE                        
          GL_INCR                           
          GL_DECR                           
          ;;      GL_INVERT 
          
          ;; StringName 
          GL_VENDOR                         
          GL_RENDERER                       
          GL_VERSION                        
          GL_EXTENSIONS                     
          
          ;; TexCoordPointerType 
          ;;      GL_SHORT 
          ;;      GL_FLOAT 
          ;;      GL_FIXED 
          ;;      GL_BYTE 
          
          ;; TextureEnvMode 
          GL_MODULATE                       
          GL_DECAL                          
          ;;      GL_BLEND 
          GL_ADD                            
          ;;      GL_REPLACE 
          
          ;; TextureEnvParameter 
          GL_TEXTURE_ENV_MODE               
          GL_TEXTURE_ENV_COLOR              
          
          ;; TextureEnvTarget 
          GL_TEXTURE_ENV                    
          
          ;; TextureMagFilter 
          GL_NEAREST                        
          GL_LINEAR                         
          
          ;; TextureMinFilter 
          ;;      GL_NEAREST 
          ;;      GL_LINEAR 
          GL_NEAREST_MIPMAP_NEAREST         
          GL_LINEAR_MIPMAP_NEAREST          
          GL_NEAREST_MIPMAP_LINEAR          
          GL_LINEAR_MIPMAP_LINEAR           
          
          ;; TextureParameterName 
          GL_TEXTURE_MAG_FILTER             
          GL_TEXTURE_MIN_FILTER             
          GL_TEXTURE_WRAP_S                 
          GL_TEXTURE_WRAP_T                 
          GL_GENERATE_MIPMAP                
          
          ;; TextureTarget 
          ;;      GL_TEXTURE_2D 
          
          ;; TextureUnit 
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
          GL_CLIENT_ACTIVE_TEXTURE          
          
          ;; TextureWrapMode 
          GL_REPEAT                         
          GL_CLAMP_TO_EDGE                  
          
          ;; PixelInternalFormat 
          GL_PALETTE4_RGB8_OES              
          GL_PALETTE4_RGBA8_OES             
          GL_PALETTE4_R5_G6_B5_OES          
          GL_PALETTE4_RGBA4_OES             
          GL_PALETTE4_RGB5_A1_OES           
          GL_PALETTE8_RGB8_OES              
          GL_PALETTE8_RGBA8_OES             
          GL_PALETTE8_R5_G6_B5_OES          
          GL_PALETTE8_RGBA4_OES             
          GL_PALETTE8_RGB5_A1_OES           
          
          ;; VertexPointerType 
          ;;      GL_SHORT 
          ;;      GL_FLOAT 
          ;;      GL_FIXED 
          ;;      GL_BYTE 
          
          ;; LightName 
          GL_LIGHT0                         
          GL_LIGHT1                         
          GL_LIGHT2                         
          GL_LIGHT3                         
          GL_LIGHT4                         
          GL_LIGHT5                         
          GL_LIGHT6                         
          GL_LIGHT7                         
          
          ;; Buffer Objects 
          GL_ARRAY_BUFFER                   
          GL_ELEMENT_ARRAY_BUFFER           
          
          GL_ARRAY_BUFFER_BINDING           
          GL_ELEMENT_ARRAY_BUFFER_BINDING   
          GL_VERTEX_ARRAY_BUFFER_BINDING    
          GL_NORMAL_ARRAY_BUFFER_BINDING    
          GL_COLOR_ARRAY_BUFFER_BINDING     
          GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING 
          
          GL_STATIC_DRAW                    
          GL_DYNAMIC_DRAW                   
          
          GL_BUFFER_SIZE                    
          GL_BUFFER_USAGE                   
          
          ;; Texture combine + dot3 
          GL_SUBTRACT                       
          GL_COMBINE                        
          GL_COMBINE_RGB                    
          GL_COMBINE_ALPHA                  
          GL_RGB_SCALE                      
          GL_ADD_SIGNED                     
          GL_INTERPOLATE                    
          GL_CONSTANT                       
          GL_PRIMARY_COLOR                  
          GL_PREVIOUS                       
          GL_OPERAND0_RGB                   
          GL_OPERAND1_RGB                   
          GL_OPERAND2_RGB                   
          GL_OPERAND0_ALPHA                 
          GL_OPERAND1_ALPHA                 
          GL_OPERAND2_ALPHA                 
          
          GL_ALPHA_SCALE                    
          
          GL_SRC0_RGB                       
          GL_SRC1_RGB                       
          GL_SRC2_RGB                       
          GL_SRC0_ALPHA                     
          GL_SRC1_ALPHA                     
          GL_SRC2_ALPHA                     
          
          GL_DOT3_RGB                       
          GL_DOT3_RGBA                      
          
          
          ;;***************************************************************************************
          ;;                                 OES extension functions                               
          ;;***************************************************************************************
          
          ;; OES_draw_texture 
          GL_TEXTURE_CROP_RECT_OES          
          
          ;; OES_matrix_get 
          GL_MODELVIEW_MATRIX_FLOAT_AS_INT_BITS_OES   
          GL_PROJECTION_MATRIX_FLOAT_AS_INT_BITS_OES  
          GL_TEXTURE_MATRIX_FLOAT_AS_INT_BITS_OES     
          
          ;; OES_matrix_palette 
          GL_MAX_VERTEX_UNITS_OES           
          GL_MAX_PALETTE_MATRICES_OES       
          GL_MATRIX_PALETTE_OES             
          GL_MATRIX_INDEX_ARRAY_OES         
          GL_WEIGHT_ARRAY_OES               
          GL_CURRENT_PALETTE_MATRIX_OES     
          
          GL_MATRIX_INDEX_ARRAY_SIZE_OES    
          GL_MATRIX_INDEX_ARRAY_TYPE_OES    
          GL_MATRIX_INDEX_ARRAY_STRIDE_OES  
          GL_MATRIX_INDEX_ARRAY_POINTER_OES 
          GL_MATRIX_INDEX_ARRAY_BUFFER_BINDING_OES 
          
          GL_WEIGHT_ARRAY_SIZE_OES          
          GL_WEIGHT_ARRAY_TYPE_OES          
          GL_WEIGHT_ARRAY_STRIDE_OES        
          GL_WEIGHT_ARRAY_POINTER_OES       
          GL_WEIGHT_ARRAY_BUFFER_BINDING_OES 
          
          ;; OES_point_size_array 
          GL_POINT_SIZE_ARRAY_OES           
          GL_POINT_SIZE_ARRAY_TYPE_OES      
          GL_POINT_SIZE_ARRAY_STRIDE_OES    
          GL_POINT_SIZE_ARRAY_POINTER_OES   
          GL_POINT_SIZE_ARRAY_BUFFER_BINDING_OES 
          
          ;; OES_point_sprite 
          GL_POINT_SPRITE_OES               
          GL_COORD_REPLACE_OES
          
          
          
          
          ;;***********************************************************
          
          glAlphaFunc
          glClearColor 
          glClearDepthf 
          glClipPlanef 
          glColor4f 
          glDepthRangef 
          glFogf 
          glFogfv 
          glFrustumf 
          glGetClipPlanef 
          glGetFloatv 
          glGetLightfv 
          glGetMaterialfv 
          glGetTexEnvfv 
          glGetTexParameterfv 
          glLightModelf 
          glLightModelfv 
          glLightf 
          glLightfv 
          glLineWidth 
          glLoadMatrixf 
          glMaterialf 
          glMaterialfv 
          glMultMatrixf 
          glMultiTexCoord4f 
          glNormal3f 
          glOrthof 
          glPointParameterf 
          glPointParameterfv 
          glPointSize 
          glPolygonOffset 
          glRotatef 
          glSampleCoverage 
          glScalef 
          glTexEnvf 
          glTexEnvfv 
          glTexParameterf 
          glTexParameterfv 
          glTranslatef 
          
          glActiveTexture 
          glAlphaFuncx 
          glBindBuffer 
          glBindTexture 
          glBlendFunc 
          glBufferData 
          glBufferSubData 
          glClear 
          glClearColorx 
          glClearDepthx 
          glClearStencil 
          glClientActiveTexture 
          glClipPlanex 
          glColor4ub 
          glColor4x 
          glColorMask 
          glColorPointer 
          glCompressedTexImage2D 
          glCompressedTexSubImage2D 
          glCopyTexImage2D 
          glCopyTexSubImage2D 
          glCullFace 
          glDeleteBuffers 
          glDeleteTextures 
          glDepthFunc 
          glDepthMask 
          glDepthRangex 
          glDisable 
          glDisableClientState 
          glDrawArrays 
          glDrawElements 
          glEnable 
          glEnableClientState 
          glFinish 
          glFlush 
          glFogx 
          glFogxv 
          glFrontFace 
          glFrustumx 
          glGenBuffers 
          glGenTextures 
          glGetBooleanv 
          glGetBufferParameteriv 
          glGetClipPlanex 
          glGetError 
          glGetFixedv 
          glGetIntegerv 
          glGetLightxv 
          glGetMaterialxv 
          glGetPointerv 
          glGetString 
          glGetTexEnviv 
          glGetTexEnvxv 
          glGetTexParameteriv 
          glGetTexParameterxv 
          glHint 
          glIsBuffer 
          glIsEnabled 
          glIsTexture 
          glLightModelx 
          glLightModelxv 
          glLightx 
          glLightxv 
          glLineWidthx 
          glLoadIdentity 
          glLoadMatrixx 
          glLogicOp 
          glMaterialx 
          glMaterialxv 
          glMatrixMode 
          glMultMatrixx 
          glMultiTexCoord4x 
          glNormal3x 
          glNormalPointer 
          glOrthox 
          glPixelStorei 
          glPointParameterx 
          glPointParameterxv 
          glPointSizex 
          glPolygonOffsetx 
          glPopMatrix 
          glPushMatrix 
          glReadPixels 
          glRotatex 
          glSampleCoveragex 
          glScalex 
          glScissor 
          glShadeModel 
          glStencilFunc 
          glStencilMask 
          glStencilOp 
          glTexCoordPointer 
          glTexEnvi 
          glTexEnvx 
          glTexEnviv 
          glTexEnvxv 
          glTexImage2D 
          glTexParameteri 
          glTexParameterx 
          glTexParameteriv 
          glTexParameterxv 
          glTexSubImage2D 
          glTranslatex 
          glVertexPointer 
          glViewport 
          
          ;;***************************************************************************************
          ;;                                 OES extension functions                               
          ;;***************************************************************************************
          ;; OES_matrix_palette 
          glCurrentPaletteMatrixOES 
          glLoadPaletteFromModelViewMatrixOES 
          glMatrixIndexPointerOES 
          glWeightPointerOES 
          
          ;; OES_point_size_array 
          glPointSizePointerOES 
          
          ;; OES_draw_texture 
          glDrawTexsOES 
          glDrawTexiOES 
          glDrawTexxOES 
          
          glDrawTexsvOES 
          glDrawTexivOES 
          glDrawTexxvOES 
          
          glDrawTexfOES 
          glDrawTexfvOES 
          
          
          
          
          )
         (import (scheme) (utils libutil))
         
         (define lib-name
           (case (machine-type)
             ((arm32le) "libglut.so")
             ((i3le ti3le) "libglut.so.6")
             ((i3osx)  "libglut.dylib")))
         
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
         
         
         ;; OpenGL ES core versions 
         (define GL_VERSION_ES_CM_1_0              1)
         (define GL_VERSION_ES_CL_1_0              1)
         (define GL_VERSION_ES_CM_1_1              1)
         (define GL_VERSION_ES_CL_1_1              1)
         
         ;; Legacy core versions 
         (define GL_OES_VERSION_1_0                1)
         (define GL_OES_VERSION_1_1                1)
         
         ;; Extensions 
         (define GL_OES_byte_coordinates           1)
         (define GL_OES_compressed_paletted_texture 1)
         (define GL_OES_draw_texture               1)
         (define GL_OES_fixed_point                1)
         (define GL_OES_matrix_get                 1)
         (define GL_OES_matrix_palette             1)
         (define GL_OES_point_size_array           1)
         (define GL_OES_point_sprite               1)
         (define GL_OES_read_format                1)
         (define GL_OES_single_precision           1)
         
         ;; ClearBufferMask 
         (define GL_DEPTH_BUFFER_BIT               #x00000100)
         (define GL_STENCIL_BUFFER_BIT             #x00000400)
         (define GL_COLOR_BUFFER_BIT               #x00004000)
         
         ;; Boolean 
         (define GL_FALSE                          0)
         (define GL_TRUE                           1)
         
         ;; BeginMode 
         (define GL_POINTS                         #x0000)
         (define GL_LINES                          #x0001)
         (define GL_LINE_LOOP                      #x0002)
         (define GL_LINE_STRIP                     #x0003)
         (define GL_TRIANGLES                      #x0004)
         (define GL_TRIANGLE_STRIP                 #x0005)
         (define GL_TRIANGLE_FAN                   #x0006)
         
         ;; AlphaFunction 
         (define GL_NEVER                          #x0200)
         (define GL_LESS                           #x0201)
         (define GL_EQUAL                          #x0202)
         (define GL_LEQUAL                         #x0203)
         (define GL_GREATER                        #x0204)
         (define GL_NOTEQUAL                       #x0205)
         (define GL_GEQUAL                         #x0206)
         (define GL_ALWAYS                         #x0207)
         
         ;; BlendingFactorDest 
         (define GL_ZERO                           0)
         (define GL_ONE                            1)
         (define GL_SRC_COLOR                      #x0300)
         (define GL_ONE_MINUS_SRC_COLOR            #x0301)
         (define GL_SRC_ALPHA                      #x0302)
         (define GL_ONE_MINUS_SRC_ALPHA            #x0303)
         (define GL_DST_ALPHA                      #x0304)
         (define GL_ONE_MINUS_DST_ALPHA            #x0305)
         
         ;; BlendingFactorSrc 
         ;;      GL_ZERO 
         ;;      GL_ONE 
         (define GL_DST_COLOR                      #x0306)
         (define GL_ONE_MINUS_DST_COLOR            #x0307)
         (define GL_SRC_ALPHA_SATURATE             #x0308)
         ;;      GL_SRC_ALPHA 
         ;;      GL_ONE_MINUS_SRC_ALPHA 
         ;;      GL_DST_ALPHA 
         ;;      GL_ONE_MINUS_DST_ALPHA 
         
         ;; ClipPlaneName 
         (define GL_CLIP_PLANE0                    #x3000)
         (define GL_CLIP_PLANE1                    #x3001)
         (define GL_CLIP_PLANE2                    #x3002)
         (define GL_CLIP_PLANE3                    #x3003)
         (define GL_CLIP_PLANE4                    #x3004)
         (define GL_CLIP_PLANE5                    #x3005)
         
         ;; ColorMaterialFace 
         ;;      GL_FRONT_AND_BACK 
         
         ;; ColorMaterialParameter 
         ;;      GL_AMBIENT_AND_DIFFUSE 
         
         ;; ColorPointerType 
         ;;      GL_UNSIGNED_BYTE 
         ;;      GL_FLOAT 
         ;;      GL_FIXED 
         
         ;; CullFaceMode 
         (define GL_FRONT                          #x0404)
         (define GL_BACK                           #x0405)
         (define GL_FRONT_AND_BACK                 #x0408)
         
         ;; DepthFunction 
         ;;      GL_NEVER 
         ;;      GL_LESS 
         ;;      GL_EQUAL 
         ;;      GL_LEQUAL 
         ;;      GL_GREATER 
         ;;      GL_NOTEQUAL 
         ;;      GL_GEQUAL 
         ;;      GL_ALWAYS 
         
         ;; EnableCap 
         (define GL_FOG                            #x0B60)
         (define GL_LIGHTING                       #x0B50)
         (define GL_TEXTURE_2D                     #x0DE1)
         (define GL_CULL_FACE                      #x0B44)
         (define GL_ALPHA_TEST                     #x0BC0)
         (define GL_BLEND                          #x0BE2)
         (define GL_COLOR_LOGIC_OP                 #x0BF2)
         (define GL_DITHER                         #x0BD0)
         (define GL_STENCIL_TEST                   #x0B90)
         (define GL_DEPTH_TEST                     #x0B71)
         ;;      GL_LIGHT0 
         ;;      GL_LIGHT1 
         ;;      GL_LIGHT2 
         ;;      GL_LIGHT3 
         ;;      GL_LIGHT4 
         ;;      GL_LIGHT5 
         ;;      GL_LIGHT6 
         ;;      GL_LIGHT7 
         (define GL_POINT_SMOOTH                   #x0B10)
         (define GL_LINE_SMOOTH                    #x0B20)
         (define GL_COLOR_MATERIAL                 #x0B57)
         (define GL_NORMALIZE                      #x0BA1)
         (define GL_RESCALE_NORMAL                 #x803A)
         (define GL_VERTEX_ARRAY                   #x8074)
         (define GL_NORMAL_ARRAY                   #x8075)
         (define GL_COLOR_ARRAY                    #x8076)
         (define GL_TEXTURE_COORD_ARRAY            #x8078)
         (define GL_MULTISAMPLE                    #x809D)
         (define GL_SAMPLE_ALPHA_TO_COVERAGE       #x809E)
         (define GL_SAMPLE_ALPHA_TO_ONE            #x809F)
         (define GL_SAMPLE_COVERAGE                #x80A0)
         
         ;; ErrorCode 
         (define GL_NO_ERROR                       0)
         (define GL_INVALID_ENUM                   #x0500)
         (define GL_INVALID_VALUE                  #x0501)
         (define GL_INVALID_OPERATION              #x0502)
         (define GL_STACK_OVERFLOW                 #x0503)
         (define GL_STACK_UNDERFLOW                #x0504)
         (define GL_OUT_OF_MEMORY                  #x0505)
         
         ;; FogMode 
         ;;      GL_LINEAR 
         (define GL_EXP                            #x0800)
         (define GL_EXP2                           #x0801)
         
         ;; FogParameter 
         (define GL_FOG_DENSITY                    #x0B62)
         (define GL_FOG_START                      #x0B63)
         (define GL_FOG_END                        #x0B64)
         (define GL_FOG_MODE                       #x0B65)
         (define GL_FOG_COLOR                      #x0B66)
         
         ;; FrontFaceDirection 
         (define GL_CW                             #x0900)
         (define GL_CCW                            #x0901)
         
         ;; GetPName 
         (define GL_CURRENT_COLOR                  #x0B00)
         (define GL_CURRENT_NORMAL                 #x0B02)
         (define GL_CURRENT_TEXTURE_COORDS         #x0B03)
         (define GL_POINT_SIZE                     #x0B11)
         (define GL_POINT_SIZE_MIN                 #x8126)
         (define GL_POINT_SIZE_MAX                 #x8127)
         (define GL_POINT_FADE_THRESHOLD_SIZE      #x8128)
         (define GL_POINT_DISTANCE_ATTENUATION     #x8129)
         (define GL_SMOOTH_POINT_SIZE_RANGE        #x0B12)
         (define GL_LINE_WIDTH                     #x0B21)
         (define GL_SMOOTH_LINE_WIDTH_RANGE        #x0B22)
         (define GL_ALIASED_POINT_SIZE_RANGE       #x846D)
         (define GL_ALIASED_LINE_WIDTH_RANGE       #x846E)
         (define GL_CULL_FACE_MODE                 #x0B45)
         (define GL_FRONT_FACE                     #x0B46)
         (define GL_SHADE_MODEL                    #x0B54)
         (define GL_DEPTH_RANGE                    #x0B70)
         (define GL_DEPTH_WRITEMASK                #x0B72)
         (define GL_DEPTH_CLEAR_VALUE              #x0B73)
         (define GL_DEPTH_FUNC                     #x0B74)
         (define GL_STENCIL_CLEAR_VALUE            #x0B91)
         (define GL_STENCIL_FUNC                   #x0B92)
         (define GL_STENCIL_VALUE_MASK             #x0B93)
         (define GL_STENCIL_FAIL                   #x0B94)
         (define GL_STENCIL_PASS_DEPTH_FAIL        #x0B95)
         (define GL_STENCIL_PASS_DEPTH_PASS        #x0B96)
         (define GL_STENCIL_REF                    #x0B97)
         (define GL_STENCIL_WRITEMASK              #x0B98)
         (define GL_MATRIX_MODE                    #x0BA0)
         (define GL_VIEWPORT                       #x0BA2)
         (define GL_MODELVIEW_STACK_DEPTH          #x0BA3)
         (define GL_PROJECTION_STACK_DEPTH         #x0BA4)
         (define GL_TEXTURE_STACK_DEPTH            #x0BA5)
         (define GL_MODELVIEW_MATRIX               #x0BA6)
         (define GL_PROJECTION_MATRIX              #x0BA7)
         (define GL_TEXTURE_MATRIX                 #x0BA8)
         (define GL_ALPHA_TEST_FUNC                #x0BC1)
         (define GL_ALPHA_TEST_REF                 #x0BC2)
         (define GL_BLEND_DST                      #x0BE0)
         (define GL_BLEND_SRC                      #x0BE1)
         (define GL_LOGIC_OP_MODE                  #x0BF0)
         (define GL_SCISSOR_BOX                    #x0C10)
         (define GL_SCISSOR_TEST                   #x0C11)
         (define GL_COLOR_CLEAR_VALUE              #x0C22)
         (define GL_COLOR_WRITEMASK                #x0C23)
         
         
         
         (define GL_MAX_LIGHTS                     #x0D31)
         (define GL_MAX_CLIP_PLANES                #x0D32)
         (define GL_MAX_TEXTURE_SIZE               #x0D33)
         (define GL_MAX_MODELVIEW_STACK_DEPTH      #x0D36)
         (define GL_MAX_PROJECTION_STACK_DEPTH     #x0D38)
         (define GL_MAX_TEXTURE_STACK_DEPTH        #x0D39)
         (define GL_MAX_VIEWPORT_DIMS              #x0D3A)
         (define GL_MAX_TEXTURE_UNITS              #x84E2)
         (define GL_SUBPIXEL_BITS                  #x0D50)
         (define GL_RED_BITS                       #x0D52)
         (define GL_GREEN_BITS                     #x0D53)
         (define GL_BLUE_BITS                      #x0D54)
         (define GL_ALPHA_BITS                     #x0D55)
         (define GL_DEPTH_BITS                     #x0D56)
         (define GL_STENCIL_BITS                   #x0D57)
         (define GL_POLYGON_OFFSET_UNITS           #x2A00)
         (define GL_POLYGON_OFFSET_FILL            #x8037)
         (define GL_POLYGON_OFFSET_FACTOR          #x8038)
         (define GL_TEXTURE_BINDING_2D             #x8069)
         (define GL_VERTEX_ARRAY_SIZE              #x807A)
         (define GL_VERTEX_ARRAY_TYPE              #x807B)
         (define GL_VERTEX_ARRAY_STRIDE            #x807C)
         (define GL_NORMAL_ARRAY_TYPE              #x807E)
         (define GL_NORMAL_ARRAY_STRIDE            #x807F)
         (define GL_COLOR_ARRAY_SIZE               #x8081)
         (define GL_COLOR_ARRAY_TYPE               #x8082)
         (define GL_COLOR_ARRAY_STRIDE             #x8083)
         (define GL_TEXTURE_COORD_ARRAY_SIZE       #x8088)
         (define GL_TEXTURE_COORD_ARRAY_TYPE       #x8089)
         (define GL_TEXTURE_COORD_ARRAY_STRIDE     #x808A)
         (define GL_VERTEX_ARRAY_POINTER           #x808E)
         (define GL_NORMAL_ARRAY_POINTER           #x808F)
         (define GL_COLOR_ARRAY_POINTER            #x8090)
         (define GL_TEXTURE_COORD_ARRAY_POINTER    #x8092)
         (define GL_SAMPLE_BUFFERS                 #x80A8)
         (define GL_SAMPLES                        #x80A9)
         (define GL_SAMPLE_COVERAGE_VALUE          #x80AA)
         (define GL_SAMPLE_COVERAGE_INVERT         #x80AB)
         
         ;; GetTextureParameter 
         ;;      GL_TEXTURE_MAG_FILTER 
         ;;      GL_TEXTURE_MIN_FILTER 
         ;;      GL_TEXTURE_WRAP_S 
         ;;      GL_TEXTURE_WRAP_T 
         
         (define GL_IMPLEMENTATION_COLOR_READ_TYPE_OES   #x8B9A)
         (define GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES #x8B9B)
         (define GL_NUM_COMPRESSED_TEXTURE_FORMATS       #x86A2)
         (define GL_COMPRESSED_TEXTURE_FORMATS           #x86A3)
         
         ;; HintMode 
         (define GL_DONT_CARE                      #x1100)
         (define GL_FASTEST                        #x1101)
         (define GL_NICEST                         #x1102)
         
         ;; HintTarget 
         (define GL_PERSPECTIVE_CORRECTION_HINT    #x0C50)
         (define GL_POINT_SMOOTH_HINT              #x0C51)
         (define GL_LINE_SMOOTH_HINT               #x0C52)
         (define GL_FOG_HINT                       #x0C54)
         (define GL_GENERATE_MIPMAP_HINT           #x8192)
         
         ;; LightModelParameter 
         (define GL_LIGHT_MODEL_AMBIENT            #x0B53)
         (define GL_LIGHT_MODEL_TWO_SIDE           #x0B52)
         
         ;; LightParameter 
         (define GL_AMBIENT                        #x1200)
         (define GL_DIFFUSE                        #x1201)
         (define GL_SPECULAR                       #x1202)
         (define GL_POSITION                       #x1203)
         (define GL_SPOT_DIRECTION                 #x1204)
         (define GL_SPOT_EXPONENT                  #x1205)
         (define GL_SPOT_CUTOFF                    #x1206)
         (define GL_CONSTANT_ATTENUATION           #x1207)
         (define GL_LINEAR_ATTENUATION             #x1208)
         (define GL_QUADRATIC_ATTENUATION          #x1209)
         
         ;; DataType 
         (define GL_BYTE                           #x1400)
         (define GL_UNSIGNED_BYTE                  #x1401)
         (define GL_SHORT                          #x1402)
         (define GL_UNSIGNED_SHORT                 #x1403)
         (define GL_FLOAT                          #x1406)
         (define GL_FIXED                          #x140C)
         
         ;; LogicOp 
         (define GL_CLEAR                          #x1500)
         (define GL_AND                            #x1501)
         (define GL_AND_REVERSE                    #x1502)
         (define GL_COPY                           #x1503)
         (define GL_AND_INVERTED                   #x1504)
         (define GL_NOOP                           #x1505)
         (define GL_XOR                            #x1506)
         (define GL_OR                             #x1507)
         (define GL_NOR                            #x1508)
         (define GL_EQUIV                          #x1509)
         (define GL_INVERT                         #x150A)
         (define GL_OR_REVERSE                     #x150B)
         (define GL_COPY_INVERTED                  #x150C)
         (define GL_OR_INVERTED                    #x150D)
         (define GL_NAND                           #x150E)
         (define GL_SET                            #x150F)
         
         ;; MaterialFace 
         ;;      GL_FRONT_AND_BACK 
         
         ;; MaterialParameter 
         (define GL_EMISSION                       #x1600)
         (define GL_SHININESS                      #x1601)
         (define GL_AMBIENT_AND_DIFFUSE            #x1602)
         ;;      GL_AMBIENT 
         ;;      GL_DIFFUSE 
         ;;      GL_SPECULAR 
         
         ;; MatrixMode 
         (define GL_MODELVIEW                      #x1700)
         (define GL_PROJECTION                     #x1701)
         (define GL_TEXTURE                        #x1702)
         
         ;; NormalPointerType 
         ;;      GL_BYTE 
         ;;      GL_SHORT 
         ;;      GL_FLOAT 
         ;;      GL_FIXED 
         
         ;; PixelFormat 
         (define GL_ALPHA                          #x1906)
         (define GL_RGB                            #x1907)
         (define GL_RGBA                           #x1908)
         (define GL_LUMINANCE                      #x1909)
         (define GL_LUMINANCE_ALPHA                #x190A)
         
         ;; PixelStoreParameter 
         (define GL_UNPACK_ALIGNMENT               #x0CF5)
         (define GL_PACK_ALIGNMENT                 #x0D05)
         
         ;; PixelType 
         ;;      GL_UNSIGNED_BYTE 
         (define GL_UNSIGNED_SHORT_4_4_4_4         #x8033)
         (define GL_UNSIGNED_SHORT_5_5_5_1         #x8034)
         (define GL_UNSIGNED_SHORT_5_6_5           #x8363)
         
         ;; ShadingModel 
         (define GL_FLAT                           #x1D00)
         (define GL_SMOOTH                         #x1D01)
         
         ;; StencilFunction 
         ;;      GL_NEVER 
         ;;      GL_LESS 
         ;;      GL_EQUAL 
         ;;      GL_LEQUAL 
         ;;      GL_GREATER 
         ;;      GL_NOTEQUAL 
         ;;      GL_GEQUAL 
         ;;      GL_ALWAYS 
         
         ;; StencilOp 
         ;;      GL_ZERO 
         (define GL_KEEP                           #x1E00)
         (define GL_REPLACE                        #x1E01)
         (define GL_INCR                           #x1E02)
         (define GL_DECR                           #x1E03)
         ;;      GL_INVERT 
         
         ;; StringName 
         (define GL_VENDOR                         #x1F00)
         (define GL_RENDERER                       #x1F01)
         (define GL_VERSION                        #x1F02)
         (define GL_EXTENSIONS                     #x1F03)
         
         ;; TexCoordPointerType 
         ;;      GL_SHORT 
         ;;      GL_FLOAT 
         ;;      GL_FIXED 
         ;;      GL_BYTE 
         
         ;; TextureEnvMode 
         (define GL_MODULATE                       #x2100)
         (define GL_DECAL                          #x2101)
         ;;      GL_BLEND 
         (define GL_ADD                            #x0104)
         ;;      GL_REPLACE 
         
         ;; TextureEnvParameter 
         (define GL_TEXTURE_ENV_MODE               #x2200)
         (define GL_TEXTURE_ENV_COLOR              #x2201)
         
         ;; TextureEnvTarget 
         (define GL_TEXTURE_ENV                    #x2300)
         
         ;; TextureMagFilter 
         (define GL_NEAREST                        #x2600)
         (define GL_LINEAR                         #x2601)
         
         ;; TextureMinFilter 
         ;;      GL_NEAREST 
         ;;      GL_LINEAR 
         (define GL_NEAREST_MIPMAP_NEAREST         #x2700)
         (define GL_LINEAR_MIPMAP_NEAREST          #x2701)
         (define GL_NEAREST_MIPMAP_LINEAR          #x2702)
         (define GL_LINEAR_MIPMAP_LINEAR           #x2703)
         
         ;; TextureParameterName 
         (define GL_TEXTURE_MAG_FILTER             #x2800)
         (define GL_TEXTURE_MIN_FILTER             #x2801)
         (define GL_TEXTURE_WRAP_S                 #x2802)
         (define GL_TEXTURE_WRAP_T                 #x2803)
         (define GL_GENERATE_MIPMAP                #x8191)
         
         ;; TextureTarget 
         ;;      GL_TEXTURE_2D 
         
         ;; TextureUnit 
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
         (define GL_CLIENT_ACTIVE_TEXTURE          #x84E1)
         
         ;; TextureWrapMode 
         (define GL_REPEAT                         #x2901)
         (define GL_CLAMP_TO_EDGE                  #x812F)
         
         ;; PixelInternalFormat 
         (define GL_PALETTE4_RGB8_OES              #x8B90)
         (define GL_PALETTE4_RGBA8_OES             #x8B91)
         (define GL_PALETTE4_R5_G6_B5_OES          #x8B92)
         (define GL_PALETTE4_RGBA4_OES             #x8B93)
         (define GL_PALETTE4_RGB5_A1_OES           #x8B94)
         (define GL_PALETTE8_RGB8_OES              #x8B95)
         (define GL_PALETTE8_RGBA8_OES             #x8B96)
         (define GL_PALETTE8_R5_G6_B5_OES          #x8B97)
         (define GL_PALETTE8_RGBA4_OES             #x8B98)
         (define GL_PALETTE8_RGB5_A1_OES           #x8B99)
         
         ;; VertexPointerType 
         ;;      GL_SHORT 
         ;;      GL_FLOAT 
         ;;      GL_FIXED 
         ;;      GL_BYTE 
         
         ;; LightName 
         (define GL_LIGHT0                         #x4000)
         (define GL_LIGHT1                         #x4001)
         (define GL_LIGHT2                         #x4002)
         (define GL_LIGHT3                         #x4003)
         (define GL_LIGHT4                         #x4004)
         (define GL_LIGHT5                         #x4005)
         (define GL_LIGHT6                         #x4006)
         (define GL_LIGHT7                         #x4007)
         
         ;; Buffer Objects 
         (define GL_ARRAY_BUFFER                   #x8892)
         (define GL_ELEMENT_ARRAY_BUFFER           #x8893)
         
         (define GL_ARRAY_BUFFER_BINDING           #x8894)
         (define GL_ELEMENT_ARRAY_BUFFER_BINDING   #x8895)
         (define GL_VERTEX_ARRAY_BUFFER_BINDING    #x8896)
         (define GL_NORMAL_ARRAY_BUFFER_BINDING    #x8897)
         (define GL_COLOR_ARRAY_BUFFER_BINDING     #x8898)
         (define GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING #x889A)
         
         (define GL_STATIC_DRAW                    #x88E4)
         (define GL_DYNAMIC_DRAW                   #x88E8)
         
         (define GL_BUFFER_SIZE                    #x8764)
         (define GL_BUFFER_USAGE                   #x8765)
         
         ;; Texture combine + dot3 
         (define GL_SUBTRACT                       #x84E7)
         (define GL_COMBINE                        #x8570)
         (define GL_COMBINE_RGB                    #x8571)
         (define GL_COMBINE_ALPHA                  #x8572)
         (define GL_RGB_SCALE                      #x8573)
         (define GL_ADD_SIGNED                     #x8574)
         (define GL_INTERPOLATE                    #x8575)
         (define GL_CONSTANT                       #x8576)
         (define GL_PRIMARY_COLOR                  #x8577)
         (define GL_PREVIOUS                       #x8578)
         (define GL_OPERAND0_RGB                   #x8590)
         (define GL_OPERAND1_RGB                   #x8591)
         (define GL_OPERAND2_RGB                   #x8592)
         (define GL_OPERAND0_ALPHA                 #x8598)
         (define GL_OPERAND1_ALPHA                 #x8599)
         (define GL_OPERAND2_ALPHA                 #x859A)
         
         (define GL_ALPHA_SCALE                    #x0D1C)
         
         (define GL_SRC0_RGB                       #x8580)
         (define GL_SRC1_RGB                       #x8581)
         (define GL_SRC2_RGB                       #x8582)
         (define GL_SRC0_ALPHA                     #x8588)
         (define GL_SRC1_ALPHA                     #x8589)
         (define GL_SRC2_ALPHA                     #x858A)
         
         (define GL_DOT3_RGB                       #x86AE)
         (define GL_DOT3_RGBA                      #x86AF)
         
         
         ;;***************************************************************************************
         ;;                                 OES extension functions                               
         ;;***************************************************************************************
         
         ;; OES_draw_texture 
         (define GL_TEXTURE_CROP_RECT_OES          #x8B9D)
         
         ;; OES_matrix_get 
         (define GL_MODELVIEW_MATRIX_FLOAT_AS_INT_BITS_OES   #x898D)
         (define GL_PROJECTION_MATRIX_FLOAT_AS_INT_BITS_OES  #x898E)
         (define GL_TEXTURE_MATRIX_FLOAT_AS_INT_BITS_OES     #x898F)
         
         ;; OES_matrix_palette 
         (define GL_MAX_VERTEX_UNITS_OES           #x86A4)
         (define GL_MAX_PALETTE_MATRICES_OES       #x8842)
         (define GL_MATRIX_PALETTE_OES             #x8840)
         (define GL_MATRIX_INDEX_ARRAY_OES         #x8844)
         (define GL_WEIGHT_ARRAY_OES               #x86AD)
         (define GL_CURRENT_PALETTE_MATRIX_OES     #x8843)
         
         (define GL_MATRIX_INDEX_ARRAY_SIZE_OES    #x8846)
         (define GL_MATRIX_INDEX_ARRAY_TYPE_OES    #x8847)
         (define GL_MATRIX_INDEX_ARRAY_STRIDE_OES  #x8848)
         (define GL_MATRIX_INDEX_ARRAY_POINTER_OES #x8849)
         (define GL_MATRIX_INDEX_ARRAY_BUFFER_BINDING_OES #x8B9E)
         
         (define GL_WEIGHT_ARRAY_SIZE_OES          #x86AB)
         (define GL_WEIGHT_ARRAY_TYPE_OES          #x86A9)
         (define GL_WEIGHT_ARRAY_STRIDE_OES        #x86AA)
         (define GL_WEIGHT_ARRAY_POINTER_OES       #x86AC)
         (define GL_WEIGHT_ARRAY_BUFFER_BINDING_OES #x889E)
         
         ;; OES_point_size_array 
         (define GL_POINT_SIZE_ARRAY_OES           #x8B9C)
         (define GL_POINT_SIZE_ARRAY_TYPE_OES      #x898A)
         (define GL_POINT_SIZE_ARRAY_STRIDE_OES    #x898B)
         (define GL_POINT_SIZE_ARRAY_POINTER_OES   #x898C)
         (define GL_POINT_SIZE_ARRAY_BUFFER_BINDING_OES #x8B9F)
         
         ;; OES_point_sprite 
         (define GL_POINT_SPRITE_OES               #x8861)
         (define GL_COORD_REPLACE_OES              #x8862)
         
         
         
         
         
         ;;***********************************************************

         (define-function void  glAlphaFunc (int  float));
         (define-function void  glClearColor (float  float  float  float));
         (define-function void  glClearDepthf (float));
         (define-function void  glClipPlanef (int   void*));
         (define-function void  glColor4f (float  float  float  float));
         (define-function void  glDepthRangef (float  float));
         (define-function void  glFogf (int  float));
         (define-function void  glFogfv (int   void*));
         (define-function void  glFrustumf (float  float  float  float  float  float));
         (define-function void  glGetClipPlanef (int  void*));
         (define-function void  glGetFloatv (int  void*));
         (define-function void  glGetLightfv (int  int  void*));
         (define-function void  glGetMaterialfv (int  int  void*));
         (define-function void  glGetTexEnvfv (int  int  void*));
         (define-function void  glGetTexParameterfv (int  int  void*));
         (define-function void  glLightModelf (int  float));
         (define-function void  glLightModelfv (int   void*));
         (define-function void  glLightf (int  int  float));
         (define-function void  glLightfv (int  int   void*));
         (define-function void  glLineWidth (float));
         (define-function void  glLoadMatrixf ( void*));
         (define-function void  glMaterialf (int  int  float));
         (define-function void  glMaterialfv (int  int   void*));
         (define-function void  glMultMatrixf ( void*));
         (define-function void  glMultiTexCoord4f (int  float  float  float  float));
         (define-function void  glNormal3f (float  float  float));
         (define-function void  glOrthof (float  float  float  float  float   float ));
         (define-function void  glPointParameterf (int  float));
         (define-function void  glPointParameterfv (int   void*));
         (define-function void  glPointSize (float));
         (define-function void  glPolygonOffset (float  float));
         (define-function void  glRotatef (float  float  float  float));
         (define-function void  glSampleCoverage (float  int));
         (define-function void  glScalef (float  float  float));
         (define-function void  glTexEnvf (int  int  float));
         (define-function void  glTexEnvfv (int  int   void*));
         (define-function void  glTexParameterf (int  int  float));
         (define-function void  glTexParameterfv (int  int   void*));
         (define-function void  glTranslatef (float  float  float));
         
         (define-function void  glActiveTexture (int));
         (define-function void  glAlphaFuncx (int  int));
         (define-function void  glBindBuffer (int  int));
         (define-function void  glBindTexture (int  int));
         (define-function void  glBlendFunc (int  int));
         (define-function void  glBufferData (int  void*   void*  int));
         (define-function void  glBufferSubData (int  void*  void*   void*));
         (define-function void  glClear (int));
         (define-function void  glClearColorx (int  int  int  int));
         (define-function void  glClearDepthx (int));
         (define-function void  glClearStencil (int));
         (define-function void  glClientActiveTexture (int));
         (define-function void  glClipPlanex (int   void*));
         (define-function void  glColor4ub (int  int  int  int));
         (define-function void  glColor4x (int   int   int   int ));
         (define-function void  glColorMask (int  int  int  int));
         (define-function void  glColorPointer (int  int  int   void*));
         (define-function void  glCompressedTexImage2D (int  int  int  int  int  int  int   void*));
         (define-function void  glCompressedTexSubImage2D (int  int  int  int  int  int  int  int   void*));
         (define-function void  glCopyTexImage2D (int  int  int  int  int  int  int  int));
         (define-function void  glCopyTexSubImage2D (int  int  int  int  int  int  int  int));
         (define-function void  glCullFace (int));
         (define-function void  glDeleteBuffers (int   void*));
         (define-function void  glDeleteTextures (int   void*));
         (define-function void  glDepthFunc (int));
         (define-function void  glDepthMask (int));
         (define-function void  glDepthRangex (int  int));
         (define-function void  glDisable (int));
         (define-function void  glDisableClientState (int));
         (define-function void  glDrawArrays (int  int  int));
         (define-function void  glDrawElements (int  int  int   void*));
         (define-function void  glEnable (int));
         (define-function void  glEnableClientState (int));
         (define-function void  glFinish ());
         (define-function void  glFlush ());
         (define-function void  glFogx (int  int));
         (define-function void  glFogxv (int   void*));
         (define-function void  glFrontFace (int));
         (define-function void  glFrustumx (int   int   int   int   int   int ));
         (define-function void  glGenBuffers (int  void*));
         (define-function void  glGenTextures (int  void*));
         (define-function void  glGetBooleanv (int  void*));
         (define-function void  glGetBufferParameteriv (int  int  void*));
         (define-function void  glGetClipPlanex (int  int));
         (define-function int  glGetError ());
         (define-function void  glGetFixedv (int  void*));
         (define-function void  glGetIntegerv (int  void*));
         (define-function void  glGetLightxv (int  int  void*));
         (define-function void  glGetMaterialxv (int  int void*));
         (define-function void  glGetPointerv (int  void*));
         (define-function  void*  glGetString (int));
         (define-function void  glGetTexEnviv (int  int  void*));
         (define-function void  glGetTexEnvxv (int  int  void*));
         (define-function void  glGetTexParameteriv (int  int  void*));
         (define-function void  glGetTexParameterxv (int  int  void*));
         (define-function void  glHint (int  int));
         (define-function int  glIsBuffer (int));
         (define-function int  glIsEnabled (int));
         (define-function int  glIsTexture (int));
         (define-function void  glLightModelx (int  int));
         (define-function void  glLightModelxv (int   void*));
         (define-function void  glLightx (int  int  int));
         (define-function void  glLightxv (int  int   void*));
         (define-function void  glLineWidthx (int));
         (define-function void  glLoadIdentity ());
         (define-function void  glLoadMatrixx ( void*));
         (define-function void  glLogicOp (int));
         (define-function void  glMaterialx (int  int  int));
         (define-function void  glMaterialxv (int  int   void*));
         (define-function void  glMatrixMode (int));
         (define-function void  glMultMatrixx ( void*));
         (define-function void  glMultiTexCoord4x (int  int   int   int   int ));
         (define-function void  glNormal3x (int   int   int ));
         (define-function void  glNormalPointer (int  int   void*));
         (define-function void  glOrthox (int   int   int   int   int   int ));
         (define-function void  glPixelStorei (int  int));
         (define-function void  glPointParameterx (int  int));
         (define-function void  glPointParameterxv (int   void*));
         (define-function void  glPointSizex (int));
         (define-function void  glPolygonOffsetx (int   int ));
         (define-function void  glPopMatrix ());
         (define-function void  glPushMatrix ());
         (define-function void  glReadPixels (int  int  int  int  int  int  void*));
         (define-function void  glRotatex (int   int   int   int ));
         (define-function void  glSampleCoveragex (int  int));
         (define-function void  glScalex (int int   int ));
         (define-function void  glScissor (int  int  int  int));
         (define-function void  glShadeModel (int));
         (define-function void  glStencilFunc (int  int  int));
         (define-function void  glStencilMask (int));
         (define-function void  glStencilOp (int  int  int));
         (define-function void  glTexCoordPointer (int  int  int   void*));
         (define-function void  glTexEnvi (int  int  int));
         (define-function void  glTexEnvx (int  int  int));
         (define-function void  glTexEnviv (int  int   void*));
         (define-function void  glTexEnvxv (int  int   void*));
         (define-function void  glTexImage2D (int  int  int  int  int  int  int  int   void*));
         (define-function void  glTexParameteri (int  int  int));
         (define-function void  glTexParameterx (int  int  int));
         (define-function void  glTexParameteriv (int  int   void*));
         (define-function void  glTexParameterxv (int  int   void*));
         (define-function void  glTexSubImage2D (int  int  int  int  int  int  int  int   void*));
         (define-function void  glTranslatex (int  int   int));
         (define-function void  glVertexPointer (int  int  int   void*));
         (define-function void  glViewport (int  int  int  int));
         
         ;;***************************************************************************************
         ;;                                 OES extension functions                               
         ;;***************************************************************************************
         ;; OES_matrix_palette 
         (define-function void  glCurrentPaletteMatrixOES (int));
         (define-function void  glLoadPaletteFromModelViewMatrixOES ());
         (define-function void  glMatrixIndexPointerOES (int  int  int   void*));
         (define-function void  glWeightPointerOES (int  int  int   void*));
         
         ;; OES_point_size_array 
         (define-function void  glPointSizePointerOES (int  int   void*));
         
         ;; OES_draw_texture 
         (define-function void  glDrawTexsOES (int  int  int  int  int));
         (define-function void  glDrawTexiOES (int  int  int  int  int));
         (define-function void  glDrawTexxOES (int  int  int  int  int ));
         
         (define-function void  glDrawTexsvOES ( void*));
         (define-function void  glDrawTexivOES ( void*));
         (define-function void  glDrawTexxvOES ( void*));
         
         (define-function void  glDrawTexfOES (float  float  float  float  float));
         (define-function void  glDrawTexfvOES ( void*));
         
         
         
         
         )
