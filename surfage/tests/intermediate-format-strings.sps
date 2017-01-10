#!r6rs
(import
  (rnrs)
  (rnrs mutable-pairs)
  (surfage s48 intermediate-format-strings)
  (surfage s78 lightweight-testing))

#;(define (format-lots n f fmt-str . args)
  (let loop ([i 0] [r #f])
    (if (= i n)
      r
      (loop (+ 1 i) (apply f fmt-str args)))))

(define-syntax expect
   (syntax-rules ()
     [(_ expected expr)
      (check expr => expected)]))

;;;===================================================

(expect (format "test ~s" 'me) (format #f "test ~a" "me"))

(check (format "~6,3F" 1/3)
       (=> member)  
         '(" 0.333" "  .333"))

(expect "  12" (format "~4F" 12))

(expect "  12.346" (format "~8,3F" 12.3456))

(expect "123.346" (format "~6,3F" 123.3456))

(expect "123.346" (format "~4,3F" 123.3456))

(expect "0.000+1.949i" (format "~8,3F" (sqrt -3.8)))

(expect " 32.00" (format "~6,2F" 32))

(expect "    32" (format "~6F" 32))

(check (format "~6F" 32.)
;; NB: (not (and (exact? 32.) (integer? 32.)))
       (=> member)  
         '("  32.0" "   32."))

(check (format "~8F" 32e45)
       (=> member)  
       '("  3.2e46" " 3.2e+46"))

(expect " 3.2e-44" (format "~8,1F" 32e-45))

(check (format "~8F" 32e20)
       (=> member)  
       '("  3.2e21" " 3.2e+21"))

(check (format "~8F" 32e5)
       (=> member)  
         '("3200000.0"  "   3.2e6" "  3.2e+6"))

(check (format "~8F" 32e2)
       (=> member)  
       '("  3200.0" "   3200."))

(check (format "~8,2F" 32e10)
       (=> member)  
         '(" 3.20e11" "3.20e+11" "320000000000.00"))

(check (format "~0,3F" 20263/2813)
       (=> member)
       '( "7.203" ))

(check (format "~0,2F" 20263/2813)
       (=> member)
       '( "7.20" ))


(expect "      1.2345" (format "~12F" 1.2345))

(expect "        1.23" (format "~12,2F" 1.2345))

(expect "       1.234" (format "~12,3F" 1.2345)) ;; "round to even"

(expect "        0.000+1.949i" (format "~20,3F" (sqrt -3.8)))

(expect "0.000+1.949i" (format "~8,3F" (sqrt -3.8)))

(check (format "~8,2F" 3.4567e11)
       (=> member)  
       '(" 3.46e11" "3.46e+11" "345670000000.00"))


(check (format "~w" (let ( (c (list 'a 'b 'c)) ) (set-cdr! (cddr c) c) c))
       (=> member)
       '("#0=(a b c . #0#)" "#1=(a b c . #1#)"))

(expect "
"
        (format "~A~A~&" (list->string (list #\newline)) ""))

(expect "a new test"
        (format "~a ~? ~a" 'a "~a" '(new) 'test))

(expect "a \"new\" test"
        (format "~a ~? ~a" 'a "~s" '("new") 'test))

;; from SLIB

(define-syntax test
   (syntax-rules ()
     [(test <format-args> <expected>)
      (check (apply format <format-args>) => <expected>)]))

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
(test '("~a" (a (b c . d))) "(a (b c . d))")

; # argument test

(test '("~a ~a" 10 20) "10 20")
(test '("~a abc ~a def" 10 20) "10 abc 20 def")

; numerical test

(test '("~d" 100) "100")
(test '("~x" 100) "64")
(test '("~o" 100) "144")
(test '("~b" 100) "1100100")


; character test

(test '("~c" #\a) "a")


; tilde test

(test '("~~~~") "~~")


; whitespace character test

(test '("~%") "
")
(test '("~&") "
")
(test '("abc~&") "abc
")
(test '("abc~&def") "abc
def")
(test '("~&") "
")
(test '("~_~_~_") "   ")



; indirection test

(test '("~a ~? ~a" 10 "~a ~a" (20 30) 40) "10 20 30 40")



; slashify test

(test '("~s" "abc") "\"abc\"")
(test '("~s" "abc \\ abc") "\"abc \\\\ abc\"")
(test '("~a" "abc \\ abc") "abc \\ abc")
(test '("~s" "abc \" abc") "\"abc \\\" abc\"")
(test '("~a" "abc \" abc") "abc \" abc")
(test '("~s" #\space) "#\\space")
;(test '("~s" #\newline) "#\\newline")
(test '("~s" #\a) "#\\a")
(test '("~s" (a "b" c)) "(a \"b\" c)")
(test '("~a" (a "b" c)) "(a b c)")


; fixed floating points

  (test '("~6,2f" 3.14159) "  3.14")
  (test '("~6,1f" 3.14159) "   3.1")
  (test '("~6,0f" 3.14159) "    3.")
  (test '("~5,1f" 0) "  0.0")
  (test '("~10,7f" 3.14159) " 3.1415900")
  (test '("~10,7f" -3.14159) "-3.1415900")
  (test '("~6,3f" 0.0)    " 0.000")
  (check (format "~6,4f" 0.007)
         (=> member)
         '("  7e-3" "0.0070" ".0070"))
  (check (format "~6,3f" 0.007)
         (=> member)
         '("  7e-3"  " 0.007"))
  (check (format "~6,2f" 0.007)
         (=> member)
         '("  7e-3" "  0.01"))
  (check (format "~3,2f" 0.007)
         (=> member)
         '("7e-3" ".01" "0.01"))
  (check (format "~3,2f" -0.007)
          (=> member)
          '("-7e-3" "-.01" "-0.01"))
  (test '("~6,3f" 12345.6789) "12345.679")
  (test '("~6f" 23.4) "  23.4")
  (test '("~6f" 1234.5) "1234.5")
  (test '("~6f" 12345678) "12345678")
  (test '("~6,2f" 123.56789) "123.57")
  (test '("~6f" 123.0) " 123.0")
  (test '("~6f" -123.0) "-123.0")
  (test '("~6f" 0.0) "   0.0")
  (test '("~3,1f" 3.141) "3.1")
  (test '("~2,0f" 3.141) "3.")
  (test '("~1f" 3.141) "3.141")
  (test '("~f" 123.56789) "123.56789")
  (test '("~f" -314.0) "-314.0")
  (check (format "~f" 1e4)
         (=> member)
         '("1e4" "10000.0"))
  (check (format "~f" -1.23e10)
         (=> member)
         '("-1.23e10" "-1.23e+10" "-12300000000.0" "-12300000000."))
  (check (format "~f" 1e-4)
         (=> member)
         '("1e-4" "0.0001" ".0001"))
  (check (format "~f" -1.23e-10)
         (=> member)
         '("-0.000000000123" "-1.23e-10"))


(check-report)

;; #!eof
