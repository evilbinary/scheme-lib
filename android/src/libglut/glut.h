/**
 * 作者:evilbinary on 10/31/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef GLUT_H
#define GLUT_H

#include "scm.h"

void glut_init();
void glut_exit();
void glut_main_loop_init();

void glut_sleep(int ms);

void glut_on_event(int type,int x,int y);
void glut_on_display();
void glut_on_reshape(int width,int height);
void glut_main_loop_run();



#endif //GLUT_H
