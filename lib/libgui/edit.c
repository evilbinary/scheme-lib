#include "edit.h"

font_t *new_font(char *name, float size) {
  font_t *font = malloc(sizeof(font_t));
  font->name = name;
  font->size = size;
  font->stash = sth_create(512, 512);
  font->id = sth_add_font(font->stash, name);
  // sth_add_font_from_memory(self->stash, self->data);
  return font;
}

void destroy_font(font_t *font) {
  if (font == NULL) return;
  sth_delete(font->stash);
  free(font);
  font = NULL;
}

buffer_t *new_buffer() {
  buffer_t *buffer = malloc(sizeof(buffer_t));
  buffer->lines = new_lines(LINE_SIZE);
  buffer->line_avail = LINE_SIZE;
  buffer->color = NULL;
  buffer->line_count = 0;
  buffer->cursor_col = 0;
  buffer->cursor_row = 0;
  return buffer;
}

line_t *new_line(size_t size) {
  line_t *line = malloc(sizeof(line_t));
  line->actual = 0;
  line->available = size;
  line->texts = malloc(line->available);
  line->colors = NULL;
  line->color = NULL;
  line->width = 0.0;
  line->count = 0;
  line->height = 0;
  memset(line->texts, 0, line->available);
  return line;
}

void line_recalc_len(line_t *line) {
  if (line == NULL) {
    return;
  }
  line->actual = strlen(line->texts);
  line->count = utf8_strlen(line->texts);
}

void line_reset(line_t *line) {
  if (line == NULL) {
    return;
  }
  line->actual = 0;
  line->count = 0;
  memset(line->texts, 0, sizeof(char) * line->actual);
}

void destroy_line(line_t *line) {
  if (line == NULL) {
    return;
  }
  if (line->texts != NULL) {
    free(line->texts);
  }
  free(line);
}

line_t *new_line_text(char *text, size_t len) {
  line_t *line = new_line(len + 1);
  line->actual = len;
  memcpy(line->texts, text, len);
  line->count = utf8_strlen(line->texts);
  return line;
}

line_t **new_lines(size_t size) {
  line_t **lines = malloc(sizeof(line_t *) * size);
  for (int i = 0; i < size; i++) {
    lines[i] = NULL;
  }
  return lines;
}

void buffer_insert_line(buffer_t *buffer, int pos, line_t *line) {
  line->font = buffer->font;
  if (line->color == NULL) {
    line->color = buffer->color;
  }
  // printf("buffer=>%p lines=%p\n",buffer,buffer->lines);
  if (pos >= buffer->line_avail) {
    int size = buffer->line_avail * 2 > pos ? buffer->line_avail * 2 : pos;
    line_t **lines = new_lines(size);
    memcpy(lines, buffer->lines, buffer->line_count * sizeof(line_t *));
    free(buffer->lines);
    buffer->lines = lines;
    printf("no enough pos>buffer->line_avail %d %d size=%d\n", pos,
           buffer->line_avail, size);
    buffer->line_avail = size;
  }
  // printf("buffer->line_avail %d\n",buffer->line_avail);

  for (int i = (buffer->line_avail - 1); i >= 0 && i >= pos; i--) {
    // printf("buffer lines[%d]=%p buffer
    // lines[%d]=%p\n",i,buffer->lines[i],i-1,buffer->lines[i-1]);

    buffer->lines[i] = buffer->lines[i - 1];
  }
  // printf("buffer_insert_line %d %p\n",pos);
  (buffer->lines[pos]) = line;
  buffer->line_count++;
}

int line_get_col_index(line_t *line, int col) {
  unsigned int state = 0;
  unsigned int codepoint;
  int count = 0;
  int i;
  for (i = 0; i < line->actual; i += utf8_surrogate_len(&line->texts[i])) {
    // printf("i %d col=%d count=%d texts=>", i, col, count);
    // print_string(&line->texts[i],line->actual);
    // printf("\n");
    if (count == col) {
      break;
    }
    count++;
  }
  // printf("i=>%d\n", i);
  return i;
}

void buffer_split_line(buffer_t *buffer, int row, int col) {
  if (row >= 0 && row < buffer->line_avail) {
    line_t *line = buffer->lines[row];
    int start = line_get_col_index(line, col);
    line_t *new = NULL;
    if (start == line->actual) {
      new = new_line(line->available);
    } else {
      // printf("split %s  start=%d %d=%d\n", &line->texts[start], start,
      //        strlen(&line->texts[start]), line->actual - start);
      new = new_line_text(&line->texts[start], line->actual - start);
      memset(&line->texts[start], 0, line->actual - start);
      line->actual = start;
      line->count = utf8_strlen(line->texts);
    }

    buffer_insert_line(buffer, row + 1, new);
  }
}

