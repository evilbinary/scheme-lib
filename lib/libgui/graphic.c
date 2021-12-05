/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com
 */
#include "graphic.h"
#include "logger.h"

#ifndef STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#endif

mvp_t* mvp_create(int shader, int width, int height) {
  mvp_t* self = malloc(sizeof(mvp_t));
  self->shader = shader;
  mat4_set_identity(&self->projection);
  mat4_set_identity(&self->model);
  mat4_set_identity(&self->view);
  mat4_set_orthographic(&self->projection, 0, width, height, 0, -1, 1);
  return self;
}
void mvp_set_orthographic(mvp_t* self, float left, float right, float bottom,
                          float top, float znear, float zfar) {
  glUseProgram(self->shader);
  mat4_set_orthographic(&self->projection, left, right, bottom, top, znear,
                        zfar);
  mvp_set_mvp(self);
}

void mvp_set_shader(mvp_t* self, int shader) { self->shader = shader; }

mat4* mvp_get_projection(mvp_t* self) { return &self->projection; }

mat4* mvp_get_model(mvp_t* self) { return &self->model; }

mat4* mvp_get_view(mvp_t* self) { return &self->view; }

int mvp_get_shader(mvp_t* self) { return &self->shader; }

void mvp_set_mvp(mvp_t* mvp) {
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                     mvp->model.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                     mvp->view.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                     mvp->projection.data);
}


font_t * add_fallback_font(font_t* font,char* fallbackname){
  printf("load fallback %s\n",fallbackname);
  font->fallback_id = sth_add_font(font->stash,fallbackname);
  struct sth_font * fnt=get_font_by_index(font->stash,font->id);
  int n=sth_add_fallback_font(fnt,font->fallback_id);
  return font;
}

font_t* new_font(char* name, float size) {
  LOGI("new_font %s %f\n",name,size);
  font_t* font = malloc(sizeof(font_t));
  font->name = malloc(strlen(name));
  strcpy(font->name, name);
  font->size = size;
  font->stash = sth_create(512, 512);
  font->id = sth_add_font(font->stash, name);
  char fallbackname[1024];
  char ext[20];
  int len=strlen(name);
  strcpy(fallbackname,name);
  strcpy(ext,&name[len-4]);
  fallbackname[len-4]=0;
  sprintf(fallbackname,"%s%s%s",fallbackname,"Fallback",ext);
  if (!access(fallbackname, 0)) {
    printf("load fallback %s\n",fallbackname);
    add_fallback_font(font,fallbackname);
  }else{
    strcpy(fallbackname,name);
    fallbackname[len-4]=0;
    sprintf(fallbackname,"%s%s%s",fallbackname,"-Fallback",ext);
    if (!access(fallbackname, 0)) {
      add_fallback_font(font,fallbackname);
    }
  }
  // font->stash->fonts->lineh = font->stash->fonts->lineh * 2.0;
  // printf("new font %f %f\n",font->stash->fonts->lineh,size);
  // LOGI("new_font font=>%p stash=>%p %p\n",font,font->stash,*(font->stash) );
  return font;
}

void copy_stash(struct sth_stash* src,struct sth_stash* target){
  target->bm_textures=src->bm_textures;
  target->tw=src->tw, 
  target->th=src->th;
  target->itw=src->itw;
  target->ith=src->ith;
  target->empty_data=src->empty_data;
  target->tt_textures=src->tt_textures;
  target->bm_textures=src->bm_textures;
  target->fonts=src->fonts;
  target->drawing=src->drawing;
  target->flags=src->flags;
  target->scale=src->scale;
}

font_t* copy_font(font_t* oldfont, float size) {
  font_t* font = malloc(sizeof(font_t));
  font->name = oldfont->name;
  font->size = size;
  struct sth_stash* stash = malloc(sizeof(struct sth_stash));
  // memcpy(stash, oldfont->stash, sizeof(struct sth_stash));
  copy_stash(oldfont->stash,stash);
  font->stash = stash;
  font->id = oldfont->id;
  return font;
}

void destroy_font(font_t* font) {
  if (font == NULL) return;
  sth_delete(font->stash);
  if (font->name != NULL) free(font->name);
  free(font);
  font = NULL;
}

float measure_text(font_t* font, float size, char* text, int count) {
  float dx, dy;
  if (count < 0) {
    count = strlen(text);
  }
  if (size < 0) {
    size = font->size;
  }
  sth_measure(font->stash, font->id, size, -1, text, count, &dx, &dy);
  return dx;
}

long get_time() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

