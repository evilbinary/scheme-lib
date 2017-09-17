
/*****************************************************************************
*作者:evilbinary on 2017-09-17 13:52:31.
*邮箱:rootdebug@163.com
******************************************************************************/
#include "c.h" 
// //long a64l(const char* )
// long c_a64l (const char* arg0){
// return  a64l(arg0);
// }

//void abort(void )
void c_abort (){
 abort();
}

//int abs(int )
int c_abs (int arg0){
return  abs(arg0);
}

//int atexit()
int c_atexit (void (*arg0)(void) ){
return  atexit(arg0);
}

//double atof(const char* )
double c_atof (const char* arg0){
return  atof(arg0);
}

//int atoi(const char* )
int c_atoi (const char* arg0){
return  atoi(arg0);
}

//long atol(const char* )
long c_atol (const char* arg0){
return  atol(arg0);
}

//void* bsearch(const void*  ,const void*  ,size_t  ,size_t )
void* c_bsearch (const void* arg0,const void* arg1,size_t arg2,size_t arg3,int (*arg4)(const void *, const void *)){
return  bsearch(arg0,arg1,arg2,arg3,arg4);
}

//void* calloc(size_t  ,size_t )
void* c_calloc (size_t arg0,size_t arg1){
return  calloc(arg0,arg1);
}

//div_t div(int  ,int )
div_t c_div (int arg0,int arg1){
return  div(arg0,arg1);
}

// //double drand48(void )
// double c_drand48 (){
// return  drand48();
// }

//char* ecvt(double  ,int  , int*  , int* )
char* c_ecvt (double arg0,int arg1, int* arg2, int* arg3){
return  ecvt(arg0,arg1,arg2,arg3);
}

// //double erand48(unsigned )
// double c_erand48 (unsigned short int arg0[3] ){
// return  erand48(arg0);
// }

//void exit(int )
void c_exit (int arg0){
 exit(arg0);
}

//char* fcvt(double  ,int  , int*  , int* )
char* c_fcvt (double arg0,int arg1, int* arg2, int* arg3){
return  fcvt(arg0,arg1,arg2,arg3);
}

//void free( void* )
void c_free ( void* arg0){
 free(arg0);
}

//char* gcvt(double  ,int  , char* )
char* c_gcvt (double arg0,int arg1, char* arg2){
return  gcvt(arg0,arg1,arg2);
}

//char* getenv(const char* )
char* c_getenv (const char* arg0){
return  getenv(arg0);
}

// //int getsubopt(char  ,char  ,char )
// int c_getsubopt (char** arg0,char *const * arg1,char** arg2){
// return  getsubopt(arg0,arg1,arg2);
// }

// //int grantpt(int )
// int c_grantpt (int arg0){
// return  grantpt(arg0);
// }

// //char* initstate(unsigned int  , char*  ,size_t )
// char* c_initstate (unsigned int arg0, char* arg1,size_t arg2){
// return  initstate(arg0,arg1,arg2);
// }

// //char* l64a(long )
// char* c_l64a (long arg0){
// return  l64a(arg0);
// }

//long labs(long int )
long c_labs (long int arg0){
return  labs(arg0);
}

// //void lcong48(unsigned )
// void c_lcong(unsigned short int arg0[7]){
//  lcong(arg0);
// }

//ldiv_t ldiv(long int  ,long int )
ldiv_t c_ldiv (long int arg0,long int arg1){
return  ldiv(arg0,arg1);
}

// //long lrand(void )
// long c_lrand (){
// return  lrand();
// }

//void* malloc(size_t )
void* c_malloc (size_t arg0){
return  malloc(arg0);
}

//int mblen(const char*  ,size_t )
int c_mblen (const char* arg0,size_t arg1){
return  mblen(arg0,arg1);
}

//size_t mbstowcs( wchar_t*  ,const char*  ,size_t )
size_t c_mbstowcs ( wchar_t* arg0,const char* arg1,size_t arg2){
return  mbstowcs(arg0,arg1,arg2);
}

//int mbtowc( wchar_t*  ,const char*  ,size_t )
int c_mbtowc ( wchar_t* arg0,const char* arg1,size_t arg2){
return  mbtowc(arg0,arg1,arg2);
}

//char* mktemp( char* )
char* c_mktemp ( char* arg0){
return  mktemp(arg0);
}

//int mkstemp( char* )
int c_mkstemp ( char* arg0){
return  mkstemp(arg0);
}

