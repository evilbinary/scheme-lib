; Test suite for SRFI 43
;
; $Id: srfi-43-test.sps 6152 2009-03-19 22:30:05Z will $

(import (except (rnrs base) 
                vector-fill!
                vector->list
                list->vector
                vector-map
                vector-for-each)
        (rnrs lists)
        (rnrs io simple)
        (surfage s6 basic-string-ports)
        (surfage s43 vectors))

(define (writeln . xs)
  (for-each display xs)
  (newline))

(define (fail token . more)
  (writeln "Error: test failed: " token)
  #f)

(or (vector? (make-vector 0))
    (fail 'make-vector:0))

(or (= 10 (vector-length (make-vector 10)))
    (fail 'vector-length:basic))

(or (= 97 (vector-ref (make-vector 500 97) 499))
    (fail 'vector-ref:basic))

(or (equal? (vector) '#())
    (fail 'vector:0))

(or (equal? (vector 'a 'b 97) '#(a b 97))
    (fail 'vector))

(or (equal? (vector-unfold (lambda (i x) (values x (- x 1)))
                           10 0)
            '#(0 -1 -2 -3 -4 -5 -6 -7 -8 -9)) ; but SRFI 43 says -8 -8 at end
    (fail 'vector-unfold:1))

(or (equal? (vector-unfold values 10) '#(0 1 2 3 4 5 6 7 8 9))
    (fail 'vector-unfold:2))

(or (let ((vector '#(a b 97)))
      (equal? (vector-unfold (lambda (i) (vector-ref vector i))
                             (vector-length vector))
              vector))
    (fail 'vector-unfold:3))

(or (equal? (vector-unfold-right (lambda (i x) (values x (+ x 1))) 8 0)
            '#(7 6 5 4 3 2 1 0))
    (fail 'vector-unfold-right:1))

(or (let ((vector '#(3 1 4 5 9)))
      (equal? (vector-unfold-right (lambda (i x)
                                     (values (vector-ref vector x) (+ x 1)))
                                   (vector-length vector)
                                   0)
              '#(9 5 4 1 3)))
    (fail 'vector-unfold-right:2))

(or (equal? (vector-copy '#(a b c d e f g h i))
            '#(a b c d e f g h i))
    (fail 'vector-copy:1))

(or (equal? (vector-copy '#(a b c d e f g h i) 6)
            '#(g h i))
    (fail 'vector-copy:2))

(or (equal? (vector-copy '#(a b c d e f g h i) 3 6)
            '#(d e f))
    (fail 'vector-copy:3))

(or (equal? (vector-copy '#(a b c d e f g h i) 6 12 'x)
            '#(g h i x x x))
    (fail 'vector-copy:4))

(or (equal? (vector-reverse-copy '#(5 4 3 2 1 0) 1 5)
            '#(1 2 3 4))
    (fail 'vector-reverse-copy))

(or (equal? (vector-append '#(x) '#(y))
            '#(x y))
    (fail 'vector-append:1))

(or (equal? (vector-append '#(a) '#(b c d))
            '#(a b c d))
    (fail 'vector-append:2))

(or (equal? (vector-append '#(a #(b)) '#(#(c)))
            '#(a #(b) #(c)))
    (fail 'vector-append:3))

(or (equal? (vector-concatenate '(#(a b) #(c d)))
            '#(a b c d))
    (fail 'vector-concatenate))

(or (and (eq? (vector? '#(a b c)) #t)
         (eq? (vector? '(a b c)) #f)
         (eq? (vector? #t) #f)
         (eq? (vector? '#()) #t)
         (eq? (vector? '()) #f))
    (fail 'vector?))

(or (and (eq? (vector-empty? '#(a)) #f)
         (eq? (vector-empty? '#(())) #f)
         (eq? (vector-empty? '#(#())) #f)
         (eq? (vector-empty? '#()) #t))
    (fail 'vector-empty?))

(or (and (eq? (vector= eq? '#(a b c d) '#(a b c d)) #t)
         (eq? (vector= eq? '#(a b c d) '#(a b d c)) #f)
         (eq? (vector= = '#(1 2 3 4 5) '#(1 2 3 4)) #f)
         (eq? (vector= = '#(1 2 3 4) '#(1 2 3 4))   #t)
         (eq? (vector= eq?) #t)
         (eq? (vector= eq? '#(a)) #t)
         (eq? (vector= eq? (vector (vector 'a)) (vector (vector 'a))) #f)
         (eq? (vector= equal? (vector (vector 'a)) (vector (vector 'a))) #t))
    (fail 'vector=))

(or (eq? (vector-ref '#(a b c d) 2) 'c)
    (fail 'vector-ref))

(or (eq? (vector-length '#(a b c)) 3)
    (fail 'vector-length))

(or (equal? (vector-fold (lambda (index len str) (max (string-length str) len))
                         0 '#("a" "b" "" "dd" "e"))
            2)
    (fail 'vector-fold:1))

(or (equal? (vector-fold (lambda (index tail elt) (cons elt tail))
                         '() '#(0 1 2 3 4))
            '(4 3 2 1 0))
    (fail 'vector-fold:2))

(or (equal? (vector-fold (lambda (index counter n)
                           (if (even? n) (+ counter 1) counter))
                         0 '#(0 1 2 3 4 4 4 5 6 7))
            6)
    (fail 'vector-fold:3))

(or (equal? (vector-fold-right (lambda (index tail elt) (cons elt tail))
                               '() '#(a b c d))
            '(a b c d))
    (fail 'vector-fold-right))


(or (equal? (vector-map (lambda (i x) (* x x))
                        (vector-unfold (lambda (i x) (values x (+ x 1))) 4 1))
            '#(1 4 9 16))
    (fail 'vector-map:1))

(or (equal? (vector-map (lambda (i x y) (* x y))
                        (vector-unfold (lambda (i x) (values x (+ x 1))) 5 1)
                        (vector-unfold (lambda (i x) (values x (- x 1))) 5 5))
            '#(5 8 9 8 5))
    (fail 'vector-map:2))

(or (member (let ((count 0))
              (vector-map (lambda (ignored-index ignored-elt)
                            (set! count (+ count 1))
                            count)
                          '#(a b)))
            '(#(1 2) #(2 1)))
    (fail 'vector-map:3))

(or (equal? (let ((v (vector 1 2 3 4)))
              (vector-map! (lambda (i elt) (+ i elt)) v)
              v)
            '#(1 3 5 7))
    (fail 'vector-map!))

(or (equal? (let ((p (open-output-string)))
              (vector-for-each (lambda (i x) (display x p) (newline p))
                               '#("foo" "bar" "baz" "quux" "zot"))
              (get-output-string p))
            "foo\nbar\nbaz\nquux\nzot\n")
    (fail 'vector-for-each))

(or (equal? (vector-count (lambda (i elt) (even? elt)) '#(3 1 4 1 5 9 2 5 6))
            3)
    (fail 'vector-count:1))

(or (equal? (vector-count (lambda (i x y) (< x y))
                          '#(1 3 6 9)
                          '#(2 4 6 8 10 12))
            2)
    (fail 'vector-count:2))

(or (equal? (vector-index even? '#(3 1 4 1 5 9))
            2)
    (fail 'vector-index:1))

(or (equal? (vector-index < '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2))
            1)
    (fail 'vector-index:2))

(or (equal? (vector-index = '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2))
            #f)
    (fail 'vector-index:3))

(or (equal? (vector-index-right even? '#(3 1 4 1 5 9))
            2)
    (fail 'vector-index-right:1))

(or (equal? (vector-index-right < '#(3 1 4 1 5) '#(2 7 1 8 2))
            3)
    (fail 'vector-index-right:2))

(or (equal? (vector-index-right = '#(3 1 4 1 5) '#(2 7 1 8 2))
            #f)
    (fail 'vector-index-right:3))

(or (equal? (vector-skip even? '#(3 1 4 1 5 9))
            0)
    (fail 'vector-skip:1))

(or (equal? (vector-skip < '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2))
            0)
    (fail 'vector-skip:2))

(or (equal? (vector-skip = '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2))
            0)
    (fail 'vector-skip:3))

(or (equal? (vector-skip > '#(3 1 4 1 5 9 2 5 6) '#(2 7 1 8 2))
            1)
    (fail 'vector-skip:4))

(or (equal? (vector-skip-right even? '#(3 1 4 1 5 9))
            5)
    (fail 'vector-skip-right:1))

(or (equal? (vector-skip-right < '#(3 1 4 1 5) '#(2 7 1 8 2))
            4)
    (fail 'vector-skip-right:2))

(or (equal? (vector-skip-right = '#(3 1 4 1 5) '#(2 7 1 8 2))
            4)
    (fail 'vector-skip-right:3))

(or (equal? (vector-skip-right > '#(3 1 4 1 5) '#(2 7 1 8 2))
            3)
    (fail 'vector-skip-right:4))

(define (string-comparator s1 s2)
  (cond ((< (string-length s1) (string-length s2))
         -1)
        ((> (string-length s1) (string-length s2))
         +1)
        ((string<? s1 s2)
         -1)
        ((string>? s1 s2)
         +1)
        (else
         0)))

(or (equal? (vector-binary-search '#()
                                  "bad"
                                  string-comparator)
            #f)
    (fail 'vector-binary-search:0))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  "bad"
                                  string-comparator)
            #f)
    (fail 'vector-binary-search:1))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  ""
                                  string-comparator)
            #f)
    (fail 'vector-binary-search:2))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  "hello"
                                  string-comparator)
            #f)
    (fail 'vector-binary-search:3))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  "ab"
                                  string-comparator)
            0)
    (fail 'vector-binary-search:4))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  "aaaa"
                                  string-comparator)
            5)
    (fail 'vector-binary-search:5))

(or (equal? (vector-binary-search '#("ab" "cd" "ef" "bcd" "cde" "aaaa")
                                  "bcd"
                                  string-comparator)
            3)
    (fail 'vector-binary-search:6))

(or (equal? (vector-any list '#() '#(a b c))
            #f)
    (fail 'vector-any:0))

(or (equal? (vector-any list '#(a b c) '#())
            #f)
    (fail 'vector-any:1))

(or (equal? (vector-any list '#(a b c) '#(d))
            '(a d))
    (fail 'vector-any:2))

(or (equal? (vector-any memq '#(a b c) '#(() (c d e) (b c 97)))
            '(c 97))
    (fail 'vector-any:3))

(or (equal? (vector-every list '#() '#(a b c))
            #t)
    (fail 'vector-every:0))

(or (equal? (vector-every list '#(a b c) '#())
            #t)
    (fail 'vector-every:1))

(or (equal? (vector-every list '#(a b c) '#(d))
            '(a d))
    (fail 'vector-every:2))

(or (equal? (vector-every memq '#(a b c) '#(() (c d e) (b c 97)))
            #f)
    (fail 'vector-every:3))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-set! v 1 11)
              v)
            '#(0 11 2 3))
    (fail 'vector-set!))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-swap! v 1 3)
              v)
            '#(0 3 2 1))
    (fail 'vector-swap!))

(or (equal? (let ((v (vector)))
              (vector-fill! v 97)
              v)
            '#())
    (fail 'vector-fill!:0))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-fill! v 97)
              v)
            '#(97 97 97 97))
    (fail 'vector-fill!:1))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-fill! v 97 1)
              v)
            '#(0 97 97 97))
    (fail 'vector-fill!:2))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-fill! v 97 1 2)
              v)
            '#(0 97 2 3))
    (fail 'vector-fill!:3))

(or (equal? (let ((v (vector)))
              (vector-reverse! v)
              v)
            '#())
    (fail 'vector-reverse!:0))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-reverse! v)
              v)
            '#(3 2 1 0))
    (fail 'vector-reverse!:1))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-reverse! v 1)
              v)
            '#(0 3 2 1))
    (fail 'vector-reverse!:2))

(or (equal? (let ((v (vector 0 1 2 3)))
              (vector-reverse! v 1 3)
              v)
            '#(0 2 1 3))
    (fail 'vector-reverse!:3))

(or (equal? (let ((v (vector))
                  (src '#(100 101 102 103 104 105)))
              (vector-copy! v 0 v)
              v)
            '#())
    (fail 'vector-copy!:0))

(or (equal? (let ((v (vector 0 1 2 3 4 5))
                  (src '#(100 101 102 103 104 105)))
              (vector-copy! v 0 src)
              v)
            '#(100 101 102 103 104 105))
    (fail 'vector-copy!:1))

(or (equal? (let ((v (vector 0 1 2 3))
                  (src '#(100 101 102 103 104 105)))
              (vector-copy! v 1 src 4)
              v)
            '#(0 104 105 3))
    (fail 'vector-copy!:2))

(or (equal? (let ((v (vector 0 1 2 3))
                  (src '#(100 101 102 103 104 105)))
              (vector-copy! v 1 src 2 4)
              v)
            '#(0 102 103 3))
    (fail 'vector-copy!:3))

(or (equal? (let ((v (vector))
                  (src '#(100 101 102 103 104 105)))
              (vector-reverse-copy! v 0 v)
              v)
            '#())
    (fail 'vector-reverse-copy!:0))

(or (equal? (let ((v (vector 0 1 2 3 4 5))
                  (src '#(100 101 102 103 104 105)))
              (vector-reverse-copy! v 0 src)
              v)
            '#(105 104 103 102 101 100))
    (fail 'vector-reverse-copy!:1))

(or (equal? (let ((v (vector 0 1 2 3))
                  (src '#(100 101 102 103 104 105)))
              (vector-reverse-copy! v 1 src 4)
              v)
            '#(0 105 104 3))
    (fail 'vector-reverse-copy!:2))

(or (equal? (let ((v (vector 0 1 2 3))
                  (src '#(100 101 102 103 104 105)))
              (vector-reverse-copy! v 1 src 2 4)
              v)
            '#(0 103 102 3))
    (fail 'vector-reverse-copy!:3))

(or (equal? (vector->list '#())
            '())
    (fail 'vector->list:0))

(or (equal? (vector->list '#(a b c))
            '(a b c))
    (fail 'vector->list:1))

(or (equal? (vector->list '#(a b c d e) 1)
            '(b c d e))
    (fail 'vector->list:2))

(or (equal? (vector->list '#(a b c d e) 1 4)
            '(b c d))
    (fail 'vector->list:3))

(or (equal? (reverse-vector->list '#())
            '())
    (fail 'reverse-vector->list:0))

(or (equal? (reverse-vector->list '#(a b c))
            '(c b a))
    (fail 'reverse-vector->list:1))

(or (equal? (reverse-vector->list '#(a b c d e) 1)
            '(e d c b))
    (fail 'reverse-vector->list:2))

(or (equal? (reverse-vector->list '#(a b c d e) 1 3)
            '(c b))
    (fail 'reverse-vector->list:3))

(or (equal? (list->vector '())
            '#())
    (fail 'list->vector:0))

(or (equal? (list->vector '(a b c))
            '#(a b c))
    (fail 'list->vector:1))

(or (equal? (reverse-list->vector '())
            '#())
    (fail 'reverse-list->vector:0))

(or (equal? (reverse-list->vector '(a b c))
            '#(c b a))
    (fail 'reverse-list->vector:1))

(writeln "Done.")
