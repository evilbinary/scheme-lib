/**
 * 作者:evilbinary on 10/30/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef SCM_H_H
#define SCM_H_H


#ifdef ANDROID
    typedef void *ptr;
    typedef int iptr;
    typedef unsigned int uptr;
#else
    #ifdef __x86_64__

    typedef void * ptr;
    typedef long int iptr;
    typedef unsigned long int uptr;
       
    #else
    typedef void * ptr;
    typedef int iptr;
    typedef unsigned int uptr;
    #endif
    
#endif

#define scm_fixnum(x) ((ptr)(uptr)((x)*8))
#define scm_char(x) ((ptr)(uptr)((x)<<8|0x16))
#define scm_nil ((ptr)0x26)
#define scm_true ((ptr)0xE)
#define scm_false ((ptr)0x6)
#define scm_boolean(x) ((x)?scm_true:scm_false)
#define scm_bwp_object ((ptr)0x4E)
#define scm_void ((ptr)0x3E)
#define scm_eof_object ((ptr)0x36)

#define scm_fixnump(x) (((uptr)(x)&0x7)==0x0)
#define scm_charp(x) (((uptr)(x)&0xFF)==0x16)
#define scm_nullp(x) ((uptr)(x)==0x26)
#define scm_eof_objectp(x) ((uptr)(x)==0x36)
#define scm_bwp_objectp(x) ((uptr)(x)==0x4E)
#define scm_booleanp(x) (((uptr)(x)&0xF7)==0x6)
#define scm_pairp(x) (((uptr)(x)&0x7)==0x1)
#define scm_symbolp(x) (((uptr)(x)&0x7)==0x3)
#define scm_procedurep(x) (((uptr)(x)&0x7)==0x5)
#define scm_flonump(x) (((uptr)(x)&0x7)==0x2)

#ifdef __cplusplus
extern "C" {
#endif



    int scm_init();

    ptr scm_read_string(char *string);

    ptr scm_eval(char *string);
    ptr scm_eval_exp(ptr exp);
    char *scm_strings(ptr p);
    ptr scm_string(char * p);
    void scm_deinit();

    ptr scm_call0(ptr who);

    ptr scm_call1(ptr who, ptr arg);

    ptr scm_call2(ptr who, ptr arg0, ptr arg1);

    ptr scm_call3(ptr who, ptr arg0, ptr arg1, ptr arg2);
    ptr scm_call4(ptr who,ptr arg0,ptr arg1,ptr arg2,ptr arg3);

    iptr scm_fixnum_value(ptr p);

    iptr scm_objectp(ptr p);

#ifdef __cplusplus
}
#endif

#endif //SCM_H_H
