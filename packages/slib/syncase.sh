#! /bin/sh -e

echo Cleaning up old version and unpacking original ...
rm -fr syntax-case
gzip --decompress --stdout syntax-case.tar.z | tar xf -

cd syntax-case

echo Removing some files ...
rm *.ps loadpp.ss hooks*

# Remove enormous amount (about 200k) of white space in expand.pp
echo Slimming expand.pp ...
sed -e '/^ */s///' expand.pp > tt; mv tt expand.pp

echo Patching ...
patch -s -b .ORIG << 'PATCH'
--- ./expand.pp.ORIG	Wed Mar 24 19:54:52 1993
+++ ./expand.pp	Wed Mar 24 19:54:52 1993
@@ -337,9 +337,10 @@
 '()
 (lambda (e maps) (regen e)))))
 (ellipsis? (lambda (x)
-(if (if (top-level-bound? 'dp) dp #f)
-(break)
-(void))
+;; I dont know what this is supposed to do, and removing it seemed harmless.
+;; (if (if (top-level-bound? 'dp) dp #f)
+;; (break)
+;; (void))
 (if (identifier? x)
 (free-id=? x '...)
 #f)))
@@ -1674,7 +1675,7 @@
 (set! generate-temporaries
 (lambda (ls)
 (arg-check list? ls 'generate-temporaries)
-(map (lambda (x) (wrap (gensym) top-wrap)) ls)))
+(map (lambda (x) (wrap (new-symbol-hook "g") top-wrap)) ls)))
 (set! free-identifier=?
 (lambda (x y)
 (arg-check id? x 'free-identifier=?)
--- ./expand.ss.ORIG	Thu Jul  2 13:56:19 1992
+++ ./expand.ss	Wed Mar 24 19:54:53 1993
@@ -564,7 +564,8 @@
 
 (define ellipsis?
    (lambda (x)
-      (when (and (top-level-bound? 'dp) dp) (break))
+      ;; I dont know what this is supposed to do, and removing it seemed harmless.
+      ;; (when (and (top-level-bound? 'dp) dp) (break))
       (and (identifier? x)
            (free-id=? x (syntax (... ...))))))
 
@@ -887,7 +888,7 @@
    ;; gensym
    (lambda (ls)
       (arg-check list? ls 'generate-temporaries)
-      (map (lambda (x) (wrap (gensym) top-wrap)) ls)))
+      (map (lambda (x) (wrap (new-symbol-hook "g") top-wrap)) ls)))
 
 (set! free-identifier=?
    (lambda (x y)
--- ./macro-defs.ss.ORIG	Thu Jul  2 12:28:49 1992
+++ ./macro-defs.ss	Wed Mar 24 19:55:31 1993
@@ -161,26 +161,3 @@
        (syntax-case x ()
           ((- e) (gen (syntax e) 0))))))
 
-;;; simple delay and force; also defines make-promise
-
-(define-syntax delay
-   (lambda (x)
-      (syntax-case x ()
-         ((delay exp)
-          (syntax (make-promise (lambda () exp)))))))
-
-(define make-promise
-   (lambda (thunk)
-      (let ([value (void)] [set? #f])
-         (lambda ()
-            (unless set?
-               (let ([v (thunk)])
-                  (unless set?
-                     (set! value v)
-                     (set! set? #t))))
-            value))))
-
-(define force
-   (lambda (promise)
-      (promise)))
-
PATCH
test $# -gt 0 && exit 0
rm *.ORIG
###############################################################################

echo Renaming globals ...

CR='
'
SEDCMD='s/list\*/syncase:list*/g'
for x in \
  build- void andmap install-global-transformer eval-hook error-hook \
  new-symbol-hook put-global-definition-hook get-global-definition-hook \
  expand-install-hook;
do SEDCMD=$SEDCMD$CR"s/$x/syncase:$x/g"; done

WARN=";;; This file was munged by a simple minded sed script since it left
;;; its original authors' hands.  See syncase.doc for the horrid details.
"

for f in *.pp *.ss; do
  mv $f tt; (echo "$WARN"; sed -e "$SEDCMD" tt) >$f; rm tt; done

echo Making the doc file ...
DOC=syncase.doc
cp ../$DOC .
for f in Notes ReadMe; do
echo "
*******************************************************************************
The file named $f in the original distribution:
"
cat $f
rm $f
done >>$DOC

echo "
*******************************************************************************
The shell script that created these files out of the original distribution:
" >>$DOC
cat ../fixit >>$DOC

echo Renaming files ...
mv compat.ss sca-comp.scm
mv output.ss scaoutp.scm
mv init.ss scaglob.scm
mv expand.pp scaexpp.scm
mv expand.ss sca-exp.scm
mv macro-defs.ss scamacr.scm
mv structure.ss structure.scm

echo Adding new pieces ...
cp ../sca-init.scm scainit.scm

echo Done.
