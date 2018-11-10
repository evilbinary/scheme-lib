/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */
#include "gui.h"


mvp * mvp_create(int shader,int width ,int height){
  mvp* self =malloc(sizeof(mvp));
  self->shader=shader;
  mat4_set_identity(&self->projection);
  mat4_set_identity(&self->model);
  mat4_set_identity(&self->view);
  //mat4_set_orthographic( &self->projection, 0, width*2,height*2,0,-1,1);
  mat4_set_orthographic(&self->projection, 0, width * 2, 0, height * 2, -1, 1);
  
  return self;
}

font* font_create(char* font_name){
  font* self=malloc(sizeof(font));
  self->stash = sth_create(512, 512);
  self->font = sth_add_font(self->stash, font_name);
  return self;
}

long get_time() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

long get_fps() {
    static long fps = 0;
    static long lastTime = 0; // ms
    static long frameCount = 0;
    ++frameCount;
    if (lastTime == 0) {
        lastTime = get_time();
    }

    long curTime = get_time();
    //printf("cur time %ld ==%ld\n",curTime,lastTime);
    if (curTime - lastTime > 1000) { // 取固定时间间隔为1秒
        fps = frameCount;
        frameCount = 0;
        lastTime = curTime;
    }
    return fps;
}

void gl_edit_set_color(edit_t * self,int color){
  self->color=color;
}

void gl_edit_set_markup(edit_t *self, void *m, int index) {
    //printf("gl_edit_set_marku\n");
    //m->font = texture_font_new_from_file( self->atlas, m->size,m->family);
    //self->markup[index]=*m;
}

void gl_markup_set_foreground(void *m, float r, float g, float b, float a) {
    if (m != NULL) {

    }
}

void gl_markup_set_background(void *m, float r, float g, float b, float a) {
    if (m != NULL) {

    }
}

void gl_markup_set_font_size(void *m, float font_size) {
    if (m != NULL) {
        //m->size=font_size;
    }
}

void gl_free_markup(void *m) {
    free(m);
}

void *gl_new_markup(char *name, float font_size) {
    char *font_name = "Roboto-Regular.ttf";
    if (name != NULL) {
        font_name = name;
    }
    return NULL;
}

void gl_edit_set_editable(edit_t *self, int v) {
    if (self != NULL) {
        self->editable = v;
    }
}

edit_t *gl_new_edit(int shader, float w, float h, float width, float height) {
    edit_t *self = malloc(sizeof(edit_t));
    if (!self) {
        return self;
    }
    self->prompt = strdup(">>> ");
    self->shader = shader;
    self->max_input = 0;
    self->input = NULL;
    self->cursor_total = 0;
    self->cursor = 0;
    self->pen.x = self->pen.y = 0;
    self->old_pen.x=self->old_pen.y=0;
    self->editable = 1;
    self->font_size = 38.0;

    self->bound.width = w * 2;
    self->bound.height = h * 2;
    self->bound.left = 0;
    self->bound.top = 0;
    self->window_width = width;
    self->window_height = height;
    self->colors=NULL;
    self->color=0xffffff;
    self->cursor_text= "|";
    self->cursor_x=-1.0;
    self->cursor_y=-1.0;
    self->cursor_current_row=0;
    self->cursor_current_col=0;
    self->cursor_current_cols=0;


    char *font_name = "Roboto-Regular.ttf";


    mat4_set_identity(&self->projection);
    mat4_set_identity(&self->model);
    mat4_set_identity(&self->view);

    //mat4_set_orthographic( &self->projection, 0, width*2,height*2,0,-1,1);
    mat4_set_orthographic(&self->projection, 0, width * 2, 0, height * 2, -1, 1);

    self->stash = sth_create(512, 512);
    self->font = sth_add_font(self->stash, font_name);
    //sth_add_font_from_memory(self->stash, self->data);

    //printf("load font %d\n",self->regular_font);
    
    return self;
}

void gl_edit_set_font(edit_t *self,char* font_name,float size){
  if(font_name!=NULL){
    self->font = sth_add_font(self->stash, font_name);
  }
  if(size>0){
    self->font_size=size;
  }
}

void gl_resize_edit_window(edit_t *self, float width, float height) {
    mat4_set_orthographic(&self->projection, 0, width * 2, 0, height * 2, -1, 1);
}


