/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com
 */

#ifndef __DUCK_LOGGER_H__
#define __DUCK_LOGGER_H__
#if ANDROID

#ifndef  LOG_TAG
#define  LOG_TAG    "gui"
#endif

#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO,LOG_TAG , __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define LOGV(...) ((void)__android_log_print(ANDROID_LOG_VERBOSE, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...)  fprintf(stdout,__VA_ARGS__)
#define LOGW(...)  fprintf(stdout,__VA_ARGS__)
#define LOGE(...)  fprintf(stdout,__VA_ARGS__)

#endif


#endif