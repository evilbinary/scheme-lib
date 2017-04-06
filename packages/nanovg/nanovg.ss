;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (nanovg nanovg)
    (export
        nvg-create-gles2 
        nvg-delete-gles2

	nvg-create-gles222
	nvg-create-gles22
        
        nvg-begin-frame
        nvg-cancel-frame
        nvg-end-frame
        nvg-global-composite-operation
        nvg-global-composite-blend-func
        nvg-global-composite-blend-func-separate
        nvg-rgb
        nvg-rgbf
        nvg-rgba
        nvg-rgbaf
        nvg-lerp-rgba
        nvg-trans-rgba
        nvg-trans-rgbaf
        nvg-h-s-l
        nvg-hsla
        nvg-save
        nvg-restore
        nvg-reset
        nvg-stroke-color
        nvg-stroke-paint
        nvg-fill-color
        nvg-fill-paint
        nvg-miter-limit
        nvg-stroke-width
        nvg-line-cap
        nvg-line-join
        nvg-global-alpha
        nvg-reset-transform
        nvg-transform
        nvg-translate
        nvg-rotate
        nvg-skew-x
        nvg-skew-y
        nvg-scale
        nvg-current-transform
        nvg-transform-identity
        nvg-transform-translate
        nvg-transform-scale
        nvg-transform-rotate
        nvg-transform-skew-x
        nvg-transform-skew-y
        nvg-transform-multiply
        nvg-transform-premultiply
        nvg-transform-inverse
        nvg-transform-point
        nvg-deg-to-rad
        nvg-rad-to-deg
        nvg-create-image
        nvg-create-image-mem
        nvg-create-image-rgba
        nvg-update-image
        nvg-image-size
        nvg-delete-image
        nvg-linear-gradient
        nvg-box-gradient
        nvg-radial-gradient
        nvg-image-pattern
        nvg-scissor
        nvg-intersect-scissor
        nvg-reset-scissor
        nvg-begin-path
        nvg-move-to
        nvg-line-to
        nvg-bezier-to
        nvg-quad-to
        nvg-arc-to
        nvg-close-path
        nvg-path-winding
        nvg-arc
        nvg-rect
        nvg-rounded-rect
        nvg-rounded-rect-varying
        nvg-ellipse
        nvg-circle
        nvg-fill
        nvg-stroke
        nvg-create-font
        nvg-create-font-mem
        nvg-find-font
        nvg-add-fallback-font-id
        nvg-add-fallback-font
        nvg-font-size
        nvg-font-blur
        nvg-text-letter-spacing
        nvg-text-line-height
        nvg-text-align
        nvg-font-face-id
        nvg-font-face
        nvg-text
        nvg-text-box
        nvg-text-bounds
        nvg-text-box-bounds
        nvg-text-glyph-positions
        nvg-text-metrics
        nvg-text-break-lines

        make-array6
        make-array2

        make-NVGcolor

        NVGcolor-r
        NVGcolor-g
        NVGcolor-b
        NVGcolor-a

        NVGcolor-type
        NVGcolor-size
        make-NVGpaint
        NVGpaint-type
        NVGpaint-size


        NVG_ANTIALIAS
        NVG_STENCIL_STROKES
        NVG_DEBUG
        NVG_SOLID
        NVG_HOLE 
        NVG_ALIGN_LEFT  
        NVG_ALIGN_CENTER  
        NVG_ALIGN_RIGHT  
        NVG_ALIGN_TOP  
        NVG_ALIGN_MIDDLE  
        NVG_ALIGN_BOTTOM  
        NVG_ALIGN_BASELINE
        NULL
	NVG_BUTT
	NVG_ROUND
	NVG_SQUARE
	NVG_BEVEL
	NVG_MITER
    )

    (import (scheme) (utils libutil) (cffi cffi) )

    (define NVG_ANTIALIAS 1)
    (define NVG_STENCIL_STROKES 2)
    (define NVG_DEBUG 4)
    (define NVG_SOLID 1)
    (define NVG_HOLE 2)
    (define NVG_ALIGN_LEFT 1)
    (define NVG_ALIGN_CENTER 2)
    (define NVG_ALIGN_RIGHT 4)
    (define NVG_ALIGN_TOP 8)
    (define NVG_ALIGN_MIDDLE 16)
    (define NVG_ALIGN_BOTTOM 32)
    (define NVG_ALIGN_BASELINE 64)
    (define NULL 0)
    
    (define NVG_BUTT 0)
    (define NVG_ROUND 1)
    (define NVG_SQUARE 2)
    (define NVG_BEVEL 3)
    (define NVG_MITER 4)

    (define lib-name
     (case (machine-type)
       ((arm32le) "libnanovg.so")
       ((a6nt i3nt) "libnanovg.dll")
       ((a6osx i3osx)  "libnanovg.so")
       ((a6le i3le) "libnanovg.so")))
    (define lib (load-librarys  lib-name ))


    (def-struct NVGcolor
        (r float 32)
        (g float 32)
        (b float 32)
        (a float 32)
     )
    (def-struct array6
        (e0 float 32)
        (e1 float 32)
        (e2 float 32)
        (e3 float 32)
        (e4 float 32)
        (e5 float 32))

    (def-struct array2
        (e0 float 32)
        (e1 float 32))

    (def-struct NVGpaint 
        (xform array6 (* 32 6) )
        (extent array2 (* 32 2) )
        (radius float (* 32 1) )
        (feather float 32)
        (innerColor NVGcolor (* 32 4) )
        (outerColor NVGcolor (* 32 4) )
        (image int 32)
        )

     (def-function nvg-create-gles22 
       "nvgCreateGL22" (int) void*)

 (def-function nvg-create-gles222 
       "nvgCreateGLES222" (int) void*)
     
    (def-function nvg-create-gles2 
      "nvgCreateGL2" (int) void*)
    
    (def-function nvg-delete-gles2 
      "nvgDeleteGL2" (void*) void)


