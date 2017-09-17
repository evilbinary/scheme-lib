;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-09-17 15:15:33.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (c c-ffi ) 
  (export c-a64l
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
  c-seed
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
  c-clearerr
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
  c-strdup
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
  c-strncasecmp)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libc.so")
   ((a6nt i3nt) "libc.dll")
   ((a6osx i3osx)  "libc.so")
   ((a6le i3le) "libc.so")))
 (define lib (load-librarys  lib-name ))

;;long c_a64l(char* )
(def-function c-a64l
             "c_a64l" (string) long)

;;void c_abort(void )
(def-function c-abort
             "c_abort" (void) void)

;;int c_abs(int )
(def-function c-abs
             "c_abs" (int) int)

;;int c_atexit()
(def-function c-atexit
             "c_atexit" () int)

;;double c_atof(char* )
(def-function c-atof
             "c_atof" (string) double)

;;int c_atoi(char* )
(def-function c-atoi
             "c_atoi" (string) int)

;;long c_atol(char* )
(def-function c-atol
             "c_atol" (string) long)

;;void* c_bsearch(void*  ,void*  ,size_t  ,size_t )
(def-function c-bsearch
             "c_bsearch" (void* void* int int) void*)

;;void* c_calloc(size_t  ,size_t )
(def-function c-calloc
             "c_calloc" (int int) void*)

;;div_t c_div(int  ,int )
(def-function c-div
             "c_div" (int int) div_t)

;;double c_drand48(void )
(def-function c-drand48
             "c_drand48" (void) double)

;;char* c_ecvt(double  ,int  ,int*  ,int* )
(def-function c-ecvt
             "c_ecvt" (double int void* void*) string)

;;double c_erand48(unsigned )
(def-function c-erand48
             "c_erand48" (int) double)

;;void c_exit(int )
(def-function c-exit
             "c_exit" (int) void)

;;char* c_fcvt(double  ,int  ,int*  ,int* )
(def-function c-fcvt
             "c_fcvt" (double int void* void*) string)

;;void c_free(void* )
(def-function c-free
             "c_free" (void*) void)

;;char* c_gcvt(double  ,int  ,char* )
(def-function c-gcvt
             "c_gcvt" (double int string) string)

;;char* c_getenv(char* )
(def-function c-getenv
             "c_getenv" (string) string)

;;int c_getsubopt(char  ,char  ,char )
(def-function c-getsubopt
             "c_getsubopt" (char char char) int)

;;int c_grantpt(int )
(def-function c-grantpt
             "c_grantpt" (int) int)

;;char* c_initstate(unsigned int  ,char*  ,size_t )
(def-function c-initstate
             "c_initstate" (int string int) string)

;;char* c_l64a(long )
(def-function c-l64a
             "c_l64a" (long) string)

;;long c_labs(long int )
(def-function c-labs
             "c_labs" (long int) long)

;;void c_lcong48(unsigned )
(def-function c-lcong48
             "c_lcong48" (int) void)

;;ldiv_t c_ldiv(long int  ,long int )
(def-function c-ldiv
             "c_ldiv" (long int long int) ldiv_t)

;;long c_lrand48(void )
(def-function c-lrand48
             "c_lrand48" (void) long)

;;void* c_malloc(size_t )
(def-function c-malloc
             "c_malloc" (int) void*)

;;int c_mblen(char*  ,size_t )
(def-function c-mblen
             "c_mblen" (string int) int)

;;size_t c_mbstowcs(wchar_t*  ,char*  ,size_t )
(def-function c-mbstowcs
             "c_mbstowcs" (string string int) int)

;;int c_mbtowc(wchar_t*  ,char*  ,size_t )
(def-function c-mbtowc
             "c_mbtowc" (string string int) int)

;;char* c_mktemp(char* )
(def-function c-mktemp
             "c_mktemp" (string) string)

;;int c_mkstemp(char* )
(def-function c-mkstemp
             "c_mkstemp" (string) int)

;;long c_mrand48(void )
(def-function c-mrand48
             "c_mrand48" (void) long)

;;long c_nrand48(unsigned )
(def-function c-nrand48
             "c_nrand48" (int) long)

;;char* c_ptsname(int )
(def-function c-ptsname
             "c_ptsname" (int) string)

;;int c_putenv(char* )
(def-function c-putenv
             "c_putenv" (string) int)

