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
#define NUM_BUFFERS 32

#define OUT_PCM_FILE 0

/* no AV sync correction is done if below the minimum AV sync threshold */
#define AV_SYNC_THRESHOLD_MIN 0.04
/* AV sync correction is done if above the maximum AV sync threshold */
#define AV_SYNC_THRESHOLD_MAX 0.1
/* If a frame duration is longer than this, it will not be duplicated to compensate AV sync */
#define AV_SYNC_FRAMEDUP_THRESHOLD 0.1
/* no AV correction is done if too big error */
#define AV_NOSYNC_THRESHOLD 10.0


#define GET_STR(x) #x

#include "mat4.h"
#include "shader.h"

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
#include <libswresample/swresample.h>
#include <stdio.h>

#include "al.h" 
#include "alut.h"

//typedef  AVPacket type; //存储数据元素的类型

#include "queue.h"
#include "pthread.h"

// compatibility with newer API
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55,28,1)
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_free avcodec_free_frame
#endif

#define MAX_CACHE 1024
#define MAX_STREAM 2

#if OUT_PCM_FILE
FILE *file= NULL;
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


#define PRINT(fmt, ...) printf("%s   "fmt, get_cur_time(), ##__VA_ARGS__)
#define ERROR(fmt, ...) printf("%s   "fmt" :%s\n", get_cur_time(), ##__VA_ARGS__, strerror(errno))
 
char *get_cur_time(){
  static char s[40];
  time_t t;
  struct tm* ltime;
  time(&t);
  ltime = localtime(&t);
  strftime(s, 20, "%Y-%m-%d %H:%M:%S ", ltime); 
  return s;
}