void line_remove_char(line_t *line, int col) {
  if (line->actual <= 0) return;
  int start = line_get_col_index(line, col);
  int len = utf8_surrogate_len(&line->texts[start]);
  remove_string(line->texts, start, len);
  if (line->actual > 0) line->actual -= len;
  if (line->count > 0) line->count -= 1;
  line->texts[line->actual] = 0;
}

void line_remove_text(line_t *line, int col, int count) {
  for (int i = 0; i < count; i++) {
    line_remove_char(line, col);
  }
}

void line_extend_text(line_t *line, int extend_len) {
  char *old_texts = line->texts;
  int new_len = line->available + extend_len;
  line->texts = malloc(new_len);
  strncpy(line->texts, old_texts, new_len);
  line->available = new_len;
}

void line_insert_text(line_t *line, int col, char *text) {
  printf(">>>>>>>>>>>>>>>>line_insert_text\n");
  int start = line_get_col_index(line, col);
  int len = utf8_strlen(text);
  int len1 = strlen(text);
  printf("line_insert_text at col=%d start=%d  len=%d len1=%d %s\n", col, start,
         len, len1, text);
  if ((line->actual + len1) > line->available) {
    printf("line no available line->available=%d %d\n", line->available,
           (line->actual + len1));
    line_extend_text(line, line->available * 2);
  }
  printf("line current %s\n", line->texts);
  insert_string(line->texts, line->actual, start, text, len1);
  printf("line after %s$$$\n", line->texts);
  line->count += len;
  line->actual += len1;
}

void line_append_text(line_t *line, char *text) {
  line_insert_text(line, line->count, text);
}

int buffer_total_text_length(buffer_t *buffer) {
  int total = 0;
  for (int i = 0; i < buffer->line_count; i++) {
    total += buffer->lines[i]->actual;
  }
  return total;
}

float buffer_height(buffer_t *buffer) {
  float total = 0;
  for (int i = 0; i < buffer->line_count; i++) {
    // printf("%2d height=%f\n", buffer->lines[i]->height );
    if (buffer->lines[i]->height > 0) {
      total += buffer->lines[i]->height;
    } else {
      // not actual
      total += buffer->lines[i]->font->stash->fonts->lineh *
               buffer->lines[i]->font->size;
    }
  }
  // printf("buffer_height=%f\n", total);
  return total;
}

void buffer_delete_line_char(buffer_t *buffer, int row, int col) {
  if (col >= 0 && row >= 0 && row < buffer->line_avail) {
    line_t *line = buffer->lines[row];
    line_remove_char(line, col);
  }
}

void buffer_delete_line_text(buffer_t *buffer, int row, int start, int end) {
  if (start >= 0 && end >= 0 && row >= 0 && row < buffer->line_avail) {
    line_t *line = buffer->lines[row];
    line_remove_text(line, start, end - start);
  }
}

void buffer_insert_line_text_at(buffer_t *buffer, int row, int col,
                                char *text) {
  if (row >= 0 && row < buffer->line_avail) {
    line_t *line = buffer->lines[row];
    line_insert_text(line, col, text);
  }
}

void buffer_delete_line(buffer_t *buffer, int row) {
  if (row >= 0 && row < buffer->line_avail) {
    line_t *line = buffer->lines[row];
    destroy_line(line);
    for (int i = row; i < buffer->line_avail; i++) {
      buffer->lines[i] = buffer->lines[i + 1];
    }
    buffer->line_count--;
  }
}

void buffer_delete_text(buffer_t *buffer, int row_start, int col_start,
                        int row_end, int col_end) {
  int is_swap = 0;
  if (row_start > row_end) {
    int tmp = row_start;
    row_start = row_end;
    row_end = tmp;
    is_swap = 1;
  }

  for (int i = row_end; i >= row_start; i--) {
    line_t *line = buffer->lines[i];
    int start = 0;
    int end = line->count;
    if (is_swap == 1) {
      if (i == row_start) {
        start = col_end;
      }
      if (i == row_end) {
        end = col_start;
      }
    } else {
      if (i == row_start) {
        start = col_start;
      }
      if (i == row_end) {
        end = col_end;
      }
    }
    if (row_start == 0 && row_end == line->count) {
      buffer_delete_line(buffer, i);
    } else if (i == row_start || i == row_end) {
      if (start > end) {
        int temp = start;
        start = end;
        end = temp;
      }
      // printf("buffer_delete_line_text %d %d,%d\n", i, start, end);
      buffer_delete_line_text(buffer, i, start, end);
    } else {
      // printf("buffer_delete_line %d\n", i);
      buffer_delete_line(buffer, i);
    }
  }
}

void buffer_merge_lines(buffer_t *buffer, int row, int count) {
  if (row >= 0 && (row + count) < buffer->line_avail) {
    line_t *current_line = buffer->lines[row];
    for (int i = (row + 1); i < buffer->line_count; i++) {
      line_t *line = buffer->lines[i];
      if (i <= (row + count)) {
        line_append_text(current_line, line->texts);
        destroy_line(line);
      }
      buffer->lines[i] = buffer->lines[i + 1];
    }
    buffer->line_count -= count;
  }
}

