;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (cffi cffi)
  (export ffi-prep-cif ffi-prep-cif-var ffi-call load-lib
   load-libs cffi-set-char cffi-set-int cffi-set-float
   cffi-set-double cffi-set-long cffi-get-addr cffi-get-uchar
   cffi-get-uint cffi-get-ulong cffi-get-char cffi-get-int
   cffi-get-float cffi-get-long cffi-get-double
   cffi-get-pointer cffi-get-string cffi-get-string-offset
   cffi-set-pointer cffi-set-string cffi-get-pointer-offset
   cffi-get-string-pointer cffi-string-pointer cffi-string
   cffi-sym print-ptr print-string cffi-set load-librarys
   def-function def-function-callback def-struct struct-size
   lisp2struct struct2lisp cffi-alloc cffi-free cffi-log
   cffi-thread)
  (import (scheme) (utils libutil) (utils macro))
  (define FFI_DEFAULT_ABI 2)
  (define FFI_TYPE_VOID 0)
  (define FFI_TYPE_INT 1)
  (define FFI_TYPE_FLOAT 2)
  (define FFI_TYPE_DOUBLE 3)
  (define FFI_TYPE_LONGDOUBLE 4)
  (define FFI_TYPE_UINT8 5)
  (define FFI_TYPE_SINT8 6)
  (define FFI_TYPE_UINT16 7)
  (define FFI_TYPE_SINT16 8)
  (define FFI_TYPE_UINT32 9)
  (define FFI_TYPE_SINT32 10)
  (define FFI_TYPE_UINT64 11)
  (define FFI_TYPE_SINT64 12)
  (define FFI_TYPE_STRUCT 13)
  (define FFI_TYPE_POINTER 14)
  (define FFI_TYPE_COMPLEX 15)
  (define FFI_OK 0)
  (define FFI_BAD_TYPEDEF 1)
  (define FFI_BAD_ABI 2)
  (define RTLD_LAZY 1)
  (define RTLD_NOW 2)
  (define RTLD_GLOBAL 256)
  (define cffi-enable-log #f)
  (define cffi-enable-thread #f)
  (define (cffi-log t) (set! cffi-enable-log t))
  (define (cffi-thread t) (set! cffi-enable-thread t))
  (define lib-name
    (case (machine-type)
      [(arm32le) "libcffi.so"]
      [(a6nt i3nt ta6nt ti3nt) "libcffi.dll"]
      [(a6osx ta6osx i3osx ti3osx) "libcffi.so"]
      [(a6le i3le ta6le ti3le) "libcffi.so"]))
  (define lib (load-lib lib-name))
  (define ffi-prep-cif
    (foreign-procedure "ffi_prep_cif"
      (void* int int void* void*)
      int))
  (define ffi-prep-cif-var
    (foreign-procedure "ffi_prep_cif_var"
      (void* int int int void* void*)
      int))
  (define ffi-call
    (foreign-procedure "ffi_call"
      (void* void* void* void*)
      void))
  (define $ffi-cif-alloc
    (foreign-procedure "ffi_cif_alloc" () void*))
  (define $ffi-cif-free
    (foreign-procedure "ffi_cif_free" (void*) void))
  (define $ffi-types-alloc
    (foreign-procedure "ffi_types_alloc" (int) void*))
  (define $ffi-types-free
    (foreign-procedure "ffi_types_free" (void*) void))
  (define $ffi-values-alloc
    (foreign-procedure "ffi_values_alloc" (int) void*))
  (define $ffi-values-free
    (foreign-procedure "ffi_values_free" (void*) void))
  (define $ffi-alloc
    (foreign-procedure "ffi_alloc" (int) void*))
  (define $ffi-free
    (foreign-procedure "ffi_free" (void*) void))
  (define (ffi-cif-alloc $ffi-alloc-list)
    (let ([m ($ffi-cif-alloc)])
      (set-box!
        $ffi-alloc-list
        (append! (unbox $ffi-alloc-list) (list m)))
      m))
  (define (ffi-types-alloc $ffi-alloc-list size)
    (let ([m ($ffi-types-alloc size)])
      (set-box!
        $ffi-alloc-list
        (append! (unbox $ffi-alloc-list) (list m)))
      m))
  (define (ffi-values-alloc $ffi-alloc-list size)
    (let ([m ($ffi-values-alloc size)])
      (set-box!
        $ffi-alloc-list
        (append! (unbox $ffi-alloc-list) (list m)))
      m))
  (define (ffi-alloc $ffi-alloc-list size)
    (let ([m ($ffi-alloc size)])
      (set-box!
        $ffi-alloc-list
        (append (unbox $ffi-alloc-list) (list m)))
      m))
  (define (ffi-free-all $ffi-alloc-list)
    (let loop ([l (unbox $ffi-alloc-list)])
      (if (pair? l) (begin ($ffi-free (car l)) (loop (cdr l)))))
    (set! $ffi-alloc-list '()))
  (define ffi-values-set
    (foreign-procedure "ffi_values_set" (void* int void*) void))
  (define ffi-types-set
    (foreign-procedure "ffi_types_set" (void* int void*) void))
  (define ffi-type-void-ptr
    (foreign-procedure "ffi_type_void_ptr" () void*))
  (define ffi-type-pointer-ptr
    (foreign-procedure "ffi_type_pointer_ptr" () void*))
  (define ffi-type-sint8-ptr
    (foreign-procedure "ffi_type_sint8_ptr" () void*))
  (define ffi-type-sint16-ptr
    (foreign-procedure "ffi_type_sint16_ptr" () void*))
  (define ffi-type-sint-ptr
    (foreign-procedure "ffi_type_sint32_ptr" () void*))
  (define ffi-type-sint64-ptr
    (foreign-procedure "ffi_type_sint64_ptr" () void*))
  (define ffi-type-uint8-ptr
    (foreign-procedure "ffi_type_uint8_ptr" () void*))
  (define ffi-type-uint16-ptr
    (foreign-procedure "ffi_type_uint16_ptr" () void*))
  (define ffi-type-uint-ptr
    (foreign-procedure "ffi_type_uint32_ptr" () void*))
  (define ffi-type-uint64-ptr
    (foreign-procedure "ffi_type_uint64_ptr" () void*))
  (define ffi-type-float-ptr
    (foreign-procedure "ffi_type_float_ptr" () void*))
  (define ffi-type-double-ptr
    (foreign-procedure "ffi_type_double_ptr" () void*))
  (define ffi-type-longdouble-ptr
    (foreign-procedure "ffi_type_longdouble_ptr" () void*))
  (define ffi-type-void (ffi-type-void-ptr))
  (define ffi-type-pointer (ffi-type-pointer-ptr))
  (define ffi-type-sint8 (ffi-type-sint8-ptr))
  (define ffi-type-uint8 (ffi-type-uint8-ptr))
  (define ffi-type-sint16 (ffi-type-sint16-ptr))
  (define ffi-type-uint16 (ffi-type-uint16-ptr))
  (define ffi-type-sint (ffi-type-sint-ptr))
  (define ffi-type-uint (ffi-type-uint-ptr))
  (define ffi-type-sint64 (ffi-type-sint64-ptr))
  (define ffi-type-uint64 (ffi-type-uint64-ptr))
  (define ffi-type-float (ffi-type-float-ptr))
  (define ffi-type-double (ffi-type-double-ptr))
  (define ffi-type-longdouble (ffi-type-longdouble-ptr))
  (define ffi-get-addr
    (foreign-procedure "ffi_get_addr" (void* integer-32) void*))
  (define ffi-set-char
    (foreign-procedure "ffi_set_char" (void* char) void))
  (define ffi-set-int
    (foreign-procedure "ffi_set_int" (void* int) void))
  (define ffi-set-short
    (foreign-procedure "ffi_set_short" (void* short) void))
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
    (case (machine-type)
      [(arm32le)
       (foreign-procedure "ffi_set_pointer"
         (void* integer-32)
         void)]
      [else
       (foreign-procedure "ffi_set_pointer"
         (void* integer-64)
         void)]))
  (define ffi-set-long
    (case (machine-type)
      [(arm32le)
       (foreign-procedure "ffi_set_long" (void* integer-32) void)]
      [else
       (foreign-procedure "ffi_set_long"
         (void* integer-64)
         void)]))
  (define ffi-copy-mem
    (case (machine-type)
      [(arm32le)
       (foreign-procedure "ffi_copy_mem"
         (void* void* integer-32)
         void)]
      [else
       (foreign-procedure "ffi_copy_mem"
         (void* void* integer-64)
         void)]))
  (define ffi-get-ulong
    (case (machine-type)
      [(arm32le)
       (foreign-procedure "ffi_get_ulong" (void*) unsigned-32)]
      [else
       (foreign-procedure "ffi_get_ulong" (void*) unsigned-64)]))
  (define ffi-set-string
    (foreign-procedure "ffi_set_string" (void* string) void))
  (define ffi-init-struct
    (foreign-procedure "ffi_init_struct"
      (void* int int int void*)
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
  (define ffi-dlsym
    (foreign-procedure "ffi_dlsym" (void* string) void*))
  (define ffi-dlopen
    (foreign-procedure "ffi_dlopen" (string int) void*))
  (define ffi-dlerror
    (foreign-procedure "ffi_dlerror" () string))
  (define ffi-close
    (foreign-procedure "ffi_dlclose" (void*) int))
  (define $ffi-set
    (foreign-procedure "ffi_set" (void* int int) void))
  (define print-string
    (foreign-procedure "print_string" (string) int))
  (define print-ptr
    (foreign-procedure "print_ptr" (void*) int))
  (define print-array
    (foreign-procedure "printf_array" (void*) int))
  (define cffi-alloc $ffi-alloc)
  (define cffi-free $ffi-free)
  (define cffi-set $ffi-set)
  (define cffi-get-addr ffi-get-addr)
  (define cffi-set-char ffi-set-char)
  (define cffi-set-int ffi-set-int)
  (define cffi-set-float ffi-set-float)
  (define cffi-set-double ffi-set-double)
  (define cffi-set-long ffi-set-long)
  (define cffi-get-char ffi-get-char)
  (define cffi-get-int ffi-get-int)
  (define cffi-get-long ffi-get-long)
  (define cffi-get-uchar ffi-get-uchar)
  (define cffi-get-uint ffi-get-uint)
  (define cffi-get-ulong ffi-get-ulong)
  (define cffi-get-float ffi-get-float)
  (define cffi-get-double ffi-get-double)
  (define cffi-get-pointer ffi-get-pointer)
  (define cffi-get-string ffi-get-string)
  (define cffi-get-string-pointer ffi-get-string-pointer)
  (define cffi-get-string-offset
    (case-lambda
      [(addr) (ffi-get-string-offset addr 0)]
      [(addr offset) (ffi-get-string-offset addr offset)]))
  (define cffi-get-pointer-offset
    (case-lambda
      [(addr) (ffi-get-pointer-offset addr 0)]
      [(addr offset) (ffi-get-pointer-offset addr offset)]))
  (define cffi-set-pointer ffi-set-pointer)
  (define cffi-set-string ffi-set-string)
  (define cffi-string-pointer ffi-string-pointer)
  (define cffi-string ffi-string)
  (define handlers (list))
  (define precedures '())
  (define handler '())
  (define loaded-libs (make-hashtable equal-hash equal?))
  (define (cffi-load-lib-op name)
    (let loop ([libs (map car (library-directories))])
      (if (pair? libs)
          (begin
            (if (and (file-exists? (string-append (car libs) "/" name))
                     (eq? ""
                          (hashtable-ref
                            loaded-libs
                            (string-append (car libs) "/" name)
                            "")))
                (begin
                  (if cffi-enable-log
                      (display
                        (format
                          "cffi-load-lib ~a\n"
                          (string-append (car libs) "/" name))))
                  (cffi-open-lib (string-append (car libs) "/" name))
                  (hashtable-set!
                    loaded-libs
                    (string-append (car libs) "/" name)
                    name)))
            (loop (cdr libs))))))
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
  (define (cffi-open-lib path)
    (set! handler (ffi-dlopen path RTLD_LAZY))
    (set! handlers (append handlers (list handler)))
    handler)
  (define (cffi-sym name)
    (let ([s (ffi-dlsym handler name)])
      (if (= 0 s)
          (let loop ([h handlers])
            (if (pair? h)
                (let ([sym (ffi-dlsym (car h) name)])
                  (if (= sym 0) (loop (cdr h)) sym))
                0))
          s)))
  (define-syntax def-function-callback
    (lambda (x)
      (syntax-case x ()
        [(_ name args ret)
         #'(define name
             (lambda (p)
               (let ([code (foreign-callable p args ret)])
                 (lock-object code)
                 (foreign-callable-entry-point code))))])))
  (define-syntax def-function
    (lambda (x)
      (define lib-name
        (case (machine-type)
          [(arm32le) "libcffi.so"]
          [(a6nt i3nt ta6nt ti3nt) "libcffi.dll"]
          [(a6osx ta6osx i3osx ti3osx) "libcffi.so"]
          [(a6le i3le ta6le ti3le) "libcffi.so"]))
      (define lib (load-lib lib-name))
      (define ffi-dlsym
        (foreign-procedure "ffi_dlsym" (void* string) void*))
      (define ffi-dlopen
        (foreign-procedure "ffi_dlopen" (string int) void*))
      (define RTLD_LAZY 1)
      (syntax-case x ()
        [(_ name sym args ret)
         (with-syntax ([libs (get-loaded-libs-list)])
           #`(define name
               (lambda values
                 (cffi-call sym
                   #,((lambda (libs s)
                        (let loop ([lib libs])
                          (if (pair? lib)
                              (let ([ret (ffi-dlsym
                                           (ffi-dlopen (car lib) RTLD_LAZY)
                                           (syntax->datum s))])
                                (if (> ret 0) ret (loop (cdr lib))))
                              #'0)))
                       #'libs
                       #'sym)
                   'args 'ret values))))])))
  (define (cffi-size l)
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
  (define (cffi-init) #t)
  (define (create-carg-type alloc-list arg-type)
    (let ([carg-type (ffi-types-alloc
                       alloc-list
                       (length arg-type))])
      (let loop ([type arg-type] [i 0])
        (if (pair? type)
            (begin
              (ffi-types-set
                carg-type
                i
                (create-cret-type alloc-list (car type)))
              (loop (cdr type) (+ i 1)))))
      carg-type))
  (define (process-struct alloc-list ret-type)
    (let ([ret-struct-val '()]
          [typelist '()]
          [typeelement '()]
          [alloc 0])
      (set! alloc (ffi-alloc alloc-list (+ 64 16 16 64)))
      (set! ret-struct-val
        ((top-level-value
           (string->symbol (format "make-~a" ret-type)))))
      (set! typelist (struct-ref ret-struct-val 0))
      (set! typeelement
        (ffi-alloc alloc-list (* 64 (+ (length typelist) 1))))
      (ffi-init-struct alloc 0 0 FFI_TYPE_STRUCT typeelement)
      (let loop ([type typelist] [i 0])
        (if (pair? type)
            (begin
              (case (car type)
                [(char) (ffi-types-set typeelement i ffi-type-sint8)]
                [(uchar) (ffi-types-set typeelement i ffi-type-uint8)]
                [(ushort) (ffi-types-set typeelement i ffi-type-uint16)]
                [(short) (ffi-types-set typeelement i ffi-type-sint16)]
                [(uint) (ffi-types-set typeelement i ffi-type-uint)]
                [(int) (ffi-types-set typeelement i ffi-type-sint)]
                [(ulong) (ffi-types-set typeelement i ffi-type-uint64)]
                [(long) (ffi-types-set typeelement i ffi-type-sint64)]
                [(int64 long)
                 (ffi-types-set typeelement i ffi-type-sint64)]
                [(float) (ffi-types-set typeelement i ffi-type-float)]
                [(double) (ffi-types-set typeelement i ffi-type-double)]
                [(void* float*)
                 (ffi-types-set typeelement i ffi-type-pointer)]
                [(string) (ffi-types-set typeelement i ffi-type-pointer)]
                [else
                 (ffi-types-set
                   typeelement
                   i
                   (process-struct alloc-list (car type)))])
              (loop (cdr type) (+ i 1)))))
      (ffi-types-set typeelement (length typelist) 0)
      alloc))
  (define (create-cret-type alloc-list ret-type)
    (let ([alloc 0]
          [ret-struct-val 0]
          [typeelement 0]
          [typelist '()])
      (case ret-type
        [(short) ffi-type-sint16]
        [(ushort) ffi-type-uint16]
        [(uint) ffi-type-uint]
        [(int) ffi-type-sint]
        [(int64 long) ffi-type-sint64]
        [(float) ffi-type-float]
        [(double) ffi-type-double]
        [(string) ffi-type-pointer]
        [(void* float*) ffi-type-pointer]
        [(void) ffi-type-void]
        [else (process-struct alloc-list ret-type)])))
  (define (create-cret alloc-list ret-type)
    (let ([ret-fun (lambda (x) x)]
          [ret-type-s ret-type]
          [ret-struct-val '()])
      (set! ret-fun
        (case ret-type
          [(short) ffi-get-short]
          [(ushort) ffi-get-ushort]
          [(uint) ffi-get-uint]
          [(int) ffi-get-int]
          [(int64 long) ffi-get-long]
          [(float) ffi-get-float]
          [(double) ffi-get-double]
          [(string) ffi-get-string]
          [(void* float*) ffi-get-pointer]
          [(void) '()]
          [else
           (set! ret-struct-val
             ((top-level-value
                (string->symbol (format "make-~a" ret-type)))))
           (set! ret-type-s (struct-ref ret-struct-val 1))
           (lambda (addr) (struct2lisp addr ret-struct-val))]))
      (list
        (ffi-alloc alloc-list (cffi-size ret-type-s))
        ret-fun)))
  (define (create-cargs alloc-list arg-type args carg-type)
    (let ([cargs (ffi-values-alloc alloc-list (length args))]
          [alloc 0])
      (let loop ([arg args] [type arg-type] [i 0])
        (if (pair? arg)
            (begin
              (case (car type)
                [(ushort)
                 (set! alloc (ffi-alloc alloc-list 2))
                 (ffi-set-ushort alloc (car arg))
                 (ffi-values-set cargs i alloc)]
                [(short)
                 (set! alloc (ffi-alloc alloc-list 2))
                 (ffi-set-short alloc (car arg))
                 (ffi-values-set cargs i alloc)]
                [(uint)
                 (set! alloc (ffi-alloc alloc-list 4))
                 (ffi-set-uint alloc (car arg))
                 (ffi-values-set cargs i alloc)]
                [(int)
                 (set! alloc (ffi-alloc alloc-list 4))
                 (ffi-set-int alloc (car arg))
                 (ffi-values-set cargs i alloc)]
                [(int64 long)
                 (set! alloc (ffi-alloc alloc-list 8))
                 (ffi-set-long alloc (car arg))
                 (ffi-values-set cargs i alloc)]
                [(float)
                 (set! alloc (ffi-alloc alloc-list 4))
                 (ffi-set-float alloc (+ 0.0 (car arg)))
                 (ffi-values-set cargs i alloc)]
                [(double)
                 (set! alloc (ffi-alloc alloc-list 8))
                 (ffi-set-double alloc (+ 0.0 (car arg)))
                 (ffi-values-set cargs i alloc)]
                [(void) (void)]
                [(string)
                 (set! alloc (ffi-alloc alloc-list 8))
                 (if (string? (car arg))
                     (ffi-set-string alloc (car arg))
                     (ffi-set-pointer alloc (car arg)))
                 (ffi-values-set cargs i alloc)]
                [(void*)
                 (set! alloc (ffi-alloc alloc-list 8))
                 (if (string? (car arg))
                     (ffi-set-string alloc (car arg))
                     (ffi-set-pointer alloc (car arg)))
                 (ffi-values-set cargs i alloc)]
                [else
                 (set! alloc
                   (ffi-alloc
                     alloc-list
                     (cffi-size (struct-ref (car arg) 1))))
                 (lisp2struct (car arg) alloc)
                 (ffi-values-set cargs i alloc)])
              (loop (cdr arg) (cdr type) (+ i 1)))))
      cargs))
  (define (cffi-call sym fptr arg-type ret-type args)
    (if cffi-enable-log
        (begin
          (display "\n")
          (display
            (format "cffi-call ~a arg-type=~a ret-type=~a args=~a \n"
              sym arg-type ret-type args))))
    (try (let* ([alloc-list (box '())]
                [carg-type (create-carg-type alloc-list arg-type)]
                [cret-type (create-cret-type alloc-list ret-type)]
                [cargs (create-cargs alloc-list arg-type args carg-type)]
                [cret-info (create-cret alloc-list ret-type)]
                [cret '()]
                [cif (ffi-cif-alloc alloc-list)]
                [call-ret '()]
                [ret-val '()])
           (set! call-ret (cadr cret-info))
           (set! cret (car cret-info))
           (if (= FFI_OK
                  (ffi-prep-cif cif FFI_DEFAULT_ABI (length arg-type)
                    cret-type carg-type))
               (begin
                 (if (> fptr 0)
                     (begin (ffi-call cif fptr cret cargs))
                     (display (format "cannot find symbol ~a\n" sym))))
               (error 'cffi (format "ffi-prep-cif return error\n")))
           (if (procedure? call-ret) (set! ret-val (call-ret cret)))
           (ffi-free-all alloc-list)
           (if cffi-enable-log
               (display (format "ffi-call ret=~x\n" ret-val)))
           ret-val)
         (catch
           (lambda (x)
             (printf "Call [~a ~a ~a ~a] ~a\n" sym arg-type ret-type args
               (with-output-to-string (lambda () (display-condition x))))
             x))))
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

