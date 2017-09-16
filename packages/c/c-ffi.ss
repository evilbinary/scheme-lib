;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-09-16 14:55:09.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (c c-ffi ) 
  (export c-clearerr
  c-ctermid
  c-cuserid
  c-fclose
  c-fdopen
  c-feof
  c-ferror
  c-fflush
  c-fgetc
  c-fgetpos
  c-fgets
  c-fileno
  c-flockfile
  c-fopen
  c-fprintf
  c-fputc
  c-fputs
  c-fread
  c-freopen
  c-fscanf
  c-fseek
  c-fseeko
  c-fsetpos
  c-ftell
  c-ftello
  c-ftrylockfile
  c-funlockfile
  c-fwrite
  c-getc
  c-getchar
  c-getc-unlocked
  c-getchar-unlocked
  c-getopt
  c-gets
  c-getw
  c-pclose
  c-perror
  c-popen
  c-printf
  c-putc
  c-putchar
  c-putc-unlocked
  c-putchar-unlocked
  c-puts
  c-putw
  c-remove
  c-rename
  c-rewind
  c-scanf
  c-setbuf
  c-setvbuf
  c-snprintf
  c-sprintf
  c-sscanf
  c-tempnam
  c-tmpfile
  c-tmpnam
  c-ungetc
  c-vfprintf
  c-vprintf
  c-vsnprintf
  c-vsprintf
  c-a64l
  c-abort
  c-abs
  c-atexit
  c-atof
  c-atoi
  c-atol
  c-bsearch
  c-calloc
  c-div
  c-drand48
  c-ecvt
  c-erand48
  c-exit
  c-fcvt
  c-free
  c-gcvt
  c-getenv
  c-getsubopt
  c-grantpt
  c-initstate
  c-jrand48
  c-l64a
  c-labs
  c-lcong48
  c-ldiv
  c-lrand48
  c-malloc
  c-mblen
  c-mbstowcs
  c-mbtowc
  c-mktemp
  c-mkstemp
  c-mrand48
  c-nrand48
  c-ptsname
  c-putenv
  c-qsort
  c-rand
  c-rand-r
  c-random
  c-realloc
  c-realpath
  c-seed48
  c-setkey
  c-setstate
  c-srand
  c-srand48
  c-srandom
  c-strtod
  c-strtol
  c-strtoul
  c-system
  c-unlockpt
  c-wcstombs
  c-wctomb
  c-memccpy
  c-memchr
  c-memcmp
  c-memcpy
  c-memmove
  c-memset
  c-strcat
  c-strchr
  c-strcmp
  c-strcoll
  c-strcpy
  c-strcspn
  c-strerror
  c-strlen
  c-strncat
  c-strncmp
  c-strncpy
  c-strpbrk
  c-strrchr
  c-strspn
  c-strstr
  c-strtok
  c-strtok-r
  c-strxfrm
  c-strndup
  c-bcmp
  c-bcopy
  c-bzero
  c-ffs
  c-index
  c-rindex
  c-strcasecmp
  c-strncasecmp
  c-acos
  c-asin
  c-atan
  c-atan2
  c-ceil
  c-cos
  c-cosh
  c-exp
  c-fabs
  c-floor
  c-fmod
  c-frexp
  c-ldexp
  c-log
  c-log10
  c-modf
  c-pow
  c-sin
  c-sinh
  c-sqrt
  c-tan
  c-tanh
  c-erf
  c-erfc
  c-gamma
  c-hypot
  c-j0
  c-j1
  c-jn
  c-lgamma
  c-y0
  c-y1
  c-yn
  c-isnan
  c-acosh
  c-asinh
  c-atanh
  c-cbrt
  c-expm1
  c-ilogb
  c-log1p
  c-logb
  c-nextafter
  c-remainder
  c-rint
  c-scalb
  c-asctime
  c-asctime-r
  c-clock
  c-clock-getres
  c-clock-gettime
  c-clock-settime
  c-ctime
  c-ctime-r
  c-difftime
  c-getdate
  c-gmtime
  c-gmtime-r
  c-localtime
  c-localtime-r
  c-mktime
  c-nanosleep
  c-strftime
  c-strptime
  c-time
  c-timer-delete
  c-timer-gettime
  c-timer-getoverrun
  c-timer-settime
  c-tzset)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libscm.so")
   ((a6nt i3nt) "libscm.dll")
   ((a6osx i3osx)  "libscm.so")
   ((a6le i3le) "libscm.so")))
 (define lib (load-librarys  lib-name ))