//no check size
void insert_string(char *destination, int pos, char *seed) {
    char *strC;
    strC = (char *) malloc(strlen(destination) + strlen(seed) + 1);
    strncpy(strC, destination, pos);
    strC[pos] = '\0';
    strcat(strC, seed);
    strcat(strC, destination + pos);
    strcpy(destination, strC);
    free(strC);
}

void remove_string(char *str, int pos, int len) {
  memmove(str+pos,str+pos+len,strlen(str+pos+len));
}

void replace_string(char *str, int pos, char *seed) {

}


int get_text_index(edit_t *self, int index) {
    int i;
    int count = 0;
    for (i = 0; i < strlen(self->input); i += utf8_surrogate_len(self->input + i)) {
        //printf(" count=%d index=%d\n",count,index);
        if (count == index) {
            return i;
        }
        count++;
    }
    return -1;
}


void gl_add_edit_text(edit_t *self, char *text) {

    size_t len = 0;
    size_t text_len = strlen(text);
    if (self->input == NULL) {
        size_t alloc_size = text_len;
        self->input = malloc(alloc_size);
        self->max_input = alloc_size;
    }
    len = strlen(self->input);
    //printf("len=%d max_input=%d text_len=%d \n",len,self->max_input,text_len);

    if ((len + text_len + self->cursor) >= self->max_input) {
        size_t alloc_size = 0;
        alloc_size = self->max_input * 2;
        if (alloc_size < text_len) {
            alloc_size = text_len + 10;
        }
        //printf(" alloc_size=>%d\n",alloc_size);
        char *new_input = malloc(alloc_size);
        strncpy(new_input, self->input, strlen(self->input));
        char *old_input = self->input;
        self->input = new_input;
        self->max_input = alloc_size;
        if (old_input != NULL) {
            free(old_input);
        }
    }

    if (len == 0) {
        strcpy(self->input, text);
    } else {
        int index = get_text_index(self, self->cursor);
        //printf("index=%d cursor=%d\n",index,self->cursor);
        if (index == 1) {
            index = 0;
        }
        if (index >= 0 && index < self->max_input) {
            //printf("insert  %d max_input=>%d\n",index,self->max_input );
            insert_string(self->input, index, text);
	    /* int ulen=utf8_strlen(text); */
	    /* for(int i=0;i<ulen;i++){ */
	    /*   self->cursor_current_col++; */
	    /* } */
	    calc_cursor_pos(self);

        } else {
            printf("insert err index=%d\n", index);
        }
    }

    //strcpy(self->input,text);
    self->cursor_total += utf8_strlen(text);
    
}

void gl_set_edit_text(edit_t *self, char *text) {
    self->cursor = 0;
    if (self->input != NULL) {
        memset(self->input, 0, strlen(self->input));
    }
    gl_add_edit_text(self, text);
}
char* gl_get_edit_text(edit_t *self){
  return self->input;
}

//strings keywords comments
void gl_edit_set_highlight(edit_t *self,void* colors) {
    self->colors =colors;
}

void
draw_solid_quad(edit_t *self, float x1, float y1, float x2, float y2, float r, float g, float b,
                float a) {
    glUseProgram(self->shader);
    {

        //glDisable( GL_TEXTURE_2D );
        //glActiveTexture(GL_TEXTURE1);
        glEnable(GL_TEXTURE_2D);
        glUniform1i(glGetUniformLocation(self->shader, "texture"), 0);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "model"),
                           1, 0, self->model.data);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "view"),
                           1, 0, self->view.data);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "projection"),
                           1, 0, self->projection.data);

        GLfloat vVertices[] = {x1, y1,
                               x2, y1,
                               x2, y2,
                               x1, y2};
        float color[] = {r, g, b, a,
                         r, g, b, a,
                         r, g, b, a,
                         r, g, b, a};

        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, vVertices);
        glEnableVertexAttribArray(0);

        glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 0, color);
        glEnableVertexAttribArray(2);

        glDrawArrays(GL_QUADS, 0, 4);
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(2);
    }
}

static int idx = 1;
static int idx2 = 1;

