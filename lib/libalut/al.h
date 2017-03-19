/**
 * 作者:evilbinary on 12/13/16.
 * 邮箱:rootdebug@163.com 
 */
#ifndef AL_H
#define AL_H

#include "scm.h"

#ifdef __APPLE__
#include <OpenAL/al.h>
#else
#include <AL/al.h>
#endif


SCM_API ALuint al_gen_source(ALsizei n);

#endif //AL_H
