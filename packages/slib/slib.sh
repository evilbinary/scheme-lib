
##"slib" script; Find a Scheme implementation and initialize SLIB in it.
#Copyright (C) 2003, 2004 Aubrey Jaffer
#
#Permission to copy this software, to modify it, to redistribute it,
#to distribute modified versions, and to use it for any purpose is
#granted, subject to the following restrictions and understandings.
#
#1.  Any copy made of this software must include this copyright notice
#in full.
#
#2.  I have made no warranty or representation that the operation of
#this software will be error-free, and I am under no obligation to
#provide any services, by way of maintenance, update, or otherwise.
#
#3.  In conjunction with products arising from the use of this
#material, there shall be no use of my name in any advertising,
#promotional, or sales literature without prior written consent in
#each case.

usage="Usage: slib [--version | -v]

  Display version information and exit successfully.

Usage: slib SCHEME

  Initialize SLIB in Scheme implementation SCHEME.

Usage: slib

  Initialize SLIB session using executable (MIT)'scheme', 'scm',
  'gsi', 'gosh', 'guile', 'slib48', 'larceny', 'scmlit', 'elk',
  'sisc', 'kawa', or 'mzscheme'."

case "$1" in
    -v | --ver*) echo slib "$VERSION"; exit 0;;
    "") if type scheme>/dev/null 2>&1; then
	  command=scheme
	fi;;
    -*) echo "$usage"; exit 1;;
    *) command="$1"
	shift
esac
## If more arguments are supplied, then err out.
# if [ ! -z "$1" ]; then
#     echo "$usage"; exit 1
# fi

if [ -z "$command" ]; then
    if type scm>/dev/null 2>&1; then
	command=scm; implementation=scm
    elif type gsi>/dev/null 2>&1; then
	command=gsi; implementation=gam
    elif type gosh>/dev/null 2>&1; then
	command=gosh; implementation=gch
    elif type guile>/dev/null 2>&1; then
	command=guile; implementation=gui
    elif type slib48>/dev/null 2>&1; then
	command=slib48; implementation=s48
    elif type larceny>/dev/null 2>&1; then
	command=larceny; implementation=lar
    elif type scmlit>/dev/null 2>&1; then
	command=scmlit; implementation=scm
    elif type elk>/dev/null 2>&1; then
	command=elk; implementation=elk
    elif type sisc>/dev/null 2>&1; then
	command=sisc; implementation=ssc
    elif type kawa>/dev/null 2>&1; then
	command=kawa; implementation=kwa
    elif type mzscheme>/dev/null 2>&1; then
	command=mzscheme; implementation=plt
    else
	echo No Scheme implementation found.
	exit 1
    fi
# Gambit 4.0 doesn't allow input redirection; foils --version test.
elif [ "$command" = "gsi" ]; then implementation=gam
elif type $command>/dev/null 2>&1; then
  SPEW="`$command --version < /dev/null 2>&1`"
  if   echo ${SPEW} | grep 'Initialize load-path (colon-list of directories)'\
				       >/dev/null 2>&1; then implementation=elk
  elif echo ${SPEW} | grep 'MIT'       >/dev/null 2>&1; then implementation=mit
  elif echo ${SPEW} | grep 'UMB Scheme'>/dev/null 2>&1; then implementation=umb
  elif echo ${SPEW} | grep 'scheme48'  >/dev/null 2>&1; then implementation=s48
  elif echo ${SPEW} | grep 'larceny'   >/dev/null 2>&1; then implementation=lar
  elif echo ${SPEW} | grep 'Guile'     >/dev/null 2>&1; then implementation=gui
  elif echo ${SPEW} | grep 'gosh'      >/dev/null 2>&1; then implementation=gch
  elif echo ${SPEW} | grep 'SCM'       >/dev/null 2>&1; then implementation=scm
  elif echo ${SPEW} | grep 'SISC'      >/dev/null 2>&1; then implementation=ssc
  elif echo ${SPEW} | grep 'Kawa'      >/dev/null 2>&1; then implementation=kwa
  elif echo ${SPEW} | grep 'MzScheme'  >/dev/null 2>&1; then implementation=plt
  else implementation=
  fi
else
  echo "Program '$command' not found."
  exit 1
fi

case $implementation in
  scm);;
  s48);;
  *) if [ -z "${SCHEME_LIBRARY_PATH}" ]; then
	if type rpm>/dev/null 2>&1; then
	  SCHEME_LIBRARY_PATH=`rpm -ql slib 2>/dev/null \
	     | grep require.scm | sed 's%require.scm%%'`
	fi
     fi
     if [ -z "${SCHEME_LIBRARY_PATH}" ]; then
       if [ -d /usr/local/lib/slib/ ]; then
	  SCHEME_LIBRARY_PATH=/usr/local/lib/slib/
       elif [ -d /usr/share/slib/ ]; then
	  SCHEME_LIBRARY_PATH=/usr/share/slib/
       fi
     export SCHEME_LIBRARY_PATH
     fi;;
esac

# for gambit
case $implementation in
  gam) if [ -z "${LD_LIBRARY_PATH}" ]; then
	LD_LIBRARY_PATH=/usr/local/lib
	export LD_LIBRARY_PATH
	fi;;
esac

case $implementation in
    scm) exec $command -ip1 -l ${SCHEME_LIBRARY_PATH}scm.init "$@";;
    elk) exec $command -i -l ${SCHEME_LIBRARY_PATH}elk.init "$@";;
    gam) exec $command -:s ${SCHEME_LIBRARY_PATH}gambit.init - "$@";;
    gch) exec $command -l ${SCHEME_LIBRARY_PATH}gosh.init "$@";;
    ssc) exec $command -e "(load \"${SCHEME_LIBRARY_PATH}sisc.init\")" -- "$@";;
    kwa) exec $command -f ${SCHEME_LIBRARY_PATH}kawa.init -- "$@";;
    gui) if [ -f ${SCHEME_LIBRARY_PATH}guile.use ]; then
	exec $command -l ${SCHEME_LIBRARY_PATH}guile.init -l ${SCHEME_LIBRARY_PATH}guile.use "$@"
	else
	exec $command -l ${SCHEME_LIBRARY_PATH}guile.init "$@"
	fi;;
    lar) exec $command -- -e "(require 'srfi-96)" "$@";;
    mit) exec $command -load ${SCHEME_LIBRARY_PATH}mitscheme.init "$@";;
    s48) if [ -f "${S48_VICINITY}slib.image" ]; then
	exec scheme48 -h 4000000 -i ${S48_VICINITY}slib.image
	else
	echo "scheme48 found; in slib directory do: 'make slib48 && make install48'";
	fi
	exit 1;;
    plt) exec $command -f ${SCHEME_LIBRARY_PATH}mzscheme.init "$@";;
    umb) echo "umb-scheme vicinities are too wedged to run slib"; exit 1;;
    *)   exit 1;;
esac
