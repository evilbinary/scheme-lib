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

#include "mat4.h"
#include "freetype-gl.h"
#include "font-manager.h"
#include "vertex-buffer.h"
#include "text-buffer.h"
#include "markup.h"


typedef struct{
  char* text;
  vec4 color;
  vec2 pen;
  int font_size;
  char* font_name;
  mat4 model;
  mat4 view;
  mat4 projection;
  font_manager_t * font_manager;
  text_buffer_t * buffer;
  vertex_buffer_t *lines_buffer;
  markup_t normal;
  int shader;
}text_t;


text_t * gl_new_text(int shader,float width,float height){
  text_t *text=malloc(sizeof(text_t));
  text->shader=shader;
  text->font_manager = font_manager_new( 512, 512, LCD_FILTERING_ON);
  text->buffer = text_buffer_new( );

  vec4 white = {{1,1,1,1}};
  vec4 black = {{0,0,0,1}};
  vec4 none = {{0,0,1,0}};
  vec2 pen={220,200};
  char *f_normal   = "Roboto-Regular.ttf";
    
  markup_t normal = {
    .family  = f_normal,
    .size    = 26.0, .bold    = 0,   .italic  = 0,
    .spacing = 0.0,  .gamma   = 1.,
    .foreground_color    = white, .background_color    = none,
    .underline           = 0,     .underline_color     = white,
    .overline            = 0,     .overline_color      = white,
    .strikethrough       = 0,     .strikethrough_color = white,
    .font = 0,
  };
  normal.font = font_manager_get_from_markup(text->font_manager, &normal );
  text->normal=normal;
  text->pen=pen;
    
  

    vec4 bounds = text_buffer_get_bounds( text->buffer, &text->pen );
    float left = bounds.left;
    float right = bounds.left + bounds.width;
    float top = bounds.top;
    float bottom = bounds.top - bounds.height;


    mat4_set_identity( &text->projection );
    mat4_set_identity( &text->model );
    mat4_set_identity( &text->view );
    //mat4_set_orthographic( &text->projection, 0, width*2,height*2,0,-1,1);
    mat4_set_orthographic( &text->projection, 0, width*2, 0, height*2,-1,1);
    
  return text;
}
void gl_destroy_text(text_t *text){
  if(text!=NULL){
    
  }
}

void gl_add_text(text_t *text,char* str,float x1,float y1){
  vec2 pen = {{x1*2,y1*2}};
  vertex_buffer_clear(text->buffer->buffer );
  
   text_buffer_printf( text->buffer, &pen,
		      &text->normal,str,
		      NULL );

   if(text->font_manager->atlas->id==0){
     glGenTextures( 1, &text->font_manager->atlas->id );
   }
  
   glBindTexture( GL_TEXTURE_2D, text->font_manager->atlas->id );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
   
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
   glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
   glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB, text->font_manager->atlas->width,
		 text->font_manager->atlas->height, 0, GL_RGB, GL_UNSIGNED_BYTE,
		 text->font_manager->atlas->data );
   //text_buffer_align( text->buffer, &text->pen, ALIGN_CENTER );
    
}

void gl_render_text(text_t* text){
  int text_shader=text->shader;
  
  glUseProgram(text_shader );
  {
    glUniformMatrix4fv( glGetUniformLocation(text_shader, "model" ),
			1, 0, text->model.data);
    glUniformMatrix4fv( glGetUniformLocation(text_shader, "view" ),
			1, 0, text->view.data);
    glUniformMatrix4fv( glGetUniformLocation(text_shader, "projection" ),
			1, 0, text->projection.data);
    glUniform1i( glGetUniformLocation( text_shader, "texture" ), 0 );
    glUniform3f( glGetUniformLocation( text_shader, "pixel" ),
		 1.0f/text->font_manager->atlas->width,
		 1.0f/text->font_manager->atlas->height,
		 (float)text->font_manager->atlas->depth );

    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( GL_TEXTURE_2D, text->font_manager->atlas->id );

    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glBlendColor( 1, 1, 1, 1 );
    
    vertex_buffer_render(text->buffer->buffer, GL_TRIANGLES );
    
    glBindTexture( GL_TEXTURE_2D, 0 );
    glBlendColor( 0, 0, 0, 0 );
    glUseProgram( 0 );
  }
}


