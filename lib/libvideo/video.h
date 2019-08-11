/**
 * 作者:evilbinary on 10/20/18.
 * 邮箱:rootdebug@163.com 
 */

#ifndef VIDEO_H
#define VIDEO_H

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
#define NUM_BUFFERS 16
#ifdef WIN32
#define QUEUE_NUM_BUFFERS 8
#else
#define QUEUE_NUM_BUFFERS 16
#endif
#define OUT_PCM_FILE 0

#define AV_SYNC_THRESHOLD_MIN 0.01
#define AV_SYNC_THRESHOLD_MAX 0.4
#define AV_SYNC_FRAMEDUP_THRESHOLD 0.1
#define AV_NOSYNC_THRESHOLD 20.0
#define AV_SYNC_THRESHOLD 20.0

#define VIDEO_QUEUE_SIZE 16

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

enum {
  AV_SYNC_AUDIO_MASTER,
  AV_SYNC_VIDEO_MASTER,
  AV_SYNC_EXTERNAL_MASTER,
};

#if OUT_PCM_FILE
FILE *file= NULL;
#endif

#define PRINT(fmt, ...) printf("%s   "fmt, get_cur_time(), ##__VA_ARGS__)
#define ERROR(fmt, ...) printf("%s   "fmt" :%s\n", get_cur_time(), ##__VA_ARGS__, strerror(errno))
 



typedef struct _video_t{
  AVFormatContext   *pFormatCtx ;
  int               i, videoStream,audioStream;
  AVCodecContext    *pCodecCtxOrig ;
  AVCodecContext    *pCodecCtx;
  AVCodec           *pCodec ;

  AVFrame           *pFrame ;
  AVFrame           *pFrameYUV ;
  AVFrame           *frame;
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
  int paused;
  
  //thread
  pthread_t read_stream;
  pthread_t decode_audio;
  pthread_t decode_video;

  //互斥锁
  pthread_mutex_t audio_mutex;
  pthread_mutex_t video_mutex;
  pthread_mutex_t frame_mutex;
  //条件变量
  pthread_cond_t audio_cond;
  pthread_cond_t video_cond;
  pthread_cond_t frame_cond;
  
  pthread_mutex_t lock; 

  Queue packets[MAX_STREAM];
  Queue frames;
  //fps
  long fps;
  int is_sleep;
  int av_sync_type;
  double video_current_pts; ///当前视频帧pts
  double video_current_pts_drift;
  double audio_current_pts;  //当前音频帧显示时间
  double frame_last_duration;
  double frame_timer;
  double frame_last_pts;
  double duration;
  

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
  int use_soft_conver; 

  GLint textureUniformY;  
  GLint textureUniformU;  
  GLint textureUniformV;   
}video_t;


enum {
  ATTRIBUTE_VERTEX,   //
  ATTRIBUTE_TEXTURE,
};




void* decode_audio(void* arg);
void* decode_video(void* arg);
int video_get_fps(video_t *video);
void video_set_soft_conver(video_t *video,int mod);
double video_get_duration(video_t *video);
double video_get_current_duration(video_t * video);

#endif //