// //long mrand48(void )
// long int  c_nrand48(unsigned short int arg0[3]){
// return  mrand48(arg0);
// }

//char* ptsname(int )
// char* c_ptsname (int arg0){
// return  ptsname(arg0);
// }

//int putenv( char* )
int c_putenv ( char* arg0){
return  putenv(arg0);
}

//void qsort( void*  ,size_t  ,size_t )
void c_qsort ( void* arg0,size_t arg1,size_t arg2,int (*arg3)(const void *, const void *) ){
 qsort(arg0,arg1,arg2,arg3);
}

//int rand(void )
int c_rand (){
return  rand();
}

// //int rand_r( unsigned int* )
// int c_rand_r ( unsigned int* arg0){
// return  rand_r(arg0);
// }

// //long random(void )
// long c_random (){
// return  random();
// }

//void* realloc( void*  ,size_t )
void* c_realloc ( void* arg0,size_t arg1){
return  realloc(arg0,arg1);
}

//char* realpath(const char*  , char* )
// char* c_realpath (const char* arg0, char* arg1){
// return  realpath(arg0,arg1);
// }

// //unsigned  short int seed(unsigned )
// unsigned  short int c_seed (unsigned short int arg0[3] ){
// return  seed(arg0);
// }

// //void setkey(const char* )
// void c_setkey (const char* arg0){
//  setkey(arg0);
// }

// //char* setstate(const char* )
// char* c_setstate (const char* arg0){
// return  setstate(arg0);
// }

//void srand(unsigned int )
void c_srand (unsigned int arg0){
 srand(arg0);
}

// //void srand48(long int )
// void c_srand (long int arg0){
//  srand(arg0);
// }

//void srandom(unsigned )
// void c_srandom (unsigned arg0){
//  srandom(arg0);
// }

//double strtod(const char*  ,char )
double c_strtod (const char* arg0,char** arg1){
return  strtod(arg0,arg1);
}

//long strtol(const char*  ,char  ,int )
long int c_strtol (const char* arg0,char** arg1,int arg2){
return  strtol(arg0,arg1,arg2);
}

//unsigned strtoul(const char*  ,char  ,int )
unsigned long int  c_strtoul (const char* arg0,char** arg1,int arg2){
return  strtoul(arg0,arg1,arg2);
}

//int system(const char* )
int c_system (const char* arg0){
return  system(arg0);
}

// //int unlockpt(int )
// int c_unlockpt (int arg0){
// return  unlockpt(arg0);
// }

//size_t wcstombs( char*  ,const wchar_t*  ,size_t )
size_t c_wcstombs ( char* arg0,const wchar_t* arg1,size_t arg2){
return  wcstombs(arg0,arg1,arg2);
}

//int wctomb( char*  ,wchar_t )
int c_wctomb ( char* arg0,wchar_t arg1){
return  wctomb(arg0,arg1);
}

//double acos(double )
double c_acos (double arg0){
return  acos(arg0);
}

//double asin(double )
double c_asin (double arg0){
return  asin(arg0);
}

//double atan(double )
double c_atan (double arg0){
return  atan(arg0);
}

//double atan2(double  ,double )
double c_atan2 (double arg0,double arg1){
return  atan2(arg0,arg1);
}

//double ceil(double )
double c_ceil (double arg0){
return  ceil(arg0);
}

//double cos(double )
double c_cos (double arg0){
return  cos(arg0);
}

//double cosh(double )
double c_cosh (double arg0){
return  cosh(arg0);
}

//double exp(double )
double c_exp (double arg0){
return  exp(arg0);
}

//double fabs(double )
double c_fabs (double arg0){
return  fabs(arg0);
}

//double floor(double )
double c_floor (double arg0){
return  floor(arg0);
}

//double fmod(double  ,double )
double c_fmod (double arg0,double arg1){
return  fmod(arg0,arg1);
}

//double frexp(double  , int* )
double c_frexp (double arg0, int* arg1){
return  frexp(arg0,arg1);
}

//double ldexp(double  ,int )
double c_ldexp (double arg0,int arg1){
return  ldexp(arg0,arg1);
}

//double log(double )
double c_log (double arg0){
return  log(arg0);
}

//double log10(double )
double c_log10 (double arg0){
return  log10(arg0);
}

//double modf(double  , double* )
double c_modf (double arg0, double* arg1){
return  modf(arg0,arg1);
}