//editor hereg
const int MARKUP_NORMAL      = 0;
const int MARKUP_DEFAULT     = 0;
const int MARKUP_ERROR       = 1;
const int MARKUP_WARNING     = 2;
const int MARKUP_OUTPUT      = 3;
const int MARKUP_BOLD        = 4;
const int MARKUP_ITALIC      = 5;
const int MARKUP_BOLD_ITALIC = 6;
const int MARKUP_FAINT       = 7;
#define   MARKUP_COUNT         8

typedef struct {
    float x, y, z;
    float s, t;
    float r, g, b, a;
} vertex_t;

typedef struct _edit_t{
  char *prompt;
  char *input;
  size_t max_input;
  size_t         cursor;
  size_t         cursor_total;
  
  vertex_buffer_t * buffer;
  texture_atlas_t *atlas;
  vec2 pen;
  vec4 bound;
  markup_t       markup[MARKUP_COUNT];
  
  int shader;
  mat4 model;
  mat4 view;
  mat4 projection;
  
}edit_t;



markup_t * gl_new_markup(char* name,float font_size){

  char *font_name   = "Roboto-Regular.ttf";
  if(name!=NULL){
    font_name=name;
  }
  vec4 white = {{1,1,1,1}};
  vec4 black = {{0,0,0,1}};
  vec4 none = {{0,0,1,0}};
  
  markup_t normal = {
    .family  = font_name,
    .size    = font_size, .bold    = 0,   .italic  = 0,
    .spacing = 0.0,  .gamma   = 1.,
    .foreground_color    = white, .background_color    = none,
    .underline           = 0,     .underline_color     = white,
    .overline            = 0,     .overline_color      = white,
    .strikethrough       = 0,     .strikethrough_color = white,
    .font = 0,
  };

  font_manager_t * font_manager=font_manager_new( 512, 512, LCD_FILTERING_ON);
   
  normal.font = font_manager_get_from_markup(font_manager,&normal );

  markup_t* markup=(markup_t *) malloc(sizeof(markup_t));
  *markup=normal;

  return  markup;
}

edit_t * gl_new_edit(int shader,float w,float h,float width,float height){
  edit_t *self=malloc(sizeof(edit_t));
  if( !self ){
    return self;
  }
  self->prompt = strdup( ">>> " );
  self->shader=shader;
  self->max_input=1024;
  self->input = malloc(sizeof(char)*self->max_input) ;
  self->input[0]='\0';
  self->cursor_total = 0;
  self->cursor=0;
  self->buffer = vertex_buffer_new( "vertex:3f,tex_coord:2f,color:4f" );
  self->pen.x = self->pen.y = 0;
  self->atlas = texture_atlas_new( 512, 512, 1 );
  glGenTextures( 1, &self->atlas->id );

  self->bound.width=w*2;
  self->bound.height=h*2;
  self->bound.left=0;
  self->bound.top=0;
  
  vec4 white = {{1,1,1,1}};
  vec4 black = {{0,0,0,1}};
  vec4 none = {{0,0,1,0}};

  float font_size=28.0;
  char *font_name   = "Roboto-Regular.ttf";
  

  markup_t normal;
    normal.family  = font_name;
    normal.size    = font_size;
    normal.bold    = 0;
    normal.italic  = 0;
    normal.spacing = 0.0;
    normal.gamma   = 1.0;
    normal.foreground_color    = white;
    normal.background_color    = none;
    normal.underline           = 0;
    normal.underline_color     = white;
    normal.overline            = 0;
    normal.overline_color      = white;
    normal.strikethrough       = 0;
    normal.strikethrough_color = white;

    normal.font = texture_font_new_from_file( self->atlas, font_size, font_name );

    markup_t bold = normal;
    bold.bold = 1;
    bold.font = texture_font_new_from_file( self->atlas, font_size, "fonts/VeraMoBd.ttf" );

    markup_t italic = normal;
    italic.italic = 1;
    bold.font = texture_font_new_from_file( self->atlas, font_size, "fonts/VeraMoIt.ttf" );

    markup_t bold_italic = normal;
    bold.bold = 1;
    italic.italic = 1;
    italic.font = texture_font_new_from_file( self->atlas, font_size, "fonts/VeraMoBI.ttf" );

    markup_t faint = normal;
    faint.foreground_color.r = 0.35;
    faint.foreground_color.g = 0.35;
    faint.foreground_color.b = 0.35;

    markup_t error = normal;
    error.foreground_color.r = 1.00;
    error.foreground_color.g = 0.00;
    error.foreground_color.b = 0.00;

    markup_t warning = normal;
    warning.foreground_color.r = 1.00;
    warning.foreground_color.g = 0.50;
    warning.foreground_color.b = 0.50;

    markup_t output = normal;
    output.foreground_color.r = 0.00;
    output.foreground_color.g = 0.00;
    output.foreground_color.b = 1.00;
  
  self->markup[MARKUP_NORMAL] = normal;
  self->markup[MARKUP_ERROR] = error;
  self->markup[MARKUP_WARNING] = warning;
  self->markup[MARKUP_OUTPUT] = output;
  self->markup[MARKUP_FAINT] = faint;
  self->markup[MARKUP_BOLD] = bold;
  self->markup[MARKUP_ITALIC] = italic;
  self->markup[MARKUP_BOLD_ITALIC] = bold_italic;
  
  mat4_set_identity( &self->projection );
  mat4_set_identity( &self->model );
  mat4_set_identity( &self->view );
  //mat4_set_orthographic( &text->projection, 0, width*2,height*2,0,-1,1);
  mat4_set_orthographic( &self->projection, 0, width*2, 0, height*2,-1,1);
    
  return self;
}


