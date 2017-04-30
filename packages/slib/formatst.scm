;; "formatst.scm" SLIB FORMAT Version 3.0 conformance test
; Written by Dirk Lutzebaeck (lutzeb@cs.tu-berlin.de)
;
; This code is in the public domain.

;; Test run: (slib:load "formatst")

; Failure reports for various scheme interpreters:
;
; SCM4d
;   None.
; Elk 2.2:
;   None.
; MIT C-Scheme 7.1:
;   The empty list is always evaluated as a boolean and consequently
;   represented as `#f'.
; Scheme->C 01nov91:
;   None, if format:symbol-case-conv and format:iobj-case-conv are set
;   to string-downcase.

(require 'format)

(if (not (string=? format:version "3.1"))
    (begin
      (display "You have format version ")
      (display format:version)
      (display ". This test is for format version 3.0!")
      (newline)
      (format:abort)))

(define fails 0)
(define total 0)
(define test-verbose #f)		; shows each test performed

(define (test format-args out-str)
  (set! total (+ total 1))
  (if (not test-verbose)
      (if (zero? (modulo total 10))
          (begin
            (display total)
            (display ",")
	    (force-output (current-output-port)))))
  (let ((format-out (apply format `(#f ,@format-args))))
    (if (string=? out-str format-out)
	(if test-verbose
	    (begin
	      (display "Verified ")
	      (write format-args)
	      (display " returns ")
	      (write out-str)
	      (newline)))
	(begin
	  (set! fails (+ fails 1))
	  (if (not test-verbose) (newline))
	  (display "*Failed* ")
	  (write format-args)
	  (newline)
	  (display " returns  ")
	  (write format-out)
	  (newline)
	  (display " expected ")
	  (write out-str)
	  (newline)))))

; ensure format default configuration