char* get_next_line(edit_t *self,char* s,int * n,int *len,float *cursor_x,float * cursor_y){
  int row=0;
  int col=0;
  struct sth_font *fnt = NULL;
  int count = 0;
  short isize = (short) (self->font_size * 10.0f);
  unsigned int codepoint;
  unsigned int state = 0;
  struct sth_glyph *glyph = NULL;
  int last_count=0;
  *n=0;
  *len=0;
  if (s == NULL||*s==0)
    return NULL;
  
  fnt = self->stash->fonts;

  float sx = *cursor_x;
  float sy = *cursor_y;
  
  for (; *s; ++s,(*len)++ ) {
    if (decutf8(&state, &codepoint, *(unsigned char *) s)) {
      continue;
    }
    //printf("%x ",*s);
    if(*s==0x0a ) {
      *cursor_y -= self->stash->fonts->lineh * self->font_size;
      *cursor_x = sx;
      col=0;
      row++;
      count++;
      //printf("break %d %d %c\n",count,*len,*s);
      break;
    }
    glyph = get_glyph(self->stash, fnt, codepoint, isize);
    float advance=0.0;
    if (!glyph) {
      count++;
      //printf("%x\n",*s);
      continue;
    }else{
      advance=sth_get_advace(self->stash, fnt, glyph, isize);
    }
    //printf("%c",*s);
    
    if (self->bound.width > 0 &&
	*cursor_x >= (self->bound.width + sx - advance)) {
      *cursor_y -= self->stash->fonts->lineh * self->font_size;
      *cursor_x = sx;
      col=0;
      row++;
      //printf("break2 %d %d %c\n",count,len,*s);
      break;
    }
    count++;
    col++;
    *cursor_x += advance;
  }
  if(n!=NULL){
    *n=count;
  }

  return s;
}
void get_line_col(edit_t *self,char* s,int * n,int *len,float *cursor_x,float * cursor_y){
  int count=0;
  int col=0;
  float sx = *cursor_x;

  struct sth_font *fnt = NULL;
  unsigned int state = 0;
  short isize = (short) (self->font_size * 10.0f);
  unsigned int codepoint;
  struct sth_glyph *glyph = NULL;
  fnt = self->stash->fonts;
  decutf8(&state, &codepoint, *(unsigned char *)s);
  glyph = get_glyph(self->stash, fnt, codepoint, isize);

  for (; *s; ++s,(*len)++ ) {
    if (decutf8(&state, &codepoint, *(unsigned char *) s)) {
      continue;
    }
    if(*s==0x0a) {
      //*cursor_x = sx;
      //*cursor_y -= self->stash->fonts->lineh * self->font_size;
      //self->cursor_current_row++;
      col++;
      count++;
      break;
    }
    glyph = get_glyph(self->stash, fnt, codepoint, isize);
    float advance=0.0;
    if (!glyph) {
      count++;
      col++;
      continue;
    }else{
      advance=sth_get_advace(self->stash, fnt, glyph, isize);
    }
    if (self->bound.width > 0 &&
    	*cursor_x >= (self->bound.width + sx - advance)) {
      *cursor_x = sx;
      *cursor_y -= self->stash->fonts->lineh * self->font_size;
      self->cursor_current_row++;
      col=0;
      break;
    }
    if(count==self->cursor_current_col){
      break;
    }
    col++;
    count++;
    *cursor_x += advance;
  }
  if(n!=NULL){
    *n=col;
  }

}

void calc_pos_cursor(edit_t * self,float x,float y){

  float cursor_x = self->pen.x;
  float cursor_y = self->pen.y;
  int row=0;
  int col=0;
  int last_col=col;
  struct sth_font *fnt = NULL;
  char *s = self->input;
  int count = 0;
  short isize = (short) (self->font_size * 10.0f);
  unsigned int codepoint;
  unsigned int state = 0;
  struct sth_glyph *glyph = NULL;
  int last_count=0;
  if (s == NULL)
    return;
  fnt = self->stash->fonts;
  decutf8(&state, &codepoint, *(unsigned char *) self->cursor_text);
  glyph = get_glyph(self->stash, fnt, codepoint, isize);

  cursor_x -= +(glyph->xadv) / 2;
  float sx = cursor_x;
  float sy = cursor_y;
  x=x*2.0-glyph->xadv;
  y=y*2.0-self->stash->fonts->lineh * self->font_size;
  
  //printf("==> %f %f\n",cursor_x,cursor_y);
  
  //while(fnt != NULL && fnt->idx != idx2) fnt = fnt->next;
  if (fnt == NULL) {
    printf("calc cursor font is null\n");
    return;
  }
  if (fnt->type != BMFONT && !fnt->data) {
    return;
  }
  int is_in=0;
  for (; *s; s++) {
    if (decutf8(&state, &codepoint, *(unsigned char *) s)) {
      continue;
    }
    
    if(*s==0x0a ){
      cursor_y -= self->stash->fonts->lineh * self->font_size;
      cursor_x = sx;
      col=0;
      row++;
      //count++;
      if(is_in<=0){
      continue;
      }else{
	break;
      }
    }
    glyph = get_glyph(self->stash, fnt, codepoint, isize);
    float advance=0.0;
    if (!glyph) {
      continue;
    }else{
      //advance=sth_get_advace(self->stash, fnt, glyph, isize);
      advance=glyph->xadv;
    }

     if (y<= (self->pen.y-cursor_y) ) {
       last_col=col;
       is_in++;
      if(x<= (cursor_x-self->pen.x)){
	
	break;
      }
    }
    if (self->bound.width > 0 &&
	cursor_x >= (self->bound.width + sx - advance)) {
      cursor_y -= self->stash->fonts->lineh * self->font_size;
      cursor_x = sx;
      col=0;
      row++;
    }

    //printf("calc_pos_cursor %f %f == %f %f\n",x,y,(cursor_x-self->pen.x),(self->pen.y-cursor_y));
   
    //printf("===>%d %d\n",self->cursor,count);
  
    col++;
    count++;
    cursor_x += advance;
  }
  //printf("===> %d %d\n",row,col);
  self->cursor_current_col=col;
  self->cursor_current_row=row;
  self->cursor_x=cursor_x;
  self->cursor_y=cursor_y;

  //calc_cursor_pos(self);
  
}


