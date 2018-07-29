;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-06-10 23:49:57.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (regex regex-ffi )
  (export regcomp
  regexec
  regerror
  regfree
  REG_EXTENDED
  REG_NOERROR
REG_NOMATCH
REG_BADPAT
REG_ECOLLATE
REG_ECTYPE
REG_EESCAPE
REG_ESUBREG
REG_EBRACK
REG_EPAREN
REG_EBRACE
REG_BADBR
REG_ERANGE
REG_ESPACE
REG_BADRPT

  )

 (import (scheme) (utils libutil) (cffi cffi) )


 (load-librarys  "libscm" "libsystre-0" )

 (define  REG_EXTENDED 1)

 (define   REG_NOERROR  0);;	/* Success.  */
 (define    REG_NOMATCH 1);;,		/* Didn't find a match (for regexec).  */
 (define    REG_BADPAT 2);;,		/* Invalid pattern.  */
 (define    REG_ECOLLATE 3);;,		/* Inalid collating element.  */
 (define    REG_ECTYPE 4);;,		/* Invalid character class name.  */
 (define    REG_EESCAPE 5);;,		/* Trailing backslash.  */
 (define    REG_ESUBREG 6 );;,		/* Invalid back reference.  */
 (define    REG_EBRACK 7);;,		/* Unmatched left bracket.  */
 (define    REG_EPAREN 8);;,		/* Parenthesis imbalance.  */
 (define    REG_EBRACE 9);;,		/* Unmatched \{.  */
 (define    REG_BADBR 10);;,		/* Invalid contents of \{\}.  */
 (define    REG_ERANGE 11);;,		/* Invalid range end.  */
 (define    REG_ESPACE 12);;,		/* Ran out of memory.  */
 (define    REG_BADRPT 13);;,		/* No preceding re for repetition op.  */


;;int regcomp(regex_t* __preg ,char* __pattern ,int __cflags)
(def-function regcomp
             "regcomp" (void* string int) int)

;;int regexec(regex_t* __preg ,char* __string ,size_t __nmatch,regmatch_t matchptr [] ,int __eflags)
(def-function regexec
             "regexec" (void* string int void* int) int)

;;size_t regerror(int __errcode ,regex_t* __preg ,char* __errbuf ,size_t __errbuf_size)
(def-function regerror
             "regerror" (int void* string int) int)

;;void regfree(regex_t* __preg)
(def-function regfree
             "regfree" (void*) void)


)
