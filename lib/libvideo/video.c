/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com
 */

#include "video.h"

const char* vertexShaderString =
    GET_STR(attribute vec4 vertexIn; attribute vec2 textureIn;
            varying vec2 textureOut; uniform vec2 screenSize; void main(void) {
              // gl_Position = vertexIn;
              gl_Position =
                  vec4(vertexIn.x * 2.0 / screenSize.x - 1.0,
                       (screenSize.y - vertexIn.y) * 2.0 / screenSize.y - 1.0,
                       0.0, 1.0);
              textureOut = textureIn;
              // textureOut=vec2(textureIn.x,1.0-textureIn.y);
            });

const char* yuvFragmentShaderString = GET_STR(
    varying vec2 textureOut; uniform sampler2D tex_y; uniform sampler2D tex_u;
    uniform sampler2D tex_v; uniform float saturation; void main(void) {
      vec3 yuv;
      vec3 rgb;
      yuv.x = texture2D(tex_y, textureOut).r;
      yuv.y = texture2D(tex_u, textureOut).r - 0.5;
      yuv.z = texture2D(tex_v, textureOut).r - 0.5;
      rgb = mat3(1, 1, 1, 0, -0.39465, 2.03211, 1.13983, -0.58060, 0) * yuv;
      gl_FragColor = vec4(rgb, 1);
      // vec4 textureColor = vec4(rgb,1);
      // float luminance = dot(textureColor.rgb, rgb);
      // vec3 greyScaleColor = vec3(luminance);
      // gl_FragColor = vec4(mix(greyScaleColor, textureColor.rgb, saturation),
      // textureColor.w);
    });

char* get_cur_time() {
  static char s[40];
  time_t t;
  struct tm* ltime;
  time(&t);
  ltime = localtime(&t);
  strftime(s, 20, "%Y-%m-%d %H:%M:%S ", ltime);
  return s;
}

