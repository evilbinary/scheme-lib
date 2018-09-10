/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */


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


long get_time(){
  struct timeval tv;  
  gettimeofday(&tv,NULL);  
  return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

long get_fps(){
    static long fps = 0;
    static long lastTime = 0; // ms
    static long frameCount = 0;
    ++frameCount;
    if(lastTime==0){
      lastTime = get_time();
    }
    
    long curTime = get_time();
    //printf("cur time %ld ==%ld\n",curTime,lastTime);
    if (curTime - lastTime > 1000){ // 取固定时间间隔为1秒
        fps = frameCount;
        frameCount = 0;
        lastTime = curTime;
    }
    return fps;
}


//editor here

typedef struct {
    float x, y, z;
    float s, t;
    float r, g, b, a;
} vertex_t;

typedef struct _edit_t{
  char *prompt;
  char *input;
  size_t max_input;
  size_t cursor;
  size_t cursor_total;
  vec4 bound;
  vec2 pen;
  int shader;
  mat4 model;
  mat4 view;
  mat4 projection;
  int editable;

  struct sth_stash* stash;
  unsigned char* data;
  int font;
  float font_size;

  float window_width;
  float window_height;
  
}edit_t;


void gl_edit_set_markup(edit_t *self,void * m,int index){
  //printf("gl_edit_set_marku\n");
  //m->font = texture_font_new_from_file( self->atlas, m->size,m->family);
  //self->markup[index]=*m;
}

void gl_markup_set_foreground(void *m,float r,float g,float b,float a){
  
  if(m!=NULL){
   
  }
}
void gl_markup_set_background(void *m,float r,float g,float b,float a){
  if(m!=NULL){
    
  }
}

void gl_markup_set_font_size(void *m,float font_size){
  if(m!=NULL){
    //m->size=font_size;
  }
}

void gl_free_markup(void* m){
  free(m);
}

void * gl_new_markup(char* name,float font_size){
  char *font_name   = "Roboto-Regular.ttf";
  if(name!=NULL){
    font_name=name;
  }
  return  NULL;
}

void gl_edit_set_editable(edit_t * self,int v){
  if(self!=NULL){
    self->editable=v;
  }
}

edit_t * gl_new_edit(int shader,float w,float h,float width,float height){
  edit_t *self=malloc(sizeof(edit_t));
  if( !self ){
    return self;
  }
  self->prompt = strdup( ">>> " );
  self->shader=shader;
  self->max_input=0;
  self->input = NULL ;
  self->cursor_total = 0;
  self->cursor=0;
  self->pen.x = self->pen.y = 0;
  self->editable=1;
  self-> font_size=38.0;

  self->bound.width=w*2;
  self->bound.height=h*2;
  self->bound.left=0;
  self->bound.top=0;
  self->window_width=width;
  self->window_height=height;
  
  char *font_name   = "Roboto-Regular.ttf";
  
  
  mat4_set_identity( &self->projection );
  mat4_set_identity( &self->model );
  mat4_set_identity( &self->view );

  //mat4_set_orthographic( &self->projection, 0, width*2,height*2,0,-1,1);
  mat4_set_orthographic( &self->projection, 0, width*2, 0, height*2,-1,1);
  
  self->stash = sth_create(512,512);
  self->font = sth_add_font(self->stash,font_name);
  //sth_add_font_from_memory(self->stash, self->data);
  
  //printf("load font %d\n",self->regular_font);
 
  return self;
}

void gl_resize_edit_window(edit_t *self,float width,float height){
  mat4_set_orthographic( &self->projection, 0, width*2, 0, height*2,-1,1);
}


//no check size
void insert_string(char* destination, int pos, char* seed){
    char * strC;
    strC = (char*)malloc(strlen(destination)+strlen(seed)+1);
    strncpy(strC,destination,pos);
    strC[pos] = '\0';
    strcat(strC,seed);
    strcat(strC,destination+pos);
    strcpy(destination,strC);
    free(strC);
}
void remove_string(char* str,int pos,int len){
  
}
void replace_string(char* str,int pos,char* seed){
  
}


int get_text_index(edit_t *self,int index){
  int i;
  int count=0;
  for(i=0;i<strlen(self->input);i+=utf8_surrogate_len(self->input+i)){
    //printf(" count=%d index=%d\n",count,index);
    if(count==index){
      return i;
    }
    count++;
  }
  return -1;
}



void gl_add_edit_text(edit_t * self,char* text){
  
  size_t len =0;
  size_t text_len=strlen(text);
  if(self->input==NULL){
    size_t alloc_size=text_len;
    self->input=malloc(alloc_size);
    self->max_input=alloc_size;
  }
  len=strlen(self->input);
  //printf("len=%d max_input=%d text_len=%d \n",len,self->max_input,text_len);
  
  if((len + text_len+self->cursor ) >= self->max_input ){
    size_t alloc_size=0;
    alloc_size=self->max_input*2;
    if(alloc_size<text_len){
      alloc_size=text_len+10;
    }
    //printf(" alloc_size=>%d\n",alloc_size);
    char* new_input=malloc(alloc_size);
    strncpy(new_input,self->input,strlen(self->input));
    char* old_input=self->input;
    self->input=new_input;
    self->max_input=alloc_size;
    if(old_input!=NULL){
      free(old_input);
    }
  }
    


  if(len==0){
    strcpy(self->input,text);
  }else{
    int index=get_text_index(self,self->cursor);    
    //printf("index=%d cursor=%d\n",index,self->cursor);
    if(index==1){
      index=0;
    }
    if(index>=0&&index<self->max_input ){
      printf("insert  %d max_input=>%d\n",index,self->max_input );
      insert_string(self->input,index,text);
    }else{
      printf("insert err index=%d\n",index);
    }
  }
  
  //strcpy(self->input,text);
  self->cursor_total+=utf8_strlen(text);
  
}

void gl_set_edit_text(edit_t * self,char* text){
  self->cursor=0;
  if(self->input!=NULL){
    memset(self->input,0,strlen(self->input));
  }
  gl_add_edit_text(self,text);
}


void gl_edit_char_event(edit_t  *self,int ch,int mods){
  if(self!=NULL){
    
    char* input=(char*)&ch;
    int len=utf8_surrogate_len(input);
    char buf[10]={0};
    utf8_encode(buf,ch);
    
    //printf("get char %d %x len==>%d %s\n",ch,ch,len,buf );
    
    if(self->cursor<=self->cursor_total ){
      gl_add_edit_text(self,buf);
      self->cursor++;
    }
    //printf("key event %d action=%d self->cursor=%d total=%d\n",key,action, self->cursor,self->cursor_total);

  }
}

void gl_edit_key_event(edit_t  *self,int key, int scancode, int action, int mods){
  if(self!=NULL&& (action==1||action==2)){

    if(key==263){
      if(self->cursor>0){
	self->cursor--;
      }
    }else if(key==262){
      if(self->cursor<self->cursor_total ){
	self->cursor++;
      }
    }
    //printf("key event %d action=%d self->cursor=%d total=%d\n",key,action, self->cursor,self->cursor_total);

  }
}


      
void draw_solid_quad(edit_t* self,float x1, float y1, float x2, float y2, float r, float g, float b, float a){

  
  glUseProgram( self->shader );
  {

    //glDisable( GL_TEXTURE_2D );
    //glActiveTexture(GL_TEXTURE1);
    glEnable( GL_TEXTURE_2D );
    glUniform1i( glGetUniformLocation( self->shader, "texture" ),0);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "model" ),
			1, 0,self->model.data);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "view" ),
			1, 0, self->view.data);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "projection" ),
			1, 0, self->projection.data);


  GLfloat vVertices[] = {x1,  y1,
  			 x2,  y1,
  			 x2,  y2,
  			 x1,  y2};
  float color[]={r,g,b,a,
		 r,g,b,a,
		 r,g,b,a,
		 r,g,b,a};
  
 
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