;;void clearerr(FILE* )
(def-function c-clearerr
             "clearerr" (void*) void)

;;char* ctermid(char* )
(def-function c-ctermid
             "ctermid" (string) string)

;;char* cuserid(char* )
(def-function c-cuserid
             "cuserid" (string) string)

;;int fclose(FILE* )
(def-function c-fclose
             "fclose" (void*) int)

;;FILE* fdopen(int  ,char* )
(def-function c-fdopen
             "fdopen" (int string) void*)

;;int feof(FILE* )
(def-function c-feof
             "feof" (void*) int)

;;int ferror(FILE* )
(def-function c-ferror
             "ferror" (void*) int)

;;int fflush(FILE* )
(def-function c-fflush
             "fflush" (void*) int)

;;int fgetc(FILE* )
(def-function c-fgetc
             "fgetc" (void*) int)

;;int fgetpos(FILE*  ,fpos_t* )
(def-function c-fgetpos
             "fgetpos" (void* void*) int)

;;char* fgets(char*  ,int  ,FILE* )
(def-function c-fgets
             "fgets" (string int void*) string)

;;int fileno(FILE* )
(def-function c-fileno
             "fileno" (void*) int)

;;void flockfile(FILE* )
(def-function c-flockfile
             "flockfile" (void*) void)

;;FILE* fopen(char*  ,char* )
(def-function c-fopen
             "fopen" (string string) void*)

;;int fprintf(FILE*  ,char* )
(def-function c-fprintf
             "fprintf" (void* string) int)

;;int fputc(int  ,FILE* )
(def-function c-fputc
             "fputc" (int void*) int)

;;int fputs(char*  ,FILE* )
(def-function c-fputs
             "fputs" (string void*) int)

;;size_t fread(void*  ,size_t  ,size_t  ,FILE* )
(def-function c-fread
             "fread" (void* int int void*) int)

;;FILE* freopen(char*  ,char*  ,FILE* )
(def-function c-freopen
             "freopen" (string string void*) void*)

;;int fscanf(FILE*  ,char* )
(def-function c-fscanf
             "fscanf" (void* string) int)

;;int fseek(FILE*  ,long int  ,int )
(def-function c-fseek
             "fseek" (void* long int int) int)

;;int fseeko(FILE*  ,off_t  ,int )
(def-function c-fseeko
             "fseeko" (void* off_t int) int)

;;int fsetpos(FILE*  ,fpos_t* )
(def-function c-fsetpos
             "fsetpos" (void* void*) int)

;;long ftell(FILE* )
(def-function c-ftell
             "ftell" (void*) long)

;;off_t ftello(FILE* )
(def-function c-ftello
             "ftello" (void*) off_t)

;;int ftrylockfile(FILE* )
(def-function c-ftrylockfile
             "ftrylockfile" (void*) int)

;;void funlockfile(FILE* )
(def-function c-funlockfile
             "funlockfile" (void*) void)

;;size_t fwrite(void*  ,size_t  ,size_t  ,FILE* )
(def-function c-fwrite
             "fwrite" (void* int int void*) int)

;;int getc(FILE* )
(def-function c-getc
             "getc" (void*) int)

;;int getchar(void )
(def-function c-getchar
             "getchar" (void) int)

;;int getc_unlocked(FILE* )
(def-function c-getc-unlocked
             "getc_unlocked" (void*) int)

;;int getchar_unlocked(void )
(def-function c-getchar-unlocked
             "getchar_unlocked" (void) int)

;;int getopt(int  ,char* )
(def-function c-getopt
             "getopt" (int string) int)

;;char* gets(char* )
(def-function c-gets
             "gets" (string) string)

;;int getw(FILE* )
(def-function c-getw
             "getw" (void*) int)

;;int pclose(FILE* )
(def-function c-pclose
             "pclose" (void*) int)

;;void perror(char* )
(def-function c-perror
             "perror" (string) void)

;;FILE* popen(char*  ,char* )
(def-function c-popen
             "popen" (string string) void*)

;;int printf(char* )
(def-function c-printf
             "printf" (string) int)

;;int putc(int  ,FILE* )
(def-function c-putc
             "putc" (int void*) int)

;;int putchar(int )
(def-function c-putchar
             "putchar" (int) int)

;;int putc_unlocked(int  ,FILE* )
(def-function c-putc-unlocked
             "putc_unlocked" (int void*) int)

;;int putchar_unlocked(int )
(def-function c-putchar-unlocked
             "putchar_unlocked" (int) int)