//double pow(double  ,double )
double c_pow (double arg0,double arg1){
return  pow(arg0,arg1);
}

//double sin(double )
double c_sin (double arg0){
return  sin(arg0);
}

//double sinh(double )
double c_sinh (double arg0){
return  sinh(arg0);
}

//double sqrt(double )
double c_sqrt (double arg0){
return  sqrt(arg0);
}

//double tan(double )
double c_tan (double arg0){
return  tan(arg0);
}

//double tanh(double )
double c_tanh (double arg0){
return  tanh(arg0);
}

//double erf(double )
double c_erf (double arg0){
return  erf(arg0);
}

//double erfc(double )
double c_erfc (double arg0){
return  erfc(arg0);
}

// //double gamma(double )
// double c_gamma (double arg0){
// return  gamma(arg0);
// }

//double hypot(double  ,double )
double c_hypot (double arg0,double arg1){
return  hypot(arg0,arg1);
}

//double j0(double )
double c_j0 (double arg0){
return  j0(arg0);
}

//double j1(double )
double c_j1 (double arg0){
return  j1(arg0);
}

//double jn(int  ,double )
double c_jn (int arg0,double arg1){
return  jn(arg0,arg1);
}

//double lgamma(double )
double c_lgamma (double arg0){
return  lgamma(arg0);
}

//double y0(double )
double c_y0 (double arg0){
return  y0(arg0);
}

//double y1(double )
double c_y1 (double arg0){
return  y1(arg0);
}

//double yn(int  ,double )
double c_yn (int arg0,double arg1){
return  yn(arg0,arg1);
}

//int isnan(double )
int c_isnan (double arg0){
return  isnan(arg0);
}

//double acosh(double )
double c_acosh (double arg0){
return  acosh(arg0);
}

//double asinh(double )
double c_asinh (double arg0){
return  asinh(arg0);
}

//double atanh(double )
double c_atanh (double arg0){
return  atanh(arg0);
}

//double cbrt(double )
double c_cbrt (double arg0){
return  cbrt(arg0);
}

//double expm1(double )
double c_expm1 (double arg0){
return  expm1(arg0);
}

//int ilogb(double )
int c_ilogb (double arg0){
return  ilogb(arg0);
}

//double log1p(double )
double c_log1p (double arg0){
return  log1p(arg0);
}

//double logb(double )
double c_logb (double arg0){
return  logb(arg0);
}

//double nextafter(double  ,double )
double c_nextafter (double arg0,double arg1){
return  nextafter(arg0,arg1);
}

//double remainder(double  ,double )
double c_remainder (double arg0,double arg1){
return  remainder(arg0,arg1);
}

//double rint(double )
double c_rint (double arg0){
return  rint(arg0);
}

// //double scalb(double  ,double )
// double c_scalb (double arg0,double arg1){
// return  scalb(arg0,arg1);
// }

//void clearerr( FILE* )
void c_clearerr ( FILE* arg0){
 clearerr(arg0);
}

// //char* ctermid( char* )
// char* c_ctermid ( char* arg0){
// return  ctermid(arg0);
// }

// //char* cuserid( char* )
// char* c_cuserid ( char* arg0){
// return  cuserid(arg0);
// }

//int fclose( FILE* )
int c_fclose ( FILE* arg0){
return  fclose(arg0);
}

//FILE* fdopen(int  ,const char* )
FILE* c_fdopen (int arg0,const char* arg1){
return  fdopen(arg0,arg1);
}

//int feof( FILE* )
int c_feof ( FILE* arg0){
return  feof(arg0);
}

//int ferror( FILE* )
int c_ferror ( FILE* arg0){
return  ferror(arg0);
}

//int fflush( FILE* )
int c_fflush ( FILE* arg0){
return  fflush(arg0);
}

//int fgetc( FILE* )
int c_fgetc ( FILE* arg0){
return  fgetc(arg0);
}

//int fgetpos( FILE*  , fpos_t* )
int c_fgetpos ( FILE* arg0, fpos_t* arg1){
return  fgetpos(arg0,arg1);
}

//char* fgets( char*  ,int  , FILE* )
char* c_fgets ( char* arg0,int arg1, FILE* arg2){
return  fgets(arg0,arg1,arg2);
}

//int fileno( FILE* )
int c_fileno ( FILE* arg0){
return  fileno(arg0);
}

// //void flockfile( FILE* )
// void c_flockfile ( FILE* arg0){
//  flockfile(arg0);
// }