print_string(char *str, int len) {
  for (int i = 0; i < len; i++) {
    if (str[i] == '\n') {
      printf("\\n");
    } else if (str[i] == '\r') {
      printf("\\r");
    } else if (str[i] == '\t') {
      printf("\\t");
    } else {
      printf("%c", str[i]);
    }
  }
}

int string_to_buffer_lines(buffer_t *buffer, char *strings, uint32_t *colors) {
  int lines = 0;
  int count = 0;
  int start = 0;
  for (int i = 0; i < strlen(strings);) {
    if (strings[i] == '\n' || strings[i] == '\r') {
      int newline_len = 1;
      if (strings[i] == '\r' && strings[i + 1] == '\n') {  // 0x0d 0x0a
        newline_len = 2;
      }
      // print_string(&strings[start], i - start);
      // printf(">>>>>>>\n");
      line_t *line = new_line_text(&strings[start], i - start);
      line->width = buffer->width;
      if (colors != NULL) {
        line->colors = &colors[count];
      }
      buffer_insert_line(buffer, lines, line);
      i += newline_len;
      start = i;
      lines++;
    } else {
      i += utf8_surrogate_len(strings + i);
      count++;
    }
  }
  if (lines == 0) {
    line_t *line = new_line_text(strings, strlen(strings));
    buffer_insert_line(buffer, lines, line);
    lines = 1;
  }
  // printf("line_count=%d\n", lines);
  buffer->line_count = lines;
  return lines;
}

void buffer_insert_line_text(buffer_t *buffer, int pos, char *text) {
  // printf("buffer_insert_line at %d %s\n",pos ,text);
  buffer_insert_line(buffer, pos, new_line_text(text, strlen(text)));
}

void gl_delete_edit(edit_t *self) {}

void gl_render_string_colors(font_t *font, float size, float sx, float sy,
                             char *text, float width) {
  // printf("==========>addr %lx\n",colors );
  // print_array(colors,1024);

  // float dx, dy;
  // sth_draw_text_colors(font->stash, font->font, size, sx, sy, width * 2, -1,
  //                      text, colors, &dx, &dy);
}

void gl_render_line(line_t *line, float *sx, float *sy) {
  if (line == NULL) {
    return;
  }
  float dx = 0, dy = 0;
  line->sx = *sx;
  line->sy = *sy;
  font_t *font = line->font;
  if (font == NULL) return;
  if (font->size < 0) {
    printf("gl_render_line %p font->size %f\n", font, font->size);
    return;
  }
  if (line->colors != NULL) {
    sth_draw_text_colors(font->stash, font->id, font->size, line->sx, line->sy,
                         line->width, -1, line->texts, line->colors, &dx, &dy);
  } else {
    uint32_t color = 0xffffffff;
    if (line->color != NULL) {
      color = *line->color;
    }
    float b = (color & 0xff) / 255.0;
    float g = (color >> 8 & 0xff) / 255.0;
    float r = (color >> 16 & 0xff) / 255.0;
    float a = (color >> 24 & 0xff) / 255.0;
    sth_draw_text(font->stash, font->id, font->size, line->sx, line->sy,
                  line->width, -1, line->texts, r, g, b, a, &dx, &dy);
  }
  line->height = dy - line->sy;
  *sy += line->height;
}

float gl_render_lines(buffer_t *buffer, float sx, float sy) {
  // printf("gl_render_lines %d\n", buffer->line_count);
  sth_begin_draw(buffer->font->stash);
  for (int i = 0; i < buffer->line_count; i++) {
    // printf("line:%d %s\n", i, buffer->lines[i]->texts);
    gl_render_line(buffer->lines[i], &sx, &sy);
  }
  sth_end_draw(buffer->font->stash);
  return sy;
}

