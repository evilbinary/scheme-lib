/**
 * 作者:evilbinary on 10/30/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef CHEZ_SCM_H_H
#define CHEZ_SCM_H_H

#include <jni.h>

typedef void *ptr;
typedef int iptr;
typedef unsigned int uptr;

#ifdef __cplusplus
extern "C" {
#endif

    int scm_init();

    ptr scm_read_string(char *string);

    ptr scm_eval(char *string);

    char *scm_string(ptr p);

    void scm_deinit();

    ptr scm_procedurep(ptr p);

    ptr scm_call0(ptr who);

    ptr scm_call1(ptr who, ptr arg);

    ptr scm_call2(ptr who, ptr arg0, ptr arg1);

    ptr scm_call3(ptr who, ptr arg0, ptr arg1, ptr arg2);

    iptr scm_fixnum_value(ptr p);

    char *jstringTostring(JNIEnv *env, jstring jstr);

    jstring strToJstring(JNIEnv *env, const char *pat);

#ifdef __cplusplus
}
#endif
#endif //CHEZ_SCM_H_H
