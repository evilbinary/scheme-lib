#ifndef _TERMILAL_H
#define _TERMILAL_H

#include <string.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef WIN32
	#include <winsock2.h>
	#include <winsock.h>
	#include <ws2tcpip.h>

#else
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <sys/un.h>
	#include <sys/ioctl.h>
	#include <netinet/in.h>
	#include <unistd.h>
#endif


#include "libtsm.h"
#include "libtsm_int.h"
#include "graphic.h"
#include "xkbcommon-keysyms.h"
#include "shl_pty.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct terminal_t{
	struct tsm_screen *console;
	struct tsm_vte *vte;
	struct shl_pty *pty;
	struct tsm_screen_attr attr;
	font_t * font;
	float lineh;
	float linew;
	float ascender;
 	float descender;
	float x,y;
	float starx,stary;
	float scale;
	mvp_t* mvp;
	float width;
	float height;
}terminal;


#define KMOD_SHIFT           0x0001
#define KMOD_CTRL         0x0002
#define KMOD_ALT             0x0004
#define KMOD_META           0x0008

#ifdef __cplusplus
}
#endif



#endif