;; Begin drawing a new frame
;; Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
;; nvgBeginFrame() defines the size of the window to render to in relation currently
;; set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
;; control the rendering on Hi-DPI devices.
;; For example, GLFW returns two dimension for an opened window: window size and
;; frame buffer size. In that case you would set windowWidth/Height to the window size
;; devicePixelRatio to: frameBufferWidth / windowWidth.
;; void nvgBeginFrame(NVGcontext* ctx, int windowWidth, int windowHeight, float devicePixelRatio);
(def-function nvg-begin-frame 
                 "nvgBeginFrame" (void* int int float) void)

;; Cancels drawing the current frame.
;; void nvgCancelFrame(NVGcontext* ctx);
(def-function nvg-cancel-frame 
                 "nvgCancelFrame" (void*) void)

;; Ends drawing flushing remaining render state.
;; void nvgEndFrame(NVGcontext* ctx);
(def-function nvg-end-frame 
                 "nvgEndFrame" (void*) void)

;; 
;; Composite operation
;; 
;; The composite operations in NanoVG are modeled after HTML Canvas API, and
;; the blend func is based on OpenGL (see corresponding manuals for more info).
;; The colors in the blending state have premultiplied alpha.
;; Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
;; void nvgGlobalCompositeOperation(NVGcontext* ctx, int op);
(def-function nvg-global-composite-operation 
                 "nvgGlobalCompositeOperation" (void* int) void)

;; Sets the composite operation with custom pixel arithmetic. The parameters should be one of NVGblendFactor.
;; void nvgGlobalCompositeBlendFunc(NVGcontext* ctx, int sfactor, int dfactor);
(def-function nvg-global-composite-blend-func 
                 "nvgGlobalCompositeBlendFunc" (void* int int) void)

;; Sets the composite operation with custom pixel arithmetic for RGB and alpha components separately. The parameters should be one of NVGblendFactor.
;; void nvgGlobalCompositeBlendFuncSeparate(NVGcontext* ctx, int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);
(def-function nvg-global-composite-blend-func-separate 
                 "nvgGlobalCompositeBlendFuncSeparate" (void* int int int int) void)

;; 
;; Color utils
;; 
;; Colors in NanoVG are stored as unsigned ints in ABGR format.
;; Returns a color value from red, green, blue values. Alpha will be set to 255 (1.0f).
;; NVGcolor nvgRGB(unsigned char r, unsigned char g, unsigned char b);
(def-function nvg-rgb 
                 "nvgRGB" (int int int) NVGcolor)

;; Returns a color value from red, green, blue values. Alpha will be set to 1.0f.
;; NVGcolor nvgRGBf(float r, float g, float b);
(def-function nvg-rgbf 
                 "nvgRGBf" (float float float) NVGcolor)