typedef struct _video_t{
  AVFormatContext   *pFormatCtx ;
  int               i, videoStream,audioStream;
  AVCodecContext    *pCodecCtxOrig ;
  AVCodecContext    *pCodecCtx;
  AVCodec           *pCodec ;

  AVFrame           *pFrame ;
  AVFrame           *pFrameYUV ;
  AVPacket          packet;
  int               frameFinished;
  
  AVCodecContext  *aCodecCtx;
  AVCodec         *aCodec;
  AVFrame           *aFrame;
  int aframeFinished;
  ALCcontext* alContext;
  ALCdevice* alDevice;
  ALuint alSource;
  ALuint alBuffers[NUM_BUFFERS];
  int needsResample;
  AVFrame* resampledFrame;
  SwrContext* resampler;
  enum AVSampleFormat outFmt;
  int fmt;
  
  //thread
  pthread_t read_stream;
  pthread_t decode_audio;
  

  //互斥锁
  pthread_mutex_t audio_mutex;
  pthread_mutex_t video_mutex;
  //条件变量
  pthread_cond_t audio_cond;
  pthread_cond_t video_cond;

  Queue packets[MAX_STREAM];

  double timestamp;
  double audioclock;

  int is_end;
  
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

void video_al_init(video_t *video){

  video->alDevice=alcOpenDevice(NULL);
  if (video->alDevice) {
    video->alContext = alcCreateContext(video->alDevice, NULL);
    alcMakeContextCurrent(video->alContext);
    if(!video->alContext){
      printf("alcMakeContextCurrent erro\n");
    }
  }else{
    printf("alcOpenDevice erro\n");
  }

 
  alGenBuffers(NUM_BUFFERS, video->alBuffers);
  alGenSources(1, &video->alSource);
  alSourcei(video->alSource, AL_LOOPING, AL_FALSE);   
  alSourcef(video->alSource, AL_SOURCE_TYPE, AL_STREAMING); 
  //alSpeedOfSound(1.0);
  
  int sample_fmt = video->aCodecCtx->sample_fmt;
  int channels=video->aCodecCtx->channels;
  
  ALenum fmt = AL_FORMAT_MONO8;
  int out_fmt;  
  uint64_t in_layout;
  int frequency=video->aCodecCtx->sample_rate;
  
  switch (sample_fmt)
    {
    case AV_SAMPLE_FMT_S16P:
      in_layout = video->aCodecCtx->channel_layout;
      out_fmt = AV_SAMPLE_FMT_S16;
      video->needsResample = true;
    case AV_SAMPLE_FMT_S16:
      if (channels == 2)
	{
	  fmt = AL_FORMAT_STEREO16;
	}
      else
	{
	  fmt = AL_FORMAT_MONO16;
	}
      break;
    case AV_SAMPLE_FMT_U8P:
      in_layout = video->aCodecCtx->channel_layout;
      out_fmt = AV_SAMPLE_FMT_U8;
      video->needsResample = true;
    case AV_SAMPLE_FMT_U8:
      if (channels == 2)
	{
	  fmt = AL_FORMAT_STEREO8;
	}
      else
	{
	  fmt = AL_FORMAT_MONO8;
	}
      break;
    default:
      in_layout =  video->aCodecCtx->channel_layout;
      fmt = AL_FORMAT_STEREO16;
      out_fmt = AV_SAMPLE_FMT_S16;
      video->needsResample = true;
      break;
    }
  video->outFmt=out_fmt;
  video->fmt=fmt;
  //setup our resampler
  if (video->needsResample){
    printf("needsResample %d\n",video->needsResample);
    
    video->resampledFrame = av_frame_alloc();
    video->resampledFrame->channel_layout = in_layout;
    video->resampledFrame->sample_rate = frequency;
    video->resampledFrame->format = out_fmt;

    video->resampler = swr_alloc_set_opts(NULL,
    					  in_layout,
    					  out_fmt,
    					  frequency,
    					  in_layout,
    					  sample_fmt,
    					  frequency,
    					  0, NULL);


    /*video->resampler = swr_alloc();
    if (video->aCodecCtx->channel_layout == 0)
      video->aCodecCtx->channel_layout = av_get_default_channel_layout( video->aCodecCtx->channels );
    
    av_opt_set_int(video->resampler, "in_channel_layout",  video->aCodecCtx->channel_layout, 0);
    av_opt_set_int(video->resampler, "out_channel_layout", video->aCodecCtx->channel_layout,  0);
    av_opt_set_int(video->resampler, "in_sample_rate",     video->aCodecCtx->sample_rate, 0);
    av_opt_set_int(video->resampler, "out_sample_rate",    video->aCodecCtx->sample_rate, 0);
    av_opt_set_sample_fmt(video->resampler, "in_sample_fmt",  AV_SAMPLE_FMT_FLTP, 0);
    av_opt_set_sample_fmt(video->resampler, "out_sample_fmt", AV_SAMPLE_FMT_S16,  0);*/

    if (swr_init(video->resampler) != 0){
      printf("Could not init resampler!");
    }
  }
  
  /* alSpeedOfSound(1.0); */
  /* alDopplerVelocity(1.0); */
  /* alDopplerFactor(1.0); */
  /* alSourcef( video->alSource, AL_PITCH, 1.0f); */
  /* alSourcef( video->alSource, AL_GAIN, 1.0f); */
  /* alSourcei( video->alSource, AL_LOOPING, AL_FALSE); */
  alSourcef( video->alSource, AL_SOURCE_TYPE, AL_STREAMING);
  
  //alSourcePlay(video->alSource);

  
}
void video_al_destroy(video_t * video){
  alcMakeContextCurrent(NULL);
  alcDestroyContext(video->alContext);
  alcCloseDevice(video->alDevice);

}
int play=0;

void video_update_audio_buffer(video_t *video,int index){
  int ret=-1;
  int data_size=0;
  uint8_t* data;
  int linesize=0;
  
  if(video->needsResample==1){

    swr_convert_frame(video->resampler,video->resampledFrame,video->aFrame );
    data_size = av_samples_get_buffer_size(&linesize, video->aCodecCtx->channels,  video->resampledFrame->nb_samples, video->outFmt, 0);
    data = video->resampledFrame->data[0];

    /*int dstNbSamples = av_rescale_rnd(video->aFrame->nb_samples, video->aCodecCtx->sample_rate, video->aCodecCtx->sample_rate, AV_ROUND_UP);
    uint8_t** dstData = NULL;
    int dstLineSize;
    av_samples_alloc_array_and_samples(&dstData, &dstLineSize, video->aCodecCtx->channels, dstNbSamples, video->outFmt, 0);
    ret=swr_convert(video->resampler,dstData,dstNbSamples,(const uint8_t **)video->aFrame->extended_data,video->aFrame->nb_samples);
    if (ret < 0) {
      printf("err=-==> %d\n",ret);
    }
    data=dstData[0];*/
     
     /*for (int i=0; i<frame->nb_samples; i++){
       fwrite(ptr_l++, sizeof(float), 1, outfile);
       fwrite(ptr_r++, sizeof(float), 1, outfile);
       }*/
    
  }else{
    data_size = av_samples_get_buffer_size(&linesize, video->aCodecCtx->channels,  video->aFrame->nb_samples, video->outFmt, 1);
    data =  video->aFrame->data[0];
  }
  
#if OUT_PCM_FILE
  fwrite(data,1,data_size,file);
  fflush(file);
#endif
  
  //printf("data_size %d %d %d\n",data_size,video->outFmt,video->aCodecCtx->sample_rate);
  
  alBufferData(video->alBuffers[index],video->fmt ,data, data_size, video->aCodecCtx->sample_rate );


  //printf("size=%d format=%x freq=%d chanel=%d channel_layout=%d\n",size,format,freq,video->aCodecCtx->channels,video->aCodecCtx->channel_layout );
  
  
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
    glDisableVertexAttribArray(ATTRIBUTE_VERTEX);
    glDisableVertexAttribArray(ATTRIBUTE_TEXTURE);

    
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


void* read_stream(void* arg){
  int ret;
  video_t * video=(video_t*)arg;
  int index=0;
  printf("read stream\n");
  do{
    AVPacket* packet=malloc(sizeof(AVPacket));
    ret=av_read_frame(video->pFormatCtx,packet);
    //printf("read index=%d\n",index);
    if(packet->stream_index==video->videoStream ){ //
      pthread_mutex_lock(&video->video_mutex);
      //printf("queue%d len=> %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));
      
      if(queue_in(&video->packets[packet->stream_index],packet)==false){
	//printf("wait queue%d is full %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));
	pthread_cond_wait(&video->video_cond,&video->video_mutex);
      }else{
	//printf("broadcast\n");
	//printf("queue%d in %p %d\n",packet->stream_index,packet,queue_get_length(&video->packets[packet->stream_index]));
	pthread_cond_broadcast(&video->video_cond);
      }
      pthread_mutex_unlock(&video->video_mutex);
      
    }else if(packet->stream_index==video->audioStream){
      pthread_mutex_lock(&video->audio_mutex);
      if(queue_in(&video->packets[packet->stream_index],packet)==false){
	//printf("wait queue%d is full %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));

	pthread_cond_wait(&video->audio_cond,&video->audio_mutex);
      }else{
	//printf("broadcast\n");
	//printf("queue%d in %p %d\n",packet->stream_index,packet,queue_get_length(&video->packets[packet->stream_index]));
	pthread_cond_broadcast(&video->audio_cond);
      }
      pthread_mutex_unlock(&video->audio_mutex);
    }
    
    index++;
  }while(ret>=0);
  video->is_end=1;
  //pthread_join(video->decode_audio, NULL);
  printf("read stream end ............\n");
}



void* decode_audio(void* arg){
  int ret;
  video_t * video=(video_t*)arg;
  int index=0;
  int first=0;
#if  OUT_PCM_FILE
   file = fopen("test.pcm", "w+b");
#endif   

   //printf("decode audio video->audioStream=>%d queue=%p\n",video->audioStream,&video->packets[video->audioStream]);
  while(video->is_end==0) {
    pthread_mutex_lock(&video->audio_mutex);
    AVPacket* packet = queue_out(&video->packets[video->audioStream]);
    if(packet!=NULL){
      //printf("queue%d out %p len=%d\n",video->audioStream,packet,queue_get_length(&video->packets[video->audioStream]));
      //printf("decode_audio packet=%p\n",packet);
      // while(packet->size>0){
	avcodec_send_packet(video->aCodecCtx,packet);
	if (avcodec_receive_frame(video->aCodecCtx, video->aFrame) == 0){
	  video->aframeFinished=1;
	}

	//int len=avcodec_decode_audio4(video->aCodecCtx, video->aFrame, &video->aframeFinished,packet);
	if(video->aframeFinished){
	  //render audio
	  AVStream *stream=video->pFormatCtx->streams[packet->stream_index];

	  video->audioclock=video->aFrame->pkt_pts*av_q2d(stream->time_base);
	  //printf("audioclock=>%f\n",video->audioclock);

	  
	  ALint processed;
	  alGetSourcei(video->alSource, AL_BUFFERS_PROCESSED, &processed);
	  alSourceUnqueueBuffers(video->alSource, processed, (ALuint[NUM_BUFFERS]){});


	  ALint queued;
	  alGetSourcei(video->alSource, AL_BUFFERS_QUEUED, &queued);
	  if(queued < NUM_BUFFERS){
	    video_update_audio_buffer(video,index);
	    alSourceQueueBuffers(video->alSource, 1, &video->alBuffers[index]);
	    //printf("queued=>%d %d\n",queued,index);
	    index++;
	    queued++;
	  }else{
	    index=0;
	    ALint stateVaue;
	    alGetSourcei(video->alSource, AL_SOURCE_STATE, &stateVaue);
	    if (stateVaue != AL_PLAYING){
	      alSourcePlay(video->alSource);
	    }
	    //PRINT("star play\n");
	    do{
	      alGetSourcei(video->alSource, AL_SOURCE_STATE, &stateVaue);
	      struct timespec ts = {0, 1 * 100};
	      //nanosleep(&ts, NULL);
	      usleep(100);
	    }while(stateVaue==AL_PLAYING);
	    //PRINT("end ..........\n");
	     
	    ALint state;
	    alGetSourcei(video->alSource, AL_SOURCE_STATE, &state);
	    if(state == AL_STOPPED){
	      alGetSourcei(video->alSource, AL_BUFFERS_PROCESSED, &processed);
	      alSourceUnqueueBuffers(video->alSource, processed, (ALuint[NUM_BUFFERS]){});
	      alSourceRewind(video->alSource);
	    }
	  }
	  
#if OUTPUT_PCM
	  if (video->aCodecCtx->sample_fmt==AV_SAMPLE_FMT_S16P){ // Audacity: 16bit PCM little endian stereo
	    int16_t* ptr_l = (int16_t*)video->aFrame->extended_data[0];
	    int16_t* ptr_r = (int16_t*)video->aFrame->extended_data[1];
	   
	    /*for (int i=0; i<video->pFrame->nb_samples; i++){
	      fwrite(ptr_l++, sizeof(int16_t), 1, outfile);
	      fwrite(ptr_r++, sizeof(int16_t), 1, outfile);
	      }*/
	  }else if (video->aCodecCtx->sample_fmt==AV_SAMPLE_FMT_FLTP){ //Audacity: big endian 32bit stereo start offset 7 (but has noise)
	    float* ptr_l = (float*)video->aFrame->extended_data[0];
	    float* ptr_r = (float*)video->aFrame->extended_data[1];
	    
	    /*for (int i=0; i<frame->nb_samples; i++){
	      fwrite(ptr_l++, sizeof(float), 1, outfile);
	      fwrite(ptr_r++, sizeof(float), 1, outfile);
	      }*/
	  }
#endif

	  pthread_cond_broadcast(&video->audio_cond);

	}
	//packet->data += len;
      /* 	packet->size-=len; */
      /* } */

      
      av_free_packet(packet);
      free(packet);
      
    }else{
      //printf("decode audio wait packet=%d\n",packet);
      //pthread_cond_wait(&video->cond,&video->mutex);
    }
    pthread_mutex_unlock(&video->audio_mutex);

  }
}

void video_render(video_t* video,float x1,float y1,float x2,float y2){

  while(video->is_end==0){
  pthread_mutex_lock(&video->video_mutex);
  AVPacket* packet = queue_out(&video->packets[video->videoStream]);
  //printf("#queue%d out %p len=%d\n",video->videoStream,packet,queue_get_length(&video->packets[video->videoStream]));
  if(packet!=NULL){
    //printf("decode video packet=%p\n",packet);
    avcodec_decode_video2(video->pCodecCtx, video->pFrame, &video->frameFinished,packet);
    if(video->frameFinished) {
      //printf("video->pFrame->data=>%p\n",video->pFrame->data);
      if(packet->pts == AV_NOPTS_VALUE) {
	video->timestamp = 0;
      } else {
	 AVStream *stream=video->pFormatCtx->streams[packet->stream_index];
	video->timestamp = av_frame_get_best_effort_timestamp(video->pFrame)*av_q2d(stream->time_base);
      }

      
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
        // Save the frame to disk
      if(++video->i <=5){
	//save_frame(video->pFrameRGB, video->pCodecCtx->width, video->pCodecCtx->height,video->i);
	  
      }
#endif
    

      AVStream *stream=video->pFormatCtx->streams[packet->stream_index];
      double frameRate = av_q2d(stream->avg_frame_rate);
      frameRate += video->pFrame->repeat_pict * (frameRate * 0.5);

      video_render_yuv(video,x1,y1,x2,y2);
      usleep((unsigned long)(frameRate*1000));


      if (video->timestamp == 0.0) {
	usleep((unsigned long)(frameRate*1000));
      }else {
	//printf("==>%f\n", );
	if (fabs(video->timestamp - video->audioclock) > AV_SYNC_THRESHOLD_MIN &&
            fabs(video->timestamp - video->audioclock) < AV_NOSYNC_THRESHOLD) {
	  if (video->timestamp > video->audioclock) {
	    //printf("video->audioclock=%f timestamp=%f\n",video->audioclock,video->timestamp );
            usleep((unsigned long)((video->timestamp - video->audioclock)*1000000 ));
	  }
	}
      }
      
      pthread_cond_broadcast(&video->video_cond);
      break;
    }    
    av_free_packet(packet);
    free(packet);
  }else{
    pthread_cond_wait(&video->video_cond,&video->video_mutex);
  }
  
  pthread_mutex_unlock(&video->video_mutex);
  }

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
  video->audioStream=-1;
  for(int i=0; i<video->pFormatCtx->nb_streams; i++){
    if(video->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO&&video->videoStream<0) {
      video->videoStream=i;
      //break;
    }
    if(video->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO&&video->audioStream<0){
      video->audioStream=i;
    }
  }
  
  if(video->videoStream==-1){
    video->erro=-1;
    fprintf(stderr,"Didn't find a video stream.\n");
    return video;
  }

  if(video->audioStream==-1){
    video->erro=-1;
    fprintf(stderr,"Didn't find a audio stream.\n");
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

  //audio code context
  video->aCodecCtx=video->pFormatCtx->streams[video->audioStream]->codec;
  //find decoder for audio stream
  video->aCodec = avcodec_find_decoder(video->aCodecCtx->codec_id);
  //open audio codec
  
if(avcodec_open2(video->aCodecCtx, video->aCodec, NULL)<0){
    video->erro=-1;
    fprintf(stderr, "Couldn't open audio codec");
    return video;// Could not open codec
  }
  
  
  // Allocate video frame
  video->pFrame=av_frame_alloc();

  //allocate audio frame
  video->aFrame=av_frame_alloc();

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
  //al init
  video_al_init(video);

  for(int i=0;i<MAX_STREAM;i++){
    queue_init(&video->packets[i]);
    //printf("queue %d %p %d\n",i,&video->packets[i],queue_get_length(&video->packets[i]) );
  }
  //thread init
  pthread_mutex_init(&video->audio_mutex,NULL);
  pthread_mutex_init(&video->audio_mutex,NULL);
  pthread_cond_init(&video->audio_cond,NULL);
  pthread_cond_init(&video->video_cond,NULL);
  
  pthread_create(&(video->read_stream), NULL, read_stream, (void*)video);
  pthread_create(&(video->decode_audio), NULL, decode_audio, (void*)video);

  /* pthread_join(video->read_stream, NULL); */
  /* pthread_join(video->decode_audio, NULL); */

  
  return video;
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
