/**
 * 作者:evilbinary on 12/13/16.
 * 邮箱:rootdebug@163.com 
 */
#include "alut.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <AL/alut.h>

/*
 * This program loads and plays a variety of files.
 */

SCM_API int alut_init(){
	return alutInit (0, NULL);
}
SCM_API void alut_exit(){
	alutExit();
}
SCM_API int alut_play_file (const char *fileName){
  ALuint buffer;
  ALuint source;
  ALenum error;
  ALint status;

  /* Create an AL buffer from the given sound file. */
  buffer = alutCreateBufferFromFile (fileName);
  if (buffer == AL_NONE)
    {
      error = alutGetError ();
      fprintf (stderr, "Error loading file: '%s'\n",
               alutGetErrorString (error));
     return source;
    }

  /* Generate a single source, attach the buffer to it and start playing. */
  alGenSources (1, &source);
  alSourcei (source, AL_BUFFER, buffer);
  alSourcePlay (source);
  /* Normally nothing should go wrong above, but one never knows... */
  error = alGetError ();
  if (error != ALUT_ERROR_NO_ERROR)
    {
      fprintf (stderr, "ee=%s\n", alGetString (error));
      return source;
    }

  /* Check every 0.1 seconds if the sound is still playing. */
  // do
  //   {
  //     //alutSleep (0.1f);
  //     //alGetSourcei (source, AL_SOURCE_STATE, &status);
  //   }
  // while (status == AL_PLAYING);
    return source;
}

int
test_main (int argc, char **argv)
{
  /* Initialise ALUT and eat any ALUT-specific commandline flags. */
  if (!alutInit (0, NULL))
    {
      ALenum error = alutGetError ();
      fprintf (stderr, "error=%s\n", alutGetErrorString (error));
      exit (EXIT_FAILURE);
    }

  /* Check for correct usage. */
  if (argc != 2)
    {
      fprintf (stderr, "usage: playfile <fileName>\n");
      alutExit ();
      exit (EXIT_FAILURE);
    }

  /* If everything is OK, play the sound file and exit when finished. */
  alut_play_file (argv[1]);
getchar();

  if (!alutExit ())
    {
      ALenum error = alutGetError ();
      fprintf (stderr, "eeor=%s\n", alutGetErrorString (error));
      exit (EXIT_FAILURE);
    }
  return EXIT_SUCCESS;
}