;;int puts(char* )
(def-function c-puts
             "puts" (string) int)

;;int putw(int  ,FILE* )
(def-function c-putw
             "putw" (int void*) int)

;;int remove(char* )
(def-function c-remove
             "remove" (string) int)

;;int rename(char*  ,char* )
(def-function c-rename
             "rename" (string string) int)

;;void rewind(FILE* )
(def-function c-rewind
             "rewind" (void*) void)

;;int scanf(char* )
(def-function c-scanf
             "scanf" (string) int)

;;void setbuf(FILE*  ,char* )
(def-function c-setbuf
             "setbuf" (void* string) void)

;;int setvbuf(FILE*  ,char*  ,int  ,size_t )
(def-function c-setvbuf
             "setvbuf" (void* string int int) int)

;;int snprintf(char*  ,size_t  ,char* )
(def-function c-snprintf
             "snprintf" (string int string) int)

;;int sprintf(char*  ,char* )
(def-function c-sprintf
             "sprintf" (string string) int)

;;int sscanf(char*  ,char* )
(def-function c-sscanf
             "sscanf" (string string) int)

;;char* tempnam(char*  ,char* )
(def-function c-tempnam
             "tempnam" (string string) string)

;;FILE* tmpfile(void )
(def-function c-tmpfile
             "tmpfile" (void) void*)

;;char* tmpnam(char* )
(def-function c-tmpnam
             "tmpnam" (string) string)

;;int ungetc(int  ,FILE* )
(def-function c-ungetc
             "ungetc" (int void*) int)

;;int vfprintf(FILE*  ,char*  ,va_list )
(def-function c-vfprintf
             "vfprintf" (void* string va_list) int)

;;int vprintf(char*  ,va_list )
(def-function c-vprintf
             "vprintf" (string va_list) int)

;;int vsnprintf(char*  ,size_t  ,char*  ,va_list )
(def-function c-vsnprintf
             "vsnprintf" (string int string va_list) int)

;;int vsprintf(char*  ,char*  ,va_list )
(def-function c-vsprintf
             "vsprintf" (string string va_list) int)

;;long a64l(char* )
(def-function c-a64l
             "a64l" (string) long)

;;void abort(void )
(def-function c-abort
             "abort" (void) void)

;;int abs(int )
(def-function c-abs
             "abs" (int) int)

;;int atexit()
(def-function c-atexit
             "atexit" () int)

;;double atof(char* )
(def-function c-atof
             "atof" (string) double)

;;int atoi(char* )
(def-function c-atoi
             "atoi" (string) int)

;;long atol(char* )
(def-function c-atol
             "atol" (string) long)

;;void* bsearch(void*  ,void*  ,size_t  ,size_t )
(def-function c-bsearch
             "bsearch" (void* void* int int) void*)

;;void* calloc(size_t  ,size_t )
(def-function c-calloc
             "calloc" (int int) void*)

;;div_t div(int  ,int )
(def-function c-div
             "div" (int int) div_t)

;;double drand48(void )
(def-function c-drand48
             "drand48" (void) double)

;;char* ecvt(double  ,int  ,int*  ,int* )
(def-function c-ecvt
             "ecvt" (double int void* void*) string)

;;double erand48(unsigned )
(def-function c-erand48
             "erand48" (int) double)

;;void exit(int )
(def-function c-exit
             "exit" (int) void)

;;char* fcvt(double  ,int  ,int*  ,int* )
(def-function c-fcvt
             "fcvt" (double int void* void*) string)

;;void free(void* )
(def-function c-free
             "free" (void*) void)

;;char* gcvt(double  ,int  ,char* )
(def-function c-gcvt
             "gcvt" (double int string) string)

;;char* getenv(char* )
(def-function c-getenv
             "getenv" (string) string)

;;int getsubopt(char  ,char  ,char )
(def-function c-getsubopt
             "getsubopt" (char char char) int)

;;int grantpt(int )
(def-function c-grantpt
             "grantpt" (int) int)

;;char* initstate(unsigned int  ,char*  ,size_t )
(def-function c-initstate
             "initstate" (int string int) string)

;;long jrand48(unsigned )
(def-function c-jrand48
             "jrand48" (int) long)

;;char* l64a(long )
(def-function c-l64a
             "l64a" (long) string)

;;long labs(long int )
(def-function c-labs
             "labs" (long int) long)

;;void lcong48(unsigned )
(def-function c-lcong48
             "lcong48" (int) void)