void gl_render_params(edit_t *self, void *pcolor) {
  float sx = self->bound.left;
  float sy = self->bound.top;
  glUseProgram(self->mvp.shader);
  {
    glUniform1i(glGetUniformLocation(self->mvp.shader, "texture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(self->mvp.shader, "model"), 1, 0,
                       self->mvp.model.data);
    glUniformMatrix4fv(glGetUniformLocation(self->mvp.shader, "view"), 1, 0,
                       self->mvp.view.data);
    glUniformMatrix4fv(glGetUniformLocation(self->mvp.shader, "projection"), 1,
                       0, self->mvp.projection.data);
    glUniform1i(glGetUniformLocation(self->mvp.shader, "type"), 0);
    if (pcolor != NULL) {
      self->color = *(int *)pcolor;
    }
    self->ebound.height = gl_render_lines(self->buffer, sx, sy);
  }
}

void gl_render_edit_once(edit_t *self, float x, float y, char *text,
                         int color) {
  gl_set_edit_text(self, text);
  if (self->status == UPDATED) {
    self->bound.left = x * self->scale;
    self->bound.top = y * self->scale;
    gl_render_selection(self);
    gl_render_params(self, &color);
    if (self->editable == 1) {
      gl_render_cursor(self);
    }
  }
}

void gl_render_edit(edit_t *self, float x, float y) {
  if (self == NULL) return;
  self->bound.left = x * self->scale;
  self->bound.top = y * self->scale;
  if (self->status == UPDATED) {
    gl_render_selection(self);
    gl_render_params(self, NULL);
    if (self->editable == 1) {
      gl_render_cursor(self);
    }
  }
}

float measure_text(font_t *font, char *text, int count) {
  float dx, dy;
  sth_measure(font->stash, font->id, font->size, -1, text, count, &dx, &dy);
  return dx;
}

void update_cursor_pos(buffer_t *self) {
  int cur_row = self->cursor_row;
  if (cur_row < 0 || self->line_count <= 0) {
    return;
  }
  // if (cur_row >= (self->line_count - 1)) {
  //   cur_row = self->line_count - 1;
  // }
  if (self->lines[cur_row]->texts == NULL) {
    return;
  }
  self->cursor_y = cur_row * self->font->stash->fonts->lineh * self->font->size;
  self->cursor_x =
      measure_text(self->font, self->lines[cur_row]->texts, self->cursor_col);
}

void gl_edit_cursor_move_left(buffer_t *self) {
  if (self->cursor_col > 0) {
    self->cursor_col--;
  } else if (self->cursor_row > 0) {
    gl_edit_cursor_move_up(self);
    int len = self->lines[self->cursor_row]->count;
    self->cursor_col = len;
  }
}

void gl_edit_cursor_move_right(buffer_t *self) {
  int cur_row = self->cursor_row;
  if (cur_row >= (self->line_count - 1)) {
    cur_row = self->line_count - 1;
  }
  int len = self->lines[cur_row]->count;
  if (self->cursor_col <= (len - 1)) {
    self->cursor_col++;
  } else if (self->cursor_row < (self->line_count - 1)) {
    gl_edit_cursor_move_down(self);
    self->cursor_col = 0;
  }
}

void gl_edit_cursor_move_up(buffer_t *self) {
  if (self->cursor_row > 0) {
    self->cursor_row--;
    if (self->cursor_col >= (self->lines[self->cursor_row]->count - 1)) {
      self->cursor_col = self->lines[self->cursor_row]->count - 1;
      if (self->cursor_col < 0) self->cursor_col = 0;
    }
  }
}

void gl_edit_cursor_move_down(buffer_t *self) {
  if (self->cursor_row < (self->line_count - 1)) {
    self->cursor_row++;
    if (self->cursor_col >= (self->lines[self->cursor_row]->count - 1)) {
      self->cursor_col = self->lines[self->cursor_row]->count - 1;
      if (self->cursor_col < 0) self->cursor_col = 0;
    }
  }
}

void gl_edit_mouse_motion_event(edit_t *self, float x, float y) {
  // printf("gl_edit_mouse_motion_event %f,%f\n", x, y);
  if (self->select_press == 1) {
    pos_to_cursor(self->buffer, x - self->scroll_x, y - self->scroll_y);
    self->select_end[0] = self->buffer->cursor_row;
    self->select_end[1] = self->buffer->cursor_col;
  }
}

void gl_edit_mouse_event(edit_t *self, int action, float x, float y) {
  // printf("gl_edit_mouse_event %d %f,%f\n", action, x, y);

  if (action == 1) {  // press mouse button
    pos_to_cursor(self->buffer, x - self->scroll_x, y - self->scroll_y);
    self->select_start[0] = self->buffer->cursor_row;
    self->select_start[1] = self->buffer->cursor_col;
    self->select_end[0] = self->buffer->cursor_row;
    self->select_end[1] = self->buffer->cursor_col;
  } else if (action == 0) {  // release mouse button
    pos_to_cursor(self->buffer, x - self->scroll_x, y - self->scroll_y);
    self->select_end[0] = self->buffer->cursor_row;
    self->select_end[1] = self->buffer->cursor_col;
    printf("start %d,%d end %d,%d\n", self->select_start[0],
           self->select_start[1], self->select_end[0], self->select_end[1]);
    // printf("gl_get_selection %s\n", gl_get_selection(self));
  }
  self->select_press = action;
}

void reset_selection(edit_t *self) {
  self->select_start[0] = self->buffer->cursor_row;
  self->select_start[1] = self->buffer->cursor_col;
  self->select_end[0] = self->buffer->cursor_row;
  self->select_end[1] = self->buffer->cursor_col;
}

void reset_delete_selection(edit_t *self) {
  int start_row = self->select_start[0];
  int start_col = self->select_start[1];
  if (self->select_start[0] > self->select_end[0]) {
    start_row = self->select_end[0];
    start_col = self->select_end[1];
    self->select_start[0] = start_row;
    self->select_start[1] = start_col;
  } else {
    self->select_end[0] = start_row;
    self->select_end[1] = start_col;
  }
  self->buffer->cursor_row = start_row;
  self->buffer->cursor_col = start_col;
}

void gl_render_line_selected(mvp_t *mvp, line_t *line, int start, int end,
                             int color) {
  // printf("gl_render_line_selected %d,%d\n", start, end);

  float b = (color & 0xff) / 255.0;
  float g = (color >> 8 & 0xff) / 255.0;
  float r = (color >> 16 & 0xff) / 255.0;
  float a = (color >> 24 & 0xff) / 255.0;
  float startx = 0;
  float endx = 0;
  if (line->count == 0 || start == end) {
    endx = line->font->stash->fonts->lineh * line->font->size / 2;
  } else {
    startx = measure_text(line->font, line->texts, start);
    endx = measure_text(line->font, line->texts, end);
  }
  // printf("%d,%d==> %f to %f\n", start, end, startx, endx);
  draw_solid_quad(mvp, line->sx + startx, line->sy, line->sx + endx,
                  line->sy + line->height +
                      line->font->stash->fonts->lineh * line->font->size / 2,
                  r, g, b, a);
}

void gl_render_selection(edit_t *self) {
  if (self->select_start[0] == self->select_end[0] &&
      self->select_start[1] == self->select_end[1]) {
    return;
  }
  buffer_t *buffer = self->buffer;
  int color = self->selected_color;
  int row_start = self->select_start[0];
  int row_end = self->select_end[0];
  if (row_start > row_end) {
    row_start = self->select_end[0];
    row_end = self->select_start[0];
  }

  for (int i = row_start; i <= row_end; i++) {
    line_t *line = buffer->lines[i];
    int start = 0;
    int end = line->count;
    if (self->select_start[0] > self->select_end[0]) {
      if (i == row_start) {
        start = self->select_end[1];
      }
      if (i == row_end) {
        end = self->select_start[1];
      }
    } else {
      if (i == row_start) {
        start = self->select_start[1];
      }
      if (i == row_end) {
        end = self->select_end[1];
      }
    }
    // printf("start=%d end=%d\n", start, end);
    gl_render_line_selected(&self->mvp, line, start, end, color);
  }
}

int gl_edit_get_selection_length(edit_t *self) {
  int total = 0;
  buffer_t *buffer = self->buffer;
  int crlf_len = strlen(self->crlf);
  int row_start = self->select_start[0];
  int row_end = self->select_end[0];
  if (row_start > row_end) {
    row_start = self->select_end[0];
    row_end = self->select_start[0];
  }
  for (int i = row_start; i <= row_end; i++) {
    line_t *line = buffer->lines[i];
    int start = 0;
    int end = line->count;
    if (self->select_start[0] > self->select_end[0]) {
      if (i == row_start) {
        start = self->select_end[1];
      }
      if (i == row_end) {
        end = self->select_start[1];
      }
    } else {
      if (i == row_start) {
        start = self->select_start[1];
      }
      if (i == row_end) {
        end = self->select_end[1];
      }
    }
    total += abs(end - start);
    total += crlf_len;
  }
  return total;
}

char *gl_get_selection(edit_t *self) {
  int total = gl_edit_get_selection_length(self);
  int crlf_len = strlen(self->crlf);
  buffer_t *buffer = self->buffer;

  if (self->select_text == NULL) {
    self->select_text = malloc(total * 2);
    self->select_text_avail = total * 2;
  }
  if (self->texts_avail < total) {
    printf("no enough select texts avail=%d total=%d\n", self->texts_avail,
           total);
    int avail = self->texts_avail + total;
    char *old_texts = self->select_text;
    char *new_texts = malloc(avail);
    strcpy(new_texts, old_texts);
    self->select_text = new_texts;
    self->select_text_avail = avail;
    free(old_texts);
  }
  int row_start = self->select_start[0];
  int row_end = self->select_end[0];
  if (row_start > row_end) {  // selection from  end to start
    row_start = self->select_end[0];
    row_end = self->select_start[0];
  }
  int pos = 0;
  for (int i = row_start; i <= row_end; i++) {
    line_t *line = buffer->lines[i];
    int start = 0;
    int end = line->actual;
    // printf("self->select_start[0]=%d self->select_end[0]=%d\n",
    //        self->select_start[0], self->select_end[0]);

    if (self->select_start[0] > self->select_end[0]) {
      if (i == row_start) {
        start = line_get_col_index(line, self->select_end[1]);
      }
      if (i == row_end) {
        end = line_get_col_index(line, self->select_start[1]);
      }
    } else {
      if (i == row_start) {
        start = line_get_col_index(line, self->select_start[1]);
      }
      if (i == row_end) {
        end = line_get_col_index(line, self->select_end[1]);
      }
    }
    if (self->select_start[0] == self->select_end[0]) {
      if (start > end) {
        int tmp = start;
        start = end;
        end = tmp;
      }
    }
    // printf("--------->self->select_start[1]=%d self->select_end[1]=%d
    // %d,%d\n",
    //        self->select_start[1], self->select_end[1], start, end);
    // printf("&self->select_text[pos]=%p
    // &line->texts[start]=%p\n",&self->select_text[pos], &line->texts[start]);

    memcpy(&self->select_text[pos], &line->texts[start], end - start);
    pos += (end - start);
    memcpy(&self->select_text[pos], self->crlf, crlf_len);
    pos += crlf_len;
  }
  self->select_text[pos - 1] = 0;
  return self->select_text;
}

// events
void gl_edit_char_event(edit_t *self, int ch, int mods) {
  if (self != NULL) {
    // int len = utf8_surrogate_len(input);
    char buf[10] = {0};
    utf8_encode(buf, ch);
    printf("gl_edit_char_event %s\n", buf);
    buffer_t *buffer = self->buffer;
    line_insert_text(buffer->lines[buffer->cursor_row], buffer->cursor_col,
                     buf);
    gl_edit_cursor_move_right(buffer);
    update_cursor_pos(buffer);
  }
}

void gl_edit_key_event(edit_t *self, int key, int scancode, int action,
                       int mods) {
  printf("gl_edit_key_event %d %d\n", key, action);
  if (self != NULL && (action == 1 || action == 2)) {
    buffer_t *buffer = self->buffer;
    if (key == 263) {  // left
      gl_edit_cursor_move_left(buffer);
      update_cursor_pos(buffer);
    } else if (key == 262) {  // right
      gl_edit_cursor_move_right(buffer);
      update_cursor_pos(buffer);
    } else if (key == 265) {  // up
      gl_edit_cursor_move_up(buffer);
      update_cursor_pos(buffer);

    } else if (key == 264) {  // down
      gl_edit_cursor_move_down(buffer);
      update_cursor_pos(buffer);
    } else if (key == 257) {  // enter
      // buffer_insert_line_text(buffer,buffer->cursor_row+1,"\n");
      buffer_split_line(buffer, buffer->cursor_row, buffer->cursor_col);
      gl_edit_cursor_move_down(buffer);
      buffer->cursor_col = 0;
      update_cursor_pos(buffer);
    } else if (key == 259) {  // backspace
      if (gl_edit_get_selection_length(self) > 1) {
        buffer_delete_text(buffer, self->select_start[0], self->select_start[1],
                           self->select_end[0], self->select_end[1]);
        reset_delete_selection(self);
      } else {
        if (buffer->cursor_col <= 0 && buffer->cursor_row > 0) {
          gl_edit_cursor_move_left(buffer);
          buffer_merge_lines(buffer, buffer->cursor_row, 1);
        } else {
          gl_edit_cursor_move_left(buffer);
          buffer_delete_line_char(buffer, buffer->cursor_row,
                                  buffer->cursor_col);
        }
      }
      update_cursor_pos(buffer);
    }
    if (buffer->cursor_row < buffer->line_count) {
      printf("row=%d col=%d line_cols=%d  count=%d actual=%d text=",
             buffer->cursor_row, buffer->cursor_col,
             buffer->lines[buffer->cursor_row]->count, buffer->line_count,
             buffer->lines[buffer->cursor_row]->actual);
      // print_string(buffer->lines[buffer->cursor_row]->texts,
      //              buffer->lines[buffer->cursor_row]->actual);
      // printf("\n");
    }
  }
}

void gl_render_prepare_string(mvp_t *mvp, font_t *font) {
  glUseProgram(mvp->shader);
  glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                     mvp->model.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                     mvp->view.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                     mvp->projection.data);
  sth_begin_draw(font->stash);
}

