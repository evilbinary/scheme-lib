/**
 * 作者:evilbinary on 10/30/16.
 * 邮箱:rootdebug@163.com 
 */

#ifndef SCM_H_H
#define SCM_H_H


#ifdef _WIN32
#  if __cplusplus
#    ifdef SCM_IMPORT
#      define SCM_API extern "C" __declspec (dllimport)
#    elif SCM_STATIC
#      define SCM_API extern "C"
#    else
#      define SCM_API extern "C" __declspec (dllexport)
#    endif
#  else
#    ifdef SCM_IMPORT
#      define SCM_API extern __declspec (dllimport)
#    elif SCM_STATIC
#      define SCM_API extern
#    else
#      define SCM_API extern __declspec (dllexport)
#    endif
#  endif
#else
#  if __cplusplus
#    define SCM_API extern "C"
#  else
#    define SCM_API extern
#  endif
#endif

#ifdef ANDROID
    typedef void *ptr;
    typedef int iptr;
    typedef unsigned int uptr;

    #define scm_fixnum(x) ((ptr)(uptr)((x)*4))
    #define scm_char(x) ((ptr)(uptr)((x)<<8|0x16))
    #define scm_nil ((ptr)0x26)
    #define scm_true ((ptr)0xE)
    #define scm_false ((ptr)0x6)
    #define scm_boolean(x) ((x)?scm_true:scm_false)
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
    #define scm_boolean(x) ((x)?scm_true:scm_false)
    #define scm_bwp_object ((ptr)0x4E)
    #define scm_eof_object ((ptr)0x36)
    #define scm_void ((ptr)0x3E)

    #endif
    
#endif

    

SCM_API int scm_init();
SCM_API ptr scm_read_string(char *string);
SCM_API ptr scm_eval(char *string);
SCM_API ptr scm_eval_exp(ptr exp);
SCM_API char *scm_strings(ptr p);
SCM_API ptr scm_string(char * p);
SCM_API void scm_deinit();
SCM_API ptr scm_call0(ptr who);
SCM_API ptr scm_call1(ptr who, ptr arg);
SCM_API ptr scm_call2(ptr who, ptr arg0, ptr arg1);
SCM_API ptr scm_call3(ptr who, ptr arg0, ptr arg1, ptr arg2);
SCM_API ptr scm_call4(ptr who,ptr arg0,ptr arg1,ptr arg2,ptr arg3);
SCM_API ptr scm_call0_proc(ptr proc);
SCM_API ptr scm_call1_proc(ptr proc,ptr arg);
SCM_API ptr scm_call2_proc(ptr proc,ptr arg0,ptr arg1);
SCM_API ptr scm_call3_proc(ptr proc,ptr arg0,ptr arg1,ptr arg2);
SCM_API ptr scm_call4_proc(ptr proc,ptr arg0,ptr arg1,ptr arg2,ptr arg3);
SCM_API ptr scm_call5_proc(ptr proc,ptr arg0,ptr arg1,ptr arg2,ptr arg3,ptr arg4);


SCM_API iptr scm_fixnum_value(ptr p);
SCM_API iptr scm_objectp(ptr p);
SCM_API iptr scm_fixnump(ptr x);
SCM_API iptr scm_charp(ptr x);
SCM_API iptr scm_nullp(ptr x);
SCM_API iptr scm_eof_objectp(ptr x);
SCM_API iptr scm_bwp_objectp(ptr x);
SCM_API iptr scm_booleanp(ptr x);
SCM_API iptr scm_pairp(ptr x);
SCM_API iptr scm_symbolp(ptr x) ;
SCM_API iptr scm_procedurep(ptr x);
SCM_API iptr scm_flonump(ptr x) ;

SCM_API ptr scm_flonum(double x);
SCM_API double scm_flonum_value(ptr x);

SCM_API ptr scm_integer64 (long long);
SCM_API void scm_print(ptr p);
SCM_API ptr scm_get_thread_context();

#endif //SCM_H_H
