# Makefile for Scheme Library
# Author: Aubrey Jaffer
#
# This code is in the public domain.

# These are normally set in "config.status"; defaults are here so that
# "make" won't complain about target redefinitions.
snapdir=$(HOME)/pub/
infodir=$(HOME)/info/
htmldir=$(HOME)/public_html/

SHELL = /bin/sh
INSTALL = install
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_INFO = ginstall-info

SCHEME = scm
CHPAT = $(HOME)/bin/chpat
MAKEDEV = $(MAKE) -f $(HOME)/makefile.dev
TEXI2HTML = /usr/local/bin/texi2html -split -verbose
TEXI2PDF = texi2pdf
RSYNC = rsync -av
Uploadee = csail

RUNNABLE = scheme48
S48INIT = scheme48.init
S48LIB = $(libdir)$(RUNNABLE)/
S48SLIB = $(S48LIB)slib/
IMAGE48 = slib.image

intro:	config.status
	@echo
	@echo "Welcome to SLIB.  Read \"README\" and \"slib.info\" (or"
	@echo "\"slib.texi\") to learn how to install and use SLIB."
	@echo

VERSION = 3b5
RELEASE = 1

# ./configure --distdir=${HOME}/dist/ --snapdir=${HOME}/pub/ --htmldir=${HOME}/public_html/ --pdfdir=${HOME}/public_html/

config.status:
	./configure
Makefile: config.status
include config.status

prevdocsdir = prevdocs/
libslibdir = $(libdir)slib/
windistdir = /c/Voluntocracy/dist/
rpm_prefix = $(HOME)/rpmbuild/

ffiles = format.scm printf.scm genwrite.scm pp.scm \
	ppfile.scm strcase.scm debug.scm trace.scm \
	strport.scm scanf.scm qp.scm break.scm stdio.scm \
	strsrch.scm prec.scm schmooz.scm defmacex.scm mbe.scm
lfiles = sort.scm comlist.scm logical.scm
revfiles = sc4opt.scm sc4sc3.scm sc2.scm mularg.scm mulapply.scm \
	trnscrpt.scm withfile.scm dynwind.scm promise.scm \
	values.scm eval.scm null.scm
afiles = charplot.scm root.scm cring.scm selfset.scm limit.scm \
	 timecore.scm psxtime.scm cltime.scm timezone.scm tzfile.scm \
	 math-real.scm
bfiles = fluidlet.scm fluid-let.scm object.scm recobj.scm yasyn.scm	\
	collect.scm collectx.scm
scfiles = r4rsyn.scm scmacro.scm synclo.scm synrul.scm synchk.scm \
	repl.scm macwork.scm mwexpand.scm mwdenote.scm mwsynrul.scm
scafiles = scainit.scm scaglob.scm scamacr.scm scaoutp.scm scaexpp.scm \
	structure.scm
srfiles = srfi-2.scm srfi-8.scm srfi-9.scm srfi-11.scm	\
	srfi-23.scm srfi-39.scm srfi-61.scm
efiles = record.scm dynamic.scm process.scm hash.scm wttree.scm	\
	wttree-test.scm sierpinski.scm soundex.scm simetrix.scm
rfiles = rdms.scm alistab.scm paramlst.scm \
	batch.scm crc.scm dbrowse.scm getopt.scm dbinterp.scm \
	dbcom.scm dbsyn.scm
ciefiles = cie1931.xyz cie1964.xyz resenecolours.txt saturate.txt \
	nbs-iscc.txt ciesid65.dat ciesia.dat

txiscms =grapheps.scm glob.scm getparam.scm \
	vet.scm top-refs.scm hashtab.scm chap.scm comparse.scm\
	alist.scm ratize.scm modular.scm dirs.scm priorque.scm queue.scm\
	srfi.scm srfi-1.scm xml-parse.scm\
	pnm.scm http-cgi.scm htmlform.scm html4each.scm db2html.scm uri.scm\
	dft.scm solid.scm random.scm randinex.scm obj2str.scm ncbi-dna.scm\
	minimize.scm factor.scm determ.scm daylight.scm colornam.scm\
	mkclrnam.scm color.scm subarray.scm dbutil.scm array.scm transact.scm\
	arraymap.scm phil-spc.scm lineio.scm differ.scm cvs.scm tree.scm\
	coerce.scm byte.scm bytenumb.scm matfile.scm tsort.scm manifest.scm\
	peanosfc.scm linterp.scm math-integer.scm rmdsff.scm
