;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (c c-ffi)
  (export c-a64l c-abort c-abs c-atexit c-atof c-atoi c-atol
   c-bsearch c-calloc c-div c-drand48 c-ecvt c-erand48 c-exit
   c-fcvt c-free c-gcvt c-getenv c-getsubopt c-grantpt
   c-initstate c-l64a c-labs c-lcong48 c-ldiv c-lrand48
   c-malloc c-mblen c-mbstowcs c-mbtowc c-mktemp c-mkstemp
   c-mrand48 c-nrand48 c-ptsname c-putenv c-qsort c-rand
   c-rand-r c-random c-realloc c-realpath c-seed c-setkey
   c-setstate c-srand c-srand48 c-srandom c-strtod c-strtol
   c-strtoul c-system c-unlockpt c-wcstombs c-wctomb c-acos
   c-asin c-atan c-atan2 c-ceil c-cos c-cosh c-exp c-fabs
   c-floor c-fmod c-frexp c-ldexp c-log c-log10 c-modf c-pow
   c-sin c-sinh c-sqrt c-tan c-tanh c-erf c-erfc c-gamma
   c-hypot c-j0 c-j1 c-jn c-lgamma c-y0 c-y1 c-yn c-isnan
   c-acosh c-asinh c-atanh c-cbrt c-expm1 c-ilogb c-log1p
   c-logb c-nextafter c-remainder c-rint c-scalb c-clearerr
   c-ctermid c-cuserid c-fclose c-fdopen c-feof c-ferror
   c-fflush c-fgetc c-fgetpos c-fgets c-fileno c-flockfile
   c-fopen c-fprintf c-fputc c-fputs c-fread c-freopen c-fscanf
   c-fseek c-fseeko c-fsetpos c-ftell c-ftello c-ftrylockfile
   c-funlockfile c-fwrite c-getc c-getchar c-getc-unlocked
   c-getchar-unlocked c-getopt c-gets c-getw c-pclose c-perror
   c-popen c-printf c-putc c-putchar c-putc-unlocked
   c-putchar-unlocked c-puts c-putw c-remove c-rename c-rewind
   c-scanf c-setbuf c-setvbuf c-snprintf c-sprintf c-sscanf
   c-tempnam c-tmpfile c-tmpnam c-ungetc c-vfprintf c-vprintf
   c-vsnprintf c-vsprintf c-memccpy c-memchr c-memcmp c-memcpy
   c-memmove c-memset c-strcat c-strchr c-strcmp c-strcoll
   c-strcpy c-strcspn c-strdup c-strerror c-errorno c-strlen
   c-strncat c-strncmp c-strncpy c-strpbrk c-strrchr c-strspn
   c-strstr c-strtok c-strtok-r c-strxfrm c-strndup c-bcmp
   c-bcopy c-bzero c-ffs c-index c-rindex c-strcasecmp
   c-strncasecmp)
  (import (scheme) (utils libutil) (cffi cffi))
  (load-librarys "libcc")
  (def-function c-a64l "c_a64l" (string) long)
  (def-function c-abort "c_abort" (void) void)
  (def-function c-abs "c_abs" (int) int)
  (def-function c-atexit "c_atexit" () int)
  (def-function c-atof "c_atof" (string) double)
  (def-function c-atoi "c_atoi" (string) int)
  (def-function c-atol "c_atol" (string) long)
  (def-function
    c-bsearch
    "c_bsearch"
    (void* void* int int)
    void*)
  (def-function c-calloc "c_calloc" (int int) void*)
  (def-function c-div "c_div" (int int) div_t)
  (def-function c-drand48 "c_drand48" (void) double)
  (def-function
    c-ecvt
    "c_ecvt"
    (double int void* void*)
    string)
  (def-function c-erand48 "c_erand48" (int) double)
  (def-function c-exit "c_exit" (int) void)
  (def-function
    c-fcvt
    "c_fcvt"
    (double int void* void*)
    string)
  (def-function c-free "c_free" (void*) void)
  (def-function c-gcvt "c_gcvt" (double int string) string)
  (def-function c-getenv "c_getenv" (string) string)
  (def-function
    c-getsubopt
    "c_getsubopt"
    (char char char)
    int)
  (def-function c-grantpt "c_grantpt" (int) int)
  (def-function
    c-initstate
    "c_initstate"
    (int string int)
    string)
  (def-function c-l64a "c_l64a" (long) string)
  (def-function c-labs "c_labs" (long int) long)
  (def-function c-lcong48 "c_lcong48" (int) void)
  (def-function c-ldiv "c_ldiv" (long int long int) ldiv_t)
  (def-function c-lrand48 "c_lrand48" (void) long)
  (def-function c-malloc "c_malloc" (int) void*)
  (def-function c-mblen "c_mblen" (string int) int)
  (def-function
    c-mbstowcs
    "c_mbstowcs"
    (string string int)
    int)
  (def-function c-mbtowc "c_mbtowc" (string string int) int)
  (def-function c-mktemp "c_mktemp" (string) string)
  (def-function c-mkstemp "c_mkstemp" (string) int)
  (def-function c-mrand48 "c_mrand48" (void) long)
  (def-function c-nrand48 "c_nrand48" (int) long)
  (def-function c-ptsname "c_ptsname" (int) string)
  (def-function c-putenv "c_putenv" (string) int)
  (def-function c-qsort "c_qsort" (void* int int) void)
  (def-function c-rand "c_rand" (void) int)
  (def-function c-rand-r "c_rand_r" (void*) int)
  (def-function c-random "c_random" (void) long)
  (def-function c-realloc "c_realloc" (void* int) void*)
  (def-function
    c-realpath
    "c_realpath"
    (string string)
    string)
  (def-function c-seed "c_seed" (int) int)
  (def-function c-setkey "c_setkey" (string) void)
  (def-function c-setstate "c_setstate" (string) string)
  (def-function c-srand "c_srand" (int) void)
  (def-function c-srand48 "c_srand48" (long int) void)
  (def-function c-srandom "c_srandom" (int) void)
  (def-function c-strtod "c_strtod" (string char) double)
  (def-function c-strtol "c_strtol" (string char int) long)
  (def-function c-strtoul "c_strtoul" (string char int) int)
  (def-function c-system "c_system" (string) int)
  (def-function c-unlockpt "c_unlockpt" (int) int)
  (def-function
    c-wcstombs
    "c_wcstombs"
    (string string int)
    int)
  (def-function c-wctomb "c_wctomb" (string wchar_t) int)
  (def-function c-acos "c_acos" (double) double)
  (def-function c-asin "c_asin" (double) double)
  (def-function c-atan "c_atan" (double) double)
  (def-function c-atan2 "c_atan2" (double double) double)
  (def-function c-ceil "c_ceil" (double) double)
  (def-function c-cos "c_cos" (double) double)
  (def-function c-cosh "c_cosh" (double) double)
  (def-function c-exp "c_exp" (double) double)
  (def-function c-fabs "c_fabs" (double) double)
  (def-function c-floor "c_floor" (double) double)
  (def-function c-fmod "c_fmod" (double double) double)
  (def-function c-frexp "c_frexp" (double void*) double)
  (def-function c-ldexp "c_ldexp" (double int) double)
  (def-function c-log "c_log" (double) double)
  (def-function c-log10 "c_log10" (double) double)
  (def-function c-modf "c_modf" (double void*) double)
  (def-function c-pow "c_pow" (double double) double)
  (def-function c-sin "c_sin" (double) double)
  (def-function c-sinh "c_sinh" (double) double)
  (def-function c-sqrt "c_sqrt" (double) double)
  (def-function c-tan "c_tan" (double) double)
  (def-function c-tanh "c_tanh" (double) double)
  (def-function c-erf "c_erf" (double) double)
  (def-function c-erfc "c_erfc" (double) double)
  (def-function c-gamma "c_gamma" (double) double)
  (def-function c-hypot "c_hypot" (double double) double)
  (def-function c-j0 "c_j0" (double) double)
  (def-function c-j1 "c_j1" (double) double)
  (def-function c-jn "c_jn" (int double) double)
  (def-function c-lgamma "c_lgamma" (double) double)
  (def-function c-y0 "c_y0" (double) double)
  (def-function c-y1 "c_y1" (double) double)
  (def-function c-yn "c_yn" (int double) double)
  (def-function c-isnan "c_isnan" (double) int)
  (def-function c-acosh "c_acosh" (double) double)
  (def-function c-asinh "c_asinh" (double) double)
  (def-function c-atanh "c_atanh" (double) double)
  (def-function c-cbrt "c_cbrt" (double) double)
  (def-function c-expm1 "c_expm1" (double) double)
  (def-function c-ilogb "c_ilogb" (double) int)
  (def-function c-log1p "c_log1p" (double) double)
  (def-function c-logb "c_logb" (double) double)
  (def-function
    c-nextafter
    "c_nextafter"
    (double double)
    double)
  (def-function
    c-remainder
    "c_remainder"
    (double double)
    double)
  (def-function c-rint "c_rint" (double) double)
  (def-function c-scalb "c_scalb" (double double) double)
  (def-function c-clearerr "c_clearerr" (void*) void)
  (def-function c-ctermid "c_ctermid" (string) string)
  (def-function c-cuserid "c_cuserid" (string) string)
  (def-function c-fclose "c_fclose" (void*) int)
  (def-function c-fdopen "c_fdopen" (int string) void*)
  (def-function c-feof "c_feof" (void*) int)
  (def-function c-ferror "c_ferror" (void*) int)
  (def-function c-fflush "c_fflush" (void*) int)
  (def-function c-fgetc "c_fgetc" (void*) int)
  (def-function c-fgetpos "c_fgetpos" (void* void*) int)
  (def-function c-fgets "c_fgets" (string int void*) string)
  (def-function c-fileno "c_fileno" (void*) int)
  (def-function c-flockfile "c_flockfile" (void*) void)
  (def-function c-fopen "c_fopen" (string string) void*)
  (def-function c-fprintf "c_fprintf" (void* string) int)
  (def-function c-fputc "c_fputc" (int void*) int)
  (def-function c-fputs "c_fputs" (string void*) int)
  (def-function c-fread "c_fread" (void* int int void*) int)
  (def-function
    c-freopen
    "c_freopen"
    (string string void*)
    void*)
  (def-function c-fscanf "c_fscanf" (void* string) int)
  (def-function c-fseek "c_fseek" (void* int int) int)
  (def-function c-fseeko "c_fseeko" (void* off_t int) int)
  (def-function c-fsetpos "c_fsetpos" (void* void*) int)
  (def-function c-ftell "c_ftell" (void*) int)
  (def-function c-ftello "c_ftello" (void*) off_t)
  (def-function c-ftrylockfile "c_ftrylockfile" (void*) int)
  (def-function c-funlockfile "c_funlockfile" (void*) void)
  (def-function c-fwrite "c_fwrite" (void* int int void*) int)
  (def-function c-getc "c_getc" (void*) int)
  (def-function c-getchar "c_getchar" (void) int)
  (def-function c-getc-unlocked "c_getc_unlocked" (void*) int)
  (def-function
    c-getchar-unlocked
    "c_getchar_unlocked"
    (void)
    int)
  (def-function c-getopt "c_getopt" (int char string) int)
  (def-function c-gets "c_gets" (string) string)
  (def-function c-getw "c_getw" (void*) int)
  (def-function c-pclose "c_pclose" (void*) int)
  (def-function c-perror "c_perror" (string) void)
  (def-function c-popen "c_popen" (string string) void*)
  (def-function c-printf "c_printf" (string) int)
  (def-function c-putc "c_putc" (int void*) int)
  (def-function c-putchar "c_putchar" (int) int)
  (def-function
    c-putc-unlocked
    "c_putc_unlocked"
    (int void*)
    int)
  (def-function
    c-putchar-unlocked
    "c_putchar_unlocked"
    (int)
    int)
  (def-function c-puts "c_puts" (string) int)
  (def-function c-putw "c_putw" (int void*) int)
  (def-function c-remove "c_remove" (string) int)
  (def-function c-rename "c_rename" (string string) int)
  (def-function c-rewind "c_rewind" (void*) void)
  (def-function c-scanf "c_scanf" (string) int)
  (def-function c-setbuf "c_setbuf" (void* string) void)
  (def-function
    c-setvbuf
    "c_setvbuf"
    (void* string int int)
    int)
  (def-function
    c-snprintf
    "c_snprintf"
    (string int string)
    int)
  (def-function c-sprintf "c_sprintf" (string string) int)
  (def-function c-sscanf "c_sscanf" (string string) int)
  (def-function c-tempnam "c_tempnam" (string string) string)
  (def-function c-tmpfile "c_tmpfile" (void) void*)
  (def-function c-tmpnam "c_tmpnam" (string) string)
  (def-function c-ungetc "c_ungetc" (int void*) int)
  (def-function
    c-vfprintf
    "c_vfprintf"
    (void* string va_list)
    int)
  (def-function c-vprintf "c_vprintf" (string va_list) int)
  (def-function
    c-vsnprintf
    "c_vsnprintf"
    (string int string va_list)
    int)
  (def-function
    c-vsprintf
    "c_vsprintf"
    (string string va_list)
    int)
  (def-function
    c-memccpy
    "c_memccpy"
    (void* void* int int)
    void*)
  (def-function c-memchr "c_memchr" (void* int int) void*)
  (def-function c-memcmp "c_memcmp" (void* void* int) int)
  (def-function c-memcpy "c_memcpy" (void* void* int) void*)
  (def-function c-memmove "c_memmove" (void* void* int) void*)
  (def-function c-memset "c_memset" (void* int int) void*)
  (def-function c-strcat "c_strcat" (string string) string)
  (def-function c-strchr "c_strchr" (string int) string)
  (def-function c-strcmp "c_strcmp" (string string) int)
  (def-function c-strcoll "c_strcoll" (string string) int)
  (def-function c-strcpy "c_strcpy" (string string) string)
  (def-function c-strcspn "c_strcspn" (string string) int)
  (def-function c-strdup "c_strdup" (string) string)
  (def-function c-strerror "c_strerror" (int) string)
  (def-function c-errorno "c_errorno" (void) int)
  (def-function c-strlen "c_strlen" (string) int)
  (def-function
    c-strncat
    "c_strncat"
    (string string int)
    string)
  (def-function c-strncmp "c_strncmp" (string string int) int)
  (def-function
    c-strncpy
    "c_strncpy"
    (string string int)
    string)
  (def-function c-strpbrk "c_strpbrk" (string string) string)
  (def-function c-strrchr "c_strrchr" (string int) string)
  (def-function c-strspn "c_strspn" (string string) int)
  (def-function c-strstr "c_strstr" (string string) string)
  (def-function c-strtok "c_strtok" (string string) string)
  (def-function
    c-strtok-r
    "c_strtok_r"
    (string string char)
    string)
  (def-function c-strxfrm "c_strxfrm" (string string int) int)
  (def-function c-strndup "c_strndup" (string int) string)
  (def-function c-bcmp "c_bcmp" (void* void* int) int)
  (def-function c-bcopy "c_bcopy" (void* void* int) void)
  (def-function c-bzero "c_bzero" (void* int) void)
  (def-function c-ffs "c_ffs" (int) int)
  (def-function c-index "c_index" (string int) string)
  (def-function c-rindex "c_rindex" (string int) string)
  (def-function
    c-strcasecmp
    "c_strcasecmp"
    (string string)
    int)
  (def-function
    c-strncasecmp
    "c_strncasecmp"
    (string string int)
    int))