;;ldiv_t ldiv(long int  ,long int )
(def-function c-ldiv
             "ldiv" (long int long int) ldiv_t)

;;long lrand48(void )
(def-function c-lrand48
             "lrand48" (void) long)

;;void* malloc(size_t )
(def-function c-malloc
             "malloc" (int) void*)

;;int mblen(char*  ,size_t )
(def-function c-mblen
             "mblen" (string int) int)

;;size_t mbstowcs(wchar_t*  ,char*  ,size_t )
(def-function c-mbstowcs
             "mbstowcs" (string string int) int)

;;int mbtowc(wchar_t*  ,char*  ,size_t )
(def-function c-mbtowc
             "mbtowc" (string string int) int)

;;char* mktemp(char* )
(def-function c-mktemp
             "mktemp" (string) string)

;;int mkstemp(char* )
(def-function c-mkstemp
             "mkstemp" (string) int)

;;long mrand48(void )
(def-function c-mrand48
             "mrand48" (void) long)

;;long nrand48(unsigned )
(def-function c-nrand48
             "nrand48" (int) long)

;;char* ptsname(int )
(def-function c-ptsname
             "ptsname" (int) string)

;;int putenv(char* )
(def-function c-putenv
             "putenv" (string) int)

;;void qsort(void*  ,size_t  ,size_t )
(def-function c-qsort
             "qsort" (void* int int) void)

;;int rand(void )
(def-function c-rand
             "rand" (void) int)

;;int rand_r(unsigned* )
(def-function c-rand-r
             "rand_r" (void*) int)

;;long random(void )
(def-function c-random
             "random" (void) long)

;;void* realloc(void*  ,size_t )
(def-function c-realloc
             "realloc" (void* int) void*)

;;char* realpath(char*  ,char* )
(def-function c-realpath
             "realpath" (string string) string)

;;unsigned seed48(unsigned )
(def-function c-seed48
             "seed48" (int) int)

;;void setkey(char* )
(def-function c-setkey
             "setkey" (string) void)

;;char* setstate(char* )
(def-function c-setstate
             "setstate" (string) string)

;;void srand(unsigned int )
(def-function c-srand
             "srand" (int) void)

;;void srand48(long int )
(def-function c-srand48
             "srand48" (long int) void)

;;void srandom(unsigned )
(def-function c-srandom
             "srandom" (int) void)

;;double strtod(char*  ,char )
(def-function c-strtod
             "strtod" (string char) double)

;;long strtol(char*  ,char  ,int )
(def-function c-strtol
             "strtol" (string char int) long)

;;unsigned strtoul(char*  ,char  ,int )
(def-function c-strtoul
             "strtoul" (string char int) int)

;;int system(char* )
(def-function c-system
             "system" (string) int)

;;int unlockpt(int )
(def-function c-unlockpt
             "unlockpt" (int) int)

;;size_t wcstombs(char*  ,wchar_t*  ,size_t )
(def-function c-wcstombs
             "wcstombs" (string string int) int)

;;int wctomb(char*  ,wchar_t )
(def-function c-wctomb
             "wctomb" (string wchar_t) int)

;;void* memccpy(void*  ,void*  ,int  ,size_t )
(def-function c-memccpy
             "memccpy" (void* void* int int) void*)

;;void* memchr(void*  ,int  ,size_t )
(def-function c-memchr
             "memchr" (void* int int) void*)

;;int memcmp(void*  ,void*  ,size_t )
(def-function c-memcmp
             "memcmp" (void* void* int) int)

;;void* memcpy(void*  ,void*  ,size_t )
(def-function c-memcpy
             "memcpy" (void* void* int) void*)

;;void* memmove(void*  ,void*  ,size_t )
(def-function c-memmove
             "memmove" (void* void* int) void*)

;;void* memset(void*  ,int  ,size_t )
(def-function c-memset
             "memset" (void* int int) void*)

;;char* strcat(char*  ,char* )
(def-function c-strcat
             "strcat" (string string) string)

;;char* strchr(char*  ,int )
(def-function c-strchr
             "strchr" (string int) string)

;;int strcmp(char*  ,char* )
(def-function c-strcmp
             "strcmp" (string string) int)

;;int strcoll(char*  ,char* )
(def-function c-strcoll
             "strcoll" (string string) int)

;;char* strcpy(char*  ,char* )
(def-function c-strcpy
             "strcpy" (string string) string)

;;size_t strcspn(char*  ,char* )
(def-function c-strcspn
             "strcspn" (string string) int)

