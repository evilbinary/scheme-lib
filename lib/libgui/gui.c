/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com
 */
#include "gui.h"

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
  // mat4_set_orthographic(&self->projection, 0, width * 2, 0, height * 2, -1,
  // 1);
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
  // glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                     mvp->model.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                     mvp->view.data);
  glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                     mvp->projection.data);
}

font_t* font_create(char* font_name) {
  font_t* self = malloc(sizeof(font_t));
  self->stash = sth_create(512, 512);
  self->id = sth_add_font(self->stash, font_name);
  return self;
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
  // printf("cur time %ld ==%ld\n",curTime,lastTime);
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

void draw_solid_quad(mvp_t* mvp, float x1, float y1, float x2, float y2,
                     float r, float g, float b, float a) {
  glUseProgram(mvp->shader);
  {
    // glActiveTexture(GL_TEXTURE0);
    // glEnable(GL_BLEND);
    // glBindTexture(GL_TEXTURE_2D, mvp->shader);
    // glDisable(GL_TEXTURE_2D);
    // glEnable(GL_TEXTURE_2D);
    glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"), 1, 0,
                       mvp->model.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"), 1, 0,
                       mvp->view.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"), 1, 0,
                       mvp->projection.data);

    glUniform1i(glGetUniformLocation(mvp->shader, "type"), 1);
    // printf("mvp->shader=%d %f %f %f %f\n", mvp->shader, x1, y1, x2, y2);

    // float s0 = 0;
    // float s1 = 1;
    // float t0 = 0;
    // float t1 = 1;

    GLfloat vVertices[] = {
        x1, y1, x2, y1, x2, y2, x1, y2,
    };
    // GLfloat vTextCoord[] = {s0, t0, s1, t0, s1, t1, s0, t1};
    float color[] = {r, g, b, a, r, g, b, a, r, g, b, a, r, g, b, a};

    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, vVertices);
    glEnableVertexAttribArray(0);

    // glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, VERT_STRIDE, vTextCoord);
    // glEnableVertexAttribArray(1);

    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, color);
    glEnableVertexAttribArray(2);

    glDrawArrays(GL_QUADS, 0, 4);
    // glDrawArrays(GL_LINES, 0, 4);

    glDisableVertexAttribArray(0);
    // glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
  }
}

void glShaderSource2(GLuint shader, GLsizei count, const GLchar* string,
                     const GLint* length) {
  glShaderSource(shader, count, &string, length);
}