void gl_render_end_string(font_t *font) { sth_end_draw(font->stash); }

void gl_render_string(font_t *font, float size, char *text, float sx, float sy,
                      float *dx, float *dy, int color) {
  float b = (color & 0xff) / 255.0;
  float g = (color >> 8 & 0xff) / 255.0;
  float r = (color >> 16 & 0xff) / 255.0;
  float a = (color >> 24 & 0xff) / 255.0;

  sth_draw_text(font->stash, font->id, size, sx, sy, -1, -1, text, r, g, b, a,
                dx, dy);
}

void gl_render_cursor(edit_t *self) {
  float dx = 0, dy = 0;
  buffer_t *buffer = self->buffer;
  float sx = self->bound.left;
  float sy = self->bound.top;

  // gl_render_prepare_string(&self->mvp, buffer->font);
  sth_begin_draw(self->buffer->font->stash);
  // printf("buffer->cursor_x %f\n", buffer->cursor_x + sx);
  gl_render_string(buffer->font, buffer->font->size, "|",
                   buffer->cursor_x + sx - 6.0, buffer->cursor_y + sy, &dx, &dy,
                   self->cursor_color);
  // gl_render_end_string(buffer->font);
  sth_end_draw(self->buffer->font->stash);

  /*draw_solid_quad(&self->mvp, self->buffer->cursor_x, self->buffer->cursor_y,
                  self->buffer->cursor_x + 4.0, self->buffer->cursor_y
                  + 20.0, 1.0, 0.0, 0.0, 1.0);
  draw_solid_quad(&self->mvp, 100.0, 100.0, 120.0, 120.0, 255.0, 255.0, 255.0,
  0.5);*/
}