;; Returns a color value from red, green, blue and alpha values.
;; NVGcolor nvgRGBA(unsigned char r, unsigned char g, unsigned char b, unsigned char a);
(def-function nvg-rgba 
                 "nvgRGBA" (int int int int) NVGcolor)

;; Returns a color value from red, green, blue and alpha values.
;; NVGcolor nvgRGBAf(float r, float g, float b, float a);
(def-function nvg-rgbaf 
                 "nvgRGBAf" (float float float float) NVGcolor)

;; Linearly interpolates from color c0 to c1, and returns resulting color value.
;; NVGcolor nvgLerpRGBA(NVGcolor c0, NVGcolor c1, float u);
(def-function nvg-lerp-rgba 
                 "nvgLerpRGBA" (NVGcolor NVGcolor float) NVGcolor)

;; Sets transparency of a color value.
;; NVGcolor nvgTransRGBA(NVGcolor c0, unsigned char a);
(def-function nvg-trans-rgba 
                 "nvgTransRGBA" (NVGcolor int) NVGcolor)

;; Sets transparency of a color value.
;; NVGcolor nvgTransRGBAf(NVGcolor c0, float a);
(def-function nvg-trans-rgbaf 
                 "nvgTransRGBAf" (NVGcolor float) NVGcolor)

;; Returns color value specified by hue, saturation and lightness.
;; HSL values are all in range [0..1], alpha will be set to 255.
;; NVGcolor nvgHSL(float h, float s, float l);
(def-function nvg-h-s-l 
                 "nvgHSL" (float float float) NVGcolor)

;; Returns color value specified by hue, saturation and lightness and alpha.
;; HSL values are all in range [0..1], alpha in range [0..255]
;; NVGcolor nvgHSLA(float h, float s, float l, unsigned char a);
(def-function nvg-hsla 
                 "nvgHSLA" (float float float int) NVGcolor)

;; 
;; State Handling
;; 
;; NanoVG contains state which represents how paths will be rendered.
;; The state contains transform, fill and stroke styles, text and font styles,
;; and scissor clipping.
;; Pushes and saves the current render state into a state stack.
;; A matching nvgRestore() must be used to restore the state.
;; void nvgSave(NVGcontext* ctx);
(def-function nvg-save 
                 "nvgSave" (void*) void)

;; Pops and restores current render state.
;; void nvgRestore(NVGcontext* ctx);
(def-function nvg-restore 
                 "nvgRestore" (void*) void)

;; Resets current render state to default values. Does not affect the render state stack.
;; void nvgReset(NVGcontext* ctx);
(def-function nvg-reset 
                 "nvgReset" (void*) void)

;; 
;; Render styles
;; 
;; Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
;; Solid color is simply defined as a color value, different kinds of paints can be created
;; using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().
;; 
;; Current render style can be saved and restored using nvgSave() and nvgRestore().
;; Sets current stroke style to a solid color.
;; void nvgStrokeColor(NVGcontext* ctx, NVGcolor color);
(def-function nvg-stroke-color 
                 "nvgStrokeColor" (void* NVGcolor) void)

;; Sets current stroke style to a paint, which can be a one of the gradients or a pattern.
;; void nvgStrokePaint(NVGcontext* ctx, NVGpaint paint);
(def-function nvg-stroke-paint 
                 "nvgStrokePaint" (void* NVGpaint) void)

;; Sets current fill style to a solid color.
;; void nvgFillColor(NVGcontext* ctx, NVGcolor color);
(def-function nvg-fill-color 
                 "nvgFillColor" (void* NVGcolor) void)

;; Sets current fill style to a paint, which can be a one of the gradients or a pattern.
;; void nvgFillPaint(NVGcontext* ctx, NVGpaint paint);
(def-function nvg-fill-paint 
                 "nvgFillPaint" (void* NVGpaint) void)

;; Sets the miter limit of the stroke style.
;; Miter limit controls when a sharp corner is beveled.
;; void nvgMiterLimit(NVGcontext* ctx, float limit);
(def-function nvg-miter-limit 
                 "nvgMiterLimit" (void* float) void)

;; Sets the stroke width of the stroke style.
;; void nvgStrokeWidth(NVGcontext* ctx, float size);
(def-function nvg-stroke-width 
                 "nvgStrokeWidth" (void* float) void)

