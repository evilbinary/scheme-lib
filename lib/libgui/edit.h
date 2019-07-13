/**
 * 作者:evilbinary on 02/23/19.
 * 邮箱:rootdebug@163.com
 */

#ifndef __DUCK_EDIT_H__
#define __DUCK_EDIT_H__

#include "graphic.h"

#define LINE_SIZE 512
#define UPDATING 1
#define UPDATED 2

// editor here
typedef struct {
  float x, y, z;
  float s, t;
  float r, g, b, a;
} vertex_t;

typedef struct {
  int available;  //可用长度
  int count;      //个数
  int actual;     //实际占用长度
  unsigned char *texts;
  uint32_t *colors;
  uint32_t *color;
  float width;
  float height;
  font_t *font;
  float sx, sy;
} line_t;

typedef struct {
  char *file_name;
  int offset;
  int coffset;
  int line_count;
  int line_avail;
  line_t **lines;
  font_t *font;
  uint32_t *color;
  int cursor_col;
  int cursor_row;
  float cursor_x;
  float cursor_y;
  float width;
  float height;
  int scale;
  // history_t * history;
  // history_t * last_save_history;
} buffer_t;

typedef struct _edit_t {
  buffer_t *buffer;
  font_t *font;
  char *texts;
  int texts_avail;
  char *crlf;
  int status;
  vec4 bound;
  vec4 ebound;
  mvp_t mvp;
  float scroll_x;
  float scroll_y;

  int editable;

  int select_start[2];
  int select_end[2];
  int selected_color;
  char *select_text;
  int select_text_avail;
  int selected_bg_color;
  int select_press;
  int cursor_color;

  int show_lineno;
  int lineno_width;
  int lineno_color;
  int color;
  int bg_color;

  float window_width;
  float window_height;

  void *colors;
  int colors_avail;
  int scale;

} edit_t;

void buffer_insert_line(buffer_t *buffer, int pos, line_t *line);
line_t **new_lines(size_t size);
buffer_t *new_buffer();
line_t *new_line(size_t size);

edit_t *new_edit(int shader, font_t *font, float font_size, float scale,
                 float w, float h, float width, float height);
void resize_edit_window(edit_t *self, float width, float height);
void edit_set_highlight(edit_t *self, void *colors);
void edit_mouse_event(edit_t *self, int action, float x, float y);
void edit_key_event(edit_t *self, int key, int scancode, int action, int mods);
void render_cursor(edit_t *self);
void add_edit_text(edit_t *self, char *text);
void set_edit_text(edit_t *self, char *text);

void edit_cursor_move_left(buffer_t *self);
void edit_cursor_move_right(buffer_t *self);
void edit_cursor_move_down(buffer_t *self);
void edit_cursor_move_up(buffer_t *self);

void render_selection(edit_t *self);
void render_line_selected(mvp_t *mvp, line_t *line, int start, int end,
                          int color);
char *get_selection(edit_t *self);

void calc_cursor(edit_t *self);
void pos_to_cursor(buffer_t *buffer, float x, float y);
float buffer_height(buffer_t *buffer);
int buffer_total_text_length(buffer_t *buffer);

void remove_string(char *str, int pos, int len);
void insert_string(char *base, int n, int position, char *texts, int len);

#endif