;;(set! format:symbol-case-conv #f)
;;(set! format:iobj-case-conv #f)
;;(set! format:iteration-bounded #t)
;;(set! format:max-iterations 100)

(format #t "~q")

(format #t "This implementation has~@[ no~] flonums ~
            ~:[but no~;and~] complex numbers~%"
	(not format:floats) format:complex-numbers)

; any object test

(test '("abc") "abc")
(test '("~a" 10) "10")
(test '("~a" -1.2) "-1.2")
(test '("~a" a) "a")
(test '("~a" #t) "#t")
(test '("~a" #f) "#f")
(test '("~a" "abc") "abc")
(test '("~a" #(1 2 3)) "#(1 2 3)")
(test '("~a" ()) "()")
(test '("~a" (a)) "(a)")
(test '("~a" (a b)) "(a b)")
(test '("~a" (a (b c) d)) "(a (b c) d)")
(test '("~a" (a . b)) "(a . b)")
(test '("~a" (a (b c . d))) "(a (b . (c . d)))") ; this is ugly
(test `("~a" ,display) (format:iobj->str display #f))
(test `("~a" ,(current-input-port)) (format:iobj->str (current-input-port) #f))
(test `("~a" ,(current-output-port)) (format:iobj->str (current-output-port) #f))

; # argument test

(test '("~a ~a" 10 20) "10 20")
(test '("~a abc ~a def" 10 20) "10 abc 20 def")

; numerical test

(test '("~d" 100) "100")
(test '("~x" 100) "64")
(test '("~o" 100) "144")
(test '("~b" 100) "1100100")
(test '("~@d" 100) "+100")
(test '("~@d" -100) "-100")
(test '("~@x" 100) "+64")
(test '("~@o" 100) "+144")
(test '("~@b" 100) "+1100100")
(test '("~10d" 100) "       100")
(test '("~:d" 123) "123")
(test '("~:d" 1234) "1,234")
(test '("~:d" 12345) "12,345")
(test '("~:d" 123456) "123,456")
(test '("~:d" 12345678) "12,345,678")
(test '("~:d" -123) "-123")
(test '("~:d" -1234) "-1,234")
(test '("~:d" -12345) "-12,345")
(test '("~:d" -123456) "-123,456")
(test '("~:d" -12345678) "-12,345,678")
(test '("~10:d" 1234) "     1,234")
(test '("~10:d" -1234) "    -1,234")
(test '("~10,'*d" 100) "*******100")
(test '("~10,,'|:d" 12345678) "12|345|678")
(test '("~10,,,2:d" 12345678) "12,34,56,78")
(test '("~14,'*,'|,4:@d" 12345678) "****+1234|5678")
(test '("~10r" 100) "100")
(test '("~2r" 100) "1100100")
(test '("~8r" 100) "144")
(test '("~16r" 100) "64")
(test '("~16,10,'*r" 100) "********64")

; roman numeral test

(test '("~@r" 4) "IV")
(test '("~@r" 19) "XIX")
(test '("~@r" 50) "L")
(test '("~@r" 100) "C")
(test '("~@r" 1000) "M")
(test '("~@r" 99) "XCIX")
(test '("~@r" 1994) "MCMXCIV")

; old roman numeral test

(test '("~:@r" 4) "IIII")
(test '("~:@r" 5) "V")
(test '("~:@r" 10) "X")
(test '("~:@r" 9) "VIIII")

; cardinal/ordinal English number test

(test '("~r" 4) "four")
(test '("~r" 10) "ten")
(test '("~r" 19) "nineteen")
(test '("~r" 1984) "one thousand, nine hundred eighty-four")
(test '("~:r" -1984) "minus one thousand, nine hundred eighty-fourth")

; character test

(test '("~c" #\a) "a")
(test '("~@c" #\a) "#\\a")
(test `("~@c" ,(integer->char 32)) "#\\space")
(test `("~@c" ,(integer->char 0)) "#\\nul")
(test `("~@c" ,(integer->char 27)) "#\\esc")
(test `("~@c" ,(integer->char 127)) "#\\del")
(test `("~@c" ,(integer->char 128)) "#\\200")
(test `("~@c" ,(integer->char 255)) "#\\377")
(test '("~65c") "A")
(test '("~7@c") "#\\bel")
(test '("~:c" #\a) "a")
(test `("~:c" ,(integer->char 1)) "^A")
(test `("~:c" ,(integer->char 27)) "^[")
(test '("~7:c") "^G")
(test `("~:c" ,(integer->char 128)) "#\\200")
(test `("~:c" ,(integer->char 127)) "#\\177")
(test `("~:c" ,(integer->char 255)) "#\\377")


; plural test

(test '("test~p" 1) "test")
(test '("test~p" 2) "tests")
(test '("test~p" 0) "tests")
(test '("tr~@p" 1) "try")
(test '("tr~@p" 2) "tries")
(test '("tr~@p" 0) "tries")
(test '("~a test~:p" 10) "10 tests")
(test '("~a test~:p" 1) "1 test")

; tilde test

(test '("~~~~") "~~")
(test '("~3~") "~~~")

; whitespace character test

(test '("~%") "
")
(test '("~3%") "


")
(test '("~&") "")
(test '("abc~&") "abc
")
(test '("abc~&def") "abc
def")
(test '("~&") "
")
(test '("~3&") "

")
(test '("abc~3&") "abc


")
(test '("~|") (string slib:form-feed))
(test '("~_~_~_") "   ")
(test '("~3_") "   ")
(test '("~/") (string slib:tab))
(test '("~3/") (make-string 3 slib:tab))

; tabulate test

(test '("~0&~3t") "   ")
(test '("~0&~10t") "          ")
(test '("~10t") "")
(test '("~0&1234567890~,8tABC")  "1234567890       ABC")
(test '("~0&1234567890~0,8tABC") "1234567890      ABC")
(test '("~0&1234567890~1,8tABC") "1234567890       ABC")
(test '("~0&1234567890~2,8tABC") "1234567890ABC")
(test '("~0&1234567890~3,8tABC") "1234567890 ABC")
(test '("~0&1234567890~4,8tABC") "1234567890  ABC")
(test '("~0&1234567890~5,8tABC") "1234567890   ABC")
(test '("~0&1234567890~6,8tABC") "1234567890    ABC")
(test '("~0&1234567890~7,8tABC") "1234567890     ABC")
(test '("~0&1234567890~8,8tABC") "1234567890      ABC")
(test '("~0&1234567890~9,8tABC") "1234567890       ABC")
(test '("~0&1234567890~10,8tABC") "1234567890ABC")
(test '("~0&1234567890~11,8tABC") "1234567890 ABC")
(test '("~0&12345~,8tABCDE~,8tXYZ") "12345    ABCDE   XYZ")
(test '("~,8t+++~,8t===") "     +++     ===")
(test '("~0&ABC~,8,'.tDEF") "ABC......DEF")
(test '("~0&~3,8@tABC") "        ABC")
(test '("~0&1234~3,8@tABC") "1234    ABC")
(test '("~0&12~3,8@tABC~3,8@tDEF") "12      ABC     DEF")

; indirection test

(test '("~a ~? ~a" 10 "~a ~a" (20 30) 40) "10 20 30 40")
(test '("~a ~@? ~a" 10 "~a ~a" 20 30 40) "10 20 30 40")

; field test

(test '("~10a" "abc") "abc       ")
(test '("~10@a" "abc") "       abc")
(test '("~10a" "0123456789abc") "0123456789abc")
(test '("~10@a" "0123456789abc") "0123456789abc")

; pad character test

(test '("~10,,,'*a" "abc") "abc*******")
(test '("~10,,,'Xa" "abc") "abcXXXXXXX")
(test '("~10,,,42a" "abc") "abc*******")
(test '("~10,,,'*@a" "abc") "*******abc")
(test '("~10,,3,'*a" "abc") "abc*******")
(test '("~10,,3,'*a" "0123456789abc") "0123456789abc***") ; min. padchar length
(test '("~10,,3,'*@a" "0123456789abc") "***0123456789abc")

; colinc, minpad padding test

(test '("~10,8,0,'*a" 123)  "123********")
(test '("~10,9,0,'*a" 123)  "123*********")
(test '("~10,10,0,'*a" 123) "123**********")
(test '("~10,11,0,'*a" 123) "123***********")
(test '("~8,1,0,'*a" 123) "123*****")
(test '("~8,2,0,'*a" 123) "123******")
(test '("~8,3,0,'*a" 123) "123******")
(test '("~8,4,0,'*a" 123) "123********")
(test '("~8,5,0,'*a" 123) "123*****")
(test '("~8,1,3,'*a" 123) "123*****")
(test '("~8,1,5,'*a" 123) "123*****")
(test '("~8,1,6,'*a" 123) "123******")
(test '("~8,1,9,'*a" 123) "123*********")

; slashify test

(test '("~s" "abc") "\"abc\"")
(test '("~s" "abc \\ abc") "\"abc \\\\ abc\"")
(test '("~a" "abc \\ abc") "abc \\ abc")
(test '("~s" "abc \" abc") "\"abc \\\" abc\"")
(test '("~a" "abc \" abc") "abc \" abc")
(test '("~s" #\space) "#\\space")
(test '("~s" #\newline) "#\\newline")
(test `("~s" ,slib:tab) "#\\ht")
(test '("~s" #\a) "#\\a")
(test '("~a" (a "b" c)) "(a \"b\" c)")

; symbol case force test

(define format:old-scc format:symbol-case-conv)
(set! format:symbol-case-conv string-upcase)
(test '("~a" abc) "ABC")
(set! format:symbol-case-conv string-downcase)
(test '("~s" abc) "abc")
(set! format:symbol-case-conv string-capitalize)
(test '("~s" abc) "Abc")
(set! format:symbol-case-conv format:old-scc)

; read proof test

(test `("~:s" ,display) (format:iobj->str display #t))
(test `("~:a" ,display) (format:iobj->str display #t))
(test `("~:a" (1 2 ,display)) (string-append "(1 2 " (format:iobj->str display #t) ")"))
(test '("~:a" "abc") "abc")

; internal object case type force test

(set! format:iobj-case-conv string-upcase)
(test `("~a" ,display) (string-upcase (format:iobj->str display #f)))
(set! format:iobj-case-conv string-downcase)
(test `("~s" ,display) (string-downcase (format:iobj->str display #f)))
(set! format:iobj-case-conv string-capitalize)
(test `("~s" ,display) (string-capitalize (format:iobj->str display #f)))
(set! format:iobj-case-conv #f)

; continuation line test

(test '("abc~
         123") "abc123")
(test '("abc~
123") "abc123")
(test '("abc~
") "abc")
(test '("abc~:
         def") "abc         def")
(test '("abc~@
         def")
"abc
def")

; flush output (can't test it here really)

(test '("abc ~! xyz") "abc  xyz")

; string case conversion

(test '("~a ~(~a~) ~a" "abc" "HELLO WORLD" "xyz") "abc hello world xyz")
(test '("~a ~:(~a~) ~a" "abc" "HELLO WORLD" "xyz") "abc Hello World xyz")
(test '("~a ~@(~a~) ~a" "abc" "HELLO WORLD" "xyz") "abc Hello world xyz")
(test '("~a ~:@(~a~) ~a" "abc" "hello world" "xyz") "abc HELLO WORLD xyz")
(test '("~:@(~a~)" (a b c)) "(A B C)")
(test '("~:@(~x~)" 255) "FF")
(test '("~:@(~p~)" 2) "S")
(test `("~:@(~a~)" ,display) (string-upcase (format:iobj->str display #f)))
(test '("~:(~a ~a ~a~) ~a" "abc" "xyz" "123" "world") "Abc Xyz 123 world")

; variable parameter

(test '("~va" 10 "abc") "abc       ")
(test '("~v,,,va" 10 42 "abc") "abc*******")

; number of remaining arguments as parameter

(test '("~#,,,'*@a ~a ~a ~a" 1 1 1 1) "***1 1 1 1")

; argument jumping

(test '("~a ~* ~a" 10 20 30) "10  30")
(test '("~a ~2* ~a" 10 20 30 40) "10  40")
(test '("~a ~:* ~a" 10) "10  10")
(test '("~a ~a ~2:* ~a ~a" 10 20) "10 20  10 20")
(test '("~a ~a ~@* ~a ~a" 10 20) "10 20  10 20")
(test '("~a ~a ~4@* ~a ~a" 10 20 30 40 50 60) "10 20  50 60")

; conditionals

(test '("~[abc~;xyz~]" 0) "abc")
(test '("~[abc~;xyz~]" 1) "xyz")
(test '("~[abc~;xyz~:;456~]" 99) "456")
(test '("~0[abc~;xyz~:;456~]") "abc")
(test '("~1[abc~;xyz~:;456~] ~a" 100) "xyz 100")
(test '("~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]") "no arg")
(test '("~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]" 10) "10")
(test '("~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]" 10 20) "10 and 20")
(test '("~#[no arg~;~a~;~a and ~a~;~a, ~a and ~a~]" 10 20 30) "10, 20 and 30")
(test '("~:[hello~;world~] ~a" #t 10) "world 10")
(test '("~:[hello~;world~] ~a" #f 10) "hello 10")
(test '("~@[~a tests~]" #f) "")
(test '("~@[~a tests~]" 10) "10 tests")
(test '("~@[~a test~:p~] ~a" 10 done) "10 tests done")
(test '("~@[~a test~:p~] ~a" 1 done) "1 test done")
(test '("~@[~a test~:p~] ~a" 0 done) "0 tests done")
(test '("~@[~a test~:p~] ~a" #f done) " done")
(test '("~@[ level = ~d~]~@[ length = ~d~]" #f 5) " length = 5")
(test '("~[abc~;~[4~;5~;6~]~;xyz~]" 0) "abc")   ; nested conditionals (irrghh)
(test '("~[abc~;~[4~;5~;6~]~;xyz~]" 2) "xyz")
(test '("~[abc~;~[4~;5~;6~]~;xyz~]" 1 2) "6")

; iteration

(test '("~{ ~a ~}" (a b c)) " a  b  c ")
(test '("~{ ~a ~}" ()) "")
(test '("~{ ~a ~5,,,'*a~}" (a b c d)) " a b**** c d****")
(test '("~{ ~a,~a ~}" (a 1 b 2 c 3)) " a,1  b,2  c,3 ")
(test '("~2{ ~a,~a ~}" (a 1 b 2 c 3)) " a,1  b,2 ")
(test '("~3{~a ~} ~a" (a b c d e) 100) "a b c  100")
(test '("~0{~a ~} ~a" (a b c d e) 100) " 100")
(test '("~:{ ~a,~a ~}" ((a b) (c d e f) (g h))) " a,b  c,d  g,h ")
(test '("~2:{ ~a,~a ~}" ((a b) (c d e f) (g h))) " a,b  c,d ")
(test '("~@{ ~a,~a ~}" a 1 b 2 c 3) " a,1  b,2  c,3 ")
(test '("~2@{ ~a,~a ~} <~a|~a>" a 1 b 2 c 3) " a,1  b,2  <c|3>")
(test '("~:@{ ~a,~a ~}" (a 1) (b 2) (c 3)) " a,1  b,2  c,3 ")
(test '("~2:@{ ~a,~a ~} ~a" (a 1) (b 2) (c 3)) " a,1  b,2  (c 3)")
(test '("~{~}" "<~a,~a>" (a 1 b 2 c 3)) "<a,1><b,2><c,3>")
(test '("~{ ~a ~{<~a>~}~} ~a" (a (1 2) b (3 4)) 10) " a <1><2> b <3><4> 10")
(let ((nums (let iter ((ns '()) (l 0))
              (if (> l 105) (reverse ns) (iter (cons l ns) (+ l 1))))))
  ;; Test default, only 100 items formatted out:
  (test `("~D~{, ~D~}" ,(car nums) ,(cdr nums))
	"0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100")
  ;; Test control of number of items formatted out:
  (set! format:max-iterations 90)
  (test `("~D~{, ~D~}" ,(car nums) ,(cdr nums))
	"0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90")
  ;; Test control of imposing bound on number of items formatted out:
  (set! format:iteration-bounded #f)
  (test `("~D~{, ~D~}" ,(car nums) ,(cdr nums))
	"0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105")
  ;; Restore defaults:
  (set! format:iteration-bounded #t)
  (set! format:max-iterations 100)
  )

; up and out

(test '("abc ~^ xyz") "abc ")
(test '("~@(abc ~^ xyz~) ~a" 10) "ABC  xyz 10")
(test '("done. ~^ ~d warning~:p. ~^ ~d error~:p.") "done. ")
(test '("done. ~^ ~d warning~:p. ~^ ~d error~:p." 10) "done.  10 warnings. ")
(test '("done. ~^ ~d warning~:p. ~^ ~d error~:p." 10 1)
      "done.  10 warnings.  1 error.")
(test '("~{ ~a ~^<~a>~} ~a" (a b c d e f) 10) " a <b> c <d> e <f> 10")
(test '("~{ ~a ~^<~a>~} ~a" (a b c d e) 10) " a <b> c <d> e  10")
(test '("abc~0^ xyz") "abc")
(test '("abc~9^ xyz") "abc xyz")
(test '("abc~7,4^ xyz") "abc xyz")
(test '("abc~7,7^ xyz") "abc")
(test '("abc~3,7,9^ xyz") "abc")
(test '("abc~8,7,9^ xyz") "abc xyz")
(test '("abc~3,7,5^ xyz") "abc xyz")

; complexity tests (oh my god, I hardly understand them myself (see CL std))

(define fmt "Items:~#[ none~; ~a~; ~a and ~a~:;~@{~#[~; and~] ~a~^,~}~].")

(test `(,fmt ) "Items: none.")
(test `(,fmt foo) "Items: foo.")
(test `(,fmt foo bar) "Items: foo and bar.")
(test `(,fmt foo bar baz) "Items: foo, bar, and baz.")
(test `(,fmt foo bar baz zok) "Items: foo, bar, baz, and zok.")

; fixed floating points

(cond
 (format:floats
  (test '("~6,2f" 3.14159) "  3.14")
  (test '("~6,1f" 3.14159) "   3.1")
  (test '("~6,0f" 3.14159) "    3.")
  (test '("~5,1f" 0) "  0.0")
  (test '("~10,7f" 3.14159) " 3.1415900")
  (test '("~10,7f" -3.14159) "-3.1415900")
  (test '("~10,7@f" 3.14159) "+3.1415900")
  (test '("~6,3f" 0.0) " 0.000")
  (test '("~6,4f" 0.007) "0.0070")
  (test '("~6,3f" 0.007) " 0.007")
  (test '("~6,2f" 0.007) "  0.01")
  (test '("~3,2f" 0.007) ".01")
  (test '("~3,2f" -0.007) "-.01")
  (test '("~6,2,,,'*f" 3.14159) "**3.14")
  (test '("~6,3,,'?f" 12345.56789) "??????")
  (test '("~6,3f" 12345.6789) "12345.679")
  (test '("~,3f" 12345.6789) "12345.679")
  (test '("~,3f" 9.9999) "10.000")
  (test '("~6f" 23.4) "  23.4")
  (test '("~6f" 1234.5) "1234.5")
  (test '("~6f" 12345678) "12345678.0")
  (test '("~6,,,'?f" 12345678) "??????")
  (test '("~6f" 123.56789) "123.57")
  (test '("~6f" 123.0) " 123.0")
  (test '("~6f" -123.0) "-123.0")
  (test '("~6f" 0.0) "   0.0")
  (test '("~3f" 3.141) "3.1")
  (test '("~2f" 3.141) "3.")
  (test '("~1f" 3.141) "3.141")
  (test '("~f" 123.56789) "123.56789")
  (test '("~f" -314.0) "-314.0")
  (test '("~f" 1e4) "10000.0")
  (test '("~f" -1.23e10) "-12300000000.0")
  (test '("~f" 1e-4) "0.0001")
  (test '("~f" -1.23e-10) "-0.000000000123")
  (test '("~@f" 314.0) "+314.0")
  (test '("~,,3f" 0.123456) "123.456")
  (test '("~,,-3f" -123.456) "-0.123456")
  (test '("~5,,3f" 0.123456) "123.5")
))

; exponent floating points

(cond
 (format:floats
  (test '("~e" 3.14159) "3.14159E+0")
  (test '("~e" 0.00001234) "1.234E-5")
  (test '("~,,,0e" 0.00001234) "0.1234E-4")
  (test '("~,3e" 3.14159) "3.142E+0")
  (test '("~,3@e" 3.14159) "+3.142E+0")
  (test '("~,3@e" 0.0) "+0.000E+0")
  (test '("~,0e" 3.141) "3.E+0")
  (test '("~,3,,0e" 3.14159) "0.314E+1")
  (test '("~,5,3,-2e" 3.14159) "0.00314E+003")
  (test '("~,5,3,-5e" -3.14159) "-0.00000E+006")
  (test '("~,5,2,2e" 3.14159) "31.4159E-01")
  (test '("~,5,2,,,,'ee" 0.0) "0.00000e+00")
  (test '("~12,3e" -3.141) "   -3.141E+0")
  (test '("~12,3,,,,'#e" -3.141) "###-3.141E+0")
  (test '("~10,2e" -1.236e-4) "  -1.24E-4")
  (test '("~5,3e" -3.141) "-3.141E+0")
  (test '("~5,3,,,'*e" -3.141) "*****")
  (test '("~3e" 3.14159) "3.14159E+0")
  (test '("~4e" 3.14159) "3.14159E+0")
  (test '("~5e" 3.14159) "3.E+0")
  (test '("~5,,,,'*e" 3.14159) "3.E+0")
  (test '("~6e" 3.14159) "3.1E+0")
  (test '("~7e" 3.14159) "3.14E+0")
  (test '("~7e" -3.14159) "-3.1E+0")
  (test '("~8e" 3.14159) "3.142E+0")
  (test '("~9e" 3.14159) "3.1416E+0")
  (test '("~9,,,,,,'ee" 3.14159) "3.1416e+0")
  (test '("~10e" 3.14159) "3.14159E+0")
  (test '("~11e" 3.14159) " 3.14159E+0")
  (test '("~12e" 3.14159) "  3.14159E+0")
  (test '("~13,6,2,-5e" 3.14159) " 0.000003E+06")
  (test '("~13,6,2,-4e" 3.14159) " 0.000031E+05")
  (test '("~13,6,2,-3e" 3.14159) " 0.000314E+04")
  (test '("~13,6,2,-2e" 3.14159) " 0.003142E+03")
  (test '("~13,6,2,-1e" 3.14159) " 0.031416E+02")
  (test '("~13,6,2,0e" 3.14159)  " 0.314159E+01")
  (test '("~13,6,2,1e" 3.14159)  " 3.141590E+00")
  (test '("~13,6,2,2e" 3.14159)  " 31.41590E-01")
  (test '("~13,6,2,3e" 3.14159)  " 314.1590E-02")
  (test '("~13,6,2,4e" 3.14159)  " 3141.590E-03")
  (test '("~13,6,2,5e" 3.14159)  " 31415.90E-04")
  (test '("~13,6,2,6e" 3.14159)  " 314159.0E-05")
  (test '("~13,6,2,7e" 3.14159)  " 3141590.E-06")
  (test '("~13,6,2,8e" 3.14159)  "31415900.E-07")
  (test '("~7,3,,-2e" 0.001) ".001E+0")
  (test '("~8,3,,-2@e" 0.001) "+.001E+0")
  (test '("~8,3,,-2@e" -0.001) "-.001E+0")
  (test '("~8,3,,-2e" 0.001) "0.001E+0")
  (test '("~7,,,-2e" 0.001) "0.00E+0")
  (test '("~12,3,1e" 3.14159e12) "   3.142E+12")
  (test '("~12,3,1,,'*e" 3.14159e12) "************")
  (test '("~5,3,1e" 3.14159e12) "3.142E+12")
))

; general floating point (this test is from Steele's CL book)

(cond
 (format:floats
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  0.0314159 0.0314159 0.0314159 0.0314159)
	"  3.14E-2|314.2$-04|0.314E-01|  3.14E-2")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  0.314159 0.314159 0.314159 0.314159)
	"  0.31   |0.314    |0.314    | 0.31    ")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  3.14159 3.14159 3.14159 3.14159)
	"   3.1   | 3.14    | 3.14    |  3.1    ")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  31.4159 31.4159 31.4159 31.4159)
	"   31.   | 31.4    | 31.4    |  31.    ")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  314.159 314.159 314.159 314.159)
	"  3.14E+2| 314.    | 314.    |  3.14E+2")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  3141.59 3141.59 3141.59 3141.59)
	"  3.14E+3|314.2$+01|0.314E+04|  3.14E+3")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  3.14E12 3.14E12 3.14E12 3.14E12)
	"*********|314.0$+10|0.314E+13| 3.14E+12")
  (test '("~9,2,1,,'*g|~9,3,2,3,'?,,'$g|~9,3,2,0,'%g|~9,2g"
	  3.14E120 3.14E120 3.14E120 3.14E120)
	"*********|?????????|%%%%%%%%%|3.14E+120")

  (test '("~g" 0.0) "0.0    ")		; further ~g tests
  (test '("~g" 0.1) "0.1    ")
  (test '("~g" 0.01) "1.0E-2")
  (test '("~g" 123.456) "123.456    ")
  (test '("~g" 123456.7) "123456.7    ")
  (test '("~g" 123456.78) "123456.78    ")
  (test '("~g" 0.9282) "0.9282    ")
  (test '("~g" 0.09282) "9.282E-2")
  (test '("~g" 1) "1.0    ")
  (test '("~g" 12) "12.0    ")
  ))

; dollar floating point

(cond
 (format:floats
  (test '("~$" 1.23) "1.23")
  (test '("~$" 1.2) "1.20")
  (test '("~$" 0.0) "0.00")
  (test '("~$" 9.999) "10.00")
  (test '("~3$" 9.9999) "10.000")
  (test '("~,4$" 3.2) "0003.20")
  (test '("~,4$" 10000.2) "10000.20")
  (test '("~,4,10$" 3.2) "   0003.20")
  (test '("~,4,10@$" 3.2) "  +0003.20")
  (test '("~,4,10:@$" 3.2) "+  0003.20")
  (test '("~,4,10:$" -3.2) "-  0003.20")
  (test '("~,4,10$" -3.2) "  -0003.20")
  (test '("~,,10@$" 3.2) "     +3.20")
  (test '("~,,10:@$" 3.2) "+     3.20")
  (test '("~,,10:@$" -3.2) "-     3.20")
  (test '("~,,10,'_@$" 3.2) "_____+3.20")
  (test '("~,,4$" 1234.4) "1234.40")
))

; complex numbers

(cond
 (format:complex-numbers
  (test '("~i" 3.0) "3.0+0.0i")
  (test '("~,3i" 3.0) "3.000+0.000i")
  (test `("~7,2i" ,(string->number "3.0+5.0i")) "   3.00  +5.00i")
  (test `("~7,2,1i" ,(string->number "3.0+5.0i")) "  30.00 +50.00i")
  (test `("~7,2@i" ,(string->number "3.0+5.0i")) "  +3.00  +5.00i")
  (test `("~7,2,,,'*@i" ,(string->number "3.0+5.0i")) "**+3.00**+5.00i")
  )) ; note: some parsers choke syntactically on reading a complex
     ; number though format:complex is #f; this is why we put them in
     ; strings

; inquiry test

(test '("~:q") format:version)

(if (not test-verbose) (display "done."))

(format #t "~%~a Test~:p completed. (~a failure~:p)~2%" total fails)