void video_gl_init(video_t* video) {
  video->shader =
      shader_load_from_string(vertexShaderString, yuvFragmentShaderString);

  glBindAttribLocation(video->shader, ATTRIBUTE_VERTEX, "vertexIn");
  glBindAttribLocation(video->shader, ATTRIBUTE_TEXTURE, "textureIn");

  video->textureUniformY = glGetUniformLocation(video->shader, "tex_y");
  video->textureUniformU = glGetUniformLocation(video->shader, "tex_u");
  video->textureUniformV = glGetUniformLocation(video->shader, "tex_v");
  video->screenSizeUniform = glGetUniformLocation(video->shader, "screenSize");

  glGenTextures(3, video->texture);

  // Init Texture
  // y
  glBindTexture(GL_TEXTURE_2D, video->texture[0]);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // u
  glBindTexture(GL_TEXTURE_2D, video->texture[1]);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  // v
  glBindTexture(GL_TEXTURE_2D, video->texture[2]);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

void video_set_pos(video_t* video, float x, float y, float w, float h) {
  // printf("-->%f %f\n",x/video->window_width,x);
}

void video_al_init(video_t* video) {
  video->alDevice = alcOpenDevice(NULL);
  if (video->alDevice) {
    video->alContext = alcCreateContext(video->alDevice, NULL);
    alcMakeContextCurrent(video->alContext);
    if (!video->alContext) {
      printf("alcMakeContextCurrent erro\n");
    }
  } else {
    printf("alcOpenDevice erro\n");
  }

  ALenum error = alGetError();
  if (error != AL_NO_ERROR) {
    fprintf(stderr, "Error init %x\n", error);
  }

  alGenBuffers(NUM_BUFFERS, video->alBuffers);
  alGenSources(1, &video->alSource);
  /* alSourcei(video->alSource, AL_LOOPING, AL_FALSE);    */
  /* alSourcef(video->alSource, AL_SOURCE_TYPE, AL_STREAMING);  */
  /* alSpeedOfSound(1.0); */

  error = alGetError();
  if (error != AL_NO_ERROR) {
    fprintf(stderr, "Error init2 %x\n", error);
  }

  int sample_fmt = video->aCodecCtx->sample_fmt;
  int channels = video->aCodecCtx->channels;

  ALenum fmt = AL_FORMAT_MONO8;
  int out_fmt;
  uint64_t in_layout;
  int frequency = video->aCodecCtx->sample_rate;

  switch (sample_fmt) {
    case AV_SAMPLE_FMT_S16P:
      in_layout = video->aCodecCtx->channel_layout;
      out_fmt = AV_SAMPLE_FMT_S16;
      video->needsResample = true;
    case AV_SAMPLE_FMT_S16:
      if (channels == 2) {
        fmt = AL_FORMAT_STEREO16;
      } else {
        fmt = AL_FORMAT_MONO16;
      }
      break;
    case AV_SAMPLE_FMT_U8P:
      in_layout = video->aCodecCtx->channel_layout;
      out_fmt = AV_SAMPLE_FMT_U8;
      video->needsResample = true;
    case AV_SAMPLE_FMT_U8:
      if (channels == 2) {
        fmt = AL_FORMAT_STEREO8;
      } else {
        fmt = AL_FORMAT_MONO8;
      }
      break;
    default:
      in_layout = video->aCodecCtx->channel_layout;
      fmt = AL_FORMAT_STEREO16;
      out_fmt = AV_SAMPLE_FMT_S16;
      video->needsResample = true;
      break;
  }
  video->outFmt = out_fmt;
  video->fmt = fmt;
  // setup our resampler
  if (video->needsResample) {
    printf("needsResample %d\n", video->needsResample);

    video->resampledFrame = av_frame_alloc();
    video->resampledFrame->channel_layout = in_layout;
    video->resampledFrame->sample_rate = frequency;
    video->resampledFrame->format = out_fmt;

    video->resampler =
        swr_alloc_set_opts(NULL, in_layout, out_fmt, frequency, in_layout,
                           sample_fmt, frequency, 0, NULL);

    /*video->resampler = swr_alloc();
    if (video->aCodecCtx->channel_layout == 0)
      video->aCodecCtx->channel_layout = av_get_default_channel_layout(
    video->aCodecCtx->channels );

    av_opt_set_int(video->resampler, "in_channel_layout",
    video->aCodecCtx->channel_layout, 0); av_opt_set_int(video->resampler,
    "out_channel_layout", video->aCodecCtx->channel_layout,  0);
    av_opt_set_int(video->resampler, "in_sample_rate",
    video->aCodecCtx->sample_rate, 0); av_opt_set_int(video->resampler,
    "out_sample_rate",    video->aCodecCtx->sample_rate, 0);
    av_opt_set_sample_fmt(video->resampler, "in_sample_fmt", AV_SAMPLE_FMT_FLTP,
    0); av_opt_set_sample_fmt(video->resampler, "out_sample_fmt",
    AV_SAMPLE_FMT_S16,  0);*/

    if (swr_init(video->resampler) != 0) {
      printf("Could not init resampler!");
    }
  }
}
void video_al_destroy(video_t* video) {
  alcMakeContextCurrent(NULL);
  alcDestroyContext(video->alContext);
  alcCloseDevice(video->alDevice);
}
int play = 0;

void video_update_audio_buffer(video_t* video, ALuint buffer) {
  int ret = -1;
  int data_size = 0;
  uint8_t* data;
  int linesize = 0;

  if (video->needsResample == 1) {
    swr_convert_frame(video->resampler, video->resampledFrame, video->aFrame);
    data_size = av_samples_get_buffer_size(
        &linesize, video->aCodecCtx->channels,
        video->resampledFrame->nb_samples, video->outFmt, 0);
    data = video->resampledFrame->data[0];

    /*int dstNbSamples = av_rescale_rnd(video->aFrame->nb_samples,
    video->aCodecCtx->sample_rate, video->aCodecCtx->sample_rate, AV_ROUND_UP);
    uint8_t** dstData = NULL;
    int dstLineSize;
    av_samples_alloc_array_and_samples(&dstData, &dstLineSize,
    video->aCodecCtx->channels, dstNbSamples, video->outFmt, 0);
    ret=swr_convert(video->resampler,dstData,dstNbSamples,(const uint8_t
    **)video->aFrame->extended_data,video->aFrame->nb_samples); if (ret < 0) {
      printf("err=-==> %d\n",ret);
    }
    data=dstData[0];*/

    /*for (int i=0; i<frame->nb_samples; i++){
      fwrite(ptr_l++, sizeof(float), 1, outfile);
      fwrite(ptr_r++, sizeof(float), 1, outfile);
      }*/

  } else {
    data_size =
        av_samples_get_buffer_size(&linesize, video->aCodecCtx->channels,
                                   video->aFrame->nb_samples, video->outFmt, 1);
    data = video->aFrame->data[0];
  }

#if OUT_PCM_FILE
  fwrite(data, 1, data_size, file);
  fflush(file);
#endif

  // printf("data_size %d %d
  // %d\n",data_size,video->outFmt,video->aCodecCtx->sample_rate);

  alBufferData(buffer, video->fmt, data, data_size,
               video->aCodecCtx->sample_rate);

  // printf("size=%d format=%x freq=%d chanel=%d
  // channel_layout=%d\n",size,format,freq,video->aCodecCtx->channels,video->aCodecCtx->channel_layout
  // );
}

void video_render_yuv(video_t* video, float x1, float y1, float x2, float y2) {
#if TEXTURE_ROTATE
  static const GLfloat vertexVertices[] = {
      -1.0f, -0.5f, 0.5f, -1.0f, -0.5f, 1.0f, 1.0f, 0.5f,
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

      x1, y1, x2, y1, x1,
      y2, x2, y2

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
      0.0f, 1.0f, 0.5f, 1.0f, 0.0f, 0.0f, 0.5f, 0.0f,
  };
#else
  /* static const GLfloat textureVertices[] = { */
  /*   1.0f,  0.0f,   */
  /*   0.0f,  0.0f,   */
  /*   1.0f,  1.0f, */
  /*   0.0f,  1.0f,   */
  /* };   */

  static const GLfloat textureVertices[] = {
      0.0f, 1 - 1.0f, 1.0f, 1 - 1.0f, 0.0f, 1 - 0.0f, 1.0f, 1 - 0.0f,

  };
#endif

  if (video->texture < 0) {
    printf("texture <0\n");
    return;
  }

  glUseProgram(video->shader);
  {
    // glPixelStorei(GL_UNPACK_ALIGNMENT,1);

    float pixel_w = video->pCodecCtx->width;
    float pixel_h = video->pCodecCtx->height;
    void* ydata = NULL;
    void* udata = NULL;
    void* vdata = NULL;
    if (video->use_soft_conver == 1) {
      ydata = video->frame->data[0];
      udata = video->frame->data[1];
      vdata = video->frame->data[2];
    } else {
      ydata = video->frame->data[0];
      udata = video->frame->data[1];
      vdata = video->frame->data[2];
      if ((int)pixel_w != video->frame->linesize[0]) {
        pixel_w = video->frame->linesize[0];
        // printf("width %f=linesize[0] %d height %f=linesize[1] %d\n", pixel_w,
        //        video->pFrame->linesize[0],pixel_h,video->pFrame->linesize[1]);
      }
    }
    glUniform2f(video->screenSizeUniform, video->window_width,
                video->window_height);
    glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, vertexVertices);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);

    glVertexAttribPointer(ATTRIBUTE_TEXTURE, 2, GL_FLOAT, 0, 0,
                          textureVertices);
    glEnableVertexAttribArray(ATTRIBUTE_TEXTURE);
    // Y
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, video->texture[0]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixel_w, pixel_h, 0,
                 GL_LUMINANCE, GL_UNSIGNED_BYTE, ydata);

    glUniform1i(video->textureUniformY, 0);
    // U
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, video->texture[1]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixel_w / 2, pixel_h / 2, 0,
                 GL_LUMINANCE, GL_UNSIGNED_BYTE, udata);
    glUniform1i(video->textureUniformU, 1);
    // V
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, video->texture[2]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, pixel_w / 2, pixel_h / 2, 0,
                 GL_LUMINANCE, GL_UNSIGNED_BYTE, vdata);
    glUniform1i(video->textureUniformV, 2);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(ATTRIBUTE_VERTEX);
    glDisableVertexAttribArray(ATTRIBUTE_TEXTURE);
  }
}