;;void c_qsort(void*  ,size_t  ,size_t )
(def-function c-qsort
             "c_qsort" (void* int int) void)

;;int c_rand(void )
(def-function c-rand
             "c_rand" (void) int)

;;int c_rand_r(unsigned* )
(def-function c-rand-r
             "c_rand_r" (void*) int)

;;long c_random(void )
(def-function c-random
             "c_random" (void) long)

;;void* c_realloc(void*  ,size_t )
(def-function c-realloc
             "c_realloc" (void* int) void*)

;;char* c_realpath(char*  ,char* )
(def-function c-realpath
             "c_realpath" (string string) string)

;;unsigned c_seed(unsigned )
(def-function c-seed
             "c_seed" (int) int)

;;void c_setkey(char* )
(def-function c-setkey
             "c_setkey" (string) void)

;;char* c_setstate(char* )
(def-function c-setstate
             "c_setstate" (string) string)

;;void c_srand(unsigned int )
(def-function c-srand
             "c_srand" (int) void)

;;void c_srand48(long int )
(def-function c-srand48
             "c_srand48" (long int) void)

;;void c_srandom(unsigned )
(def-function c-srandom
             "c_srandom" (int) void)

;;double c_strtod(char*  ,char )
(def-function c-strtod
             "c_strtod" (string char) double)

;;long c_strtol(char*  ,char  ,int )
(def-function c-strtol
             "c_strtol" (string char int) long)

;;unsigned c_strtoul(char*  ,char  ,int )
(def-function c-strtoul
             "c_strtoul" (string char int) int)

;;int c_system(char* )
(def-function c-system
             "c_system" (string) int)

;;int c_unlockpt(int )
(def-function c-unlockpt
             "c_unlockpt" (int) int)

;;size_t c_wcstombs(char*  ,wchar_t*  ,size_t )
(def-function c-wcstombs
             "c_wcstombs" (string string int) int)

;;int c_wctomb(char*  ,wchar_t )
(def-function c-wctomb
             "c_wctomb" (string wchar_t) int)

;;double c_acos(double )
(def-function c-acos
             "c_acos" (double) double)

;;double c_asin(double )
(def-function c-asin
             "c_asin" (double) double)

;;double c_atan(double )
(def-function c-atan
             "c_atan" (double) double)

;;double c_atan2(double  ,double )
(def-function c-atan2
             "c_atan2" (double double) double)

;;double c_ceil(double )
(def-function c-ceil
             "c_ceil" (double) double)

;;double c_cos(double )
(def-function c-cos
             "c_cos" (double) double)

;;double c_cosh(double )
(def-function c-cosh
             "c_cosh" (double) double)

;;double c_exp(double )
(def-function c-exp
             "c_exp" (double) double)

;;double c_fabs(double )
(def-function c-fabs
             "c_fabs" (double) double)

;;double c_floor(double )
(def-function c-floor
             "c_floor" (double) double)

;;double c_fmod(double  ,double )
(def-function c-fmod
             "c_fmod" (double double) double)

;;double c_frexp(double  ,int* )
(def-function c-frexp
             "c_frexp" (double void*) double)

;;double c_ldexp(double  ,int )
(def-function c-ldexp
             "c_ldexp" (double int) double)

;;double c_log(double )
(def-function c-log
             "c_log" (double) double)

;;double c_log10(double )
(def-function c-log10
             "c_log10" (double) double)

;;double c_modf(double  ,double* )
(def-function c-modf
             "c_modf" (double void*) double)

;;double c_pow(double  ,double )
(def-function c-pow
             "c_pow" (double double) double)

;;double c_sin(double )
(def-function c-sin
             "c_sin" (double) double)

;;double c_sinh(double )
(def-function c-sinh
             "c_sinh" (double) double)

;;double c_sqrt(double )
(def-function c-sqrt
             "c_sqrt" (double) double)

;;double c_tan(double )
(def-function c-tan
             "c_tan" (double) double)

;;double c_tanh(double )
(def-function c-tanh
             "c_tanh" (double) double)

;;double c_erf(double )
(def-function c-erf
             "c_erf" (double) double)

;;double c_erfc(double )
(def-function c-erfc
             "c_erfc" (double) double)

;;double c_gamma(double )
(def-function c-gamma
             "c_gamma" (double) double)

;;double c_hypot(double  ,double )
(def-function c-hypot
             "c_hypot" (double double) double)

