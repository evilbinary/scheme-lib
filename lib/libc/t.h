#ifndef _H
#define _H

#include <string.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

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

long      a64l(const char *);
void      abort(void);
int       abs(int);
int       atexit(void (*)(void));
double    atof(const char *);
int       atoi(const char *);
long int  atol(const char *);
void     *bsearch(const void *, const void *, size_t, size_t, int (*)(const void *, const void *));
void     *calloc(size_t, size_t);
div_t     div(int, int);
double    drand48(void);
char     *ecvt(double, int, int *, int *);
double    erand48(unsigned short int[3]);
void      exit(int);
char     *fcvt (double, int, int *, int *);
void      free(void *);

char     *gcvt(double, int, char *);
char     *getenv(const char *);
int       getsubopt(char **, char *const *, char **);
int       grantpt(int);
char     *initstate(unsigned int, char *, size_t);
long int  jrand48(unsigned short int[3]);
char     *l64a(long);
long int  labs(long int);
void      lcong48(unsigned short int[7]);
ldiv_t    ldiv(long int, long int);
long int  lrand48(void);
void     *malloc(size_t);
int       mblen(const char *, size_t);
size_t    mbstowcs(wchar_t *, const char *, size_t);
int       mbtowc(wchar_t *, const char *, size_t);
char     *mktemp(char *);
int       mkstemp(char *);
long int  mrand48(void);
long int  nrand48(unsigned short int [3]);
char     *ptsname(int);
int       putenv(char *);
void      qsort(void *, size_t, size_t, int (*)(const void *, const void *));
int       rand(void);
int       rand_r(unsigned int *);
long      random(void);
void     *realloc(void *, size_t);
char     *realpath(const char *, char *);
unsigned  short int    seed48(unsigned short int[3]);
void      setkey(const char *);
char     *setstate(const char *);
void      srand(unsigned int);
void      srand48(long int);
void      srandom(unsigned);
double    strtod(const char *, char **);
long int  strtol(const char *, char **, int);
unsigned long int strtoul(const char *, char **, int);
int       system(const char *);
int       unlockpt(int);
size_t    wcstombs(char *, const wchar_t *, size_t);
int       wctomb(char *, wchar_t);

double acos(double);
double asin(double);
double atan(double);
double atan2(double, double);
double ceil(double);
double cos(double);
double cosh(double);
double exp(double);
double fabs(double);
double floor(double);
double fmod(double, double);
double frexp(double, int *);
double ldexp(double, int);
double log(double);
double log10(double);
double modf(double, double *);
double pow(double, double);
double sin(double);
double sinh(double);
double sqrt(double);
double tan(double);
double tanh(double);
double erf(double);
double erfc(double);
double gamma(double);
double hypot(double, double);
double j0(double);
double j1(double);
double jn(int, double);
double lgamma(double);
double y0(double);
double y1(double);
double yn(int, double);
int    isnan(double);
double acosh(double);
double asinh(double);
double atanh(double);
double cbrt(double);
double expm1(double);
int    ilogb(double);
double log1p(double);
double logb(double);
double nextafter(double, double);
double remainder(double, double);
double rint(double);
double scalb(double, double);


void  clearerr(FILE *);
char *ctermid(char *);
char *cuserid(char *); // LEGACY
int   fclose(FILE *);
FILE *fdopen(int, const char *);
int feof(FILE *);
int ferror(FILE *);
int fflush(FILE *);
int fgetc(FILE *);
int fgetpos(FILE *, fpos_t *);
char *fgets(char *, int, FILE *);
int fileno(FILE *);
void  flockfile(FILE *);
FILE  *fopen(const char *, const char *);
int fprintf(FILE *, const char *, ...);
int fputc(int, FILE *);
int fputs(const char *, FILE *);
size_t   fread(void *, size_t, size_t, FILE *);
FILE *freopen(const char *, const char *, FILE *);
int fscanf(FILE *, const char *, ...);
int fseek(FILE *, long int, int);
int fseeko(FILE *, off_t, int);
int fsetpos(FILE *, const fpos_t *);
long int ftell(FILE *);
off_t ftello(FILE *);
int ftrylockfile(FILE *);
void  funlockfile(FILE *);
size_t   fwrite(const void *, size_t, size_t, FILE *);
int getc(FILE *);
int getchar(void);
int getunlocked(FILE *);
int getchar_unlocked(void);
int getopt(int, char * const[], const char*);  // LEGACY
char *gets(char *);
int getw(FILE *);
int pclose(FILE *);
void  perror(const char *);
FILE *popen(const char *, const char *);
int printf(const char *, ...);
int putc(int, FILE *);
int putchar(int);
int putunlocked(int, FILE *);
int putchar_unlocked(int);
int puts(const char *);
int putw(int, FILE *);
int remove(const char *);
int rename(const char *, const char *);
void  rewind(FILE *);
int scanf(const char *, ...);
void  setbuf(FILE *, char *);
int setvbuf(FILE *, char *, int, size_t);
int snprintf(char *, size_t, const char *, ...);
int sprintf(char *, const char *, ...);
int sscanf(const char *, const char *, ...);
char *tempnam(const char *, const char *);
FILE *tmpfile(void);
char *tmpnam(char *);
int ungetc(int, FILE *);
int vfprintf(FILE *, const char *, va_list);
int vprintf(const char *, va_list);
int vsnprintf(char *, size_t, const char *, va_list);
int vsprintf(char *, const char *, va_list);


void    *memccpy(void *, const void *, int, size_t);
void    *memchr(const void *, int, size_t);
int      memcmp(const void *, const void *, size_t);
void    *memcpy(void *, const void *, size_t);
void    *memmove(void *, const void *, size_t);
void    *memset(void *, int, size_t);
char    *strcat(char *, const char *);
char    *strchr(const char *, int);
int      strcmp(const char *, const char *);
int      strcoll(const char *, const char *);
char    *strcpy(char *, const char *);
size_t   strcspn(const char *, const char *);
char    *strdup(const char *);
char    *strerror(int);
size_t   strlen(const char *);
char    *strncat(char *, const char *, size_t);
int      strncmp(const char *, const char *, size_t);
char    *strncpy(char *, const char *, size_t);
char    *strpbrk(const char *, const char *);
char    *strrchr(const char *, int);
size_t   strspn(const char *, const char *);
char    *strstr(const char *, const char *);
char    *strtok(char *, const char *);
char    *strtok_r(char *, const char *, char **);
size_t   strxfrm(char *, const char *, size_t);
char*	 strndup(const char *s, size_t n);

int    bcmp(const void *, const void *, size_t);
void   bcopy(const void *, void *, size_t);
void   bzero(void *, size_t);
int    ffs(int);
char   *index(const char *, int);
char   *rindex(const char *, int);
int    strcasecmp(const char *, const char *);
int    strncasecmp(const char *, const char *, size_t);



#ifdef __cplusplus
}
#endif



#endif



