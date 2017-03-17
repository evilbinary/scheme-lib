
;; Original version for Gambit by David St-Hilaire
;;
;; Ported to Ypsilon by Ed Cavazos

(library

 (agave glu compat)

 (export

  GLU_EXT_object_space_tess
  GLU_EXT_nurbs_tessellator
  GLU_FALSE
  GLU_TRUE
  GLU_VERSION_1_1
  GLU_VERSION_1_2
  GLU_VERSION_1_3
  GLU_VERSION
  GLU_EXTENSIONS
  GLU_INVALID_ENUM
  GLU_INVALID_VALUE
  GLU_OUT_OF_MEMORY
  GLU_INCOMPATIBLE_GL_VERSION
  GLU_INVALID_OPERATION
  GLU_OUTLINE_POLYGON
  GLU_OUTLINE_PATCH
  GLU_NURBS_ERROR
  GLU_ERROR
  GLU_NURBS_BEGIN
  GLU_NURBS_BEGIN_EXT
  GLU_NURBS_VERTEX
  GLU_NURBS_VERTEX_EXT
  GLU_NURBS_NORMAL
  GLU_NURBS_NORMAL_EXT
  GLU_NURBS_COLOR
  GLU_NURBS_COLOR_EXT
  GLU_NURBS_TEXTURE_COORD
  GLU_NURBS_TEX_COORD_EXT
  GLU_NURBS_END
  GLU_NURBS_END_EXT
  GLU_NURBS_BEGIN_DATA
  GLU_NURBS_BEGIN_DATA_EXT
  GLU_NURBS_VERTEX_DATA
  GLU_NURBS_VERTEX_DATA_EXT
  GLU_NURBS_NORMAL_DATA
  GLU_NURBS_NORMAL_DATA_EXT
  GLU_NURBS_COLOR_DATA
  GLU_NURBS_COLOR_DATA_EXT
  GLU_NURBS_TEXTURE_COORD_DATA
  GLU_NURBS_TEX_COORD_DATA_EXT
  GLU_NURBS_END_DATA
  GLU_NURBS_END_DATA_EXT
  GLU_NURBS_ERROR1
  GLU_NURBS_ERROR2
  GLU_NURBS_ERROR3
  GLU_NURBS_ERROR4
  GLU_NURBS_ERROR5
  GLU_NURBS_ERROR6
  GLU_NURBS_ERROR7
  GLU_NURBS_ERROR8
  GLU_NURBS_ERROR9
  GLU_NURBS_ERROR10
  GLU_NURBS_ERROR11
  GLU_NURBS_ERROR12
  GLU_NURBS_ERROR13
  GLU_NURBS_ERROR14
  GLU_NURBS_ERROR15
  GLU_NURBS_ERROR16
  GLU_NURBS_ERROR17
  GLU_NURBS_ERROR18
  GLU_NURBS_ERROR19
  GLU_NURBS_ERROR20
  GLU_NURBS_ERROR21
  GLU_NURBS_ERROR22
  GLU_NURBS_ERROR23
  GLU_NURBS_ERROR24
  GLU_NURBS_ERROR25
  GLU_NURBS_ERROR26
  GLU_NURBS_ERROR27
  GLU_NURBS_ERROR28
  GLU_NURBS_ERROR29
  GLU_NURBS_ERROR30
  GLU_NURBS_ERROR31
  GLU_NURBS_ERROR32
  GLU_NURBS_ERROR33
  GLU_NURBS_ERROR34
  GLU_NURBS_ERROR35
  GLU_NURBS_ERROR36
  GLU_NURBS_ERROR37
  GLU_AUTO_LOAD_MATRIX
  GLU_CULLING
  GLU_SAMPLING_TOLERANCE
  GLU_DISPLAY_MODE
  GLU_PARAMETRIC_TOLERANCE
  GLU_SAMPLING_METHOD
  GLU_U_STEP
  GLU_V_STEP
  GLU_NURBS_MODE
  GLU_NURBS_MODE_EXT
  GLU_NURBS_TESSELLATOR
  GLU_NURBS_TESSELLATOR_EXT
  GLU_NURBS_RENDERER
  GLU_NURBS_RENDERER_EXT
  GLU_OBJECT_PARAMETRIC_ERROR
  GLU_OBJECT_PARAMETRIC_ERROR_EXT
  GLU_OBJECT_PATH_LENGTH
  GLU_OBJECT_PATH_LENGTH_EXT
  GLU_PATH_LENGTH
  GLU_PARAMETRIC_ERROR
  GLU_DOMAIN_DISTANCE
  GLU_MAP1_TRIM_2
  GLU_MAP1_TRIM_3
  GLU_POINT
  GLU_LINE
  GLU_FILL
  GLU_SILHOUETTE
  GLU_SMOOTH
  GLU_FLAT
  GLU_NONE
  GLU_OUTSIDE
  GLU_INSIDE
  GLU_TESS_BEGIN
  GLU_BEGIN
  GLU_TESS_VERTEX
  GLU_VERTEX
  GLU_TESS_END
  GLU_END
  GLU_TESS_ERROR
  GLU_TESS_EDGE_FLAG
  GLU_EDGE_FLAG
  GLU_TESS_COMBINE
  GLU_TESS_BEGIN_DATA
  GLU_TESS_VERTEX_DATA
  GLU_TESS_END_DATA
  GLU_TESS_ERROR_DATA
  GLU_TESS_EDGE_FLAG_DATA
  GLU_TESS_COMBINE_DATA
  GLU_CW
  GLU_CCW
  GLU_INTERIOR
  GLU_EXTERIOR
  GLU_UNKNOWN
  GLU_TESS_WINDING_RULE
  GLU_TESS_BOUNDARY_ONLY
  GLU_TESS_TOLERANCE
  GLU_TESS_ERROR1
  GLU_TESS_ERROR2
  GLU_TESS_ERROR3
  GLU_TESS_ERROR4
  GLU_TESS_ERROR5
  GLU_TESS_ERROR6
  GLU_TESS_ERROR7
  GLU_TESS_ERROR8
  GLU_TESS_MISSING_BEGIN_POLYGON
  GLU_TESS_MISSING_BEGIN_CONTOUR
  GLU_TESS_MISSING_END_POLYGON
  GLU_TESS_MISSING_END_CONTOUR
  GLU_TESS_COORD_TOO_LARGE
  GLU_TESS_NEED_COMBINE_CALLBACK
  GLU_TESS_WINDING_ODD
  GLU_TESS_WINDING_NONZERO
  GLU_TESS_WINDING_POSITIVE
  GLU_TESS_WINDING_NEGATIVE
  GLU_TESS_WINDING_ABS_GEQ_TWO
  GLU_TESS_MAX_COORD

  gluBeginCurve
  gluBeginPolygon
  gluBeginSurface
  gluBeginTrim
  gluBuild1DMipmapLevels
  gluBuild1DMipmaps
  gluBuild2DMipmapLevels
  gluBuild2DMipmaps
  gluBuild3DMipmapLevels
  gluBuild3DMipmaps
  gluCheckExtension
  gluCylinder
  gluDeleteNurbsRenderer
  gluDeleteQuadric
  gluDeleteTess
  gluDisk
  gluEndCurve
  gluEndPolygon
  gluEndSurface
  gluEndTrim
  gluErrorString
  gluGetNurbsProperty
  gluGetString
  gluGetTessProperty
  gluLoadSamplingMatrices
  gluLookAt
  gluNewNurbsRenderer
  gluNewQuadric
  gluNewTess
  gluNextContour
  ;; gluNurbsCallback
  gluNurbsCallbackData
  gluNurbsCallbackDataEXT
  gluNurbsCurve
  gluNurbsProperty
  gluNurbsSurface
  gluOrtho2D
  gluPartialDisk
  gluPerspective
  gluPickMatrix
  gluProject
  gluPwlCurve
  gluQuadricCallback
  gluQuadricDrawStyle
  gluQuadricNormals
  gluQuadricOrientation
  gluQuadricTexture
  gluScaleImage
  gluSphere
  gluTessBeginContour
  gluTessBeginPolygon
  ;; gluTessCallback
  gluTessEndContour
  gluTessEndPolygon
  gluTessNormal
  gluTessProperty
  gluTessVertex
  gluUnProject
  gluUnProject4)

 (import (core)
         (ypsilon ffi)
         (ypsilon c-types)
         )

 (define libGLU (cond

                 (on-darwin  (load-shared-object "OpenGL.framework/OpenGL"))
                 ;; (on-windows (load-shared-object "opengl32.dll"))
                 (on-linux   (load-shared-object "libGLU.so.1"))
                 (on-freebsd (load-shared-object "libGLU.so"))
                 (on-openbsd (load-shared-object "libGLU.so.7.3"))
                 (else
                  (assertion-violation #f "can not locate OpenGL library, unknown operating system"))))

 (define GLU_EXT_object_space_tess 1)
 (define GLU_EXT_nurbs_tessellator 1)

                                        ;/* Boolean* /
 (define GLU_FALSE 0)
 (define GLU_TRUE 1)

                                        ;/* Version* /
 (define GLU_VERSION_1_1 1)
 (define GLU_VERSION_1_2 1)
 (define GLU_VERSION_1_3 1)

                                        ;/* StringName* /
 (define GLU_VERSION 100800)
 (define GLU_EXTENSIONS 100801)

                                        ;/* ErrorCode* /
 (define GLU_INVALID_ENUM 100900)
 (define GLU_INVALID_VALUE 100901)
 (define GLU_OUT_OF_MEMORY 100902)
 (define GLU_INCOMPATIBLE_GL_VERSION 100903)
 (define GLU_INVALID_OPERATION 100904)

 ;; /* NurbsDisplay* /
 ;; /*      GLU_FILL* /
 (define GLU_OUTLINE_POLYGON 100240)
 (define GLU_OUTLINE_PATCH 100241)

                                        ;/* NurbsCallback* /
 (define GLU_NURBS_ERROR 100103)
 (define GLU_ERROR 100103)
 (define GLU_NURBS_BEGIN 100164)
 (define GLU_NURBS_BEGIN_EXT 100164)
 (define GLU_NURBS_VERTEX 100165)
 (define GLU_NURBS_VERTEX_EXT 100165)
 (define GLU_NURBS_NORMAL 100166)
 (define GLU_NURBS_NORMAL_EXT 100166)
 (define GLU_NURBS_COLOR 100167)
 (define GLU_NURBS_COLOR_EXT 100167)
 (define GLU_NURBS_TEXTURE_COORD 100168)
 (define GLU_NURBS_TEX_COORD_EXT 100168)
 (define GLU_NURBS_END 100169)
 (define GLU_NURBS_END_EXT 100169)
 (define GLU_NURBS_BEGIN_DATA 100170)
 (define GLU_NURBS_BEGIN_DATA_EXT 100170)
 (define GLU_NURBS_VERTEX_DATA 100171)
 (define GLU_NURBS_VERTEX_DATA_EXT 100171)
 (define GLU_NURBS_NORMAL_DATA 100172)
 (define GLU_NURBS_NORMAL_DATA_EXT 100172)
 (define GLU_NURBS_COLOR_DATA 100173)
 (define GLU_NURBS_COLOR_DATA_EXT 100173)
 (define GLU_NURBS_TEXTURE_COORD_DATA 100174)
 (define GLU_NURBS_TEX_COORD_DATA_EXT 100174)
 (define GLU_NURBS_END_DATA 100175)
 (define GLU_NURBS_END_DATA_EXT 100175)

                                        ;/* NurbsError* /
 (define GLU_NURBS_ERROR1 100251)
 (define GLU_NURBS_ERROR2 100252)
 (define GLU_NURBS_ERROR3 100253)
 (define GLU_NURBS_ERROR4 100254)
 (define GLU_NURBS_ERROR5 100255)
 (define GLU_NURBS_ERROR6 100256)
 (define GLU_NURBS_ERROR7 100257)
 (define GLU_NURBS_ERROR8 100258)
 (define GLU_NURBS_ERROR9 100259)
 (define GLU_NURBS_ERROR10 100260)
 (define GLU_NURBS_ERROR11 100261)
 (define GLU_NURBS_ERROR12 100262)
 (define GLU_NURBS_ERROR13 100263)
 (define GLU_NURBS_ERROR14 100264)
 (define GLU_NURBS_ERROR15 100265)
 (define GLU_NURBS_ERROR16 100266)
 (define GLU_NURBS_ERROR17 100267)
 (define GLU_NURBS_ERROR18 100268)
 (define GLU_NURBS_ERROR19 100269)
 (define GLU_NURBS_ERROR20 100270)
 (define GLU_NURBS_ERROR21 100271)
 (define GLU_NURBS_ERROR22 100272)
 (define GLU_NURBS_ERROR23 100273)
 (define GLU_NURBS_ERROR24 100274)
 (define GLU_NURBS_ERROR25 100275)
 (define GLU_NURBS_ERROR26 100276)
 (define GLU_NURBS_ERROR27 100277)
 (define GLU_NURBS_ERROR28 100278)
 (define GLU_NURBS_ERROR29 100279)
 (define GLU_NURBS_ERROR30 100280)
 (define GLU_NURBS_ERROR31 100281)
 (define GLU_NURBS_ERROR32 100282)
 (define GLU_NURBS_ERROR33 100283)
 (define GLU_NURBS_ERROR34 100284)
 (define GLU_NURBS_ERROR35 100285)
 (define GLU_NURBS_ERROR36 100286)
 (define GLU_NURBS_ERROR37 100287)

                                        ;/* NurbsProperty* /
 (define GLU_AUTO_LOAD_MATRIX 100200)
 (define GLU_CULLING 100201)
 (define GLU_SAMPLING_TOLERANCE 100203)
 (define GLU_DISPLAY_MODE 100204)
 (define GLU_PARAMETRIC_TOLERANCE 100202)
 (define GLU_SAMPLING_METHOD 100205)
 (define GLU_U_STEP 100206)
 (define GLU_V_STEP 100207)
 (define GLU_NURBS_MODE 100160)
 (define GLU_NURBS_MODE_EXT 100160)
 (define GLU_NURBS_TESSELLATOR 100161)
 (define GLU_NURBS_TESSELLATOR_EXT 100161)
 (define GLU_NURBS_RENDERER 100162)
 (define GLU_NURBS_RENDERER_EXT 100162)

                                        ;/* NurbsSampling* /
 (define GLU_OBJECT_PARAMETRIC_ERROR 100208)
 (define GLU_OBJECT_PARAMETRIC_ERROR_EXT 100208)
 (define GLU_OBJECT_PATH_LENGTH 100209)
 (define GLU_OBJECT_PATH_LENGTH_EXT 100209)
 (define GLU_PATH_LENGTH 100215)
 (define GLU_PARAMETRIC_ERROR 100216)
 (define GLU_DOMAIN_DISTANCE 100217)

                                        ;/* NurbsTrim* /
 (define GLU_MAP1_TRIM_2 100210)
 (define GLU_MAP1_TRIM_3 100211)

                                        ;/* QuadricDrawStyle* /
 (define GLU_POINT 100010)
 (define GLU_LINE 100011)
 (define GLU_FILL 100012)
 (define GLU_SILHOUETTE 100013)

 ;; /* QuadricCallback* /
 ;; /*      GLU_ERROR* /

                                        ;/* QuadricNormal* /
 (define GLU_SMOOTH 100000)
 (define GLU_FLAT 100001)
 (define GLU_NONE 100002)

                                        ;/* QuadricOrientation* /
 (define GLU_OUTSIDE 100020)
 (define GLU_INSIDE 100021)

                                        ;/* TessCallback* /
 (define GLU_TESS_BEGIN 100100)
 (define GLU_BEGIN 100100)
 (define GLU_TESS_VERTEX 100101)
 (define GLU_VERTEX 100101)
 (define GLU_TESS_END 100102)
 (define GLU_END 100102)
 (define GLU_TESS_ERROR 100103)
 (define GLU_TESS_EDGE_FLAG 100104)
 (define GLU_EDGE_FLAG 100104)
 (define GLU_TESS_COMBINE 100105)
 (define GLU_TESS_BEGIN_DATA 100106)
 (define GLU_TESS_VERTEX_DATA 100107)
 (define GLU_TESS_END_DATA 100108)
 (define GLU_TESS_ERROR_DATA 100109)
 (define GLU_TESS_EDGE_FLAG_DATA 100110)
 (define GLU_TESS_COMBINE_DATA 100111)

                                        ;/* TessContour* /
 (define GLU_CW 100120)
 (define GLU_CCW 100121)
 (define GLU_INTERIOR 100122)
 (define GLU_EXTERIOR 100123)
 (define GLU_UNKNOWN 100124)

                                        ;/* TessProperty* /
 (define GLU_TESS_WINDING_RULE 100140)
 (define GLU_TESS_BOUNDARY_ONLY 100141)
 (define GLU_TESS_TOLERANCE 100142)

                                        ;/* TessError* /
 (define GLU_TESS_ERROR1 100151)
 (define GLU_TESS_ERROR2 100152)
 (define GLU_TESS_ERROR3 100153)
 (define GLU_TESS_ERROR4 100154)
 (define GLU_TESS_ERROR5 100155)
 (define GLU_TESS_ERROR6 100156)
 (define GLU_TESS_ERROR7 100157)
 (define GLU_TESS_ERROR8 100158)
 (define GLU_TESS_MISSING_BEGIN_POLYGON 100151)
 (define GLU_TESS_MISSING_BEGIN_CONTOUR 100152)
 (define GLU_TESS_MISSING_END_POLYGON 100153)
 (define GLU_TESS_MISSING_END_CONTOUR 100154)
 (define GLU_TESS_COORD_TOO_LARGE 100155)
 (define GLU_TESS_NEED_COMBINE_CALLBACK 100156)

                                        ;/* TessWinding* /
 (define GLU_TESS_WINDING_ODD 100130)
 (define GLU_TESS_WINDING_NONZERO 100131)
 (define GLU_TESS_WINDING_POSITIVE 100132)
 (define GLU_TESS_WINDING_NEGATIVE 100133)
 (define GLU_TESS_WINDING_ABS_GEQ_TWO 100134)


 (define GLU_TESS_MAX_COORD 1e150)

 (define-syntax define-function
   (syntax-rules ()
     ((_ ret name args)
      (define name (c-function libGLU "GLU library" ret __stdcall name args)))))
 
 (define-function void gluBeginCurve (void*))
 (define-function void gluBeginPolygon (void*))
 (define-function void gluBeginSurface (void*))
 (define-function void gluBeginTrim (void*))
 (define-function int gluBuild1DMipmapLevels (int int int int int int int int void*))
 (define-function int gluBuild1DMipmaps (int int int int int void*))
 (define-function int gluBuild2DMipmapLevels (int int int int int int int int int void*))
 (define-function int gluBuild2DMipmaps (int int int int int int void*))
 (define-function int gluBuild3DMipmapLevels (int int int int int int int int int int void*))
 (define-function int gluBuild3DMipmaps (int int int int int int int void*))
 (define-function int gluCheckExtension (void* void*))
 (define-function void gluCylinder (void* double double double int int))
 (define-function void gluDeleteNurbsRenderer (void*))
 (define-function void gluDeleteQuadric (void*))
 (define-function void gluDeleteTess (void*))
 (define-function void gluDisk (void* double double int int))
 (define-function void gluEndCurve (void*))
 (define-function void gluEndPolygon (void*))
 (define-function void gluEndSurface (void*))
 (define-function void gluEndTrim (void*))
 (define-function void* gluErrorString (int))
 (define-function void gluGetNurbsProperty (void* int void*))
 (define-function void* gluGetString (int))
 (define-function void gluGetTessProperty (void* int void*))
 (define-function void gluLoadSamplingMatrices (void* void* void* void*))
 (define-function void gluLookAt (double double double double double double double double double))
 (define-function void* gluNewNurbsRenderer ())
 (define-function void* gluNewQuadric ())
 (define-function void* gluNewTess ())
 (define-function void gluNextContour (void* int))
 ;; (define-function void gluNurbsCallback (void* int _GLUfuncptr))
 (define-function void gluNurbsCallbackData (void* void*))
 (define-function void gluNurbsCallbackDataEXT (void* void*))
 (define-function void gluNurbsCurve (void* int void* int void* int int))
 (define-function void gluNurbsProperty (void* int float))
 (define-function void gluNurbsSurface (void* int void* int void* int int void* int int int))
 (define-function void gluOrtho2D (double double double double))
 (define-function void gluPartialDisk (void* double double int int double double))
 (define-function void gluPerspective (double double double double))
 (define-function void gluPickMatrix (double double double double void*))
 (define-function int gluProject (double double double void* void* void* void* void* void*))
 (define-function void gluPwlCurve (void* int void* int int))

 ;; (define-function void gluQuadricCallback (void* int _GLUfuncptr))

 (define-function void gluQuadricCallback (void* int (c-callback void (int))))
 
 (define-function void gluQuadricDrawStyle (void* int))
 (define-function void gluQuadricNormals (void* int))
 (define-function void gluQuadricOrientation (void* int))
 (define-function void gluQuadricTexture (void* int))
 (define-function int gluScaleImage (int int int int void* int int int void*))
 (define-function void gluSphere (void* double int int))
 (define-function void gluTessBeginContour (void*))
 (define-function void gluTessBeginPolygon (void* void*))

 ;; (define-function void gluTessCallback (void* int _GLUfuncptr))

 (define-function void gluTessEndContour (void*))
 (define-function void gluTessEndPolygon (void*))
 (define-function void gluTessNormal (void* double double double))
 (define-function void gluTessProperty (void* int double))
 (define-function void gluTessVertex (void* void* void*))
 (define-function int gluUnProject (double double double void* void* void* void* void* void*))
 (define-function int gluUnProject4 (double double double double void* void* void* double double void* void* void* void*))

 )