;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 02/06/17.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (cffi cffi)
  (export
   ffi-prep-cif
   ffi-prep-cif-var
   ffi-call

   cffi-get-int
   cffi-get-float
   cffi-get-long
   cffi-get-double
   cffi-get-pointer
   cffi-get-string
   cffi-get-string-offset
   cffi-set-pointer
   cffi-set-string
   cffi-get-pointer-offset
   cffi-get-string-pointer
   cffi-string-pointer
   cffi-string
   print-ptr
   print-string
   ;; cffi-load-lib
   ;; cffi-open-lib
   ;; cffi-call
   ;; cffi-def
   load-librarys
   def-function
   def-struct
   cffi-alloc
   cffi-free
   cffi-log)
  (import  (scheme) (utils libutil) (utils macro) )

  (define FFI_DEFAULT_ABI  2)

  (define FFI_TYPE_VOID       0)   
  (define FFI_TYPE_INT        1)
  (define FFI_TYPE_FLOAT      2 )   
  (define FFI_TYPE_DOUBLE     3)
  (define FFI_TYPE_LONGDOUBLE 4)
					;(define FFI_TYPE_LONGDOUBLE F)FI_TYPE_DOUBLE
  (define FFI_TYPE_UINT8      5 )  
  (define FFI_TYPE_SINT8      6)
  (define FFI_TYPE_UINT16     7 )
  (define FFI_TYPE_SINT16     8)
  (define FFI_TYPE_UINT32     9)
  (define FFI_TYPE_SINT32     10)
  (define FFI_TYPE_UINT64     11)
  (define FFI_TYPE_SINT64     12)
  (define FFI_TYPE_STRUCT     13)
  (define FFI_TYPE_POINTER    14)
  (define FFI_TYPE_COMPLEX    15)

  (define FFI_OK 0)
  (define FFI_BAD_TYPEDEF 1)
  (define FFI_BAD_ABI 2)


  (define RTLD_LAZY 1)
  (define RTLD_NOW 2)
  (define RTLD_GLOBAL #x00100)
  


  (define cffi-enable-log #f)
  (define (cffi-log t)
    (set! cffi-enable-log t)
    )

  (define $ffi-alloc-list '() )

  (define lib-name
    (case (machine-type)
      ((arm32le) "libffi.so")
      ((a6nt i3nt)  "libffi.dll")
      ((a6osx i3osx)  "libffi.so")
      ((a6le i3le) "libffi.so")))
  (define lib (load-lib lib-name))
  
  (define ffi-prep-cif (foreign-procedure "ffi_prep_cif" (void* int int void* void*) int))
  (define ffi-prep-cif-var (foreign-procedure "ffi_prep_cif_var" (void* int int int void* void*) int))
  (define ffi-call (foreign-procedure "ffi_call" (void* void* void* void*) void))
  ;;(define ffi-get-struct-offsets (foreign-procedure "ffi_get_struct_offsets" (int void* void* ) int))

  (define $ffi-cif-alloc (foreign-procedure "ffi_cif_alloc" () void*))
  (define $ffi-cif-free (foreign-procedure "ffi_cif_free" (void*) void))

  (define $ffi-types-alloc (foreign-procedure "ffi_types_alloc" (int ) void*))
  (define $ffi-types-free (foreign-procedure "ffi_types_free" (void*) void))

  (define $ffi-values-alloc (foreign-procedure "ffi_values_alloc" (int) void*))
  (define $ffi-values-free (foreign-procedure "ffi_values_free" (void*) void))

  (define $ffi-alloc (foreign-procedure "ffi_alloc" (int ) void*))
  (define $ffi-free (foreign-procedure "ffi_free" (void*) void))
  ;;(define $ffi-free (lambda (addr)
  ;;(display (format "addr=~x\n" addr))))

  
  (define (ffi-cif-alloc)
    (let ((m ($ffi-cif-alloc)))
      (set! $ffi-alloc-list(append! $ffi-alloc-list (list m) ))
      m
      )
    )
  (define (ffi-types-alloc size)
    (let ((m ($ffi-types-alloc size)))
      (set! $ffi-alloc-list(append! $ffi-alloc-list (list m) ))
      m
      )
    )
  (define (ffi-values-alloc size)
    (let ((m ($ffi-values-alloc size)))
      (set! $ffi-alloc-list(append! $ffi-alloc-list (list m) ))
      m
      )
    )
  (define (ffi-alloc size)
    (let ((m ($ffi-alloc size)))
      (set! $ffi-alloc-list(append! $ffi-alloc-list (list m) ))
      m
      )
    )

  (define (ffi-free-all)
    ;;(display (format "ffi-free-all=~a\n" (length $ffi-alloc-list)))
    (let loop ((l $ffi-alloc-list))
      (if (pair? l)
	  (begin
	    ;;(display (format "addr=~x\n" (car l)))
	    ($ffi-free (car l) )
	    (loop (cdr l))
	    )
	  )
      )
    (set! $ffi-alloc-list '() )
    )

  (define ffi-values-set (foreign-procedure "ffi_values_set" (void* int void*) void))
  (define ffi-types-set (foreign-procedure "ffi_types_set" (void* int void*) void))


  (define ffi-type-void-ptr (foreign-procedure "ffi_type_void_ptr" () void*))
  (define ffi-type-pointer-ptr (foreign-procedure "ffi_type_pointer_ptr" () void*))
  (define ffi-type-sint8-ptr (foreign-procedure "ffi_type_sint8_ptr" () void*))
  (define ffi-type-sint-ptr (foreign-procedure "ffi_type_sint32_ptr" () void*))
  (define ffi-type-float-ptr (foreign-procedure "ffi_type_float_ptr" () void*))
  (define ffi-type-double-ptr (foreign-procedure "ffi_type_double_ptr" () void*))
  (define ffi-type-longdouble-ptr (foreign-procedure "ffi_type_longdouble_ptr" () void*))

  (define ffi-type-void (ffi-type-void-ptr))
  (define ffi-type-pointer (ffi-type-pointer-ptr))
  (define ffi-type-sint8 (ffi-type-sint8-ptr))
  (define ffi-type-sint (ffi-type-sint-ptr))
  (define ffi-type-float (ffi-type-float-ptr))
  (define ffi-type-double (ffi-type-double-ptr))
  (define ffi-type-longdouble (ffi-type-longdouble-ptr))




  (define test-float (foreign-procedure "test_float" (void* int void* void* void*) void))


  (define ffi-set-char (foreign-procedure "ffi_set_char" (void* int) void))
  (define ffi-set-int (foreign-procedure "ffi_set_int" (void* int) void))
  (define ffi-set-float (foreign-procedure "ffi_set_float" (void* float) void))
  (define ffi-set-double (foreign-procedure "ffi_set_double" (void* double) void))
  (define ffi-set-longdouble (foreign-procedure "ffi_set_longdouble" (void* double ) void))
  (define ffi-set-pointer (foreign-procedure "ffi_set_pointer" (void* integer-64) void))
  (define ffi-set-string (foreign-procedure "ffi_set_string" (void* string) void))
  
  (define ffi-init-struct (foreign-procedure "ffi_init_struct" (void* int int int void*) void))
  (define ffi-copy-mem (foreign-procedure "ffi_copy_mem" (void* void* integer-64) void))




  (define ffi-get-int (foreign-procedure "ffi_get_int" (void* ) int))
  (define ffi-get-long (foreign-procedure "ffi_get_long" (void* ) integer-64))
  (define ffi-get-float (foreign-procedure "ffi_get_float" (void* ) float))
  (define ffi-get-double (foreign-procedure "ffi_get_double" (void* ) double))
  (define ffi-get-string (foreign-procedure "ffi_get_string" (void* ) string ))
  (define ffi-get-pointer (foreign-procedure "ffi_get_pointer" (void* ) void* ))
  (define ffi-get-string-pointer
    (foreign-procedure "ffi_get_string_pointer" (string ) void* ))
  
  (define ffi-get-string-offset
    (foreign-procedure "ffi_get_string_offset" (string int) string))

  (define ffi-get-pointer-offset
    (foreign-procedure "ffi_get_pointer_offset" (void* int) void*))


  (define ffi-string-pointer
      (foreign-procedure "ffi_string_pointer" (string) void*))

  (define ffi-string
    (foreign-procedure "ffi_string" (void*) string))


  
  (define ffi-dlsym (foreign-procedure "ffi_dlsym" (void*  string) void*))
  (define ffi-dlopen (foreign-procedure "ffi_dlopen" (string int ) void*))
  (define ffi-dlerror (foreign-procedure "ffi_dlerror" ( ) string ))
  (define ffi-close (foreign-procedure "ffi_dlclose" (void* ) int))
  
  (define ffi-dl-test (foreign-procedure "ffi_dl_test" ( ) void))


  (define print-string (foreign-procedure "print_string" (string) int ))
  (define print-ptr (foreign-procedure "print_ptr" (void*) int))
  (define print-array (foreign-procedure "printf_array" (void*) int))
  
  ;;cffi define here
  (define cffi-alloc $ffi-alloc)
  (define cffi-free $ffi-free)
  (define cffi-get-int ffi-get-int)
  (define cffi-get-long ffi-get-long)
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
  
  (define cffi-set-pointer  ffi-set-pointer)
  (define cffi-set-string  ffi-set-string)
  (define cffi-string-pointer  ffi-string-pointer)
  (define cffi-string  ffi-string)
  
  (define handler '() )
  (define precedures '() )

  (define loaded-libs (make-hashtable equal-hash equal?))
  
  (define (cffi-load-lib-op name)
    (let  loop ((libs (map car (library-directories)) ) )
      (if (pair? libs )
	  (begin
	    ;;(display (format "   lib##>>>~a ~a\n" (car libs)  (length (cdr libs))))
	    (if (and (file-exists? (string-append (car libs) "/" name)) 
		     (eq? "" (hashtable-ref loaded-libs (string-append (car libs) "/" name) "") ) )
		(begin
		  (if  cffi-enable-log
		       (display (format "cffi-load-lib ~a\n" (string-append (car libs) "/" name)) ))
		  (cffi-open-lib (string-append (car libs) "/" name)) 
		  (hashtable-set! loaded-libs (string-append (car libs) "/" name) name )))
	    (loop (cdr libs)) ))) )


  (define (load-librarys . args)
    (let loop ((arg args))
      (if (pair? arg)
	  (begin
	    (cffi-load-lib-op (car arg))
	    (loop (cdr arg))
	    ))
      )
    )
  
  ;;(name1 name2 name3)
  ;;(type1 type2 type3)

  ;;def-struct
  (define-syntax def-struct
    (lambda (x)
        (syntax-case x ()
          ((_ name (v t s) ... )
               #`(define-record-type name
                  ;(nongenerative)
                  ;(sealed #t)
                  (fields 
                        (mutable type)
                        (mutable size)
                      #,@(map (lambda (vv) 
                              #`(mutable #,vv) ) #'(v ...)) 
                      )
                  (protocol (lambda (new) 
                    (case-lambda
                              [() (new  
                                 '(t ...) 
                                 '#,@(list (map (lambda (ss)
                                      ;(display (format "  ###=>~a\n" (syntax->datum ss) ) )
                                          (case (syntax->datum ss)
                                              [(number?) (syntax->datum ss)]
                                              [else (eval (syntax->datum ss) ) ]
                                            )
                                          )
                                      #'(s ...) ) )

                                 #,@(map (lambda (vv) 
                                         #`'()  ) #'(v ...)) )]
                              [(v ...)  (new  
                                '(t ... ) 
                                '#,@(list (map (lambda (ss)
                                      ;(display (format "  ###=>~a\n" (syntax->datum ss) ) )
                                          (case (syntax->datum ss)
                                              [(number?) (syntax->datum ss)]
                                              [else (eval (syntax->datum ss) ) ]
                                            )
                                          )
                                      #'(s ...) ) )

                                 v ... ) ])
                    )) 
                  ) 

                  )
          ((_ name (v t ) ... )
               #`(define-record-type name
                  ;(nongenerative)
                  ;(sealed #t)
                  (fields 
                      (mutable type)
                      (mutable size)
                      #,@(map (lambda (vv) 
                              #`(mutable #,vv) ) #'(v ...)) 
          
                      )
                  (protocol (lambda (new) 
                    (case-lambda
                              [() 
                                (new 
                                     '(t ...)
                                     '#,@(list (map (lambda (ss)
                                          (case (syntax->datum ss)
                                            [(int float double ) 64 ]
                                            [(short ) 16 ]
                                            [(char ) 8 ]
                                           ))
                                      #'(t ...) ) )
                                      #,@(map (lambda (vv) 
                                           #`'()  ) #'(v ...))

                                              )]
                              [(v ...)  
                                (new 
                                     '(t ...)
                                     '#,@(list (map (lambda (ss)
                                          (case (syntax->datum ss)
                                            [(int float double ) 64 ]
                                            [(short ) 16 ]
                                            [(char ) 8 ]
                                           ))
                                      #'(t ...) ) )
                                      v ...
                               ) ]
                      )
                    )) 
                  ) 

                  )
          )) )


  ;;def-function funname args 
  (define-syntax def-function
    (lambda (x)
      (syntax-case x ()
	((_ name sym args ret)
	 #'(define name 
	     (lambda values
	       (cffi-call sym 'args 'ret values )
	       ))))  ) )



  ;;cffi functions begin
  (define (cffi-open-lib path)
    (set! handler (ffi-dlopen path  RTLD_LAZY) )
    handler
    )

  (define (cffi-sym name)
    (ffi-dlsym handler name)
    )
  ;;cal-size 
  (define (cffi-size l)
    ;(display (format "cffi-size ~a\n" (syntax->datum l)  ) )
      (if (pair? l)
        (apply + l)
        (case l
          [(int long ) 32]
          [(float ) 32]
          [(double  void* string ) 64]
          [(float* ) 32]
	  [(void ) 0]
          )
      )
    )

  ;;ffi init
  (define (cffi-init)
    #t
  )
  ;;
  (define (create-carg-type arg-type)
    ;;(display (format "creat-carg-type arg-type=~a len=~a \n" arg-type (length arg-type) ))
    (let ((carg-type (ffi-types-alloc (length arg-type) )))
      (let loop ((type arg-type) (i 0))
	(if (pair? type)
	    (begin 
	      ;;(display (format "  type=~a index=~a \n" (car type) i   ))
	      (ffi-types-set carg-type i (create-cret-type (car type)) )

	      (loop (cdr type) (+ i 1) )
	      )
            )
        )
      ;;(display (format "  carg-type=~x\n" carg-type))
      carg-type 
      )
    )

  (define (process-struct  ret-type)
    (let ((ret-struct-val '())
          (typelist '() )
          (typeelement '() )
          (alloc 0)
        )
      (set! alloc (ffi-alloc  (+ 64 16 16 64)))
      (set! ret-struct-val ((top-level-value 
                                (string->symbol (format "make-~a" ret-type ) )) ))
      (set! typelist (struct-ref ret-struct-val 0) )
      (set! typeelement (ffi-alloc (* 64 (+ (length typelist ) 1) ) ))
      (ffi-init-struct alloc 0 0 FFI_TYPE_STRUCT typeelement)
      (let loop ((type typelist) (i 0))
        (if (pair? type)
          (begin 
            (case (car type)
                [(char )  (ffi-types-set typeelement i ffi-type-sint8 ) ]
                [(int )  (ffi-types-set typeelement i ffi-type-sint ) ]
                [(float )  (ffi-types-set typeelement i ffi-type-float ) ]
                [(double )  (ffi-types-set typeelement i ffi-type-double ) ]
                [(void* float*)  (ffi-types-set typeelement i ffi-type-pointer ) ]
                [(string )  (ffi-types-set typeelement i ffi-type-pointer ) ]
                [else 
                    ;(display (format "  ###$$$else type=~a\n" (car type) ) )
                    (ffi-types-set typeelement i (process-struct  (car type) ) )
                  ]
              )
            (loop (cdr type) (+ i 1) )
            )
          )
        )
      (ffi-types-set typeelement (length typelist ) 0 ) 
      alloc
      )
      
    )

  (define (create-cret-type ret-type)
    (let ((alloc 0) (ret-struct-val 0) (typeelement 0) (typelist '() ) )
      (case ret-type
          [(int ) ffi-type-sint]
          [(float ) ffi-type-float]
          [(double ) ffi-type-double]
          [(string ) ffi-type-pointer]
          [(void* float* ) ffi-type-pointer]
          [(void)  ffi-type-void ]
          [else
            ;;(display (format "  $$$else type=~a\n" ret-type) )
            (process-struct ret-type )
            ]
        ))
    )

  (define (create-cret ret-type)
    ;;(display (format "ret-type-size=~a\n" (cffi-size ret-type) ))
    (let ( (ret-fun (lambda (x) x)  )
	   (ret-type-s ret-type )
	   (ret-struct-val '() )
	   )
      (set! ret-fun (case ret-type
		      [(int ) ffi-get-int]
		      [(float ) ffi-get-float]
		      [(double ) ffi-get-double]
		      [(string ) ffi-get-string]
		      [(void* float* ) ffi-get-pointer]
		      [(void)  '() ]
		      [else
		       ;;(display (format "  ###else type=~a\n" ret-type) )
		       (set! ret-struct-val ((top-level-value 
					      (string->symbol (format "make-~a" ret-type ) )) ))
		       (set! ret-type-s (struct-ref ret-struct-val 1) )
		       (lambda (addr)
			 (struct2lisp addr ret-struct-val )
			 )
		       ]
		      ) )
      (list (ffi-alloc (cffi-size ret-type-s) ) ret-fun )

      )
    )

  (define (create-cargs arg-type args carg-type)
    ;(display (format "creat-cargs args=~a len=~a carg-type=~a\n" args (length args) carg-type))
    (let ((cargs (ffi-values-alloc (length args)))
          (alloc 0)
          )
        (let loop ((arg args) (type arg-type) (i 0))
          (if (pair? arg)
              (begin 
                ;(display (format "  type=~a value=~a index=~a \n" (car type) (car arg) i   ))
                (case (car type) 
                  [(int)
                    (set! alloc (ffi-alloc 32) ) 
                    (ffi-set-int alloc (car arg) )
                    (ffi-values-set cargs i alloc) ]
                  [(float)
                    (set! alloc (ffi-alloc 32) ) 
                    (ffi-set-float alloc (car arg) )
                    (ffi-values-set cargs i alloc) ]
                  [(double)
                    (set! alloc (ffi-alloc 64) ) 
                    (ffi-set-double alloc  (car arg))
                    (ffi-values-set cargs i alloc) ]
                  [(void)
                    ; (set! alloc (ffi-alloc 32) ) 
                    ; (ffi-set-int alloc (car arg) )
                    ; (ffi-values-set cargs i alloc)
                    1
                     ]
                  [(string )
                    (set! alloc (ffi-alloc 64) )
                    (if (number? (car arg)) 
                      (ffi-set-pointer alloc  (car arg))
                      (ffi-set-string alloc  (car arg))
                    )
                    (ffi-values-set cargs i alloc) ]
                  [(void* )
		   (set! alloc (ffi-alloc 64) )
		   ;;(display (format "===>~x\n" (car arg)))
			    
		   (ffi-set-pointer alloc  (car arg))
		   (ffi-values-set cargs i alloc) ]
                  [else
                      ;(display (format "  %%%else type=~a size=~a \n" (car type) (cffi-size (struct-ref (car arg) 1) ) ) )
                      (set! alloc (ffi-alloc (cffi-size (struct-ref (car arg) 1) ))  )
                      (lisp2struct (car arg) alloc)
                      (ffi-values-set cargs i alloc)
                     ]
                  
                  )

                (loop (cdr arg) (cdr type) (+ i 1) )
                )
            )
        )
        ;(display (format "  cargs=~x\n" cargs))
        cargs 
      )

    )

  ;;ffi call
  (define (cffi-call sym arg-type ret-type args )
    (if cffi-enable-log
	(begin
	  (display "\n")(display (format "cffi-call ~a arg-type=~a ret-type=~a args=~a \n"  sym  arg-type ret-type args) )  ) )
    (let* (
          (carg-type (create-carg-type arg-type) )
          (cret-type (create-cret-type ret-type) )
          (cargs (create-cargs arg-type args carg-type) )

          (cret-info (create-cret ret-type) )
          (cret '() )
          (cif (ffi-cif-alloc) )
          (fptr (cffi-sym  sym )) 
          (call-ret '() )
          (ret-val '() )
          )

          (set! call-ret (cadr cret-info))
          (set! cret (car cret-info))

          ;;(display (format "ffi-prep-cif len=~a  cret-type=~a carg-type=~a\n" (length arg-type) cret-type carg-type) )
          ;;(display (test-float cif FFI_DEFAULT_ABI  cret-type carg-type cargs) )
          ;;init cif
          (if (= FFI_OK (ffi-prep-cif cif FFI_DEFAULT_ABI (length arg-type) cret-type carg-type ) )
              (begin
                ;;(display "ffi-ok\n")
                (if (> fptr 0)
                  (begin 
                    ;;(display (format "ffi-call cret=~x cargs=~x\n" cret cargs ))
                    (ffi-call cif fptr cret cargs)  
                    )
                  (display (format "cannot find symbol ~a\n" sym ))
                ))
              (error 'cffi (format "ffi-prep-cif return error\n"))
	      )
	  ;;(display (format "cret=~x\n" cret))
          (if (procedure? call-ret)
            (set! ret-val (call-ret cret))
            )
          (ffi-free-all)
	   (if cffi-enable-log
	       (display (format "ffi-call ret=~x\n" ret-val)))
          ret-val
        )

    )    


(define (struct-ref s index )
    ( (record-accessor (record-rtd  s ) index ) s )
  )
(define (struct-set! s index  val)
  ((record-mutator (record-rtd  s ) index )  s val)
  )
 
;;struct2lisp
(define (struct2lisp addr ret-struct-val)
  ;(display (format "  ret-fun conver======>~a ~a\n" addr ret-struct-val ) )
  (let loop ((i 0) (offset 0) 
             (t (struct-ref ret-struct-val 0) ) 
             (s (struct-ref ret-struct-val 1)) )
            (if (pair? t)
              (let ((struct-val 0)) 
                  (case (car t)
                    [(char ) (set! struct-val (ffi-get-int (+ addr offset)) )
                        (set! offset (+ offset (/ (car s) 8) ))
                      ]
                    [(double ) (set! struct-val (ffi-get-double (+ addr offset)))
                        (set! offset (+ offset (/ (car s) 8) ))
                    ]
                    [(int ) (set! struct-val (ffi-get-int (+ addr offset)))
                        (set! offset (+ offset (/ (car s) 8) ))
                      ]
                    [(float ) (set! struct-val (ffi-get-float (+ addr offset)))
                        (set! offset (+ offset (/ (car s) 8) ))
                      ]
                    [(void* float* )
                        (set! struct-val (ffi-get-pointer (+ addr offset)))
                        (set! offset (+ offset (/ (car s) 8) ))
                      ]
                    ; [(float*)
                    ;   (print-array (+ addr offset ) )
                    ;   (set! offset (+ offset (/ (car s) 8) ))
                    ; ]
                    [else 
                        ;;make struct
                        (struct-set! ret-struct-val 
                                      (+ i 2) ((top-level-value (string->symbol (format "make-~a" (car t) ) )) ) )
                        (set! struct-val (struct2lisp (+ addr offset) (struct-ref ret-struct-val (+ i 2) ) ) )
                        (set! offset (+ offset (/ (car s) 8) ))
                      ] 

                    )
                  (struct-set! ret-struct-val (+ i 2)  struct-val)
                  ;(display (format "   >>>>ret fun type=~a size=~a struct-val=~a\n" (car t) (car s)  struct-val) )

                  (loop (+ i 1)  offset (cdr t) (cdr s) )
              )
              (begin 
                ;(display (format "      ret-struct-val=~a\n\n" ret-struct-val) )
                ret-struct-val))
      )
      
  )

;;lisp2struct
  (define (lisp2struct struct-val addr)
    (let loop ((i 0) (e (struct-ref struct-val 0) ) (offset 0) (s (struct-ref struct-val 1)) )
        (if (pair? e)
          (let ((v ((record-accessor 
                (record-rtd  struct-val) (+ i 2) ) struct-val ))
                (ss (car s))
                ) 
              ;(display (format "    set ~a value==>~a size=~a offset=~a\n" (car e) v ss offset))
              (case (car e)
                [(char ) 
                    (ffi-set-char (+ offset addr) v)
                    (set! offset (+ offset (/ ss 8) ) )
                  ]
                [(double ) 
                    (ffi-set-double (+ offset addr) v)
                    (set! offset (+ offset (/ ss 8) ))
                ]
                [(int ) 
                  (ffi-set-int (+ offset addr) v)
                    (set! offset (+ offset (/ ss 8) ))
                  ]
                [(float ) 
                    (ffi-set-float (+ offset addr) v)
                    (set! offset (+ offset (/ ss 8) ))
                  ]
                [(float* )
                  ;(print-array v )
                  ; (let loop ((i  (car s) ) (o 0) )
                  ;     (if (>= i 0)
                  ;       (begin 

                  ;         (display (format "    ######====>~a\n" (ffi-get-float (+ v o) ) ))
                  ;         (ffi-set-float (+ offset addr o) (ffi-get-float (+ v o) ) )
                  ;         (loop (- i 32) (+ o 32) )
                  ;         ))
                  ;   )
                  (ffi-copy-mem  v (+ offset addr) (/ (car s) 1) )
                  (set! offset (+ offset (/ (car s) 8) ))
                ]
                [(void* ) 
                  ;(display (format "v=~x addr=~x\n"  v (+ offset addr) ))
                  ;(ffi-copy-mem  v (+ offset addr) (/ (car s) 8) )
                  ;(ffi-set-pointer (+ offset addr) v)
                  (set! offset (+ offset (/ (car s) 8) ))
                  ]
                [else
                    ;(display (format "    ===else ~a ~a\n" (car e) (car s) ) )
                    (lisp2struct v (+ offset addr) )
                    (set! offset (+ offset (/ (car s) 8) ))
                  ]  
                )
            (loop (+ i 1) (cdr e) offset (cdr s) )
          ))
      )
    )


)