void pos_to_cursor(buffer_t *buffer, float x, float y) {
  // printf("xy= %f %f\n", x, y);
  float dy = 0;
  int row = 0;
  for (int i = 0; i < buffer->line_count; i++) {
    if (y * buffer->scale >= dy &&
        y * buffer->scale < (dy + buffer->lines[i]->height)) {
      break;
    }
    row++;
    dy += buffer->lines[i]->height;
  }
  if (row >= buffer->line_count) return;
  font_t *font = buffer->font;
  int col = sth_pos(font->stash, font->id, font->size, x * buffer->scale,
                    buffer->lines[row]->texts, buffer->lines[row]->count);

  // printf("row is %d col is %d  text=%s\n", row, col,
  // buffer->lines[row]->texts);
  if (col < 0) {
    col = buffer->lines[row]->count;
  }
  buffer->cursor_col = col;
  buffer->cursor_row = row;
  // printf("#x %f y %f\n", buffer->cursor_x, buffer->cursor_y);
  update_cursor_pos(buffer);
  // printf("x %f y %f\n", buffer->cursor_x, buffer->cursor_y);
}

void gl_edit_set_editable(edit_t *self, int v) {
  if (self != NULL) {
    self->editable = v;
  }
}
void gl_edit_set_scroll(edit_t *self, float x, float y) {
  if (self != NULL) {
    self->scroll_x = x;
    self->scroll_y = y;
  }
  // printf("gl_edit_set_scroll %f %f\n", x, y);
}

