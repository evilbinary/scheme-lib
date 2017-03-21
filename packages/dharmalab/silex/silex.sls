; SILex - Scheme Implementation of Lex
; SILex 1.0
; Copyright (C) 2001  Danny Dube'
; 
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

; Module util.scm.

;
; Quelques definitions de constantes
;

(library (dharmalab silex silex)

  (export lex lex-lib)

  (import (rnrs)
          (rnrs mutable-pairs)
          (rnrs mutable-strings)
          (rnrs r5rs))

  (define *library* #f)

  (define eof-tok              0)
  (define hblank-tok           1)
  (define vblank-tok           2)
  (define pipe-tok             3)
  (define question-tok         4)
  (define plus-tok             5)
  (define star-tok             6)
  (define lpar-tok             7)
  (define rpar-tok             8)
  (define dot-tok              9)
  (define lbrack-tok          10)
  (define lbrack-rbrack-tok   11)
  (define lbrack-caret-tok    12)
  (define lbrack-minus-tok    13)
  (define subst-tok           14)
  (define power-tok           15)
  (define doublequote-tok     16)
  (define char-tok            17)
  (define caret-tok           18)
  (define dollar-tok          19)
  (define <<EOF>>-tok         20)
  (define <<ERROR>>-tok       21)
  (define percent-percent-tok 22)
  (define id-tok              23)
  (define rbrack-tok          24)
  (define minus-tok           25)
  (define illegal-tok         26)
                                        ; Tokens agreges
  (define class-tok           27)
  (define string-tok          28)

  (define number-of-tokens 29)

  (define newline-ch   (char->integer #\newline))
  (define tab-ch       (char->integer #\	))
  (define dollar-ch    (char->integer #\$))
  (define minus-ch     (char->integer #\-))
  (define rbrack-ch    (char->integer #\]))
  (define caret-ch     (char->integer #\^))

  (define dot-class (list (cons 'inf- (- newline-ch 1))
                          (cons (+ newline-ch 1) 'inf+)))

  (define default-action
    (string-append "        (yycontinue)" (string #\newline)))
  (define default-<<EOF>>-action
    (string-append "       '(0)" (string #\newline)))
  (define default-<<ERROR>>-action
    (string-append "       (begin"
                   (string #\newline)
                   "         (display \"Error: Invalid token.\")"
                   (string #\newline)
                   "         (newline)"
                   (string #\newline)
                   "         'error)"
                   (string #\newline)))




                                        ;
                                        ; Fabrication de tables de dispatch
                                        ;

  (define make-dispatch-table
    (lambda (size alist default)
      (let ((v (make-vector size default)))
        (let loop ((alist alist))
          (if (null? alist)
              v
              (begin
                (vector-set! v (caar alist) (cdar alist))
                (loop (cdr alist))))))))




                                        ;
                                        ; Fonctions de manipulation des tokens
                                        ;

  (define make-tok
    (lambda (tok-type lexeme line column . attr)
      (cond ((null? attr)
             (vector tok-type line column lexeme))
            ((null? (cdr attr))
             (vector tok-type line column lexeme (car attr)))
            (else
             (vector tok-type line column lexeme (car attr) (cadr attr))))))

  (define get-tok-type     (lambda (tok) (vector-ref tok 0)))
  (define get-tok-line     (lambda (tok) (vector-ref tok 1)))
  (define get-tok-column   (lambda (tok) (vector-ref tok 2)))
  (define get-tok-lexeme   (lambda (tok) (vector-ref tok 3)))
  (define get-tok-attr     (lambda (tok) (vector-ref tok 4)))
  (define get-tok-2nd-attr (lambda (tok) (vector-ref tok 5)))




                                        ;
                                        ; Fonctions de manipulations des regles
                                        ;

  (define make-rule
    (lambda (line eof? error? bol? eol? regexp action)
      (vector line eof? error? bol? eol? regexp action #f)))

  (define get-rule-line    (lambda (rule) (vector-ref rule 0)))
  (define get-rule-eof?    (lambda (rule) (vector-ref rule 1)))
  (define get-rule-error?  (lambda (rule) (vector-ref rule 2)))
  (define get-rule-bol?    (lambda (rule) (vector-ref rule 3)))
  (define get-rule-eol?    (lambda (rule) (vector-ref rule 4)))
  (define get-rule-regexp  (lambda (rule) (vector-ref rule 5)))
  (define get-rule-action  (lambda (rule) (vector-ref rule 6)))
  (define get-rule-yytext? (lambda (rule) (vector-ref rule 7)))

  (define set-rule-regexp  (lambda (rule regexp)  (vector-set! rule 5 regexp)))
  (define set-rule-action  (lambda (rule action)  (vector-set! rule 6 action)))
  (define set-rule-yytext? (lambda (rule yytext?) (vector-set! rule 7 yytext?)))




                                        ;
                                        ; Noeuds des regexp
                                        ;

  (define epsilon-re  0)
  (define or-re       1)
  (define conc-re     2)
  (define star-re     3)
  (define plus-re     4)
  (define question-re 5)
  (define class-re    6)
  (define char-re     7)

  (define make-re
    (lambda (re-type . lattr)
      (cond ((null? lattr)
             (vector re-type))
            ((null? (cdr lattr))
             (vector re-type (car lattr)))
            ((null? (cddr lattr))
             (vector re-type (car lattr) (cadr lattr))))))

  (define get-re-type  (lambda (re) (vector-ref re 0)))
  (define get-re-attr1 (lambda (re) (vector-ref re 1)))
  (define get-re-attr2 (lambda (re) (vector-ref re 2)))




                                        ;
                                        ; Fonctions de manipulation des ensembles d'etats
                                        ;

                                        ; Intersection de deux ensembles d'etats
  (define ss-inter
    (lambda (ss1 ss2)
      (cond ((null? ss1)
             '())
            ((null? ss2)
             '())
            (else
             (let ((t1 (car ss1))
                   (t2 (car ss2)))
               (cond ((< t1 t2)
                      (ss-inter (cdr ss1) ss2))
                     ((= t1 t2)
                      (cons t1 (ss-inter (cdr ss1) (cdr ss2))))
                     (else
                      (ss-inter ss1 (cdr ss2)))))))))

                                        ; Difference entre deux ensembles d'etats
  (define ss-diff
    (lambda (ss1 ss2)
      (cond ((null? ss1)
             '())
            ((null? ss2)
             ss1)
            (else
             (let ((t1 (car ss1))
                   (t2 (car ss2)))
               (cond ((< t1 t2)
                      (cons t1 (ss-diff (cdr ss1) ss2)))
                     ((= t1 t2)
                      (ss-diff (cdr ss1) (cdr ss2)))
                     (else
                      (ss-diff ss1 (cdr ss2)))))))))

                                        ; Union de deux ensembles d'etats
  (define ss-union
    (lambda (ss1 ss2)
      (cond ((null? ss1)
             ss2)
            ((null? ss2)
             ss1)
            (else
             (let ((t1 (car ss1))
                   (t2 (car ss2)))
               (cond ((< t1 t2)
                      (cons t1 (ss-union (cdr ss1) ss2)))
                     ((= t1 t2)
                      (cons t1 (ss-union (cdr ss1) (cdr ss2))))
                     (else
                      (cons t2 (ss-union ss1 (cdr ss2))))))))))

                                        ; Decoupage de deux ensembles d'etats
  (define ss-sep
    (lambda (ss1 ss2)
      (let loop ((ss1 ss1) (ss2 ss2) (l '()) (c '()) (r '()))
        (if (null? ss1)
            (if (null? ss2)
                (vector (reverse l) (reverse c) (reverse r))
                (loop ss1 (cdr ss2) l c (cons (car ss2) r)))
            (if (null? ss2)
                (loop (cdr ss1) ss2 (cons (car ss1) l) c r)
                (let ((t1 (car ss1))
                      (t2 (car ss2)))
                  (cond ((< t1 t2)
                         (loop (cdr ss1) ss2 (cons t1 l) c r))
                        ((= t1 t2)
                         (loop (cdr ss1) (cdr ss2) l (cons t1 c) r))
                        (else
                         (loop ss1 (cdr ss2) l c (cons t2 r))))))))))




                                        ;
                                        ; Fonctions de manipulation des classes de caracteres
                                        ;

                                        ; Comparaisons de bornes d'intervalles
  (define class-= eqv?)

  (define class-<=
    (lambda (b1 b2)
      (cond ((eq? b1 'inf-) #t)
            ((eq? b2 'inf+) #t)
            ((eq? b1 'inf+) #f)
            ((eq? b2 'inf-) #f)
            (else (<= b1 b2)))))

  (define class->=
    (lambda (b1 b2)
      (cond ((eq? b1 'inf+) #t)
            ((eq? b2 'inf-) #t)
            ((eq? b1 'inf-) #f)
            ((eq? b2 'inf+) #f)
            (else (>= b1 b2)))))

  (define class-<
    (lambda (b1 b2)
      (cond ((eq? b1 'inf+) #f)
            ((eq? b2 'inf-) #f)
            ((eq? b1 'inf-) #t)
            ((eq? b2 'inf+) #t)
            (else (< b1 b2)))))

  (define class->
    (lambda (b1 b2)
      (cond ((eq? b1 'inf-) #f)
            ((eq? b2 'inf+) #f)
            ((eq? b1 'inf+) #t)
            ((eq? b2 'inf-) #t)
            (else (> b1 b2)))))

                                        ; Complementation d'une classe
  (define class-compl
    (lambda (c)
      (let loop ((c c) (start 'inf-))
        (if (null? c)
            (list (cons start 'inf+))
            (let* ((r (car c))
                   (rstart (car r))
                   (rend (cdr r)))
              (if (class-< start rstart)
                  (cons (cons start (- rstart 1))
                        (loop c rstart))
                  (if (class-< rend 'inf+)
                      (loop (cdr c) (+ rend 1))
                      '())))))))

                                        ; Union de deux classes de caracteres
  (define class-union
    (lambda (c1 c2)
      (let loop ((c1 c1) (c2 c2) (u '()))
        (if (null? c1)
            (if (null? c2)
                (reverse u)
                (loop c1 (cdr c2) (cons (car c2) u)))
            (if (null? c2)
                (loop (cdr c1) c2 (cons (car c1) u))
                (let* ((r1 (car c1))
                       (r2 (car c2))
                       (r1start (car r1))
                       (r1end (cdr r1))
                       (r2start (car r2))
                       (r2end (cdr r2)))
                  (if (class-<= r1start r2start)
                      (cond ((class-= r1end 'inf+)
                             (loop c1 (cdr c2) u))
                            ((class-< (+ r1end 1) r2start)
                             (loop (cdr c1) c2 (cons r1 u)))
                            ((class-<= r1end r2end)
                             (loop (cdr c1)
                                   (cons (cons r1start r2end) (cdr c2))
                                   u))
                            (else
                             (loop c1 (cdr c2) u)))
                      (cond ((class-= r2end 'inf+)
                             (loop (cdr c1) c2 u))
                            ((class-> r1start (+ r2end 1))
                             (loop c1 (cdr c2) (cons r2 u)))
                            ((class->= r1end r2end)
                             (loop (cons (cons r2start r1end) (cdr c1))
                                   (cdr c2)
                                   u))
                            (else
                             (loop (cdr c1) c2 u))))))))))

                                        ; Decoupage de deux classes de caracteres
  (define class-sep
    (lambda (c1 c2)
      (let loop ((c1 c1) (c2 c2) (l '()) (c '()) (r '()))
        (if (null? c1)
            (if (null? c2)
                (vector (reverse l) (reverse c) (reverse r))
                (loop c1 (cdr c2) l c (cons (car c2) r)))
            (if (null? c2)
                (loop (cdr c1) c2 (cons (car c1) l) c r)
                (let* ((r1 (car c1))
                       (r2 (car c2))
                       (r1start (car r1))
                       (r1end (cdr r1))
                       (r2start (car r2))
                       (r2end (cdr r2)))
                  (cond ((class-< r1start r2start)
                         (if (class-< r1end r2start)
                             (loop (cdr c1) c2 (cons r1 l) c r)
                             (loop (cons (cons r2start r1end) (cdr c1)) c2
                                   (cons (cons r1start (- r2start 1)) l) c r)))
                        ((class-> r1start r2start)
                         (if (class-> r1start r2end)
                             (loop c1 (cdr c2) l c (cons r2 r))
                             (loop c1 (cons (cons r1start r2end) (cdr c2))
                                   l c (cons (cons r2start (- r1start 1)) r))))
                        (else
                         (cond ((class-< r1end r2end)
                                (loop (cdr c1)
                                      (cons (cons (+ r1end 1) r2end) (cdr c2))
                                      l (cons r1 c) r))
                               ((class-= r1end r2end)
                                (loop (cdr c1) (cdr c2) l (cons r1 c) r))
                               (else
                                (loop (cons (cons (+ r2end 1) r1end) (cdr c1))
                                      (cdr c2)
                                      l (cons r2 c) r)))))))))))

                                        ; Transformer une classe (finie) de caracteres en une liste de ...
  (define class->char-list
    (lambda (c)
      (let loop1 ((c c))
        (if (null? c)
            '()
            (let* ((r (car c))
                   (rend (cdr r))
                   (tail (loop1 (cdr c))))
              (let loop2 ((rstart (car r)))
                (if (<= rstart rend)
                    (cons (integer->char rstart) (loop2 (+ rstart 1)))
                    tail)))))))

                                        ; Transformer une classe de caracteres en une liste poss. compl.
                                        ; 1er element = #t -> classe complementee
  (define class->tagged-char-list
    (lambda (c)
      (let* ((finite? (or (null? c) (number? (caar c))))
             (c2 (if finite? c (class-compl c)))
             (c-l (class->char-list c2)))
        (cons (not finite?) c-l))))




                                        ;
                                        ; Fonction digraph
                                        ;

                                        ; Fonction "digraph".
                                        ; Etant donne un graphe dirige dont les noeuds comportent une valeur,
                                        ; calcule pour chaque noeud la "somme" des valeurs contenues dans le
                                        ; noeud lui-meme et ceux atteignables a partir de celui-ci.  La "somme"
                                        ; consiste a appliquer un operateur commutatif et associatif aux valeurs
                                        ; lorsqu'elles sont additionnees.
                                        ; L'entree consiste en un vecteur de voisinages externes, un autre de
                                        ; valeurs initiales et d'un operateur.
                                        ; La sortie est un vecteur de valeurs finales.
  (define digraph
    (lambda (arcs init op)
      (let* ((nbnodes (vector-length arcs))
             (infinity nbnodes)
             (prio (make-vector nbnodes -1))
             (stack (make-vector nbnodes #f))
             (sp 0)
             (final (make-vector nbnodes #f)))
        (letrec ((store-final
                  (lambda (self-sp value)
                    (let loop ()
                      (if (> sp self-sp)
                          (let ((voisin (vector-ref stack (- sp 1))))
                            (vector-set! prio voisin infinity)
                            (set! sp (- sp 1))
                            (vector-set! final voisin value)
                            (loop))))))
                 (visit-node
                  (lambda (n)
                    (let ((self-sp sp))
                      (vector-set! prio n self-sp)
                      (vector-set! stack sp n)
                      (set! sp (+ sp 1))
                      (vector-set! final n (vector-ref init n))
                      (let loop ((vois (vector-ref arcs n)))
                        (if (pair? vois)
                            (let* ((v (car vois))
                                   (vprio (vector-ref prio v)))
                              (if (= vprio -1)
                                  (visit-node v))
                              (vector-set! prio n (min (vector-ref prio n)
                                                       (vector-ref prio v)))
                              (vector-set! final n (op (vector-ref final n)
                                                       (vector-ref final v)))
                              (loop (cdr vois)))))
                      (if (= (vector-ref prio n) self-sp)
                          (store-final self-sp (vector-ref final n)))))))
          (let loop ((n 0))
            (if (< n nbnodes)
                (begin
                  (if (= (vector-ref prio n) -1)
                      (visit-node n))
                  (loop (+ n 1)))))
          final))))




                                        ;
                                        ; Fonction de tri
                                        ;

  (define merge-sort-merge
    (lambda (l1 l2 cmp-<=)
      (cond ((null? l1)
             l2)
            ((null? l2)
             l1)
            (else
             (let ((h1 (car l1))
                   (h2 (car l2)))
               (if (cmp-<= h1 h2)
                   (cons h1 (merge-sort-merge (cdr l1) l2 cmp-<=))
                   (cons h2 (merge-sort-merge l1 (cdr l2) cmp-<=))))))))

  (define merge-sort
    (lambda (l cmp-<=)
      (if (null? l)
          l
          (let loop1 ((ll (map list l)))
            (if (null? (cdr ll))
                (car ll)
                (loop1
                 (let loop2 ((ll ll))
                   (cond ((null? ll)
                          ll)
                         ((null? (cdr ll))
                          ll)
                         (else
                          (cons (merge-sort-merge (car ll) (cadr ll) cmp-<=)
                                (loop2 (cddr ll))))))))))))

                                        ; Module action.l.scm.

  (define action-tables
    (vector
     'all
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (make-tok eof-tok    yytext yyline yycolumn)
         ))
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (begin
           (display "Error: Invalid token.")
           (newline)
           'error)
         ))
     (vector
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok hblank-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok vblank-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok char-tok   yytext yyline yycolumn)
          )))
     'tagged-chars-lists
     0
     0
     '#((((#f #\	 #\space) . 4)
         ((#f #\;) . 3)
         ((#f #\newline) . 2)
         ((#t #\	 #\newline #\space #\;) . 1))
        (((#t #\newline) . 1))
        ()
        (((#t #\newline) . 3))
        (((#f #\	 #\space) . 4)
         ((#f #\;) . 3)
         ((#t #\	 #\newline #\space #\;) . 1)))
     '#((#f . #f) (2 . 2) (1 . 1) (0 . 0) (0 . 0))))

                                        ; Module class.l.scm.

  (define class-tables
    (vector
     'all
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (make-tok eof-tok    yytext yyline yycolumn)
         ))
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (begin
           (display "Error: Invalid token.")
           (newline)
           'error)
         ))
     (vector
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok rbrack-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok minus-tok  yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-spec-char     yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char   yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char   yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-quoted-char   yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-ordinary-char yytext yyline yycolumn)
          )))
     'tagged-chars-lists
     0
     0
     '#((((#f #\]) . 4) ((#f #\-) . 3) ((#f #\\) . 2) ((#t #\- #\\ #\]) . 1))
        ()
        (((#f #\n) . 8)
         ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 7)
         ((#f #\-) . 6)
         ((#t #\- #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\n) . 5))
        ()
        ()
        ()
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 9))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 10))
        ()
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 9))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 10)))
     '#((#f . #f) (6 . 6)   (6 . 6)   (1 . 1)   (0 . 0)   (5 . 5)   (5 . 5)
        (3 . 3)   (2 . 2)   (4 . 4)   (3 . 3))))

                                        ; Module macro.l.scm.

  (define macro-tables
    (vector
     'all
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (make-tok eof-tok             yytext yyline yycolumn)
         ))
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (begin
           (display "Error: Invalid token.")
           (newline)
           'error)
         ))
     (vector
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok hblank-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok vblank-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok percent-percent-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-id                     yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok illegal-tok         yytext yyline yycolumn)
          )))
     'tagged-chars-lists
     0
     0
     '#((((#f #\	 #\space) . 8)
         ((#f #\;) . 7)
         ((#f #\newline) . 6)
         ((#f #\%) . 5)
         ((#f  #\! #\$ #\& #\* #\/ #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E
               #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U
               #\V #\W #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i
               #\j #\k #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y
               #\z #\~)
          .
          4)
         ((#f #\+ #\-) . 3)
         ((#f #\.) . 2)
         ((#t        #\	       #\newline #\space   #\!       #\$
                     #\%       #\&       #\*       #\+       #\-       #\.
                     #\/       #\:       #\;       #\<       #\=       #\>
                     #\?       #\A       #\B       #\C       #\D       #\E
                     #\F       #\G       #\H       #\I       #\J       #\K
                     #\L       #\M       #\N       #\O       #\P       #\Q
                     #\R       #\S       #\T       #\U       #\V       #\W
                     #\X       #\Y       #\Z       #\^       #\_       #\a
                     #\b       #\c       #\d       #\e       #\f       #\g
                     #\h       #\i       #\j       #\k       #\l       #\m
                     #\n       #\o       #\p       #\q       #\r       #\s
                     #\t       #\u       #\v       #\w       #\x       #\y
                     #\z       #\~)
          .
          1))
        ()
        (((#f #\.) . 9))
        ()
        (((#f  #\! #\$ #\% #\& #\* #\+ #\- #\. #\/ #\0 #\1 #\2 #\3 #\4 #\5
               #\6 #\7 #\8 #\9 #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E #\F #\G
               #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W
               #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k
               #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z #\~)
          .
          10))
        (((#f #\%) . 11)
         ((#f  #\! #\$ #\& #\* #\+ #\- #\. #\/ #\0 #\1 #\2 #\3 #\4 #\5 #\6
               #\7 #\8 #\9 #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E #\F #\G #\H
               #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W #\X
               #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l
               #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z #\~)
          .
          10))
        ()
        (((#t #\newline) . 12))
        ()
        (((#f #\.) . 13))
        (((#f  #\! #\$ #\% #\& #\* #\+ #\- #\. #\/ #\0 #\1 #\2 #\3 #\4 #\5
               #\6 #\7 #\8 #\9 #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E #\F #\G
               #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W
               #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k
               #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z #\~)
          .
          10))
        (((#f  #\! #\$ #\% #\& #\* #\+ #\- #\. #\/ #\0 #\1 #\2 #\3 #\4 #\5
               #\6 #\7 #\8 #\9 #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E #\F #\G
               #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W
               #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k
               #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z #\~)
          .
          10))
        (((#t #\newline) . 12))
        ())
     '#((#f . #f) (4 . 4)   (4 . 4)   (3 . 3)   (3 . 3)   (3 . 3)   (1 . 1)
        (0 . 0)   (0 . 0)   (#f . #f) (3 . 3)   (2 . 2)   (0 . 0)   (3 . 3))))

                                        ; Module regexp.l.scm.

  (define regexp-tables
    (vector
     'all
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (make-tok eof-tok           yytext yyline yycolumn)
         ))
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (begin
           (display "Error: Invalid token.")
           (newline)
           'error)
         ))
     (vector
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok hblank-tok        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok vblank-tok        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok pipe-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok question-tok      yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok plus-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok star-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok lpar-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok rpar-tok          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok dot-tok           yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok lbrack-tok        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok lbrack-rbrack-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok lbrack-caret-tok  yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok lbrack-minus-tok  yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-id-ref               yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-power-m              yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-power-m-inf          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-power-m-n            yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok illegal-tok       yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok doublequote-tok   yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-spec-char            yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-quoted-char          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok caret-tok         yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok dollar-tok        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-ordinary-char        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok <<EOF>>-tok       yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok <<ERROR>>-tok     yytext yyline yycolumn)
          )))
     'tagged-chars-lists
     0
     0
     '#((((#f #\	 #\space) . 18)
         ((#f #\;) . 17)
         ((#f #\newline) . 16)
         ((#f #\|) . 15)
         ((#f #\?) . 14)
         ((#f #\+) . 13)
         ((#f #\*) . 12)
         ((#f #\() . 11)
         ((#f #\)) . 10)
         ((#f #\.) . 9)
         ((#f #\[) . 8)
         ((#f #\{) . 7)
         ((#f #\") . 6)
         ((#f #\\) . 5)
         ((#f #\^) . 4)
         ((#f #\$) . 3)
         ((#t        #\	       #\newline #\space   #\"       #\$
                     #\(       #\)       #\*       #\+       #\.       #\;
                     #\<       #\?       #\[       #\\       #\^       #\{
                     #\|)
          .
          2)
         ((#f #\<) . 1))
        (((#f #\<) . 19))
        ()
        ()
        ()
        (((#f #\n) . 23)
         ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 22)
         ((#f #\-) . 21)
         ((#t #\- #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\n) . 20))
        ()
        (((#f  #\! #\$ #\% #\& #\* #\/ #\: #\< #\= #\> #\? #\A #\B #\C #\D
               #\E #\F #\G #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T
               #\U #\V #\W #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h
               #\i #\j #\k #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x
               #\y #\z #\~)
          .
          27)
         ((#f #\+ #\-) . 26)
         ((#f #\.) . 25)
         ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 24))
        (((#f #\]) . 30) ((#f #\^) . 29) ((#f #\-) . 28))
        ()
        ()
        ()
        ()
        ()
        ()
        ()
        ()
        (((#t #\newline) . 31))
        ()
        (((#f #\E) . 32))
        ()
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 33))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 34))
        ()
        (((#f #\}) . 36)
         ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 24)
         ((#f #\,) . 35))
        (((#f #\.) . 37))
        (((#f #\}) . 38))
        (((#f #\}) . 38)
         ((#f  #\! #\$ #\% #\& #\* #\+ #\- #\. #\/ #\0 #\1 #\2 #\3 #\4 #\5
               #\6 #\7 #\8 #\9 #\: #\< #\= #\> #\? #\A #\B #\C #\D #\E #\F #\G
               #\H #\I #\J #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V #\W
               #\X #\Y #\Z #\^ #\_ #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k
               #\l #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x #\y #\z #\~)
          .
          27))
        ()
        ()
        ()
        (((#t #\newline) . 31))
        (((#f #\O) . 40) ((#f #\R) . 39))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 33))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 34))
        (((#f #\}) . 42) ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 41))
        ()
        (((#f #\.) . 26))
        ()
        (((#f #\R) . 43))
        (((#f #\F) . 44))
        (((#f #\}) . 45) ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 41))
        ()
        (((#f #\O) . 46))
        (((#f #\>) . 47))
        ()
        (((#f #\R) . 48))
        (((#f #\>) . 49))
        (((#f #\>) . 50))
        ()
        (((#f #\>) . 51))
        ())
     '#((#f . #f) (25 . 25) (25 . 25) (24 . 24) (23 . 23) (25 . 25) (18 . 18)
        (17 . 17) (9 . 9)   (8 . 8)   (7 . 7)   (6 . 6)   (5 . 5)   (4 . 4)
        (3 . 3)   (2 . 2)   (1 . 1)   (0 . 0)   (0 . 0)   (#f . #f) (22 . 22)
        (22 . 22) (20 . 20) (19 . 19) (#f . #f) (#f . #f) (#f . #f) (#f . #f)
        (12 . 12) (11 . 11) (10 . 10) (0 . 0)   (#f . #f) (21 . 21) (20 . 20)
        (#f . #f) (14 . 14) (#f . #f) (13 . 13) (#f . #f) (#f . #f) (#f . #f)
        (15 . 15) (#f . #f) (#f . #f) (16 . 16) (#f . #f) (#f . #f) (#f . #f)
        (26 . 26) (#f . #f) (27 . 27))))

                                        ; Module string.l.scm.

  (define string-tables
    (vector
     'all
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (make-tok eof-tok         yytext yyline yycolumn)
         ))
     (lambda (yycontinue yygetc yyungetc)
       (lambda (yytext yyline yycolumn yyoffset)
         (begin
           (display "Error: Invalid token.")
           (newline)
           'error)
         ))
     (vector
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (make-tok doublequote-tok yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-spec-char          yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-digits-char        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-quoted-char        yytext yyline yycolumn)
          ))
      #t
      (lambda (yycontinue yygetc yyungetc)
        (lambda (yytext yyline yycolumn yyoffset)
          (parse-ordinary-char      yytext yyline yycolumn)
          )))
     'tagged-chars-lists
     0
     0
     '#((((#f #\") . 3) ((#f #\\) . 2) ((#t #\" #\\) . 1))
        ()
        (((#f #\n) . 7)
         ((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 6)
         ((#f #\-) . 5)
         ((#t #\- #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\n) . 4))
        ()
        ()
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 8))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 9))
        ()
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 8))
        (((#f #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9) . 9)))
     '#((#f . #f) (5 . 5)   (5 . 5)   (0 . 0)   (4 . 4)   (4 . 4)   (2 . 2)
        (1 . 1)   (3 . 3)   (2 . 2))))

                                        ; Module multilex.scm.

                                        ;
                                        ; Gestion des Input Systems
                                        ; Fonctions a utiliser par l'usager:
                                        ;   lexer-make-IS, lexer-get-func-getc, lexer-get-func-ungetc,
                                        ;   lexer-get-func-line, lexer-get-func-column et lexer-get-func-offset
                                        ;

                                        ; Taille initiale par defaut du buffer d'entree
  (define lexer-init-buffer-len 1024)

                                        ; Numero du caractere newline
  (define lexer-integer-newline (char->integer #\newline))

                                        ; Constructeur d'IS brut
  (define lexer-raw-IS-maker
    (lambda (buffer read-ptr input-f counters)
      (let ((input-f          input-f)                ; Entree reelle
            (buffer           buffer)                 ; Buffer
            (buflen           (string-length buffer))
            (read-ptr         read-ptr)
            (start-ptr        1)                      ; Marque de debut de lexeme
            (start-line       1)
            (start-column     1)
            (start-offset     0)
            (end-ptr          1)                      ; Marque de fin de lexeme
            (point-ptr        1)                      ; Le point
            (user-ptr         1)                      ; Marque de l'usager
            (user-line        1)
            (user-column      1)
            (user-offset      0)
            (user-up-to-date? #t))                    ; Concerne la colonne seul.
        (letrec
            ((start-go-to-end-none         ; Fonctions de depl. des marques
              (lambda ()
                (set! start-ptr end-ptr)))
             (start-go-to-end-line
              (lambda ()
                (let loop ((ptr start-ptr) (line start-line))
                  (if (= ptr end-ptr)
                      (begin
                        (set! start-ptr ptr)
                        (set! start-line line))
                      (if (char=? (string-ref buffer ptr) #\newline)
                          (loop (+ ptr 1) (+ line 1))
                          (loop (+ ptr 1) line))))))
             (start-go-to-end-all
              (lambda ()
                (set! start-offset (+ start-offset (- end-ptr start-ptr)))
                (let loop ((ptr start-ptr)
                           (line start-line)
                           (column start-column))
                  (if (= ptr end-ptr)
                      (begin
                        (set! start-ptr ptr)
                        (set! start-line line)
                        (set! start-column column))
                      (if (char=? (string-ref buffer ptr) #\newline)
                          (loop (+ ptr 1) (+ line 1) 1)
                          (loop (+ ptr 1) line (+ column 1)))))))
             (start-go-to-user-none
              (lambda ()
                (set! start-ptr user-ptr)))
             (start-go-to-user-line
              (lambda ()
                (set! start-ptr user-ptr)
                (set! start-line user-line)))
             (start-go-to-user-all
              (lambda ()
                (set! start-line user-line)
                (set! start-offset user-offset)
                (if user-up-to-date?
                    (begin
                      (set! start-ptr user-ptr)
                      (set! start-column user-column))
                    (let loop ((ptr start-ptr) (column start-column))
                      (if (= ptr user-ptr)
                          (begin
                            (set! start-ptr ptr)
                            (set! start-column column))
                          (if (char=? (string-ref buffer ptr) #\newline)
                              (loop (+ ptr 1) 1)
                              (loop (+ ptr 1) (+ column 1))))))))
             (end-go-to-point
              (lambda ()
                (set! end-ptr point-ptr)))
             (point-go-to-start
              (lambda ()
                (set! point-ptr start-ptr)))
             (user-go-to-start-none
              (lambda ()
                (set! user-ptr start-ptr)))
             (user-go-to-start-line
              (lambda ()
                (set! user-ptr start-ptr)
                (set! user-line start-line)))
             (user-go-to-start-all
              (lambda ()
                (set! user-ptr start-ptr)
                (set! user-line start-line)
                (set! user-column start-column)
                (set! user-offset start-offset)
                (set! user-up-to-date? #t)))
             (init-lexeme-none             ; Debute un nouveau lexeme
              (lambda ()
                (if (< start-ptr user-ptr)
                    (start-go-to-user-none))
                (point-go-to-start)))
             (init-lexeme-line
              (lambda ()
                (if (< start-ptr user-ptr)
                    (start-go-to-user-line))
                (point-go-to-start)))
             (init-lexeme-all
              (lambda ()
                (if (< start-ptr user-ptr)
                    (start-go-to-user-all))
                (point-go-to-start)))
             (get-start-line               ; Obtention des stats du debut du lxm
              (lambda ()
                start-line))
             (get-start-column
              (lambda ()
                start-column))
             (get-start-offset
              (lambda ()
                start-offset))
             (peek-left-context            ; Obtention de caracteres (#f si EOF)
              (lambda ()
                (char->integer (string-ref buffer (- start-ptr 1)))))
             (peek-char
              (lambda ()
                (if (< point-ptr read-ptr)
                    (char->integer (string-ref buffer point-ptr))
                    (let ((c (input-f)))
                      (if (char? c)
                          (begin
                            (if (= read-ptr buflen)
                                (reorganize-buffer))
                            (string-set! buffer point-ptr c)
                            (set! read-ptr (+ point-ptr 1))
                            (char->integer c))
                          (begin
                            (set! input-f (lambda () 'eof))
                            #f))))))
             (read-char
              (lambda ()
                (if (< point-ptr read-ptr)
                    (let ((c (string-ref buffer point-ptr)))
                      (set! point-ptr (+ point-ptr 1))
                      (char->integer c))
                    (let ((c (input-f)))
                      (if (char? c)
                          (begin
                            (if (= read-ptr buflen)
                                (reorganize-buffer))
                            (string-set! buffer point-ptr c)
                            (set! read-ptr (+ point-ptr 1))
                            (set! point-ptr read-ptr)
                            (char->integer c))
                          (begin
                            (set! input-f (lambda () 'eof))
                            #f))))))
             (get-start-end-text           ; Obtention du lexeme
              (lambda ()
                (substring buffer start-ptr end-ptr)))
             (get-user-line-line           ; Fonctions pour l'usager
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-line))
                user-line))
             (get-user-line-all
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-all))
                user-line))
             (get-user-column-all
              (lambda ()
                (cond ((< user-ptr start-ptr)
                       (user-go-to-start-all)
                       user-column)
                      (user-up-to-date?
                       user-column)
                      (else
                       (let loop ((ptr start-ptr) (column start-column))
                         (if (= ptr user-ptr)
                             (begin
                               (set! user-column column)
                               (set! user-up-to-date? #t)
                               column)
                             (if (char=? (string-ref buffer ptr) #\newline)
                                 (loop (+ ptr 1) 1)
                                 (loop (+ ptr 1) (+ column 1)))))))))
             (get-user-offset-all
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-all))
                user-offset))
             (user-getc-none
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-none))
                (if (< user-ptr read-ptr)
                    (let ((c (string-ref buffer user-ptr)))
                      (set! user-ptr (+ user-ptr 1))
                      c)
                    (let ((c (input-f)))
                      (if (char? c)
                          (begin
                            (if (= read-ptr buflen)
                                (reorganize-buffer))
                            (string-set! buffer user-ptr c)
                            (set! read-ptr (+ read-ptr 1))
                            (set! user-ptr read-ptr)
                            c)
                          (begin
                            (set! input-f (lambda () 'eof))
                            'eof))))))
             (user-getc-line
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-line))
                (if (< user-ptr read-ptr)
                    (let ((c (string-ref buffer user-ptr)))
                      (set! user-ptr (+ user-ptr 1))
                      (if (char=? c #\newline)
                          (set! user-line (+ user-line 1)))
                      c)
                    (let ((c (input-f)))
                      (if (char? c)
                          (begin
                            (if (= read-ptr buflen)
                                (reorganize-buffer))
                            (string-set! buffer user-ptr c)
                            (set! read-ptr (+ read-ptr 1))
                            (set! user-ptr read-ptr)
                            (if (char=? c #\newline)
                                (set! user-line (+ user-line 1)))
                            c)
                          (begin
                            (set! input-f (lambda () 'eof))
                            'eof))))))
             (user-getc-all
              (lambda ()
                (if (< user-ptr start-ptr)
                    (user-go-to-start-all))
                (if (< user-ptr read-ptr)
                    (let ((c (string-ref buffer user-ptr)))
                      (set! user-ptr (+ user-ptr 1))
                      (if (char=? c #\newline)
                          (begin
                            (set! user-line (+ user-line 1))
                            (set! user-column 1))
                          (set! user-column (+ user-column 1)))
                      (set! user-offset (+ user-offset 1))
                      c)
                    (let ((c (input-f)))
                      (if (char? c)
                          (begin
                            (if (= read-ptr buflen)
                                (reorganize-buffer))
                            (string-set! buffer user-ptr c)
                            (set! read-ptr (+ read-ptr 1))
                            (set! user-ptr read-ptr)
                            (if (char=? c #\newline)
                                (begin
                                  (set! user-line (+ user-line 1))
                                  (set! user-column 1))
                                (set! user-column (+ user-column 1)))
                            (set! user-offset (+ user-offset 1))
                            c)
                          (begin
                            (set! input-f (lambda () 'eof))
                            'eof))))))
             (user-ungetc-none
              (lambda ()
                (if (> user-ptr start-ptr)
                    (set! user-ptr (- user-ptr 1)))))
             (user-ungetc-line
              (lambda ()
                (if (> user-ptr start-ptr)
                    (begin
                      (set! user-ptr (- user-ptr 1))
                      (let ((c (string-ref buffer user-ptr)))
                        (if (char=? c #\newline)
                            (set! user-line (- user-line 1))))))))
             (user-ungetc-all
              (lambda ()
                (if (> user-ptr start-ptr)
                    (begin
                      (set! user-ptr (- user-ptr 1))
                      (let ((c (string-ref buffer user-ptr)))
                        (if (char=? c #\newline)
                            (begin
                              (set! user-line (- user-line 1))
                              (set! user-up-to-date? #f))
                            (set! user-column (- user-column 1)))
                        (set! user-offset (- user-offset 1)))))))
             (reorganize-buffer            ; Decaler ou agrandir le buffer
              (lambda ()
                (if (< (* 2 start-ptr) buflen)
                    (let* ((newlen (* 2 buflen))
                           (newbuf (make-string newlen))
                           (delta (- start-ptr 1)))
                      (let loop ((from (- start-ptr 1)))
                        (if (< from buflen)
                            (begin
                              (string-set! newbuf
                                           (- from delta)
                                           (string-ref buffer from))
                              (loop (+ from 1)))))
                      (set! buffer    newbuf)
                      (set! buflen    newlen)
                      (set! read-ptr  (- read-ptr delta))
                      (set! start-ptr (- start-ptr delta))
                      (set! end-ptr   (- end-ptr delta))
                      (set! point-ptr (- point-ptr delta))
                      (set! user-ptr  (- user-ptr delta)))
                    (let ((delta (- start-ptr 1)))
                      (let loop ((from (- start-ptr 1)))
                        (if (< from buflen)
                            (begin
                              (string-set! buffer
                                           (- from delta)
                                           (string-ref buffer from))
                              (loop (+ from 1)))))
                      (set! read-ptr  (- read-ptr delta))
                      (set! start-ptr (- start-ptr delta))
                      (set! end-ptr   (- end-ptr delta))
                      (set! point-ptr (- point-ptr delta))
                      (set! user-ptr  (- user-ptr delta)))))))
          (list (cons 'start-go-to-end
                      (cond ((eq? counters 'none) start-go-to-end-none)
                            ((eq? counters 'line) start-go-to-end-line)
                            ((eq? counters 'all ) start-go-to-end-all)))
                (cons 'end-go-to-point
                      end-go-to-point)
                (cons 'init-lexeme
                      (cond ((eq? counters 'none) init-lexeme-none)
                            ((eq? counters 'line) init-lexeme-line)
                            ((eq? counters 'all ) init-lexeme-all)))
                (cons 'get-start-line
                      get-start-line)
                (cons 'get-start-column
                      get-start-column)
                (cons 'get-start-offset
                      get-start-offset)
                (cons 'peek-left-context
                      peek-left-context)
                (cons 'peek-char
                      peek-char)
                (cons 'read-char
                      read-char)
                (cons 'get-start-end-text
                      get-start-end-text)
                (cons 'get-user-line
                      (cond ((eq? counters 'none) #f)
                            ((eq? counters 'line) get-user-line-line)
                            ((eq? counters 'all ) get-user-line-all)))
                (cons 'get-user-column
                      (cond ((eq? counters 'none) #f)
                            ((eq? counters 'line) #f)
                            ((eq? counters 'all ) get-user-column-all)))
                (cons 'get-user-offset
                      (cond ((eq? counters 'none) #f)
                            ((eq? counters 'line) #f)
                            ((eq? counters 'all ) get-user-offset-all)))
                (cons 'user-getc
                      (cond ((eq? counters 'none) user-getc-none)
                            ((eq? counters 'line) user-getc-line)
                            ((eq? counters 'all ) user-getc-all)))
                (cons 'user-ungetc
                      (cond ((eq? counters 'none) user-ungetc-none)
                            ((eq? counters 'line) user-ungetc-line)
                            ((eq? counters 'all ) user-ungetc-all))))))))

                                        ; Construit un Input System
                                        ; Le premier parametre doit etre parmi "port", "procedure" ou "string"
                                        ; Prend un parametre facultatif qui doit etre parmi
                                        ; "none", "line" ou "all"
  (define lexer-make-IS
    (lambda (input-type input . largs)
      (let ((counters-type (cond ((null? largs)
                                  'line)
                                 ((memq (car largs) '(none line all))
                                  (car largs))
                                 (else
                                  'line))))
        (cond ((and (eq? input-type 'port) (input-port? input))
               (let* ((buffer   (make-string lexer-init-buffer-len #\newline))
                      (read-ptr 1)
                      (input-f  (lambda () (read-char input))))
                 (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
              ((and (eq? input-type 'procedure) (procedure? input))
               (let* ((buffer   (make-string lexer-init-buffer-len #\newline))
                      (read-ptr 1)
                      (input-f  input))
                 (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
              ((and (eq? input-type 'string) (string? input))
               (let* ((buffer   (string-append (string #\newline) input))
                      (read-ptr (string-length buffer))
                      (input-f  (lambda () 'eof)))
                 (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
              (else
               (let* ((buffer   (string #\newline))
                      (read-ptr 1)
                      (input-f  (lambda () 'eof)))
                 (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))))))

                                        ; Les fonctions:
                                        ;   lexer-get-func-getc, lexer-get-func-ungetc,
                                        ;   lexer-get-func-line, lexer-get-func-column et lexer-get-func-offset
  (define lexer-get-func-getc
    (lambda (IS) (cdr (assq 'user-getc IS))))
  (define lexer-get-func-ungetc
    (lambda (IS) (cdr (assq 'user-ungetc IS))))
  (define lexer-get-func-line
    (lambda (IS) (cdr (assq 'get-user-line IS))))
  (define lexer-get-func-column
    (lambda (IS) (cdr (assq 'get-user-column IS))))
  (define lexer-get-func-offset
    (lambda (IS) (cdr (assq 'get-user-offset IS))))

                                        ;
                                        ; Gestion des lexers
                                        ;

                                        ; Fabrication de lexer a partir d'arbres de decision
  (define lexer-make-tree-lexer
    (lambda (tables IS)
      (letrec
          (; Contenu de la table
           (counters-type        (vector-ref tables 0))
           (<<EOF>>-pre-action   (vector-ref tables 1))
           (<<ERROR>>-pre-action (vector-ref tables 2))
           (rules-pre-actions    (vector-ref tables 3))
           (table-nl-start       (vector-ref tables 5))
           (table-no-nl-start    (vector-ref tables 6))
           (trees-v              (vector-ref tables 7))
           (acc-v                (vector-ref tables 8))

                                        ; Contenu du IS
           (IS-start-go-to-end    (cdr (assq 'start-go-to-end IS)))
           (IS-end-go-to-point    (cdr (assq 'end-go-to-point IS)))
           (IS-init-lexeme        (cdr (assq 'init-lexeme IS)))
           (IS-get-start-line     (cdr (assq 'get-start-line IS)))
           (IS-get-start-column   (cdr (assq 'get-start-column IS)))
           (IS-get-start-offset   (cdr (assq 'get-start-offset IS)))
           (IS-peek-left-context  (cdr (assq 'peek-left-context IS)))
           (IS-peek-char          (cdr (assq 'peek-char IS)))
           (IS-read-char          (cdr (assq 'read-char IS)))
           (IS-get-start-end-text (cdr (assq 'get-start-end-text IS)))
           (IS-get-user-line      (cdr (assq 'get-user-line IS)))
           (IS-get-user-column    (cdr (assq 'get-user-column IS)))
           (IS-get-user-offset    (cdr (assq 'get-user-offset IS)))
           (IS-user-getc          (cdr (assq 'user-getc IS)))
           (IS-user-ungetc        (cdr (assq 'user-ungetc IS)))

                                        ; Resultats
           (<<EOF>>-action   #f)
           (<<ERROR>>-action #f)
           (rules-actions    #f)
           (states           #f)
           (final-lexer      #f)

                                        ; Gestion des hooks
           (hook-list '())
           (add-hook
            (lambda (thunk)
              (set! hook-list (cons thunk hook-list))))
           (apply-hooks
            (lambda ()
              (let loop ((l hook-list))
                (if (pair? l)
                    (begin
                      ((car l))
                      (loop (cdr l)))))))

                                        ; Preparation des actions
           (set-action-statics
            (lambda (pre-action)
              (pre-action final-lexer IS-user-getc IS-user-ungetc)))
           (prepare-special-action-none
            (lambda (pre-action)
              (let ((action #f))
                (let ((result
                       (lambda ()
                         (action "")))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-special-action-line
            (lambda (pre-action)
              (let ((action #f))
                (let ((result
                       (lambda (yyline)
                         (action "" yyline)))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-special-action-all
            (lambda (pre-action)
              (let ((action #f))
                (let ((result
                       (lambda (yyline yycolumn yyoffset)
                         (action "" yyline yycolumn yyoffset)))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-special-action
            (lambda (pre-action)
              (cond ((eq? counters-type 'none)
                     (prepare-special-action-none pre-action))
                    ((eq? counters-type 'line)
                     (prepare-special-action-line pre-action))
                    ((eq? counters-type 'all)
                     (prepare-special-action-all  pre-action)))))
           (prepare-action-yytext-none
            (lambda (pre-action)
              (let ((get-start-end-text IS-get-start-end-text)
                    (start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda ()
                         (let ((yytext (get-start-end-text)))
                           (start-go-to-end)
                           (action yytext))))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-yytext-line
            (lambda (pre-action)
              (let ((get-start-end-text IS-get-start-end-text)
                    (start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda (yyline)
                         (let ((yytext (get-start-end-text)))
                           (start-go-to-end)
                           (action yytext yyline))))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-yytext-all
            (lambda (pre-action)
              (let ((get-start-end-text IS-get-start-end-text)
                    (start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda (yyline yycolumn yyoffset)
                         (let ((yytext (get-start-end-text)))
                           (start-go-to-end)
                           (action yytext yyline yycolumn yyoffset))))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-yytext
            (lambda (pre-action)
              (cond ((eq? counters-type 'none)
                     (prepare-action-yytext-none pre-action))
                    ((eq? counters-type 'line)
                     (prepare-action-yytext-line pre-action))
                    ((eq? counters-type 'all)
                     (prepare-action-yytext-all  pre-action)))))
           (prepare-action-no-yytext-none
            (lambda (pre-action)
              (let ((start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda ()
                         (start-go-to-end)
                         (action)))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-no-yytext-line
            (lambda (pre-action)
              (let ((start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda (yyline)
                         (start-go-to-end)
                         (action yyline)))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-no-yytext-all
            (lambda (pre-action)
              (let ((start-go-to-end    IS-start-go-to-end)
                    (action             #f))
                (let ((result
                       (lambda (yyline yycolumn yyoffset)
                         (start-go-to-end)
                         (action yyline yycolumn yyoffset)))
                      (hook
                       (lambda ()
                         (set! action (set-action-statics pre-action)))))
                  (add-hook hook)
                  result))))
           (prepare-action-no-yytext
            (lambda (pre-action)
              (cond ((eq? counters-type 'none)
                     (prepare-action-no-yytext-none pre-action))
                    ((eq? counters-type 'line)
                     (prepare-action-no-yytext-line pre-action))
                    ((eq? counters-type 'all)
                     (prepare-action-no-yytext-all  pre-action)))))

                                        ; Fabrique les fonctions de dispatch
           (prepare-dispatch-err
            (lambda (leaf)
              (lambda (c)
                #f)))
           (prepare-dispatch-number
            (lambda (leaf)
              (let ((state-function #f))
                (let ((result
                       (lambda (c)
                         state-function))
                      (hook
                       (lambda ()
                         (set! state-function (vector-ref states leaf)))))
                  (add-hook hook)
                  result))))
           (prepare-dispatch-leaf
            (lambda (leaf)
              (if (eq? leaf 'err)
                  (prepare-dispatch-err leaf)
                  (prepare-dispatch-number leaf))))
           (prepare-dispatch-<
            (lambda (tree)
              (let ((left-tree  (list-ref tree 1))
                    (right-tree (list-ref tree 2)))
                (let ((bound      (list-ref tree 0))
                      (left-func  (prepare-dispatch-tree left-tree))
                      (right-func (prepare-dispatch-tree right-tree)))
                  (lambda (c)
                    (if (< c bound)
                        (left-func c)
                        (right-func c)))))))
           (prepare-dispatch-=
            (lambda (tree)
              (let ((left-tree  (list-ref tree 2))
                    (right-tree (list-ref tree 3)))
                (let ((bound      (list-ref tree 1))
                      (left-func  (prepare-dispatch-tree left-tree))
                      (right-func (prepare-dispatch-tree right-tree)))
                  (lambda (c)
                    (if (= c bound)
                        (left-func c)
                        (right-func c)))))))
           (prepare-dispatch-tree
            (lambda (tree)
              (cond ((not (pair? tree))
                     (prepare-dispatch-leaf tree))
                    ((eq? (car tree) '=)
                     (prepare-dispatch-= tree))
                    (else
                     (prepare-dispatch-< tree)))))
           (prepare-dispatch
            (lambda (tree)
              (let ((dicho-func (prepare-dispatch-tree tree)))
                (lambda (c)
                  (and c (dicho-func c))))))

                                        ; Fabrique les fonctions de transition (read & go) et (abort)
           (prepare-read-n-go
            (lambda (tree)
              (let ((dispatch-func (prepare-dispatch tree))
                    (read-char     IS-read-char))
                (lambda ()
                  (dispatch-func (read-char))))))
           (prepare-abort
            (lambda (tree)
              (lambda ()
                #f)))
           (prepare-transition
            (lambda (tree)
              (if (eq? tree 'err)
                  (prepare-abort     tree)
                  (prepare-read-n-go tree))))

                                        ; Fabrique les fonctions d'etats ([set-end] & trans)
           (prepare-state-no-acc
            (lambda (s r1 r2)
              (let ((trans-func (prepare-transition (vector-ref trees-v s))))
                (lambda (action)
                  (let ((next-state (trans-func)))
                    (if next-state
                        (next-state action)
                        action))))))
           (prepare-state-yes-no
            (lambda (s r1 r2)
              (let ((peek-char       IS-peek-char)
                    (end-go-to-point IS-end-go-to-point)
                    (new-action1     #f)
                    (trans-func (prepare-transition (vector-ref trees-v s))))
                (let ((result
                       (lambda (action)
                         (let* ((c (peek-char))
                                (new-action
                                 (if (or (not c) (= c lexer-integer-newline))
                                     (begin
                                       (end-go-to-point)
                                       new-action1)
                                     action))
                                (next-state (trans-func)))
                           (if next-state
                               (next-state new-action)
                               new-action))))
                      (hook
                       (lambda ()
                         (set! new-action1 (vector-ref rules-actions r1)))))
                  (add-hook hook)
                  result))))
           (prepare-state-diff-acc
            (lambda (s r1 r2)
              (let ((end-go-to-point IS-end-go-to-point)
                    (peek-char       IS-peek-char)
                    (new-action1     #f)
                    (new-action2     #f)
                    (trans-func (prepare-transition (vector-ref trees-v s))))
                (let ((result
                       (lambda (action)
                         (end-go-to-point)
                         (let* ((c (peek-char))
                                (new-action
                                 (if (or (not c) (= c lexer-integer-newline))
                                     new-action1
                                     new-action2))
                                (next-state (trans-func)))
                           (if next-state
                               (next-state new-action)
                               new-action))))
                      (hook
                       (lambda ()
                         (set! new-action1 (vector-ref rules-actions r1))
                         (set! new-action2 (vector-ref rules-actions r2)))))
                  (add-hook hook)
                  result))))
           (prepare-state-same-acc
            (lambda (s r1 r2)
              (let ((end-go-to-point IS-end-go-to-point)
                    (trans-func (prepare-transition (vector-ref trees-v s)))
                    (new-action #f))
                (let ((result
                       (lambda (action)
                         (end-go-to-point)
                         (let ((next-state (trans-func)))
                           (if next-state
                               (next-state new-action)
                               new-action))))
                      (hook
                       (lambda ()
                         (set! new-action (vector-ref rules-actions r1)))))
                  (add-hook hook)
                  result))))
           (prepare-state
            (lambda (s)
              (let* ((acc (vector-ref acc-v s))
                     (r1 (car acc))
                     (r2 (cdr acc)))
                (cond ((not r1)  (prepare-state-no-acc   s r1 r2))
                      ((not r2)  (prepare-state-yes-no   s r1 r2))
                      ((< r1 r2) (prepare-state-diff-acc s r1 r2))
                      (else      (prepare-state-same-acc s r1 r2))))))

                                        ; Fabrique la fonction de lancement du lexage a l'etat de depart
           (prepare-start-same
            (lambda (s1 s2)
              (let ((peek-char    IS-peek-char)
                    (eof-action   #f)
                    (start-state  #f)
                    (error-action #f))
                (let ((result
                       (lambda ()
                         (if (not (peek-char))
                             eof-action
                             (start-state error-action))))
                      (hook
                       (lambda ()
                         (set! eof-action   <<EOF>>-action)
                         (set! start-state  (vector-ref states s1))
                         (set! error-action <<ERROR>>-action))))
                  (add-hook hook)
                  result))))
           (prepare-start-diff
            (lambda (s1 s2)
              (let ((peek-char         IS-peek-char)
                    (eof-action        #f)
                    (peek-left-context IS-peek-left-context)
                    (start-state1      #f)
                    (start-state2      #f)
                    (error-action      #f))
                (let ((result
                       (lambda ()
                         (cond ((not (peek-char))
                                eof-action)
                               ((= (peek-left-context) lexer-integer-newline)
                                (start-state1 error-action))
                               (else
                                (start-state2 error-action)))))
                      (hook
                       (lambda ()
                         (set! eof-action <<EOF>>-action)
                         (set! start-state1 (vector-ref states s1))
                         (set! start-state2 (vector-ref states s2))
                         (set! error-action <<ERROR>>-action))))
                  (add-hook hook)
                  result))))
           (prepare-start
            (lambda ()
              (let ((s1 table-nl-start)
                    (s2 table-no-nl-start))
                (if (= s1 s2)
                    (prepare-start-same s1 s2)
                    (prepare-start-diff s1 s2)))))

                                        ; Fabrique la fonction principale
           (prepare-lexer-none
            (lambda ()
              (let ((init-lexeme IS-init-lexeme)
                    (start-func  (prepare-start)))
                (lambda ()
                  (init-lexeme)
                  ((start-func))))))
           (prepare-lexer-line
            (lambda ()
              (let ((init-lexeme    IS-init-lexeme)
                    (get-start-line IS-get-start-line)
                    (start-func     (prepare-start)))
                (lambda ()
                  (init-lexeme)
                  (let ((yyline (get-start-line)))
                    ((start-func) yyline))))))
           (prepare-lexer-all
            (lambda ()
              (let ((init-lexeme      IS-init-lexeme)
                    (get-start-line   IS-get-start-line)
                    (get-start-column IS-get-start-column)
                    (get-start-offset IS-get-start-offset)
                    (start-func       (prepare-start)))
                (lambda ()
                  (init-lexeme)
                  (let ((yyline   (get-start-line))
                        (yycolumn (get-start-column))
                        (yyoffset (get-start-offset)))
                    ((start-func) yyline yycolumn yyoffset))))))
           (prepare-lexer
            (lambda ()
              (cond ((eq? counters-type 'none) (prepare-lexer-none))
                    ((eq? counters-type 'line) (prepare-lexer-line))
                    ((eq? counters-type 'all)  (prepare-lexer-all))))))

                                        ; Calculer la valeur de <<EOF>>-action et de <<ERROR>>-action
        (set! <<EOF>>-action   (prepare-special-action <<EOF>>-pre-action))
        (set! <<ERROR>>-action (prepare-special-action <<ERROR>>-pre-action))

                                        ; Calculer la valeur de rules-actions
        (let* ((len (quotient (vector-length rules-pre-actions) 2))
               (v (make-vector len)))
          (let loop ((r (- len 1)))
            (if (< r 0)
                (set! rules-actions v)
                (let* ((yytext? (vector-ref rules-pre-actions (* 2 r)))
                       (pre-action (vector-ref rules-pre-actions (+ (* 2 r) 1)))
                       (action (if yytext?
                                   (prepare-action-yytext    pre-action)
                                   (prepare-action-no-yytext pre-action))))
                  (vector-set! v r action)
                  (loop (- r 1))))))

                                        ; Calculer la valeur de states
        (let* ((len (vector-length trees-v))
               (v (make-vector len)))
          (let loop ((s (- len 1)))
            (if (< s 0)
                (set! states v)
                (begin
                  (vector-set! v s (prepare-state s))
                  (loop (- s 1))))))

                                        ; Calculer la valeur de final-lexer
        (set! final-lexer (prepare-lexer))

                                        ; Executer les hooks
        (apply-hooks)

                                        ; Resultat
        final-lexer)))

                                        ; Fabrication de lexer a partir de listes de caracteres taggees
  (define lexer-make-char-lexer
    (let* ((char->class
            (lambda (c)
              (let ((n (char->integer c)))
                (list (cons n n)))))
           (merge-sort
            (lambda (l combine zero-elt)
              (if (null? l)
                  zero-elt
                  (let loop1 ((l l))
                    (if (null? (cdr l))
                        (car l)
                        (loop1
                         (let loop2 ((l l))
                           (cond ((null? l)
                                  l)
                                 ((null? (cdr l))
                                  l)
                                 (else
                                  (cons (combine (car l) (cadr l))
                                        (loop2 (cddr l))))))))))))
           (finite-class-union
            (lambda (c1 c2)
              (let loop ((c1 c1) (c2 c2) (u '()))
                (if (null? c1)
                    (if (null? c2)
                        (reverse u)
                        (loop c1 (cdr c2) (cons (car c2) u)))
                    (if (null? c2)
                        (loop (cdr c1) c2 (cons (car c1) u))
                        (let* ((r1 (car c1))
                               (r2 (car c2))
                               (r1start (car r1))
                               (r1end (cdr r1))
                               (r2start (car r2))
                               (r2end (cdr r2)))
                          (if (<= r1start r2start)
                              (cond ((< (+ r1end 1) r2start)
                                     (loop (cdr c1) c2 (cons r1 u)))
                                    ((<= r1end r2end)
                                     (loop (cdr c1)
                                           (cons (cons r1start r2end) (cdr c2))
                                           u))
                                    (else
                                     (loop c1 (cdr c2) u)))
                              (cond ((> r1start (+ r2end 1))
                                     (loop c1 (cdr c2) (cons r2 u)))
                                    ((>= r1end r2end)
                                     (loop (cons (cons r2start r1end) (cdr c1))
                                           (cdr c2)
                                           u))
                                    (else
                                     (loop (cdr c1) c2 u))))))))))
           (char-list->class
            (lambda (cl)
              (let ((classes (map char->class cl)))
                (merge-sort classes finite-class-union '()))))
           (class-<
            (lambda (b1 b2)
              (cond ((eq? b1 'inf+) #f)
                    ((eq? b2 'inf-) #f)
                    ((eq? b1 'inf-) #t)
                    ((eq? b2 'inf+) #t)
                    (else (< b1 b2)))))
           (finite-class-compl
            (lambda (c)
              (let loop ((c c) (start 'inf-))
                (if (null? c)
                    (list (cons start 'inf+))
                    (let* ((r (car c))
                           (rstart (car r))
                           (rend (cdr r)))
                      (if (class-< start rstart)
                          (cons (cons start (- rstart 1))
                                (loop c rstart))
                          (loop (cdr c) (+ rend 1))))))))
           (tagged-chars->class
            (lambda (tcl)
              (let* ((inverse? (car tcl))
                     (cl (cdr tcl))
                     (class-tmp (char-list->class cl)))
                (if inverse? (finite-class-compl class-tmp) class-tmp))))
           (charc->arc
            (lambda (charc)
              (let* ((tcl (car charc))
                     (dest (cdr charc))
                     (class (tagged-chars->class tcl)))
                (cons class dest))))
           (arc->sharcs
            (lambda (arc)
              (let* ((range-l (car arc))
                     (dest (cdr arc))
                     (op (lambda (range) (cons range dest))))
                (map op range-l))))
           (class-<=
            (lambda (b1 b2)
              (cond ((eq? b1 'inf-) #t)
                    ((eq? b2 'inf+) #t)
                    ((eq? b1 'inf+) #f)
                    ((eq? b2 'inf-) #f)
                    (else (<= b1 b2)))))
           (sharc-<=
            (lambda (sharc1 sharc2)
              (class-<= (caar sharc1) (caar sharc2))))
           (merge-sharcs
            (lambda (l1 l2)
              (let loop ((l1 l1) (l2 l2))
                (cond ((null? l1)
                       l2)
                      ((null? l2)
                       l1)
                      (else
                       (let ((sharc1 (car l1))
                             (sharc2 (car l2)))
                         (if (sharc-<= sharc1 sharc2)
                             (cons sharc1 (loop (cdr l1) l2))
                             (cons sharc2 (loop l1 (cdr l2))))))))))
           (class-= eqv?)
           (fill-error
            (lambda (sharcs)
              (let loop ((sharcs sharcs) (start 'inf-))
                (cond ((class-= start 'inf+)
                       '())
                      ((null? sharcs)
                       (cons (cons (cons start 'inf+) 'err)
                             (loop sharcs 'inf+)))
                      (else
                       (let* ((sharc (car sharcs))
                              (h (caar sharc))
                              (t (cdar sharc)))
                         (if (class-< start h)
                             (cons (cons (cons start (- h 1)) 'err)
                                   (loop sharcs h))
                             (cons sharc (loop (cdr sharcs)
                                               (if (class-= t 'inf+)
                                                   'inf+
                                                   (+ t 1)))))))))))
           (charcs->tree
            (lambda (charcs)
              (let* ((op (lambda (charc) (arc->sharcs (charc->arc charc))))
                     (sharcs-l (map op charcs))
                     (sorted-sharcs (merge-sort sharcs-l merge-sharcs '()))
                     (full-sharcs (fill-error sorted-sharcs))
                     (op (lambda (sharc) (cons (caar sharc) (cdr sharc))))
                     (table (list->vector (map op full-sharcs))))
                (let loop ((left 0) (right (- (vector-length table) 1)))
                  (if (= left right)
                      (cdr (vector-ref table left))
                      (let ((mid (quotient (+ left right 1) 2)))
                        (if (and (= (+ left 2) right)
                                 (= (+ (car (vector-ref table mid)) 1)
                                    (car (vector-ref table right)))
                                 (eqv? (cdr (vector-ref table left))
                                       (cdr (vector-ref table right))))
                            (list '=
                                  (car (vector-ref table mid))
                                  (cdr (vector-ref table mid))
                                  (cdr (vector-ref table left)))
                            (list (car (vector-ref table mid))
                                  (loop left (- mid 1))
                                  (loop mid right))))))))))
      (lambda (tables IS)
        (let ((counters         (vector-ref tables 0))
              (<<EOF>>-action   (vector-ref tables 1))
              (<<ERROR>>-action (vector-ref tables 2))
              (rules-actions    (vector-ref tables 3))
              (nl-start         (vector-ref tables 5))
              (no-nl-start      (vector-ref tables 6))
              (charcs-v         (vector-ref tables 7))
              (acc-v            (vector-ref tables 8)))
          (let* ((len (vector-length charcs-v))
                 (v (make-vector len)))
            (let loop ((i (- len 1)))
              (if (>= i 0)
                  (begin
                    (vector-set! v i (charcs->tree (vector-ref charcs-v i)))
                    (loop (- i 1)))
                  (lexer-make-tree-lexer
                   (vector counters
                           <<EOF>>-action
                           <<ERROR>>-action
                           rules-actions
                           'decision-trees
                           nl-start
                           no-nl-start
                           v
                           acc-v)
                   IS))))))))

                                        ; Fabrication d'un lexer a partir de code pre-genere
  (define lexer-make-code-lexer
    (lambda (tables IS)
      (let ((<<EOF>>-pre-action   (vector-ref tables 1))
            (<<ERROR>>-pre-action (vector-ref tables 2))
            (rules-pre-action     (vector-ref tables 3))
            (code                 (vector-ref tables 5)))
        (code <<EOF>>-pre-action <<ERROR>>-pre-action rules-pre-action IS))))

  (define lexer-make-lexer
    (lambda (tables IS)
      (let ((automaton-type (vector-ref tables 4)))
        (cond ((eq? automaton-type 'decision-trees)
               (lexer-make-tree-lexer tables IS))
              ((eq? automaton-type 'tagged-chars-lists)
               (lexer-make-char-lexer tables IS))
              ((eq? automaton-type 'code)
               (lexer-make-code-lexer tables IS))))))

                                        ; Module lexparser.scm.

                                        ;
                                        ; Fonctions auxilliaires du lexer
                                        ;

  (define parse-spec-char
    (lambda (lexeme line column)
      (make-tok char-tok lexeme line column newline-ch)))

  (define parse-digits-char
    (lambda (lexeme line column)
      (let* ((num (substring lexeme 1 (string-length lexeme)))
             (n (string->number num)))
        (make-tok char-tok lexeme line column n))))

  (define parse-quoted-char
    (lambda (lexeme line column)
      (let ((c (string-ref lexeme 1)))
        (make-tok char-tok lexeme line column (char->integer c)))))

  (define parse-ordinary-char
    (lambda (lexeme line column)
      (let ((c (string-ref lexeme 0)))
        (make-tok char-tok lexeme line column (char->integer c)))))

  ;; (define string-downcase
  ;;   (lambda (s)
  ;;     (let* ((l (string->list s))
  ;;            (ld (map char-downcase l)))
  ;;       (list->string ld))))

  (define extract-id
    (lambda (s)
      (let ((len (string-length s)))
        (substring s 1 (- len 1)))))

  (define parse-id
    (lambda (lexeme line column)
      (make-tok id-tok lexeme line column (string-downcase lexeme) lexeme)))

  (define parse-id-ref
    (lambda (lexeme line column)
      (let* ((orig-name (extract-id lexeme))
             (name (string-downcase orig-name)))
        (make-tok subst-tok lexeme line column name orig-name))))

  (define parse-power-m
    (lambda (lexeme line column)
      (let* ((len (string-length lexeme))
             (substr (substring lexeme 1 (- len 1)))
             (m (string->number substr))
             (range (cons m m)))
        (make-tok power-tok lexeme line column range))))

  (define parse-power-m-inf
    (lambda (lexeme line column)
      (let* ((len (string-length lexeme))
             (substr (substring lexeme 1 (- len 2)))
             (m (string->number substr))
             (range (cons m 'inf)))
        (make-tok power-tok lexeme line column range))))

  (define parse-power-m-n
    (lambda (lexeme line column)
      (let ((len (string-length lexeme)))
        (let loop ((comma 2))
          (if (char=? (string-ref lexeme comma) #\,)
              (let* ((sub1 (substring lexeme 1 comma))
                     (sub2 (substring lexeme (+ comma 1) (- len 1)))
                     (m (string->number sub1))
                     (n (string->number sub2))
                     (range (cons m n)))
                (make-tok power-tok lexeme line column range))
              (loop (+ comma 1)))))))




                                        ;
                                        ; Lexer generique
                                        ;

  (define lexer-raw #f)
  (define lexer-stack '())

  (define lexer-alist #f)

  (define lexer-buffer #f)
  (define lexer-buffer-empty? #t)

  (define lexer-history '())
  (define lexer-history-interp #f)

  (define init-lexer
    (lambda (port)
      (let* ((IS (lexer-make-IS 'port port 'all))
             (action-lexer (lexer-make-lexer action-tables IS))
             (class-lexer  (lexer-make-lexer class-tables  IS))
             (macro-lexer  (lexer-make-lexer macro-tables  IS))
             (regexp-lexer (lexer-make-lexer regexp-tables IS))
             (string-lexer (lexer-make-lexer string-tables IS)))
        (set! lexer-raw #f)
        (set! lexer-stack '())
        (set! lexer-alist
              (list (cons 'action action-lexer)
                    (cons 'class  class-lexer)
                    (cons 'macro  macro-lexer)
                    (cons 'regexp regexp-lexer)
                    (cons 'string string-lexer)))
        (set! lexer-buffer-empty? #t)
        (set! lexer-history '()))))

                                        ; Lexer brut
                                        ; S'assurer qu'il n'y a pas de risque de changer de
                                        ; lexer quand le buffer est rempli
  (define push-lexer
    (lambda (name)
      (set! lexer-stack (cons lexer-raw lexer-stack))
      (set! lexer-raw (cdr (assq name lexer-alist)))))

  (define pop-lexer
    (lambda ()
      (set! lexer-raw (car lexer-stack))
      (set! lexer-stack (cdr lexer-stack))))

                                        ; Traite le "unget" (capacite du unget: 1)
  (define lexer2
    (lambda ()
      (if lexer-buffer-empty?
          (lexer-raw)
          (begin
            (set! lexer-buffer-empty? #t)
            lexer-buffer))))

  (define lexer2-unget
    (lambda (tok)
      (set! lexer-buffer tok)
      (set! lexer-buffer-empty? #f)))

                                        ; Traite l'historique
  (define lexer
    (lambda ()
      (let* ((tok (lexer2))
             (tok-lexeme (get-tok-lexeme tok))
             (hist-lexeme (if lexer-history-interp
                              (blank-translate tok-lexeme)
                              tok-lexeme)))
        (set! lexer-history (cons hist-lexeme lexer-history))
        tok)))

  (define lexer-unget
    (lambda (tok)
      (set! lexer-history (cdr lexer-history))
      (lexer2-unget tok)))

  (define lexer-set-blank-history
    (lambda (b)
      (set! lexer-history-interp b)))

  (define blank-translate
    (lambda (s)
      (let ((ss (string-copy s)))
        (let loop ((i (- (string-length ss) 1)))
          (cond ((< i 0)
                 ss)
                ((char=? (string-ref ss i) (integer->char tab-ch))
                 (loop (- i 1)))
                ((char=? (string-ref ss i) #\newline)
                 (loop (- i 1)))
                (else
                 (string-set! ss i #\space)
                 (loop (- i 1))))))))

  (define lexer-get-history
    (lambda ()
      (let* ((rightlist (reverse lexer-history))
             (str (apply string-append rightlist))
             (strlen (string-length str))
             (str2 (if (and (> strlen 0)
                            (char=? (string-ref str (- strlen 1)) #\newline))
                       str
                       (string-append str (string #\newline)))))
        (set! lexer-history '())
        str2)))




                                        ;
                                        ; Traitement des listes de tokens
                                        ;

  (define de-anchor-tokens
    (let ((not-anchor-toks (make-dispatch-table number-of-tokens
                                                (list (cons caret-tok     #f)
                                                      (cons dollar-tok    #f)
                                                      (cons <<EOF>>-tok   #f)
                                                      (cons <<ERROR>>-tok #f))
                                                #t)))
      (lambda (tok-list)
        (if (null? tok-list)
            '()
            (let* ((tok (car tok-list))
                   (tok-type (get-tok-type tok))
                   (toks (cdr tok-list))
                   (new-toks (de-anchor-tokens toks)))
              (cond ((vector-ref not-anchor-toks tok-type)
                     (cons tok new-toks))
                    ((or (= tok-type caret-tok) (= tok-type dollar-tok))
                     (let* ((line (get-tok-line tok))
                            (column (get-tok-column tok))
                            (attr (if (= tok-type caret-tok) caret-ch dollar-ch))
                            (new-tok (make-tok char-tok "" line column attr)))
                       (cons new-tok new-toks)))
                    ((= tok-type <<EOF>>-tok)
                     (lex-error (get-tok-line tok)
                                (get-tok-column tok)
                                "the <<EOF>> anchor must be used alone"
                                " and only after %%."))
                    ((= tok-type <<ERROR>>-tok)
                     (lex-error (get-tok-line tok)
                                (get-tok-column tok)
                                "the <<ERROR>> anchor must be used alone"
                                " and only after %%."))))))))

  (define strip-end
    (lambda (l)
      (if (null? (cdr l))
          '()
          (cons (car l) (strip-end (cdr l))))))

  (define extract-anchors
    (lambda (tok-list)
      (let* ((tok1 (car tok-list))
             (line (get-tok-line tok1))
             (tok1-type (get-tok-type tok1)))
        (cond ((and (= tok1-type <<EOF>>-tok) (null? (cdr tok-list)))
               (make-rule line #t #f #f #f '() #f))
              ((and (= tok1-type <<ERROR>>-tok) (null? (cdr tok-list)))
               (make-rule line #f #t #f #f '() #f))
              (else
               (let* ((bol? (= tok1-type caret-tok))
                      (tok-list2 (if bol? (cdr tok-list) tok-list)))
                 (if (null? tok-list2)
                     (make-rule line #f #f bol? #f tok-list2 #f)
                     (let* ((len (length tok-list2))
                            (tok2 (list-ref tok-list2 (- len 1)))
                            (tok2-type (get-tok-type tok2))
                            (eol? (= tok2-type dollar-tok))
                            (tok-list3 (if eol?
                                           (strip-end tok-list2)
                                           tok-list2)))
                       (make-rule line #f #f bol? eol? tok-list3 #f)))))))))

  (define char-list->conc
    (lambda (char-list)
      (if (null? char-list)
          (make-re epsilon-re)
          (let loop ((cl char-list))
            (let* ((c (car cl))
                   (cl2 (cdr cl)))
              (if (null? cl2)
                  (make-re char-re c)
                  (make-re conc-re (make-re char-re c) (loop cl2))))))))

  (define parse-tokens-atom
    (let ((action-table
           (make-dispatch-table
            number-of-tokens
            (list (cons lpar-tok
                        (lambda (tok tok-list macros)
                          (parse-tokens-sub tok-list macros)))
                  (cons dot-tok
                        (lambda (tok tok-list macros)
                          (cons (make-re class-re dot-class) (cdr tok-list))))
                  (cons subst-tok
                        (lambda (tok tok-list macros)
                          (let* ((name (get-tok-attr tok))
                                 (ass (assoc name macros)))
                            (if ass
                                (cons (cdr ass) (cdr tok-list))
                                (lex-error (get-tok-line tok)
                                           (get-tok-column tok)
                                           "unknown macro \""
                                           (get-tok-2nd-attr tok)
                                           "\".")))))
                  (cons char-tok
                        (lambda (tok tok-list macros)
                          (let ((c (get-tok-attr tok)))
                            (cons (make-re char-re c) (cdr tok-list)))))
                  (cons class-tok
                        (lambda (tok tok-list macros)
                          (let ((class (get-tok-attr tok)))
                            (cons (make-re class-re class) (cdr tok-list)))))
                  (cons string-tok
                        (lambda (tok tok-list macros)
                          (let* ((char-list (get-tok-attr tok))
                                 (re (char-list->conc char-list)))
                            (cons re (cdr tok-list))))))
            (lambda (tok tok-list macros)
              (lex-error (get-tok-line tok)
                         (get-tok-column tok)
                         "syntax error in regular expression.")))))
      (lambda (tok-list macros)
        (let* ((tok (car tok-list))
               (tok-type (get-tok-type tok))
               (action (vector-ref action-table tok-type)))
          (action tok tok-list macros)))))

  (define check-power-tok
    (lambda (tok)
      (let* ((range (get-tok-attr tok))
             (start (car range))
             (end (cdr range)))
        (if (or (eq? 'inf end) (<= start end))
            range
            (lex-error (get-tok-line tok)
                       (get-tok-column tok)
                       "incorrect power specification.")))))

  (define power->star-plus
    (lambda (re range)
      (power->star-plus-rec re (car range) (cdr range))))

  (define power->star-plus-rec
    (lambda (re start end)
      (cond ((eq? end 'inf)
             (cond ((= start 0)
                    (make-re star-re re))
                   ((= start 1)
                    (make-re plus-re re))
                   (else
                    (make-re conc-re
                             re
                             (power->star-plus-rec re (- start 1) 'inf)))))
            ((= start 0)
             (cond ((= end 0)
                    (make-re epsilon-re))
                   ((= end 1)
                    (make-re question-re re))
                   (else
                    (make-re question-re
                             (power->star-plus-rec re 1 end)))))
            ((= start 1)
             (if (= end 1)
                 re
                 (make-re conc-re re (power->star-plus-rec re 0 (- end 1)))))
            (else
             (make-re conc-re
                      re
                      (power->star-plus-rec re (- start 1) (- end 1)))))))

  (define parse-tokens-fact
    (let ((not-op-toks (make-dispatch-table number-of-tokens
                                            (list (cons question-tok #f)
                                                  (cons plus-tok     #f)
                                                  (cons star-tok     #f)
                                                  (cons power-tok    #f))
                                            #t)))
      (lambda (tok-list macros)
        (let* ((result (parse-tokens-atom tok-list macros))
               (re (car result))
               (tok-list2 (cdr result)))
          (let loop ((re re) (tok-list3 tok-list2))
            (let* ((tok (car tok-list3))
                   (tok-type (get-tok-type tok)))
              (cond ((vector-ref not-op-toks tok-type)
                     (cons re tok-list3))
                    ((= tok-type question-tok)
                     (loop (make-re question-re re) (cdr tok-list3)))
                    ((= tok-type plus-tok)
                     (loop (make-re plus-re re) (cdr tok-list3)))
                    ((= tok-type star-tok)
                     (loop (make-re star-re re) (cdr tok-list3)))
                    ((= tok-type power-tok)
                     (loop (power->star-plus re (check-power-tok tok))
                           (cdr tok-list3))))))))))

  (define parse-tokens-conc
    (lambda (tok-list macros)
      (let* ((result1 (parse-tokens-fact tok-list macros))
             (re1 (car result1))
             (tok-list2 (cdr result1))
             (tok (car tok-list2))
             (tok-type (get-tok-type tok)))
        (cond ((or (= tok-type pipe-tok)
                   (= tok-type rpar-tok))
               result1)
              (else ; Autres facteurs
               (let* ((result2 (parse-tokens-conc tok-list2 macros))
                      (re2 (car result2))
                      (tok-list3 (cdr result2)))
                 (cons (make-re conc-re re1 re2) tok-list3)))))))

  (define parse-tokens-or
    (lambda (tok-list macros)
      (let* ((result1 (parse-tokens-conc tok-list macros))
             (re1 (car result1))
             (tok-list2 (cdr result1))
             (tok (car tok-list2))
             (tok-type (get-tok-type tok)))
        (cond ((= tok-type pipe-tok)
               (let* ((tok-list3 (cdr tok-list2))
                      (result2 (parse-tokens-or tok-list3 macros))
                      (re2 (car result2))
                      (tok-list4 (cdr result2)))
                 (cons (make-re or-re re1 re2) tok-list4)))
              (else ; rpar-tok
               result1)))))

  (define parse-tokens-sub
    (lambda (tok-list macros)
      (let* ((tok-list2 (cdr tok-list)) ; Manger le lpar-tok
             (result (parse-tokens-or tok-list2 macros))
             (re (car result))
             (tok-list3 (cdr result))
             (tok-list4 (cdr tok-list3))) ; Manger le rpar-tok
        (cons re tok-list4))))

  (define parse-tokens-match
    (lambda (tok-list line)
      (let loop ((tl tok-list) (count 0))
        (if (null? tl)
            (if (> count 0)
                (lex-error line
                           #f
                           "mismatched parentheses."))
            (let* ((tok (car tl))
                   (tok-type (get-tok-type tok)))
              (cond ((= tok-type lpar-tok)
                     (loop (cdr tl) (+ count 1)))
                    ((= tok-type rpar-tok)
                     (if (zero? count)
                         (lex-error line
                                    #f
                                    "mismatched parentheses."))
                     (loop (cdr tl) (- count 1)))
                    (else
                     (loop (cdr tl) count))))))))

                                        ; Ne traite pas les anchors
  (define parse-tokens
    (lambda (tok-list macros)
      (if (null? tok-list)
          (make-re epsilon-re)
          (let ((line (get-tok-line (car tok-list))))
            (parse-tokens-match tok-list line)
            (let* ((begin-par (make-tok lpar-tok "" line 1))
                   (end-par (make-tok rpar-tok "" line 1)))
              (let* ((tok-list2 (append (list begin-par)
                                        tok-list
                                        (list end-par)))
                     (result (parse-tokens-sub tok-list2 macros)))
                (car result))))))) ; (cdr result) == () obligatoirement

  (define tokens->regexp
    (lambda (tok-list macros)
      (let ((tok-list2 (de-anchor-tokens tok-list)))
        (parse-tokens tok-list2 macros))))

  (define tokens->rule
    (lambda (tok-list macros)
      (let* ((rule (extract-anchors tok-list))
             (tok-list2 (get-rule-regexp rule))
             (tok-list3 (de-anchor-tokens tok-list2))
             (re (parse-tokens tok-list3 macros)))
        (set-rule-regexp rule re)
        rule)))

                                        ; Retourne une paire: <<EOF>>-action et vecteur des regles ordinaires
  (define adapt-rules
    (lambda (rules)
      (let loop ((r rules) (revr '()) (<<EOF>>-action #f) (<<ERROR>>-action #f))
        (if (null? r)
            (cons (or <<EOF>>-action default-<<EOF>>-action)
                  (cons (or <<ERROR>>-action default-<<ERROR>>-action)
                        (list->vector (reverse revr))))
            (let ((r1 (car r)))
              (cond ((get-rule-eof? r1)
                     (if <<EOF>>-action
                         (lex-error (get-rule-line r1)
                                    #f
                                    "the <<EOF>> anchor can be "
                                    "used at most once.")
                         (loop (cdr r)
                               revr
                               (get-rule-action r1)
                               <<ERROR>>-action)))
                    ((get-rule-error? r1)
                     (if <<ERROR>>-action
                         (lex-error (get-rule-line r1)
                                    #f
                                    "the <<ERROR>> anchor can be "
                                    "used at most once.")
                         (loop (cdr r)
                               revr
                               <<EOF>>-action
                               (get-rule-action r1))))
                    (else
                     (loop (cdr r)
                           (cons r1 revr)
                           <<EOF>>-action
                           <<ERROR>>-action))))))))




                                        ;
                                        ; Analyseur de fichier lex
                                        ;

  (define parse-hv-blanks
    (lambda ()
      (let* ((tok (lexer))
             (tok-type (get-tok-type tok)))
        (if (or (= tok-type hblank-tok)
                (= tok-type vblank-tok))
            (parse-hv-blanks)
            (lexer-unget tok)))))

  (define parse-class-range
    (lambda ()
      (let* ((tok (lexer))
             (tok-type (get-tok-type tok)))
        (cond ((= tok-type char-tok)
               (let* ((c (get-tok-attr tok))
                      (tok2 (lexer))
                      (tok2-type (get-tok-type tok2)))
                 (if (not (= tok2-type minus-tok))
                     (begin
                       (lexer-unget tok2)
                       (cons c c))
                     (let* ((tok3 (lexer))
                            (tok3-type (get-tok-type tok3)))
                       (cond ((= tok3-type char-tok)
                              (let ((c2 (get-tok-attr tok3)))
                                (if (> c c2)
                                    (lex-error (get-tok-line tok3)
                                               (get-tok-column tok3)
                                               "bad range specification in "
                                               "character class;"
                                               #\newline
                                               "the start character is "
                                               "higher than the end one.")
                                    (cons c c2))))
                             ((or (= tok3-type rbrack-tok)
                                  (= tok3-type minus-tok))
                              (lex-error (get-tok-line tok3)
                                         (get-tok-column tok3)
                                         "bad range specification in "
                                         "character class; a specification"
                                         #\newline
                                         "like \"-x\", \"x--\" or \"x-]\" has "
                                         "been used."))
                             ((= tok3-type eof-tok)
                              (lex-error (get-tok-line tok3)
                                         #f
                                         "eof of file found while parsing "
                                         "a character class.")))))))
              ((= tok-type minus-tok)
               (lex-error (get-tok-line tok)
                          (get-tok-column tok)
                          "bad range specification in character class; a "
                          "specification"
                          #\newline
                          "like \"-x\", \"x--\" or \"x-]\" has been used."))
              ((= tok-type rbrack-tok)
               #f)
              ((= tok-type eof-tok)
               (lex-error (get-tok-line tok)
                          #f
                          "eof of file found while parsing "
                          "a character class."))))))

  (define parse-class
    (lambda (initial-class negative-class? line column)
      (push-lexer 'class)
      (let loop ((class initial-class))
        (let ((new-range (parse-class-range)))
          (if new-range
              (loop (class-union (list new-range) class))
              (let ((class (if negative-class?
                               (class-compl class)
                               class)))
                (pop-lexer)
                (make-tok class-tok "" line column class)))))))

  (define parse-string
    (lambda (line column)
      (push-lexer 'string)
      (let ((char-list (let loop ()
                         (let* ((tok (lexer))
                                (tok-type (get-tok-type tok)))
                           (cond ((= tok-type char-tok)
                                  (cons (get-tok-attr tok) (loop)))
                                 ((= tok-type doublequote-tok)
                                  (pop-lexer)
                                  '())
                                 (else ; eof-tok
                                  (lex-error (get-tok-line tok)
                                             #f
                                             "end of file found while "
                                             "parsing a string.")))))))
        (make-tok string-tok "" line column char-list))))

  (define parse-regexp
    (let* ((end-action
            (lambda (tok loop)
              (lexer-unget tok)
              (pop-lexer)
              (lexer-set-blank-history #f)
              `()))
           (action-table
            (make-dispatch-table
             number-of-tokens
             (list (cons eof-tok end-action)
                   (cons hblank-tok end-action)
                   (cons vblank-tok end-action)
                   (cons lbrack-tok
                         (lambda (tok loop)
                           (let ((tok1 (parse-class (list)
                                                    #f
                                                    (get-tok-line tok)
                                                    (get-tok-column tok))))
                             (cons tok1 (loop)))))
                   (cons lbrack-rbrack-tok
                         (lambda (tok loop)
                           (let ((tok1 (parse-class
                                        (list (cons rbrack-ch rbrack-ch))
                                        #f
                                        (get-tok-line tok)
                                        (get-tok-column tok))))
                             (cons tok1 (loop)))))
                   (cons lbrack-caret-tok
                         (lambda (tok loop)
                           (let ((tok1 (parse-class (list)
                                                    #t
                                                    (get-tok-line tok)
                                                    (get-tok-column tok))))
                             (cons tok1 (loop)))))
                   (cons lbrack-minus-tok
                         (lambda (tok loop)
                           (let ((tok1 (parse-class
                                        (list (cons minus-ch minus-ch))
                                        #f
                                        (get-tok-line tok)
                                        (get-tok-column tok))))
                             (cons tok1 (loop)))))
                   (cons doublequote-tok
                         (lambda (tok loop)
                           (let ((tok1 (parse-string (get-tok-line tok)
                                                     (get-tok-column tok))))
                             (cons tok1 (loop)))))
                   (cons illegal-tok
                         (lambda (tok loop)
                           (lex-error (get-tok-line tok)
                                      (get-tok-column tok)
                                      "syntax error in macro reference."))))
             (lambda (tok loop)
               (cons tok (loop))))))
      (lambda ()
        (push-lexer 'regexp)
        (lexer-set-blank-history #t)
        (parse-hv-blanks)
        (let loop ()
          (let* ((tok (lexer))
                 (tok-type (get-tok-type tok))
                 (action (vector-ref action-table tok-type)))
            (action tok loop))))))

  (define parse-ws1-regexp  ; Exige un blanc entre le nom et la RE d'une macro
    (lambda ()
      (let* ((tok (lexer))
             (tok-type (get-tok-type tok)))
        (cond ((or (= tok-type hblank-tok) (= tok-type vblank-tok))
               (parse-regexp))
              (else  ; percent-percent-tok, id-tok ou illegal-tok
               (lex-error (get-tok-line tok)
                          (get-tok-column tok)
                          "white space expected."))))))

  (define parse-macro
    (lambda (macros)
      (push-lexer 'macro)
      (parse-hv-blanks)
      (let* ((tok (lexer))
             (tok-type (get-tok-type tok)))
        (cond ((= tok-type id-tok)
               (let* ((name (get-tok-attr tok))
                      (ass (assoc name macros)))
                 (if ass
                     (lex-error (get-tok-line tok)
                                (get-tok-column tok)
                                "the macro \""
                                (get-tok-2nd-attr tok)
                                "\" has already been defined.")
                     (let* ((tok-list (parse-ws1-regexp))
                            (regexp (tokens->regexp tok-list macros)))
                       (pop-lexer)
                       (cons name regexp)))))
              ((= tok-type percent-percent-tok)
               (pop-lexer)
               #f)
              ((= tok-type illegal-tok)
               (lex-error (get-tok-line tok)
                          (get-tok-column tok)
                          "macro name expected."))
              ((= tok-type eof-tok)
               (lex-error (get-tok-line tok)
                          #f
                          "end of file found before %%."))))))

  (define parse-macros
    (lambda ()
      (let loop ((macros '()))
        (let ((macro (parse-macro macros)))
          (if macro
              (loop (cons macro macros))
              macros)))))

  (define parse-action-end
    (lambda (<<EOF>>-action? <<ERROR>>-action? action?)
      (let ((act (lexer-get-history)))
        (cond (action?
               act)
              (<<EOF>>-action?
               (string-append act default-<<EOF>>-action))
              (<<ERROR>>-action?
               (string-append act default-<<ERROR>>-action))
              (else
               (string-append act default-action))))))

  (define parse-action
    (lambda (<<EOF>>-action? <<ERROR>>-action?)
      (push-lexer 'action)
      (let loop ((action? #f))
        (let* ((tok (lexer))
               (tok-type (get-tok-type tok)))
          (cond ((= tok-type char-tok)
                 (loop #t))
                ((= tok-type hblank-tok)
                 (loop action?))
                ((= tok-type vblank-tok)
                 (push-lexer 'regexp)
                 (let* ((tok (lexer))
                        (tok-type (get-tok-type tok))
                        (bidon (lexer-unget tok)))
                   (pop-lexer)
                   (if (or (= tok-type hblank-tok)
                           (= tok-type vblank-tok))
                       (loop action?)
                       (begin
                         (pop-lexer)
                         (parse-action-end <<EOF>>-action?
                                           <<ERROR>>-action?
                                           action?)))))
                (else ; eof-tok
                 (lexer-unget tok)
                 (pop-lexer)
                 (parse-action-end <<EOF>>-action?
                                   <<ERROR>>-action?
                                   action?)))))))

  (define parse-rule
    (lambda (macros)
      (let ((tok-list (parse-regexp)))
        (if (null? tok-list)
            #f
            (let* ((rule (tokens->rule tok-list macros))
                   (action
                    (parse-action (get-rule-eof? rule) (get-rule-error? rule))))
              (set-rule-action rule action)
              rule)))))

  (define parse-rules
    (lambda (macros)
      (parse-action #f #f)
      (let loop ()
        (let ((rule (parse-rule macros)))
          (if rule
              (cons rule (loop))
              '())))))

  (define parser
    (lambda (filename)
      (let* ((port (open-input-file filename))
             (port-open? #t))
        (lex-unwind-protect (lambda ()
                              (if port-open?
                                  (close-input-port port))))
        (init-lexer port)
        (let* ((macros (parse-macros))
               (rules (parse-rules macros)))
          (close-input-port port)
          (set! port-open? #f)
          (adapt-rules rules)))))

                                        ; Module re2nfa.scm.

                                        ; Le vecteur d'etats contient la table de transition du nfa.
                                        ; Chaque entree contient les arcs partant de l'etat correspondant.
                                        ; Les arcs sont stockes dans une liste.
                                        ; Chaque arc est une paire (class . destination).
                                        ; Les caracteres d'une classe sont enumeres par ranges.
                                        ; Les ranges sont donnes dans une liste,
                                        ;   chaque element etant une paire (debut . fin).
                                        ; Le symbole eps peut remplacer une classe.
                                        ; L'acceptation est decrite par une paire (acc-if-eol . acc-if-no-eol).

                                        ; Quelques variables globales
  (define r2n-counter 0)
  (define r2n-v-arcs '#(#f))
  (define r2n-v-acc '#(#f))
  (define r2n-v-len 1)

                                        ; Initialisation des variables globales
  (define r2n-init
    (lambda ()
      (set! r2n-counter 0)
      (set! r2n-v-arcs (vector '()))
      (set! r2n-v-acc (vector #f))
      (set! r2n-v-len 1)))

                                        ; Agrandissement des vecteurs
  (define r2n-extend-v
    (lambda ()
      (let* ((new-len (* 2 r2n-v-len))
             (new-v-arcs (make-vector new-len '()))
             (new-v-acc (make-vector new-len #f)))
        (let loop ((i 0))
          (if (< i r2n-v-len)
              (begin
                (vector-set! new-v-arcs i (vector-ref r2n-v-arcs i))
                (vector-set! new-v-acc i (vector-ref r2n-v-acc i))
                (loop (+ i 1)))))
        (set! r2n-v-arcs new-v-arcs)
        (set! r2n-v-acc new-v-acc)
        (set! r2n-v-len new-len))))

                                        ; Finalisation des vecteurs
  (define r2n-finalize-v
    (lambda ()
      (let* ((new-v-arcs (make-vector r2n-counter))
             (new-v-acc (make-vector r2n-counter)))
        (let loop ((i 0))
          (if (< i r2n-counter)
              (begin
                (vector-set! new-v-arcs i (vector-ref r2n-v-arcs i))
                (vector-set! new-v-acc i (vector-ref r2n-v-acc i))
                (loop (+ i 1)))))
        (set! r2n-v-arcs new-v-arcs)
        (set! r2n-v-acc new-v-acc)
        (set! r2n-v-len r2n-counter))))

                                        ; Creation d'etat
  (define r2n-get-state
    (lambda (acc)
      (if (= r2n-counter r2n-v-len)
          (r2n-extend-v))
      (let ((state r2n-counter))
        (set! r2n-counter (+ r2n-counter 1))
        (vector-set! r2n-v-acc state (or acc (cons #f #f)))
        state)))

                                        ; Ajout d'un arc
  (define r2n-add-arc
    (lambda (start chars end)
      (vector-set! r2n-v-arcs
                   start
                   (cons (cons chars end) (vector-ref r2n-v-arcs start)))))

                                        ; Construction de l'automate a partir des regexp
  (define r2n-build-epsilon
    (lambda (re start end)
      (r2n-add-arc start 'eps end)))

  (define r2n-build-or
    (lambda (re start end)
      (let ((re1 (get-re-attr1 re))
            (re2 (get-re-attr2 re)))
        (r2n-build-re re1 start end)
        (r2n-build-re re2 start end))))

  (define r2n-build-conc
    (lambda (re start end)
      (let* ((re1 (get-re-attr1 re))
             (re2 (get-re-attr2 re))
             (inter (r2n-get-state #f)))
        (r2n-build-re re1 start inter)
        (r2n-build-re re2 inter end))))

  (define r2n-build-star
    (lambda (re start end)
      (let* ((re1 (get-re-attr1 re))
             (inter1 (r2n-get-state #f))
             (inter2 (r2n-get-state #f)))
        (r2n-add-arc start 'eps inter1)
        (r2n-add-arc inter1 'eps inter2)
        (r2n-add-arc inter2 'eps end)
        (r2n-build-re re1 inter2 inter1))))

  (define r2n-build-plus
    (lambda (re start end)
      (let* ((re1 (get-re-attr1 re))
             (inter1 (r2n-get-state #f))
             (inter2 (r2n-get-state #f)))
        (r2n-add-arc start 'eps inter1)
        (r2n-add-arc inter2 'eps inter1)
        (r2n-add-arc inter2 'eps end)
        (r2n-build-re re1 inter1 inter2))))

  (define r2n-build-question
    (lambda (re start end)
      (let ((re1 (get-re-attr1 re)))
        (r2n-add-arc start 'eps end)
        (r2n-build-re re1 start end))))

  (define r2n-build-class
    (lambda (re start end)
      (let ((class (get-re-attr1 re)))
        (r2n-add-arc start class end))))

  (define r2n-build-char
    (lambda (re start end)
      (let* ((c (get-re-attr1 re))
             (class (list (cons c c))))
        (r2n-add-arc start class end))))

  (define r2n-build-re
    (let ((sub-function-v (vector r2n-build-epsilon
                                  r2n-build-or
                                  r2n-build-conc
                                  r2n-build-star
                                  r2n-build-plus
                                  r2n-build-question
                                  r2n-build-class
                                  r2n-build-char)))
      (lambda (re start end)
        (let* ((re-type (get-re-type re))
               (sub-f (vector-ref sub-function-v re-type)))
          (sub-f re start end)))))

                                        ; Construction de l'automate relatif a une regle
  (define r2n-build-rule
    (lambda (rule ruleno nl-start no-nl-start)
      (let* ((re (get-rule-regexp rule))
             (bol? (get-rule-bol? rule))
             (eol? (get-rule-eol? rule))
             (rule-start (r2n-get-state #f))
             (rule-end (r2n-get-state (if eol?
                                          (cons ruleno #f)
                                          (cons ruleno ruleno)))))
        (r2n-build-re re rule-start rule-end)
        (r2n-add-arc nl-start 'eps rule-start)
        (if (not bol?)
            (r2n-add-arc no-nl-start 'eps rule-start)))))

                                        ; Construction de l'automate complet
  (define re2nfa
    (lambda (rules)
      (let ((nb-of-rules (vector-length rules)))
        (r2n-init)
        (let* ((nl-start (r2n-get-state #f))
               (no-nl-start (r2n-get-state #f)))
          (let loop ((i 0))
            (if (< i nb-of-rules)
                (begin
                  (r2n-build-rule (vector-ref rules i)
                                  i
                                  nl-start
                                  no-nl-start)
                  (loop (+ i 1)))))
          (r2n-finalize-v)
          (let ((v-arcs r2n-v-arcs)
                (v-acc r2n-v-acc))
            (r2n-init)
            (list nl-start no-nl-start v-arcs v-acc))))))

                                        ; Module noeps.scm.

                                        ; Fonction "merge" qui elimine les repetitions
  (define noeps-merge-1
    (lambda (l1 l2)
      (cond ((null? l1)
             l2)
            ((null? l2)
             l1)
            (else
             (let ((t1 (car l1))
                   (t2 (car l2)))
               (cond ((< t1 t2)
                      (cons t1 (noeps-merge-1 (cdr l1) l2)))
                     ((= t1 t2)
                      (cons t1 (noeps-merge-1 (cdr l1) (cdr l2))))
                     (else
                      (cons t2 (noeps-merge-1 l1 (cdr l2))))))))))

                                        ; Fabrication des voisinages externes
  (define noeps-mkvois
    (lambda (trans-v)
      (let* ((nbnodes (vector-length trans-v))
             (arcs (make-vector nbnodes '())))
        (let loop1 ((n 0))
          (if (< n nbnodes)
              (begin
                (let loop2 ((trans (vector-ref trans-v n)) (ends '()))
                  (if (null? trans)
                      (vector-set! arcs n ends)
                      (let* ((tran (car trans))
                             (class (car tran))
                             (end (cdr tran)))
                        (loop2 (cdr trans) (if (eq? class 'eps)
                                               (noeps-merge-1 ends (list end))
                                               ends)))))
                (loop1 (+ n 1)))))
        arcs)))

                                        ; Fabrication des valeurs initiales
  (define noeps-mkinit
    (lambda (trans-v)
      (let* ((nbnodes (vector-length trans-v))
             (init (make-vector nbnodes)))
        (let loop ((n 0))
          (if (< n nbnodes)
              (begin
                (vector-set! init n (list n))
                (loop (+ n 1)))))
        init)))

                                        ; Traduction d'une liste d'arcs
  (define noeps-trad-arcs
    (lambda (trans dict)
      (let loop ((trans trans))
        (if (null? trans)
            '()
            (let* ((tran (car trans))
                   (class (car tran))
                   (end (cdr tran)))
              (if (eq? class 'eps)
                  (loop (cdr trans))
                  (let* ((new-end (vector-ref dict end))
                         (new-tran (cons class new-end)))
                    (cons new-tran (loop (cdr trans))))))))))

                                        ; Elimination des transitions eps
  (define noeps
    (lambda (nl-start no-nl-start arcs acc)
      (let* ((digraph-arcs (noeps-mkvois arcs))
             (digraph-init (noeps-mkinit arcs))
             (dict (digraph digraph-arcs digraph-init noeps-merge-1))
             (new-nl-start (vector-ref dict nl-start))
             (new-no-nl-start (vector-ref dict no-nl-start)))
        (let loop ((i (- (vector-length arcs) 1)))
          (if (>= i 0)
              (begin
                (vector-set! arcs i (noeps-trad-arcs (vector-ref arcs i) dict))
                (loop (- i 1)))))
        (list new-nl-start new-no-nl-start arcs acc))))

                                        ; Module sweep.scm.

                                        ; Preparer les arcs pour digraph
  (define sweep-mkarcs
    (lambda (trans-v)
      (let* ((nbnodes (vector-length trans-v))
             (arcs-v (make-vector nbnodes '())))
        (let loop1 ((n 0))
          (if (< n nbnodes)
              (let loop2 ((trans (vector-ref trans-v n)) (arcs '()))
                (if (null? trans)
                    (begin
                      (vector-set! arcs-v n arcs)
                      (loop1 (+ n 1)))
                    (loop2 (cdr trans) (noeps-merge-1 (cdar trans) arcs))))
              arcs-v)))))

                                        ; Preparer l'operateur pour digraph
  (define sweep-op
    (let ((acc-min (lambda (rule1 rule2)
                     (cond ((not rule1)
                            rule2)
                           ((not rule2)
                            rule1)
                           (else
                            (min rule1 rule2))))))
      (lambda (acc1 acc2)
        (cons (acc-min (car acc1) (car acc2))
              (acc-min (cdr acc1) (cdr acc2))))))

                                        ; Renumerotation des etats (#f pour etat a eliminer)
                                        ; Retourne (new-nbnodes . dict)
  (define sweep-renum
    (lambda (dist-acc-v)
      (let* ((nbnodes (vector-length dist-acc-v))
             (dict (make-vector nbnodes)))
        (let loop ((n 0) (new-n 0))
          (if (< n nbnodes)
              (let* ((acc (vector-ref dist-acc-v n))
                     (dead? (equal? acc '(#f . #f))))
                (if dead?
                    (begin
                      (vector-set! dict n #f)
                      (loop (+ n 1) new-n))
                    (begin
                      (vector-set! dict n new-n)
                      (loop (+ n 1) (+ new-n 1)))))
              (cons new-n dict))))))

                                        ; Elimination des etats inutiles d'une liste d'etats
  (define sweep-list
    (lambda (ss dict)
      (if (null? ss)
          '()
          (let* ((olds (car ss))
                 (news (vector-ref dict olds)))
            (if news
                (cons news (sweep-list (cdr ss) dict))
                (sweep-list (cdr ss) dict))))))

                                        ; Elimination des etats inutiles d'une liste d'arcs
  (define sweep-arcs
    (lambda (arcs dict)
      (if (null? arcs)
          '()
          (let* ((arc (car arcs))
                 (class (car arc))
                 (ss (cdr arc))
                 (new-ss (sweep-list ss dict)))
            (if (null? new-ss)
                (sweep-arcs (cdr arcs) dict)
                (cons (cons class new-ss) (sweep-arcs (cdr arcs) dict)))))))

                                        ; Elimination des etats inutiles dans toutes les transitions
  (define sweep-all-arcs
    (lambda (arcs-v dict)
      (let loop ((n (- (vector-length arcs-v) 1)))
        (if (>= n 0)
            (begin
              (vector-set! arcs-v n (sweep-arcs (vector-ref arcs-v n) dict))
              (loop (- n 1)))
            arcs-v))))

                                        ; Elimination des etats inutiles dans un vecteur
  (define sweep-states
    (lambda (v new-nbnodes dict)
      (let ((nbnodes (vector-length v))
            (new-v (make-vector new-nbnodes)))
        (let loop ((n 0))
          (if (< n nbnodes)
              (let ((new-n (vector-ref dict n)))
                (if new-n
                    (vector-set! new-v new-n (vector-ref v n)))
                (loop (+ n 1)))
              new-v)))))

                                        ; Elimination des etats inutiles
  (define sweep
    (lambda (nl-start no-nl-start arcs-v acc-v)
      (let* ((digraph-arcs (sweep-mkarcs arcs-v))
             (digraph-init acc-v)
             (digraph-op sweep-op)
             (dist-acc-v (digraph digraph-arcs digraph-init digraph-op))
             (result (sweep-renum dist-acc-v))
             (new-nbnodes (car result))
             (dict (cdr result))
             (new-nl-start (sweep-list nl-start dict))
             (new-no-nl-start (sweep-list no-nl-start dict))
             (new-arcs-v (sweep-states (sweep-all-arcs arcs-v dict)
                                       new-nbnodes
                                       dict))
             (new-acc-v (sweep-states acc-v new-nbnodes dict)))
        (list new-nl-start new-no-nl-start new-arcs-v new-acc-v))))

                                        ; Module nfa2dfa.scm.

                                        ; Recoupement de deux arcs
  (define n2d-2arcs
    (lambda (arc1 arc2)
      (let* ((class1 (car arc1))
             (ss1 (cdr arc1))
             (class2 (car arc2))
             (ss2 (cdr arc2))
             (result (class-sep class1 class2))
             (classl (vector-ref result 0))
             (classc (vector-ref result 1))
             (classr (vector-ref result 2))
             (ssl ss1)
             (ssc (ss-union ss1 ss2))
             (ssr ss2))
        (vector (if (or (null? classl) (null? ssl)) #f (cons classl ssl))
                (if (or (null? classc) (null? ssc)) #f (cons classc ssc))
                (if (or (null? classr) (null? ssr)) #f (cons classr ssr))))))

                                        ; Insertion d'un arc dans une liste d'arcs a classes distinctes
  (define n2d-insert-arc
    (lambda (new-arc arcs)
      (if (null? arcs)
          (list new-arc)
          (let* ((arc (car arcs))
                 (others (cdr arcs))
                 (result (n2d-2arcs new-arc arc))
                 (arcl (vector-ref result 0))
                 (arcc (vector-ref result 1))
                 (arcr (vector-ref result 2))
                 (list-arcc (if arcc (list arcc) '()))
                 (list-arcr (if arcr (list arcr) '())))
            (if arcl
                (append list-arcc list-arcr (n2d-insert-arc arcl others))
                (append list-arcc list-arcr others))))))

                                        ; Regroupement des arcs qui aboutissent au meme sous-ensemble d'etats
  (define n2d-factorize-arcs
    (lambda (arcs)
      (if (null? arcs)
          '()
          (let* ((arc (car arcs))
                 (arc-ss (cdr arc))
                 (others-no-fact (cdr arcs))
                 (others (n2d-factorize-arcs others-no-fact)))
            (let loop ((o others))
              (if (null? o)
                  (list arc)
                  (let* ((o1 (car o))
                         (o1-ss (cdr o1)))
                    (if (equal? o1-ss arc-ss)
                        (let* ((arc-class (car arc))
                               (o1-class (car o1))
                               (new-class (class-union arc-class o1-class))
                               (new-arc (cons new-class arc-ss)))
                          (cons new-arc (cdr o)))
                        (cons o1 (loop (cdr o)))))))))))

                                        ; Transformer une liste d'arcs quelconques en des arcs a classes distinctes
  (define n2d-distinguish-arcs
    (lambda (arcs)
      (let loop ((arcs arcs) (n-arcs '()))
        (if (null? arcs)
            n-arcs
            (loop (cdr arcs) (n2d-insert-arc (car arcs) n-arcs))))))

                                        ; Transformer une liste d'arcs quelconques en des arcs a classes et a
                                        ; destinations distinctes
  (define n2d-normalize-arcs
    (lambda (arcs)
      (n2d-factorize-arcs (n2d-distinguish-arcs arcs))))

                                        ; Factoriser des arcs a destination unique (~deterministes)
  (define n2d-factorize-darcs
    (lambda (arcs)
      (if (null? arcs)
          '()
          (let* ((arc (car arcs))
                 (arc-end (cdr arc))
                 (other-arcs (cdr arcs))
                 (farcs (n2d-factorize-darcs other-arcs)))
            (let loop ((farcs farcs))
              (if (null? farcs)
                  (list arc)
                  (let* ((farc (car farcs))
                         (farc-end (cdr farc)))
                    (if (= farc-end arc-end)
                        (let* ((arc-class (car arc))
                               (farc-class (car farc))
                               (new-class (class-union farc-class arc-class))
                               (new-arc (cons new-class arc-end)))
                          (cons new-arc (cdr farcs)))
                        (cons farc (loop (cdr farcs)))))))))))

                                        ; Normaliser un vecteur de listes d'arcs
  (define n2d-normalize-arcs-v
    (lambda (arcs-v)
      (let* ((nbnodes (vector-length arcs-v))
             (new-v (make-vector nbnodes)))
        (let loop ((n 0))
          (if (= n nbnodes)
              new-v
              (begin
                (vector-set! new-v n (n2d-normalize-arcs (vector-ref arcs-v n)))
                (loop (+ n 1))))))))

                                        ; Inserer un arc dans une liste d'arcs a classes distinctes en separant
                                        ; les arcs contenant une partie de la classe du nouvel arc des autres arcs
                                        ; Retourne: (oui . non)
  (define n2d-ins-sep-arc
    (lambda (new-arc arcs)
      (if (null? arcs)
          (cons (list new-arc) '())
          (let* ((arc (car arcs))
                 (others (cdr arcs))
                 (result (n2d-2arcs new-arc arc))
                 (arcl (vector-ref result 0))
                 (arcc (vector-ref result 1))
                 (arcr (vector-ref result 2))
                 (l-arcc (if arcc (list arcc) '()))
                 (l-arcr (if arcr (list arcr) '()))
                 (result (if arcl
                             (n2d-ins-sep-arc arcl others)
                             (cons '() others)))
                 (oui-arcs (car result))
                 (non-arcs (cdr result)))
            (cons (append l-arcc oui-arcs) (append l-arcr non-arcs))))))

                                        ; Combiner deux listes d'arcs a classes distinctes
                                        ; Ne tente pas de combiner les arcs qui ont nec. des classes disjointes
                                        ; Conjecture: les arcs crees ont leurs classes disjointes
                                        ; Note: envisager de rajouter un "n2d-factorize-arcs" !!!!!!!!!!!!
  (define n2d-combine-arcs
    (lambda (arcs1 arcs2)
      (let loop ((arcs1 arcs1) (arcs2 arcs2) (dist-arcs2 '()))
        (if (null? arcs1)
            (append arcs2 dist-arcs2)
            (let* ((arc (car arcs1))
                   (result (n2d-ins-sep-arc arc arcs2))
                   (oui-arcs (car result))
                   (non-arcs (cdr result)))
              (loop (cdr arcs1) non-arcs (append oui-arcs dist-arcs2)))))))

                                        ; ; 
                                        ; ; Section temporaire: vieille facon de generer le dfa
                                        ; ; Dictionnaire d'etat det.  Recherche lineaire.  Creation naive
                                        ; ; des arcs d'un ensemble d'etats.
                                        ; ; 
                                        ; 
                                        ; ; Quelques variables globales
                                        ; (define n2d-state-dict '#(#f))
                                        ; (define n2d-state-len 1)
                                        ; (define n2d-state-count 0)
                                        ; 
                                        ; ; Fonctions de gestion des entrees du dictionnaire
                                        ; (define make-dentry (lambda (ss) (vector ss #f #f)))
                                        ; 
                                        ; (define get-dentry-ss    (lambda (dentry) (vector-ref dentry 0)))
                                        ; (define get-dentry-darcs (lambda (dentry) (vector-ref dentry 1)))
                                        ; (define get-dentry-acc   (lambda (dentry) (vector-ref dentry 2)))
                                        ; 
                                        ; (define set-dentry-darcs (lambda (dentry arcs) (vector-set! dentry 1 arcs)))
                                        ; (define set-dentry-acc   (lambda (dentry acc)  (vector-set! dentry 2 acc)))
                                        ; 
                                        ; ; Initialisation des variables globales
                                        ; (define n2d-init-glob-vars
                                        ;   (lambda ()
                                        ;     (set! n2d-state-dict (vector #f))
                                        ;     (set! n2d-state-len 1)
                                        ;     (set! n2d-state-count 0)))
                                        ; 
                                        ; ; Extension du dictionnaire
                                        ; (define n2d-extend-dict
                                        ;   (lambda ()
                                        ;     (let* ((new-len (* 2 n2d-state-len))
                                        ; 	   (v (make-vector new-len #f)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (begin
                                        ; 	      (set! n2d-state-dict v)
                                        ; 	      (set! n2d-state-len new-len))
                                        ; 	    (begin
                                        ; 	      (vector-set! v n (vector-ref n2d-state-dict n))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Ajout d'un etat
                                        ; (define n2d-add-state
                                        ;   (lambda (ss)
                                        ;     (let* ((s n2d-state-count)
                                        ; 	   (dentry (make-dentry ss)))
                                        ;       (if (= n2d-state-count n2d-state-len)
                                        ; 	  (n2d-extend-dict))
                                        ;       (vector-set! n2d-state-dict s dentry)
                                        ;       (set! n2d-state-count (+ n2d-state-count 1))
                                        ;       s)))
                                        ; 
                                        ; ; Recherche d'un etat
                                        ; (define n2d-search-state
                                        ;   (lambda (ss)
                                        ;     (let loop ((n 0))
                                        ;       (if (= n n2d-state-count)
                                        ; 	  (n2d-add-state ss)
                                        ; 	  (let* ((dentry (vector-ref n2d-state-dict n))
                                        ; 		 (dentry-ss (get-dentry-ss dentry)))
                                        ; 	    (if (equal? dentry-ss ss)
                                        ; 		n
                                        ; 		(loop (+ n 1))))))))
                                        ; 
                                        ; ; Transformer un arc non-det. en un arc det.
                                        ; (define n2d-translate-arc
                                        ;   (lambda (arc)
                                        ;     (let* ((class (car arc))
                                        ; 	   (ss (cdr arc))
                                        ; 	   (s (n2d-search-state ss)))
                                        ;       (cons class s))))
                                        ; 
                                        ; ; Transformer une liste d'arcs non-det. en ...
                                        ; (define n2d-translate-arcs
                                        ;   (lambda (arcs)
                                        ;     (map n2d-translate-arc arcs)))
                                        ; 
                                        ; ; Trouver le minimum de deux acceptants
                                        ; (define n2d-acc-min2
                                        ;   (let ((acc-min (lambda (rule1 rule2)
                                        ; 		   (cond ((not rule1)
                                        ; 			  rule2)
                                        ; 			 ((not rule2)
                                        ; 			  rule1)
                                        ; 			 (else
                                        ; 			  (min rule1 rule2))))))
                                        ;     (lambda (acc1 acc2)
                                        ;       (cons (acc-min (car acc1) (car acc2))
                                        ; 	    (acc-min (cdr acc1) (cdr acc2))))))
                                        ; 
                                        ; ; Trouver le minimum de plusieurs acceptants
                                        ; (define n2d-acc-mins
                                        ;   (lambda (accs)
                                        ;     (if (null? accs)
                                        ; 	(cons #f #f)
                                        ; 	(n2d-acc-min2 (car accs) (n2d-acc-mins (cdr accs))))))
                                        ; 
                                        ; ; Fabriquer les vecteurs d'arcs et d'acceptance
                                        ; (define n2d-extract-vs
                                        ;   (lambda ()
                                        ;     (let* ((arcs-v (make-vector n2d-state-count))
                                        ; 	   (acc-v (make-vector n2d-state-count)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (cons arcs-v acc-v)
                                        ; 	    (begin
                                        ; 	      (vector-set! arcs-v n (get-dentry-darcs
                                        ; 				     (vector-ref n2d-state-dict n)))
                                        ; 	      (vector-set! acc-v n (get-dentry-acc
                                        ; 				    (vector-ref n2d-state-dict n)))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Effectuer la transformation de l'automate de non-det. a det.
                                        ; (define nfa2dfa
                                        ;   (lambda (nl-start no-nl-start arcs-v acc-v)
                                        ;     (n2d-init-glob-vars)
                                        ;     (let* ((nl-d (n2d-search-state nl-start))
                                        ; 	   (no-nl-d (n2d-search-state no-nl-start)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (< n n2d-state-count)
                                        ; 	    (let* ((dentry (vector-ref n2d-state-dict n))
                                        ; 		   (ss (get-dentry-ss dentry))
                                        ; 		   (arcss (map (lambda (s) (vector-ref arcs-v s)) ss))
                                        ; 		   (arcs (apply append arcss))
                                        ; 		   (dist-arcs (n2d-distinguish-arcs arcs))
                                        ; 		   (darcs (n2d-translate-arcs dist-arcs))
                                        ; 		   (fact-darcs (n2d-factorize-darcs darcs))
                                        ; 		   (accs (map (lambda (s) (vector-ref acc-v s)) ss))
                                        ; 		   (acc (n2d-acc-mins accs)))
                                        ; 	      (set-dentry-darcs dentry fact-darcs)
                                        ; 	      (set-dentry-acc   dentry acc)
                                        ; 	      (loop (+ n 1)))))
                                        ;       (let* ((result (n2d-extract-vs))
                                        ; 	     (new-arcs-v (car result))
                                        ; 	     (new-acc-v (cdr result)))
                                        ; 	(n2d-init-glob-vars)
                                        ; 	(list nl-d no-nl-d new-arcs-v new-acc-v)))))

                                        ; ; 
                                        ; ; Section temporaire: vieille facon de generer le dfa
                                        ; ; Dictionnaire d'etat det.  Recherche lineaire.  Creation des
                                        ; ; arcs d'un ensemble d'etats en combinant des ensembles d'arcs a
                                        ; ; classes distinctes.
                                        ; ; 
                                        ; 
                                        ; ; Quelques variables globales
                                        ; (define n2d-state-dict '#(#f))
                                        ; (define n2d-state-len 1)
                                        ; (define n2d-state-count 0)
                                        ; 
                                        ; ; Fonctions de gestion des entrees du dictionnaire
                                        ; (define make-dentry (lambda (ss) (vector ss #f #f)))
                                        ; 
                                        ; (define get-dentry-ss    (lambda (dentry) (vector-ref dentry 0)))
                                        ; (define get-dentry-darcs (lambda (dentry) (vector-ref dentry 1)))
                                        ; (define get-dentry-acc   (lambda (dentry) (vector-ref dentry 2)))
                                        ; 
                                        ; (define set-dentry-darcs (lambda (dentry arcs) (vector-set! dentry 1 arcs)))
                                        ; (define set-dentry-acc   (lambda (dentry acc)  (vector-set! dentry 2 acc)))
                                        ; 
                                        ; ; Initialisation des variables globales
                                        ; (define n2d-init-glob-vars
                                        ;   (lambda ()
                                        ;     (set! n2d-state-dict (vector #f))
                                        ;     (set! n2d-state-len 1)
                                        ;     (set! n2d-state-count 0)))
                                        ; 
                                        ; ; Extension du dictionnaire
                                        ; (define n2d-extend-dict
                                        ;   (lambda ()
                                        ;     (let* ((new-len (* 2 n2d-state-len))
                                        ; 	   (v (make-vector new-len #f)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (begin
                                        ; 	      (set! n2d-state-dict v)
                                        ; 	      (set! n2d-state-len new-len))
                                        ; 	    (begin
                                        ; 	      (vector-set! v n (vector-ref n2d-state-dict n))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Ajout d'un etat
                                        ; (define n2d-add-state
                                        ;   (lambda (ss)
                                        ;     (let* ((s n2d-state-count)
                                        ; 	   (dentry (make-dentry ss)))
                                        ;       (if (= n2d-state-count n2d-state-len)
                                        ; 	  (n2d-extend-dict))
                                        ;       (vector-set! n2d-state-dict s dentry)
                                        ;       (set! n2d-state-count (+ n2d-state-count 1))
                                        ;       s)))
                                        ; 
                                        ; ; Recherche d'un etat
                                        ; (define n2d-search-state
                                        ;   (lambda (ss)
                                        ;     (let loop ((n 0))
                                        ;       (if (= n n2d-state-count)
                                        ; 	  (n2d-add-state ss)
                                        ; 	  (let* ((dentry (vector-ref n2d-state-dict n))
                                        ; 		 (dentry-ss (get-dentry-ss dentry)))
                                        ; 	    (if (equal? dentry-ss ss)
                                        ; 		n
                                        ; 		(loop (+ n 1))))))))
                                        ; 
                                        ; ; Combiner des listes d'arcs a classes dictinctes
                                        ; (define n2d-combine-arcs-l
                                        ;   (lambda (arcs-l)
                                        ;     (if (null? arcs-l)
                                        ; 	'()
                                        ; 	(let* ((arcs (car arcs-l))
                                        ; 	       (other-arcs-l (cdr arcs-l))
                                        ; 	       (other-arcs (n2d-combine-arcs-l other-arcs-l)))
                                        ; 	  (n2d-combine-arcs arcs other-arcs)))))
                                        ; 
                                        ; ; Transformer un arc non-det. en un arc det.
                                        ; (define n2d-translate-arc
                                        ;   (lambda (arc)
                                        ;     (let* ((class (car arc))
                                        ; 	   (ss (cdr arc))
                                        ; 	   (s (n2d-search-state ss)))
                                        ;       (cons class s))))
                                        ; 
                                        ; ; Transformer une liste d'arcs non-det. en ...
                                        ; (define n2d-translate-arcs
                                        ;   (lambda (arcs)
                                        ;     (map n2d-translate-arc arcs)))
                                        ; 
                                        ; ; Trouver le minimum de deux acceptants
                                        ; (define n2d-acc-min2
                                        ;   (let ((acc-min (lambda (rule1 rule2)
                                        ; 		   (cond ((not rule1)
                                        ; 			  rule2)
                                        ; 			 ((not rule2)
                                        ; 			  rule1)
                                        ; 			 (else
                                        ; 			  (min rule1 rule2))))))
                                        ;     (lambda (acc1 acc2)
                                        ;       (cons (acc-min (car acc1) (car acc2))
                                        ; 	    (acc-min (cdr acc1) (cdr acc2))))))
                                        ; 
                                        ; ; Trouver le minimum de plusieurs acceptants
                                        ; (define n2d-acc-mins
                                        ;   (lambda (accs)
                                        ;     (if (null? accs)
                                        ; 	(cons #f #f)
                                        ; 	(n2d-acc-min2 (car accs) (n2d-acc-mins (cdr accs))))))
                                        ; 
                                        ; ; Fabriquer les vecteurs d'arcs et d'acceptance
                                        ; (define n2d-extract-vs
                                        ;   (lambda ()
                                        ;     (let* ((arcs-v (make-vector n2d-state-count))
                                        ; 	   (acc-v (make-vector n2d-state-count)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (cons arcs-v acc-v)
                                        ; 	    (begin
                                        ; 	      (vector-set! arcs-v n (get-dentry-darcs
                                        ; 				     (vector-ref n2d-state-dict n)))
                                        ; 	      (vector-set! acc-v n (get-dentry-acc
                                        ; 				    (vector-ref n2d-state-dict n)))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Effectuer la transformation de l'automate de non-det. a det.
                                        ; (define nfa2dfa
                                        ;   (lambda (nl-start no-nl-start arcs-v acc-v)
                                        ;     (n2d-init-glob-vars)
                                        ;     (let* ((nl-d (n2d-search-state nl-start))
                                        ; 	   (no-nl-d (n2d-search-state no-nl-start))
                                        ; 	   (norm-arcs-v (n2d-normalize-arcs-v arcs-v)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (< n n2d-state-count)
                                        ; 	    (let* ((dentry (vector-ref n2d-state-dict n))
                                        ; 		   (ss (get-dentry-ss dentry))
                                        ; 		   (arcs-l (map (lambda (s) (vector-ref norm-arcs-v s)) ss))
                                        ; 		   (arcs (n2d-combine-arcs-l arcs-l))
                                        ; 		   (darcs (n2d-translate-arcs arcs))
                                        ; 		   (fact-darcs (n2d-factorize-darcs darcs))
                                        ; 		   (accs (map (lambda (s) (vector-ref acc-v s)) ss))
                                        ; 		   (acc (n2d-acc-mins accs)))
                                        ; 	      (set-dentry-darcs dentry fact-darcs)
                                        ; 	      (set-dentry-acc   dentry acc)
                                        ; 	      (loop (+ n 1)))))
                                        ;       (let* ((result (n2d-extract-vs))
                                        ; 	     (new-arcs-v (car result))
                                        ; 	     (new-acc-v (cdr result)))
                                        ; 	(n2d-init-glob-vars)
                                        ; 	(list nl-d no-nl-d new-arcs-v new-acc-v)))))

                                        ; ; 
                                        ; ; Section temporaire: vieille facon de generer le dfa
                                        ; ; Dictionnaire d'etat det.  Arbre de recherche.  Creation des
                                        ; ; arcs d'un ensemble d'etats en combinant des ensembles d'arcs a
                                        ; ; classes distinctes.
                                        ; ; 
                                        ; 
                                        ; ; Quelques variables globales
                                        ; (define n2d-state-dict '#(#f))
                                        ; (define n2d-state-len 1)
                                        ; (define n2d-state-count 0)
                                        ; (define n2d-state-tree '#(#f ()))
                                        ; 
                                        ; ; Fonctions de gestion des entrees du dictionnaire
                                        ; (define make-dentry (lambda (ss) (vector ss #f #f)))
                                        ; 
                                        ; (define get-dentry-ss    (lambda (dentry) (vector-ref dentry 0)))
                                        ; (define get-dentry-darcs (lambda (dentry) (vector-ref dentry 1)))
                                        ; (define get-dentry-acc   (lambda (dentry) (vector-ref dentry 2)))
                                        ; 
                                        ; (define set-dentry-darcs (lambda (dentry arcs) (vector-set! dentry 1 arcs)))
                                        ; (define set-dentry-acc   (lambda (dentry acc)  (vector-set! dentry 2 acc)))
                                        ; 
                                        ; ; Fonctions de gestion de l'arbre de recherche
                                        ; (define make-snode (lambda () (vector #f '())))
                                        ; 
                                        ; (define get-snode-dstate   (lambda (snode) (vector-ref snode 0)))
                                        ; (define get-snode-children (lambda (snode) (vector-ref snode 1)))
                                        ; 
                                        ; (define set-snode-dstate
                                        ;   (lambda (snode dstate)   (vector-set! snode 0 dstate)))
                                        ; (define set-snode-children
                                        ;   (lambda (snode children) (vector-set! snode 1 children)))
                                        ; 
                                        ; ; Initialisation des variables globales
                                        ; (define n2d-init-glob-vars
                                        ;   (lambda ()
                                        ;     (set! n2d-state-dict (vector #f))
                                        ;     (set! n2d-state-len 1)
                                        ;     (set! n2d-state-count 0)
                                        ;     (set! n2d-state-tree (make-snode))))
                                        ; 
                                        ; ; Extension du dictionnaire
                                        ; (define n2d-extend-dict
                                        ;   (lambda ()
                                        ;     (let* ((new-len (* 2 n2d-state-len))
                                        ; 	   (v (make-vector new-len #f)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (begin
                                        ; 	      (set! n2d-state-dict v)
                                        ; 	      (set! n2d-state-len new-len))
                                        ; 	    (begin
                                        ; 	      (vector-set! v n (vector-ref n2d-state-dict n))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Ajout d'un etat
                                        ; (define n2d-add-state
                                        ;   (lambda (ss)
                                        ;     (let* ((s n2d-state-count)
                                        ; 	   (dentry (make-dentry ss)))
                                        ;       (if (= n2d-state-count n2d-state-len)
                                        ; 	  (n2d-extend-dict))
                                        ;       (vector-set! n2d-state-dict s dentry)
                                        ;       (set! n2d-state-count (+ n2d-state-count 1))
                                        ;       s)))
                                        ; 
                                        ; ; Recherche d'un etat
                                        ; (define n2d-search-state
                                        ;   (lambda (ss)
                                        ;     (let loop ((s-l ss) (snode n2d-state-tree))
                                        ;       (if (null? s-l)
                                        ; 	  (or (get-snode-dstate snode)
                                        ; 	      (let ((s (n2d-add-state ss)))
                                        ; 		(set-snode-dstate snode s)
                                        ; 		s))
                                        ; 	  (let* ((next-s (car s-l))
                                        ; 		 (alist (get-snode-children snode))
                                        ; 		 (ass (or (assv next-s alist)
                                        ; 			  (let ((ass (cons next-s (make-snode))))
                                        ; 			    (set-snode-children snode (cons ass alist))
                                        ; 			    ass))))
                                        ; 	    (loop (cdr s-l) (cdr ass)))))))
                                        ; 
                                        ; ; Combiner des listes d'arcs a classes dictinctes
                                        ; (define n2d-combine-arcs-l
                                        ;   (lambda (arcs-l)
                                        ;     (if (null? arcs-l)
                                        ; 	'()
                                        ; 	(let* ((arcs (car arcs-l))
                                        ; 	       (other-arcs-l (cdr arcs-l))
                                        ; 	       (other-arcs (n2d-combine-arcs-l other-arcs-l)))
                                        ; 	  (n2d-combine-arcs arcs other-arcs)))))
                                        ; 
                                        ; ; Transformer un arc non-det. en un arc det.
                                        ; (define n2d-translate-arc
                                        ;   (lambda (arc)
                                        ;     (let* ((class (car arc))
                                        ; 	   (ss (cdr arc))
                                        ; 	   (s (n2d-search-state ss)))
                                        ;       (cons class s))))
                                        ; 
                                        ; ; Transformer une liste d'arcs non-det. en ...
                                        ; (define n2d-translate-arcs
                                        ;   (lambda (arcs)
                                        ;     (map n2d-translate-arc arcs)))
                                        ; 
                                        ; ; Trouver le minimum de deux acceptants
                                        ; (define n2d-acc-min2
                                        ;   (let ((acc-min (lambda (rule1 rule2)
                                        ; 		   (cond ((not rule1)
                                        ; 			  rule2)
                                        ; 			 ((not rule2)
                                        ; 			  rule1)
                                        ; 			 (else
                                        ; 			  (min rule1 rule2))))))
                                        ;     (lambda (acc1 acc2)
                                        ;       (cons (acc-min (car acc1) (car acc2))
                                        ; 	    (acc-min (cdr acc1) (cdr acc2))))))
                                        ; 
                                        ; ; Trouver le minimum de plusieurs acceptants
                                        ; (define n2d-acc-mins
                                        ;   (lambda (accs)
                                        ;     (if (null? accs)
                                        ; 	(cons #f #f)
                                        ; 	(n2d-acc-min2 (car accs) (n2d-acc-mins (cdr accs))))))
                                        ; 
                                        ; ; Fabriquer les vecteurs d'arcs et d'acceptance
                                        ; (define n2d-extract-vs
                                        ;   (lambda ()
                                        ;     (let* ((arcs-v (make-vector n2d-state-count))
                                        ; 	   (acc-v (make-vector n2d-state-count)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (= n n2d-state-count)
                                        ; 	    (cons arcs-v acc-v)
                                        ; 	    (begin
                                        ; 	      (vector-set! arcs-v n (get-dentry-darcs
                                        ; 				     (vector-ref n2d-state-dict n)))
                                        ; 	      (vector-set! acc-v n (get-dentry-acc
                                        ; 				    (vector-ref n2d-state-dict n)))
                                        ; 	      (loop (+ n 1))))))))
                                        ; 
                                        ; ; Effectuer la transformation de l'automate de non-det. a det.
                                        ; (define nfa2dfa
                                        ;   (lambda (nl-start no-nl-start arcs-v acc-v)
                                        ;     (n2d-init-glob-vars)
                                        ;     (let* ((nl-d (n2d-search-state nl-start))
                                        ; 	   (no-nl-d (n2d-search-state no-nl-start))
                                        ; 	   (norm-arcs-v (n2d-normalize-arcs-v arcs-v)))
                                        ;       (let loop ((n 0))
                                        ; 	(if (< n n2d-state-count)
                                        ; 	    (let* ((dentry (vector-ref n2d-state-dict n))
                                        ; 		   (ss (get-dentry-ss dentry))
                                        ; 		   (arcs-l (map (lambda (s) (vector-ref norm-arcs-v s)) ss))
                                        ; 		   (arcs (n2d-combine-arcs-l arcs-l))
                                        ; 		   (darcs (n2d-translate-arcs arcs))
                                        ; 		   (fact-darcs (n2d-factorize-darcs darcs))
                                        ; 		   (accs (map (lambda (s) (vector-ref acc-v s)) ss))
                                        ; 		   (acc (n2d-acc-mins accs)))
                                        ; 	      (set-dentry-darcs dentry fact-darcs)
                                        ; 	      (set-dentry-acc   dentry acc)
                                        ; 	      (loop (+ n 1)))))
                                        ;       (let* ((result (n2d-extract-vs))
                                        ; 	     (new-arcs-v (car result))
                                        ; 	     (new-acc-v (cdr result)))
                                        ; 	(n2d-init-glob-vars)
                                        ; 	(list nl-d no-nl-d new-arcs-v new-acc-v)))))

                                        ; 
                                        ; Section temporaire: vieille facon de generer le dfa
; Dictionnaire d'etat det.  Table de hashage.  Creation des
; arcs d'un ensemble d'etats en combinant des ensembles d'arcs a
; classes distinctes.
; 

; Quelques variables globales
(define n2d-state-dict '#(#f))
(define n2d-state-len 1)
(define n2d-state-count 0)
(define n2d-state-hash '#())

; Fonctions de gestion des entrees du dictionnaire
(define make-dentry (lambda (ss) (vector ss #f #f)))

(define get-dentry-ss    (lambda (dentry) (vector-ref dentry 0)))
(define get-dentry-darcs (lambda (dentry) (vector-ref dentry 1)))
(define get-dentry-acc   (lambda (dentry) (vector-ref dentry 2)))

(define set-dentry-darcs (lambda (dentry arcs) (vector-set! dentry 1 arcs)))
(define set-dentry-acc   (lambda (dentry acc)  (vector-set! dentry 2 acc)))

; Initialisation des variables globales
(define n2d-init-glob-vars
  (lambda (hash-len)
    (set! n2d-state-dict (vector #f))
    (set! n2d-state-len 1)
    (set! n2d-state-count 0)
    (set! n2d-state-hash (make-vector hash-len '()))))

; Extension du dictionnaire
(define n2d-extend-dict
  (lambda ()
    (let* ((new-len (* 2 n2d-state-len))
	   (v (make-vector new-len #f)))
      (let loop ((n 0))
	(if (= n n2d-state-count)
	    (begin
	      (set! n2d-state-dict v)
	      (set! n2d-state-len new-len))
	    (begin
	      (vector-set! v n (vector-ref n2d-state-dict n))
	      (loop (+ n 1))))))))

; Ajout d'un etat
(define n2d-add-state
  (lambda (ss)
    (let* ((s n2d-state-count)
	   (dentry (make-dentry ss)))
      (if (= n2d-state-count n2d-state-len)
	  (n2d-extend-dict))
      (vector-set! n2d-state-dict s dentry)
      (set! n2d-state-count (+ n2d-state-count 1))
      s)))

; Recherche d'un etat
(define n2d-search-state
  (lambda (ss)
    (let* ((hash-no (if (null? ss) 0 (car ss)))
	   (alist (vector-ref n2d-state-hash hash-no))
	   (ass (assoc ss alist)))
      (if ass
	  (cdr ass)
	  (let* ((s (n2d-add-state ss))
		 (new-ass (cons ss s)))
	    (vector-set! n2d-state-hash hash-no (cons new-ass alist))
	    s)))))

; Combiner des listes d'arcs a classes dictinctes
(define n2d-combine-arcs-l
  (lambda (arcs-l)
    (if (null? arcs-l)
	'()
	(let* ((arcs (car arcs-l))
	       (other-arcs-l (cdr arcs-l))
	       (other-arcs (n2d-combine-arcs-l other-arcs-l)))
	  (n2d-combine-arcs arcs other-arcs)))))

; Transformer un arc non-det. en un arc det.
(define n2d-translate-arc
  (lambda (arc)
    (let* ((class (car arc))
	   (ss (cdr arc))
	   (s (n2d-search-state ss)))
      (cons class s))))

; Transformer une liste d'arcs non-det. en ...
(define n2d-translate-arcs
  (lambda (arcs)
    (map n2d-translate-arc arcs)))

; Trouver le minimum de deux acceptants
(define n2d-acc-min2
  (let ((acc-min (lambda (rule1 rule2)
		   (cond ((not rule1)
			  rule2)
			 ((not rule2)
			  rule1)
			 (else
			  (min rule1 rule2))))))
    (lambda (acc1 acc2)
      (cons (acc-min (car acc1) (car acc2))
	    (acc-min (cdr acc1) (cdr acc2))))))

; Trouver le minimum de plusieurs acceptants
(define n2d-acc-mins
  (lambda (accs)
    (if (null? accs)
	(cons #f #f)
	(n2d-acc-min2 (car accs) (n2d-acc-mins (cdr accs))))))

; Fabriquer les vecteurs d'arcs et d'acceptance
(define n2d-extract-vs
  (lambda ()
    (let* ((arcs-v (make-vector n2d-state-count))
	   (acc-v (make-vector n2d-state-count)))
      (let loop ((n 0))
	(if (= n n2d-state-count)
	    (cons arcs-v acc-v)
	    (begin
	      (vector-set! arcs-v n (get-dentry-darcs
				     (vector-ref n2d-state-dict n)))
	      (vector-set! acc-v n (get-dentry-acc
				    (vector-ref n2d-state-dict n)))
	      (loop (+ n 1))))))))

; Effectuer la transformation de l'automate de non-det. a det.
(define nfa2dfa
  (lambda (nl-start no-nl-start arcs-v acc-v)
    (n2d-init-glob-vars (vector-length arcs-v))
    (let* ((nl-d (n2d-search-state nl-start))
	   (no-nl-d (n2d-search-state no-nl-start))
	   (norm-arcs-v (n2d-normalize-arcs-v arcs-v)))
      (let loop ((n 0))
	(if (< n n2d-state-count)
	    (let* ((dentry (vector-ref n2d-state-dict n))
		   (ss (get-dentry-ss dentry))
		   (arcs-l (map (lambda (s) (vector-ref norm-arcs-v s)) ss))
		   (arcs (n2d-combine-arcs-l arcs-l))
		   (darcs (n2d-translate-arcs arcs))
		   (fact-darcs (n2d-factorize-darcs darcs))
		   (accs (map (lambda (s) (vector-ref acc-v s)) ss))
		   (acc (n2d-acc-mins accs)))
	      (set-dentry-darcs dentry fact-darcs)
	      (set-dentry-acc   dentry acc)
	      (loop (+ n 1)))))
      (let* ((result (n2d-extract-vs))
	     (new-arcs-v (car result))
	     (new-acc-v (cdr result)))
	(n2d-init-glob-vars 0)
	(list nl-d no-nl-d new-arcs-v new-acc-v)))))

; Module prep.scm.

;
; Divers pre-traitements avant l'ecriture des tables
;

; Passe d'un arc multi-range a une liste d'arcs mono-range
(define prep-arc->sharcs
  (lambda (arc)
    (let* ((range-l (car arc))
	   (dest (cdr arc))
	   (op (lambda (range) (cons range dest))))
      (map op range-l))))

; Compare des arcs courts selon leur premier caractere
(define prep-sharc-<=
  (lambda (sharc1 sharc2)
    (class-<= (caar sharc1) (caar sharc2))))

; Remplit les trous parmi les sharcs avec des arcs "erreur"
(define prep-fill-error
  (lambda (sharcs)
    (let loop ((sharcs sharcs) (start 'inf-))
      (cond ((class-= start 'inf+)
	     '())
	    ((null? sharcs)
	     (cons (cons (cons start 'inf+) 'err) (loop sharcs 'inf+)))
	    (else
	     (let* ((sharc (car sharcs))
		    (h (caar sharc))
		    (t (cdar sharc)))
	       (if (class-< start h)
		   (cons (cons (cons start (- h 1)) 'err) (loop sharcs h))
		   (cons sharc (loop (cdr sharcs)
				     (if (class-= t 'inf+)
					 'inf+
					 (+ t 1)))))))))))

; ; Passe d'une liste d'arcs a un arbre de decision
; ; 1ere methode: seulement des comparaisons <
; (define prep-arcs->tree
;   (lambda (arcs)
;     (let* ((sharcs-l (map prep-arc->sharcs arcs))
; 	   (sharcs (apply append sharcs-l))
; 	   (sorted-with-holes (merge-sort sharcs prep-sharc-<=))
; 	   (sorted (prep-fill-error sorted-with-holes))
; 	   (op (lambda (sharc) (cons (caar sharc) (cdr sharc))))
; 	   (table (list->vector (map op sorted))))
;       (let loop ((left 0) (right (- (vector-length table) 1)))
; 	(if (= left right)
; 	    (cdr (vector-ref table left))
; 	    (let ((mid (quotient (+ left right 1) 2)))
; 	      (list (car (vector-ref table mid))
; 		    (loop left (- mid 1))
; 		    (loop mid right))))))))

; Passe d'une liste d'arcs a un arbre de decision
; 2eme methode: permettre des comparaisons = quand ca adonne
(define prep-arcs->tree
  (lambda (arcs)
    (let* ((sharcs-l (map prep-arc->sharcs arcs))
	   (sharcs (apply append sharcs-l))
	   (sorted-with-holes (merge-sort sharcs prep-sharc-<=))
	   (sorted (prep-fill-error sorted-with-holes))
	   (op (lambda (sharc) (cons (caar sharc) (cdr sharc))))
	   (table (list->vector (map op sorted))))
      (let loop ((left 0) (right (- (vector-length table) 1)))
	(if (= left right)
	    (cdr (vector-ref table left))
	    (let ((mid (quotient (+ left right 1) 2)))
	      (if (and (= (+ left 2) right)
		       (= (+ (car (vector-ref table mid)) 1)
			  (car (vector-ref table right)))
		       (eqv? (cdr (vector-ref table left))
			     (cdr (vector-ref table right))))
		  (list '=
			(car (vector-ref table mid))
			(cdr (vector-ref table mid))
			(cdr (vector-ref table left)))
		  (list (car (vector-ref table mid))
			(loop left (- mid 1))
			(loop mid right)))))))))

; Determine si une action a besoin de calculer yytext
(define prep-detect-yytext
  (lambda (s)
    (let loop1 ((i (- (string-length s) 6)))
      (cond ((< i 0)
	     #f)
	    ((char-ci=? (string-ref s i) #\y)
	     (let loop2 ((j 5))
	       (cond ((= j 0)
		      #t)
		     ((char-ci=? (string-ref s (+ i j))
				 (string-ref "yytext" j))
		      (loop2 (- j 1)))
		     (else
		      (loop1 (- i 1))))))
	    (else
	     (loop1 (- i 1)))))))

; Note dans une regle si son action a besoin de yytext
(define prep-set-rule-yytext?
  (lambda (rule)
    (let ((action (get-rule-action rule)))
      (set-rule-yytext? rule (prep-detect-yytext action)))))

; Note dans toutes les regles si leurs actions ont besoin de yytext
(define prep-set-rules-yytext?
  (lambda (rules)
    (let loop ((n (- (vector-length rules) 1)))
      (if (>= n 0)
	  (begin
	    (prep-set-rule-yytext? (vector-ref rules n))
	    (loop (- n 1)))))))

; Module output.scm.

;
; Nettoie les actions en enlevant les lignes blanches avant et apres
;

(define out-split-in-lines
  (lambda (s)
    (let ((len (string-length s)))
      (let loop ((i 0) (start 0))
	(cond ((= i len)
	       '())
	      ((char=? (string-ref s i) #\newline)
	       (cons (substring s start (+ i 1))
		     (loop (+ i 1) (+ i 1))))
	      (else
	       (loop (+ i 1) start)))))))

(define out-empty-line?
  (lambda (s)
    (let ((len (- (string-length s) 1)))
      (let loop ((i 0))
	(cond ((= i len)
	       #t)
	      ((char-whitespace? (string-ref s i))
	       (loop (+ i 1)))
	      (else
	       #f))))))

; Enleve les lignes vides dans une liste avant et apres l'action
(define out-remove-empty-lines
  (lambda (lines)
    (let loop ((lines lines) (top? #t))
      (if (null? lines)
	  '()
	  (let ((line (car lines)))
	    (cond ((not (out-empty-line? line))
		   (cons line (loop (cdr lines) #f)))
		  (top?
		   (loop (cdr lines) #t))
		  (else
		   (let ((rest (loop (cdr lines) #f)))
		     (if (null? rest)
			 '()
			 (cons line rest))))))))))

; Enleve les lignes vides avant et apres l'action
(define out-clean-action
  (lambda (s)
    (let* ((lines (out-split-in-lines s))
	   (clean-lines (out-remove-empty-lines lines)))
      (apply string-append clean-lines))))




;
; Pretty-printer pour les booleens, la liste vide, les nombres,
; les symboles, les caracteres, les chaines, les listes et les vecteurs
;

; Colonne limite pour le pretty-printer (a ne pas atteindre)
(define out-max-col 76)

(define out-flatten-list
  (lambda (ll)
    (let loop ((ll ll) (part-out '()))
      (if (null? ll)
	  part-out
	  (let* ((new-part-out (loop (cdr ll) part-out))
		 (head (car ll)))
	    (cond ((null? head)
		   new-part-out)
		  ((pair? head)
		   (loop head new-part-out))
		  (else
		   (cons head new-part-out))))))))

(define out-force-string
  (lambda (obj)
    (if (char? obj)
	(string obj)
	obj)))

; Transforme une liste impropre en une liste propre qui s'ecrit
; de la meme facon
(define out-regular-list
  (let ((symbolic-dot (string->symbol ".")))
    (lambda (p)
      (let ((tail (cdr p)))
	(cond ((null? tail)
	       p)
	      ((pair? tail)
	       (cons (car p) (out-regular-list tail)))
	      (else
	       (list (car p) symbolic-dot tail)))))))

; Cree des chaines d'espaces de facon paresseuse
(define out-blanks
  (let ((cache-v (make-vector 80 #f)))
    (lambda (n)
      (or (vector-ref cache-v n)
	  (let ((result (make-string n #\space)))
	    (vector-set! cache-v n result)
	    result)))))

; Insere le separateur entre chaque element d'une liste non-vide
(define out-separate
  (lambda (text-l sep)
    (if (null? (cdr text-l))
	text-l
	(cons (car text-l) (cons sep (out-separate (cdr text-l) sep))))))

; Met des donnees en colonnes.  Retourne comme out-pp-aux-list
(define out-pp-columns
  (lambda (left right wmax txt&lens)
    (let loop1 ((tls txt&lens) (lwmax 0) (lwlast 0) (lines '()))
      (if (null? tls)
	  (vector #t 0 lwmax lwlast (reverse lines))
	  (let loop2 ((tls tls) (len 0) (first? #t) (prev-pad 0) (line '()))
	    (cond ((null? tls)
		   (loop1 tls
			  (max len lwmax)
			  len
			  (cons (reverse line) lines)))
		  ((> (+ left len prev-pad 1 wmax) out-max-col)
		   (loop1 tls
			  (max len lwmax)
			  len
			  (cons (reverse line) lines)))
		  (first?
		   (let ((text     (caar tls))
			 (text-len (cdar tls)))
		     (loop2 (cdr tls)
			    (+ len text-len)
			    #f
			    (- wmax text-len)
			    (cons text line))))
		  ((pair? (cdr tls))
		   (let* ((prev-pad-s (out-blanks prev-pad))
			  (text     (caar tls))
			  (text-len (cdar tls)))
		     (loop2 (cdr tls)
			    (+ len prev-pad 1 text-len)
			    #f
			    (- wmax text-len)
			    (cons text (cons " " (cons prev-pad-s line))))))
		  (else
		   (let ((prev-pad-s (out-blanks prev-pad))
			 (text     (caar tls))
			 (text-len (cdar tls)))
		     (if (> (+ left len prev-pad 1 text-len) right)
			 (loop1 tls
				(max len lwmax)
				len
				(cons (reverse line) lines))
			 (loop2 (cdr tls)
				(+ len prev-pad 1 text-len)
				#f
				(- wmax text-len)
				(append (list text " " prev-pad-s)
					line)))))))))))

; Retourne un vecteur #( multiline? width-all width-max width-last text-l )
(define out-pp-aux-list
  (lambda (l left right)
    (let loop ((l l) (multi? #f) (wall -1) (wmax -1) (wlast -1) (txt&lens '()))
      (if (null? l)
	  (cond (multi?
		 (vector #t wall wmax wlast (map car (reverse txt&lens))))
		((<= (+ left wall) right)
		 (vector #f wall wmax wlast (map car (reverse txt&lens))))
		((<= (+ left wmax 1 wmax) out-max-col)
		 (out-pp-columns left right wmax (reverse txt&lens)))
		(else
		 (vector #t wall wmax wlast (map car (reverse txt&lens)))))
	  (let* ((obj (car l))
		 (last? (null? (cdr l)))
		 (this-right (if last? right out-max-col))
		 (result (out-pp-aux obj left this-right))
		 (obj-multi? (vector-ref result 0))
		 (obj-wmax   (vector-ref result 1))
		 (obj-wlast  (vector-ref result 2))
		 (obj-text   (vector-ref result 3)))
	    (loop (cdr l)
		  (or multi? obj-multi?)
		  (+ wall obj-wmax 1)
		  (max wmax obj-wmax)
		  obj-wlast
		  (cons (cons obj-text obj-wmax) txt&lens)))))))

; Retourne un vecteur #( multiline? wmax wlast text )
(define out-pp-aux
  (lambda (obj left right)
    (cond ((boolean? obj)
	   (vector #f 2 2 (if obj '("#t") '("#f"))))
	  ((null? obj)
	   (vector #f 2 2 '("()")))
	  ((number? obj)
	   (let* ((s (number->string obj))
		  (len (string-length s)))
	     (vector #f len len (list s))))
	  ((symbol? obj)
	   (let* ((s (symbol->string obj))
		  (len (string-length s)))
	     (vector #f len len (list s))))
	  ((char? obj)
	   (cond ((char=? obj #\space)
		  (vector #f 7 7 (list "#\\space")))
		 ((char=? obj #\newline)
		  (vector #f 9 9 (list "#\\newline")))
		 (else
		  (vector #f 3 3 (list "#\\" obj)))))
	  ((string? obj)
	   (let loop ((i (- (string-length obj) 1))
		      (len 1)
		      (text '("\"")))
	     (if (= i -1)
		 (vector #f (+ len 1) (+ len 1) (cons "\"" text))
		 (let ((c (string-ref obj i)))
		   (cond ((char=? c #\\)
			  (loop (- i 1) (+ len 2) (cons "\\\\" text)))
			 ((char=? c #\")
			  (loop (- i 1) (+ len 2) (cons "\\\"" text)))
			 (else
			  (loop (- i 1) (+ len 1) (cons (string c) text))))))))
	  ((pair? obj)
	   (let* ((l (out-regular-list obj))
		  (result (out-pp-aux-list l (+ left 1) (- right 1)))
		  (multiline? (vector-ref result 0))
		  (width-all  (vector-ref result 1))
		  (width-max  (vector-ref result 2))
		  (width-last (vector-ref result 3))
		  (text-l     (vector-ref result 4)))
	     (if multiline?
		 (let* ((sep (list #\newline (out-blanks left)))
			(formatted-text (out-separate text-l sep))
			(text (list "(" formatted-text ")")))
		   (vector #t
			   (+ (max width-max (+ width-last 1)) 1)
			   (+ width-last 2)
			   text))
		 (let* ((sep (list " "))
			(formatted-text (out-separate text-l sep))
			(text (list "(" formatted-text ")")))
		   (vector #f (+ width-all 2) (+ width-all 2) text)))))
	  ((and (vector? obj) (zero? (vector-length obj)))
	   (vector #f 3 3 '("#()")))
	  ((vector? obj)
	   (let* ((l (vector->list obj))
		  (result (out-pp-aux-list l (+ left 2) (- right 1)))
		  (multiline? (vector-ref result 0))
		  (width-all  (vector-ref result 1))
		  (width-max  (vector-ref result 2))
		  (width-last (vector-ref result 3))
		  (text-l     (vector-ref result 4)))
	     (if multiline?
		 (let* ((sep (list #\newline (out-blanks (+ left 1))))
			(formatted-text (out-separate text-l sep))
			(text (list "#(" formatted-text ")")))
		   (vector #t
			   (+ (max width-max (+ width-last 1)) 2)
			   (+ width-last 3)
			   text))
		 (let* ((sep (list " "))
			(formatted-text (out-separate text-l sep))
			(text (list "#(" formatted-text ")")))
		   (vector #f (+ width-all 3) (+ width-all 3) text)))))
	  (else
	   (display "Internal error: out-pp")
	   (newline)))))

; Retourne la chaine a afficher
(define out-pp
  (lambda (obj col)
    (let* ((list-rec-of-strings-n-chars
	    (vector-ref (out-pp-aux obj col out-max-col) 3))
	   (list-of-strings-n-chars
	    (out-flatten-list list-rec-of-strings-n-chars))
	   (list-of-strings
	    (map out-force-string list-of-strings-n-chars)))
      (apply string-append list-of-strings))))




;
; Nice-printer, plus rapide mais moins beau que le pretty-printer
;

(define out-np
  (lambda (obj start)
    (letrec ((line-pad
	      (string-append (string #\newline)
			     (out-blanks (- start 1))))
	     (step-line
	      (lambda (p)
		(set-car! p line-pad)))
	     (p-bool
	      (lambda (obj col objw texts hole cont)
		(let ((text (if obj "#t" "#f")))
		  (cont (+ col 2) (+ objw 2) (cons text texts) hole))))
	     (p-number
	      (lambda (obj col objw texts hole cont)
		(let* ((text (number->string obj))
		       (len (string-length text)))
		  (cont (+ col len) (+ objw len) (cons text texts) hole))))
	     (p-symbol
	      (lambda (obj col objw texts hole cont)
		(let* ((text (symbol->string obj))
		       (len (string-length text)))
		  (cont (+ col len) (+ objw len) (cons text texts) hole))))
	     (p-char
	      (lambda (obj col objw texts hole cont)
		(let* ((text
			(cond ((char=? obj #\space) "#\\space")
			      ((char=? obj #\newline) "#\\newline")
			      (else (string-append "#\\" (string obj)))))
		       (len (string-length text)))
		  (cont (+ col len) (+ objw len) (cons text texts) hole))))
	     (p-list
	      (lambda (obj col objw texts hole cont)
		(p-tail obj (+ col 1) (+ objw 1) (cons "(" texts) hole cont)))
	     (p-vector
	      (lambda (obj col objw texts hole cont)
		(p-list (vector->list obj)
			(+ col 1) (+ objw 1) (cons "#" texts) hole cont)))
	     (p-tail
	      (lambda (obj col objw texts hole cont)
		(if (null? obj)
		    (cont (+ col 1) (+ objw 1) (cons ")" texts) hole)
		    (p-obj (car obj) col objw texts hole
			   (make-cdr-cont obj cont)))))
	     (make-cdr-cont
	      (lambda (obj cont)
		(lambda (col objw texts hole)
		  (cond ((null? (cdr obj))
			 (cont (+ col 1) (+ objw 1) (cons ")" texts) hole))
			((> col out-max-col)
			 (step-line hole)
			 (let ((hole2 (cons " " texts)))
			   (p-cdr obj (+ start objw 1) 0 hole2 hole2 cont)))
			(else
			 (let ((hole2 (cons " " texts)))
			   (p-cdr obj (+ col 1) 0 hole2 hole2 cont)))))))
	     (p-cdr
	      (lambda (obj col objw texts hole cont)
		(if (pair? (cdr obj))
		    (p-tail (cdr obj) col objw texts hole cont)
		    (p-dot col objw texts hole
			   (make-cdr-cont (list #f (cdr obj)) cont)))))
	     (p-dot
	      (lambda (col objw texts hole cont)
		(cont (+ col 1) (+ objw 1) (cons "." texts) hole)))
	     (p-obj
	      (lambda (obj col objw texts hole cont)
		(cond ((boolean? obj)
		       (p-bool obj col objw texts hole cont))
		      ((number? obj)
		       (p-number obj col objw texts hole cont))
		      ((symbol? obj)
		       (p-symbol obj col objw texts hole cont))
		      ((char? obj)
		       (p-char obj col objw texts hole cont))
		      ((or (null? obj) (pair? obj))
		       (p-list obj col objw texts hole cont))
		      ((vector? obj)
		       (p-vector obj col objw texts hole cont))))))
      (p-obj obj start 0 '() (cons #f #f)
	     (lambda (col objw texts hole)
	       (if (> col out-max-col)
		   (step-line hole))
	       (apply string-append (reverse texts)))))))




;
; Fonction pour afficher une table
; Appelle la sous-routine adequate pour le type de fin de table
;

; Affiche la table d'un driver
(define out-print-table
  (lambda (args-alist
	   <<EOF>>-action <<ERROR>>-action rules
	   nl-start no-nl-start arcs-v acc-v
	   port)
    (let* ((filein
	    (cdr (assq 'filein args-alist)))
	   (table-name
	    (cdr (assq 'table-name args-alist)))
	   (pretty?
	    (assq 'pp args-alist))
	   (counters-type
	    (let ((a (assq 'counters args-alist)))
	      (if a (cdr a) 'line)))
	   (counters-param-list
	    (cond ((eq? counters-type 'none)
		   ")")
		  ((eq? counters-type 'line)
		   " yyline)")
		  (else ; 'all
		   " yyline yycolumn yyoffset)")))
	   (counters-param-list-short
	    (if (char=? (string-ref counters-param-list 0) #\space)
		(substring counters-param-list
			   1
			   (string-length counters-param-list))
		counters-param-list))
	   (clean-eof-action
	    (out-clean-action <<EOF>>-action))
	   (clean-error-action
	    (out-clean-action <<ERROR>>-action))
	   (rule-op
	    (lambda (rule) (out-clean-action (get-rule-action rule))))
	   (rules-l
	    (vector->list rules))
	   (clean-actions-l
	    (map rule-op rules-l))
	   (yytext?-l
	    (map get-rule-yytext? rules-l)))

      ; Commentaires prealables
      (display ";" port)
      (newline port)
      (display "; Table generated from the file " port)
      (display filein port)
      (display " by SILex 1.0" port)
      (newline port)
      (display ";" port)
      (newline port)
      (newline port)

      ; Ecrire le debut de la table
      (display "(define " port)
      (display table-name port)
      (newline port)
      (display "  (vector" port)
      (newline port)

      ; Ecrire la description du type de compteurs
      (display "   '" port)
      (write counters-type port)
      (newline port)

      ; Ecrire l'action pour la fin de fichier
      (display "   (lambda (yycontinue yygetc yyungetc)" port)
      (newline port)
      (display "     (lambda (yytext" port)
      (display counters-param-list port)
      (newline port)
      (display clean-eof-action port)
      (display "       ))" port)
      (newline port)

      ; Ecrire l'action pour le cas d'erreur
      (display "   (lambda (yycontinue yygetc yyungetc)" port)
      (newline port)
      (display "     (lambda (yytext" port)
      (display counters-param-list port)
      (newline port)
      (display clean-error-action port)
      (display "       ))" port)
      (newline port)

      ; Ecrire le vecteur des actions des regles ordinaires
      (display "   (vector" port)
      (newline port)
      (let loop ((al clean-actions-l) (yyl yytext?-l))
	(if (pair? al)
	    (let ((yytext? (car yyl)))
	      (display "    " port)
	      (write yytext? port)
	      (newline port)
	      (display "    (lambda (yycontinue yygetc yyungetc)" port)
	      (newline port)
	      (if yytext?
		  (begin
		    (display "      (lambda (yytext" port)
		    (display counters-param-list port))
		  (begin
		    (display "      (lambda (" port)
		    (display counters-param-list-short port)))
	      (newline port)
	      (display (car al) port)
	      (display "        ))" port)
	      (if (pair? (cdr al))
		  (newline port))
	      (loop (cdr al) (cdr yyl)))))
      (display ")" port)
      (newline port)

      ; Ecrire l'automate
      (cond ((assq 'portable args-alist)
	     (out-print-table-chars
	      pretty?
	      nl-start no-nl-start arcs-v acc-v
	      port))
	    ((assq 'code args-alist)
	     (out-print-table-code
	      counters-type (vector-length rules) yytext?-l
	      nl-start no-nl-start arcs-v acc-v
	      port))
	    (else
	     (out-print-table-data
	      pretty?
	      nl-start no-nl-start arcs-v acc-v
	      port))))))

;
; Affiche l'automate sous forme d'arbres de decision
; Termine la table du meme coup
;

(define out-print-table-data
  (lambda (pretty? nl-start no-nl-start arcs-v acc-v port)
    (let* ((len (vector-length arcs-v))
	   (trees-v (make-vector len)))
      (let loop ((i 0))
	(if (< i len)
	    (begin
	      (vector-set! trees-v i (prep-arcs->tree (vector-ref arcs-v i)))
	      (loop (+ i 1)))))

      ; Decrire le format de l'automate
      (display "   'decision-trees" port)
      (newline port)

      ; Ecrire l'etat de depart pour le cas "debut de la ligne"
      (display "   " port)
      (write nl-start port)
      (newline port)

      ; Ecrire l'etat de depart pour le cas "pas au debut de la ligne"
      (display "   " port)
      (write no-nl-start port)
      (newline port)

      ; Ecrire la table de transitions
      (display "   '" port)
      (if pretty?
	  (display (out-pp trees-v 5) port)
	  (display (out-np trees-v 5) port))
      (newline port)

      ; Ecrire la table des acceptations
      (display "   '" port)
      (if pretty?
	  (display (out-pp acc-v 5) port)
	  (display (out-np acc-v 5) port))

      ; Ecrire la fin de la table
      (display "))" port)
      (newline port))))

;
; Affiche l'automate sous forme de listes de caracteres taggees
; Termine la table du meme coup
;

(define out-print-table-chars
  (lambda (pretty? nl-start no-nl-start arcs-v acc-v port)
    (let* ((len (vector-length arcs-v))
	   (portable-v (make-vector len))
	   (arc-op (lambda (arc)
		     (cons (class->tagged-char-list (car arc)) (cdr arc)))))
      (let loop ((s 0))
	(if (< s len)
	    (let* ((arcs (vector-ref arcs-v s))
		   (port-arcs (map arc-op arcs)))
	      (vector-set! portable-v s port-arcs)
	      (loop (+ s 1)))))

      ; Decrire le format de l'automate
      (display "   'tagged-chars-lists" port)
      (newline port)

      ; Ecrire l'etat de depart pour le cas "debut de la ligne"
      (display "   " port)
      (write nl-start port)
      (newline port)

      ; Ecrire l'etat de depart pour le cas "pas au debut de la ligne"
      (display "   " port)
      (write no-nl-start port)
      (newline port)

      ; Ecrire la table de transitions
      (display "   '" port)
      (if pretty?
	  (display (out-pp portable-v 5) port)
	  (display (out-np portable-v 5) port))
      (newline port)

      ; Ecrire la table des acceptations
      (display "   '" port)
      (if pretty?
	  (display (out-pp acc-v 5) port)
	  (display (out-np acc-v 5) port))

      ; Ecrire la fin de la table
      (display "))" port)
      (newline port))))

;
; Genere l'automate en code Scheme
; Termine la table du meme coup
;

(define out-print-code-trans3
  (lambda (margin tree action-var port)
    (newline port)
    (display (out-blanks margin) port)
    (cond ((eq? tree 'err)
	   (display action-var port))
	  ((number? tree)
	   (display "(state-" port)
	   (display tree port)
	   (display " " port)
	   (display action-var port)
	   (display ")" port))
	  ((eq? (car tree) '=)
	   (display "(if (= c " port)
	   (display (list-ref tree 1) port)
	   (display ")" port)
	   (out-print-code-trans3 (+ margin 4)
				  (list-ref tree 2)
				  action-var
				  port)
	   (out-print-code-trans3 (+ margin 4)
				  (list-ref tree 3)
				  action-var
				  port)
	   (display ")" port))
	  (else
	   (display "(if (< c " port)
	   (display (list-ref tree 0) port)
	   (display ")" port)
	   (out-print-code-trans3 (+ margin 4)
				  (list-ref tree 1)
				  action-var
				  port)
	   (out-print-code-trans3 (+ margin 4)
				  (list-ref tree 2)
				  action-var
				  port)
	   (display ")" port)))))

(define out-print-code-trans2
  (lambda (margin tree action-var port)
    (newline port)
    (display (out-blanks margin) port)
    (display "(if c" port)
    (out-print-code-trans3 (+ margin 4) tree action-var port)
    (newline port)
    (display (out-blanks (+ margin 4)) port)
    (display action-var port)
    (display ")" port)))

(define out-print-code-trans1
  (lambda (margin tree action-var port)
    (newline port)
    (display (out-blanks margin) port)
    (if (eq? tree 'err)
	(display action-var port)
	(begin
	  (display "(let ((c (read-char)))" port)
	  (out-print-code-trans2 (+ margin 2) tree action-var port)
	  (display ")" port)))))

(define out-print-table-code
  (lambda (counters nbrules yytext?-l
	   nl-start no-nl-start arcs-v acc-v
	   port)
    (let* ((counters-params
	    (cond ((eq? counters 'none) ")")
		  ((eq? counters 'line) " yyline)")
		  ((eq? counters 'all)  " yyline yycolumn yyoffset)")))
	   (counters-params-short
	    (cond ((eq? counters 'none) ")")
		  ((eq? counters 'line) "yyline)")
		  ((eq? counters 'all)  "yyline yycolumn yyoffset)")))
	   (nbstates (vector-length arcs-v))
	   (trees-v (make-vector nbstates)))
      (let loop ((s 0))
	(if (< s nbstates)
	    (begin
	      (vector-set! trees-v s (prep-arcs->tree (vector-ref arcs-v s)))
	      (loop (+ s 1)))))

      ; Decrire le format de l'automate
      (display "   'code" port)
      (newline port)

      ; Ecrire l'entete de la fonction
      (display "   (lambda (<<EOF>>-pre-action" port)
      (newline port)
      (display "            <<ERROR>>-pre-action" port)
      (newline port)
      (display "            rules-pre-action" port)
      (newline port)
      (display "            IS)" port)
      (newline port)

      ; Ecrire le debut du letrec et les variables d'actions brutes
      (display "     (letrec" port)
      (newline port)
      (display "         ((user-action-<<EOF>> #f)" port)
      (newline port)
      (display "          (user-action-<<ERROR>> #f)" port)
      (newline port)
      (let loop ((i 0))
	(if (< i nbrules)
	    (begin
	      (display "          (user-action-" port)
	      (write i port)
	      (display " #f)" port)
	      (newline port)
	      (loop (+ i 1)))))

      ; Ecrire l'extraction des fonctions du IS
      (display "          (start-go-to-end    " port)
      (display "(cdr (assq 'start-go-to-end IS)))" port)
      (newline port)
      (display "          (end-go-to-point    " port)
      (display "(cdr (assq 'end-go-to-point IS)))" port)
      (newline port)
      (display "          (init-lexeme        " port)
      (display "(cdr (assq 'init-lexeme IS)))" port)
      (newline port)
      (display "          (get-start-line     " port)
      (display "(cdr (assq 'get-start-line IS)))" port)
      (newline port)
      (display "          (get-start-column   " port)
      (display "(cdr (assq 'get-start-column IS)))" port)
      (newline port)
      (display "          (get-start-offset   " port)
      (display "(cdr (assq 'get-start-offset IS)))" port)
      (newline port)
      (display "          (peek-left-context  " port)
      (display "(cdr (assq 'peek-left-context IS)))" port)
      (newline port)
      (display "          (peek-char          " port)
      (display "(cdr (assq 'peek-char IS)))" port)
      (newline port)
      (display "          (read-char          " port)
      (display "(cdr (assq 'read-char IS)))" port)
      (newline port)
      (display "          (get-start-end-text " port)
      (display "(cdr (assq 'get-start-end-text IS)))" port)
      (newline port)
      (display "          (user-getc          " port)
      (display "(cdr (assq 'user-getc IS)))" port)
      (newline port)
      (display "          (user-ungetc        " port)
      (display "(cdr (assq 'user-ungetc IS)))" port)
      (newline port)

      ; Ecrire les variables d'actions
      (display "          (action-<<EOF>>" port)
      (newline port)
      (display "           (lambda (" port)
      (display counters-params-short port)
      (newline port)
      (display "             (user-action-<<EOF>> \"\"" port)
      (display counters-params port)
      (display "))" port)
      (newline port)
      (display "          (action-<<ERROR>>" port)
      (newline port)
      (display "           (lambda (" port)
      (display counters-params-short port)
      (newline port)
      (display "             (user-action-<<ERROR>> \"\"" port)
      (display counters-params port)
      (display "))" port)
      (newline port)
      (let loop ((i 0) (yyl yytext?-l))
	(if (< i nbrules)
	    (begin
	      (display "          (action-" port)
	      (display i port)
	      (newline port)
	      (display "           (lambda (" port)
	      (display counters-params-short port)
	      (newline port)
	      (if (car yyl)
		  (begin
		    (display "             (let ((yytext" port)
		    (display " (get-start-end-text)))" port)
		    (newline port)
		    (display "               (start-go-to-end)" port)
		    (newline port)
		    (display "               (user-action-" port)
		    (display i port)
		    (display " yytext" port)
		    (display counters-params port)
		    (display ")))" port)
		    (newline port))
		  (begin
		    (display "             (start-go-to-end)" port)
		    (newline port)
		    (display "             (user-action-" port)
		    (display i port)
		    (display counters-params port)
		    (display "))" port)
		    (newline port)))
	      (loop (+ i 1) (cdr yyl)))))

      ; Ecrire les variables d'etats
      (let loop ((s 0))
	(if (< s nbstates)
	    (let* ((tree (vector-ref trees-v s))
		   (acc (vector-ref acc-v s))
		   (acc-eol (car acc))
		   (acc-no-eol (cdr acc)))
	      (display "          (state-" port)
	      (display s port)
	      (newline port)
	      (display "           (lambda (action)" port)
	      (cond ((not acc-eol)
		     (out-print-code-trans1 13 tree "action" port))
		    ((not acc-no-eol)
		     (newline port)
		     (if (eq? tree 'err)
			 (display "             (let* ((c (peek-char))" port)
			 (display "             (let* ((c (read-char))" port))
		     (newline port)
		     (display "                    (new-action (if (o" port)
		     (display "r (not c) (= c lexer-integer-newline))" port)
		     (newline port)
		     (display "                                  " port)
		     (display "  (begin (end-go-to-point) action-" port)
		     (display acc-eol port)
		     (display ")" port)
		     (newline port)
		     (display "                       " port)
		     (display "             action)))" port)
		     (if (eq? tree 'err)
			 (out-print-code-trans1 15 tree "new-action" port)
			 (out-print-code-trans2 15 tree "new-action" port))
		     (display ")" port))
		    ((< acc-eol acc-no-eol)
		     (newline port)
		     (display "             (end-go-to-point)" port)
		     (newline port)
		     (if (eq? tree 'err)
			 (display "             (let* ((c (peek-char))" port)
			 (display "             (let* ((c (read-char))" port))
		     (newline port)
		     (display "                    (new-action (if (o" port)
		     (display "r (not c) (= c lexer-integer-newline))" port)
		     (newline port)
		     (display "                      " port)
		     (display "              action-" port)
		     (display acc-eol port)
		     (newline port)
		     (display "                      " port)
		     (display "              action-" port)
		     (display acc-no-eol port)
		     (display ")))" port)
		     (if (eq? tree 'err)
			 (out-print-code-trans1 15 tree "new-action" port)
			 (out-print-code-trans2 15 tree "new-action" port))
		     (display ")" port))
		    (else
		     (let ((action-var
			    (string-append "action-"
					   (number->string acc-eol))))
		       (newline port)
		       (display "             (end-go-to-point)" port)
		       (out-print-code-trans1 13 tree action-var port))))
	      (display "))" port)
	      (newline port)
	      (loop (+ s 1)))))

      ; Ecrire la variable de lancement de l'automate
      (display "          (start-automaton" port)
      (newline port)
      (display "           (lambda ()" port)
      (newline port)
      (if (= nl-start no-nl-start)
	  (begin
	    (display "             (if (peek-char)" port)
	    (newline port)
	    (display "                 (state-" port)
	    (display nl-start port)
	    (display " action-<<ERROR>>)" port)
	    (newline port)
	    (display "                 action-<<EOF>>)" port))
	  (begin
	    (display "             (cond ((not (peek-char))" port)
	    (newline port)
	    (display "                    action-<<EOF>>)" port)
	    (newline port)
	    (display "                   ((= (peek-left-context)" port)
	    (display " lexer-integer-newline)" port)
	    (newline port)
	    (display "                    (state-" port)
	    (display nl-start port)
	    (display " action-<<ERROR>>))" port)
	    (newline port)
	    (display "                   (else" port)
	    (newline port)
	    (display "                    (state-" port)
	    (display no-nl-start port)
	    (display " action-<<ERROR>>)))" port)))
      (display "))" port)
      (newline port)

      ; Ecrire la fonction principale de lexage
      (display "          (final-lexer" port)
      (newline port)
      (display "           (lambda ()" port)
      (newline port)
      (display "             (init-lexeme)" port)
      (newline port)
      (cond ((eq? counters 'none)
	     (display "             ((start-automaton))" port))
	    ((eq? counters 'line)
	     (display "             (let ((yyline (get-start-line)))" port)
	     (newline port)
	     (display "               ((start-automaton) yyline))" port))
	    ((eq? counters 'all)
	     (display "             (let ((yyline (get-start-line))" port)
	     (newline port)
	     (display "                   (yycolumn (get-start-column))" port)
	     (newline port)
	     (display "                   (yyoffset (get-start-offset)))" port)
	     (newline port)
	     (display "               ((start-automat" port)
	     (display "on) yyline yycolumn yyoffset))" port)))
      (display "))" port)

      ; Fermer les bindings du grand letrec
      (display ")" port)
      (newline port)

      ; Initialiser les variables user-action-XX
      (display "       (set! user-action-<<EOF>>" port)
      (display " (<<EOF>>-pre-action" port)
      (newline port)
      (display "                                  final-lexer" port)
      (display " user-getc user-ungetc))" port)
      (newline port)
      (display "       (set! user-action-<<ERROR>>" port)
      (display " (<<ERROR>>-pre-action" port)
      (newline port)
      (display "                                    final-lexer" port)
      (display " user-getc user-ungetc))" port)
      (newline port)
      (let loop ((r 0))
	(if (< r nbrules)
	    (let* ((str-r (number->string r))
		   (blanks (out-blanks (string-length str-r))))
	      (display "       (set! user-action-" port)
	      (display str-r port)
	      (display " ((vector-ref rules-pre-action " port)
	      (display (number->string (+ (* 2 r) 1)) port)
	      (display ")" port)
	      (newline port)
	      (display blanks port)
	      (display "                           final-lexer " port)
	      (display "user-getc user-ungetc))" port)
	      (newline port)
	      (loop (+ r 1)))))

      ; Faire retourner le lexer final et fermer la table au complet
      (display "       final-lexer))))" port)
      (newline port))))

;
; Fonctions necessaires a l'initialisation automatique du lexer
;

(define out-print-driver-functions
  (lambda (args-alist port)
    (let ((counters   (cdr (or (assq 'counters args-alist) '(z . line))))
	  (table-name (cdr (assq 'table-name args-alist))))
      (display ";" port)
      (newline port)
      (display "; User functions" port)
      (newline port)
      (display ";" port)
      (newline port)
      (newline port)

      (display '(define the-lexer #f) port)

      (newline port)
      (newline port)

      ;; (display "(define lexer #f)" port)

      (display '(define (lexer) (the-lexer)) port)
      
      (newline port)
      (newline port)
      (if (not (eq? counters 'none))
	  (begin
	    (display "(define lexer-get-line   #f)" port)
	    (newline port)
	    (if (eq? counters 'all)
		(begin
		  (display "(define lexer-get-column #f)" port)
		  (newline port)
		  (display "(define lexer-get-offset #f)" port)
		  (newline port)))))
      (display "(define lexer-getc       #f)" port)
      (newline port)
      (display "(define lexer-ungetc     #f)" port)
      (newline port)
      (newline port)
      (display "(define lexer-init" port)
      (newline port)
      (display "  (lambda (input-type input)" port)
      (newline port)
      (display "    (let ((IS (lexer-make-IS input-type input '" port)
      (write counters port)
      (display ")))" port)
      (newline port)

      ;; (display "      (set! lexer (lexer-make-lexer " port)

      (display "      (set! the-lexer (lexer-make-lexer " port)
      
      (display table-name port)
      (display " IS))" port)
      (newline port)
      (if (not (eq? counters 'none))
	  (begin
	    (display "      (set! lexer-get-line   (lexer-get-func-line IS))"
		     port)
	    (newline port)
	    (if (eq? counters 'all)
		(begin
		  (display
		   "      (set! lexer-get-column (lexer-get-func-column IS))"
		   port)
		  (newline port)
		  (display
		   "      (set! lexer-get-offset (lexer-get-func-offset IS))"
		   port)
		  (newline port)))))
      (display "      (set! lexer-getc       (lexer-get-func-getc IS))" port)
      (newline port)
      (display "      (set! lexer-ungetc     (lexer-get-func-ungetc IS)))))"
	       port)
      (newline port))))

;
; Fonction principale
; Affiche une table ou un driver complet
;

(define output
  (lambda (args-alist
	   <<EOF>>-action <<ERROR>>-action rules
	   nl-start no-nl-start arcs acc)
    (let* ((fileout          (cdr (assq 'fileout args-alist)))
	   (port             (open-output-file fileout))
	   (complete-driver? (cdr (assq 'complete-driver? args-alist))))


      (if *library*

          (begin (display "(library " port)
                 (display *library*   port)
                 (display "\n\n"      port)

                 (display '(export lexer lexer-init) port)

                 (newline port)
                 (newline port)

                 (display '(import (rnrs)
                                   (rnrs r5rs)
                                   (rnrs mutable-strings))
                          port)

                 (newline port)
                 (newline port)
                 ))
      
      (if complete-driver?
	  (begin
	    (out-print-run-time-lib port)
	    (newline port)))
      (out-print-table args-alist
		       <<EOF>>-action <<ERROR>>-action rules
		       nl-start no-nl-start arcs acc
		       port)
      (if complete-driver?
	  (begin
	    (newline port)
	    (out-print-driver-functions args-alist port)))

      (if *library* (display ")" port))
      
      (close-output-port port))))

; Module output2.scm.

;
; Fonction de copiage du fichier run-time
;

(define out-print-run-time-lib
  (lambda (port)
    (display "; *** This file start" port)
    (display "s with a copy of the " port)
    (display "file multilex.scm ***" port)
    (newline port)
    (display "; SILex - Scheme Implementation of Lex
; Copyright (C) 2001  Danny Dube'
; 
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;
; Gestion des Input Systems
; Fonctions a utiliser par l'usager:
;   lexer-make-IS, lexer-get-func-getc, lexer-get-func-ungetc,
;   lexer-get-func-line, lexer-get-func-column et lexer-get-func-offset
;

; Taille initiale par defaut du buffer d'entree
(define lexer-init-buffer-len 1024)

; Numero du caractere newline
(define lexer-integer-newline (char->integer #\\newline))

; Constructeur d'IS brut
(define lexer-raw-IS-maker
  (lambda (buffer read-ptr input-f counters)
    (let ((input-f          input-f)                ; Entree reelle
	  (buffer           buffer)                 ; Buffer
	  (buflen           (string-length buffer))
	  (read-ptr         read-ptr)
	  (start-ptr        1)                      ; Marque de debut de lexeme
	  (start-line       1)
	  (start-column     1)
	  (start-offset     0)
	  (end-ptr          1)                      ; Marque de fin de lexeme
	  (point-ptr        1)                      ; Le point
	  (user-ptr         1)                      ; Marque de l'usager
	  (user-line        1)
	  (user-column      1)
	  (user-offset      0)
	  (user-up-to-date? #t))                    ; Concerne la colonne seul.
      (letrec
	  ((start-go-to-end-none         ; Fonctions de depl. des marques
	    (lambda ()
	      (set! start-ptr end-ptr)))
	   (start-go-to-end-line
	    (lambda ()
	      (let loop ((ptr start-ptr) (line start-line))
		(if (= ptr end-ptr)
		    (begin
		      (set! start-ptr ptr)
		      (set! start-line line))
		    (if (char=? (string-ref buffer ptr) #\\newline)
			(loop (+ ptr 1) (+ line 1))
			(loop (+ ptr 1) line))))))
	   (start-go-to-end-all
	    (lambda ()
	      (set! start-offset (+ start-offset (- end-ptr start-ptr)))
	      (let loop ((ptr start-ptr)
			 (line start-line)
			 (column start-column))
		(if (= ptr end-ptr)
		    (begin
		      (set! start-ptr ptr)
		      (set! start-line line)
		      (set! start-column column))
		    (if (char=? (string-ref buffer ptr) #\\newline)
			(loop (+ ptr 1) (+ line 1) 1)
			(loop (+ ptr 1) line (+ column 1)))))))
	   (start-go-to-user-none
	    (lambda ()
	      (set! start-ptr user-ptr)))
	   (start-go-to-user-line
	    (lambda ()
	      (set! start-ptr user-ptr)
	      (set! start-line user-line)))
	   (start-go-to-user-all
	    (lambda ()
	      (set! start-line user-line)
	      (set! start-offset user-offset)
	      (if user-up-to-date?
		  (begin
		    (set! start-ptr user-ptr)
		    (set! start-column user-column))
		  (let loop ((ptr start-ptr) (column start-column))
		    (if (= ptr user-ptr)
			(begin
			  (set! start-ptr ptr)
			  (set! start-column column))
			(if (char=? (string-ref buffer ptr) #\\newline)
			    (loop (+ ptr 1) 1)
			    (loop (+ ptr 1) (+ column 1))))))))
	   (end-go-to-point
	    (lambda ()
	      (set! end-ptr point-ptr)))
	   (point-go-to-start
	    (lambda ()
	      (set! point-ptr start-ptr)))
	   (user-go-to-start-none
	    (lambda ()
	      (set! user-ptr start-ptr)))
	   (user-go-to-start-line
	    (lambda ()
	      (set! user-ptr start-ptr)
	      (set! user-line start-line)))
	   (user-go-to-start-all
	    (lambda ()
	      (set! user-ptr start-ptr)
	      (set! user-line start-line)
	      (set! user-column start-column)
	      (set! user-offset start-offset)
	      (set! user-up-to-date? #t)))
	   (init-lexeme-none             ; Debute un nouveau lexeme
	    (lambda ()
	      (if (< start-ptr user-ptr)
		  (start-go-to-user-none))
	      (point-go-to-start)))
	   (init-lexeme-line
	    (lambda ()
	      (if (< start-ptr user-ptr)
		  (start-go-to-user-line))
	      (point-go-to-start)))
	   (init-lexeme-all
	    (lambda ()
	      (if (< start-ptr user-ptr)
		  (start-go-to-user-all))
	      (point-go-to-start)))
	   (get-start-line               ; Obtention des stats du debut du lxm
	    (lambda ()
	      start-line))
	   (get-start-column
	    (lambda ()
	      start-column))
	   (get-start-offset
	    (lambda ()
	      start-offset))
	   (peek-left-context            ; Obtention de caracteres (#f si EOF)
	    (lambda ()
	      (char->integer (string-ref buffer (- start-ptr 1)))))
	   (peek-char
	    (lambda ()
	      (if (< point-ptr read-ptr)
		  (char->integer (string-ref buffer point-ptr))
		  (let ((c (input-f)))
		    (if (char? c)
			(begin
			  (if (= read-ptr buflen)
			      (reorganize-buffer))
			  (string-set! buffer point-ptr c)
			  (set! read-ptr (+ point-ptr 1))
			  (char->integer c))
			(begin
			  (set! input-f (lambda () 'eof))
			  #f))))))
	   (read-char
	    (lambda ()
	      (if (< point-ptr read-ptr)
		  (let ((c (string-ref buffer point-ptr)))
		    (set! point-ptr (+ point-ptr 1))
		    (char->integer c))
		  (let ((c (input-f)))
		    (if (char? c)
			(begin
			  (if (= read-ptr buflen)
			      (reorganize-buffer))
			  (string-set! buffer point-ptr c)
			  (set! read-ptr (+ point-ptr 1))
			  (set! point-ptr read-ptr)
			  (char->integer c))
			(begin
			  (set! input-f (lambda () 'eof))
			  #f))))))
	   (get-start-end-text           ; Obtention du lexeme
	    (lambda ()
	      (substring buffer start-ptr end-ptr)))
	   (get-user-line-line           ; Fonctions pour l'usager
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-line))
	      user-line))
	   (get-user-line-all
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-all))
	      user-line))
	   (get-user-column-all
	    (lambda ()
	      (cond ((< user-ptr start-ptr)
		     (user-go-to-start-all)
		     user-column)
		    (user-up-to-date?
		     user-column)
		    (else
		     (let loop ((ptr start-ptr) (column start-column))
		       (if (= ptr user-ptr)
			   (begin
			     (set! user-column column)
			     (set! user-up-to-date? #t)
			     column)
			   (if (char=? (string-ref buffer ptr) #\\newline)
			       (loop (+ ptr 1) 1)
			       (loop (+ ptr 1) (+ column 1)))))))))
	   (get-user-offset-all
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-all))
	      user-offset))
	   (user-getc-none
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-none))
	      (if (< user-ptr read-ptr)
		  (let ((c (string-ref buffer user-ptr)))
		    (set! user-ptr (+ user-ptr 1))
		    c)
		  (let ((c (input-f)))
		    (if (char? c)
			(begin
			  (if (= read-ptr buflen)
			      (reorganize-buffer))
			  (string-set! buffer user-ptr c)
			  (set! read-ptr (+ read-ptr 1))
			  (set! user-ptr read-ptr)
			  c)
			(begin
			  (set! input-f (lambda () 'eof))
			  'eof))))))
	   (user-getc-line
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-line))
	      (if (< user-ptr read-ptr)
		  (let ((c (string-ref buffer user-ptr)))
		    (set! user-ptr (+ user-ptr 1))
		    (if (char=? c #\\newline)
			(set! user-line (+ user-line 1)))
		    c)
		  (let ((c (input-f)))
		    (if (char? c)
			(begin
			  (if (= read-ptr buflen)
			      (reorganize-buffer))
			  (string-set! buffer user-ptr c)
			  (set! read-ptr (+ read-ptr 1))
			  (set! user-ptr read-ptr)
			  (if (char=? c #\\newline)
			      (set! user-line (+ user-line 1)))
			  c)
			(begin
			  (set! input-f (lambda () 'eof))
			  'eof))))))
	   (user-getc-all
	    (lambda ()
	      (if (< user-ptr start-ptr)
		  (user-go-to-start-all))
	      (if (< user-ptr read-ptr)
		  (let ((c (string-ref buffer user-ptr)))
		    (set! user-ptr (+ user-ptr 1))
		    (if (char=? c #\\newline)
			(begin
			  (set! user-line (+ user-line 1))
			  (set! user-column 1))
			(set! user-column (+ user-column 1)))
		    (set! user-offset (+ user-offset 1))
		    c)
		  (let ((c (input-f)))
		    (if (char? c)
			(begin
			  (if (= read-ptr buflen)
			      (reorganize-buffer))
			  (string-set! buffer user-ptr c)
			  (set! read-ptr (+ read-ptr 1))
			  (set! user-ptr read-ptr)
			  (if (char=? c #\\newline)
			      (begin
				(set! user-line (+ user-line 1))
				(set! user-column 1))
			      (set! user-column (+ user-column 1)))
			  (set! user-offset (+ user-offset 1))
			  c)
			(begin
			  (set! input-f (lambda () 'eof))
			  'eof))))))
	   (user-ungetc-none
	    (lambda ()
	      (if (> user-ptr start-ptr)
		  (set! user-ptr (- user-ptr 1)))))
	   (user-ungetc-line
	    (lambda ()
	      (if (> user-ptr start-ptr)
		  (begin
		    (set! user-ptr (- user-ptr 1))
		    (let ((c (string-ref buffer user-ptr)))
		      (if (char=? c #\\newline)
			  (set! user-line (- user-line 1))))))))
	   (user-ungetc-all
	    (lambda ()
	      (if (> user-ptr start-ptr)
		  (begin
		    (set! user-ptr (- user-ptr 1))
		    (let ((c (string-ref buffer user-ptr)))
		      (if (char=? c #\\newline)
			  (begin
			    (set! user-line (- user-line 1))
			    (set! user-up-to-date? #f))
			  (set! user-column (- user-column 1)))
		      (set! user-offset (- user-offset 1)))))))
	   (reorganize-buffer            ; Decaler ou agrandir le buffer
	    (lambda ()
	      (if (< (* 2 start-ptr) buflen)
		  (let* ((newlen (* 2 buflen))
			 (newbuf (make-string newlen))
			 (delta (- start-ptr 1)))
		    (let loop ((from (- start-ptr 1)))
		      (if (< from buflen)
			  (begin
			    (string-set! newbuf
					 (- from delta)
					 (string-ref buffer from))
			    (loop (+ from 1)))))
		    (set! buffer    newbuf)
		    (set! buflen    newlen)
		    (set! read-ptr  (- read-ptr delta))
		    (set! start-ptr (- start-ptr delta))
		    (set! end-ptr   (- end-ptr delta))
		    (set! point-ptr (- point-ptr delta))
		    (set! user-ptr  (- user-ptr delta)))
		  (let ((delta (- start-ptr 1)))
		    (let loop ((from (- start-ptr 1)))
		      (if (< from buflen)
			  (begin
			    (string-set! buffer
					 (- from delta)
					 (string-ref buffer from))
			    (loop (+ from 1)))))
		    (set! read-ptr  (- read-ptr delta))
		    (set! start-ptr (- start-ptr delta))
		    (set! end-ptr   (- end-ptr delta))
		    (set! point-ptr (- point-ptr delta))
		    (set! user-ptr  (- user-ptr delta)))))))
	(list (cons 'start-go-to-end
		    (cond ((eq? counters 'none) start-go-to-end-none)
			  ((eq? counters 'line) start-go-to-end-line)
			  ((eq? counters 'all ) start-go-to-end-all)))
	      (cons 'end-go-to-point
		    end-go-to-point)
	      (cons 'init-lexeme
		    (cond ((eq? counters 'none) init-lexeme-none)
			  ((eq? counters 'line) init-lexeme-line)
			  ((eq? counters 'all ) init-lexeme-all)))
	      (cons 'get-start-line
		    get-start-line)
	      (cons 'get-start-column
		    get-start-column)
	      (cons 'get-start-offset
		    get-start-offset)
	      (cons 'peek-left-context
		    peek-left-context)
	      (cons 'peek-char
		    peek-char)
	      (cons 'read-char
		    read-char)
	      (cons 'get-start-end-text
		    get-start-end-text)
	      (cons 'get-user-line
		    (cond ((eq? counters 'none) #f)
			  ((eq? counters 'line) get-user-line-line)
			  ((eq? counters 'all ) get-user-line-all)))
	      (cons 'get-user-column
		    (cond ((eq? counters 'none) #f)
			  ((eq? counters 'line) #f)
			  ((eq? counters 'all ) get-user-column-all)))
	      (cons 'get-user-offset
		    (cond ((eq? counters 'none) #f)
			  ((eq? counters 'line) #f)
			  ((eq? counters 'all ) get-user-offset-all)))
	      (cons 'user-getc
		    (cond ((eq? counters 'none) user-getc-none)
			  ((eq? counters 'line) user-getc-line)
			  ((eq? counters 'all ) user-getc-all)))
	      (cons 'user-ungetc
		    (cond ((eq? counters 'none) user-ungetc-none)
			  ((eq? counters 'line) user-ungetc-line)
			  ((eq? counters 'all ) user-ungetc-all))))))))

; Construit un Input System
; Le premier parametre doit etre parmi \"port\", \"procedure\" ou \"string\"
; Prend un parametre facultatif qui doit etre parmi
; \"none\", \"line\" ou \"all\"
(define lexer-make-IS
  (lambda (input-type input . largs)
    (let ((counters-type (cond ((null? largs)
				'line)
			       ((memq (car largs) '(none line all))
				(car largs))
			       (else
				'line))))
      (cond ((and (eq? input-type 'port) (input-port? input))
	     (let* ((buffer   (make-string lexer-init-buffer-len #\\newline))
		    (read-ptr 1)
		    (input-f  (lambda () (read-char input))))
	       (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
	    ((and (eq? input-type 'procedure) (procedure? input))
	     (let* ((buffer   (make-string lexer-init-buffer-len #\\newline))
		    (read-ptr 1)
		    (input-f  input))
	       (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
	    ((and (eq? input-type 'string) (string? input))
	     (let* ((buffer   (string-append (string #\\newline) input))
		    (read-ptr (string-length buffer))
		    (input-f  (lambda () 'eof)))
	       (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))
	    (else
	     (let* ((buffer   (string #\\newline))
		    (read-ptr 1)
		    (input-f  (lambda () 'eof)))
	       (lexer-raw-IS-maker buffer read-ptr input-f counters-type)))))))

; Les fonctions:
;   lexer-get-func-getc, lexer-get-func-ungetc,
;   lexer-get-func-line, lexer-get-func-column et lexer-get-func-offset
(define lexer-get-func-getc
  (lambda (IS) (cdr (assq 'user-getc IS))))
(define lexer-get-func-ungetc
  (lambda (IS) (cdr (assq 'user-ungetc IS))))
(define lexer-get-func-line
  (lambda (IS) (cdr (assq 'get-user-line IS))))
(define lexer-get-func-column
  (lambda (IS) (cdr (assq 'get-user-column IS))))
(define lexer-get-func-offset
  (lambda (IS) (cdr (assq 'get-user-offset IS))))

;
; Gestion des lexers
;

; Fabrication de lexer a partir d'arbres de decision
(define lexer-make-tree-lexer
  (lambda (tables IS)
    (letrec
	(; Contenu de la table
	 (counters-type        (vector-ref tables 0))
	 (<<EOF>>-pre-action   (vector-ref tables 1))
	 (<<ERROR>>-pre-action (vector-ref tables 2))
	 (rules-pre-actions    (vector-ref tables 3))
	 (table-nl-start       (vector-ref tables 5))
	 (table-no-nl-start    (vector-ref tables 6))
	 (trees-v              (vector-ref tables 7))
	 (acc-v                (vector-ref tables 8))

	 ; Contenu du IS
	 (IS-start-go-to-end    (cdr (assq 'start-go-to-end IS)))
	 (IS-end-go-to-point    (cdr (assq 'end-go-to-point IS)))
	 (IS-init-lexeme        (cdr (assq 'init-lexeme IS)))
	 (IS-get-start-line     (cdr (assq 'get-start-line IS)))
	 (IS-get-start-column   (cdr (assq 'get-start-column IS)))
	 (IS-get-start-offset   (cdr (assq 'get-start-offset IS)))
	 (IS-peek-left-context  (cdr (assq 'peek-left-context IS)))
	 (IS-peek-char          (cdr (assq 'peek-char IS)))
	 (IS-read-char          (cdr (assq 'read-char IS)))
	 (IS-get-start-end-text (cdr (assq 'get-start-end-text IS)))
	 (IS-get-user-line      (cdr (assq 'get-user-line IS)))
	 (IS-get-user-column    (cdr (assq 'get-user-column IS)))
	 (IS-get-user-offset    (cdr (assq 'get-user-offset IS)))
	 (IS-user-getc          (cdr (assq 'user-getc IS)))
	 (IS-user-ungetc        (cdr (assq 'user-ungetc IS)))

	 ; Resultats
	 (<<EOF>>-action   #f)
	 (<<ERROR>>-action #f)
	 (rules-actions    #f)
	 (states           #f)
	 (final-lexer      #f)

	 ; Gestion des hooks
	 (hook-list '())
	 (add-hook
	  (lambda (thunk)
	    (set! hook-list (cons thunk hook-list))))
	 (apply-hooks
	  (lambda ()
	    (let loop ((l hook-list))
	      (if (pair? l)
		  (begin
		    ((car l))
		    (loop (cdr l)))))))

	 ; Preparation des actions
	 (set-action-statics
	  (lambda (pre-action)
	    (pre-action final-lexer IS-user-getc IS-user-ungetc)))
	 (prepare-special-action-none
	  (lambda (pre-action)
	    (let ((action #f))
	      (let ((result
		     (lambda ()
		       (action \"\")))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-special-action-line
	  (lambda (pre-action)
	    (let ((action #f))
	      (let ((result
		     (lambda (yyline)
		       (action \"\" yyline)))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-special-action-all
	  (lambda (pre-action)
	    (let ((action #f))
	      (let ((result
		     (lambda (yyline yycolumn yyoffset)
		       (action \"\" yyline yycolumn yyoffset)))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-special-action
	  (lambda (pre-action)
	    (cond ((eq? counters-type 'none)
		   (prepare-special-action-none pre-action))
		  ((eq? counters-type 'line)
		   (prepare-special-action-line pre-action))
		  ((eq? counters-type 'all)
		   (prepare-special-action-all  pre-action)))))
	 (prepare-action-yytext-none
	  (lambda (pre-action)
	    (let ((get-start-end-text IS-get-start-end-text)
		  (start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda ()
		       (let ((yytext (get-start-end-text)))
			 (start-go-to-end)
			 (action yytext))))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-yytext-line
	  (lambda (pre-action)
	    (let ((get-start-end-text IS-get-start-end-text)
		  (start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda (yyline)
		       (let ((yytext (get-start-end-text)))
			 (start-go-to-end)
			 (action yytext yyline))))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-yytext-all
	  (lambda (pre-action)
	    (let ((get-start-end-text IS-get-start-end-text)
		  (start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda (yyline yycolumn yyoffset)
		       (let ((yytext (get-start-end-text)))
			 (start-go-to-end)
			 (action yytext yyline yycolumn yyoffset))))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-yytext
	  (lambda (pre-action)
	    (cond ((eq? counters-type 'none)
		   (prepare-action-yytext-none pre-action))
		  ((eq? counters-type 'line)
		   (prepare-action-yytext-line pre-action))
		  ((eq? counters-type 'all)
		   (prepare-action-yytext-all  pre-action)))))
	 (prepare-action-no-yytext-none
	  (lambda (pre-action)
	    (let ((start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda ()
		       (start-go-to-end)
		       (action)))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-no-yytext-line
	  (lambda (pre-action)
	    (let ((start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda (yyline)
		       (start-go-to-end)
		       (action yyline)))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-no-yytext-all
	  (lambda (pre-action)
	    (let ((start-go-to-end    IS-start-go-to-end)
		  (action             #f))
	      (let ((result
		     (lambda (yyline yycolumn yyoffset)
		       (start-go-to-end)
		       (action yyline yycolumn yyoffset)))
		    (hook
		     (lambda ()
		       (set! action (set-action-statics pre-action)))))
		(add-hook hook)
		result))))
	 (prepare-action-no-yytext
	  (lambda (pre-action)
	    (cond ((eq? counters-type 'none)
		   (prepare-action-no-yytext-none pre-action))
		  ((eq? counters-type 'line)
		   (prepare-action-no-yytext-line pre-action))
		  ((eq? counters-type 'all)
		   (prepare-action-no-yytext-all  pre-action)))))

	 ; Fabrique les fonctions de dispatch
	 (prepare-dispatch-err
	  (lambda (leaf)
	    (lambda (c)
	      #f)))
	 (prepare-dispatch-number
	  (lambda (leaf)
	    (let ((state-function #f))
	      (let ((result
		     (lambda (c)
		       state-function))
		    (hook
		     (lambda ()
		       (set! state-function (vector-ref states leaf)))))
		(add-hook hook)
		result))))
	 (prepare-dispatch-leaf
	  (lambda (leaf)
	    (if (eq? leaf 'err)
		(prepare-dispatch-err leaf)
		(prepare-dispatch-number leaf))))
	 (prepare-dispatch-<
	  (lambda (tree)
	    (let ((left-tree  (list-ref tree 1))
		  (right-tree (list-ref tree 2)))
	      (let ((bound      (list-ref tree 0))
		    (left-func  (prepare-dispatch-tree left-tree))
		    (right-func (prepare-dispatch-tree right-tree)))
		(lambda (c)
		  (if (< c bound)
		      (left-func c)
		      (right-func c)))))))
	 (prepare-dispatch-=
	  (lambda (tree)
	    (let ((left-tree  (list-ref tree 2))
		  (right-tree (list-ref tree 3)))
	      (let ((bound      (list-ref tree 1))
		    (left-func  (prepare-dispatch-tree left-tree))
		    (right-func (prepare-dispatch-tree right-tree)))
		(lambda (c)
		  (if (= c bound)
		      (left-func c)
		      (right-func c)))))))
	 (prepare-dispatch-tree
	  (lambda (tree)
	    (cond ((not (pair? tree))
		   (prepare-dispatch-leaf tree))
		  ((eq? (car tree) '=)
		   (prepare-dispatch-= tree))
		  (else
		   (prepare-dispatch-< tree)))))
	 (prepare-dispatch
	  (lambda (tree)
	    (let ((dicho-func (prepare-dispatch-tree tree)))
	      (lambda (c)
		(and c (dicho-func c))))))

	 ; Fabrique les fonctions de transition (read & go) et (abort)
	 (prepare-read-n-go
	  (lambda (tree)
	    (let ((dispatch-func (prepare-dispatch tree))
		  (read-char     IS-read-char))
	      (lambda ()
		(dispatch-func (read-char))))))
	 (prepare-abort
	  (lambda (tree)
	    (lambda ()
	      #f)))
	 (prepare-transition
	  (lambda (tree)
	    (if (eq? tree 'err)
		(prepare-abort     tree)
		(prepare-read-n-go tree))))

	 ; Fabrique les fonctions d'etats ([set-end] & trans)
	 (prepare-state-no-acc
	   (lambda (s r1 r2)
	     (let ((trans-func (prepare-transition (vector-ref trees-v s))))
	       (lambda (action)
		 (let ((next-state (trans-func)))
		   (if next-state
		       (next-state action)
		       action))))))
	 (prepare-state-yes-no
	  (lambda (s r1 r2)
	    (let ((peek-char       IS-peek-char)
		  (end-go-to-point IS-end-go-to-point)
		  (new-action1     #f)
		  (trans-func (prepare-transition (vector-ref trees-v s))))
	      (let ((result
		     (lambda (action)
		       (let* ((c (peek-char))
			      (new-action
			       (if (or (not c) (= c lexer-integer-newline))
				   (begin
				     (end-go-to-point)
				     new-action1)
				   action))
			      (next-state (trans-func)))
			 (if next-state
			     (next-state new-action)
			     new-action))))
		    (hook
		     (lambda ()
		       (set! new-action1 (vector-ref rules-actions r1)))))
		(add-hook hook)
		result))))
	 (prepare-state-diff-acc
	  (lambda (s r1 r2)
	    (let ((end-go-to-point IS-end-go-to-point)
		  (peek-char       IS-peek-char)
		  (new-action1     #f)
		  (new-action2     #f)
		  (trans-func (prepare-transition (vector-ref trees-v s))))
	      (let ((result
		     (lambda (action)
		       (end-go-to-point)
		       (let* ((c (peek-char))
			      (new-action
			       (if (or (not c) (= c lexer-integer-newline))
				   new-action1
				   new-action2))
			      (next-state (trans-func)))
			 (if next-state
			     (next-state new-action)
			     new-action))))
		    (hook
		     (lambda ()
		       (set! new-action1 (vector-ref rules-actions r1))
		       (set! new-action2 (vector-ref rules-actions r2)))))
		(add-hook hook)
		result))))
	 (prepare-state-same-acc
	  (lambda (s r1 r2)
	    (let ((end-go-to-point IS-end-go-to-point)
		  (trans-func (prepare-transition (vector-ref trees-v s)))
		  (new-action #f))
	      (let ((result
		     (lambda (action)
		       (end-go-to-point)
		       (let ((next-state (trans-func)))
			 (if next-state
			     (next-state new-action)
			     new-action))))
		    (hook
		     (lambda ()
		       (set! new-action (vector-ref rules-actions r1)))))
		(add-hook hook)
		result))))
	 (prepare-state
	  (lambda (s)
	    (let* ((acc (vector-ref acc-v s))
		   (r1 (car acc))
		   (r2 (cdr acc)))
	      (cond ((not r1)  (prepare-state-no-acc   s r1 r2))
		    ((not r2)  (prepare-state-yes-no   s r1 r2))
		    ((< r1 r2) (prepare-state-diff-acc s r1 r2))
		    (else      (prepare-state-same-acc s r1 r2))))))

	 ; Fabrique la fonction de lancement du lexage a l'etat de depart
	 (prepare-start-same
	  (lambda (s1 s2)
	    (let ((peek-char    IS-peek-char)
		  (eof-action   #f)
		  (start-state  #f)
		  (error-action #f))
	      (let ((result
		     (lambda ()
		       (if (not (peek-char))
			   eof-action
			   (start-state error-action))))
		    (hook
		     (lambda ()
		       (set! eof-action   <<EOF>>-action)
		       (set! start-state  (vector-ref states s1))
		       (set! error-action <<ERROR>>-action))))
		(add-hook hook)
		result))))
	 (prepare-start-diff
	  (lambda (s1 s2)
	    (let ((peek-char         IS-peek-char)
		  (eof-action        #f)
		  (peek-left-context IS-peek-left-context)
		  (start-state1      #f)
		  (start-state2      #f)
		  (error-action      #f))
	      (let ((result
		     (lambda ()
		       (cond ((not (peek-char))
			      eof-action)
			     ((= (peek-left-context) lexer-integer-newline)
			      (start-state1 error-action))
			     (else
			      (start-state2 error-action)))))
		    (hook
		     (lambda ()
		       (set! eof-action <<EOF>>-action)
		       (set! start-state1 (vector-ref states s1))
		       (set! start-state2 (vector-ref states s2))
		       (set! error-action <<ERROR>>-action))))
		(add-hook hook)
		result))))
	 (prepare-start
	  (lambda ()
	    (let ((s1 table-nl-start)
		  (s2 table-no-nl-start))
	      (if (= s1 s2)
		  (prepare-start-same s1 s2)
		  (prepare-start-diff s1 s2)))))

	 ; Fabrique la fonction principale
	 (prepare-lexer-none
	  (lambda ()
	    (let ((init-lexeme IS-init-lexeme)
		  (start-func  (prepare-start)))
	      (lambda ()
		(init-lexeme)
		((start-func))))))
	 (prepare-lexer-line
	  (lambda ()
	    (let ((init-lexeme    IS-init-lexeme)
		  (get-start-line IS-get-start-line)
		  (start-func     (prepare-start)))
	      (lambda ()
		(init-lexeme)
		(let ((yyline (get-start-line)))
		  ((start-func) yyline))))))
	 (prepare-lexer-all
	  (lambda ()
	    (let ((init-lexeme      IS-init-lexeme)
		  (get-start-line   IS-get-start-line)
		  (get-start-column IS-get-start-column)
		  (get-start-offset IS-get-start-offset)
		  (start-func       (prepare-start)))
	      (lambda ()
		(init-lexeme)
		(let ((yyline   (get-start-line))
		      (yycolumn (get-start-column))
		      (yyoffset (get-start-offset)))
		  ((start-func) yyline yycolumn yyoffset))))))
	 (prepare-lexer
	  (lambda ()
	    (cond ((eq? counters-type 'none) (prepare-lexer-none))
		  ((eq? counters-type 'line) (prepare-lexer-line))
		  ((eq? counters-type 'all)  (prepare-lexer-all))))))

      ; Calculer la valeur de <<EOF>>-action et de <<ERROR>>-action
      (set! <<EOF>>-action   (prepare-special-action <<EOF>>-pre-action))
      (set! <<ERROR>>-action (prepare-special-action <<ERROR>>-pre-action))

      ; Calculer la valeur de rules-actions
      (let* ((len (quotient (vector-length rules-pre-actions) 2))
	     (v (make-vector len)))
	(let loop ((r (- len 1)))
	  (if (< r 0)
	      (set! rules-actions v)
	      (let* ((yytext? (vector-ref rules-pre-actions (* 2 r)))
		     (pre-action (vector-ref rules-pre-actions (+ (* 2 r) 1)))
		     (action (if yytext?
				 (prepare-action-yytext    pre-action)
				 (prepare-action-no-yytext pre-action))))
		(vector-set! v r action)
		(loop (- r 1))))))

      ; Calculer la valeur de states
      (let* ((len (vector-length trees-v))
	     (v (make-vector len)))
	(let loop ((s (- len 1)))
	  (if (< s 0)
	      (set! states v)
	      (begin
		(vector-set! v s (prepare-state s))
		(loop (- s 1))))))

      ; Calculer la valeur de final-lexer
      (set! final-lexer (prepare-lexer))

      ; Executer les hooks
      (apply-hooks)

      ; Resultat
      final-lexer)))

; Fabrication de lexer a partir de listes de caracteres taggees
(define lexer-make-char-lexer
  (let* ((char->class
	  (lambda (c)
	    (let ((n (char->integer c)))
	      (list (cons n n)))))
	 (merge-sort
	  (lambda (l combine zero-elt)
	    (if (null? l)
		zero-elt
		(let loop1 ((l l))
		  (if (null? (cdr l))
		      (car l)
		      (loop1
		       (let loop2 ((l l))
			 (cond ((null? l)
				l)
			       ((null? (cdr l))
				l)
			       (else
				(cons (combine (car l) (cadr l))
				      (loop2 (cddr l))))))))))))
	 (finite-class-union
	  (lambda (c1 c2)
	    (let loop ((c1 c1) (c2 c2) (u '()))
	      (if (null? c1)
		  (if (null? c2)
		      (reverse u)
		      (loop c1 (cdr c2) (cons (car c2) u)))
		  (if (null? c2)
		      (loop (cdr c1) c2 (cons (car c1) u))
		      (let* ((r1 (car c1))
			     (r2 (car c2))
			     (r1start (car r1))
			     (r1end (cdr r1))
			     (r2start (car r2))
			     (r2end (cdr r2)))
			(if (<= r1start r2start)
			    (cond ((< (+ r1end 1) r2start)
				   (loop (cdr c1) c2 (cons r1 u)))
				  ((<= r1end r2end)
				   (loop (cdr c1)
					 (cons (cons r1start r2end) (cdr c2))
					 u))
				  (else
				   (loop c1 (cdr c2) u)))
			    (cond ((> r1start (+ r2end 1))
				   (loop c1 (cdr c2) (cons r2 u)))
				  ((>= r1end r2end)
				   (loop (cons (cons r2start r1end) (cdr c1))
					 (cdr c2)
					 u))
				  (else
				   (loop (cdr c1) c2 u))))))))))
	 (char-list->class
	  (lambda (cl)
	    (let ((classes (map char->class cl)))
	      (merge-sort classes finite-class-union '()))))
	 (class-<
	  (lambda (b1 b2)
	    (cond ((eq? b1 'inf+) #f)
		  ((eq? b2 'inf-) #f)
		  ((eq? b1 'inf-) #t)
		  ((eq? b2 'inf+) #t)
		  (else (< b1 b2)))))
	 (finite-class-compl
	  (lambda (c)
	    (let loop ((c c) (start 'inf-))
	      (if (null? c)
		  (list (cons start 'inf+))
		  (let* ((r (car c))
			 (rstart (car r))
			 (rend (cdr r)))
		    (if (class-< start rstart)
			(cons (cons start (- rstart 1))
			      (loop c rstart))
			(loop (cdr c) (+ rend 1))))))))
	 (tagged-chars->class
	  (lambda (tcl)
	    (let* ((inverse? (car tcl))
		   (cl (cdr tcl))
		   (class-tmp (char-list->class cl)))
	      (if inverse? (finite-class-compl class-tmp) class-tmp))))
	 (charc->arc
	  (lambda (charc)
	    (let* ((tcl (car charc))
		   (dest (cdr charc))
		   (class (tagged-chars->class tcl)))
	      (cons class dest))))
	 (arc->sharcs
	  (lambda (arc)
	    (let* ((range-l (car arc))
		   (dest (cdr arc))
		   (op (lambda (range) (cons range dest))))
	      (map op range-l))))
	 (class-<=
	  (lambda (b1 b2)
	    (cond ((eq? b1 'inf-) #t)
		  ((eq? b2 'inf+) #t)
		  ((eq? b1 'inf+) #f)
		  ((eq? b2 'inf-) #f)
		  (else (<= b1 b2)))))
	 (sharc-<=
	  (lambda (sharc1 sharc2)
	    (class-<= (caar sharc1) (caar sharc2))))
	 (merge-sharcs
	  (lambda (l1 l2)
	    (let loop ((l1 l1) (l2 l2))
	      (cond ((null? l1)
		     l2)
		    ((null? l2)
		     l1)
		    (else
		     (let ((sharc1 (car l1))
			   (sharc2 (car l2)))
		       (if (sharc-<= sharc1 sharc2)
			   (cons sharc1 (loop (cdr l1) l2))
			   (cons sharc2 (loop l1 (cdr l2))))))))))
	 (class-= eqv?)
	 (fill-error
	  (lambda (sharcs)
	    (let loop ((sharcs sharcs) (start 'inf-))
	      (cond ((class-= start 'inf+)
		     '())
		    ((null? sharcs)
		     (cons (cons (cons start 'inf+) 'err)
			   (loop sharcs 'inf+)))
		    (else
		     (let* ((sharc (car sharcs))
			    (h (caar sharc))
			    (t (cdar sharc)))
		       (if (class-< start h)
			   (cons (cons (cons start (- h 1)) 'err)
				 (loop sharcs h))
			   (cons sharc (loop (cdr sharcs)
					     (if (class-= t 'inf+)
						 'inf+
						 (+ t 1)))))))))))
	 (charcs->tree
	  (lambda (charcs)
	    (let* ((op (lambda (charc) (arc->sharcs (charc->arc charc))))
		   (sharcs-l (map op charcs))
		   (sorted-sharcs (merge-sort sharcs-l merge-sharcs '()))
		   (full-sharcs (fill-error sorted-sharcs))
		   (op (lambda (sharc) (cons (caar sharc) (cdr sharc))))
		   (table (list->vector (map op full-sharcs))))
	      (let loop ((left 0) (right (- (vector-length table) 1)))
		(if (= left right)
		    (cdr (vector-ref table left))
		    (let ((mid (quotient (+ left right 1) 2)))
		      (if (and (= (+ left 2) right)
			       (= (+ (car (vector-ref table mid)) 1)
				  (car (vector-ref table right)))
			       (eqv? (cdr (vector-ref table left))
				     (cdr (vector-ref table right))))
			  (list '=
				(car (vector-ref table mid))
				(cdr (vector-ref table mid))
				(cdr (vector-ref table left)))
			  (list (car (vector-ref table mid))
				(loop left (- mid 1))
				(loop mid right))))))))))
    (lambda (tables IS)
      (let ((counters         (vector-ref tables 0))
	    (<<EOF>>-action   (vector-ref tables 1))
	    (<<ERROR>>-action (vector-ref tables 2))
	    (rules-actions    (vector-ref tables 3))
	    (nl-start         (vector-ref tables 5))
	    (no-nl-start      (vector-ref tables 6))
	    (charcs-v         (vector-ref tables 7))
	    (acc-v            (vector-ref tables 8)))
	(let* ((len (vector-length charcs-v))
	       (v (make-vector len)))
	  (let loop ((i (- len 1)))
	    (if (>= i 0)
		(begin
		  (vector-set! v i (charcs->tree (vector-ref charcs-v i)))
		  (loop (- i 1)))
		(lexer-make-tree-lexer
		 (vector counters
			 <<EOF>>-action
			 <<ERROR>>-action
			 rules-actions
			 'decision-trees
			 nl-start
			 no-nl-start
			 v
			 acc-v)
		 IS))))))))

; Fabrication d'un lexer a partir de code pre-genere
(define lexer-make-code-lexer
  (lambda (tables IS)
    (let ((<<EOF>>-pre-action   (vector-ref tables 1))
	  (<<ERROR>>-pre-action (vector-ref tables 2))
	  (rules-pre-action     (vector-ref tables 3))
	  (code                 (vector-ref tables 5)))
      (code <<EOF>>-pre-action <<ERROR>>-pre-action rules-pre-action IS))))

(define lexer-make-lexer
  (lambda (tables IS)
    (let ((automaton-type (vector-ref tables 4)))
      (cond ((eq? automaton-type 'decision-trees)
	     (lexer-make-tree-lexer tables IS))
	    ((eq? automaton-type 'tagged-chars-lists)
	     (lexer-make-char-lexer tables IS))
	    ((eq? automaton-type 'code)
	     (lexer-make-code-lexer tables IS))))))
" port)))

; Module main.scm.

;
; Gestion d'erreurs
;

(define lex-exit-continuation #f)
(define lex-unwind-protect-list '())
(define lex-error-filename #f)

(define lex-unwind-protect
  (lambda (proc)
    (set! lex-unwind-protect-list (cons proc lex-unwind-protect-list))))

(define lex-error
  (lambda (line column . l)
    (let* ((linestr (if line   (number->string line)   #f))
	   (colstr  (if column (number->string column) #f))
	   (namelen (string-length lex-error-filename))
	   (linelen (if line   (string-length linestr) -1))
	   (collen  (if column (string-length colstr)  -1))
	   (totallen (+ namelen 1 linelen 1 collen 2)))
      (display "Lex error:")
      (newline)
      (display lex-error-filename)
      (if line
	  (begin
	    (display ":")
	    (display linestr)))
      (if column
	  (begin
	    (display ":")
	    (display colstr)))
      (display ": ")
      (let loop ((l l))
	(if (null? l)
	    (newline)
	    (let ((item (car l)))
	      (display item)
	      (if (equal? '#\newline item)
		  (let loop2 ((i totallen))
		    (if (> i 0)
			(begin
			  (display #\space)
			  (loop2 (- i 1))))))
	      (loop (cdr l)))))
      (newline)
      (let loop ((l lex-unwind-protect-list))
	(if (pair? l)
	    (begin
	      ((car l))
	      (loop (cdr l)))))
      (lex-exit-continuation #f))))




;
; Decoupage des arguments
;

(define lex-recognized-args
  '(complete-driver?
    filein
    table-name
    fileout
    counters
    portable
    code
    pp))

(define lex-valued-args
  '(complete-driver?
    filein
    table-name
    fileout
    counters))

(define lex-parse-args
  (lambda (args)
    (let loop ((args args))
      (if (null? args)
	  '()
	  (let ((sym (car args)))
	    (cond ((not (symbol? sym))
		   (lex-error #f #f "bad option list."))
		  ((not (memq sym lex-recognized-args))
		   (lex-error #f #f "unrecognized option \"" sym "\"."))
		  ((not (memq sym lex-valued-args))
		   (cons (cons sym '()) (loop (cdr args))))
		  ((null? (cdr args))
		   (lex-error #f #f "the value of \"" sym "\" not specified."))
		  (else
		   (cons (cons sym (cadr args)) (loop (cddr args))))))))))




;
; Differentes etapes de la fabrication de l'automate
;

(define lex1
  (lambda (filein)
;     (display "lex1: ") (write (get-internal-run-time)) (newline)
    (parser filein)))

(define lex2
  (lambda (filein)
    (let* ((result (lex1 filein))
	   (<<EOF>>-action (car result))
	   (<<ERROR>>-action (cadr result))
	   (rules (cddr result)))
;       (display "lex2: ") (write (get-internal-run-time)) (newline)
      (append (list <<EOF>>-action <<ERROR>>-action rules)
	      (re2nfa rules)))))

(define lex3
  (lambda (filein)
    (let* ((result (lex2 filein))
	   (<<EOF>>-action   (list-ref result 0))
	   (<<ERROR>>-action (list-ref result 1))
	   (rules            (list-ref result 2))
	   (nl-start         (list-ref result 3))
	   (no-nl-start      (list-ref result 4))
	   (arcs             (list-ref result 5))
	   (acc              (list-ref result 6)))
;       (display "lex3: ") (write (get-internal-run-time)) (newline)
      (append (list <<EOF>>-action <<ERROR>>-action rules)
	      (noeps nl-start no-nl-start arcs acc)))))

(define lex4
  (lambda (filein)
    (let* ((result (lex3 filein))
	   (<<EOF>>-action   (list-ref result 0))
	   (<<ERROR>>-action (list-ref result 1))
	   (rules            (list-ref result 2))
	   (nl-start         (list-ref result 3))
	   (no-nl-start      (list-ref result 4))
	   (arcs             (list-ref result 5))
	   (acc              (list-ref result 6)))
;       (display "lex4: ") (write (get-internal-run-time)) (newline)
      (append (list <<EOF>>-action <<ERROR>>-action rules)
	      (sweep nl-start no-nl-start arcs acc)))))

(define lex5
  (lambda (filein)
    (let* ((result (lex4 filein))
	   (<<EOF>>-action   (list-ref result 0))
	   (<<ERROR>>-action (list-ref result 1))
	   (rules            (list-ref result 2))
	   (nl-start         (list-ref result 3))
	   (no-nl-start      (list-ref result 4))
	   (arcs             (list-ref result 5))
	   (acc              (list-ref result 6)))
;       (display "lex5: ") (write (get-internal-run-time)) (newline)
      (append (list <<EOF>>-action <<ERROR>>-action rules)
	      (nfa2dfa nl-start no-nl-start arcs acc)))))

(define lex6
  (lambda (args-alist)
    (let* ((filein           (cdr (assq 'filein args-alist)))
	   (result           (lex5 filein))
	   (<<EOF>>-action   (list-ref result 0))
	   (<<ERROR>>-action (list-ref result 1))
	   (rules            (list-ref result 2))
	   (nl-start         (list-ref result 3))
	   (no-nl-start      (list-ref result 4))
	   (arcs             (list-ref result 5))
	   (acc              (list-ref result 6)))
;       (display "lex6: ") (write (get-internal-run-time)) (newline)
      (prep-set-rules-yytext? rules)
      (output args-alist
	      <<EOF>>-action <<ERROR>>-action
	      rules nl-start no-nl-start arcs acc)
      #t)))

(define lex7
  (lambda (args)
    (call-with-current-continuation
     (lambda (exit)
       (set! lex-exit-continuation exit)
       (set! lex-unwind-protect-list '())
       (set! lex-error-filename (cadr (memq 'filein args)))
       (let* ((args-alist (lex-parse-args args))
	      (result (lex6 args-alist)))
; 	 (display "lex7: ") (write (get-internal-run-time)) (newline)
	 result)))))




;
; Fonctions principales
;

(define lex
  (lambda (filein fileout . options)
    (lex7 (append (list 'complete-driver? #t
			'filein filein
			'table-name "lexer-default-table"
			'fileout fileout)
		  options))))

(define lex-lib
  (lambda (filein fileout library . options)
    (set! *library* library)
    (lex7 (append (list 'complete-driver? #t
			'filein filein
			'table-name "lexer-default-table"
			'fileout fileout)
		  options))))

(define lex-tables
  (lambda (filein table-name fileout . options)
    (lex7 (append (list 'complete-driver? #f
			'filein filein
			'table-name table-name
			'fileout fileout)
		  options))))

)