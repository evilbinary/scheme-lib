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

#define USE_SOFT_CONVER 1

#define TEXTURE_DEFAULT   1
#define TEXTURE_ROTATE    0
#define TEXTURE_HALF      0  

#define GET_STR(x) #x

#include "mat4.h"
#include "shader.h"

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <stdio.h>
  
// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

const char * vertexShaderString=GET_STR(
  attribute vec4 vertexIn;   
  attribute vec2 textureIn;
  varying vec2 textureOut;
  uniform vec2 screenSize;
  void main(void)
  {   
    //gl_Position = vertexIn;
     gl_Position = vec4(vertexIn.x * 2.0 / screenSize.x - 1.0, ( screenSize.y - vertexIn.y) * 2.0 / screenSize.y - 1.0, 0.0, 1.0); 
     textureOut = textureIn;
     //textureOut=vec2(textureIn.x,1.0-textureIn.y);
     
  });


  
const char* yuvFragmentShaderString=GET_STR(
  varying vec2 textureOut;
  uniform sampler2D tex_y;
  uniform sampler2D tex_u;
  uniform sampler2D tex_v;
  uniform float saturation;
  void main(void)
  {
      vec3 yuv;
      vec3 rgb;
      yuv.x = texture2D(tex_y, textureOut).r;
      yuv.y = texture2D(tex_u, textureOut).r - 0.5;
      yuv.z = texture2D(tex_v, textureOut).r - 0.5;
      rgb = mat3( 1,       1,         1,
                  0,       -0.39465,  2.03211,
                  1.13983, -0.58060,  0) * yuv;
      gl_FragColor = vec4(rgb, 1);
     // vec4 textureColor = vec4(rgb,1);
       //float luminance = dot(textureColor.rgb, rgb);
       //vec3 greyScaleColor = vec3(luminance);
       //gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
  });



typedef struct _video_t{
  AVFormatContext   *pFormatCtx ;
  int               i, videoStream;
  AVCodecContext    *pCodecCtxOrig ;
  AVCodecContext    *pCodecCtx;
  AVCodec           *pCodec ;
  AVFrame           *pFrame ;
  AVFrame           *pFrameYUV ;
  AVPacket          packet;
  int               frameFinished;
  int               numBytes;
  uint8_t           *buffer ;
  struct SwsContext *sws_ctx;
  char* filename;
  int erro;

  int shader;
  int texture[3];
  int screenSizeUniform;
  
  float window_width;
  float window_height;

  GLint textureUniformY;  
  GLint textureUniformU;  
  GLint textureUniformV;   
}video_t;


enum {
  ATTRIBUTE_VERTEX,   //
  ATTRIBUTE_TEXTURE,
};

void video_al_init(video_t *video){
  
}


void video_gl_init(video_t *video){
  
  video->shader=shader_load_from_string(vertexShaderString,yuvFragmentShaderString);
  

  glBindAttribLocation(video->shader, ATTRIBUTE_VERTEX, "vertexIn");  
  glBindAttribLocation(video->shader, ATTRIBUTE_TEXTURE, "textureIn");  

  video->textureUniformY = glGetUniformLocation(video->shader, "tex_y");  
  video->textureUniformU = glGetUniformLocation(video->shader, "tex_u");  
  video->textureUniformV = glGetUniformLocation(video->shader, "tex_v");   
  video->screenSizeUniform= glGetUniformLocation(video->shader, "screenSize");
  
  glGenTextures(3,video->texture);
  
 //Init Texture
  //y
  glBindTexture(GL_TEXTURE_2D, video->texture[0]);      
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);  

  //u
  glBindTexture(GL_TEXTURE_2D, video->texture[1]);     
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);  

  //v
  glBindTexture(GL_TEXTURE_2D, video->texture[2]);      
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  

}

void video_set_pos(video_t *video ,float x,float y,float w,float h){
  //printf("-->%f %f\n",x/video->window_width,x);


}