void save_frame(AVFrame* pFrame, int width, int height, int iFrame) {
  FILE* pFile;
  char szFilename[256];
  int y;

  if (pFrame->data == NULL) {
    printf("%d pFrame->data[0] is NULL\n", iFrame);
    return;
  }
  printf("pFrame->data[0]=>%d\n", pFrame->data[0]);

  // Open file
  sprintf(szFilename, "frame%d.ppm", iFrame);
  pFile = fopen(szFilename, "wb");
  if (pFile == NULL) return;

  // Write header
  fprintf(pFile, "P6\n%d %d\n255\n", width, height);

  // Write pixel data
  for (y = 0; y < height; y++)
    fwrite(pFrame->data[0] + y * pFrame->linesize[0], 1, width * 3, pFile);

  // Close file
  fclose(pFile);
}

static void pgm_save(unsigned char* buf, int wrap, int xsize, int ysize,
                     char* filename) {
  FILE* f;
  int i;
  f = fopen(filename, "w");
  fprintf(f, "P5\n%d %d\n%d\n", xsize, ysize, 255);
  for (i = 0; i < ysize; i++) fwrite(buf + i * wrap, 1, xsize, f);
  fclose(f);
}

int write_frame_to_file(FILE* file, AVFrame* frame,
                        AVCodecContext* codec_context, AVPacket* pkt) {
  int res, got_output;
  av_init_packet(pkt);
  pkt->data = NULL;
  pkt->size = 0;

  /* generate synthetic video */
  frame->pts += 1;

  res = avcodec_encode_video2(codec_context, pkt, frame, &got_output);
  if (res >= 0) {
    printf("Error encoding frame\n");
  }
  if (got_output) {
    fwrite(pkt->data, 1, pkt->size, file);
    av_free_packet(pkt);
  }
  return 0;
error:
  return -1;
}