long get_fps() {
  static long fps = 0;
  static long lastTime = 0;  // ms
  static long frameCount = 0;
  ++frameCount;
  if (lastTime == 0) {
    lastTime = get_time();
  }

  long curTime = get_time();
  if (curTime - lastTime > 1000) {  // 取固定时间间隔为1秒
    fps = frameCount;
    frameCount = 0;
    lastTime = curTime;
  }
  return fps;
}

void print_array(void* addr, int len) {
  for (int i = 0; i < len; i++) {
    printf("%x ", *((int*)addr + i));
  }
  printf("\n\n");
}

void graphic_set_draw_type(mvp_t* mvp,int type){
  glUniform1i(glGetUniformLocation(mvp->shader, "type"), type);
}

void graphic_draw_solid_quad(mvp_t* mvp, float x1, float y1, float x2, float y2,
                             float r, float g, float b, float a) {
  glUseProgram(mvp->shader);
  {
    glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                       mvp->model.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                       mvp->view.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                       mvp->projection.data);

    glUniform1i(glGetUniformLocation(mvp->shader, "type"), 0);
    GLfloat vVertices[] = {
        x1, y1, x2, y1, x2, y2, x1, y2,
    };
    float color[] = {r, g, b, a, r, g, b, a, r, g, b, a, r, g, b, a};
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, vVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, color);
    glEnableVertexAttribArray(2);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(2);
  }
}

void glShaderSource2(GLuint shader, GLsizei count, const GLchar* string,
                     const GLint* length) {
  glShaderSource(shader, count, &string, length);
}

void graphic_set_mvp(mvp_t* mvp){
  glUseProgram(mvp->shader);
  glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                     mvp->model.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                     mvp->view.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                     mvp->projection.data);
  glUniform1i(glGetUniformLocation(mvp->shader, "type"), 1);
}

void graphic_render_prepare_string(mvp_t* mvp, font_t* font) {
  graphic_set_mvp(mvp);
  sth_begin_draw(font->stash);
}

void graphic_render_end_string(font_t* font) { sth_end_draw(font->stash); }

graphic_t* graphic_new(int shader, int width, int height, float scale) {
  graphic_t* graphic = malloc(sizeof(graphic_t));
  mvp_t* mvp = mvp_create(shader, width, height);
  graphic->mvp = mvp;
  graphic->width = width;
  graphic->height = height;
  graphic->scale = scale;
  mat4_set_orthographic(&mvp->projection, 0, width * scale, height * scale, 0,
                        -1, 1);

  return graphic;
}

void graphic_render_string(font_t* font, float size, float sx, float sy,
                           char* text, float* dx, float* dy, int color) {
  float b = (color & 0xff) / 255.0;
  float g = (color >> 8 & 0xff) / 255.0;
  float r = (color >> 16 & 0xff) / 255.0;
  float a = (color >> 24 & 0xff) / 255.0;
  if (size < 0) {
    size = font->size;
  }
  sth_draw_text(font->stash, font->id, size, sx, sy, -1, -1, text, r, g, b, a,
                dx, dy);
}
void graphic_render_string_colors(font_t* font, float sx, float sy, char* text,
                                  void* colors, float width) {
  float dx, dy;
  sth_draw_text_colors(font->stash, font->id, font->size, sx, sy, width * 2, -1,
                       text, colors, &dx, &dy);
}

void graphic_render_string_immediate(mvp_t* mvp, font_t* font, float size,
                                     float sx, float sy, char* text, float* dx,
                                     float* dy, int color) {
  float b = (color & 0xff) / 255.0;
  float g = (color >> 8 & 0xff) / 255.0;
  float r = (color >> 16 & 0xff) / 255.0;
  float a = (color >> 24 & 0xff) / 255.0;
  if (size < 0) {
    size = font->size;
  }
  graphic_render_prepare_string(mvp, font);
  sth_draw_text(font->stash, font->id, size, sx, sy, -1, -1, text, r, g, b, a,
                dx, dy);
  graphic_render_end_string(font);
}

float graphic_get_font_lineh(font_t* font, float size) {
  if(font==NULL){
    printf("graphic_get_font_lineh erro\n");
    return 0.0;
  }
  if (size < 0) {
    size = font->size;
  }
  float ascender;
  float descender;
  float lineh;
  sth_vmetrics(font->stash, font->id, size, &ascender, &descender, &lineh);
  return lineh;
}

float graphic_get_font_height(font_t* font, float size) {
  if (size < 0) {
    size = font->size;
  }
  float ascender;
  float descender;
  float lineh;
  sth_vmetrics(font->stash, font->id, size, &ascender, &descender, &lineh);
  return ascender - descender;
}