(def-function c-strerror
             "strerror" (int) string)

;;size_t strlen(char* )
(def-function c-strlen
             "strlen" (string) int)

;;char* strncat(char*  ,char*  ,size_t )
(def-function c-strncat
             "strncat" (string string int) string)

;;int strncmp(char*  ,char*  ,size_t )
(def-function c-strncmp
             "strncmp" (string string int) int)

;;char* strncpy(char*  ,char*  ,size_t )
(def-function c-strncpy
             "strncpy" (string string int) string)

;;char* strpbrk(char*  ,char* )
(def-function c-strpbrk
             "strpbrk" (string string) string)

;;char* strrchr(char*  ,int )
(def-function c-strrchr
             "strrchr" (string int) string)

;;size_t strspn(char*  ,char* )
(def-function c-strspn
             "strspn" (string string) int)

;;char* strstr(char*  ,char* )
(def-function c-strstr
             "strstr" (string string) string)

;;char* strtok(char*  ,char* )
(def-function c-strtok
             "strtok" (string string) string)

;;char* strtok_r(char*  ,char*  ,char )
(def-function c-strtok-r
             "strtok_r" (string string char) string)

;;size_t strxfrm(char*  ,char*  ,size_t )
(def-function c-strxfrm
             "strxfrm" (string string int) int)

;;char* strndup(char* s ,size_t n)
(def-function c-strndup
             "strndup" (string int) string)


;;int bcmp(void*  ,void*  ,size_t )
(def-function c-bcmp
             "bcmp" (void* void* int) int)

;;void bcopy(void*  ,void*  ,size_t )
(def-function c-bcopy
             "bcopy" (void* void* int) void)

;;void bzero(void*  ,size_t )
(def-function c-bzero
             "bzero" (void* int) void)

;;int ffs(int )
(def-function c-ffs
             "ffs" (int) int)

;;char* index(char*  ,int )
(def-function c-index
             "index" (string int) string)

;;char* rindex(char*  ,int )
(def-function c-rindex
             "rindex" (string int) string)

;;int strcasecmp(char*  ,char* )
(def-function c-strcasecmp
             "strcasecmp" (string string) int)

;;int strncasecmp(char*  ,char*  ,size_t )
(def-function c-strncasecmp
             "strncasecmp" (string string int) int)

;;double acos(double )
(def-function c-acos
             "acos" (double) double)

;;double asin(double )
(def-function c-asin
             "asin" (double) double)

;;double atan(double )
(def-function c-atan
             "atan" (double) double)

;;double atan2(double  ,double )
(def-function c-atan2
             "atan2" (double double) double)

;;double ceil(double )
(def-function c-ceil
             "ceil" (double) double)

;;double cos(double )
(def-function c-cos
             "cos" (double) double)

;;double cosh(double )
(def-function c-cosh
             "cosh" (double) double)

;;double exp(double )
(def-function c-exp
             "exp" (double) double)

;;double fabs(double )
(def-function c-fabs
             "fabs" (double) double)

;;double floor(double )
(def-function c-floor
             "floor" (double) double)

;;double fmod(double  ,double )
(def-function c-fmod
             "fmod" (double double) double)

;;double frexp(double  ,int* )
(def-function c-frexp
             "frexp" (double void*) double)

;;double ldexp(double  ,int )
(def-function c-ldexp
             "ldexp" (double int) double)

;;double log(double )
(def-function c-log
             "log" (double) double)

;;double log10(double )
(def-function c-log10
             "log10" (double) double)

;;double modf(double  ,double* )
(def-function c-modf
             "modf" (double void*) double)

;;double pow(double  ,double )
(def-function c-pow
             "pow" (double double) double)

;;double sin(double )
(def-function c-sin
             "sin" (double) double)

;;double sinh(double )
(def-function c-sinh
             "sinh" (double) double)

;;double sqrt(double )
(def-function c-sqrt
             "sqrt" (double) double)

;;double tan(double )
(def-function c-tan
             "tan" (double) double)

;;double tanh(double )
(def-function c-tanh
             "tanh" (double) double)

;;double erf(double )
(def-function c-erf
             "erf" (double) double)

;;double erfc(double )
(def-function c-erfc
             "erfc" (double) double)

;;double gamma(double )
(def-function c-gamma
             "gamma" (double) double)

;;double hypot(double  ,double )
(def-function c-hypot
             "hypot" (double double) double)

;;double j0(double )
(def-function c-j0
             "j0" (double) double)

