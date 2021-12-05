
#ifdef GLAD
#include "glad/glad.h"
#else

#ifdef ANDROID

#include <GLES/gl.h>
#include <GLES/glext.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

//#include <GLES3/gl3.h>
//#include <GLES3/gl3ext.h>

#else

#endif

#endif
#include "nanovg.h"
#include "nanovg_gl.h"
