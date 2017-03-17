;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

;; NOTE: I believe this currently works only on Linux.
;; NOTE: If Larceny's FFI changes, this may no longer work.

(library (surfage s98 os-environment-variables)
  (export
    get-environment-variable get-environment-variables)
  (import
    (rnrs base)
    (rnrs control)
    (rnrs bytevectors)
    (rnrs io ports)
    (primitives
     foreign-procedure #;foreign-variable foreign-null-pointer? sizeof:pointer
     %peek-pointer %peek8u void*->address ffi/dlopen ffi/dlsym)
    (surfage private feature-cond))

  ;; TODO: Will the convenient string converters use the native transcoder in
  ;;       the future?  So that scheme-str->c-str-bv and c-str-ptr->scheme-str
  ;;       won't be needed.

  (define (scheme-str->c-str-bv x)
    (let* ((bv (string->bytevector x (native-transcoder)))
           (len (bytevector-length bv))
           (bv/z (make-bytevector (+ 1 len))))
      (bytevector-copy! bv 0 bv/z 0 len)
      (bytevector-u8-set! bv/z len 0)
      bv/z))

  (define (c-str-ptr->scheme-str x)
    (let loop ((x x) (a '()))
      (let ((b (%peek8u x)))
        (if (zero? b)
          (bytevector->string (u8-list->bytevector (reverse a))
                              (native-transcoder))
          (loop (+ 1 x) (cons b a))))))
  
  (define getenv
    (foreign-procedure "getenv" '(boxed) 'void*))
  
  (define (get-environment-variable name) 
    (unless (string? name)
      (assertion-violation 'get-environment-variable "not a string" name))
    (let ((p (getenv (scheme-str->c-str-bv name))))
      (and p
           (c-str-ptr->scheme-str (void*->address p)))))

  ;; TODO: Will foreign-variable support a pointer type in the future?
  ;;       Would this be the correct way to use it?
  #;(define environ
      (foreign-variable "environ" 'void*))

  ;; TODO: Is (ffi/dlopen "") okay?  It works for me on Ubuntu Linux 8.10.
  (define environ
    (feature-cond
     (linux
      (%peek-pointer (ffi/dlsym (ffi/dlopen "") "environ")))))

  (define (get-environment-variables)
    (define (entry->pair x) 
      (let* ((s (c-str-ptr->scheme-str x))
             (len (string-length s)))
        (let loop ((i 0))
          (if (< i len)
            (if (char=? #\= (string-ref s i))
              (cons (substring s 0 i)
                    (substring s (+ 1 i) len))
              (loop (+ 1 i)))
            (cons s #F)))))
    (let loop ((e environ) (a '()))
      (let ((entry (%peek-pointer e)))
        (if (foreign-null-pointer? entry)
          a
          (loop (+ sizeof:pointer e)
                (cons (entry->pair entry) a))))))
)