void gl_add_edit_text(edit_t * self,char* text){
  size_t len = strlen(self->input);
  //printf("len=%d max_input=%d text=%d str=>%s\n",len,self->max_input,strlen(text),text);
  
  if(len > self->max_input ){
    size_t alloc_size=self->max_input*2;
    char* new_input=malloc(alloc_size);    
    memcpy(new_input,self->input,self->max_input);
    char* old_input=self->input;
    self->input=new_input;
    free(self->input);
    self->max_input=alloc_size;
   }
  strcpy(self->input,text);
  self->cursor_total+=utf8_strlen(text);
  
}

char * get_index_text(edit_t *self,int index){
  int i;
  int count=0;
  for(i=0;i<utf8_strlen(self->input);i+=utf8_surrogate_len(self->input+i)){
    if(count==i){
      return self->input+i;
    }
    count++;
    //self->cursor+=utf8_surrogate_len(text);
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

void gl_add_glyph(edit_t *self,char* current,
		 char* previous,
		 markup_t *markup )
{
    texture_glyph_t *glyph  = texture_font_get_glyph( markup->font, current );
    if( previous )
    {
        self->pen.x += texture_glyph_get_kerning( glyph, previous );
    }
    float r = markup->foreground_color.r;
    float g = markup->foreground_color.g;
    float b = markup->foreground_color.b;
    float a = markup->foreground_color.a;
    int x0  = self->pen.x + glyph->offset_x;
    int y0  = self->pen.y + glyph->offset_y;
    int x1  = x0 + glyph->width;
    int y1  = y0 - glyph->height;
    float s0 = glyph->s0;
    float t0 = glyph->t0;
    float s1 = glyph->s1;
    float t1 = glyph->t1;

   
    
    if(*current=='\n'){
      //self->pen.y += markup->font->descender;
      self->pen.y -=markup->font->ascender;
      //self->pen.y+=glyph->height;
      self->pen.x=self->bound.left;
    }else{
      GLuint indices[] = {0,1,2, 0,2,3};
      vertex_t vertices[] = { { x0,y0,0,  s0,t0,  r,g,b,a },
			      { x0,y1,0,  s0,t1,  r,g,b,a },
			      { x1,y1,0,  s1,t1,  r,g,b,a },
			      { x1,y0,0,  s1,t0,  r,g,b,a } };
      vertex_buffer_push_back( self->buffer, vertices, 4, indices, 6 );

      //printf(" pen.x=%f w=%f  %f\n",self->pen.x,(self->bound.left+ self->bound.width),self->bound.width);
      
      if((self->pen.x+glyph->advance_x+glyph->advance_x ) > (self->bound.left+ self->bound.width)){
	self->pen.y -=markup->font->ascender;
	self->pen.x=self->bound.left;
      }else{
	self->pen.x += glyph->advance_x;
	self->pen.y += glyph->advance_y;
      
      }
       
    }
    
   
}

void gl_render_edit(edit_t *self,float x,float y){
  char* cur_char;
  char* prev_char;
  vertex_buffer_clear(self->buffer);
  self->bound.left=x*2;
  self->bound.top=y*2;
  self->pen.x=x*2;
  self->pen.y=y*2;
  
  int cursor_x = (int)self->pen.x;
  int cursor_y = (int)self->pen.y;

  int index=0;
  int i;
  int count=0;
  markup_t markup;
  markup = self->markup[MARKUP_FAINT];
  self->pen.y -= markup.font->height;
  

  markup = self->markup[MARKUP_NORMAL];
    if( strlen(self->input) > 0 )
    {
        cur_char = self->input;
        prev_char = NULL;
	index+=utf8_surrogate_len(self->input);

	cursor_x = (int) self->pen.x;
	cursor_y =(int)self->pen.y;
	
        gl_add_glyph( self, cur_char, prev_char, &markup );
	
        prev_char = cur_char;
	
	
	count++;
        for(;index < strlen(self->input); index+=utf8_surrogate_len(self->input+ index))
        {
            cur_char = self->input + index;
	    //printf ("current %d===>%s\n",count,cur_char);

	    if(self->cursor==count){
	      cursor_x = (int) self->pen.x;
	      cursor_y =(int)self->pen.y;
	    }
	    gl_add_glyph( self, cur_char, prev_char, &markup );
            prev_char = cur_char;
           
	    count++;
        }
	if(self->cursor==self->cursor_total){
	  cursor_x = (int) self->pen.x;
	  cursor_y =(int)self->pen.y;
	}
	//printf("%d %d\n",cursor_x,cursor_y);
    }

    if(  self->prompt[0] != '\0' || self->input[0] != '\0' )
    {
      //printf("hello.wolr\n");
        glBindTexture( GL_TEXTURE_2D, self->atlas->id );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RED, self->atlas->width,
                      self->atlas->height, 0, GL_RED, GL_UNSIGNED_BYTE,
                      self->atlas->data );
    }

    // Cursor (we use the black character (NULL) as texture )
    texture_glyph_t *glyph  = texture_font_get_glyph( markup.font, NULL );
    float r = markup.foreground_color.r;
    float g = markup.foreground_color.g;
    float b = markup.foreground_color.b;
    float a = markup.foreground_color.a;
    int x0  = cursor_x+1;
    int y0  = cursor_y + markup.font->descender;
    int x1  = cursor_x+2;
    int y1  = y0 + markup.font->height - markup.font->linegap;
    float s0 = glyph->s0;
    float t0 = glyph->t0;
    float s1 = glyph->s1;
    float t1 = glyph->t1;
    GLuint indices[] = {0,1,2, 0,2,3};
    vertex_t vertices[] = { { x0,y0,0,  s0,t0,  r,g,b,a },
                            { x0,y1,0,  s0,t1,  r,g,b,a },
                            { x1,y1,0,  s1,t1,  r,g,b,a },
                            { x1,y0,0,  s1,t0,  r,g,b,a } };
    
    vertex_buffer_push_back( self->buffer, vertices, 4, indices, 6 );
    //glEnable( GL_TEXTURE_2D );

    glUseProgram( self->shader );
    {
        glUniform1i( glGetUniformLocation( self->shader, "texture" ),
                     0 );
        glUniformMatrix4fv( glGetUniformLocation( self->shader, "model" ),
                            1, 0,self->model.data);
        glUniformMatrix4fv( glGetUniformLocation( self->shader, "view" ),
                            1, 0, self->view.data);
        glUniformMatrix4fv( glGetUniformLocation( self->shader, "projection" ),
                            1, 0, self->projection.data);
        vertex_buffer_render( self->buffer, GL_TRIANGLES );
    }
  
}

void gl_delete_edit(edit_t *self){
  glDeleteTextures( 1, &self->atlas->id );
  self->atlas->id = 0;
  texture_atlas_delete( self->atlas );
}





void glShaderSource2(GLuint shader,
		      GLsizei count,
		      const GLchar *string,
		      const GLint *length){
  glShaderSource(shader, count, &string, length);
}




