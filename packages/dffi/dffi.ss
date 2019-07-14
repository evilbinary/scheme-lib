;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (dffi dffi)
  (export def-function def-function-callback load-librarys
   dffi-log def-struct dffi-alloc dffi-free dffi-set-char
   dffi-set-int dffi-set-float dffi-set-double dffi-get-uchar
   dffi-get-uint dffi-get-ulong dffi-get-char dffi-get-int
   dffi-get-float dffi-get-long dffi-get-double
   dffi-get-pointer dffi-get-string dffi-get-string-offset
   dffi-set-pointer dffi-set-string dffi-get-pointer-offset
   dffi-get-string-pointer dffi-string-pointer dffi-string
   print-ptr print-string dffi-set struct-size lisp2struct
   struct2lisp load-lib get-loaded-libs-list test-call)
  (import (scheme) (utils libutil))
  (define lib-name
    (case (machine-type)
      [(arm32le) "libdffi.so"]
      [(a6nt i3nt ta6nt ti3nt) "libdffi.dll"]
      [(a6osx ta6osx i3osx ti3osx) "libdffi.so"]
      [(a6le i3le ta6le ti3le) "libdffi.so"]))
  (define lib (load-lib lib-name))
  (define DC_CALL_C_DEFAULT 0)
  (define DC_CALL_C_ELLIPSIS 100)
  (define DC_CALL_C_ELLIPSIS_VARARGS 101)
  (define DC_CALL_C_X86_CDECL 1)
  (define DC_CALL_C_X86_WIN32_STD 2)
  (define DC_CALL_C_X86_WIN32_FAST_MS 3)
  (define DC_CALL_C_X86_WIN32_FAST_GNU 4)
  (define DC_CALL_C_X86_WIN32_THIS_MS 5)
  (define DC_CALL_C_X86_WIN32_THIS_GNU 6)
  (define DC_CALL_C_X64_WIN64 7)
  (define DC_CALL_C_X64_SYSV 8)
  (define DC_CALL_C_PPC32_DARWIN 9)
  (define DC_CALL_C_PPC32_OSX DC_CALL_C_PPC32_DARWIN)
  (define DC_CALL_C_ARM_ARM_EABI 10)
  (define DC_CALL_C_ARM_THUMB_EABI 11)
  (define DC_CALL_C_ARM_ARMHF 30)
  (define DC_CALL_C_MIPS32_EABI 12)
  (define DC_CALL_C_MIPS32_PSPSDK DC_CALL_C_MIPS32_EABI)
  (define DC_CALL_C_PPC32_SYSV 13)
  (define DC_CALL_C_PPC32_LINUX DC_CALL_C_PPC32_SYSV)
  (define DC_CALL_C_ARM_ARM 14)
  (define DC_CALL_C_ARM_THUMB 15)
  (define DC_CALL_C_MIPS32_O32 16)
  (define DC_CALL_C_MIPS64_N32 17)
  (define DC_CALL_C_MIPS64_N64 18)
  (define DC_CALL_C_X86_PLAN9 19)
  (define DC_CALL_C_SPARC32 20)
  (define DC_CALL_C_SPARC64 21)
  (define DC_CALL_C_ARM64 22)
  (define DC_CALL_C_PPC64 23)
  (define DC_CALL_C_PPC64_LINUX DC_CALL_C_PPC64)
  (define DC_CALL_SYS_DEFAULT 200)
  (define DC_CALL_SYS_X86_INT80H_LINUX 201)
  (define DC_CALL_SYS_X86_INT80H_BSD 202)
  (define DC_CALL_SYS_PPC32 210)
  (define DC_CALL_SYS_PPC64 211)
  (define DC_ERROR_NONE 0)
  (define DC_ERROR_UNSUPPORTED_MODE -1)
  (define DEFAULT_ALIGNMENT 0)
  (define DC_TRUE 1)
  (define DC_FALSE 0)
  (define DC_SIGCHAR_VOID (char->integer #\v))
  (define DC_SIGCHAR_BOOL (char->integer #\B))
  (define DC_SIGCHAR_CHAR (char->integer #\c))
  (define DC_SIGCHAR_UCHAR (char->integer #\C))
  (define DC_SIGCHAR_SHORT (char->integer #\s))
  (define DC_SIGCHAR_USHORT (char->integer #\S))
  (define DC_SIGCHAR_INT (char->integer #\i))
  (define DC_SIGCHAR_UINT (char->integer #\I))
  (define DC_SIGCHAR_LONG (char->integer #\j))
  (define DC_SIGCHAR_ULONG (char->integer #\J))
  (define DC_SIGCHAR_LONGLONG (char->integer #\l))
  (define DC_SIGCHAR_ULONGLONG (char->integer #\L))
  (define DC_SIGCHAR_FLOAT (char->integer #\f))
  (define DC_SIGCHAR_DOUBLE (char->integer #\d))
  (define DC_SIGCHAR_POINTER (char->integer #\p))
  (define DC_SIGCHAR_STRING (char->integer #\Z))
  (define DC_SIGCHAR_STRUCT (char->integer #\T))
  (define DC_SIGCHAR_ENDARG (char->integer #\)))
  (define DC_SIGCHAR_CC_PREFIX (char->integer #\_))
  (define DC_SIGCHAR_CC_ELLIPSIS (char->integer #\e))
  (define DC_SIGCHAR_CC_STDCALL (char->integer #\s))
  (define DC_SIGCHAR_CC_FASTCALL_GNU (char->integer #\f))
  (define DC_SIGCHAR_CC_FASTCALL_MS (char->integer #\F))
  (define DC_SIGCHAR_CC_THISCALL_MS (char->integer #\+))
  (define dcNewCallVM
    (foreign-procedure "dcNewCallVM" (int) void*))
  (define dcFree (foreign-procedure "dcFree" (void*) void))
  (define dcReset (foreign-procedure "dcReset" (void*) void))
  (define dcMode
    (foreign-procedure "dcMode" (void* int) void))
  (define dcArgBool
    (foreign-procedure "dcArgBool" (void* int) void))
  (define dcArgChar
    (foreign-procedure "dcArgChar" (void* char) void))
  (define dcArgShort
    (foreign-procedure "dcArgShort" (void* short) void))
  (define dcArgInt
    (foreign-procedure "dcArgInt" (void* int) void))
  (define dcArgLong
    (foreign-procedure "dcArgLong" (void* int) void))
  (define dcArgLongLong
    (foreign-procedure "dcArgLongLong" (void* integer-64) void))
  (define dcArgFloat
    (foreign-procedure "dcArgFloat" (void* float) void))
  (define dcArgDouble
    (foreign-procedure "dcArgDouble" (void* double) void))
  (define dcArgPointer
    (foreign-procedure "dcArgPointer" (void* void*) void))
  (define dcArgStruct
    (foreign-procedure "dcArgStruct" (void* void* void*) void))
  (define dcArgString
    (foreign-procedure "dcArgPointer" (void* string) void))
  (define dcCallVoid
    (foreign-procedure "dcCallVoid" (void* void*) void))
  (define dcCallBool
    (foreign-procedure "dcCallBool" (void* void*) char))
  (define dcCallChar
    (foreign-procedure "dcCallChar" (void* void*) char))
  (define dcCallShort
    (foreign-procedure "dcCallShort" (void* void*) short))
  (define dcCallInt
    (foreign-procedure "dcCallInt" (void* void*) int))
  (define dcCallLong
    (foreign-procedure "dcCallLong" (void* void*) long))
  (define dcCallLongLong
    (foreign-procedure "dcCallLongLong"
      (void* void*)
      integer-64))
  (define dcCallFloat
    (foreign-procedure "dcCallFloat" (void* void*) float))
  (define dcCallDouble
    (foreign-procedure "dcCallDouble" (void* void*) double))
  (define dcCallPointer
    (foreign-procedure "dcCallPointer" (void* void*) void*))
  (define dcCallStruct
    (foreign-procedure "dcCallStruct"
      (void* void* void* void*)
      void))
  (define dcCallString
    (foreign-procedure "dcCallPointer" (void* void*) string))
  (define dcGetError
    (foreign-procedure "dcGetError" (void* void*) int))
  (define dcNewStruct
    (foreign-procedure "dcNewStruct" (int int) void*))
  (define dcStructField
    (foreign-procedure "dcStructField"
      (void* int int int)
      void))
  (define dcSubStruct
    (foreign-procedure "dcSubStruct" (void* int int int) void))
  (define dcCloseStruct
    (foreign-procedure "dcCloseStruct" (void*) void))
  (define dcStructSize
    (foreign-procedure "dcStructSize" (void*) int))
  (define dcStructAlignment
    (foreign-procedure "dcStructAlignment" (void*) int))
  (define dcFreeStruct
    (foreign-procedure "dcFreeStruct" (void*) void))
  (define ffi-set-char
    (foreign-procedure "ffi_set_char" (void* char) void))
  (define ffi-set-int
    (foreign-procedure "ffi_set_int" (void* int) void))
  (define ffi-set-short
    (foreign-procedure "ffi_set_short" (void* short) void))
  (define ffi-set-long
    (foreign-procedure "ffi_set_long" (void* integer-64) void))
  (define ffi-set-uchar
    (foreign-procedure "ffi_set_uchar" (void* char) void))
  (define ffi-set-uint
    (foreign-procedure "ffi_set_uint"
      (void* unsigned-int)
      void))
  (define ffi-set-ushort
    (foreign-procedure "ffi_set_ushort"
      (void* unsigned-short)
      void))
  (define ffi-set-ulong
    (foreign-procedure "ffi_set_ulong"
      (void* unsigned-long)
      void))
  (define ffi-set-float
    (foreign-procedure "ffi_set_float" (void* float) void))
  (define ffi-set-double
    (foreign-procedure "ffi_set_double" (void* double) void))
  (define ffi-set-longdouble
    (foreign-procedure "ffi_set_longdouble"
      (void* double)
      void))
  (define ffi-set-pointer
    (foreign-procedure "ffi_set_pointer"
      (void* integer-64)
      void))
  (define ffi-set-string
    (foreign-procedure "ffi_set_string" (void* string) void))
  (define ffi-copy-mem
    (foreign-procedure "ffi_copy_mem"
      (void* void* integer-64)
      void))
  (define ffi-get-char
    (foreign-procedure "ffi_get_char" (void*) char))
  (define ffi-get-short
    (foreign-procedure "ffi_get_short" (void*) short))
  (define ffi-get-int
    (foreign-procedure "ffi_get_int" (void*) int))
  (define ffi-get-long
    (foreign-procedure "ffi_get_long" (void*) long))
  (define ffi-get-uchar
    (foreign-procedure "ffi_get_uchar" (void*) unsigned-8))
  (define ffi-get-ushort
    (foreign-procedure "ffi_get_ushort" (void*) unsigned-short))
  (define ffi-get-uint
    (foreign-procedure "ffi_get_uint" (void*) unsigned-int))
  (define ffi-get-ulong
    (foreign-procedure "ffi_get_ulong" (void*) unsigned-64))
  (define ffi-get-float
    (foreign-procedure "ffi_get_float" (void*) float))
  (define ffi-get-double
    (foreign-procedure "ffi_get_double" (void*) double))
  (define ffi-get-string
    (foreign-procedure "ffi_get_string" (void*) string))
  (define ffi-get-pointer
    (foreign-procedure "ffi_get_pointer" (void*) void*))
  (define ffi-get-string-pointer
    (foreign-procedure "ffi_get_string_pointer" (string) void*))
  (define ffi-get-string-offset
    (foreign-procedure "ffi_get_string_offset"
      (string int)
      string))
  (define ffi-get-pointer-offset
    (foreign-procedure "ffi_get_pointer_offset"
      (void* int)
      void*))
  (define ffi-string-pointer
    (foreign-procedure "ffi_string_pointer" (string) void*))
  (define ffi-string
    (foreign-procedure "ffi_string" (void*) string))
  (define ffi-alloc
    (foreign-procedure "ffi_alloc" (int) void*))
  (define ffi-free
    (foreign-procedure "ffi_free" (void*) void))
  (define ffi-set
    (foreign-procedure "ffi_set" (void* int int) void))
  (define print-string
    (foreign-procedure "print_string" (string) int))
  (define print-ptr
    (foreign-procedure "print_ptr" (void*) int))
  (define print-array
    (foreign-procedure "printf_array" (void*) int))
  (define dffi-alloc ffi-alloc)
  (define dffi-free ffi-free)
  (define dffi-set ffi-set)
  (define dffi-set-char ffi-set-char)
  (define dffi-set-int ffi-set-int)
  (define dffi-set-float ffi-set-float)
  (define dffi-set-double ffi-set-double)
  (define dffi-get-char ffi-get-char)
  (define dffi-get-int ffi-get-int)
  (define dffi-get-long ffi-get-long)
  (define dffi-get-uchar ffi-get-uchar)
  (define dffi-get-uint ffi-get-uint)
  (define dffi-get-ulong ffi-get-ulong)
  (define dffi-get-float ffi-get-float)
  (define dffi-get-double ffi-get-double)
  (define dffi-get-pointer ffi-get-pointer)
  (define dffi-get-string ffi-get-string)
  (define dffi-get-string-pointer ffi-get-string-pointer)
  (define dffi-get-string-offset
    (case-lambda
      [(addr) (ffi-get-string-offset addr 0)]
      [(addr offset) (ffi-get-string-offset addr offset)]))
  (define dffi-get-pointer-offset
    (case-lambda
      [(addr) (ffi-get-pointer-offset addr 0)]
      [(addr offset) (ffi-get-pointer-offset addr offset)]))
  (define dffi-set-pointer ffi-set-pointer)
  (define dffi-set-string ffi-set-string)
  (define dffi-string-pointer ffi-string-pointer)
  (define dffi-string ffi-string)
  (define dffi-enable-log #f)
  (define dffi-enable-thread #f)
  (define (dffi-log t) (set! dffi-enable-log t))
  (define (dffi-size l)
    (if (pair? l)
        (apply + l)
        (case l
          [(char uchar) 8]
          [(short ushort) 16]
          [(int uint) 32]
          [(ulong long) 64]
          [(float) 32]
          [(double void* string) 64]
          [(float*) 32]
          [(void) 0])))
  (define-syntax def-function-callback
    (lambda (x)
      (syntax-case x ()
        [(_ name args ret)
         #'(define name
             (lambda (p)
               (let ([code (foreign-callable p args ret)])
                 (lock-object code)
                 (foreign-callable-entry-point code))))])))
  (define-syntax try
    (syntax-rules (catch)
      [(_ body (catch catcher))
       (call-with-current-continuation
         (lambda (exit)
           (with-exception-handler
             (lambda (condition) (catcher condition) (exit condition))
             (lambda () body))))]))
  (define test-call (foreign-procedure "test_call" () void*))
  (define get-struct
    (foreign-procedure "get_struct" () void*))
  (define call-struct
    (foreign-procedure "call_struct" (void* void* void*) void*))
  (define (get-struct-field struct-val)
    (let ([ds (dcNewStruct
                (length (struct-ref struct-val 1))
                DEFAULT_ALIGNMENT)])
      (printf "ds=>~a\n" ds)
      (let loop ([i 0]
                 [e (struct-ref struct-val 0)]
                 [offset 0]
                 [s (struct-ref struct-val 1)]
                 [aligned (get-aligned (struct-ref struct-val 1))])
        (if (pair? e)
            (let ([v ((record-accessor (record-rtd struct-val) (+ i 2))
                       struct-val)]
                  [ss (car s)])
              (printf " dc field ~a\n" (car e))
              (case (car e)
                [(char)
                 (dcStructField ds DC_SIGCHAR_CHAR DEFAULT_ALIGNMENT 1)]
                [(double)
                 (dcStructField ds DC_SIGCHAR_DOUBLE DEFAULT_ALIGNMENT 1)]
                [(int)
                 (dcStructField ds DC_SIGCHAR_INT DEFAULT_ALIGNMENT 1)]
                [(int64 long)
                 (dcStructField
                   ds
                   DC_SIGCHAR_LONGLONG
                   DEFAULT_ALIGNMENT
                   1)]
                [(float)
                 (dcStructField ds DC_SIGCHAR_FLOAT DEFAULT_ALIGNMENT 1)]
                [(float*)
                 (dcStructField ds DC_SIGCHAR_POINTER DEFAULT_ALIGNMENT 1)]
                [(string)
                 (dcStructField ds DC_SIGCHAR_STRING DEFAULT_ALIGNMENT 1)]
                [(void*)
                 (dcStructField ds DC_SIGCHAR_POINTER DEFAULT_ALIGNMENT 1)]
                [else (printf "    ===else ~a ~a\n" (car e) (car s))])
              (loop (+ i 1) (cdr e) offset (cdr s) (cdr aligned)))))
      (dcCloseStruct ds)
      ds))
  (define (dffi-call name funptr args ret values)
    (try (let ([alloc 0] [vm (dcNewCallVM 10240)])
           (dcReset vm)
           (let loop ([arg args] [value values] [i 0])
             (if (pair? value)
                 (begin
                   (case (car arg)
                     [(char) (dcArgChar vm (car value))]
                     [(ushort) (dcArgShort vm (car value))]
                     [(short) (dcArgShort vm (car value))]
                     [(uint) (dcArgInt vm (car value))]
                     [(int) (dcArgInt vm (car value))]
                     [(int64 long) (dcArgLong vm (car value))]
                     [(float) (dcArgFloat vm (car value))]
                     [(double) (dcArgDouble vm (car value))]
                     [(void) 1]
                     [(string) (dcArgString vm (car value))]
                     [(void*)
                      (if (string? (car value))
                          (dcArgString vm (car value))
                          (dcArgPointer vm (car value)))]
                     [else
                      (printf
                        " %%%else type=~a size=~a \n"
                        (car arg)
                        (dffi-size (struct-ref (car value) 1)))
                      (let ([s (get-struct-field (car value))])
                        (set! s (get-struct))
                        (printf "s=>~a\n" s)
                        (set! alloc
                          (ffi-alloc
                            (dffi-size (struct-ref (car value) 1))))
                        (lisp2struct (car value) alloc)
                        (dcArgStruct vm s alloc))])
                   (loop (cdr arg) (cdr value) (+ i 1)))))
           (let ([ret-value (case ret
                              [(char) (dcCallChar vm funptr)]
                              [(ushort) (dcCallShort vm funptr)]
                              [(short) (dcCallShort vm funptr)]
                              [(uint) (dcCallInt vm funptr)]
                              [(int) (dcCallInt vm funptr)]
                              [(int64 long) (dcCallLong vm funptr)]
                              [(float) (dcCallFloat vm funptr)]
                              [(double) (dcCallDouble vm funptr)]
                              [(void) (dcCallVoid vm funptr)]
                              [(string) (dcCallString vm funptr)]
                              [(void*) (dcCallPointer vm funptr)]
                              [else
                               (let ([pret 0]
                                     [ret-struct-val 0]
                                     [vret 0]
                                     [ret-type-s 0]
                                     [s 0])
                                 (set! ret-struct-val
                                   ((top-level-value
                                      (string->symbol
                                        (format "make-~a" ret)))))
                                 (set! ret-type-s
                                   (struct-ref ret-struct-val 1))
                                 (set! s (get-struct-field ret-struct-val))
                                 (set! s (get-struct))
                                 (set! pret
                                   (ffi-alloc (dffi-size ret-type-s)))
                                 (printf
                                   "  ###else type=~a ~a ~a\n"
                                   ret
                                   ret-struct-val
                                   ret-type-s)
                                 (printf "--->~d pret=>~a\n" s pret)
                                 (call-struct vm funptr s)
                                 (printf "pret=>~d\n" pret)
                                 (set! vret
                                   (struct2lisp pret ret-struct-val))
                                 (dcFreeStruct s)
                                 vret)])])
             (dcFree vm)
             (if dffi-enable-log
                 (printf "call ~a ~a ~a ~a ~a\ncall ret=~a\n" name funptr
                   args ret values ret-value))
             ret-value))
         (catch
           (lambda (x)
             (printf "Call [~a ~a ~a ~a ~a] ~a\n" name funptr args ret values
               (with-output-to-string (lambda () (display-condition x))))
             '()))))
  (define-syntax load-librarys
    (lambda (x)
      (import (utils libutil))
      (syntax-case x ()
        [(_ . args)
         #`(define lib
             #,(let loop ([arg (syntax->datum #'args)])
                 (if (pair? arg)
                     (begin
                       (let loop2 ([ext (get-dynamic-ext)])
                         (if (pair? ext)
                             (begin
                               (load-lib
                                 (string-append (car arg) (car ext)))
                               (loop2 (cdr ext))))
                         (loop (cdr arg))))
                     #'1)))])))
  (define-syntax def-function
    (lambda (x)
      (import (dffi dynload) (utils libutil))
      (syntax-case x ()
        [(_ name sym args ret)
         (with-syntax ([libs (get-loaded-libs-list)])
           #`(define name
               (lambda values
                 (dffi-call sym
                   #,((lambda (libs s)
                        (let loop ([lib libs])
                          (if (pair? lib)
                              (let ([ret (dlFindSymbol
                                           (dlLoadLibrary (car lib))
                                           (syntax->datum s))])
                                (if (> ret 0) ret (loop (cdr lib))))
                              #'0)))
                       #'libs
                       #'sym)
                   'args 'ret values))))])))
  (define-syntax def-struct
    (lambda (x)
      (syntax-case x ()
        [(_ name (v t s) ...)
         #`(define-record-type name
             (fields
               (mutable type)
               (mutable size)
               #,@(map (lambda (vv) #`(mutable #,vv)) #'(v ...)))
             (protocol
               (lambda (new)
                 (case-lambda
                   [()
                    (new '(t ...)
                         '#,@(list
                               (map (lambda (ss)
                                      (case (syntax->datum ss)
                                        [(number?) (syntax->datum ss)]
                                        [else (eval (syntax->datum ss))]))
                                    #'(s ...)))
                         #,@(map (lambda (vv) #`'()) #'(v ...)))]
                   [(v ...)
                    (new '(t ...)
                         '#,@(list
                               (map (lambda (ss)
                                      (case (syntax->datum ss)
                                        [(number?) (syntax->datum ss)]
                                        [else (eval (syntax->datum ss))]))
                                    #'(s ...)))
                         v
                         ...)]))))]
        [(_ name (v t) ...)
         #`(define-record-type name
             (fields
               (mutable type)
               (mutable size)
               #,@(map (lambda (vv) #`(mutable #,vv)) #'(v ...)))
             (protocol
               (lambda (new)
                 (case-lambda
                   [()
                    (new '(t ...)
                         '#,@(list
                               (map (lambda (ss)
                                      (case (syntax->datum ss)
                                        [(long ulong float double void*)
                                         64]
                                        [(int uint) 32]
                                        [(short ushort) 16]
                                        [(char uchar) 8]))
                                    #'(t ...)))
                         #,@(map (lambda (vv) #`'()) #'(v ...)))]
                   [(v ...)
                    (new '(t ...)
                         '#,@(list
                               (map (lambda (ss)
                                      (case (syntax->datum ss)
                                        [(long ulong float double void*)
                                         64]
                                        [(int uint) 32]
                                        [(short ushort) 16]
                                        [(char uchar) 8]))
                                    #'(t ...)))
                         v
                         ...)]))))])))
  (define (% x y) (- x (* y (quotient x y))))
  (define (get-padding align offset)
    (% (- align (% offset align)) align))
  (define (get-aligned l)
    (let ([pack 32] [r '()])
      (let loop ([e l] [offset 0])
        (if (pair? e)
            (let* ([align (car e)]
                   [padding (get-padding align offset)]
                   [aligned (+ offset padding)])
              (set! r (append r (list aligned)))
              (set! offset (+ offset align padding))
              (loop (cdr e) offset))
            (append
              r
              (list (+ offset (get-padding (apply max l) offset))))))))
  (define (lastt lst)
    (if (= (length lst) 1) (car lst) (lastt (cdr lst))))
  (define struct-size
    (lambda (x) (/ (lastt (get-aligned (struct-ref x 1))) 8)))
  (define (struct-ref s index)
    ((record-accessor (record-rtd s) index) s))
  (define (struct-set! s index val)
    ((record-mutator (record-rtd s) index) s val))
  (define (struct2lisp addr ret-struct-val)
    (let loop ([i 0]
               [offset 0]
               [t (struct-ref ret-struct-val 0)]
               [s (struct-ref ret-struct-val 1)]
               [aligned (get-aligned (struct-ref ret-struct-val 1))])
      (if (pair? t)
          (let ([struct-val 0])
            (set! offset (/ (car aligned) 8))
            (case (car t)
              [(char)
               (set! struct-val (ffi-get-char (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(short)
               (set! struct-val (ffi-get-short (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(ushort)
               (set! struct-val (ffi-get-ushort (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(double)
               (set! struct-val (ffi-get-double (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(uint)
               (set! struct-val (ffi-get-uint (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(int)
               (set! struct-val (ffi-get-int (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(int64 long)
               (set! struct-val (ffi-get-long (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(float)
               (set! struct-val (ffi-get-float (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [(void* float*)
               (set! struct-val (ffi-get-pointer (+ addr offset)))
               (set! offset (+ offset (/ (car s) 8)))]
              [else
               (struct-set!
                 ret-struct-val
                 (+ i 2)
                 ((top-level-value
                    (string->symbol (format "make-~a" (car t))))))
               (set! struct-val
                 (struct2lisp
                   (+ addr offset)
                   (struct-ref ret-struct-val (+ i 2))))
               (set! offset (+ offset (/ (car s) 8)))])
            (struct-set! ret-struct-val (+ i 2) struct-val)
            (loop (+ i 1) offset (cdr t) (cdr s) (cdr aligned)))
          (begin ret-struct-val))))
  (define (lisp2struct struct-val addr)
    (let loop ([i 0]
               [e (struct-ref struct-val 0)]
               [offset 0]
               [s (struct-ref struct-val 1)]
               [aligned (get-aligned (struct-ref struct-val 1))])
      (if (pair? e)
          (let ([v ((record-accessor (record-rtd struct-val) (+ i 2))
                     struct-val)]
                [ss (car s)])
            (set! offset (/ (car aligned) 8))
            (case (car e)
              [(char) (ffi-set-char (+ offset addr) v)]
              [(double) (ffi-set-double (+ offset addr) v)]
              [(int) (ffi-set-int (+ offset addr) v)]
              [(int64 long) (ffi-set-long (+ offset addr) v)]
              [(float) (ffi-set-float (+ offset addr) v)]
              [(float*) (ffi-set-pointer (+ offset addr) v)]
              [(void*) (ffi-set-pointer (+ offset addr) v)]
              [else (lisp2struct v (+ offset addr))])
            (loop (+ i 1) (cdr e) offset (cdr s) (cdr aligned))))
      addr)))