;; Sets how the end of the line (cap) is drawn,
;; Can be one of: NVG_BUTT (default), NVG_ROUND, NVG_SQUARE.
;; void nvgLineCap(NVGcontext* ctx, int cap);
(def-function nvg-line-cap 
                 "nvgLineCap" (void* int) void)

;; Sets how sharp path corners are drawn.
;; Can be one of NVG_MITER (default), NVG_ROUND, NVG_BEVEL.
;; void nvgLineJoin(NVGcontext* ctx, int join);
(def-function nvg-line-join 
                 "nvgLineJoin" (void* int) void)

;; Sets the transparency applied to all rendered shapes.
;; Already transparent paths will get proportionally more transparent as well.
;; void nvgGlobalAlpha(NVGcontext* ctx, float alpha);
(def-function nvg-global-alpha 
                 "nvgGlobalAlpha" (void* float) void)

;; 
;; Transforms
;; 
;; The paths, gradients, patterns and scissor region are transformed by an transformation
;; matrix at the time when they are passed to the API.
;; The current transformation matrix is a affine matrix:
;;   [sx kx tx]
;;   [ky sy ty]
;;   [ 0  0  1]
;; Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
;; The last row is assumed to be 0,0,1 and is not stored.
;; 
;; Apart from nvgResetTransform(), each transformation function first creates
;; specific transformation matrix and pre-multiplies the current transformation by it.
;; 
;; Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().
;; Resets current transform to a identity matrix.
;; void nvgResetTransform(NVGcontext* ctx);
(def-function nvg-reset-transform 
                 "nvgResetTransform" (void*) void)

;; Premultiplies current coordinate system by specified matrix.
;; The parameters are interpreted as matrix as follows:
;;   [a c e]
;;   [b d f]
;;   [0 0 1]
;; void nvgTransform(NVGcontext* ctx, float a, float b, float c, float d, float e, float f);
(def-function nvg-transform 
                 "nvgTransform" (void* float float float float float float) void)

;; Translates current coordinate system.
;; void nvgTranslate(NVGcontext* ctx, float x, float y);
(def-function nvg-translate 
                 "nvgTranslate" (void* float float) void)

;; Rotates current coordinate system. Angle is specified in radians.
;; void nvgRotate(NVGcontext* ctx, float angle);
(def-function nvg-rotate 
                 "nvgRotate" (void* float) void)

;; Skews the current coordinate system along X axis. Angle is specified in radians.
;; void nvgSkewX(NVGcontext* ctx, float angle);
(def-function nvg-skew-x 
                 "nvgSkewX" (void* float) void)

;; Skews the current coordinate system along Y axis. Angle is specified in radians.
;; void nvgSkewY(NVGcontext* ctx, float angle);
(def-function nvg-skew-y 
                 "nvgSkewY" (void* float) void)

;; Scales the current coordinate system.
;; void nvgScale(NVGcontext* ctx, float x, float y);
(def-function nvg-scale 
                 "nvgScale" (void* float float) void)

;; Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
;;   [a c e]
;;   [b d f]
;;   [0 0 1]
;; There should be space for 6 floats in the return buffer for the values a-f.
;; void nvgCurrentTransform(NVGcontext* ctx, float* xform);
(def-function nvg-current-transform 
                 "nvgCurrentTransform" (void* void*) void)

;; The following functions can be used to make calculations on 2x3 transformation matrices.
;; A 2x3 matrix is represented as float[6].
;; Sets the transform to identity matrix.
;; void nvgTransformIdentity(float* dst);
(def-function nvg-transform-identity 
                 "nvgTransformIdentity" (void*) void)

;; Sets the transform to translation matrix matrix.
;; void nvgTransformTranslate(float* dst, float tx, float ty);
(def-function nvg-transform-translate 
                 "nvgTransformTranslate" (void* float float) void)

;; Sets the transform to scale matrix.
;; void nvgTransformScale(float* dst, float sx, float sy);
(def-function nvg-transform-scale 
                 "nvgTransformScale" (void* float float) void)

;; Sets the transform to rotate matrix. Angle is specified in radians.
;; void nvgTransformRotate(float* dst, float a);
(def-function nvg-transform-rotate 
                 "nvgTransformRotate" (void* float) void)

;; Sets the transform to skew-x matrix. Angle is specified in radians.
;; void nvgTransformSkewX(float* dst, float a);
(def-function nvg-transform-skew-x 
                 "nvgTransformSkewX" (void* float) void)