;;double c_j0(double )
(def-function c-j0
             "c_j0" (double) double)

;;double c_j1(double )
(def-function c-j1
             "c_j1" (double) double)

;;double c_jn(int  ,double )
(def-function c-jn
             "c_jn" (int double) double)

;;double c_lgamma(double )
(def-function c-lgamma
             "c_lgamma" (double) double)

;;double c_y0(double )
(def-function c-y0
             "c_y0" (double) double)

;;double c_y1(double )
(def-function c-y1
             "c_y1" (double) double)

;;double c_yn(int  ,double )
(def-function c-yn
             "c_yn" (int double) double)

;;int c_isnan(double )
(def-function c-isnan
             "c_isnan" (double) int)

;;double c_acosh(double )
(def-function c-acosh
             "c_acosh" (double) double)

;;double c_asinh(double )
(def-function c-asinh
             "c_asinh" (double) double)

;;double c_atanh(double )
(def-function c-atanh
             "c_atanh" (double) double)

;;double c_cbrt(double )
(def-function c-cbrt
             "c_cbrt" (double) double)

;;double c_expm1(double )
(def-function c-expm1
             "c_expm1" (double) double)

;;int c_ilogb(double )
(def-function c-ilogb
             "c_ilogb" (double) int)

;;double c_log1p(double )
(def-function c-log1p
             "c_log1p" (double) double)

;;double c_logb(double )
(def-function c-logb
             "c_logb" (double) double)

;;double c_nextafter(double  ,double )
(def-function c-nextafter
             "c_nextafter" (double double) double)

;;double c_remainder(double  ,double )
(def-function c-remainder
             "c_remainder" (double double) double)

;;double c_rint(double )
(def-function c-rint
             "c_rint" (double) double)

;;double c_scalb(double  ,double )
(def-function c-scalb
             "c_scalb" (double double) double)

;;void c_clearerr(FILE* )
(def-function c-clearerr
             "c_clearerr" (void*) void)

;;char* c_ctermid(char* )
(def-function c-ctermid
             "c_ctermid" (string) string)

;;char* c_cuserid(char* )
(def-function c-cuserid
             "c_cuserid" (string) string)

;;int c_fclose(FILE* )
(def-function c-fclose
             "c_fclose" (void*) int)

;;FILE* c_fdopen(int  ,char* )
(def-function c-fdopen
             "c_fdopen" (int string) void*)

;;int c_feof(FILE* )
(def-function c-feof
             "c_feof" (void*) int)

;;int c_ferror(FILE* )
(def-function c-ferror
             "c_ferror" (void*) int)

;;int c_fflush(FILE* )
(def-function c-fflush
             "c_fflush" (void*) int)

;;int c_fgetc(FILE* )
(def-function c-fgetc
             "c_fgetc" (void*) int)

;;int c_fgetpos(FILE*  ,fpos_t* )
(def-function c-fgetpos
             "c_fgetpos" (void* void*) int)

;;char* c_fgets(char*  ,int  ,FILE* )
(def-function c-fgets
             "c_fgets" (string int void*) string)

;;int c_fileno(FILE* )
(def-function c-fileno
             "c_fileno" (void*) int)

;;void c_flockfile(FILE* )
(def-function c-flockfile
             "c_flockfile" (void*) void)

;;FILE* c_fopen(char*  ,char* )
(def-function c-fopen
             "c_fopen" (string string) void*)

;;int c_fprintf(FILE*  ,char* )
(def-function c-fprintf
             "c_fprintf" (void* string) int)

;;int c_fputc(int  ,FILE* )
(def-function c-fputc
             "c_fputc" (int void*) int)

;;int c_fputs(char*  ,FILE* )
(def-function c-fputs
             "c_fputs" (string void*) int)

;;size_t fread(void*  ,size_t  ,size_t  ,FILE* )
(def-function c-fread
             "c_fread" (void* int int void*) int)

;;FILE* c_freopen(char*  ,char*  ,FILE* )
(def-function c-freopen
             "c_freopen" (string string void*) void*)

;;int c_fscanf(FILE*  ,char* )
(def-function c-fscanf
             "c_fscanf" (void* string) int)

;;int c_fseek(FILE*  ,long int  ,int )
(def-function c-fseek
             "c_fseek" (void* int int) int)

;;int c_fseeko(FILE*  ,off_t  ,int )
(def-function c-fseeko
             "c_fseeko" (void* off_t int) int)