void gl_render_cursor(edit_t *self){

  
  float cursor_x = self->pen.x;
  float cursor_y =self->pen.y;
  struct sth_font* fnt = NULL;
  char* s =self->input;
  int count=0;
  short isize = (short)(self->font_size*10.0f);
  unsigned int codepoint;
  unsigned int state = 0;
  struct sth_glyph* glyph = NULL;

  char* cursor_text="|";

  if(s==NULL)
    return;
  
 fnt = self->stash->fonts;
 decutf8(&state, &codepoint, *(unsigned char*)cursor_text);
 glyph = get_glyph(self->stash, fnt, codepoint, isize);

 cursor_x-= + (glyph->xadv)/2 ;
 float sx=cursor_x;
 float sy=cursor_y;
 //while(fnt != NULL && fnt->idx != idx2) fnt = fnt->next;
 if (fnt == NULL){
    printf("gl_render_cursor null\n");

   return;
 } 
 if (fnt->type != BMFONT && !fnt->data){
   return;
 }
 

 for (; *s; ++s){
   if (decutf8(&state, &codepoint, *(unsigned char*)s)){
      continue;
   }

   glyph = get_glyph(self->stash, fnt, codepoint, isize);
   if(*s =='\n'){
     cursor_y-=self->stash->fonts->lineh*self->font_size;
     cursor_x=sx;
   }
   if (!glyph){
     count++;
     continue;
   }

   if(self->bound.width >0 && cursor_x >= (self->bound.width+sx-sth_get_advace(self->stash,fnt,glyph,isize) )){
     cursor_y-=self->stash->fonts->lineh* self->font_size;
     cursor_x=sx;
   }
  
   if(self->cursor==count){
     break;
   }
   count++;
   cursor_x+=sth_get_advace(self->stash,fnt,glyph,isize);
   
 }
 //printf("x =%d,%d\n",cursor_x,cursor_y);
   
 glUseProgram( self->shader );
 {

   glDisable( GL_TEXTURE_2D );
   //glActiveTexture(GL_TEXTURE1);
   //glEnable( GL_TEXTURE_2D );
   glUniform1i( glGetUniformLocation( self->shader, "texture" ),0);
   glUniformMatrix4fv( glGetUniformLocation( self->shader, "model" ),
		       1, 0,self->model.data);
   glUniformMatrix4fv( glGetUniformLocation( self->shader, "view" ),
		       1, 0, self->view.data);
   glUniformMatrix4fv( glGetUniformLocation( self->shader, "projection" ),
		       1, 0, self->projection.data);

   float dx=0,dy=0;
   sth_begin_draw(self->stash);
   sth_draw_text(self->stash, self->font,self->font_size,
		 cursor_x,cursor_y,
		 self->bound.width,self->bound.height,
		 cursor_text,1.0,0.0,0.0,1.0, &dx,&dy);
   //printf("%f %f %f %f\n",self->pen.x,self->pen.y,self->bound.width,self->bound.height);
   sth_end_draw(self->stash);

 }

 //draw_solid_quad(self,cursor_x,cursor_y,cursor_x+4.0,cursor_y+20.0 ,1.0,0.0,0.0,1.0);
 //draw_solid_quad(self,0.0,0.0,20.0,20.0,1.0,0.0,0.0,1.0);
}

