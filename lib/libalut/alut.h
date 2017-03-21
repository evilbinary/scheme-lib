/**
 * 作者:evilbinary on 12/13/16.
 * 邮箱:rootdebug@163.com 
 */
#ifndef ALUT_H
#define ALUT_H

#include "scm.h"

SCM_API int alut_init();
SCM_API void alut_exit();
SCM_API int alut_play_file (const char *fileName);

#endif //GLUT_H