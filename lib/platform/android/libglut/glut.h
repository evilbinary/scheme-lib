/**
 * 作者:evilbinary on 10/31/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef GLUT_H
#define GLUT_H

#include "scm.h"

#ifdef __cplusplus
extern "C" {
#endif
	
void glut_init();
void glut_exit();
void glut_main_loop();
void glut_sleep(int ms);

void glut_on_event(int type,int x,int y);
void glut_on_key_event(int type, int key);
void glut_on_touch_event(int type, int x, int y);

void glut_on_mouse_event(int button, int state);
void glut_on_motion_event(int x,int y);

void glut_on_display();
void glut_on_reshape(int width,int height);


#ifdef __cplusplus
}
#endif

#endif //GLUT_H