void read_cover(video_t* video) {
  AVPacket packet;
  AVPacket pkt;
  AVPacket opkt;
  int frameFinished;
  int ret;
  int frame_count = 0;
  char buf[1024];
  char* outfilename = "x";
  AVFrame* pFrame = av_frame_alloc();

  AVCodec* codec = avcodec_find_encoder(AV_CODEC_ID_MJPEG);
  if (!codec) {
    printf("Codec not found\n");
    return;
  }
  AVCodecContext* c = avcodec_alloc_context3(codec);
  if (!c) {
    printf("Could not allocate video codec context\n");
    return;
  }
  c->bit_rate = 400000;
  c->width = video->window_width;
  c->height = video->window_height;
  c->time_base = (AVRational){1, 25};
  c->pix_fmt = AV_PIX_FMT_YUVJ420P;

  if (avcodec_open2(c, codec, NULL) < 0) {
    printf("Could not open codec\n");
    return;
  }

  for (;;) {
    ret = av_read_frame(video->pFormatCtx, &pkt);
    if (ret < 0) {
      printf("Error av_read_frame frame\n");
      return;
    }
    ret = avcodec_decode_video2(video->pCodecCtx, pFrame, &frameFinished, &pkt);
    if (frameFinished) {
      queue_in(&video->frames, pFrame);
      // printf("Saving frame %3d\n", frame_count);
      // fflush(stdout);
      // snprintf(buf, sizeof(buf), outfilename, frame_count);
      // save_frame(pFrame, video->pCodecCtx->width, video->pCodecCtx->height,
      //            frame_count);
      // FILE* f = fopen("test.jpg", "w");
      // write_frame_to_file(f, pFrame, c, &opkt);
      frame_count++;
      break;
    }
  }
}

void* read_stream(void* arg) {
  int ret;
  video_t* video = (video_t*)arg;
  video_init_media(video);

  int index = 0;
  printf("audioStream %d vidoStream %d\n", video->audioStream,
         video->videoStream);

  if (video->audioStream >= 0) {
    pthread_create(&(video->decode_audio), NULL, decode_audio, (void*)video);
  }
  if (video->videoStream >= 0) {
    pthread_create(&(video->decode_video), NULL, decode_video, (void*)video);
  }
  read_cover(video);
  printf("read stream\n");
  do {
    AVPacket* packet = malloc(sizeof(AVPacket));
    // AVPacket *packet = av_packet_alloc();
    ret = av_read_frame(video->pFormatCtx, packet);
    // printf("read index=%d\n",index);
    if (packet->stream_index == video->videoStream) {  //
      pthread_mutex_lock(&video->video_mutex);
      // printf("queue%d len=>
      // %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));

      if (queue_in(&video->packets[packet->stream_index], packet) == false) {
        // printf("wait queue%d is full
        // %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));
        pthread_cond_wait(&video->video_cond, &video->video_mutex);
      } else {
        // printf("broadcast\n");
        // printf("queue%d in %p
        // %d\n",packet->stream_index,packet,queue_get_length(&video->packets[packet->stream_index]));
        pthread_cond_broadcast(&video->video_cond);
      }
      pthread_mutex_unlock(&video->video_mutex);

    } else if (packet->stream_index == video->audioStream) {
      pthread_mutex_lock(&video->audio_mutex);
      // printf("queue%d len=>
      // %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));

      if (queue_in(&video->packets[packet->stream_index], packet) == false) {
        // printf("wait queue%d is full
        // %d\n",packet->stream_index,queue_get_length(&video->packets[packet->stream_index]));
        pthread_cond_wait(&video->audio_cond, &video->audio_mutex);
      } else {
        // printf("broadcast\n");
        // printf("queue%d in %p
        // %d\n",packet->stream_index,packet,queue_get_length(&video->packets[packet->stream_index]));
        pthread_cond_broadcast(&video->audio_cond);
      }
      pthread_mutex_unlock(&video->audio_mutex);
    }

    index++;
  } while (ret >= 0);

  if (video->audioStream >= 0) {
    pthread_join(video->decode_audio, NULL);
  }

  if (video->videoStream >= 0) {
    pthread_join(video->decode_video, NULL);
  }
  video->is_end = 1;

  printf("read stream end\n");
}

double get_audio_clock(video_t* is) {
  double pts;
  int hw_buf_size, bytes_per_sec, n;
  pts = is->audio_current_pts;  // maintained in the audio thread.
  /*hw_buf_size = is->audio_buf_size - is->audio_buf_index;
  bytes_per_sec = 0;
  n = is->audio_st->codec->channels * 2;
  if (is->audio_st) {
    bytes_per_sec = is->audio_st->codec->sample_rate * n;
  }
  if (bytes_per_sec) {
    pts -= (double)hw_buf_size / bytes_per_sec;
    }*/
  return pts;
}

double get_external_clock(video_t* is) { return av_gettime() / 1000000.0; }

double get_video_clock(video_t* video) {
  double delta;
  delta = (av_gettime() - video->video_current_pts) / 1000000.0;
  return video->video_current_pts + delta;
}

double get_master_clock(video_t* video) {
  if (video->av_sync_type == AV_SYNC_VIDEO_MASTER) {
    return get_video_clock(video);
  } else if (video->av_sync_type == AV_SYNC_AUDIO_MASTER) {
    return get_audio_clock(video);
  } else {
    return get_external_clock(video);
  }
}

