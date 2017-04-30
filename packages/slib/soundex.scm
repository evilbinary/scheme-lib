;"soundex.scm" Original SOUNDEX algorithm.
;From jjb@isye.gatech.edu Mon May  2 22:29:43 1994
;
; This code is in the public domain.

; Taken from Knuth, Vol. 3 "Sorting and searching", pp 391--2

;;; 2003-01-26  L.J. Buitinck converted to use dotted pairs for codes.

(require 'common-list-functions)
;@
(define SOUNDEX
  (let* ((letters-to-omit
          '(#\A #\E #\H #\I #\O #\U #\W #\Y))
         (codes
          '((#\B . #\1)
            (#\F . #\1)
            (#\P . #\1)
            (#\V . #\1)
            ;;
            (#\C . #\2)
            (#\G . #\2)
            (#\J . #\2)
            (#\K . #\2)
            (#\Q . #\2)
            (#\S . #\2)
            (#\X . #\2)
            (#\Z . #\2)
            ;;
            (#\D . #\3)
            (#\T . #\3)
            ;;
            (#\L . #\4)
            ;;
            (#\M . #\5)
            (#\N . #\5)
            ;;
            (#\R . #\6)))
         (xform
          (lambda (c)
            (let ((code (assv c codes)))
              (if code
                  (cdr code)
                  c)))))
    (lambda (name)
      (let ((char-list
             (map char-upcase
                  (remove-if (lambda (c)
                               (not (char-alphabetic? c)))
                             (string->list name)))))
        (if (null? char-list)
            name
            (let* ( ;; Replace letters except first with codes:
                   (n1 (cons (car char-list) (map xform char-list)))
                   ;; If 2 or more letter with same code are adjacent
                   ;; in the original name, omit all but the first:
                   (n2 (let loop ((chars n1))
                         (cond ((null? (cdr chars))
                                chars)
                               (else
                                (if (char=? (xform (car chars))
                                            (cadr chars))
                                    (loop (cdr chars))
                                    (cons (car chars) (loop (cdr chars))))))))
                   ;; Omit vowels and similar letters, except first:
                   (n3 (cons (car char-list)
                             (remove-if
                              (lambda (c)
                                (memv c letters-to-omit))
                              (cdr n2)))))
              ;;
              ;; pad with 0's or drop rightmost digits until of form "annn":
              (let loop ((rev-chars (reverse n3)))
                (let ((len (length rev-chars)))
                  (cond ((= 4 len)
                         (list->string (reverse rev-chars)))
                        ((> 4 len)
                         (loop (cons #\0 rev-chars)))
                        ((< 4 len)
                         (loop (cdr rev-chars))))))))))))
