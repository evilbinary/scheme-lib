/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com
 */

#ifndef __DUCK_GUI_H__
#define __DUCK_GUI_H__

#include <math.h>
#include <stdio.h>
#include <string.h>

#ifdef GLAD
#include "glad/glad.h"
#else

#include <GLES/gl.h>
#include <GLES2/gl2.h>

#include <GLES/glext.h>
#include <GLES2/gl2ext.h>

#endif

#include "mat4.h"
#include "utf8-utils.h"
#include "vec234.h"

#include <stdio.h>
#include <sys/time.h>
#include <time.h>

#ifndef FONTSTASH_IMPLEMENTATION
#define FONTSTASH_IMPLEMENTATION
#include "fontstash.h"
#endif

typedef struct {
  int shader;
  mat4 model;
  mat4 view;
  mat4 projection;
} mvp_t;

typedef struct {
  float size;
  struct sth_stash *stash;
  int id;
  char *name;
  unsigned char *data;
} font_t;

font_t *font_create(char *font_name);
void glShaderSource2(GLuint shader, GLsizei count, const GLchar *string,
                     const GLint *length);

void draw_solid_quad(mvp_t *mvp, float x1, float y1, float x2, float y2,
                     float r, float g, float b, float a);
#endif
