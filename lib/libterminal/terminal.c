/*****************************************************************************
 *作者:evilbinary on 2017-09-17 13:52:31.
 *邮箱:rootdebug@163.com
 ******************************************************************************/

#include "terminal.h"
#include <fcntl.h>
#include <signal.h>

extern char **environ;

static void log_tsm(void *data, const char *file, int line, const char *fn,
                    const char *subs, unsigned int sev, const char *format,
                    va_list args) {
  fprintf(stderr, "%d: %s: ", sev, subs);
  vfprintf(stderr, format, args);
  fprintf(stderr, "\n");
}

void hup_handler(int s) {
  printf("Signal received: %s\n", strsignal(s));
  exit(1);
}

void io_handler(int s) { printf("Signal io_handler: %d\n", strsignal(s)); }

/* called when data has been read from the fd slave -> master  (vte input )*/
static void term_read_cb(struct shl_pty *pty, char *u8, size_t len,
                         void *data) {
  terminal *term = (terminal *)data;
  // printf("term_read_cb %s\n", u8);
  tsm_vte_input(term->vte, u8, len);
}

/* called when there is data to be written to the fd master -> slave  (vte
 * output) */
static void term_write_cb(struct tsm_vte *vtelocal, const char *u8, size_t len,
                          void *data) {
  // printf("term_write_cb %s\n", u8);
  terminal *term = (terminal *)data;
  int r;
  r = shl_pty_write(term->pty, u8, len);
  if (r < 0) {
    printf("could not write to pty, %d\n", r);
  }
}

static int draw_cb(struct tsm_screen *screen, uint32_t id, const uint32_t *ch,
                   size_t len, unsigned int cwidth, unsigned int posx,
                   unsigned int posy, const struct tsm_screen_attr *attr,
                   tsm_age_t age, void *data) {
  terminal *term = (terminal *)data;
  int i;
  float dx, dy;
  uint8_t fr, fg, fb, br, bg, bb;
  unsigned int color;
  if (attr->inverse) {
    fr = attr->br;
    fg = attr->bg;
    fb = attr->bb;
    br = attr->fr;
    bg = attr->fg;
    bb = attr->fb;
  } else {
    fr = attr->fr;
    fg = attr->fg;
    fb = attr->fb;
    br = attr->br;
    bg = attr->bg;
    bb = attr->bb;
  }

  if (!len) {
    // graphic_draw_solid_quad(
    // glColor4ub(br,bg,bb,255);
    // glPolygonMode(GL_FRONT, GL_FILL);
    // glRectf(dx+lw,dy,dx,dy+lh);
  } else {
    // glColor4ub(br,bg,bb,255);
    // glPolygonMode(GL_FRONT, GL_FILL);
    // glRectf(dx+lw,dy,dx,dy+lh);
  }
  // color = glfonsRGBA(fr,fg,fb,255);
  // fonsSetColor(data, color);

  sth_draw_text(term->font->stash, term->font->id, term->font->size, term->x,
                term->y, tsm_screen_get_width(term->console), -1, ch, fr, fg,
                fb, 1.0, &dx, &dy);
  // printf("%f %f\n",term->x,term->y);

  if (posx >= (screen->size_x - 1)) {
    term->x = term->starx;
    term->y = dy + term->lineh;
  } else {
    term->x = dx;
  }

  if (posy > (screen->size_y - 1)) {
    term->x = term->starx;
    term->y = term->stary;
  }

  return 0;
}

void init_pty(terminal *term) {
  pid_t pid;
  pid = shl_pty_open(&term->pty, term_read_cb, term,
                     tsm_screen_get_width(term->console),
                     tsm_screen_get_height(term->console));

  if (pid < 0) {
    perror("fork problem");
  } else if (pid != 0) {
    /* parent, pty master */
    int fd = shl_pty_get_fd(term->pty);
    unsigned oflags = 0;
    /* enable SIGIO signal for this process when it has a ready file descriptor
     */
    signal(SIGIO, &io_handler);
    fcntl(fd, F_SETOWN, getpid());
    oflags = fcntl(fd, F_GETFL);
    fcntl(fd, F_SETFL, oflags | FASYNC);
    /* watch for SIGHUP */
    signal(SIGCHLD, &hup_handler);
  } else {
    /* child, shell */
    char *shell = getenv("SHELL") ?: "/bin/bash";
    char **argv = (char *[]){shell, NULL};
    execve(argv[0], argv, environ);
    /* never reached except on execve error */
    perror("execve error");
    exit(-2);
  }
}

