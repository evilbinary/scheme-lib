/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef __DUCK_GUI_H__
#define __DUCK_GUI_H__

#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef GLAD
#include "glad/glad.h"
#else

#include <GLES/gl.h>
#include <GLES2/gl2.h>

#include <GLES/glext.h>
#include <GLES2/gl2ext.h>

#endif

#include "vec234.h"
#include "mat4.h"
#include "utf8-utils.h"


#include <stdio.h>
#include <time.h>
#include <sys/time.h>

#define FONTSTASH_IMPLEMENTATION

#include "fontstash.h"

#define STB_IMAGE_IMPLEMENTATION

#include "stb_image.h"



//editor here

typedef struct {
    float x, y, z;
    float s, t;
    float r, g, b, a;
} vertex_t;



typedef struct _edit_t {
  char *prompt;
  char *input;
  size_t max_input;
  size_t cursor;
  size_t cursor_total;
  size_t cursor_current_row;
  size_t cursor_current_col;
  size_t cursor_total_row;
  float cursor_x;
  float cursor_y;
  char* cursor_text;
  size_t cursor_current_cols;
  size_t cursor_prev_cols;
  
  vec4 bound;
  vec2 pen;
  vec2 old_pen;
  int shader;
  mat4 model;
  mat4 view;
  mat4 projection;
  int editable;

  struct sth_stash *stash;
  unsigned char *data;
  int font;
  float font_size;
  int color;

  float window_width;
  float window_height;

  void *colors;

} edit_t;


typedef struct mvp_t{
  int shader;
  mat4 model;
  mat4 view;
  mat4 projection;
}mvp;

typedef struct font_t{
  int font;
  struct sth_stash *stash;
}font;


edit_t *gl_new_edit(int shader, float w, float h, float width, float height);
void gl_resize_edit_window(edit_t *self, float width, float height);
void gl_edit_set_highlight(edit_t *self,void* colors) ;

font* font_create(char* font_name);
void calc_cursor(edit_t *self);

void glShaderSource2(GLuint shader,
                     GLsizei count,
                     const GLchar *string,
                     const GLint *length);

void calc_cursor_pos(edit_t *self);
void gl_edit_cursor_move_left(edit_t *self);
void gl_edit_cursor_move_right(edit_t *self);

#endif