txifiles =grapheps.txi glob.txi getparam.txi\
	vet.txi top-refs.txi hashtab.txi chap.txi comparse.txi\
	alist.txi ratize.txi modular.txi dirs.txi priorque.txi queue.txi\
	srfi.txi srfi-1.txi xml-parse.txi\
	pnm.txi http-cgi.txi htmlform.txi html4each.txi db2html.txi uri.txi\
	dft.txi solid.txi random.txi randinex.txi obj2str.txi ncbi-dna.txi\
	minimize.txi factor.txi determ.txi daylight.txi colornam.txi\
	mkclrnam.txi color.txi subarray.txi dbutil.txi array.txi transact.txi\
	arraymap.txi phil-spc.txi lineio.txi differ.txi cvs.txi tree.txi\
	coerce.txi byte.txi bytenumb.txi matfile.txi tsort.txi manifest.txi\
	peanosfc.txi linterp.txi math-integer.txi rmdsff.txi
#txifiles = `echo $(txiscms) | sed 's%.scm%.txi%g'`

texifiles = schmooz.texi indexes.texi object.texi format.texi limit.texi \
	 fdl.texi
docfiles = ANNOUNCE README COPYING FAQ slib.1 slib.texi \
	$(texifiles) $(txifiles)
mkfiles = Makefile require.scm Template.scm mklibcat.scm mkpltcat.scm \
	syncase.sh Bev2slib.scm slib.spec slib.sh grapheps.ps slib.nsi \
	configure
ifiles = bigloo.init chez.init elk.init macscheme.init mitscheme.init \
	scheme2c.init scheme48.init gambit.init t3.init vscm.init \
	scm.init scsh.init sisc.init pscheme.init STk.init kawa.init \
	RScheme.init mzscheme.init umbscheme.init jscheme.init s7.init \
	guile.init guile.use guile-2.init
tfiles = macrotst.scm dwindtst.scm formatst.scm
sfiles = $(ffiles) $(lfiles) $(revfiles) $(afiles) $(scfiles) $(efiles) \
	$(rfiles) colorspc.scm $(scafiles) $(txiscms) $(srfiles)
allfiles = $(docfiles) $(mkfiles) $(ifiles) $(sfiles) $(tfiles)		\
	$(bfiles) slib.doc $(ciefiles) clrnamdb.scm SLIB.ico ChangeLog	\
	slib.info version.txi
libfiles = $(ifiles) $(sfiles) $(bfiles) $(mkfiles) $(ciefiles) clrnamdb.scm
tagfiles = $(docfiles) $(mkfiles) $(sfiles) $(bfiles) $(tfiles)	$(ifiles)

# $(DESTDIR)$(S48SLIB) isn't included in installdirs because
# Scheme48 may not be installed.
$(DESTDIR)$(S48SLIB):
	mkdir -p $(DESTDIR)$(S48SLIB)

installdirs:
	mkdir -p $(DESTDIR)$(mandir)man1/
	mkdir -p $(DESTDIR)$(libslibdir)
	mkdir -p $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(infodir)
	mkdir -p $(DESTDIR)$(htmldir)
	mkdir -p $(DESTDIR)$(pdfdir)
	mkdir -p $(DESTDIR)$(dvidir)

$(txifiles): slib.texi $(txiscms) schmooz.scm
	$(SCHEME) -rschmooz -e'(schmooz "$<")'

slib.dvi: slib.texi version.txi $(txifiles) $(texifiles)
	$(TEXI2DVI) -b -c $<
dvi:	slib.dvi
xdvi:	slib.dvi
	xdvi $<
install-dvi: slib.dvi installdirs
	$(INSTALL_DATA) $< $(DESTDIR)$(dvidir)

slib.pdf: slib.texi version.txi $(txifiles) $(texifiles)
	$(TEXI2PDF) -b -c $<
pdf:	slib.pdf
xpdf:	slib.pdf
	xpdf $<
install-pdf: slib.pdf installdirs
	$(INSTALL_DATA) $< $(DESTDIR)$(pdfdir)

