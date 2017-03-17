# Quick start

## Setup

    $ cd ~/scheme # Where '~/scheme' is the path to your Scheme libraries
    $ git clone git://github.com/dharmatech/surfage.git
    $ bzr branch lp:~derick-eddington/scheme-libraries/xitomatl
    $ git clone git://github.com/dharmatech/dharmalab.git
    $ git clone git://github.com/dharmatech/agave.git

## Run a demo in Ypsilon

    $ ypsilon ~/scheme/agave/demos/flexi-line.scm

## Run a demo in Ikarus

    $ ikarus --r6rs-script ~/scheme/agave/demos/flexi-line.scm

## Make a demo load faster in Ikarus

    $ ikarus --compile-dependencies ~/scheme/agave/demos/flexi-line.scm

# Introduction

Agave started out as a collection of OpenGL demos written for R6RS
Scheme. Eventually it grew to include libraries which support basic
OpenGL programming idioms.

All of the demos run in Ikarus and Ypsilon.

# Libraries

Some of the libraries are:

```
| library                           | notes |
|-----------------------------------+-------|
| (agave glamour window)            |       |
| (agave glamour mouse)             |       |
| (agave glamour misc)              |       |
| (agave glamour frames-per-second) |       |
| (agave color rgba)                |       |
| (agave color hsva)                |       |
| (agave color conversion)          |       |
| (agave geometry pt)               |       |
| (agave geometry pt-3d)            |       |
```

The rest of the libraries are mostly support for the demos.

# Demos

A few demo highlights.

## springies

Long before [Sodaplay](http://sodaplay.com) existed, [Doug DeCarlo](http://www.cs.rutgers.edu/~decarlo/) wrote [xspringies](http://www.cs.rutgers.edu/~decarlo/software.html). Springies
is an implementation of the engine in xspringies. Note that this is
not a binding to any C library; this is an honest to goodness mass and
spring simulation written in pure Scheme. To me, this is a
demonstration that Scheme can be a high-performance language.

![](https://raw.githubusercontent.com/dharmatech/dharmatech.github.com/master/images/springies-belt-tire.png)

## cfdg

An implementation of the [Context Free Art](http://www.contextfreeart.org) semantics. It also renders
the models. :-) Only a subset of the full ContextFree language is
supported, but I picked a subset which allows for some nice pieces to
be rendered.

Screenshot:

![](https://raw.githubusercontent.com/dharmatech/dharmatech.github.com/master/images/cfdg-game1-turn6.png)

## flexi-line

A port of a [demo](http://www.openprocessing.org/visuals/?visualID=323) I found on [Open Processing](http://www.openprocessing.org).

## empathy

A port of a [demo](http://www.openprocessing.org/visuals/?visualID=1182) by [Kyle McDonald](http://www.openprocessing.org/portal/?userID=838) I found on [Open Processing](http://www.openprocessing.org).

## ca

Simulator for the [generations](http://www.mirekw.com/ca/rullex_gene.html) family of cellular automata.