static double compute_target_delay(double delay, video_t* video) {
  double sync_threshold, diff;
  //获取当前视频帧播放的时间，与系统主时钟时间相减得到差值
  diff = get_video_clock(video) - get_master_clock(video);
  sync_threshold = FFMAX(AV_SYNC_THRESHOLD, delay);
  //假如当前帧的播放时间，也就是pts，滞后于主时钟
  if (fabs(diff) < AV_NOSYNC_THRESHOLD) {
    if (diff <= -sync_threshold) delay = 0;
    //假如当前帧的播放时间，也就是pts，超前于主时钟，那就需要加大延时
    else if (diff >= sync_threshold)
      delay = 2 * delay;
  }

  return delay;
}

void video_set_pause(video_t* video, int val) { video->paused = val; }
int video_get_pause(video_t* video) { return video->paused; }

void* decode_video(void* arg) {
  video_t* video = (video_t*)arg;
  printf("decode_video\n");
  AVFrame* frame = av_frame_alloc();

  while (video->is_end == 0) {
    // while(video->is_end==0){
    pthread_mutex_lock(&video->video_mutex);
    AVPacket* packet = queue_out(&video->packets[video->videoStream]);
    // printf("#queue%d out %p
    // len=%d\n",video->videoStream,packet,queue_get_length(&video->packets[video->videoStream]));
    if (packet != NULL) {
      // printf("decode video packet=%p\n",packet);
      avcodec_decode_video2(video->pCodecCtx, video->pFrame,
                            &video->frameFinished, packet);
      if (video->frameFinished) {
        // printf("video->pFrame->data=>%p\n",video->pFrame->data);
        if (video->use_soft_conver == 1) {
          sws_scale(video->sws_ctx, (uint8_t const* const*)video->pFrame->data,
                    video->pFrame->linesize, 0, video->pCodecCtx->height,
                    video->pFrameYUV->data, video->pFrameYUV->linesize);
        }
#if OUTPUT_YUV420P
        int y_size = video->pCodecCtx->width * video->pCodecCtx->height;
        fwrite(pFrameYUV->data[0], 1, y_size, fp_yuv);      // Y
        fwrite(pFrameYUV->data[1], 1, y_size / 4, fp_yuv);  // U
        fwrite(pFrameYUV->data[2], 1, y_size / 4, fp_yuv);  // V
        // Save the frame to disk
        if (++video->i <= 5) {
          // save_frame(video->pFrameRGB, video->pCodecCtx->width,
          // video->pCodecCtx->height,video->i);
        }
#endif
        // printf("in queu %d\n",queue_get_length(&video->frames));
        AVFrame* p = av_frame_alloc();
        if (av_frame_ref(p, video->pFrame) < 0) {
          printf(" erro av_frame_ref\n");
          av_frame_unref(p);
        }
        pthread_mutex_lock(&video->frame_mutex);
        if (queue_in(&video->frames, p) == false) {
          pthread_cond_wait(&video->frame_cond, &video->frame_mutex);
        } else {
          pthread_cond_broadcast(&video->frame_cond);
        }
        pthread_mutex_unlock(&video->frame_mutex);

        pthread_cond_broadcast(&video->video_cond);
        // pthread_mutex_unlock(&video->video_mutex);
        // break;
      }
      av_free_packet(packet);
      free(packet);
      pthread_cond_broadcast(&video->video_cond);
    } else {
      pthread_cond_wait(&video->video_cond, &video->video_mutex);
    }
    pthread_mutex_unlock(&video->video_mutex);
  }
  //}
}

