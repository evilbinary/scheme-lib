#ifndef _C_H
#define _C_H

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




#ifdef __cplusplus
extern "C" {
#endif

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

SCM_API long      c_a64l(const char *);
SCM_API void      c_abort(void);
SCM_API int       c_abs(int);
SCM_API int       c_atexit(void (*)(void));
SCM_API double    c_atof(const char *);
SCM_API int       c_atoi(const char *);
SCM_API long int  c_atol(const char *);
SCM_API void     *c_bsearch(const void *, const void *, size_t, size_t, int (*)(const void *, const void *));
SCM_API void     *c_calloc(size_t, size_t);
SCM_API div_t     c_div(int, int);
SCM_API double    c_drand48(void);
SCM_API char     *c_ecvt(double, int, int *, int *);
SCM_API double    c_erand48(unsigned short int[3]);
SCM_API void      c_exit(int);
SCM_API char     *c_fcvt (double, int, int *, int *);
SCM_API void      c_free(void *);
SCM_API char     *c_gcvt(double, int, char *);
SCM_API char     *c_getenv(const char *);
SCM_API int       c_getsubopt(char **, char *const *, char **);
SCM_API int       c_grantpt(int);
SCM_API char     *c_initstate(unsigned int, char *, size_t);
SCM_API char     *c_l64a(long);
SCM_API long int  c_labs(long int);
SCM_API void      c_lcong48(unsigned short int[7]);
SCM_API ldiv_t    c_ldiv(long int, long int);
SCM_API long int  c_lrand48(void);
SCM_API void     *c_malloc(size_t);
SCM_API int       c_mblen(const char *, size_t);
SCM_API size_t    c_mbstowcs(wchar_t *, const char *, size_t);
SCM_API int       c_mbtowc(wchar_t *, const char *, size_t);
SCM_API char     *c_mktemp(char *);
SCM_API int       c_mkstemp(char *);
SCM_API long int  c_mrand48(void);
SCM_API long int  c_nrand48(unsigned short int [3]);
SCM_API char     *c_ptsname(int);
SCM_API int       c_putenv(char *);
SCM_API void      c_qsort(void *, size_t, size_t, int (*)(const void *, const void *));
SCM_API int       c_rand(void);
SCM_API int       c_rand_r(unsigned int *);
SCM_API long      c_random(void);
SCM_API void     *c_realloc(void *, size_t);
SCM_API char     *c_realpath(const char *, char *);
SCM_API unsigned  short int    c_seed(unsigned short int[3]);
SCM_API void      c_setkey(const char *);
SCM_API char     *c_setstate(const char *);
SCM_API void      c_srand(unsigned int);
SCM_API void      c_srand48(long int);
SCM_API void      c_srandom(unsigned);
SCM_API double    c_strtod(const char *, char **);
SCM_API long int  c_strtol(const char *, char **, int);
SCM_API unsigned long int c_strtoul(const char *, char **, int);
SCM_API int       c_system(const char *);
SCM_API int       c_unlockpt(int);
SCM_API size_t    c_wcstombs(char *, const wchar_t *, size_t);
SCM_API int       c_wctomb(char *, wchar_t);
SCM_API double c_acos(double);
SCM_API double c_asin(double);
SCM_API double c_atan(double);
SCM_API double c_atan2(double, double);
SCM_API double c_ceil(double);
SCM_API double c_cos(double);
SCM_API double c_cosh(double);
SCM_API double c_exp(double);
SCM_API double c_fabs(double);
SCM_API double c_floor(double);
SCM_API double c_fmod(double, double);
SCM_API double c_frexp(double, int *);
SCM_API double c_ldexp(double, int);
SCM_API double c_log(double);
SCM_API double c_log10(double);
SCM_API double c_modf(double, double *);
SCM_API double c_pow(double, double);
SCM_API double c_sin(double);
SCM_API double c_sinh(double);
SCM_API double c_sqrt(double);
SCM_API double c_tan(double);
SCM_API double c_tanh(double);
SCM_API double c_erf(double);
SCM_API double c_erfc(double);
SCM_API double c_gamma(double);
SCM_API double c_hypot(double, double);
SCM_API double c_j0(double);
SCM_API double c_j1(double);
SCM_API double c_jn(int, double);
SCM_API double c_lgamma(double);
SCM_API double c_y0(double);
SCM_API double c_y1(double);
SCM_API double c_yn(int, double);
SCM_API int    c_isnan(double);
SCM_API double c_acosh(double);
SCM_API double c_asinh(double);
SCM_API double c_atanh(double);
SCM_API double c_cbrt(double);
SCM_API double c_expm1(double);
SCM_API int    c_ilogb(double);
SCM_API double c_log1p(double);
SCM_API double c_logb(double);
SCM_API double c_nextafter(double, double);
SCM_API double c_remainder(double, double);
SCM_API double c_rint(double);
SCM_API double c_scalb(double, double); 
SCM_API void  c_clearerr(FILE *);
SCM_API char *c_ctermid(char *);
SCM_API char *c_cuserid(char *); // LEGACY
SCM_API int   c_fclose(FILE *);
SCM_API FILE *c_fdopen(int, const char *);
SCM_API int c_feof(FILE *);
SCM_API int c_ferror(FILE *);
SCM_API int c_fflush(FILE *);
SCM_API int c_fgetc(FILE *);
SCM_API int c_fgetpos(FILE *, fpos_t *);
SCM_API char *c_fgets(char *, int, FILE *);
SCM_API int c_fileno(FILE *);
SCM_API void  c_flockfile(FILE *);
SCM_API FILE  *c_fopen(const char *, const char *);
SCM_API int c_fprintf(FILE *, const char *, ...);
SCM_API int c_fputc(int, FILE *);
SCM_API int c_fputs(const char *, FILE *);
SCM_API size_t   c_fread(char *, size_t, size_t, FILE *);
SCM_API FILE *c_freopen(const char *, const char *, FILE *);
SCM_API int c_fscanf(FILE *, const char *, ...);
SCM_API int c_fseek(FILE *, long int, int);
SCM_API int c_fseeko(FILE *, off_t, int);
SCM_API int c_fsetpos(FILE *, const fpos_t *);
SCM_API long int c_ftell(FILE *);
SCM_API off_t c_ftello(FILE *);
SCM_API int c_ftrylockfile(FILE *);
SCM_API void  c_funlockfile(FILE *);
SCM_API size_t   c_fwrite(const void *, size_t, size_t, FILE *);
SCM_API int c_getc(FILE *);
SCM_API int c_getchar(void);
SCM_API int c_getc_unlocked(FILE *);
SCM_API int c_getchar_unlocked(void);
SCM_API int c_getopt(int, char **, const char*);  // LEGACY
SCM_API char *c_gets(char *);
SCM_API int c_getw(FILE *);
SCM_API int c_pclose(FILE *);
SCM_API void  c_perror(const char *);
SCM_API FILE *c_popen(const char *, const char *);
SCM_API int c_printf(const char *, ...);
SCM_API int c_putc(int, FILE *);
SCM_API int c_putchar(int);
SCM_API int c_putc_unlocked(int, FILE *);
SCM_API int c_putchar_unlocked(int);
SCM_API int c_puts(const char *);
SCM_API int c_putw(int, FILE *);
SCM_API int c_remove(const char *);
SCM_API int c_rename(const char *, const char *);
SCM_API void  c_rewind(FILE *);
SCM_API int c_scanf(const char *, ...);
SCM_API void  c_setbuf(FILE *, char *);
SCM_API int c_setvbuf(FILE *, char *, int, size_t);
SCM_API int c_snprintf(char *, size_t, const char *, ...);
SCM_API int c_sprintf(char *, const char *, ...);
SCM_API int c_sscanf(const char *, const char *, ...);
SCM_API char *c_tempnam(const char *, const char *);
SCM_API FILE *c_tmpfile(void);
SCM_API char *c_tmpnam(char *);
SCM_API int c_ungetc(int, FILE *);
SCM_API int c_vfprintf(FILE *, const char *, va_list);
SCM_API int c_vprintf(const char *, va_list);
SCM_API int c_vsnprintf(char *, size_t, const char *, va_list);
SCM_API int c_vsprintf(char *, const char *, va_list);
SCM_API void    *c_memccpy(void *, const void *, int, size_t);
SCM_API void    *c_memchr(const void *, int, size_t);
SCM_API int      c_memcmp(const void *, const void *, size_t);
SCM_API void    *c_memcpy(void *, const void *, size_t);
SCM_API void    *c_memmove(void *, const void *, size_t);
SCM_API void    *c_memset(void *, int, size_t);
SCM_API char    *c_strcat(char *, const char *);
SCM_API char    *c_strchr(const char *, int);
SCM_API int      c_strcmp(const char *, const char *);
SCM_API int      c_strcoll(const char *, const char *);
SCM_API char    *c_strcpy(char *, const char *);
SCM_API size_t   c_strcspn(const char *, const char *);
SCM_API char    *c_strdup(const char *);
SCM_API char    *c_strerror(int);
SCM_API size_t   c_strlen(const char *);
SCM_API char    *c_strncat(char *, const char *, size_t);
SCM_API int      c_strncmp(const char *, const char *, size_t);
SCM_API char    *c_strncpy(char *, const char *, size_t);
SCM_API char    *c_strpbrk(const char *, const char *);
SCM_API char    *c_strrchr(const char *, int);
SCM_API size_t   c_strspn(const char *, const char *);
SCM_API char    *c_strstr(const char *, const char *);
SCM_API char    *c_strtok(char *, const char *);
SCM_API char    *c_strtok_r(char *, const char *, char **);
SCM_API size_t   c_strxfrm(char *, const char *, size_t);
SCM_API char*	 c_strndup(const char *s, size_t n);
SCM_API int    c_bcmp(const void *, const void *, size_t);
SCM_API void   c_bcopy(const void *, void *, size_t);
SCM_API void   c_bzero(void *, size_t);
SCM_API int    c_ffs(int);
SCM_API char   *c_index(const char *, int);
SCM_API char   *c_rindex(const char *, int);
SCM_API int    c_strcasecmp(const char *, const char *);
SCM_API int    c_strncasecmp(const char *, const char *, size_t);



#ifdef __cplusplus
}
#endif



#endif