void video_render_yuv(video_t *video,float x1,float y1,float x2,float y2){
  
 #if TEXTURE_ROTATE  
    static const GLfloat vertexVertices[] = {  
        -1.0f, -0.5f,  
         0.5f, -1.0f,  
        -0.5f,  1.0f,  
         1.0f,  0.5f,  
    };      
#else  
    /* float x1=10.0; */
    /* float y1=10.0; */
    /* float x2=200.0; */
    /* float y2=200.0; */
    
    GLfloat vertexVertices[] = {  
       /* x1, y2, */
       /* x1, y1, */
       /* x2, y2, */
       /* x2, y1 */

      x1,y1,
      x2,y1,
      x1,y2,
      x2,y2
      
      /* x2,y2, */
      /* x1,y2, */
      /* x2,y1, */
      /* x1,y1, */
      
    };
     
    /* static const GLfloat vertexVertices[] = {   */
    /*     -1.0f, -1.0f,   */
    /*     1.0f, -1.0f,   */
    /*     -1.0f,  1.0f,   */
    /*     1.0f,  1.0f,   */
    /* };   */    
#endif  
  
#if TEXTURE_HALF  
    static const GLfloat textureVertices[] = {  
        0.0f,  1.0f,  
        0.5f,  1.0f,  
        0.0f,  0.0f,  
        0.5f,  0.0f,  
    };   
#else
    /* static const GLfloat textureVertices[] = { */
    /*   1.0f,  0.0f,   */
    /*   0.0f,  0.0f,   */
    /*   1.0f,  1.0f, */
    /*   0.0f,  1.0f,   */
    /* };   */
    
    static const GLfloat textureVertices[] = {
        0.0f, 1- 1.0f,
        1.0f, 1- 1.0f,
        0.0f, 1- 0.0f,
        1.0f,  1-0.0f,
	
    }; 
#endif 

  if( video->texture<0){
    return;
  }
  glUniform2f(video->screenSizeUniform,video->window_width,video->window_height);
  
  glUseProgram(video->shader);{

    //glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    
    float pixel_w=video->pCodecCtx->width;
    float pixel_h=video->pCodecCtx->height;

   #if USE_SOFT_CONVER
    
    void* ydata=video->pFrameYUV->data[0];
    void* udata=video->pFrameYUV->data[1];
    void* vdata=video->pFrameYUV->data[2];
#else
    void* ydata=video->pFrame->data[0];
    void* udata=video->pFrame->data[1];
    void* vdata=video->pFrame->data[2];
     if((int)pixel_w!=video->pFrame->linesize[0]){
      pixel_w=video->pFrame->linesize[0];
      //printf("width %f= frame->linesize[0]=%d\n",pixel_w,video->pFrame->linesize[0] );
    }
#endif

   

    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0,vertexVertices );
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    
    glVertexAttribPointer(ATTRIBUTE_TEXTURE, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIBUTE_TEXTURE);
    
    //Y  
    glActiveTexture(GL_TEXTURE0);  
    glBindTexture(GL_TEXTURE_2D,video->texture[0]);  
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixel_w, pixel_h, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, ydata);   
      
    glUniform1i(video->textureUniformY, 0);      
    //U  
    glActiveTexture(GL_TEXTURE1);  
    glBindTexture(GL_TEXTURE_2D, video->texture[1]);  
    glTexImage2D(GL_TEXTURE_2D, 0,GL_LUMINANCE, pixel_w/2, pixel_h/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, udata);         
    glUniform1i(video->textureUniformU, 1);  
    //V  
    glActiveTexture(GL_TEXTURE2);  
    glBindTexture(GL_TEXTURE_2D, video->texture[2]);  
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixel_w/2 , pixel_h/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, vdata);      
    glUniform1i(video->textureUniformV, 2);

   
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
  }
}


void save_frame(AVFrame *pFrame,int width, int height, int iFrame) {
  FILE *pFile;
  char szFilename[256];
  int  y;

  if(pFrame->data==NULL){
    printf("%d pFrame->data[0] is NULL\n",iFrame);
    return;
  }
  printf("pFrame->data[0]=>%d\n",pFrame->data[0]);

  // Open file
  sprintf(szFilename, "frame%d.ppm", iFrame);
  pFile=fopen(szFilename, "wb");
  if(pFile==NULL)
    return;
  
  // Write header
  fprintf(pFile, "P6\n%d %d\n255\n", width, height);

  // Write pixel data
  for(y=0; y<height; y++)
    fwrite(pFrame->data[0]+y*pFrame->linesize[0], 1, width*3, pFile);
  
  // Close file
  fclose(pFile);
}


