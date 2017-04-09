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

#ifdef GLAD
    #include "glad/glad.h"
    #include "glfw.h"

#define GLUT_RGB            0
#define GLUT_RGBA           GLUT_RGB
#define GLUT_INDEX          1
#define GLUT_SINGLE         0
#define GLUT_DOUBLE         2
#define GLUT_ACCUM          4
#define GLUT_ALPHA          8
#define GLUT_DEPTH          16
#define GLUT_STENCIL            32


#define GLUT_MULTISAMPLE        128
#define GLUT_STEREO         256

#define GLUTCALLBACK  
#define GLUTAPIENTRY  
#define GLUTAPI


/*
 * GLUT API macro definitions -- the special key codes:
 */
#define  GLUT_KEY_F1                        0x0001
#define  GLUT_KEY_F2                        0x0002
#define  GLUT_KEY_F3                        0x0003
#define  GLUT_KEY_F4                        0x0004
#define  GLUT_KEY_F5                        0x0005
#define  GLUT_KEY_F6                        0x0006
#define  GLUT_KEY_F7                        0x0007
#define  GLUT_KEY_F8                        0x0008
#define  GLUT_KEY_F9                        0x0009
#define  GLUT_KEY_F10                       0x000A
#define  GLUT_KEY_F11                       0x000B
#define  GLUT_KEY_F12                       0x000C
#define  GLUT_KEY_LEFT                      0x0064
#define  GLUT_KEY_UP                        0x0065
#define  GLUT_KEY_RIGHT                     0x0066
#define  GLUT_KEY_DOWN                      0x0067
#define  GLUT_KEY_PAGE_UP                   0x0068
#define  GLUT_KEY_PAGE_DOWN                 0x0069
#define  GLUT_KEY_HOME                      0x006A
#define  GLUT_KEY_END                       0x006B
#define  GLUT_KEY_INSERT                    0x006C

/*
 * GLUT API macro definitions -- mouse state definitions
 */
#define  GLUT_LEFT_BUTTON                   0x0000
#define  GLUT_MIDDLE_BUTTON                 0x0001
#define  GLUT_RIGHT_BUTTON                  0x0002
#define  GLUT_DOWN                          0x0000
#define  GLUT_UP                            0x0001
#define  GLUT_LEFT                          0x0000
#define  GLUT_ENTERED                       0x0001


 /*
 * GLUT API macro definitions -- the glutUseLayer parameters
 */
#define  GLUT_NORMAL                        0x0000
#define  GLUT_OVERLAY                       0x0001

/*
 * GLUT API macro definitions -- the glutGetModifiers parameters
 */
#define  GLUT_ACTIVE_SHIFT                  0x0001
#define  GLUT_ACTIVE_CTRL                   0x0002
#define  GLUT_ACTIVE_ALT                    0x0004



/*
 * GLUT API macro definitions -- the glutGet parameters
 */
#define  GLUT_WINDOW_X                      0x0064
#define  GLUT_WINDOW_Y                      0x0065
#define  GLUT_WINDOW_WIDTH                  0x0066
#define  GLUT_WINDOW_HEIGHT                 0x0067
#define  GLUT_WINDOW_BUFFER_SIZE            0x0068
#define  GLUT_WINDOW_STENCIL_SIZE           0x0069
#define  GLUT_WINDOW_DEPTH_SIZE             0x006A
#define  GLUT_WINDOW_RED_SIZE               0x006B
#define  GLUT_WINDOW_GREEN_SIZE             0x006C
#define  GLUT_WINDOW_BLUE_SIZE              0x006D
#define  GLUT_WINDOW_ALPHA_SIZE             0x006E
#define  GLUT_WINDOW_ACCUM_RED_SIZE         0x006F
#define  GLUT_WINDOW_ACCUM_GREEN_SIZE       0x0070
#define  GLUT_WINDOW_ACCUM_BLUE_SIZE        0x0071
#define  GLUT_WINDOW_ACCUM_ALPHA_SIZE       0x0072
#define  GLUT_WINDOW_DOUBLEBUFFER           0x0073
#define  GLUT_WINDOW_RGBA                   0x0074
#define  GLUT_WINDOW_PARENT                 0x0075
#define  GLUT_WINDOW_NUM_CHILDREN           0x0076
#define  GLUT_WINDOW_COLORMAP_SIZE          0x0077
#define  GLUT_WINDOW_NUM_SAMPLES            0x0078
#define  GLUT_WINDOW_STEREO                 0x0079
#define  GLUT_WINDOW_CURSOR                 0x007A

#define  GLUT_WINDOW_FRAMBUFFER_WIDTH                  0x007B
#define  GLUT_WINDOW_FRAMBUFFER_HEIGHT                 0x007C

#define  GLUT_SCREEN_WIDTH                  0x00C8
#define  GLUT_SCREEN_HEIGHT                 0x00C9
#define  GLUT_SCREEN_WIDTH_MM               0x00CA
#define  GLUT_SCREEN_HEIGHT_MM              0x00CB
#define  GLUT_MENU_NUM_ITEMS                0x012C
#define  GLUT_DISPLAY_MODE_POSSIBLE         0x0190
#define  GLUT_INIT_WINDOW_X                 0x01F4
#define  GLUT_INIT_WINDOW_Y                 0x01F5
#define  GLUT_INIT_WINDOW_WIDTH             0x01F6
#define  GLUT_INIT_WINDOW_HEIGHT            0x01F7
#define  GLUT_INIT_DISPLAY_MODE             0x01F8
#define  GLUT_ELAPSED_TIME                  0x02BC
#define  GLUT_WINDOW_FORMAT_ID              0x007B