;; Sets the transform to skew-y matrix. Angle is specified in radians.
;; void nvgTransformSkewY(float* dst, float a);
(def-function nvg-transform-skew-y 
                 "nvgTransformSkewY" (void* float) void)

;; Sets the transform to the result of multiplication of two transforms, of A = A*B.
;; void nvgTransformMultiply(float* dst, const float* src);
(def-function nvg-transform-multiply 
                 "nvgTransformMultiply" (void* void*) void)

;; Sets the transform to the result of multiplication of two transforms, of A = B*A.
;; void nvgTransformPremultiply(float* dst, const float* src);
(def-function nvg-transform-premultiply 
                 "nvgTransformPremultiply" (void* void*) void)

;; Sets the destination to inverse of specified transform.
;; Returns 1 if the inverse could be calculated, else 0.
;; int nvgTransformInverse(float* dst, const float* src);
(def-function nvg-transform-inverse 
                 "nvgTransformInverse" (void* void*) int)

;; Transform a point by given transform.
;; void nvgTransformPoint(float* dstx, float* dsty, const float* xform, float srcx, float srcy);
(def-function nvg-transform-point 
                 "nvgTransformPoint" (void* void* void* float float) void)

;; Converts degrees to radians and vice versa.
;; float nvgDegToRad(float deg);
(def-function nvg-deg-to-rad 
                 "nvgDegToRad" (float) float)

;; float nvgRadToDeg(float rad);
(def-function nvg-rad-to-deg 
                 "nvgRadToDeg" (float) float)

;; 
;; Images
;; 
;; NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
;; In addition you can upload your own image. The image loading is provided by stb_image.
;; The parameter imageFlags is combination of flags defined in NVGimageFlags.
;; Creates image by loading it from the disk from specified file name.
;; Returns handle to the image.
;; int nvgCreateImage(NVGcontext* ctx, const char* filename, int imageFlags);
(def-function nvg-create-image 
                 "nvgCreateImage" (void* string int) int)

;; Creates image by loading it from the specified chunk of memory.
;; Returns handle to the image.
;; int nvgCreateImageMem(NVGcontext* ctx, int imageFlags, unsigned char* data, int ndata);
(def-function nvg-create-image-mem 
                 "nvgCreateImageMem" (void* int void* int) int)

;; Creates image from specified image data.
;; Returns handle to the image.
;; int nvgCreateImageRGBA(NVGcontext* ctx, int w, int h, int imageFlags, const unsigned char* data);
(def-function nvg-create-image-rgba 
                 "nvgCreateImageRGBA" (void* int int int void*) int)

;; Updates image data specified by image handle.
;; void nvgUpdateImage(NVGcontext* ctx, int image, const unsigned char* data);
(def-function nvg-update-image 
                 "nvgUpdateImage" (void* int void*) void)

;; Returns the dimensions of a created image.
;; void nvgImageSize(NVGcontext* ctx, int image, int* w, int* h);
(def-function nvg-image-size 
                 "nvgImageSize" (void* int void* void*) void)

;; Deletes created image.
;; void nvgDeleteImage(NVGcontext* ctx, int image);
(def-function nvg-delete-image 
                 "nvgDeleteImage" (void* int) void)

;; 
;; Paints
;; 
;; NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
;; These can be used as paints for strokes and fills.
;; Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
;; of the linear gradient, icol specifies the start color and ocol the end color.
;; The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
;; NVGpaint nvgLinearGradient(NVGcontext* ctx, float sx, float sy, float ex, float ey,NVGcolor icol, NVGcolor ocol);
(def-function nvg-linear-gradient 
                 "nvgLinearGradient" (void* float float float float NVGcolor NVGcolor) NVGpaint)

;; Creates and returns a box gradient. Box gradient is a feathered rounded rectangle, it is useful for rendering
;; drop shadows or highlights for boxes. Parameters (x,y) define the top-left corner of the rectangle,
;; (w,h) define the size of the rectangle, r defines the corner radius, and f feather. Feather defines how blurry
;; the border of the rectangle is. Parameter icol specifies the inner color and ocol the outer color of the gradient.
;; The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
;; NVGpaint nvgBoxGradient(NVGcontext* ctx, float x, float y, float w, float h,float r, float f, NVGcolor icol, NVGcolor ocol);
(def-function nvg-box-gradient 
                 "nvgBoxGradient" (void* float float float float float float NVGcolor NVGcolor) NVGpaint)

