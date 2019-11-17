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
  mvp_t* mvp;
  int width;
  int height;
  float scale;
} graphic_t;

typedef struct {
  float size;
  struct sth_stash *stash;
  int id;
  char *name;
  unsigned char *data;
  int fallback_id;
} font_t;

float measure_text(font_t* font, float size, char* text, int count);
font_t *new_font(char *name, float size);
void destroy_font(font_t *font);
void glShaderSource2(GLuint shader, GLsizei count, const GLchar *string,
                     const GLint *length);

void graphic_draw_solid_quad(mvp_t* mvp, float x1, float y1, float x2,
                             float y2, float r, float g, float b, float a);
void mvp_set_orthographic(mvp_t *self, float left, float right, float bottom,
                          float top, float znear, float zfar);
void mvp_set_mvp(mvp_t *mvp);

void graphic_render_string(font_t* font,float size, float sx, float sy,
                           char* text, float* dx, float* dy, int color);

float graphic_get_font_lineh(font_t* font, float size);
float graphic_get_font_height(font_t* font, float size);
void graphic_render_string_immediate(mvp_t* mvp, font_t* font, float size,
                                     float sx, float sy, char* text, float* dx,
                                     float* dy, int color);
void graphic_render_string(font_t* font, float size, float sx, float sy,
                           char* text, float* dx, float* dy, int color);
                                                             
#endif