//FILE* fopen(const char*  ,const char* )
FILE* c_fopen (const char* arg0,const char* arg1){
return  fopen(arg0,arg1);
}

//int fprintf( FILE*  ,const char* )
int c_fprintf ( FILE* arg0,const char* arg1,...){
	int nret = 0;
	va_list args;  
    va_start(args, arg1);  
    nret = fprintf(arg0,arg1, args);  
    va_end(args);  
return  nret;
}

//int fputc(int  , FILE* )
int c_fputc (int arg0, FILE* arg1){
return  fputc(arg0,arg1);
}

//int fputs(const char*  , FILE* )
int c_fputs (const char* arg0, FILE* arg1){
return  fputs(arg0,arg1);
}

//size_t fread( void*  ,size_t  ,size_t  , FILE* )
size_t c_fread (char* arg0,size_t arg1,size_t arg2, FILE* arg3){
return  fread(arg0,arg1,arg2,arg3);
}

//FILE* freopen(const char*  ,const char*  , FILE* )
FILE* c_freopen (const char* arg0,const char* arg1, FILE* arg2){
return  freopen(arg0,arg1,arg2);
}

//int fscanf( FILE*  ,const char* )
int c_fscanf ( FILE* arg0,const char* arg1,...){

	int nret=0;
	va_list args;
	va_start(args,arg1);
	nret=fscanf(arg0,arg1,args);
	va_end(args);
	return nret;
}

//int fseek( FILE*  ,long int  ,int )
int c_fseek ( FILE* arg0,long int arg1,int arg2){
return  fseek(arg0,arg1,arg2);
}

//int fseeko( FILE*  ,off_t  ,int )
int c_fseeko ( FILE* arg0,off_t arg1,int arg2){
return  fseeko(arg0,arg1,arg2);
}

//int fsetpos( FILE*  ,const fpos_t* )
int c_fsetpos ( FILE* arg0,const fpos_t* arg1){
return  fsetpos(arg0,arg1);
}

//long ftell( FILE* )
long c_ftell ( FILE* arg0){
return  ftell(arg0);
}

//off_t ftello( FILE* )
off_t c_ftello ( FILE* arg0){
return  ftello(arg0);
}

// //int ftrylockfile( FILE* )
// int c_ftrylockfile ( FILE* arg0){
// return  ftrylockfile(arg0);
// }

// //void funlockfile( FILE* )
// void c_funlockfile ( FILE* arg0){
//  funlockfile(arg0);
// }

//size_t fwrite(const void*  ,size_t  ,size_t  , FILE* )
size_t c_fwrite (const void* arg0,size_t arg1,size_t arg2, FILE* arg3){
return  fwrite(arg0,arg1,arg2,arg3);
}

//int getc( FILE* )
int c_getc ( FILE* arg0){
return  getc(arg0);
}

//int getchar(void )
int c_getchar (){
return  getchar();
}

// //int getunlocked( FILE* )
// int c_getunlocked ( FILE* arg0){
// return  getunlocked(arg0);
// }

// //int getchar_unlocked(void )
// int c_getchar_unlocked (){
// return  getchar_unlocked();
// }

//int getopt(int  ,const char* )
int c_getopt(int arg0, char ** arg1,const char* arg2){
return  getopt(arg0,arg1,arg2);
}

//char* gets( char* )
char* c_gets ( char* arg0){
return  gets(arg0);
}

//int getw( FILE* )
int c_getw ( FILE* arg0){
return  getw(arg0);
}

//int pclose( FILE* )
int c_pclose ( FILE* arg0){
return  pclose(arg0);
}

//void perror(const char* )
void c_perror (const char* arg0){
 perror(arg0);
}

//FILE* popen(const char*  ,const char* )
FILE* c_popen (const char* arg0,const char* arg1){
return  popen(arg0,arg1);
}

//int printf(const char* )
int c_printf (const char* arg0,...){
	int nret=0;
	va_list args;
	va_start(args,arg0);
	  nret=printf(arg0,args);
	  va_end(args);
	return  nret;
}

//int putc(int  , FILE* )
int c_putc (int arg0, FILE* arg1){
return  putc(arg0,arg1);
}

//int putchar(int )
int c_putchar (int arg0){
return  putchar(arg0);
}

// //int putunlocked(int  , FILE* )
// int c_putunlocked (int arg0, FILE* arg1){
// return  putunlocked(arg0,arg1);
// }