;; Creates and returns a radial gradient. Parameters (cx,cy) specify the center, inr and outr specify
;; the inner and outer radius of the gradient, icol specifies the start color and ocol the end color.
;; The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
;; NVGpaint nvgRadialGradient(NVGcontext* ctx, float cx, float cy, float inr, float outr,NVGcolor icol, NVGcolor ocol);
(def-function nvg-radial-gradient 
                 "nvgRadialGradient" (void* float float float float NVGcolor NVGcolor) NVGpaint)

;; Creates and returns an image patter. Parameters (ox,oy) specify the left-top location of the image pattern,
;; (ex,ey) the size of one image, angle rotation around the top-left corner, image is handle to the image to render.
;; The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
;; NVGpaint nvgImagePattern(NVGcontext* ctx, float ox, float oy, float ex, float ey,float angle, int image, float alpha);
(def-function nvg-image-pattern 
                 "nvgImagePattern" (void* float float float float float int float) NVGpaint)

;; 
;; Scissoring
;; 
;; Scissoring allows you to clip the rendering into a rectangle. This is useful for various
;; user interface cases like rendering a text edit or a timeline.
;; Sets the current scissor rectangle.
;; The scissor rectangle is transformed by the current transform.
;; void nvgScissor(NVGcontext* ctx, float x, float y, float w, float h);
(def-function nvg-scissor 
                 "nvgScissor" (void* float float float float) void)

;; Intersects current scissor rectangle with the specified rectangle.
;; The scissor rectangle is transformed by the current transform.
;; Note: in case the rotation of previous scissor rect differs from
;; the current one, the intersection will be done between the specified
;; rectangle and the previous scissor rectangle transformed in the current
;; transform space. The resulting shape is always rectangle.
;; void nvgIntersectScissor(NVGcontext* ctx, float x, float y, float w, float h);
(def-function nvg-intersect-scissor 
                 "nvgIntersectScissor" (void* float float float float) void)

;; Reset and disables scissoring.
;; void nvgResetScissor(NVGcontext* ctx);
(def-function nvg-reset-scissor 
                 "nvgResetScissor" (void*) void)

;; 
;; Paths
;; 
;; Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
;; Then you define one or more paths and sub-paths which describe the shape. The are functions
;; to draw common shapes like rectangles and circles, and lower level step-by-step functions,
;; which allow to define a path curve by curve.
;; 
;; NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
;; winding and holes should have counter clockwise order. To specify winding of a path you can
;; call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.
;; 
;; Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
;; with current stroke style by calling nvgStroke().
;; 
;; The curve segments and sub-paths are transformed by the current transform.
;; Clears the current path and sub-paths.
;; void nvgBeginPath(NVGcontext* ctx);
(def-function nvg-begin-path 
                 "nvgBeginPath" (void*) void)

;; Starts new sub-path with specified point as first point.
;; void nvgMoveTo(NVGcontext* ctx, float x, float y);
(def-function nvg-move-to 
                 "nvgMoveTo" (void* float float) void)

;; Adds line segment from the last point in the path to the specified point.
;; void nvgLineTo(NVGcontext* ctx, float x, float y);
(def-function nvg-line-to 
                 "nvgLineTo" (void* float float) void)

;; Adds cubic bezier segment from last point in the path via two control points to the specified point.
;; void nvgBezierTo(NVGcontext* ctx, float c1x, float c1y, float c2x, float c2y, float x, float y);
(def-function nvg-bezier-to 
                 "nvgBezierTo" (void* float float float float float float) void)

;; Adds quadratic bezier segment from last point in the path via a control point to the specified point.
;; void nvgQuadTo(NVGcontext* ctx, float cx, float cy, float x, float y);
(def-function nvg-quad-to 
                 "nvgQuadTo" (void* float float float float) void)

;; Adds an arc segment at the corner defined by the last path point, and two specified points.
;; void nvgArcTo(NVGcontext* ctx, float x1, float y1, float x2, float y2, float radius);
(def-function nvg-arc-to 
                 "nvgArcTo" (void* float float float float float) void)

;; Closes current sub-path with a line segment.
;; void nvgClosePath(NVGcontext* ctx);
(def-function nvg-close-path 
                 "nvgClosePath" (void*) void)