void* decode_audio(void* arg) {
  int ret;
  video_t* video = (video_t*)arg;
  int index = 0;
  int first = 0;
  int firstCount = 0;

  // al init
  video_al_init(video);

#if OUT_PCM_FILE
  file = fopen("test.pcm", "w+b");
#endif
  printf("decode_audio\n");

  // printf("decode audio video->audioStream=>%d
  // queue=%p\n",video->audioStream,&video->packets[video->audioStream]);
  while (video->is_end == 0) {
    if (video->paused) {
      usleep(2000000);
      continue;
    }
    pthread_mutex_lock(&video->audio_mutex);
    AVPacket* packet = queue_out(&video->packets[video->audioStream]);
    if (packet != NULL) {
      // printf("queue%d out %p
      // len=%d\n",video->audioStream,packet,queue_get_length(&video->packets[video->audioStream]));
      // printf("decode_audio packet=%p\n",packet);
      // while(packet->size>0){
      avcodec_send_packet(video->aCodecCtx, packet);
      if (avcodec_receive_frame(video->aCodecCtx, video->aFrame) == 0) {
        video->aframeFinished = 1;
      }

      // int len=avcodec_decode_audio4(video->aCodecCtx, video->aFrame,
      // &video->aframeFinished,packet);
      if (video->aframeFinished) {
#if OUTPUT_PCM
        if (video->aCodecCtx->sample_fmt ==
            AV_SAMPLE_FMT_S16P) {  // Audacity: 16bit PCM little endian stereo
          int16_t* ptr_l = (int16_t*)video->aFrame->extended_data[0];
          int16_t* ptr_r = (int16_t*)video->aFrame->extended_data[1];

          /*for (int i=0; i<video->pFrame->nb_samples; i++){
            fwrite(ptr_l++, sizeof(int16_t), 1, outfile);
            fwrite(ptr_r++, sizeof(int16_t), 1, outfile);
            }*/
        } else if (video->aCodecCtx->sample_fmt ==
                   AV_SAMPLE_FMT_FLTP) {  // Audacity: big endian 32bit stereo
                                          // start offset 7 (but has noise)
          float* ptr_l = (float*)video->aFrame->extended_data[0];
          float* ptr_r = (float*)video->aFrame->extended_data[1];

          /*for (int i=0; i<frame->nb_samples; i++){
            fwrite(ptr_l++, sizeof(float), 1, outfile);
            fwrite(ptr_r++, sizeof(float), 1, outfile);
            }*/
        }
#endif
        // render audio
        AVStream* stream = video->pFormatCtx->streams[packet->stream_index];
        video->audio_current_pts =
            video->aFrame->pkt_pts * av_q2d(stream->time_base);
        // printf("audio_current_pts=>%f\n",video->audio_current_pts);

        if (firstCount < (NUM_BUFFERS - 1)) {
          // printf("#firstCount=>%d
          // buffer=%d\n",firstCount,video->alBuffers[firstCount]);
          video_update_audio_buffer(video, video->alBuffers[firstCount]);

          ALenum error = alGetError();
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error loading %x\n", error);
          } else {
            firstCount++;
          }
        } else if (firstCount == (NUM_BUFFERS - 1)) {
          // printf("=firstCount=>%d
          // buffer=%d\n",firstCount,video->alBuffers[firstCount]);
          // pthread_mutex_lock(&video->lock);
          alSourceQueueBuffers(video->alSource, QUEUE_NUM_BUFFERS,
                               video->alBuffers);

          ALenum error = alGetError();
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error starting alSourceQueueBuffers %x\n", error);
            // return 1;
          }
          alSourcePlay(video->alSource);
          error = alGetError();
          // pthread_mutex_unlock(&video->lock);
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error starting %x\n", error);
            // return 1;
          } else {
            firstCount++;
          }
        } else {
          // printf(">firstCount=>%d\n",firstCount);

          ALuint buffer;
          ALint val;
          ALenum error;
          do {
            alGetSourcei(video->alSource, AL_BUFFERS_PROCESSED, &val);
            usleep(2000);
          } while (val <= 0);
          alSourceUnqueueBuffers(video->alSource, 1, &buffer);

          error = alGetError();
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error buffering1  %x\n", error);
          }
          video_update_audio_buffer(video, buffer);

          error = alGetError();
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error buffering2  %x\n", error);
          }

          alSourceQueueBuffers(video->alSource, 1, &buffer);
          error = alGetError();
          if (error != AL_NO_ERROR) {
            fprintf(stderr, "Error buffering  %x\n", error);
          }

          alGetSourcei(video->alSource, AL_SOURCE_STATE, &val);
          if (val != AL_PLAYING) {
            alSourcePlay(video->alSource);
          }
        }
        pthread_cond_broadcast(&video->audio_cond);
      }
      // packet->data += len;
      /* 	packet->size-=len; */
      /* } */

      av_free_packet(packet);
      free(packet);
    } else {
      // printf("decode audio wait packet=%d\n",packet);
      pthread_cond_wait(&video->audio_cond, &video->audio_mutex);
    }
    pthread_mutex_unlock(&video->audio_mutex);
  }
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

int video_get_fps(video_t* video) { return video->fps; }

void video_update_video_last_pts(video_t* video) {
  double time = av_gettime() / 1000000.0;
  video->video_current_pts_drift = video->video_current_pts - time;
  video->frame_last_pts = video->video_current_pts;
}

void video_sync_video_pts(video_t* video, AVFrame* frame) {
  if (frame->pts == AV_NOPTS_VALUE) {
    video->video_current_pts = 0;
  } else {
    AVStream* stream = video->pFormatCtx->streams[video->videoStream];
    video->video_current_pts =
        av_frame_get_best_effort_timestamp(frame) * av_q2d(stream->time_base);
    // printf("video_current_pts %f\n",video->video_current_pts);
  }
}