/* -- GLOBAL TYPE DEFINITIONS ---------------------------------------------- */

/* Freeglut callbacks type definitions */
typedef void (* FGCBDisplay       )( void );
typedef void (* FGCBReshape       )( int, int );
typedef void (* FGCBPosition      )( int, int );
typedef void (* FGCBVisibility    )( int );
typedef void (* FGCBKeyboard      )( unsigned char, int, int );
typedef void (* FGCBKeyboardUp    )( unsigned char, int, int );
typedef void (* FGCBSpecial       )( int, int, int );
typedef void (* FGCBSpecialUp     )( int, int, int );
typedef void (* FGCBMouse         )( int, int, int, int );
typedef void (* FGCBMouseWheel    )( int, int, int, int );
typedef void (* FGCBMotion        )( int, int );
typedef void (* FGCBPassive       )( int, int );
typedef void (* FGCBEntry         )( int );
typedef void (* FGCBWindowStatus  )( int );
typedef void (* FGCBJoystick      )( unsigned int, int, int, int );
typedef void (* FGCBOverlayDisplay)( void );
typedef void (* FGCBSpaceMotion   )( int, int, int );
typedef void (* FGCBSpaceRotation )( int, int, int );
typedef void (* FGCBSpaceButton   )( int, int );
typedef void (* FGCBDials         )( int, int );
typedef void (* FGCBButtonBox     )( int, int );
typedef void (* FGCBTabletMotion  )( int, int );
typedef void (* FGCBTabletButton  )( int, int, int, int );
typedef void (* FGCBDestroy       )( void );    /* Used for both window and menu destroy callbacks */

typedef void (* FGCBMultiEntry   )( int, int );
typedef void (* FGCBMultiButton  )( int, int, int, int, int );
typedef void (* FGCBMultiMotion  )( int, int, int );
typedef void (* FGCBMultiPassive )( int, int, int );

typedef void (* FGCBInitContext)();
typedef void (* FGCBAppStatus)(int);

/* The global callbacks type definitions */
typedef void (* FGCBIdle          )( void );
typedef void (* FGCBTimer         )( int );
typedef void (* FGCBMenuState     )( int );
typedef void (* FGCBMenuStatus    )( int, int, int );




GLUTAPI int  GLUTAPIENTRY glutGetModifiers();
GLUTAPI  int GLUTAPIENTRY glutCreateWindow(const char *title);

GLUTAPI  void  GLUTAPIENTRY glutDisplayFunc(FGCBDisplay func);

GLUTAPI void GLUTAPIENTRY  glutReshapeFunc(FGCBReshape func);


GLUTAPI void  GLUTAPIENTRY glutMotionFunc(FGCBMotion func);

GLUTAPI void GLUTAPIENTRY  glutKeyboardFunc(FGCBKeyboard func);

GLUTAPI void GLUTAPIENTRY  glutMouseFunc(FGCBMouse func);

GLUTAPI void GLUTAPIENTRY  glutIdleFunc(FGCBIdle func );
GLUTAPI void GLUTAPIENTRY glutInit(int *argcp, char **argv);
GLUTAPI void GLUTAPIENTRY glutInitDisplayMode(unsigned int mode);
GLUTAPI void GLUTAPIENTRY glutInitWindowPosition(int x, int y);
GLUTAPI void GLUTAPIENTRY glutInitWindowSize(int width, int height);

GLUTAPI void GLUTAPIENTRY glutMainLoop(void);
GLUTAPI void GLUTAPIENTRY glutKeyboardUpFunc(void (GLUTCALLBACK *func)(unsigned char key, int x, int y));
GLUTAPI void GLUTAPIENTRY glutSpecialUpFunc(void (GLUTCALLBACK *func)(int key, int x, int y));
GLUTAPI void GLUTAPIENTRY glutSpecialFunc(void (GLUTCALLBACK *func)(int key, int x, int y));
GLUTAPI void GLUTAPIENTRY glutPostRedisplay(void);
GLUTAPI void GLUTAPIENTRY glutSwapBuffers(void);
GLUTAPI void GLUTAPIENTRY glutTimerFunc(unsigned int millis, void (GLUTCALLBACK *func)(int value), int value);
GLUTAPI void GLUTAPIENTRY glutSetWindowTitle(const char *title);


/*
 * State setting and retrieval functions, see fg_state.c
 */
GLUTAPI int     GLUTAPIENTRY glutGet( GLenum query );
GLUTAPI int     GLUTAPIENTRY glutDeviceGet( GLenum query );
GLUTAPI int     GLUTAPIENTRY glutGetModifiers( void );
GLUTAPI int     GLUTAPIENTRY glutLayerGet( GLenum query );


#endif

SCM_API void glut_init();
SCM_API void glut_exit();
SCM_API void glut_main_loop();
SCM_API void glut_sleep(int ms);
SCM_API void glut_on_event(int type,int x,int y);
SCM_API void glut_on_key_event(int type, int key);
SCM_API void glut_on_touch_event(int type, int x, int y);
SCM_API void glut_on_mouse_event(int button, int state);
SCM_API void glut_on_motion_event(int x,int y);
SCM_API void glut_on_display();
SCM_API void glut_on_reshape(int width,int height);
SCM_API void glut_test();
SCM_API void glut_log(char *msg);
SCM_API void glut_set_gl_version(int ver) ;
SCM_API void glut_set_soft_input_mode(int showFlags, int hideFlags);


#ifdef __cplusplus
}
#endif

#endif //GLUT_H