void calc_cursor_pos(edit_t *self){
  char* s=&self->input[0];
  int n;
  int len;
  float cursor_x=self->pen.x;
  float cursor_y=self->pen.y;
  int i=0;
  char* ss=NULL;
  int row_count=0;
  
  struct sth_font *fnt = NULL;
  short isize = (short) (self->font_size * 10.0f);
  unsigned int codepoint;
  struct sth_glyph *glyph = NULL;
  unsigned int state = 0;
  fnt = self->stash->fonts;
  decutf8(&state, &codepoint, *(unsigned char *)s);
  glyph = get_glyph(self->stash, fnt, codepoint, isize);
  if(glyph==NULL){
    return;
  }
  cursor_x -= glyph->xadv/2.0;
  cursor_y += self->stash->fonts->lineh * self->font_size;
  do{
    //printf("=====%c\n",*s);
    ss=get_next_line(self,s,&n,&len,&cursor_x,&cursor_y);
    /*char *buf=malloc(len+1);
    memset(buf,0,len+1);
    strncpy(buf,s,len);
    printf("%f %f count=%d len=%d %s\n",cursor_x,cursor_y,n,len,buf);
    printf("%d==%d %d %s\n",i,self->cursor_current_row,n,buf);
    free(buf);*/
    
    if(i==self->cursor_current_row){
      int cn;
      int clen;
      //printf("   #%d %d\n",self->cursor_current_row,self->cursor_current_col);

      if(n>0){
	
	get_line_col(self,s,&cn,&clen,&cursor_x,&cursor_y);
	self->cursor_current_col=cn;
      }else{
	self->cursor_current_col=0;
	cursor_x=self->pen.x-glyph->xadv;
      }
      //printf("row=%d cols=%d col=%d\n",i,n,cn);

      break;
    }
    row_count+=n;
    //printf("row_count %d %d\n",row_count,n);
    s=ss+1;
    i++;
    self->cursor_prev_cols=n;
  }while(*ss);
  //printf("   %d %d\n",self->cursor_current_row,self->cursor_current_col);
  //printf("cursor= %f %f %d %d\n",cursor_y,cursor_x,self->cursor_current_row,self->cursor_current_col);
  self->cursor_y=cursor_y;
  self->cursor_x=cursor_x;
  self->cursor_current_cols=n;
  self->cursor=row_count+self->cursor_current_col;
  if(self->cursor_current_col==self->cursor_current_cols){
    self->cursor-=2;
  }
  //printf("cursor %d\n",self->cursor);
}