void video_render(video_t* video, float x1, float y1, float x2, float y2) {
  // while(video->is_end==0){

  pthread_mutex_lock(&video->frame_mutex);
  AVFrame* frame = queue_get_head(&video->frames);
  if (frame != NULL) {
    // printf("video render %d\n",queue_get_length(&video->frames));
    // fflush(stdout);
    video->frame = frame;

    if (video->paused) {
      video_render_yuv(video, x1, y1, x2, y2);
      pthread_mutex_unlock(&video->frame_mutex);
      return;
    }
    video_sync_video_pts(video, frame);

    double last_duration = video->video_current_pts - video->frame_last_pts;
    if (last_duration > 0 && last_duration < 20.0) {
      video->frame_last_duration = last_duration;
    }

    double time = av_gettime() / 1000000.0;
    if (time < 0) {
      // printf("av_gettime err< %f\n",time);
      struct timeval tv;
      gettimeofday(&tv, NULL);
      time = ((int64_t)tv.tv_sec * 1000000 + tv.tv_usec) / 1000000.0;
    }
    double delay = compute_target_delay(video->frame_last_duration, video);

    // printf("time %ld %f delay=%f\n", time , av_gettime()/1000000.0 ,delay );
    // printf("%f < %f %f\n",time,video->frame_timer,delay );

    if (time < video->frame_timer + delay) {
      video_render_yuv(video, x1, y1, x2, y2);
      pthread_mutex_unlock(&video->frame_mutex);
      if (video->is_sleep == 1) {
        usleep((int)(delay * 700000));
      }
      return;
    }
    pthread_cond_broadcast(&video->frame_cond);

    if (delay > 0) {
      //更新frame_timer，frame_time是delay的累加值
      video->frame_timer +=
          delay * FFMAX(1, floor((time - video->frame_timer) / delay));
    }
    video_render_yuv(video, x1, y1, x2, y2);
    frame = queue_out(&video->frames);
    av_frame_unref(frame);

    video->fps = get_fps();
    video_update_video_last_pts(video);

    // pthread_mutex_unlock(&video->frame_mutex);
    // break;
  } else {
    if (video->frame != NULL) {
      video_render_yuv(video, x1, y1, x2, y2);
    }
    // printf("video wait\n");
    // pthread_cond_wait(&video->frame_cond,&video->frame_mutex);
  }

  pthread_mutex_unlock(&video->frame_mutex);

  //}
}

int video_init_media(video_t* video) {
  // bug
  video->pFormatCtx = avformat_alloc_context();
  av_register_all();

  avformat_network_init();

  // Read frames and save first five frames to disk
  if (avformat_open_input(&video->pFormatCtx, video->filename, NULL, NULL) !=
      0) {
    video->erro = -1;
    fprintf(stderr, "open file %s error.\n", video->filename);
    return video;
  }

  // Retrieve stream information
  if (avformat_find_stream_info(video->pFormatCtx, NULL) < 0) {
    video->erro = -1;
    return video;
  }
  // Dump information about file onto standard error
  // av_dump_format(video->pFormatCtx, 0, filename, 0);

  // Find the first video stream
  video->videoStream = -1;
  video->audioStream = -1;
  int i;
  for (i = 0; i < video->pFormatCtx->nb_streams; i++) {
    if (video->pFormatCtx->streams[i]->codec->codec_type ==
            AVMEDIA_TYPE_VIDEO &&
        video->videoStream < 0) {
      video->videoStream = i;
      // break;
    }
    if (video->pFormatCtx->streams[i]->codec->codec_type ==
            AVMEDIA_TYPE_AUDIO &&
        video->audioStream < 0) {
      video->audioStream = i;
    }
  }

  if (video->videoStream == -1) {
    video->erro = -1;
    fprintf(stderr, "Didn't find a video stream.\n");
  } else {
    // Get a pointer to the codec context for the video stream
    video->pCodecCtxOrig =
        video->pFormatCtx->streams[video->videoStream]->codec;
    // Find the decoder for the video stream
    video->pCodec = avcodec_find_decoder(video->pCodecCtxOrig->codec_id);
    if (video->pCodec == NULL) {
      fprintf(stderr, "Unsupported codec!\n");
      video->erro = -1;
      return video;
    }

    // Copy contexts
    video->pCodecCtx = avcodec_alloc_context3(video->pCodec);
    if (avcodec_copy_context(video->pCodecCtx, video->pCodecCtxOrig) != 0) {
      fprintf(stderr, "Couldn't copy codec context");
      video->erro = -1;
      return video;
    }

    // Open codec
    if (avcodec_open2(video->pCodecCtx, video->pCodec, NULL) < 0) {
      video->erro = -1;
      fprintf(stderr, "Couldn't open codec");
      return video;  // Could not open codec
    }

    // Determine required buffer size and allocate buffer
    /* video->numBytes=avpicture_get_size(AV_PIX_FMT_RGB24,
     * video->pCodecCtx->width, */
    /* 			      video->pCodecCtx->height); */

    if (video->use_soft_conver == 1) {
      // Allocate an AVFrame structure
      video->pFrameYUV = av_frame_alloc();
      if (video->pFrameYUV == NULL) {
        video->erro = -1;
        fprintf(stderr, "Allocate an AVFrame erro");
        return video;
      }

      // Determine required buffer size and allocate buffer
      video->numBytes =
          avpicture_get_size(AV_PIX_FMT_YUV420P, video->pCodecCtx->width,
                             video->pCodecCtx->height);
      video->buffer = (uint8_t*)av_malloc(video->numBytes * sizeof(uint8_t));

      // Assign appropriate parts of buffer to image planes in pFrameRGB
      // Note that pFrameRGB is an AVFrame, but AVFrame is a superset
      // of AVPicture
      avpicture_fill((AVPicture*)video->pFrameYUV, video->buffer,
                     AV_PIX_FMT_YUV420P, video->pCodecCtx->width,
                     video->pCodecCtx->height);

      // initialize SWS context for software scaling
      video->sws_ctx =
          sws_getContext(video->pCodecCtx->width, video->pCodecCtx->height,
                         video->pCodecCtx->pix_fmt, video->pCodecCtx->width,
                         video->pCodecCtx->height, AV_PIX_FMT_YUV420P,
                         SWS_BILINEAR, NULL, NULL, NULL);
    }
  }

  if (video->audioStream == -1) {
    video->erro = -1;
    fprintf(stderr, "Didn't find a audio stream.\n");

  } else {
    // audio code context
    video->aCodecCtx = video->pFormatCtx->streams[video->audioStream]->codec;
    // find decoder for audio stream
    video->aCodec = avcodec_find_decoder(video->aCodecCtx->codec_id);
    // open audio codec

    if (avcodec_open2(video->aCodecCtx, video->aCodec, NULL) < 0) {
      video->erro = -1;
      fprintf(stderr, "Couldn't open audio codec");
      return video;  // Could not open codec
    }
  }

  // Allocate video frame
  video->pFrame = av_frame_alloc();

  // allocate audio frame
  video->aFrame = av_frame_alloc();
  video->frame = NULL;

  // get duration length

  if (video->audioStream >= 0) {
    video->duration =
        video->pFormatCtx->streams[video->audioStream]->duration *
        av_q2d(video->pFormatCtx->streams[video->audioStream]->time_base);
  }

  if (video->videoStream >= 0) {
    video->duration =
        video->pFormatCtx->streams[video->videoStream]->duration *
        av_q2d(video->pFormatCtx->streams[video->videoStream]->time_base);
  }

  // printf("%f\n",video->duration);

  return 1;
}