;;double j1(double )
(def-function c-j1
             "j1" (double) double)

;;double jn(int  ,double )
(def-function c-jn
             "jn" (int double) double)

;;double lgamma(double )
(def-function c-lgamma
             "lgamma" (double) double)

;;double y0(double )
(def-function c-y0
             "y0" (double) double)

;;double y1(double )
(def-function c-y1
             "y1" (double) double)

;;double yn(int  ,double )
(def-function c-yn
             "yn" (int double) double)

;;int isnan(double )
(def-function c-isnan
             "isnan" (double) int)

;;double acosh(double )
(def-function c-acosh
             "acosh" (double) double)

;;double asinh(double )
(def-function c-asinh
             "asinh" (double) double)

;;double atanh(double )
(def-function c-atanh
             "atanh" (double) double)

;;double cbrt(double )
(def-function c-cbrt
             "cbrt" (double) double)

;;double expm1(double )
(def-function c-expm1
             "expm1" (double) double)

;;int ilogb(double )
(def-function c-ilogb
             "ilogb" (double) int)

;;double log1p(double )
(def-function c-log1p
             "log1p" (double) double)

;;double logb(double )
(def-function c-logb
             "logb" (double) double)

;;double nextafter(double  ,double )
(def-function c-nextafter
             "nextafter" (double double) double)

;;double remainder(double  ,double )
(def-function c-remainder
             "remainder" (double double) double)

;;double rint(double )
(def-function c-rint
             "rint" (double) double)

;;double scalb(double  ,double )
(def-function c-scalb
             "scalb" (double double) double)

;;char* asctime(struct tm* )
(def-function c-asctime
             "asctime" (void*) string)

;;char* asctime_r(struct tm*  ,char* )
(def-function c-asctime-r
             "asctime_r" (void* string) string)

;;clock_t clock(void )
(def-function c-clock
             "clock" (void) clock_t)

;;int clock_getres(clockid_t  ,struct timespec* )
(def-function c-clock-getres
             "clock_getres" (clockid_t void*) int)

;;int clock_gettime(clockid_t  ,struct timespec* )
(def-function c-clock-gettime
             "clock_gettime" (clockid_t void*) int)

;;int clock_settime(clockid_t  ,struct timespec* )
(def-function c-clock-settime
             "clock_settime" (clockid_t void*) int)

;;char* ctime(time_t* )
(def-function c-ctime
             "ctime" (void*) string)

;;char* ctime_r(time_t*  ,char* )
(def-function c-ctime-r
             "ctime_r" (void* string) string)

;;double difftime(time_t  ,time_t )
(def-function c-difftime
             "difftime" (time_t time_t) double)

;;tm* getdate(char* )
(def-function c-getdate
             "getdate" (string) void*)

;;tm* gmtime(time_t* )
(def-function c-gmtime
             "gmtime" (void*) void*)

;;tm* gmtime_r(time_t*  ,struct tm* )
(def-function c-gmtime-r
             "gmtime_r" (void* void*) void*)

;;tm* localtime(time_t* )
(def-function c-localtime
             "localtime" (void*) void*)

;;tm* localtime_r(time_t*  ,struct tm* )
(def-function c-localtime-r
             "localtime_r" (void* void*) void*)

;;time_t mktime(struct tm* )
(def-function c-mktime
             "mktime" (void*) time_t)

;;int nanosleep(struct timespec*  ,struct timespec* )
(def-function c-nanosleep
             "nanosleep" (void* void*) int)

;;size_t strftime(char*  ,size_t  ,char*  ,struct tm* )
(def-function c-strftime
             "strftime" (string int string void*) int)

;;char* strptime(char*  ,char*  ,struct tm* )
(def-function c-strptime
             "strptime" (string string void*) string)

;;time_t time(time_t* )
(def-function c-time
             "time" (void*) time_t)

;;int timer_delete(timer_t )
(def-function c-timer-delete
             "timer_delete" (timer_t) int)

;;int timer_gettime(timer_t  ,struct itimerspec* )
(def-function c-timer-gettime
             "timer_gettime" (timer_t void*) int)

;;int timer_getoverrun(timer_t )
(def-function c-timer-getoverrun
             "timer_getoverrun" (timer_t) int)

;;int timer_settime(timer_t  ,int  ,struct itimerspec*  ,struct itimerspec* )
(def-function c-timer-settime
             "timer_settime" (timer_t int void* void*) int)

;;void tzset(void )
(def-function c-tzset
             "tzset" (void) void)


)