void terminal_resize(terminal *term, float width, float height) {
  if(width<0||height<0) return;
  float w = measure_text(term->font, term->font->size, "W", -1);
  float h = graphic_get_font_height(term->font, term->font->size);
  tsm_screen_resize(term->console, (width* term->scale / w) - 1, (height* term->scale / (h+term->lineh )+2 ));
  shl_pty_resize(term->pty, tsm_screen_get_width(term->console),
                 tsm_screen_get_height(term->console));
}

void terminal_set_mvp(terminal *term, mvp_t *mvp, float width, float height) {
  *term->mvp = *mvp;
  mat4_set_identity(&term->mvp->projection);
  mat4_set_identity(&term->mvp->model);
  mat4_set_identity(&term->mvp->view);
  mat4_set_orthographic(&term->mvp->projection, 0, width * term->scale,
                        height * term->scale, 0, 1, -1);
}

terminal *terminal_create(font_t *font, float size, float width, float height) {
  terminal *term = malloc(sizeof(terminal));
  if (font != NULL) {
    term->font = font;
  } else {
    term->font = new_font("./Roboto-Regular.ttf", size);
  }
  term->lineh = 10.0;
  term->linew = 20.0;
  term->ascender = 10.0;
  term->scale = 2;
  term->x = 0;
  term->y = 0;
  term->mvp = malloc(sizeof(mvp_t));
  term->width=width;
  term->height=height;
  tsm_screen_new(&term->console, log_tsm, 0);
  tsm_vte_new(&term->vte, term->console, term_write_cb, term, log_tsm, 0);
  init_pty(term);

  terminal_resize(term, (int)width , (int)height );
  printf("console width: %d\n", tsm_screen_get_width(term->console));
  printf("console height: %d\n", tsm_screen_get_height(term->console));
  tsm_vte_get_def_attr(term->vte, &term->attr);

  // char* test="\033[31m red \033[0m \n\033[32m green \033[0m\n\033[33m yellow
  // \033[0m"; tsm_vte_input(term->vte, test, strlen(test));
  return term;
}

void terminal_draw(terminal *term, float x, float y) {
  term->x = term->starx;
  term->y = term->stary;
  term->starx = x * term->scale;
  term->stary = y * term->scale;
  if (term->mvp == NULL) return;
  graphic_set_mvp(term->mvp);
  sth_begin_draw(term->font->stash);
  tsm_screen_draw(term->console, draw_cb, term);
  sth_end_draw(term->font->stash);
}
void terminal_render(terminal *term, float x, float y) {
  shl_pty_dispatch(term->pty);
  terminal_draw(term, x, y);
}

void terminal_key_event(terminal *term, int key, int scancode, int action,
                        int mods) {
  if (action == 1) {
    printf("action %d %d %d %d\n", action, scancode, key, mods);
    int mod = 0;
    if (mods & KMOD_CTRL) mod |= TSM_CONTROL_MASK;
    if (mods & KMOD_SHIFT) mod |= TSM_SHIFT_MASK;
    if (mods & KMOD_ALT) mod |= TSM_ALT_MASK;
    if (mods & KMOD_META) mod |= TSM_LOGO_MASK;

    if (key == 265) scancode = XKB_KEY_Up;
    if (key == 264) scancode = XKB_KEY_Down;
    if (key == 263) scancode = XKB_KEY_Left;
    if (key == 262) scancode = XKB_KEY_Right;
    if (key == 257) scancode = XKB_KEY_Return;
    if (key == 259) scancode = XKB_KEY_Delete;
    if (scancode == XKB_KEY_Up || scancode == XKB_KEY_Down ||
        scancode == XKB_KEY_Left || scancode == XKB_KEY_Right ||
        scancode == XKB_KEY_Return || scancode == XKB_KEY_Delete) {
      printf("mode %d key=%d scancode=%0x\n", mod, key, scancode);
      tsm_vte_handle_keyboard(term->vte, scancode, key, mod, key);
      //   terminal_draw(term);
    }
  }
  // tsm_vte_get_def_attr(term->vte, &term->attr);
}
void terminal_char_event(terminal *term, int ch, int mods) {
  char buf[20] = {0};
  sprintf(buf, "%c", ch);
  // tsm_vte_input(term->vte, buf, strlen(buf));
  // printf("terminal_char_event %c\n",buf);
  tsm_vte_handle_keyboard(term->vte, 0, ch, 0, ch);
}

void terminal_destroy(terminal *term) {
  if (term != NULL) {
    free(term);
    shl_pty_close(term->pty);
  }
}
