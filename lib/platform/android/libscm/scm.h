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

    #define scm_fixnum(x) ((ptr)(uptr)((x)*4))
    #define scm_char(x) ((ptr)(uptr)((x)<<8|0x16))
    #define scm_nil ((ptr)0x26)
    #define scm_true ((ptr)0xE)
    #define scm_false ((ptr)0x6)
    #define scm_boolean(x) ((x)?Strue:Sfalse)
    #define scm_bwp_object ((ptr)0x4E)
    #define scm_eof_object ((ptr)0x36)
    #define scm_void ((ptr)0x3E)
#else
    #ifdef __x86_64__

    typedef void * ptr;
    typedef long int iptr;
    typedef unsigned long int uptr;
    
    #define scm_fixnum(x) ((ptr)(uptr)((x)*8))
    #define scm_char(x) ((ptr)(uptr)((x)<<8|0x16))
    #define scm_nil ((ptr)0x26)
    #define scm_true ((ptr)0xE)
    #define scm_false ((ptr)0x6)
    #define scm_boolean(x) ((x)?scm_true:scm_false)
    #define scm_bwp_object ((ptr)0x4E)
    #define scm_void ((ptr)0x3E)
    #define scm_eof_object ((ptr)0x36)

    #else
    typedef void * ptr;
    typedef int iptr;
    typedef unsigned int uptr;

    #define scm_fixnum(x) ((ptr)(uptr)((x)*4))
    #define scm_char(x) ((ptr)(uptr)((x)<<8|0x16))
    #define scm_nil ((ptr)0x26)
    #define scm_true ((ptr)0xE)
    #define scm_false ((ptr)0x6)
    #define scm_boolean(x) ((x)?Strue:Sfalse)
    #define scm_bwp_object ((ptr)0x4E)
    #define scm_eof_object ((ptr)0x36)
    #define scm_void ((ptr)0x3E)

    #endif
    
#endif





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

    iptr scm_fixnump(ptr x);
    iptr scm_charp(ptr x);

    iptr scm_nullp(ptr x);
    iptr scm_eof_objectp(ptr x);
    iptr scm_bwp_objectp(ptr x);
    iptr scm_booleanp(ptr x);
    iptr scm_pairp(ptr x);
    iptr scm_symbolp(ptr x) ;
    iptr scm_procedurep(ptr x);
    iptr scm_flonump(ptr x) ;


#ifdef __cplusplus
}
#endif

#endif //SCM_H_H