// //int putchar_unlocked(int )
// int c_putchar_unlocked (int arg0){
// return  putchar_unlocked(arg0);
// }

//int puts(const char* )
int c_puts (const char* arg0){
return  puts(arg0);
}

//int putw(int  , FILE* )
int c_putw (int arg0, FILE* arg1){
return  putw(arg0,arg1);
}

//int remove(const char* )
int c_remove (const char* arg0){
return  remove(arg0);
}

//int rename(const char*  ,const char* )
int c_rename (const char* arg0,const char* arg1){
return  rename(arg0,arg1);
}

//void rewind( FILE* )
void c_rewind ( FILE* arg0){
 rewind(arg0);
}

//int scanf(const char* )
int c_scanf (const char* arg0,...){
	int nret=0;
	va_list args;
	va_start(args,arg0);
	  nret=scanf(arg0,args);
	  va_end(args);
}

//void setbuf( FILE*  , char* )
void c_setbuf ( FILE* arg0, char* arg1){
 setbuf(arg0,arg1);
}

//int setvbuf( FILE*  , char*  ,int  ,size_t )
int c_setvbuf ( FILE* arg0, char* arg1,int arg2,size_t arg3){
return  setvbuf(arg0,arg1,arg2,arg3);
}

//int snprintf( char*  ,size_t  ,const char* )
int c_snprintf ( char* arg0,size_t arg1,const char* arg2,...){
	int nret;
	va_list args; 
    va_start(args, arg0);  
    nret = snprintf(arg0,arg1,args); 
    va_end(args);
	return  nret;
}

//int sprintf( char*  ,const char* )
int c_sprintf ( char* arg0,const char* arg1,...){
	int nret;
	va_list args;  
    va_start(args, arg1);  
    nret = sprintf(arg0,arg1,args); 
    va_end(args);
	return  nret;
}

//int sscanf(const char*  ,const char* )
int c_sscanf (const char* arg0,const char* arg1,...){
	int nret;
	va_list args;  
    va_start(args, arg0);  
    nret = sscanf(arg0,arg1,args); 
    va_end(args);
	return  nret;
}

//char* tempnam(const char*  ,const char* )
char* c_tempnam (const char* arg0,const char* arg1){
return  tempnam(arg0,arg1);
}

//FILE* tmpfile(void )
FILE* c_tmpfile (){
return  tmpfile();
}

//char* tmpnam( char* )
char* c_tmpnam ( char* arg0){
return  tmpnam(arg0);
}

//int ungetc(int  , FILE* )
int c_ungetc (int arg0, FILE* arg1){
return  ungetc(arg0,arg1);
}

//int vfprintf( FILE*  ,const char*  ,va_list )
int c_vfprintf ( FILE* arg0,const char* arg1,va_list arg2){
return  vfprintf(arg0,arg1,arg2);
}

//int vprintf(const char*  ,va_list )
int c_vprintf (const char* arg0,va_list arg1){
return  vprintf(arg0,arg1);
}

//int vsnprintf( char*  ,size_t  ,const char*  ,va_list )
int c_vsnprintf ( char* arg0,size_t arg1,const char* arg2,va_list arg3){
return  vsnprintf(arg0,arg1,arg2,arg3);
}

//int vsprintf( char*  ,const char*  ,va_list )
int c_vsprintf ( char* arg0,const char* arg1,va_list arg2){
return  vsprintf(arg0,arg1,arg2);
}

//void* memccpy( void*  ,const void*  ,int  ,size_t )
void* c_memccpy ( void* arg0,const void* arg1,int arg2,size_t arg3){
return  memccpy(arg0,arg1,arg2,arg3);
}

//void* memchr(const void*  ,int  ,size_t )
void* c_memchr (const void* arg0,int arg1,size_t arg2){
return  memchr(arg0,arg1,arg2);
}

//int memcmp(const void*  ,const void*  ,size_t )
int c_memcmp (const void* arg0,const void* arg1,size_t arg2){
return  memcmp(arg0,arg1,arg2);
}

//void* memcpy( void*  ,const void*  ,size_t )
void* c_memcpy ( void* arg0,const void* arg1,size_t arg2){
return  memcpy(arg0,arg1,arg2);
}

//void* memmove( void*  ,const void*  ,size_t )
void* c_memmove ( void* arg0,const void* arg1,size_t arg2){
return  memmove(arg0,arg1,arg2);
}