video_t* video_new(char* filename,float width,float height){
  video_t *video=malloc(sizeof(video_t));
  video->texture[0]=-1;
  video->texture[1]=-1;
  video->texture[2]=-1;
  video->filename=filename;
  video->i=0;
  video->window_width=width;
  video->window_height=height;
  
  //bug 
  video->pFormatCtx = avformat_alloc_context();
  av_register_all();

  avformat_network_init();
  
  // Read frames and save first five frames to disk
  if(avformat_open_input(&video->pFormatCtx, filename, NULL, NULL)!=0){
    video->erro=-1;
    fprintf(stderr,"open file %s error.\n",filename);
    return video;
  }
  
  // Retrieve stream information
  if(avformat_find_stream_info(video->pFormatCtx, NULL)<0){
    video->erro=-1;
    return video;
  }
  // Dump information about file onto standard error
  //av_dump_format(video->pFormatCtx, 0, filename, 0);
  
  // Find the first video stream
  video->videoStream=-1;
  for(int i=0; i<video->pFormatCtx->nb_streams; i++)
    if(video->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
      video->videoStream=i;
      break;
    }
  if(video->videoStream==-1){
    video->erro=-1;
    fprintf(stderr,"Didn't find a video stream.\n");
    return video;
  }
  
  // Get a pointer to the codec context for the video stream
  video->pCodecCtxOrig=video->pFormatCtx->streams[video->videoStream]->codec;
  // Find the decoder for the video stream
  video->pCodec=avcodec_find_decoder(video->pCodecCtxOrig->codec_id);
  if(video->pCodec==NULL) {
    fprintf(stderr, "Unsupported codec!\n");
    video->erro=-1;
    return video;
  }

  // Copy contexts
  video->pCodecCtx = avcodec_alloc_context3(video->pCodec);
  if(avcodec_copy_context(video->pCodecCtx, video->pCodecCtxOrig) != 0) {
    fprintf(stderr, "Couldn't copy codec context");
    video->erro=-1;
    return video;
  }

  // Open codec
  if(avcodec_open2(video->pCodecCtx, video->pCodec, NULL)<0){
    video->erro=-1;
    fprintf(stderr, "Couldn't open codec");
    return video;// Could not open codec
  }
  
  // Allocate video frame
  video->pFrame=av_frame_alloc();

  // Determine required buffer size and allocate buffer
  /* video->numBytes=avpicture_get_size(AV_PIX_FMT_RGB24, video->pCodecCtx->width, */
  /* 			      video->pCodecCtx->height); */

#if USE_SOFT_CONVER
 
  // Allocate an AVFrame structure
  video->pFrameYUV=av_frame_alloc();
  if(video->pFrameYUV==NULL){
    video->erro=-1;
    fprintf(stderr, "Allocate an AVFrame erro");
    return video;
  }
  
  // Determine required buffer size and allocate buffer
  video->numBytes=avpicture_get_size(AV_PIX_FMT_YUV420P, video->pCodecCtx->width,
			      video->pCodecCtx->height);
  video->buffer=(uint8_t *)av_malloc(video->numBytes*sizeof(uint8_t));
  
  // Assign appropriate parts of buffer to image planes in pFrameRGB
  // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
  // of AVPicture
  avpicture_fill((AVPicture *)video->pFrameYUV, video->buffer, AV_PIX_FMT_YUV420P,
		 video->pCodecCtx->width, video->pCodecCtx->height);
  
  // initialize SWS context for software scaling
  video->sws_ctx = sws_getContext(video->pCodecCtx->width,
			   video->pCodecCtx->height,
			   video->pCodecCtx->pix_fmt,
			   video->pCodecCtx->width,
			   video->pCodecCtx->height,
			   AV_PIX_FMT_YUV420P,
			   SWS_BILINEAR,
			   NULL,
			   NULL,
			   NULL
			   );

#endif  
  
  //gl init
  video_gl_init(video);
  
   
  return video;
}


void video_render(video_t* video,float x1,float y1,float x2,float y2)
  {
  if(av_read_frame(video->pFormatCtx, &video->packet)>=0) {
  // Is this a packet from the video stream?
  if(video->packet.stream_index==video->videoStream) {
  // Decode video frame
  avcodec_decode_video2(video->pCodecCtx, video->pFrame, &video->frameFinished, &video->packet);
      
  // Did we get a video frame?
  if(video->frameFinished) {
  // Convert the image from its native format to RGB
  //printf("video->pFrame->data=>%p\n",video->pFrame->data);

#if USE_SOFT_CONVER
  
  sws_scale(video->sws_ctx, (uint8_t const * const *)video->pFrame->data,
    video->pFrame->linesize, 0, video->pCodecCtx->height,
    video->pFrameYUV->data, video->pFrameYUV->linesize);
#endif
  
#if OUTPUT_YUV420P
  int y_size=video->pCodecCtx->width*video->pCodecCtx->height;  
  fwrite(pFrameYUV->data[0],1,y_size,fp_yuv);    //Y 
  fwrite(pFrameYUV->data[1],1,y_size/4,fp_yuv);  //U
  fwrite(pFrameYUV->data[2],1,y_size/4,fp_yuv);  //V
#endif  
  // Save the frame to disk
  if(++video->i <=5){
  //save_frame(video->pFrameRGB, video->pCodecCtx->width, video->pCodecCtx->height,video->i);
	  
}
  video_render_yuv(video,x1,y1,x2,y2);

}
}
  // Free the packet that was allocated by av_read_frame
  av_free_packet(&video->packet);
}
  
}

void video_destroy(video_t* video){
  // Free the RGB image
  av_free(video->buffer);
  av_frame_free(&video->pFrameYUV);
  av_frame_free(&video->pFrame);
  avcodec_close(video->pCodecCtx);
  avcodec_close(video->pCodecCtxOrig);
  avformat_close_input(&video->pFormatCtx);
}