;;int c_fsetpos(FILE*  ,fpos_t* )
(def-function c-fsetpos
             "c_fsetpos" (void* void*) int)

;;long c_ftell(FILE* )
(def-function c-ftell
             "c_ftell" (void*) int)

;;off_t c_ftello(FILE* )
(def-function c-ftello
             "c_ftello" (void*) off_t)

;;int c_ftrylockfile(FILE* )
(def-function c-ftrylockfile
             "c_ftrylockfile" (void*) int)

;;void c_funlockfile(FILE* )
(def-function c-funlockfile
             "c_funlockfile" (void*) void)

;;size_t c_fwrite(void*  ,size_t  ,size_t  ,FILE* )
(def-function c-fwrite
             "c_fwrite" (void* int int void*) int)

;;int c_getc(FILE* )
(def-function c-getc
             "c_getc" (void*) int)

;;int c_getchar(void )
(def-function c-getchar
             "c_getchar" (void) int)

;;int c_getc_unlocked(FILE* )
(def-function c-getc-unlocked
             "c_getc_unlocked" (void*) int)

;;int c_getchar_unlocked(void )
(def-function c-getchar-unlocked
             "c_getchar_unlocked" (void) int)

;;int c_getopt(int  ,char  ,char* )
(def-function c-getopt
             "c_getopt" (int char string) int)

;;char* c_gets(char* )
(def-function c-gets
             "c_gets" (string) string)

;;int c_getw(FILE* )
(def-function c-getw
             "c_getw" (void*) int)

;;int c_pclose(FILE* )
(def-function c-pclose
             "c_pclose" (void*) int)

;;void c_perror(char* )
(def-function c-perror
             "c_perror" (string) void)

;;FILE* c_popen(char*  ,char* )
(def-function c-popen
             "c_popen" (string string) void*)

;;int c_printf(char* )
(def-function c-printf
             "c_printf" (string) int)

;;int c_putc(int  ,FILE* )
(def-function c-putc
             "c_putc" (int void*) int)

;;int c_putchar(int )
(def-function c-putchar
             "c_putchar" (int) int)

;;int c_putc_unlocked(int  ,FILE* )
(def-function c-putc-unlocked
             "c_putc_unlocked" (int void*) int)

;;int c_putchar_unlocked(int )
(def-function c-putchar-unlocked
             "c_putchar_unlocked" (int) int)

;;int c_puts(char* )
(def-function c-puts
             "c_puts" (string) int)

;;int c_putw(int  ,FILE* )
(def-function c-putw
             "c_putw" (int void*) int)

;;int c_remove(char* )
(def-function c-remove
             "c_remove" (string) int)

;;int c_rename(char*  ,char* )
(def-function c-rename
             "c_rename" (string string) int)

;;void c_rewind(FILE* )
(def-function c-rewind
             "c_rewind" (void*) void)

;;int c_scanf(char* )
(def-function c-scanf
             "c_scanf" (string) int)

;;void c_setbuf(FILE*  ,char* )
(def-function c-setbuf
             "c_setbuf" (void* string) void)

;;int c_setvbuf(FILE*  ,char*  ,int  ,size_t )
(def-function c-setvbuf
             "c_setvbuf" (void* string int int) int)

;;int c_snprintf(char*  ,size_t  ,char* )
(def-function c-snprintf
             "c_snprintf" (string int string) int)

;;int c_sprintf(char*  ,char* )
(def-function c-sprintf
             "c_sprintf" (string string) int)

;;int c_sscanf(char*  ,char* )
(def-function c-sscanf
             "c_sscanf" (string string) int)

;;char* c_tempnam(char*  ,char* )
(def-function c-tempnam
             "c_tempnam" (string string) string)

;;FILE* c_tmpfile(void )
(def-function c-tmpfile
             "c_tmpfile" (void) void*)

;;char* c_tmpnam(char* )
(def-function c-tmpnam
             "c_tmpnam" (string) string)

;;int c_ungetc(int  ,FILE* )
(def-function c-ungetc
             "c_ungetc" (int void*) int)

;;int c_vfprintf(FILE*  ,char*  ,va_list )
(def-function c-vfprintf
             "c_vfprintf" (void* string va_list) int)

;;int c_vprintf(char*  ,va_list )
(def-function c-vprintf
             "c_vprintf" (string va_list) int)

