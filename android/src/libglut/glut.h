/**
 * 作者:evilbinary on 10/31/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef CHEZ_GLUT_H
#define CHEZ_GLUT_H


#define ACTION_DOWN  0
#define ACTION_UP   1
#define  ACTION_MOVE 2

#include "scheme.h"

#define CALL0(who) Scall0(Stop_level_value(Sstring_to_symbol(who)))
#define CALL1(who, arg) Scall1(Stop_level_value(Sstring_to_symbol(who)), arg)

#define CALL2(who, arg0,arg1) Scall2(Stop_level_value(Sstring_to_symbol(who)), arg0,arg1)
#define CALL3(who, arg0,arg1,arg2) Scall3(Stop_level_value(Sstring_to_symbol(who)), arg0,arg1,arg2)



void glut_init();
void glut_exit();
void glut_main_loop_init();

void glut_sleep(int ms);

void glut_on_event(int type,int x,int y);
void glut_on_display();
void glut_on_reshape(int width,int height);
void glut_main_loop_run();



#endif //CHEZ_GLUT_H