void video_set_soft_conver(video_t* video, int mod) {
  video->use_soft_conver = mod;
}
double video_get_duration(video_t* video) {
  if (video != NULL) {
    return video->duration;
  }
  return 0.000001;
}

double video_get_current_duration(video_t* video) {
  if (video->video_current_pts < 0) {
    return video->audio_current_pts;
  }
  return video->video_current_pts;
}

double video_get_video_duration(video_t* video) {
  return video->video_current_pts;
}

double video_get_audio_duration(video_t* video) {
  return video->audio_current_pts;
}

video_t* video_new(char* filename, float width, float height) {
  video_t* video = malloc(sizeof(video_t));
  memset(video, 0, sizeof(video_t));
  video->texture[0] = -1;
  video->texture[1] = -1;
  video->texture[2] = -1;
  video->filename = filename;
  video->i = 0;
  video->window_width = width;
  video->window_height = height;
  video->av_sync_type = AV_SYNC_AUDIO_MASTER;
  video->video_current_pts = 0;
  video->filename = strdup(filename);
  video->use_soft_conver = 0;
  video->paused = 1;

  // gl init
  video_gl_init(video);
  int i;
  for (i = 0; i < MAX_STREAM; i++) {
    queue_init(&video->packets[i]);
    // printf("queue %d %p
    // %d\n",i,&video->packets[i],queue_get_length(&video->packets[i]) );
  }

  // frames queue;
  queue_init_with_size(&video->frames, VIDEO_QUEUE_SIZE);

  // thread init
  pthread_mutex_init(&video->audio_mutex, NULL);
  pthread_mutex_init(&video->video_mutex, NULL);
  pthread_mutex_init(&video->frame_mutex, NULL);

  pthread_cond_init(&video->audio_cond, NULL);
  pthread_cond_init(&video->video_cond, NULL);
  pthread_cond_init(&video->frame_cond, NULL);

  pthread_create(&(video->read_stream), NULL, read_stream, (void*)video);

  /* pthread_join(video->read_stream, NULL); */
  /* pthread_join(video->decode_audio, NULL); */

  return video;
}

void video_destroy(video_t* video) {
  // Free the RGB image
  av_free(video->buffer);
  av_frame_free(&video->pFrameYUV);
  av_frame_free(&video->pFrame);
  avcodec_close(video->pCodecCtx);
  avcodec_close(video->pCodecCtxOrig);
  avformat_close_input(&video->pFormatCtx);
}