//void* memset( void*  ,int  ,size_t )
void* c_memset ( void* arg0,int arg1,size_t arg2){
return  memset(arg0,arg1,arg2);
}

//char* strcat( char*  ,const char* )
char* c_strcat ( char* arg0,const char* arg1){
return  strcat(arg0,arg1);
}

//char* strchr(const char*  ,int )
char* c_strchr (const char* arg0,int arg1){
return  strchr(arg0,arg1);
}

//int strcmp(const char*  ,const char* )
int c_strcmp (const char* arg0,const char* arg1){
return  strcmp(arg0,arg1);
}

//int strcoll(const char*  ,const char* )
int c_strcoll (const char* arg0,const char* arg1){
return  strcoll(arg0,arg1);
}

//char* strcpy( char*  ,const char* )
char* c_strcpy ( char* arg0,const char* arg1){
return  strcpy(arg0,arg1);
}

//size_t strcspn(const char*  ,const char* )
size_t c_strcspn (const char* arg0,const char* arg1){
return  strcspn(arg0,arg1);
}

//char* strdup(const char* )
char* c_strdup (const char* arg0){
return  strdup(arg0);
}

//char* strerror(int )
char* c_strerror (int arg0){
return  strerror(arg0);
}

//size_t strlen(const char* )
size_t c_strlen (const char* arg0){
return  strlen(arg0);
}

//char* strncat( char*  ,const char*  ,size_t )
char* c_strncat ( char* arg0,const char* arg1,size_t arg2){
return  strncat(arg0,arg1,arg2);
}

//int strncmp(const char*  ,const char*  ,size_t )
int c_strncmp (const char* arg0,const char* arg1,size_t arg2){
return  strncmp(arg0,arg1,arg2);
}

//char* strncpy( char*  ,const char*  ,size_t )
char* c_strncpy ( char* arg0,const char* arg1,size_t arg2){
return  strncpy(arg0,arg1,arg2);
}

//char* strpbrk(const char*  ,const char* )
char* c_strpbrk (const char* arg0,const char* arg1){
return  strpbrk(arg0,arg1);
}

//char* strrchr(const char*  ,int )
char* c_strrchr (const char* arg0,int arg1){
return  strrchr(arg0,arg1);
}

//size_t strspn(const char*  ,const char* )
size_t c_strspn (const char* arg0,const char* arg1){
return  strspn(arg0,arg1);
}

//char* strstr(const char*  ,const char* )
char* c_strstr (const char* arg0,const char* arg1){
return  strstr(arg0,arg1);
}

//char* strtok( char*  ,const char* )
char* c_strtok ( char* arg0,const char* arg1){
return  strtok(arg0,arg1);
}

//char* strtok_r( char*  ,const char*  ,char )
char* c_strtok_r ( char* arg0,const char* arg1,char** arg2){
return  strtok_r(arg0,arg1,arg2);
}

//size_t strxfrm( char*  ,const char*  ,size_t )
size_t c_strxfrm ( char* arg0,const char* arg1,size_t arg2){
return  strxfrm(arg0,arg1,arg2);
}

// //char* strndup(const char* s ,size_t n)
// char* c_strndup (const char* arg0,size_t arg1){
// return  strndup(arg0,arg1);
// }

// //int bcmp(const void*  ,const void*  ,size_t )
// int c_bcmp (const void* arg0,const void* arg1,size_t arg2){
// return  bcmp(arg0,arg1,arg2);
// }

// //void bcopy(const void*  , void*  ,size_t )
// void c_bcopy (const void* arg0, void* arg1,size_t arg2){
//  bcopy(arg0,arg1,arg2);
// }

// //void bzero( void*  ,size_t )
// void c_bzero ( void* arg0,size_t arg1){
//  bzero(arg0,arg1);
// }

//int ffs(int )
// int c_ffs (int arg0){
// return  ffs(arg0);
// }

//char* index(const char*  ,int )
// char* c_index (const char* arg0,int arg1){
// return  index(arg0,arg1);
// }

//char* rindex(const char*  ,int )
// char* c_rindex (const char* arg0,int arg1){
// return  rindex(arg0,arg1);
// }

//int strcasecmp(const char*  ,const char* )
int c_strcasecmp (const char* arg0,const char* arg1){
return  strcasecmp(arg0,arg1);
}

//int strncasecmp(const char*  ,const char*  ,size_t )
int c_strncasecmp (const char* arg0,const char* arg1,size_t arg2){
return  strncasecmp(arg0,arg1,arg2);
}



