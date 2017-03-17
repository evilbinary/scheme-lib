
;;; Ypsilon Scheme System
;;; Copyright (c) 2004-2009 Y.FUJITA / LittleWing Company Limited.
;;; See license.txt for terms and conditions of use.

;;; Ported to Chez Scheme by Ed Cavazos (wayo.cavazos@gmail.com)

(library (agave glu compat)

  (export GLU_EXT_object_space_tess
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

          ;; gluQuadricCallback

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

  (import (chezscheme))

  (define lib-name
     (case (machine-type)
        ((i3osx ti3osx)    "OpenGL.framework/OpenGL")  ; OSX x86
        ((a6osx ta6osx)    "OpenGL.framework/OpenGL")  ; OSX x86_64
        ((i3nt ti3nt)      "glu32.dll")                ; Windows x86
        ((a6nt ta6nt)      "glu64.dll")                ; Windows x86_64
        ((i3le ti3le)      "libGLU.so.1")              ; Linux x86
        ((a6le ta6le)      "libGLU.so.1")              ; Linux x86_64
        ((i3ob ti3ob)      "libGLU.so.7.0")            ; OpenBSD x86
        ((a6ob ta6ob)      "libGLU.so.7.0")            ; OpenBSD x86_64
        ((i3fb ti3fb)      "libGLU.so")                ; FreeBSD x86
        ((a6fb ta6fb)      "libGLU.so")                ; FreeBSD x86_64
        ((i3s2 ti3s2)      "libGLU.so.1")              ; Solaris x86
        ((a6s2 ta6s2)      "libGLU.so.1")              ; Solaris x86_64
           (else
            (assertion-violation #f "can not locate OpenGL library, unknown operating system"))))

  (define lib (load-shared-object lib-name))

  ;; (define-syntax define-function
  ;;   (syntax-rules ()
  ;;     ((_ ret name args)
  ;;      (define name (c-function lib lib-name ret __stdcall name args)))))

  (define-syntax define-function
    (syntax-rules ()
      ((_ ret name args)
       (define name
         (foreign-procedure (symbol->string 'name) args ret)))))

  ;;;; Extensions
  (define GLU_EXT_object_space_tess          1)
  (define GLU_EXT_nurbs_tessellator          1)
  ;;;; Boolean
  (define GLU_FALSE                          0)
  (define GLU_TRUE                           1)
  ;;;; Version
  (define GLU_VERSION_1_1                    1)
  (define GLU_VERSION_1_2                    1)
  (define GLU_VERSION_1_3                    1)
  ;;;; StringName
  (define GLU_VERSION                        100800)
  (define GLU_EXTENSIONS                     100801)
  ;;;; ErrorCode
  (define GLU_INVALID_ENUM                   100900)
  (define GLU_INVALID_VALUE                  100901)
  (define GLU_OUT_OF_MEMORY                  100902)
  (define GLU_INCOMPATIBLE_GL_VERSION        100903)
  (define GLU_INVALID_OPERATION              100904)
  ;;;; NurbsDisplay
  ;;;;    GLU_FILL
  (define GLU_OUTLINE_POLYGON                100240)
  (define GLU_OUTLINE_PATCH                  100241)
  ;;;; NurbsCallback
  (define GLU_NURBS_ERROR                    100103)
  (define GLU_ERROR                          100103)
  (define GLU_NURBS_BEGIN                    100164)
  (define GLU_NURBS_BEGIN_EXT                100164)
  (define GLU_NURBS_VERTEX                   100165)
  (define GLU_NURBS_VERTEX_EXT               100165)
  (define GLU_NURBS_NORMAL                   100166)
  (define GLU_NURBS_NORMAL_EXT               100166)
  (define GLU_NURBS_COLOR                    100167)
  (define GLU_NURBS_COLOR_EXT                100167)
  (define GLU_NURBS_TEXTURE_COORD            100168)
  (define GLU_NURBS_TEX_COORD_EXT            100168)
  (define GLU_NURBS_END                      100169)
  (define GLU_NURBS_END_EXT                  100169)
  (define GLU_NURBS_BEGIN_DATA               100170)
  (define GLU_NURBS_BEGIN_DATA_EXT           100170)
  (define GLU_NURBS_VERTEX_DATA              100171)
  (define GLU_NURBS_VERTEX_DATA_EXT          100171)
  (define GLU_NURBS_NORMAL_DATA              100172)
  (define GLU_NURBS_NORMAL_DATA_EXT          100172)
  (define GLU_NURBS_COLOR_DATA               100173)
  (define GLU_NURBS_COLOR_DATA_EXT           100173)
  (define GLU_NURBS_TEXTURE_COORD_DATA       100174)
  (define GLU_NURBS_TEX_COORD_DATA_EXT       100174)
  (define GLU_NURBS_END_DATA                 100175)
  (define GLU_NURBS_END_DATA_EXT             100175)
  ;;;; NurbsError
  (define GLU_NURBS_ERROR1                   100251)
  (define GLU_NURBS_ERROR2                   100252)
  (define GLU_NURBS_ERROR3                   100253)
  (define GLU_NURBS_ERROR4                   100254)
  (define GLU_NURBS_ERROR5                   100255)
  (define GLU_NURBS_ERROR6                   100256)
  (define GLU_NURBS_ERROR7                   100257)
  (define GLU_NURBS_ERROR8                   100258)
  (define GLU_NURBS_ERROR9                   100259)
  (define GLU_NURBS_ERROR10                  100260)
  (define GLU_NURBS_ERROR11                  100261)
  (define GLU_NURBS_ERROR12                  100262)
  (define GLU_NURBS_ERROR13                  100263)
  (define GLU_NURBS_ERROR14                  100264)
  (define GLU_NURBS_ERROR15                  100265)
  (define GLU_NURBS_ERROR16                  100266)
  (define GLU_NURBS_ERROR17                  100267)
  (define GLU_NURBS_ERROR18                  100268)
  (define GLU_NURBS_ERROR19                  100269)
  (define GLU_NURBS_ERROR20                  100270)
  (define GLU_NURBS_ERROR21                  100271)
  (define GLU_NURBS_ERROR22                  100272)
  (define GLU_NURBS_ERROR23                  100273)
  (define GLU_NURBS_ERROR24                  100274)
  (define GLU_NURBS_ERROR25                  100275)
  (define GLU_NURBS_ERROR26                  100276)
  (define GLU_NURBS_ERROR27                  100277)
  (define GLU_NURBS_ERROR28                  100278)
  (define GLU_NURBS_ERROR29                  100279)
  (define GLU_NURBS_ERROR30                  100280)
  (define GLU_NURBS_ERROR31                  100281)
  (define GLU_NURBS_ERROR32                  100282)
  (define GLU_NURBS_ERROR33                  100283)
  (define GLU_NURBS_ERROR34                  100284)
  (define GLU_NURBS_ERROR35                  100285)
  (define GLU_NURBS_ERROR36                  100286)
  (define GLU_NURBS_ERROR37                  100287)
  ;;;; NurbsProperty
  (define GLU_AUTO_LOAD_MATRIX               100200)
  (define GLU_CULLING                        100201)
  (define GLU_SAMPLING_TOLERANCE             100203)
  (define GLU_DISPLAY_MODE                   100204)
  (define GLU_PARAMETRIC_TOLERANCE           100202)
  (define GLU_SAMPLING_METHOD                100205)
  (define GLU_U_STEP                         100206)
  (define GLU_V_STEP                         100207)
  (define GLU_NURBS_MODE                     100160)
  (define GLU_NURBS_MODE_EXT                 100160)
  (define GLU_NURBS_TESSELLATOR              100161)
  (define GLU_NURBS_TESSELLATOR_EXT          100161)
  (define GLU_NURBS_RENDERER                 100162)
  (define GLU_NURBS_RENDERER_EXT             100162)
  ;;;; NurbsSampling
  (define GLU_OBJECT_PARAMETRIC_ERROR        100208)
  (define GLU_OBJECT_PARAMETRIC_ERROR_EXT    100208)
  (define GLU_OBJECT_PATH_LENGTH             100209)
  (define GLU_OBJECT_PATH_LENGTH_EXT         100209)
  (define GLU_PATH_LENGTH                    100215)
  (define GLU_PARAMETRIC_ERROR               100216)
  (define GLU_DOMAIN_DISTANCE                100217)
  ;;;; NurbsTrim
  (define GLU_MAP1_TRIM_2                    100210)
  (define GLU_MAP1_TRIM_3                    100211)
  ;;;; QuadricDrawStyle
  (define GLU_POINT                          100010)
  (define GLU_LINE                           100011)
  (define GLU_FILL                           100012)
  (define GLU_SILHOUETTE                     100013)
  ;;;; QuadricCallback
  ;;;;    GLU_ERROR
  ;;;; QuadricNormal
  (define GLU_SMOOTH                         100000)
  (define GLU_FLAT                           100001)
  (define GLU_NONE                           100002)
  ;;;; QuadricOrientation
  (define GLU_OUTSIDE                        100020)
  (define GLU_INSIDE                         100021)
  ;;;; TessCallback
  (define GLU_TESS_BEGIN                     100100)
  (define GLU_BEGIN                          100100)
  (define GLU_TESS_VERTEX                    100101)
  (define GLU_VERTEX                         100101)
  (define GLU_TESS_END                       100102)
  (define GLU_END                            100102)
  (define GLU_TESS_ERROR                     100103)
  (define GLU_TESS_EDGE_FLAG                 100104)
  (define GLU_EDGE_FLAG                      100104)
  (define GLU_TESS_COMBINE                   100105)
  (define GLU_TESS_BEGIN_DATA                100106)
  (define GLU_TESS_VERTEX_DATA               100107)
  (define GLU_TESS_END_DATA                  100108)
  (define GLU_TESS_ERROR_DATA                100109)
  (define GLU_TESS_EDGE_FLAG_DATA            100110)
  (define GLU_TESS_COMBINE_DATA              100111)
  ;;;; TessContour
  (define GLU_CW                             100120)
  (define GLU_CCW                            100121)
  (define GLU_INTERIOR                       100122)
  (define GLU_EXTERIOR                       100123)
  (define GLU_UNKNOWN                        100124)
  ;;;; TessProperty
  (define GLU_TESS_WINDING_RULE              100140)
  (define GLU_TESS_BOUNDARY_ONLY             100141)
  (define GLU_TESS_TOLERANCE                 100142)
  ;;;; TessError
  (define GLU_TESS_ERROR1                    100151)
  (define GLU_TESS_ERROR2                    100152)
  (define GLU_TESS_ERROR3                    100153)
  (define GLU_TESS_ERROR4                    100154)
  (define GLU_TESS_ERROR5                    100155)
  (define GLU_TESS_ERROR6                    100156)
  (define GLU_TESS_ERROR7                    100157)
  (define GLU_TESS_ERROR8                    100158)
  (define GLU_TESS_MISSING_BEGIN_POLYGON     100151)
  (define GLU_TESS_MISSING_BEGIN_CONTOUR     100152)
  (define GLU_TESS_MISSING_END_POLYGON       100153)
  (define GLU_TESS_MISSING_END_CONTOUR       100154)
  (define GLU_TESS_COORD_TOO_LARGE           100155)
  (define GLU_TESS_NEED_COMBINE_CALLBACK     100156)
  ;;;; TessWinding
  (define GLU_TESS_WINDING_ODD               100130)
  (define GLU_TESS_WINDING_NONZERO           100131)
  (define GLU_TESS_WINDING_POSITIVE          100132)
  (define GLU_TESS_WINDING_NEGATIVE          100133)
  (define GLU_TESS_WINDING_ABS_GEQ_TWO       100134)
  (define GLU_TESS_MAX_COORD                 1.0e150)

  ;; void gluBeginCurve (GLUnurbs* nurb)
  (define-function void gluBeginCurve (void*))

  ;; void gluBeginPolygon (GLUtesselator* tess)
  (define-function void gluBeginPolygon (void*))

  ;; void gluBeginSurface (GLUnurbs* nurb)
  (define-function void gluBeginSurface (void*))

  ;; void gluBeginTrim (GLUnurbs* nurb)
  (define-function void gluBeginTrim (void*))

  ;; GLint gluBuild1DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void* data)
  (define-function int gluBuild1DMipmapLevels (unsigned-int int int unsigned-int unsigned-int int int int void*))

  ;; GLint gluBuild1DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, const void* data)
  (define-function int gluBuild1DMipmaps (unsigned-int int int unsigned-int unsigned-int void*))

  ;; GLint gluBuild2DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void* data)
  (define-function int gluBuild2DMipmapLevels (unsigned-int int int int unsigned-int unsigned-int int int int void*))

  ;; GLint gluBuild2DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, const void* data)
  (define-function int gluBuild2DMipmaps (unsigned-int int int int unsigned-int unsigned-int void*))

  ;; GLint gluBuild3DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void* data)
  (define-function int gluBuild3DMipmapLevels (unsigned-int int int int int unsigned-int unsigned-int int int int void*))

  ;; GLint gluBuild3DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* data)
  (define-function int gluBuild3DMipmaps (unsigned-int int int int int unsigned-int unsigned-int void*))

  ;; GLboolean gluCheckExtension (const GLubyte* extName, const GLubyte* extString)

  (define-function unsigned-8 gluCheckExtension (void* void*))

  ;; void gluCylinder (GLUquadric* quad, GLdouble base, GLdouble top, GLdouble height, GLint slices, GLint stacks)
  (define-function void gluCylinder (void* double double double int int))

  ;; void gluDeleteNurbsRenderer (GLUnurbs* nurb)
  (define-function void gluDeleteNurbsRenderer (void*))

  ;; void gluDeleteQuadric (GLUquadric* quad)
  (define-function void gluDeleteQuadric (void*))

  ;; void gluDeleteTess (GLUtesselator* tess)
  (define-function void gluDeleteTess (void*))

  ;; void gluDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops)
  (define-function void gluDisk (void* double double int int))

  ;; void gluEndCurve (GLUnurbs* nurb)
  (define-function void gluEndCurve (void*))

  ;; void gluEndPolygon (GLUtesselator* tess)
  (define-function void gluEndPolygon (void*))

  ;; void gluEndSurface (GLUnurbs* nurb)
  (define-function void gluEndSurface (void*))

  ;; void gluEndTrim (GLUnurbs* nurb)
  (define-function void gluEndTrim (void*))

  ;; const GLubyte* gluErrorString (GLenum error)
  (define-function void* gluErrorString (unsigned-int))

  ;; void gluGetNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat* data)
  (define-function void gluGetNurbsProperty (void* unsigned-int void*))

  ;; const GLubyte* gluGetString (GLenum name)
  (define-function void* gluGetString (unsigned-int))

  ;; void gluGetTessProperty (GLUtesselator* tess, GLenum which, GLdouble* data)
  (define-function void gluGetTessProperty (void* unsigned-int void*))

  ;; void gluLoadSamplingMatrices (GLUnurbs* nurb, const GLfloat* model, const GLfloat* perspective, const GLint* view)
  (define-function void gluLoadSamplingMatrices (void* void* void* void*))

  ;; void gluLookAt (GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ)
  (define-function void gluLookAt (double double double double double double double double double))

  ;; GLUnurbs* gluNewNurbsRenderer (void)
  (define-function void* gluNewNurbsRenderer ())

  ;; GLUquadric* gluNewQuadric (void)
  (define-function void* gluNewQuadric ())

  ;; GLUtesselator* gluNewTess (void)
  (define-function void* gluNewTess ())

  ;; void gluNextContour (GLUtesselator* tess, GLenum type)
  (define-function void gluNextContour (void* unsigned-int))

  ;; void gluNurbsCallbackData (GLUnurbs* nurb, GLvoid* userData)
  (define-function void gluNurbsCallbackData (void* void*))

  ;; void gluNurbsCallbackDataEXT (GLUnurbs* nurb, GLvoid* userData)
  (define-function void gluNurbsCallbackDataEXT (void* void*))

  ;; void gluNurbsCurve (GLUnurbs* nurb, GLint knotCount, GLfloat* knots, GLint stride, GLfloat* control, GLint order, GLenum type)
  (define-function void gluNurbsCurve (void* int void* int void* int unsigned-int))

  ;; void gluNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat value)
  (define-function void gluNurbsProperty (void* unsigned-int float))

  ;; void gluNurbsSurface (GLUnurbs* nurb, GLint sKnotCount, GLfloat* sKnots, GLint tKnotCount, GLfloat* tKnots, GLint sStride, GLint tStride, GLfloat* control, GLint sOrder, GLint tOrder, GLenum type)
  (define-function void gluNurbsSurface (void* int void* int void* int int void* int int unsigned-int))

  ;; void gluOrtho2D (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top)
  (define-function void gluOrtho2D (double double double double))

  ;; void gluPartialDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops, GLdouble start, GLdouble sweep)
  (define-function void gluPartialDisk (void* double double int int double double))

  ;; void gluPerspective (GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar)
  (define-function void gluPerspective (double double double double))

  ;; void gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, GLint *viewport)
  (define-function void gluPickMatrix (double double double double int))

  ;; GLint gluProject (GLdouble objX, GLdouble objY, GLdouble objZ, const GLdouble* model, const GLdouble* proj, const GLint *view, GLdouble* winX, GLdouble* winY, GLdouble* winZ)
  (define-function int gluProject (double double double void* void* int void* void* void*))

  ;; void gluPwlCurve (GLUnurbs* nurb, GLint count, GLfloat* data, GLint stride, GLenum type)
  (define-function void gluPwlCurve (void* int void* int unsigned-int))

  ;; void gluQuadricDrawStyle (GLUquadric* quad, GLenum draw)
  (define-function void gluQuadricDrawStyle (void* unsigned-int))

  ;; void gluQuadricNormals (GLUquadric* quad, GLenum normal)
  (define-function void gluQuadricNormals (void* unsigned-int))

  ;; void gluQuadricOrientation (GLUquadric* quad, GLenum orientation)
  (define-function void gluQuadricOrientation (void* unsigned-int))

  ;; void gluQuadricTexture (GLUquadric* quad, GLboolean texture)
  (define-function void gluQuadricTexture (void* unsigned-8))

  ;; GLint gluScaleImage (GLenum format, GLsizei wIn, GLsizei hIn, GLenum typeIn, const void* dataIn, GLsizei wOut, GLsizei hOut, GLenum typeOut, GLvoid* dataOut)
  (define-function int gluScaleImage (unsigned-int int int unsigned-int void* int int unsigned-int void*))

  ;; void gluSphere (GLUquadric* quad, GLdouble radius, GLint slices, GLint stacks)
  (define-function void gluSphere (void* double int int))

  ;; void gluTessBeginContour (GLUtesselator* tess)
  (define-function void gluTessBeginContour (void*))

  ;; void gluTessBeginPolygon (GLUtesselator* tess, GLvoid* data)
  (define-function void gluTessBeginPolygon (void* void*))

  ;; void gluTessEndContour (GLUtesselator* tess)
  (define-function void gluTessEndContour (void*))

  ;; void gluTessEndPolygon (GLUtesselator* tess)
  (define-function void gluTessEndPolygon (void*))

  ;; void gluTessNormal (GLUtesselator* tess, GLdouble valueX, GLdouble valueY, GLdouble valueZ)
  (define-function void gluTessNormal (void* double double double))

  ;; void gluTessProperty (GLUtesselator* tess, GLenum which, GLdouble data)
  (define-function void gluTessProperty (void* unsigned-int double))

  ;; void gluTessVertex (GLUtesselator* tess, GLdouble* location, GLvoid* data)
  (define-function void gluTessVertex (void* void* void*))

  ;; GLint gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ, const GLdouble* model, const GLdouble* proj, const GLint *view, GLdouble* objX, GLdouble* objY, GLdouble* objZ)
  (define-function int gluUnProject (double double double void* void* int void* void* void*))

  ;; GLint gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, const GLdouble* model, const GLdouble* proj, const GLint *view, GLdouble nearVal, GLdouble farVal, GLdouble* objX, GLdouble* objY, GLdouble* objZ, GLdouble* objW)
  (define-function int gluUnProject4 (double double double double void* void* int double double void* void* void* void*))

  ;; void gluNurbsCallback (GLUnurbs* nurb, GLenum which, _GLUfuncptr CallBackFunc)

  ;; (define gluNurbsCallback
  ;;   (let ((thunk (c-function lib lib-name void __stdcall gluNurbsCallback (void* unsigned-int void*)))
  ;;         (alist `((,GLU_NURBS_BEGIN int)
  ;;                  (,GLU_NURBS_VERTEX float)
  ;;                  (,GLU_NURBS_NORMAL float)
  ;;                  (,GLU_NURBS_COLOR float)
  ;;                  (,GLU_NURBS_TEXTURE_COORD float)
  ;;                  (,GLU_NURBS_END)
  ;;                  (,GLU_NURBS_BEGIN_DATA int void*)
  ;;                  (,GLU_NURBS_VERTEX_DATA float void*)
  ;;                  (,GLU_NURBS_NORMAL_DATA float void*)
  ;;                  (,GLU_NURBS_COLOR_DATA float void*)
  ;;                  (,GLU_NURBS_TEXTURE_COORD_DATA float void*)
  ;;                  (,GLU_NURBS_END_DATA void*)
  ;;                  (,GLU_NURBS_ERROR int))))
  ;;     (lambda (nurb which callback)
  ;;       (if (procedure? callback)
  ;;           (let ((lst (assv which alist)))
  ;;             (or lst (assertion-violation 'gluNurbsCallback "invalid value in argument 2" (list nurb which callback)))
  ;;             (thunk nurb which (make-stdcall-callback 'void (cdr lst) callback)))
  ;;           (thunk nurb which callback)))))

  ;; void gluQuadricCallback (GLUquadric* quad, GLenum which, _GLUfuncptr CallBackFunc)

  ;; (define gluQuadricCallback
  ;;   (let ((thunk (c-function lib lib-name void __stdcall gluQuadricCallback (void* unsigned-int void*))))
  ;;     (lambda (quad which callback)
  ;;       (or (eqv? which GLU_ERROR)
  ;;           (assertion-violation 'gluQuadricCallback "invalid value in argument 2" (list quad which callback)))
  ;;       (if (procedure? callback)
  ;;           (thunk quad which (make-stdcall-callback 'void '(unsigned-int) callback))
  ;;           (thunk quad which callback)))))

  ;; void gluTessCallback (GLUtesselator* tess, GLenum which, _GLUfuncptr CallBackFunc)
  ;; (define gluTessCallback
  ;;   (let ((thunk (c-function lib lib-name void __stdcall gluTessCallback (void* unsigned-int void*)))
  ;;         (alist `((,GLU_TESS_BEGIN unsigned-int)
  ;;                  (,GLU_TESS_BEGIN_DATA unsigned-int void*)
  ;;                  (,GLU_TESS_EDGE_FLAG uint8_t)
  ;;                  (,GLU_TESS_EDGE_FLAG_DATA uint8_t void*)
  ;;                  (,GLU_TESS_VERTEX void*)
  ;;                  (,GLU_TESS_VERTEX_DATA void* void*)
  ;;                  (,GLU_TESS_END)
  ;;                  (,GLU_TESS_END_DATA void*)
  ;;                  (,GLU_TESS_COMBINE void* void* void* void*)
  ;;                  (,GLU_TESS_COMBINE_DATA void* void* void* void* void*)
  ;;                  (,GLU_TESS_ERROR unsigned-int)
  ;;                  (,GLU_TESS_ERROR_DATA unsigned-int void*))))
  ;;     (lambda (tess which callback)
  ;;       (if (procedure? callback)
  ;;           (let ((lst (assv which alist)))
  ;;             (or lst (assertion-violation 'gluTessCallback "invalid value in argument 2" (list tess which callback)))
  ;;             (thunk tess which (make-stdcall-callback 'void (cdr lst) callback)))
  ;;           (thunk tess which callback)))))

  ) ;[end]