void gl_edit_set_select_color(edit_t *self, int color) {
  self->selected_color = color;
}

void gl_edit_set_cursor_color(edit_t *self, int color) {
  self->cursor_color = color;
}

edit_t *gl_new_edit(int shader, float w, float h, float width, float height) {
  edit_t *self = malloc(sizeof(edit_t));
  if (!self) {
    return self;
  }
  self->editable = 1;
  self->font_size = 38.0;
  self->font_name = "Roboto-Regular.ttf";
  self->texts = NULL;
  self->texts_avail = 0;
  self->crlf = "\n";
  self->status = UPDATED;
  self->scroll_x = 0;
  self->scroll_y = 0;
  self->cursor_color = 0xffF8F8F0;
  self->selected_color = 0xffff0000;
  self->selected_bg_color = 0xff49483E;
  self->select_text = NULL;
  self->select_text_avail = 0;
  self->select_start[0] = 0;
  self->select_start[1] = 0;
  self->select_end[0] = 0;
  self->select_end[1] = 0;
  self->scale = 2;
  self->bound.width = w * self->scale;
  self->bound.height = h * self->scale;
  self->bound.left = 0;
  self->bound.top = 0;
  self->window_width = width;
  self->window_height = height;
  self->colors = NULL;
  self->colors_avail = 0;
  self->color = 0xffffffff;
  self->font = new_font(self->font_name, self->font_size);
  self->buffer = new_buffer();
  self->buffer->font = self->font;
  self->buffer->width = self->bound.width;
  self->buffer->color = &self->color;
  self->buffer->scale = self->scale;

  update_cursor_pos(self->buffer);

  self->mvp.shader = shader;
  mat4_set_identity(&self->mvp.projection);
  mat4_set_identity(&self->mvp.model);
  mat4_set_identity(&self->mvp.view);
  mat4_set_orthographic(&self->mvp.projection, 0, width * self->scale,
                        height * self->scale, 0, -1, 1);
  return self;
}

void gl_resize_edit_window(edit_t *self, float width, float height) {
  glUseProgram(self->mvp.shader);
  mat4_set_orthographic(&self->mvp.projection, 0, width * self->scale,
                        height * self->scale, 0, -1, 1);
  mvp_set_mvp(&self->mvp);
}

void gl_add_edit_text(edit_t *self, char *text) {
  printf("gl_add_edit_text=> %s", text);
  // string_to_buffer_lines(self->buffer, text, NULL);
}

void gl_set_edit_text(edit_t *self, char *text) {
  // printf("gl_set_edit_text=> %s", text);
  self->status = UPDATING;
  string_to_buffer_lines(self->buffer, text, NULL);
  self->status = UPDATED;
}

int gl_get_edit_text_len(edit_t *self) {
  return buffer_total_text_length(self->buffer);
}
float gl_get_edit_height(edit_t *self) {
  if (self == NULL) return 0.0;
  return buffer_height(self->buffer);
}