void gl_render_params(edit_t *self ){

  //printf("shader->%d\n",self->shader);
  
  glUseProgram( self->shader );
  {
    glUniform1i( glGetUniformLocation( self->shader, "texture" ),0);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "model" ),
			1, 0,self->model.data);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "view" ),
			1, 0, self->view.data);
    glUniformMatrix4fv( glGetUniformLocation( self->shader, "projection" ),
			1, 0, self->projection.data);

    if(self->input==NULL)
      return;
    float dx=0,dy=0;
    sth_begin_draw(self->stash);
    sth_draw_text(self->stash, self->font,self->font_size,
    		  self->pen.x,self->pen.y,
    		  self->bound.width,self->bound.height,
    		  self->input,1.0,1.0,1.0,1.0, &dx,&dy);
    //printf("%f %f %f %f\n",self->pen.x,self->pen.y,self->bound.width,self->bound.height);
    sth_end_draw(self->stash);


  }
}


void gl_render_edit_once(edit_t * self,float x ,float y ,char* text,void * markup){

  self->cursor=0;
  if(self->input!=NULL){
    memset(self->input,0,strlen(self->input));
  }
  gl_add_edit_text(self,text);
  
  self->bound.left=x*2;
  self->bound.top=y*2;
  self->pen.x=x*2;
  self->pen.y=y*2;


  gl_render_params(self);

    
  if(self->editable==1){
    gl_render_cursor(self);
  }
  

}


void gl_render_edit(edit_t *self,float x,float y){
  
  self->bound.left=x*2;
  self->bound.top=y*2;
  self->pen.x=x*2;
  self->pen.y=y*2;

  gl_render_params(self);

    
 if(self->editable==1){
    gl_render_cursor(self);
  }
  

  
}

void gl_delete_edit(edit_t *self){
  
}





void glShaderSource2(GLuint shader,
		      GLsizei count,
		      const GLchar *string,
		      const GLint *length){
  glShaderSource(shader, count, &string, length);
}




