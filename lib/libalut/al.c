#include "al.h"
#include <stdio.h>


SCM_API int alut_play_file2 (const char *fileName){
  ALuint buffer;
  ALuint source;
  ALenum error;
  ALint status;

  /* Create an AL buffer from the given sound file. */
  buffer = alutCreateBufferFromFile (fileName);
  /* Generate a single source, attach the buffer to it and start playing. */
  alGenSources (1, &source);
  alSourcei (source, AL_BUFFER, buffer);
  alSourcePlay (source);
    return source;
}

SCM_API void test(ALuint source,ALuint buffer){
  printf("aaa==buffer=%d\n",buffer);
	//ALuint source;
  //buffer = alutCreateBufferFromFile ("game_bg.wav");
  //alGenSources (1, &source);

  alSourcei (source, AL_BUFFER, buffer);
  alSourcePlay (source);
}
SCM_API ALuint al_gen_source(ALsizei n){
	ALuint source;
	alGenSources(n,&source);
	return source;
}