char *gl_get_edit_text(edit_t *self) {
  buffer_t *buffer = self->buffer;
  int total = buffer_total_text_length(buffer);
  if (self->texts == NULL) {
    self->texts = malloc(total * 2);
    self->texts_avail = total * 2;
  }
  int crlf_len = strlen(self->crlf);
  if (self->texts_avail < total) {
    printf("no enough editor texts avail=%d total=%d\n", self->texts_avail,
           total);
    int avail = self->texts_avail + total + buffer->line_count * crlf_len;
    char *old_texts = self->texts;
    char *new_texts = malloc(avail);
    strcpy(new_texts, old_texts);
    self->texts = new_texts;
    self->texts_avail = avail;
    free(old_texts);
  }
  int pos = 0;
  for (int i = 0; i < buffer->line_count; i++) {
    line_t *line = buffer->lines[i];
    // printf("text %d:%s\n", i, line->texts);
    // printf("total len=%d %d\n", self->texts_avail, pos);
    // printf("%2d actual=%2d %2d ", i, line->actual, strlen(line->texts));
    // print_string(line->texts, line->actual);
    // printf("\n");

    memcpy(&self->texts[pos], line->texts, line->actual);
    pos += line->actual;
    memcpy(&self->texts[pos], self->crlf, crlf_len);
    pos += crlf_len;
  }
  self->texts[pos] = 0;
  // printf("get_text:\n");
  // print_string(self->texts, strlen(self->texts));
  // printf("\n");

  return self->texts;
}

void buffer_color(buffer_t *buffer, void *colors) {
  int *text_colors = colors;
  int count = 0;
  for (int i = 0; i < buffer->line_count; i++) {
    // printf("buffer line %d count %d
    // %d\n",i,buffer->lines[i]->count,buffer->lines[i]->actual);
    // if(buffer->lines[i]->count==1) continue;
    buffer->lines[i]->colors = &text_colors[count];
    count += buffer->lines[i]->count;
  }
}

// strings keywords comments
void gl_edit_set_highlight(edit_t *self, void *colors) {
  if (colors == NULL) return;
  // buffer_color(self->buffer, colors);
  // self->colors = colors;
}

void gl_edit_update_highlight(edit_t *self) {
  buffer_color(self->buffer, self->colors);
}

void *gl_edit_get_highlight(edit_t *self) {
  int total = buffer_total_text_length(self->buffer);
  if (self->colors_avail < total) {
    int alloc_size = 4 * total;
    void *new_colors = malloc(alloc_size);
    if (self->colors != NULL) {
      memcpy(new_colors, self->colors, total);
    }
    void *old_colors = self->colors;
    self->colors = new_colors;
    self->colors_avail = alloc_size;
    free(old_colors);
  }
  return self->colors;
}

void gl_edit_set_color(edit_t *self, int color) {
  printf("gl_edit_set_color %x\n", color);
  self->color = color;
  // self->color=0xff0000ff;
}

void gl_edit_set_foreground(edit_t *self, int color) {
  printf("gl_edit_set_foreground %x\n", color);
  gl_edit_set_color(self, color);
}

void gl_edit_set_background(edit_t *self, int color) {
  printf("gl_edit_set_background\n");
  self->bg_color = color;
}

void gl_edit_set_font_size(edit_t *self, float size) {
  font_t *font = self->font;
  if (font == NULL) return;
  self->font->size = size;
}

void gl_edit_set_font_name(edit_t *self, char *name) {
  font_t *font = self->font;
  if (font == NULL) return;

  if (strcmp(name, font->name) != 0) {
    float size = font->size;
    sth_end_draw(font->stash);
    destroy_font(font);
    font = new_font(name, size);
  }
}

void gl_edit_set_font(edit_t *self, char *name, float size) {
  font_t *font = self->font;
  if (font == NULL) return;
  if (name != NULL) {
    gl_edit_set_font_size(self, size);
    gl_edit_set_font_name(self, name);
  } else {
    gl_edit_set_font_size(self, size);
  }
}

void gl_edit_set_font_line_height(edit_t *self, float height) {
  font_t *font = self->font;
  if (font != NULL) {
    if (font->stash != NULL) font->stash->fonts->lineh = height;
  }
}

void insert_char(char *str, int n, int position, char value) {
  for (int c = n - 1; c >= position; c--) {
    str[c + 1] = str[c];
  }
  str[position] = value;
}

/**string operation**/
// no check size
void insert_string(char *base, int n, int position, char *texts, int len) {
  // char *str = (char *)malloc(strlen(base) + len + 1);
  // strncpy(str, base, position);
  // str[position] = 0;
  // strcat(str, texts);
  // strcat(str, base + position);
  // strcpy(base, str);
  // free(str);

  for (int i = 0; i < len; i++) {
    // printf("insert_string at %d \n", position + i);
    insert_char(base, n, position + i, texts[i]);
  }
}

void remove_string(char *str, int pos, int len) {
  memmove(str + pos, str + pos + len, strlen(str + pos + len));
}

void replace_string(char *str, int pos, char *seed) {}