void gl_render_cursor(edit_t *self) {
  //printf("\n\n");
  //printf("x =%d,%d\n",cursor_x,cursor_y);

  if(self->cursor_x<0 ||self->cursor_y<0||self->pen.x!=self->old_pen.x||self->pen.y!=self->old_pen.y){
    calc_cursor_pos(self);
  }
  
  glUseProgram(self->shader);
  {

    glDisable(GL_TEXTURE_2D);
    //glActiveTexture(GL_TEXTURE1);
    //glEnable( GL_TEXTURE_2D );
    glUniform1i(glGetUniformLocation(self->shader, "texture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(self->shader, "model"),
		       1, 0, self->model.data);
    glUniformMatrix4fv(glGetUniformLocation(self->shader, "view"),
		       1, 0, self->view.data);
    glUniformMatrix4fv(glGetUniformLocation(self->shader, "projection"),
		       1, 0, self->projection.data);

    float dx = 0, dy = 0;
    sth_begin_draw(self->stash);
    sth_draw_text(self->stash, self->font, self->font_size,
		  self->cursor_x, self->cursor_y,
		  self->bound.width, self->bound.height,
		  self->cursor_text, 1.0, 0.0, 0.0, 1.0, &dx, &dy);
    //printf("%f %f %f %f\n",self->pen.x,self->pen.y,self->bound.width,self->bound.height);
    sth_end_draw(self->stash);
  }
  //draw_solid_quad(self,cursor_x,cursor_y,cursor_x+4.0,cursor_y+20.0 ,1.0,0.0,0.0,1.0);
  //draw_solid_quad(self,0.0,0.0,20.0,20.0,1.0,0.0,0.0,1.0);
}

void gl_render_prepare_string(mvp *mvp,font* font){
    glUseProgram(mvp->shader);
    glUniform1i(glGetUniformLocation(mvp->shader, "texture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "model"),
		       1, 0, mvp->model.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "view"),
		       1, 0, mvp->view.data);
    glUniformMatrix4fv(glGetUniformLocation(mvp->shader, "projection"),
		       1, 0, mvp->projection.data);
    sth_begin_draw(font->stash);
}

void gl_render_end_string(font* font){
  sth_end_draw(font->stash);
}

void gl_render_string(
		      font* font,
		      float size,
		      char* text,
		      float sx,float sy,float* dx,float* dy,
		      int color){

    float b=(color&0xff)/255.0;
    float g=(color>>8&0xff)/255.0;
    float r=(color>>16&0xff)/255.0;
    float a=(color>>24&0xff)/255.0;
    
    sth_draw_text(font->stash, font->font, size,
		  sx, sy,
		  -1, -1,
		  text,r, g, b, a, dx, dy); 
  
}

void print_array(void* addr,int len){
  for(int i=0;i<len;i++){
    printf("%x ",*((int*)addr+i) );
      
  }   
  printf("\n\n");
}

void gl_render_string_colors(
		      font* font,
		      float size,
		      float sx,float sy,
		      char* text,
		      void* colors,
		      float width
		      ){
  //printf("==========>addr %lx\n",colors );
  //print_array(colors,1024);
  
  float dx,dy;
  sth_draw_text_colors(font->stash,
		       font->font,
		       size,
  		       sx, sy,
  		       width*2, -1,
  		       text,
		       colors,
		       &dx,&dy);
  
}

void gl_render_params(edit_t *self,void* pcolor) {
    glUseProgram(self->shader);
    {
        glUniform1i(glGetUniformLocation(self->shader, "texture"), 0);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "model"),
                           1, 0, self->model.data);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "view"),
                           1, 0, self->view.data);
        glUniformMatrix4fv(glGetUniformLocation(self->shader, "projection"),
                           1, 0, self->projection.data);

        if (self->input == NULL)
            return;
	//printf("color %p\n",self->colors);
	
	if(self->colors==NULL){
	  float dx = 0, dy = 0;
	  float r,g,b,a;
	  if(pcolor==NULL){
	     b=(self->color&0xff)/255.0;
	     g=(self->color>>8&0xff)/255.0;
	     r=(self->color>>16&0xff)/255.0;
	     a=(self->color>>24&0xff)/255.0;
	    if(a==0){
	      a=1.0;
	    }
	  }else{
	    int color=*(int*)pcolor;
	    b=(color&0xff)/255.0;
	    g=(color>>8&0xff)/255.0;
	    r=(color>>16&0xff)/255.0;
	    a=(color>>24&0xff)/255.0;
	    if(a==0){
	      a=1.0;
	    }
	  }
	  sth_begin_draw(self->stash);
	  sth_draw_text(self->stash, self->font, self->font_size,
			self->pen.x, self->pen.y,
			self->bound.width, self->bound.height,
			self->input, r, g, b, a, &dx, &dy);
	  //printf("%f %f %f %f\n",self->pen.x,self->pen.y,self->bound.width,self->bound.height);
	  sth_end_draw(self->stash);
	}else{
	  float dx,dy;
	  sth_begin_draw(self->stash);
	  sth_draw_text_colors(self->stash,
			       self->font,
			       self->font_size,
			       self->pen.x, self->pen.y,
			       self->bound.width, self->bound.height,
			       self->input,
			       self->colors,
			       &dx,&dy);
	  sth_end_draw(self->stash);
	}

    }
}