;;int c_vsnprintf(char*  ,size_t  ,char*  ,va_list )
(def-function c-vsnprintf
             "c_vsnprintf" (string int string va_list) int)

;;int c_vsprintf(char*  ,char*  ,va_list )
(def-function c-vsprintf
             "c_vsprintf" (string string va_list) int)

;;void* c_memccpy(void*  ,void*  ,int  ,size_t )
(def-function c-memccpy
             "c_memccpy" (void* void* int int) void*)

;;void* c_memchr(void*  ,int  ,size_t )
(def-function c-memchr
             "c_memchr" (void* int int) void*)

;;int c_memcmp(void*  ,void*  ,size_t )
(def-function c-memcmp
             "c_memcmp" (void* void* int) int)

;;void* c_memcpy(void*  ,void*  ,size_t )
(def-function c-memcpy
             "c_memcpy" (void* void* int) void*)

;;void* c_memmove(void*  ,void*  ,size_t )
(def-function c-memmove
             "c_memmove" (void* void* int) void*)

;;void* c_memset(void*  ,int  ,size_t )
(def-function c-memset
             "c_memset" (void* int int) void*)

;;char* c_strcat(char*  ,char* )
(def-function c-strcat
             "c_strcat" (string string) string)

;;char* c_strchr(char*  ,int )
(def-function c-strchr
             "c_strchr" (string int) string)

;;int c_strcmp(char*  ,char* )
(def-function c-strcmp
             "c_strcmp" (string string) int)

;;int c_strcoll(char*  ,char* )
(def-function c-strcoll
             "c_strcoll" (string string) int)

;;char* c_strcpy(char*  ,char* )
(def-function c-strcpy
             "c_strcpy" (string string) string)

;;size_t c_strcspn(char*  ,char* )
(def-function c-strcspn
             "c_strcspn" (string string) int)

;;char* c_strdup(char* )
(def-function c-strdup
             "c_strdup" (string) string)

;;char* c_strerror(int )
(def-function c-strerror
             "c_strerror" (int) string)

;;size_t c_strlen(char* )
(def-function c-strlen
             "c_strlen" (string) int)

;;char* c_strncat(char*  ,char*  ,size_t )
(def-function c-strncat
             "c_strncat" (string string int) string)

;;int c_strncmp(char*  ,char*  ,size_t )
(def-function c-strncmp
             "c_strncmp" (string string int) int)

;;char* c_strncpy(char*  ,char*  ,size_t )
(def-function c-strncpy
             "c_strncpy" (string string int) string)

;;char* c_strpbrk(char*  ,char* )
(def-function c-strpbrk
             "c_strpbrk" (string string) string)

;;char* c_strrchr(char*  ,int )
(def-function c-strrchr
             "c_strrchr" (string int) string)

;;size_t c_strspn(char*  ,char* )
(def-function c-strspn
             "c_strspn" (string string) int)

;;char* c_strstr(char*  ,char* )
(def-function c-strstr
             "c_strstr" (string string) string)

;;char* c_strtok(char*  ,char* )
(def-function c-strtok
             "c_strtok" (string string) string)

;;char* c_strtok_r(char*  ,char*  ,char )
(def-function c-strtok-r
             "c_strtok_r" (string string char) string)

;;size_t c_strxfrm(char*  ,char*  ,size_t )
(def-function c-strxfrm
             "c_strxfrm" (string string int) int)

;;char* c_strndup(char* s ,size_t n)
(def-function c-strndup
             "c_strndup" (string int) string)

;;int c_bcmp(void*  ,void*  ,size_t )
(def-function c-bcmp
             "c_bcmp" (void* void* int) int)

;;void c_bcopy(void*  ,void*  ,size_t )
(def-function c-bcopy
             "c_bcopy" (void* void* int) void)

;;void c_bzero(void*  ,size_t )
(def-function c-bzero
             "c_bzero" (void* int) void)

;;int c_ffs(int )
(def-function c-ffs
             "c_ffs" (int) int)

;;char* c_index(char*  ,int )
(def-function c-index
             "c_index" (string int) string)

;;char* c_rindex(char*  ,int )
(def-function c-rindex
             "c_rindex" (string int) string)

;;int c_strcasecmp(char*  ,char* )
(def-function c-strcasecmp
             "c_strcasecmp" (string string) int)

;;int c_strncasecmp(char*  ,char*  ,size_t )
(def-function c-strncasecmp
             "c_strncasecmp" (string string int) int)


)
