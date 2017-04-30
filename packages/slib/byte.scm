;;; "byte.scm" small integers, not necessarily chars.
; Copyright (C) 2001, 2002, 2003, 2006, 2008 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require 'array)
(require 'multiarg-apply)

;;@code{(require 'byte)}
;;@ftindex byte
;;
;;@noindent
;;Some algorithms are expressed in terms of arrays of small integers.
;;Using Scheme strings to implement these arrays is not portable vis-a-vis
;;the correspondence between integers and characters and non-ascii
;;character sets.  These functions abstract the notion of a @dfn{byte}.
;;@cindex byte

;;@args bytes k
;;@2 must be a valid index of @1.  @0 returns byte @2 of @1 using
;;zero-origin indexing.
(define byte-ref array-ref)

;;@body
;;@2 must be a valid index of @1, and @var{byte} must be a small
;;nonnegative integer.  @0 stores @var{byte} in element @2 of @1 and
;;returns an unspecified value.  @c <!>
(define (byte-set! bytes k byte)
  (array-set! bytes byte k))

;;@args k byte
;;@args k
;;@0 returns a newly allocated byte-array of length @1.  If @2 is
;;given, then all elements of the byte-array are initialized to @2,
;;otherwise the contents of the byte-array are unspecified.
(define (make-bytes len . opt)
  (make-array (apply A:fixN8b opt) len))

;;@args bytes
;;@0 returns length of byte-array @1.
(define (bytes-length bts)
  (car (array-dimensions bts)))

;;@args byte @dots{}
;;Returns a newly allocated byte-array composed of the small
;;nonnegative arguments.
(define (bytes . args)
  (list->array 1 (A:fixN8b) args))

;;@args bytes
;;@0 returns a newly allocated byte-array formed from the small
;;nonnegative integers in the list @1.
(define (list->bytes lst)
  (list->array 1 (A:fixN8b) lst))

;;@args bytes
;;@0 returns a newly allocated list of the bytes that make up the
;;given byte-array.
(define bytes->list array->list)

;;@noindent
;;@code{Bytes->list} and @code{list->bytes} are inverses so far as
;;@code{equal?} is concerned.
;;@findex equal?

;;@args bytes
;;Returns a new string formed from applying @code{integer->char} to
;;each byte in @0.  Note that this may signal an error for bytes
;;having values between 128 and 255.
(define (bytes->string bts)
  (define len (bytes-length bts))
  (let ((new (make-string len)))
    (do ((idx (- len 1) (+ -1 idx)))
	((negative? idx) new)
      (string-set! new idx (integer->char (byte-ref bts idx))))))

;;@args string
;;Returns a new byte-array formed from applying @code{char->integer}
;;to each character in @0.  Note that this may signal an error if an
;;integer is larger than 255.
(define (string->bytes str)
  (define len (string-length str))
  (let ((new (make-bytes len)))
    (do ((idx (- len 1) (+ -1 idx)))
	((negative? idx) new)
      (byte-set! new idx (char->integer (string-ref str idx))))))

;;@args bytes
;;Returns a newly allocated copy of the given @1.
(define (bytes-copy bts)
  (define len (bytes-length bts))
  (let ((new (make-bytes len)))
    (do ((idx (- len 1) (+ -1 idx)))
	((negative? idx) new)
      (byte-set! new idx (byte-ref bytes idx)))))

;;@args bytes start end
;;@1 must be a bytes, and @2 and @3
;;must be exact integers satisfying
;;
;;@center 0 <= @2 <= @3 <= @w{@t{(bytes-length @1)@r{.}}}
;;
;;@0 returns a newly allocated bytes formed from the bytes of
;;@1 beginning with index @2 (inclusive) and ending with index
;;@3 (exclusive).
(define (subbytes bytes start end)
  (define new (make-bytes (- end start)))
  (do ((idx (- end start 1) (+ -1 idx)))
      ((negative? idx) new)
    (byte-set! new idx (byte-ref bytes (+ start idx)))))

;;@body
;;Reverses the order of byte-array @1.
(define (bytes-reverse! bytes)
  (do ((idx 0 (+ 1 idx))
       (xdi (+ -1 (bytes-length bytes)) (+ -1 xdi)))
      ((> idx xdi) bytes)
    (let ((tmp (byte-ref bytes idx)))
      (byte-set! bytes idx (byte-ref bytes xdi))
      (byte-set! bytes xdi tmp))))

;;@body
;;Returns a newly allocated bytes-array consisting of the elements of
;;@1 in reverse order.
(define (bytes-reverse bytes)
  (bytes-reverse! (bytes-copy bytes)))

;;@noindent
;;@cindex binary
;;Input and output of bytes should be with ports opened in @dfn{binary}
;;mode (@pxref{Input/Output}).  Calling @code{open-file} with @r{'rb} or
;;@findex open-file
;;@r{'wb} modes argument will return a binary port if the Scheme
;;implementation supports it.

;;@args byte port
;;@args byte
;;Writes the byte @1 (not an external representation of the byte) to
;;the given @2 and returns an unspecified value.  The @2 argument may
;;be omitted, in which case it defaults to the value returned by
;;@code{current-output-port}.
;;@findex current-output-port
(define (write-byte byt . opt)
  (apply write-char (integer->char byt) opt))

;;@args port
;;@args
;;Returns the next byte available from the input @1, updating the @1
;;to point to the following byte.  If no more bytes are available, an
;;end-of-file object is returned.  @1 may be omitted, in which case it
;;defaults to the value returned by @code{current-input-port}.
;;@findex current-input-port
(define (read-byte . opt)
  (let ((c (apply read-char opt)))
    (if (eof-object? c) c (char->integer c))))

;;@noindent
;;When reading and writing binary numbers with @code{read-bytes} and
;;@code{write-bytes}, the sign of the length argument determines the
;;endianness (order) of bytes.  Positive treats them as big-endian,
;;the first byte input or output is highest order.  Negative treats
;;them as little-endian, the first byte input or output is the lowest
;;order.
;;
;;@noindent
;;Once read in, SLIB treats byte sequences as big-endian.  The
;;multi-byte sequences produced and used by number conversion routines
;;@pxref{Byte/Number Conversions} are always big-endian.

;;@args n port
;;@args n
;;@0 returns a newly allocated bytes-array filled with
;;@code{(abs @var{n})} bytes read from @2.  If @1 is positive, then
;;the first byte read is stored at index 0; otherwise the last byte
;;read is stored at index 0.  Note that the length of the returned
;;byte-array will be less than @code{(abs @var{n})} if @2 reaches
;;end-of-file.
;;
;;@2 may be omitted, in which case it defaults to the value returned
;;by @code{current-input-port}.
(define (read-bytes n . port)
  (let* ((len (abs n))
	 (byts (make-bytes len))
	 (cnt (if (positive? n)
		  (apply subbytes-read! byts 0 n port)
		  (apply subbytes-read! byts (- n) 0 port))))
    (if (= cnt len)
	byts
	(if (positive? n)
	    (subbytes byts 0 cnt)
	    (subbytes byts (- len cnt) len)))))

;;@args bytes n port
;;@args bytes n
;;@0 writes @code{(abs @var{n})} bytes to output-port @3.  If @2 is
;;positive, then the first byte written is index 0 of @1; otherwise
;;the last byte written is index 0 of @1.  @0 returns an unspecified
;;value.
;;
;;@3 may be omitted, in which case it defaults to the value returned
;;by @code{current-output-port}.
(define (write-bytes bytes n . port)
  (if (positive? n)
      (apply subbytes-write bytes 0 n port)
      (apply subbytes-write bytes (- n) 0 port)))

;;@noindent
;;@code{subbytes-read!} and @code{subbytes-write} provide
;;lower-level procedures for reading and writing blocks of bytes.  The
;;relative size of @var{start} and @var{end} determines the order of
;;writing.

;;@args bts start end port
;;@args bts start end
;;Fills @1 with up to @code{(abs (- @var{start} @var{end}))} bytes
;;read from @4.  The first byte read is stored at index @1.
;;@0 returns the number of bytes read.
;;
;;@4 may be omitted, in which case it defaults to the value returned
;;by @code{current-input-port}.
(define (subbytes-read! bts start end . port)
  (if (>= end start)
      (do ((idx start (+ 1 idx)))
	  ((>= idx end) idx)
	(let ((byt (apply read-byte port)))
	  (cond ((eof-object? byt)
		 (set! idx (+ -1 idx))
		 (set! end idx))
		(else (byte-set! bts idx byt)))))
      (do ((idx (+ -1 start) (+ -1 idx))
	   (cnt 0 (+ 1 cnt)))
	  ((< idx end) cnt)
	(let ((byt (apply read-byte port)))
	  (cond ((eof-object? byt)
		 (set! idx start)
		 (set! cnt (+ -1 cnt)))
		(else (byte-set! bts idx byt)))))))

;;@args bts start end port
;;@args bts start end
;;@0 writes @code{(abs (- @var{start} @var{end}))} bytes to
;;output-port @4.  The first byte written is index @2 of @1.  @0
;;returns the number of bytes written.
;;
;;@4 may be omitted, in which case it defaults to the value returned
;;by @code{current-output-port}.
(define (subbytes-write bts start end . port)
  (if (>= end start)
      (do ((idx start (+ 1 idx)))
	  ((>= idx end) (- end start))
	(apply write-byte (byte-ref bts idx) port))
      (do ((idx (+ -1 start) (+ -1 idx)))
	  ((< idx end) (- start end))
	(apply write-byte (byte-ref bts idx) port))))