;; Sets the current sub-path winding, see NVGwinding and NVGsolidity.
;; void nvgPathWinding(NVGcontext* ctx, int dir);
(def-function nvg-path-winding 
                 "nvgPathWinding" (void* int) void)

;; Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
;; and the arc is drawn from angle a0 to a1, and swept in direction dir (NVG_CCW, or NVG_CW).
;; Angles are specified in radians.
;; void nvgArc(NVGcontext* ctx, float cx, float cy, float r, float a0, float a1, int dir);
(def-function nvg-arc 
                 "nvgArc" (void* float float float float float int) void)

;; Creates new rectangle shaped sub-path.
;; void nvgRect(NVGcontext* ctx, float x, float y, float w, float h);
(def-function nvg-rect 
                 "nvgRect" (void* float float float float) void)

;; Creates new rounded rectangle shaped sub-path.
;; void nvgRoundedRect(NVGcontext* ctx, float x, float y, float w, float h, float r);
(def-function nvg-rounded-rect 
                 "nvgRoundedRect" (void* float float float float float) void)

;; Creates new rounded rectangle shaped sub-path with varying radii for each corner.
;; void nvgRoundedRectVarying(NVGcontext* ctx, float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
(def-function nvg-rounded-rect-varying 
                 "nvgRoundedRectVarying" (void* float float float float float float float float) void)

;; Creates new ellipse shaped sub-path.
;; void nvgEllipse(NVGcontext* ctx, float cx, float cy, float rx, float ry);
(def-function nvg-ellipse 
                 "nvgEllipse" (void* float float float float) void)

;; Creates new circle shaped sub-path.
;; void nvgCircle(NVGcontext* ctx, float cx, float cy, float r);
(def-function nvg-circle 
                 "nvgCircle" (void* float float float) void)

;; Fills the current path with current fill style.
;; void nvgFill(NVGcontext* ctx);
(def-function nvg-fill 
                 "nvgFill" (void*) void)

;; Fills the current path with current stroke style.
;; void nvgStroke(NVGcontext* ctx);
(def-function nvg-stroke 
                 "nvgStroke" (void*) void)

;; 
;; Text
;; 
;; NanoVG allows you to load .ttf files and use the font to render text.
;; 
;; The appearance of the text can be defined by setting the current text style
;; and by specifying the fill color. Common text and font settings such as
;; font size, letter spacing and text align are supported. Font blur allows you
;; to create simple text effects such as drop shadows.
;; 
;; At render time the font face can be set based on the font handles or name.
;; 
;; Font measure functions return values in local space, the calculations are
;; carried in the same resolution as the final rendering. This is done because
;; the text glyph positions are snapped to the nearest pixels sharp rendering.
;; 
;; The local space means that values are not rotated or scale as per the current
;; transformation. For example if you set font size to 12, which would mean that
;; line height is 16, then regardless of the current scaling and rotation, the
;; returned line height is always 16. Some measures may vary because of the scaling
;; since aforementioned pixel snapping.
;; 
;; While this may sound a little odd, the setup allows you to always render the
;; same way regardless of scaling. I.e. following works regardless of scaling:
;; 
;;  const char* txt = "Text me up.";
;;  nvgTextBounds(vg, x,y, txt, NULL, bounds);
;;  nvgBeginPath(vg);
;;  nvgRoundedRect(vg, bounds[0],bounds[1], bounds[2]-bounds[0], bounds[3]-bounds[1]);
;;  nvgFill(vg);
;; 
;; Note: currently only solid color fill is supported for text.
;; Creates font by loading it from the disk from specified file name.
;; Returns handle to the font.
;; int nvgCreateFont(NVGcontext* ctx, const char* name, const char* filename);
(def-function nvg-create-font 
                 "nvgCreateFont" (void* string string) int)

;; Creates font by loading it from the specified memory chunk.
;; Returns handle to the font.
;; int nvgCreateFontMem(NVGcontext* ctx, const char* name, unsigned char* data, int ndata, int freeData);
(def-function nvg-create-font-mem 
                 "nvgCreateFontMem" (void* string void* int int) int)

;; Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
;; int nvgFindFont(NVGcontext* ctx, const char* name);
(def-function nvg-find-font 
                 "nvgFindFont" (void* string) int)

;; Adds a fallback font by handle.
;; int nvgAddFallbackFontId(NVGcontext* ctx, int baseFont, int fallbackFont);
(def-function nvg-add-fallback-font-id 
                 "nvgAddFallbackFontId" (void* int int) int)

;; Adds a fallback font by name.
;; int nvgAddFallbackFont(NVGcontext* ctx, const char* baseFont, const char* fallbackFont);
(def-function nvg-add-fallback-font 
                 "nvgAddFallbackFont" (void* string string) int)

;; Sets the font size of current text style.
;; void nvgFontSize(NVGcontext* ctx, float size);
(def-function nvg-font-size 
                 "nvgFontSize" (void* float) void)

;; Sets the blur of current text style.
;; void nvgFontBlur(NVGcontext* ctx, float blur);
(def-function nvg-font-blur 
                 "nvgFontBlur" (void* float) void)

;; Sets the letter spacing of current text style.
;; void nvgTextLetterSpacing(NVGcontext* ctx, float spacing);
(def-function nvg-text-letter-spacing 
                 "nvgTextLetterSpacing" (void* float) void)

;; Sets the proportional line height of current text style. The line height is specified as multiple of font size.
;; void nvgTextLineHeight(NVGcontext* ctx, float lineHeight);
(def-function nvg-text-line-height 
                 "nvgTextLineHeight" (void* float) void)

;; Sets the text align of current text style, see NVGalign for options.
;; void nvgTextAlign(NVGcontext* ctx, int align);
(def-function nvg-text-align 
                 "nvgTextAlign" (void* int) void)

;; Sets the font face based on specified id of current text style.
;; void nvgFontFaceId(NVGcontext* ctx, int font);
(def-function nvg-font-face-id 
                 "nvgFontFaceId" (void* int) void)

;; Sets the font face based on specified name of current text style.
;; void nvgFontFace(NVGcontext* ctx, const char* font);
(def-function nvg-font-face 
                 "nvgFontFace" (void* string) void)

;; Draws text string at specified location. If end is specified only the sub-string up to the end is drawn.
;; float nvgText(NVGcontext* ctx, float x, float y, const char* string, const char* end);
(def-function nvg-text 
                 "nvgText" (void* float float string string) float)

;; Draws multi-line text string at specified location wrapped at the specified width. If end is specified only the sub-string up to the end is drawn.
;; White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
;; Words longer than the max width are slit at nearest character (i.e. no hyphenation).
;; void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end);
(def-function nvg-text-box 
                 "nvgTextBox" (void* float float float string string) void)