void gl_render_edit_once(edit_t *self, float x, float y, char *text,int color) {

    self->cursor = 0;
    if (self->input != NULL) {
        memset(self->input, 0, strlen(self->input));
    }
    gl_add_edit_text(self, text);
    self->bound.left = x * 2;
    self->bound.top = y * 2;
    self->pen.x = x * 2;
    self->pen.y = y * 2;
    gl_render_params(self,&color);
    if (self->editable == 1) {
        gl_render_cursor(self);
    }
}

void gl_render_edit(edit_t *self, float x, float y) {
    self->bound.left = x * 2;
    self->bound.top = y * 2;
    self->old_pen.x=self->pen.x;
    self->old_pen.y=self->pen.y;
    self->pen.x = x * 2;
    self->pen.y = y * 2;
    gl_render_params(self,NULL);
    if (self->editable == 1) {
      gl_render_cursor(self);
    }
}

//events
void gl_edit_char_event(edit_t *self, int ch, int mods) {
    if (self != NULL) {
        char *input = (char *) &ch;
        int len = utf8_surrogate_len(input);
        char buf[10] = {0};
        utf8_encode(buf, ch);
        //printf("get char %d %x len==>%d %s\n",ch,ch,len,buf );
        if (self->cursor <= self->cursor_total) {
            gl_add_edit_text(self, buf);
        }
        //printf("key event %d action=%d self->cursor=%d total=%d\n",key,action, self->cursor,self->cursor_total);
	calc_cursor_pos(self);
    }
}

void gl_edit_cursor_move_left(edit_t *self){
  if(self->cursor>0){
    //printf("current col=%d cols=%d\n",self->cursor_current_col,self->cursor_current_cols);
    if(self->cursor_current_col<=0) {
      //printf("cursor_col <0\n");
      self->cursor_current_row--;
      self->cursor_current_col=self->cursor_prev_cols-2;
    }else if(self->cursor_current_col==self->cursor_current_cols ){
      //printf("cursor_col 3\n");
      if(self->cursor_current_col<=2){
	self->cursor_current_row--;
	self->cursor_current_col=self->cursor_prev_cols-2;
      }else{
	self->cursor_current_col-=3;
      }
      
    }else if(self->cursor_current_col<self->cursor_current_cols){
      self->cursor_current_col--;
    }
    else{
      //printf("cursor_col 4\n");
      //self->cursor_current_col-=2;
      self->cursor_current_row--;
      self->cursor_current_col=self->cursor_prev_cols-2;
    }
  }
}

void gl_edit_cursor_move_right(edit_t *self){
  if (self->cursor < self->cursor_total) {
	  
    if(self->cursor_current_col>=(self->cursor_current_cols-1)){
      self->cursor_current_col=0;
      self->cursor_current_row++;
    }else{
      self->cursor_current_col++;
    }
  }
}

void gl_edit_mouse_event(edit_t * self,int action,float x,float y){
  if(action==1){//press mouse button
    calc_pos_cursor(self,x,y);
  }
}

void gl_edit_key_event(edit_t *self, int key, int scancode, int action, int mods) {
  if (self != NULL && (action == 1 || action == 2)) {
    if (key == 263) {//left
      gl_edit_cursor_move_left(self);
    } else if (key == 262) {//right
      gl_edit_cursor_move_right(self);
    }else if (key==257){ //enter
      gl_add_edit_text(self, "\r\n");
      self->cursor_current_row++;
      self->cursor_current_col=0;
    }else if(key==265){//up
      if(self->cursor_current_row>0){
	self->cursor_current_row--;
      }
    }else if(key==264){//down
      self->cursor_current_row++;
    }else if(key==259){//backspace
      if(self->cursor>0){
	int index = get_text_index(self, self->cursor-1);
	int index2 = get_text_index(self, self->cursor);
	int len = index2-index;
	remove_string(self->input, index,len);
	if(len>0)
	  gl_edit_cursor_move_left(self);
	  
      }
    }
    calc_cursor_pos(self);
  }
}

void gl_delete_edit(edit_t *self) {

}

void glShaderSource2(GLuint shader,
                     GLsizei count,
                     const GLchar *string,
                     const GLint *length) {
    glShaderSource(shader, count, &string, length);
}