# slib_toc.html: slib.texi version.txi $(txifiles) $(texifiles)
# 	$(TEXI2HTML) $<
# html:	slib_toc.html
# $(DESTDIR)$(htmldir)slib_toc.html: slib_toc.html Makefile installdirs
# 	-rm -f slib_stoc.html
# 	if [ -f $(prevdocsdir)slib_toc.html ]; \
# 	  then hitch $(prevdocsdir)slib_\*.html slib_\*.html \
# 		$(DESTDIR)$(htmldir); \
# 	  else $(INSTALL_DATA) slib_*.html $(DESTDIR)$(htmldir);fi
# install-html: $(DESTDIR)$(htmldir)slib_toc.html

html/slib: slib.texi version.txi $(txifiles) $(texifiles)
	mkdir -p html
	rm -rf html/slib
	makeinfo --html $< -o html/slib
	if type icoize>/dev/null; then icoize ../Logo/SCM.ico html/slib/*.html; fi
html:	html/slib
$(DESTDIR)$(htmldir)slib: html/slib
	-rm -rf $(DESTDIR)$(htmldir)slib
	mkdir -p $(DESTDIR)$(htmldir)slib
	$(INSTALL_DATA) html/slib/*.html $(DESTDIR)$(htmldir)slib
install-html: $(DESTDIR)$(htmldir)slib

# Used by w32install
slib.html: slib.texi
	$(MAKEINFO) --html --no-split --no-warn --force $<

slib-$(VERSION).info: slib.texi version.txi $(txifiles) $(texifiles)
	$(MAKEINFO) $< --no-warn --no-split -o slib-$(VERSION).info
slib.info: slib-$(VERSION).info
	if [ -f $(prevdocsdir)slib.info ];\
	  then infobar $(prevdocsdir)slib.info slib-$(VERSION).info \
		slib.info;\
	  else cp $< $@;fi
$(DESTDIR)$(infodir)slib.info:	slib.info installdirs
	$(INSTALL_DATA) $< $@
	-rm $(DESTDIR)$(infodir)slib.info.gz
	$(POST_INSTALL)    # Post-install commands follow.
	-$(INSTALL_INFO) $@ $(DESTDIR)$(infodir)dir
install-info:	$(DESTDIR)$(infodir)slib.info
info:	install-info
$(DESTDIR)$(infodir)slib.info.gz: $(DESTDIR)$(infodir)slib.info
	gzip -f $<
install-infoz:	$(DESTDIR)$(infodir)slib.info.gz
infoz:	install-infoz

slib.doc: slib.1
	nroff -man $< | ul -tunknown >$@
install-man: slib.1 installdirs
	-$(INSTALL_DATA) $< $(DESTDIR)$(mandir)man1/

docs:	$(DESTDIR)$(infodir)slib.info.gz \
	$(DESTDIR)$(htmldir)slib_toc.html slib.dvi \
	$(DESTDIR)$(pdfdir)slib.pdf \
	slib.doc

MKNMDB = (require 'color-database) (make-slib-color-name-db) (slib:exit)
# this comment fixes emacs' colorizing

clrnamdb: clrnamdb.scm
clrnamdb.scm: mkclrnam.scm color.scm resenecolours.txt saturate.txt nbs-iscc.txt
	if type scm; then scm -e"$(MKNMDB)";\
	elif type guile; then guile -l guile.init -c\
	 "(use-modules (ice-9 slib)) $(MKNMDB)";\
	elif type slib48; then echo -e "$(MKNMDB)\n,exit" | slib48 -h 3000000;\
	elif type umb-scheme; \
	then SCHEME_INIT=`pwd`/umbscheme.init;export SCHEME_INIT;\
	 echo "$(MKNMDB)" | umb-scheme;\
	elif type mzscheme; \
	then SCHEME_LIBRARY_PATH=`pwd`/;export SCHEME_LIBRARY_PATH;\
	 echo "$(MKNMDB)" | mzscheme -f mzscheme.init;\
	fi

catalogs:
	-if type scm; then scm -c "(require 'new-catalog)"; fi
	-if type guile; then guile -l guile.init -c\
	  "(use-modules (ice-9 slib)) (require 'new-catalog)"; fi
	-if type umb-scheme; then\
	  SCHEME_INIT=umbscheme.init;export SCHEME_INIT;\
	  echo "(require 'new-catalog)" | umb-scheme; fi
	-if type mzscheme; then\
	  SCHEME_LIBRARY_PATH=`pwd`/;export SCHEME_LIBRARY_PATH;\
	  cp mkpltcat.scm `mzscheme -mf mzscheme.init -e '(begin(display(implementation-vicinity))(exit))'`mkimpcat.scm;\
	  mzscheme -g -f mzscheme.init -e "(require 'new-catalog)"</dev/null; fi
	-if type scheme48; then $(MAKE) install48; fi

$(DESTDIR)$(S48SLIB)strport.scm: $(DESTDIR)$(S48SLIB)
	echo ";;; strport.scm  -*- scheme -*-">$(DESTDIR)$(S48SLIB)strport.scm
	echo ";@">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "(define (call-with-output-string proc)">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "  (let ((port (make-string-output-port)))">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "    (proc port)">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "    (string-output-port-output port)))">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "(define (call-with-input-string string proc)">>$(DESTDIR)$(S48SLIB)strport.scm
	echo "  (proc (make-string-input-port string)))">>$(DESTDIR)$(S48SLIB)strport.scm

$(DESTDIR)$(S48SLIB)record.scm: $(DESTDIR)$(S48SLIB)
	echo ";;; record.scm  -*- scheme -*-">$(DESTDIR)$(S48SLIB)record.scm
	echo ";; This code is in the public domain">>$(DESTDIR)$(S48SLIB)record.scm
	echo ";@">>$(DESTDIR)$(S48SLIB)record.scm
	echo "(define make-record-type   make-record-type)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "(define record-constructor">>$(DESTDIR)$(S48SLIB)record.scm
	echo "  (let ((constructor record-constructor))">>$(DESTDIR)$(S48SLIB)record.scm
	echo "    (lambda (rt . fields)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "      (constructor rt (if (pair? fields)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "                          (car fields)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "                          (record-type-field-names rt))))))">>$(DESTDIR)$(S48SLIB)record.scm
	echo "(define record-predicate   record-predicate)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "(define record-accessor    record-accessor)">>$(DESTDIR)$(S48SLIB)record.scm
	echo "(define record-modifier    record-modifier)">>$(DESTDIR)$(S48SLIB)record.scm

slib48:	$(IMAGE48)
$(IMAGE48):	$(S48INIT) Makefile
	S48_VERSION="`echo ,exit | $(RUNNABLE) |\
	  sed -n 's/Welcome to Scheme 48 //;s/ ([^)]*)[.]//;p;q'`";\
	  export S48_VERSION;\
	  S48_VICINITY="$(DESTDIR)$(S48LIB)";export S48_VICINITY;\
	  SCHEME_LIBRARY_PATH="`pwd`/";export SCHEME_LIBRARY_PATH;\
	  $(RUNNABLE) < $<
install48:	$(IMAGE48) $(DESTDIR)$(S48SLIB)strport.scm \
		$(DESTDIR)$(S48SLIB)record.scm
	$(INSTALL_DATA) $(IMAGE48) $(DESTDIR)$(S48LIB)
	(echo '#! /bin/sh';\
	 echo exec $(RUNNABLE) -i '$(DESTDIR)$(S48LIB)$(IMAGE48)' \"\$$\@\") \
	  > $(DESTDIR)$(bindir)slib48
	chmod +x $(DESTDIR)$(bindir)slib48
uninstall48:
	-rm $(DESTDIR)$(S48LIB)$(IMAGE48)

install-lib: $(libfiles) installdirs
	-$(INSTALL_DATA) $(libfiles) $(DESTDIR)$(libslibdir)

install-script: slib.sh installdirs
	echo '#! /bin/sh'			     > slib-script
	echo SCHEME_LIBRARY_PATH=$(libslibdir)      >> slib-script
	echo S48_VICINITY=$(S48LIB)		    >> slib-script
	echo VERSION=$(VERSION)			    >> slib-script
	echo export SCHEME_LIBRARY_PATH S48_VICINITY>> slib-script
	cat $<					    >> slib-script
	$(INSTALL_PROGRAM) slib-script $(DESTDIR)$(bindir)slib
	rm slib-script

install: install-script install-lib install-infoz install-man

uninstall: uninstall48
	$(PRE_UNINSTALL)     # Pre-uninstall commands follow.
	-$(INSTALL_INFO) --delete $(DESTDIR)$(infodir)slib.info \
	  $(DESTDIR)$(infodir)dir
	$(NORMAL_UNINSTALL)  # Normal commands follow.
	-rm $(DESTDIR)$(infodir)slib.info*
	-rm $(DESTDIR)$(mandir)man1/slib.1
	-rm $(DESTDIR)$(bindir)slib
	cd $(DESTDIR)$(libslibdir); rm $(libfiles)
	$(POST_UNINSTALL)     # Post-uninstall commands follow.
	-rmdir $(DESTDIR)$(libslibdir)

## to build a windows installer
## make sure makeinfo and NSIS are available on the commandline
w32install: slib.nsi slib.html
	makensis $<

#### Stuff for maintaining SLIB below ####

ver = $(VERSION)

collectx.scm: collect.scm macwork.scm
	echo "(require 'macros-that-work)" > collect.sc
	echo "(require 'pprint-file)" >> collect.sc
	echo "(require 'yasos)" >> collect.sc
	echo "(pprint-filter-file \"collect.scm\" macwork:expand \"collectx.scm\")" >> collect.sc
	echo "(slib:exit #t)" >> collect.sc
	$(SCHEME) < collect.sc

temp/slib/: $(allfiles)
	-rm -rf temp
	mkdir -p temp/slib/
	ln  $(allfiles) temp/slib/

#For change-barred HTML.
prevdocs: $(prevdocsdir)slib_toc.html $(prevdocsdir)slib.info
$(prevdocsdir)slib_toc.html:
$(prevdocsdir)slib.info: Makefile
	cd $(prevdocsdir); unzip -ao $(distdir)slib*.zip
	rm $(prevdocsdir)slib/slib.info
	cd $(prevdocsdir)slib; $(MAKE) slib.info; $(MAKE) slib_toc.html
	cd $(prevdocsdir); mv -f slib/slib.info slib/*.html ./
	rm -rf $(prevdocsdir)slib
	-rm -f slib-$(VERSION).info

release:	dist pdf tar.gz	# rpm
	cvs tag -F slib-$(VERSION)
	cp ANNOUNCE $(htmldir)SLIB_ANNOUNCE.txt
	cp COPYING $(htmldir)SLIB_COPYING.txt
	cp FAQ $(htmldir)SLIB.FAQ
	$(RSYNC) $(htmldir)SLIB.html $(htmldir)SLIB_ANNOUNCE.txt \
	 $(htmldir)SLIB_COPYING.txt $(Uploadee):public_html/
	$(RSYNC) $(distdir)README $(distdir)slib-$(VERSION).zip \
	 $(distdir)slib-$(VERSION).tar.gz \
	 $(distdir)slib-$(VERSION)-$(RELEASE).noarch.rpm \
	 $(distdir)slib-$(VERSION)-$(RELEASE).src.rpm $(Uploadee):dist/
#	upload $(distdir)README $(distdir)slib-$(VERSION).zip ftp.gnu.org:gnu/jacal/

upzip:	$(snapdir)slib.zip
	$(RSYNC) $(snapdir)slib.zip $(Uploadee):pub/

dist:	$(distdir)slib-$(VERSION).zip
$(distdir)slib-$(VERSION).zip:	temp/slib/
	$(MAKEDEV) DEST=$(distdir) PROD=slib ver=-$(VERSION) zip

upgnu:	$(distdir)slib-$(VERSION).tar.gz
	cd $(distdir); gnupload --to ftp.gnu.org:slib slib-$(VERSION).tar.gz
tar.gz:	$(distdir)slib-$(VERSION).tar.gz
$(distdir)slib-$(VERSION).tar.gz:	temp/slib/
	$(MAKEDEV) DEST=$(distdir) PROD=slib ver=-$(VERSION) tar.gz

rpm:	pubzip
#$(distdir)slib-$(VERSION)-$(RELEASE).noarch.rpm: $(distdir)slib-$(VERSION).zip
	cp $(snapdir)slib.zip $(rpm_prefix)SOURCES/slib-$(VERSION).zip
	rpmbuild -ba slib.spec	# --clean
	rm $(rpm_prefix)SOURCES/slib-$(VERSION).zip
	mv $(rpm_prefix)RPMS/noarch/slib-$(VERSION)-$(RELEASE).noarch.rpm \
	   $(rpm_prefix)SRPMS/slib-$(VERSION)-$(RELEASE).src.rpm $(distdir)

shar:	slib.shar
slib.shar:	temp/slib/
	$(MAKEDEV) PROD=slib shar
dclshar:	slib.com
com:	slib.com
slib.com:	temp/slib/
	$(MAKEDEV) PROD=slib com
zip:	slib.zip
slib.zip:	temp/slib/
	$(MAKEDEV) DEST=../ PROD=slib zip
doszip:	$(windistdir)slib-$(VERSION).zip
$(windistdir)slib-$(VERSION).zip:	temp/slib/ slib.html
	$(MAKEDEV) DEST=$(windistdir) PROD=slib ver=-$(VERSION) zip
	-cd ..; zip -9ur $(windistdir)slib-$(VERSION).zip slib/slib.html
	zip -d $(windistdir)slib-$(VERSION).zip slib/slib.info
pubzip:	temp/slib/
	$(MAKEDEV) DEST=$(snapdir) PROD=slib zip

diffs:	pubdiffs
pubdiffs:	temp/slib/
	$(MAKEDEV) DEST=$(snapdir) PROD=slib pubdiffs
distdiffs:	temp/slib/
	$(MAKEDEV) DEST=$(distdir) PROD=slib ver=$(ver) distdiffs
announcediffs:	temp/slib/
	$(MAKEDEV) DEST=$(distdir) PROD=slib ver=-$(VERSION) announcediffs

psdfiles=COPYING.psd README.psd cmuscheme.el comint.el instrum.scm pexpr.scm \
	primitives.scm psd-slib.scm psd.el read.scm runtime.scm version.scm
psdocfiles=article.bbl article.tex manual.bbl manual.tex quick-intro.tex

psdtemp/slib/:
	-rm -rf psdtemp
	mkdir -p psdtemp/slib/psd
	cd psd; ln $(psdfiles) ../psdtemp/slib/psd
	mkdir -p psdtemp/slib/psd/doc
	cd psd/doc; ln $(psdocfiles) ../../psdtemp/slib/psd/doc

psdist:	$(distdir)slib-psd.tar.gz
$(distdir)slib-psd.tar.gz:	psdtemp/slib/
	$(MAKEDEV) DEST=$(distdir) PROD=slib ver=-psd tar.gz TEMP=psdtemp/

CITERS = FAQ README ANNOUNCE $(distdir)README ../jacal/ANNOUNCE		\
	../jacal/jacal.texi ../scm/ANNOUNCE ../scm/scm.texi		\
	../wb/ANNOUNCE ../wb/README ../synch/ANNOUNCE			\
	$(windistdir)unzipall.bat $(windistdir)buildall			\
	$(htmldir)JACAL.html $(htmldir)README.html $(htmldir)SCM.html	\
	$(htmldir)SIMSYNCH.html $(htmldir)FreeSnell/FreeSnell.texi	\
	$(htmldir)FreeSnell/ANNOUNCE $(htmldir)FreeSnell/index.html
CITES =  require.scm Makefile slib.spec scheme48.init \
	$(htmldir)SLIB.html slib.nsi ../scm/scm.nsi

new:
	$(CHPAT) slib-$(VERSION) slib-$(ver) $(CITERS)
	$(CHPAT) $(VERSION) $(ver) $(CITES)
	echo @set SLIBVERSION $(ver) > version.txi
	echo @set SLIBDATE `date +"%B %Y"` >> version.txi
	echo `date -I` \ Aubrey Jaffer \ \<`whoami`@`hostname`\>> change
	echo>> change
	echo \	\* require.scm \(*slib-version*\): Bumped from $(VERSION) to $(ver).>>change
	echo>> change
	cat ChangeLog >> change
	mv -f change ChangeLog
	cvs commit -lm '(*slib-version*): Bumped from $(VERSION) to $(ver).'
	cvs tag -F slib-$(ver)

tags:	$(tagfiles)
	etags $(tagfiles)
rights:
	$(SCHEME) -ladmin -e"(admin:check-all)" $(sfiles) $(tfiles) \
		$(bfiles) $(ifiles)
report:
	$(SCHEME) -e"(slib:report #t)"
clean:
	-rm -f *~ *.bak *.orig *.rej core a.out *.o \#*
	-rm -rf *temp
distclean:	realclean
realclean:
	-rm -f *~ *.bak *.orig *.rej TAGS core a.out *.o \#*
	-rm -f slib.info* slib.?? slib.html
	-rm -rf *temp SLIB-*.exe
realempty:	temp/slib/
	-rm -f $(allfiles)