;; Measures the specified text string. Parameter bounds should be a pointer to float[4],
;; if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
;; Returns the horizontal advance of the measured text (i.e. where the next character should drawn).
;; Measured values are returned in local coordinate space.
;; float nvgTextBounds(NVGcontext* ctx, float x, float y, const char* string, const char* end, float* bounds);
(def-function nvg-text-bounds 
                 "nvgTextBounds" (void* float float string string void*) float)

;; Measures the specified multi-text string. Parameter bounds should be a pointer to float[4],
;; if the bounding box of the text should be returned. The bounds value are [xmin,ymin, xmax,ymax]
;; Measured values are returned in local coordinate space.
;; void nvgTextBoxBounds(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end, float* bounds);
(def-function nvg-text-box-bounds 
                 "nvgTextBoxBounds" (void* float float float string string void*) void)

;; Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
;; Measured values are returned in local coordinate space.
;; int nvgTextGlyphPositions(NVGcontext* ctx, float x, float y, const char* string, const char* end, NVGglyphPosition* positions, int maxPositions);
(def-function nvg-text-glyph-positions 
                 "nvgTextGlyphPositions" (void* float float string string void* int) int)

;; Returns the vertical metrics based on the current text style.
;; Measured values are returned in local coordinate space.
;; void nvgTextMetrics(NVGcontext* ctx, float* ascender, float* descender, float* lineh);
(def-function nvg-text-metrics 
                 "nvgTextMetrics" (void* void* void* void*) void)

;; Breaks the specified text into lines. If end is specified only the sub-string will be used.
;; White space is stripped at the beginning of the rows, the text is split at word boundaries or when new-line characters are encountered.
;; Words longer than the max width are slit at nearest character (i.e. no hyphenation).
;; int nvgTextBreakLines(NVGcontext* ctx, const char* string, const char* end, float breakRowWidth, NVGtextRow* rows, int maxRows);
(def-function nvg-text-break-lines 
                 "nvgTextBreakLines" (void* string string float void*  int) int)

 
)
