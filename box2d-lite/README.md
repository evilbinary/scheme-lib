
# Introduction

[Box2D](http://www.box2d.org) is a physics engine written in C++ by
Erin Catto. [Box2D Lite](http://box2d.googlecode.com/files/Box2D_Lite.zip)
is a simpler version which Erin posted to his blog once upon a
time. This is a port of Box2D Lite to R6RS Scheme.

# Setup

    $ cd ~/scheme # Where '~/scheme' is the path to your Scheme libraries
    $ git clone git://github.com/dharmatech/surfage.git
    $ git clone git://github.com/dharmatech/dharmalab.git
    $ git clone git://github.com/dharmatech/agave.git

# Running the demos

## Run a demo in Ikarus

    $ ikarus --r6rs-script ~/scheme/box2d-lite/demos/small-pyramid.sps

## Run a demo in Chez

    $ scheme --program ~/scheme/box2d-lite/demos/small-pyramid.sps

## Run a demo in Larceny

    $ larceny --r6rs --program ~/scheme/box2d-lite/demos/small-pyramid.sps

# Notes

## Chez Scheme

OpenGL library for Chez Scheme: [chez-gl](https://github.com/dharmatech/chez-gl).

On my system, I keep R6RS libraries in `~/scheme`. I keep chez-gl in `~/src`.
So my `CHEZSCHEMELIBDIRS` is set like this in my `~/.bashrc`:

    export CHEZSCHEMELIBDIRS=~/scheme:~/src/chez-gl

## Make a demo load faster in Ikarus

    $ ikarus --compile-dependencies ~/scheme/box2d-lite/demos/small-pyramid.sps

## Screenshot

![dominos screenshot](https://raw.githubusercontent.com/dharmatech/dharmatech.github.com/master/images/box2d-lite-dominos-chez.png)
