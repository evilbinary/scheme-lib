;;;; "grapheps.scm", Create PostScript Graphs
;;; Copyright (C) 2003, 2004, 2005, 2006, 2008, 2010, 2011 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require 'array)
(require 'array-for-each)
(require 'line-i/o)
(require 'color)
(require 'resene)
(require 'saturate)
(require 'filename)

;;@code{(require 'eps-graph)}
;;
;;@noindent
;;This is a graphing package creating encapsulated-PostScript files.
;;Its motivations and design choice are described in
;;@url{http://people.csail.mit.edu/jaffer/Docupage/grapheps}
;;
;;@noindent
;;A dataset to be plotted is taken from a 2-dimensional array.
;;Corresponding coordinates are in rows.  Coordinates from any
;;pair of columns can be plotted.

;;; String append which accepts numbers, symbols, vectors, and lists.
(define (scheme->ps . args)
  (apply string-append
	 (map (lambda (arg)
		(cond ((number? arg) (number->string arg))
		      ((symbol? arg) (symbol->string arg))
		      ((or (vector? arg) (list? arg))
		       (string-append
			"[ "
			(apply string-append
			       (map (lambda (x) (scheme->ps x " "))
				    (if (vector? arg) (vector->list arg) arg)))
			"]"))
		      (else arg)))
	      args)))

(define (data->ps . args)
  (apply string-append
	 (map (lambda (arg)
		(cond ((number? arg) (number->string arg))
		      ((symbol? arg) (string-append "/" (symbol->string arg)))
		      ((string? arg) (string-append "(" arg ")"))
		      ((or (vector? arg) (list? arg))
		       (string-append
			"[ "
			(apply string-append
			       (map (lambda (x) (data->ps x " "))
				    (if (vector? arg) (vector->list arg) arg)))
			"]"))
		      (else arg)))
	      args)))

;;; Capture for %%Title
(define *plot-title* #f)

;; Remember arrays so each is output only once.
(define *plot-arrays* '())

;;@args filename.eps size elt1 ...
;;@1 should be a string naming an output file to be created.  @2
;;should be an exact integer, a list of two exact integers, or #f.
;;@3, ... are values returned by graphing primitives described here.
;;
;;@0 creates an @dfn{Encapsulated-PostScript} file named @1 containing
;;graphs as directed by the @3, ... arguments.
;;
;;The size of the graph is determined by the @2 argument.  If a list
;;of two integers, they specify the width and height.  If one integer,
;;then that integer is the width and the height is 3/4 of the width.
;;If #f, the graph will be 800 by 600.
(define (create-postscript-graph filename size . args)
  (define xsize (cond ((pair? size) (car size))
		      ((number? size) size)
		      (else 800)))
  (let ((ysize (if (and (pair? size) (pair? (cdr size)))
		   (cadr size)
		   (quotient (* 3 xsize) 4))))
    (cond ((provided? 'inexact)
	   (set! xsize (inexact->exact (round xsize)))
	   (set! ysize (inexact->exact (round ysize)))))
    (call-with-output-file filename
      (lambda (oprt)
	(define (write-lines lines)
	  (for-each (lambda (line) (if (list? line)
				       (write-lines line)
				       (write-line line oprt)))
		    lines))
	(write-line "%!PS-Adobe-3.0 EPSF-3.0" oprt)
	(write-line (scheme->ps "%%BoundingBox: 0 0 " xsize " " ysize) oprt)
	(write-line (scheme->ps "%%Title: " (or *plot-title* filename)) oprt)
	(write-line (scheme->ps "%%EndComments: ") oprt)
	(write-line (scheme->ps "0 0 " xsize " " ysize) oprt)
	(call-with-input-file (in-vicinity (library-vicinity) "grapheps.ps")
	  (lambda (iprt)
	    (do ((line (read-line iprt) (read-line iprt)))
		((eof-object? line))
	      (write-line line oprt))))
	(for-each (lambda (pair) (write-array-def (cdr pair) (car pair) oprt))
		  *plot-arrays*)
	(write-lines args)
	(newline oprt)
	(write-line "grestore" oprt)
	(write-line "end" oprt)
	(write-line "showpage" oprt)))
    (set! *plot-title* #f)
    (set! *plot-arrays* '())))

(define (write-array-def name array oprt)
  (define row-length (cadr (array-dimensions array)))
  (define idx 0)
  (set! idx row-length)
  (write-line (scheme->ps "/" name) oprt)
  (write-line "[" oprt)
  (display " [" oprt)
  (array-for-each
   (lambda (elt)
     (cond ((zero? idx)
	    (write-line "]" oprt)
	    (display " [" oprt)))
     (display  "	" oprt)
     (display (data->ps elt) oprt)
     (set! idx (modulo (+ 1 idx) row-length)))
   array)
  (write-line "]" oprt)
  (write-line "] def" oprt))

;;; Arrays are named and cached in *plot-arrays*.
(define (import-array array)
  (cond ((assq array *plot-arrays*) => cdr)
	(else
	 (let ((name (gentemp)))
	   (set! *plot-arrays* (cons (cons array name) *plot-arrays*))
	   name))))

;;@noindent
;;These graphing procedures should be called as arguments to
;;@code{create-postscript-graph}.  The order of these arguments is
;;significant; PostScript graphics state is affected serially from the
;;first @var{elt} argument to the last.

;;@body
;;Pushes a rectangle for the whole encapsulated page onto the
;;PostScript stack.  This pushed rectangle is an implicit argument to
;;@code{partition-page} or @code{setup-plot}.
(define (whole-page) 'whole-page)

;;@menu
;;* Column Ranges::
;;* Drawing the Graph::
;;* Graphics Context::
;;* Rectangles::
;;* Legending::
;;* Legacy Plotting::
;;* Example Graph::
;;@end menu
;;
;;@node Column Ranges, Drawing the Graph, PostScript Graphing, PostScript Graphing
;;@subsubsection Column Ranges

;;@noindent
;;A @dfn{range} is a list of two numbers, the minimum and the maximum.
;;@cindex range
;;Ranges can be given explicity or computed in PostScript by
;;@code{column-range}.

;;@body
;;Returns the range of values in 2-dimensional @1 column @2.
(define (column-range array k)
  (set! array (import-array array))
  (scheme->ps array " " k " column-range"))

;;@body
;;Expands @1 by @2/100 on each end.
(define (pad-range range p) (scheme->ps range " " p " pad-range"))

;;@body
;;Expands @1 to round number of ticks.
(define (snap-range range) (scheme->ps range " snap-range"))

;;@args range1 range2 ...
;;Returns the minimal range covering all @1, @2, ...
(define (combine-ranges rng1 . rngs)
  (define (loop rngs)
    (cond ((null? rngs) "")
	  (else (scheme->ps " " (car rngs) (loop (cdr rngs))
			    " combine-ranges"))))
  (scheme->ps rng1 (loop rngs)))

;;@args x-range y-range pagerect
;;@args x-range y-range
;;@1 and @2 should each be a list of two numbers or the value returned
;;by @code{pad-range}, @code{snap-range}, or @code{combine-range}.
;;@3 is the rectangle bounding the graph to be drawn; if missing, the
;;rectangle from the top of the PostScript stack is popped and used.
;;
;;Based on the given ranges, @0 sets up scaling and margins for making
;;a graph.  The margins are sized proportional to the @var{fontheight}
;;value at the time of the call to setup-plot.  @0 sets two variables:
;;
;;@table @var
;;@item plotrect
;;The region where data points will be plotted.
;;@item graphrect
;;The @3 argument to @0.  Includes plotrect, legends, etc.
;;@end table
(define (setup-plot xrange yrange . pagerect)
  (if (null? pagerect)
      (scheme->ps xrange " " yrange " setup-plot")
      (scheme->ps (car pagerect) " " xrange " " yrange " setup-plot")))

;;@node Drawing the Graph, Graphics Context, Column Ranges, PostScript Graphing
;;@subsubsection Drawing the Graph

;;@body
;;Plots points with x coordinate in @2 of @1 and y coordinate @3 of
;;@1.  The symbol @4 specifies the type of glyph or drawing style for
;;presenting these coordinates.
(define (plot-column array x-column y-column proc3s)
  (set! array (import-array array))
  (scheme->ps "[ " array " " x-column " " y-column " ] "  proc3s
		  " plot-column"))

;;@noindent
;;The glyphs and drawing styles available are:
;;
;;@table @code
;;@item line
;;Draws line connecting points in order.
;;@item mountain
;;Fill area below line connecting points.
;;@item cloud
;;Fill area above line connecting points.
;;@item impulse
;;Draw line from x-axis to each point.
;;@item bargraph
;;Draw rectangle from x-axis to each point.
;;@item disc
;;Solid round dot.
;;@item point
;;Minimal point -- invisible if linewidth is 0.
;;@item square
;;Square box.
;;@item diamond
;;Square box at 45.o
;;@item plus
;;Plus sign.
;;@item cross
;;X sign.
;;@item triup
;;Triangle pointing upward
;;@item tridown
;;Triangle pointing downward
;;@item pentagon
;;Five sided polygon
;;@item circle
;;Hollow circle
;;@end table

;;@body
;;Plots text in @4 of @1 at x coordinate in @2 of @1 and y coordinate
;;@3 of @1.  The symbol @5 specifies the offset of the text from the
;;specified coordinates.
(define (plot-text-column array x-column y-column t-column proc3s)
  (set! array (import-array array))
  (scheme->ps "[ " array " " x-column " " y-column " " t-column " ] "  proc3s
		  " plot-text-column"))

;;@noindent
;;The offsets available are:
;;
;;@table @code
;;@item above
;;Draws the text centered above at the point.
;;@item center
;;Draws the text centered at the point.
;;@item below
;;Draws the text centered below the point.
;;@item left
;;Draws the text to the left of the point.
;;@item right
;;Draws the text to the right of the point.
;;@end table
;;
;;All the offsets other than @code{center} are calculated to keep the
;;text clear of a glyph drawn at the same coordinates.  If you need
;;more or less clearance, use @code{set-glyphsize}.


;;@node Graphics Context, Rectangles, Drawing the Graph, PostScript Graphing
;;@subsubsection Graphics Context

;;@body
;;Saves the current graphics state, executes @1, then restores
;;to saved graphics state.
(define (in-graphic-context . args)
  (append '("gpush") args '("gpop")))

;;@args color
;;@1 should be a string naming a Resene color, a saturate color, or a
;;number between 0 and 100.
;;
;;@0 sets the PostScript color to the color of the given string, or a
;;grey value between black (0) and white (100).
(define (set-color clrn)
  (define clr
    (cond ((color? clrn) clrn)
	  ((number? clrn) (* 255/100 clrn))
	  ((or (eq? 'black clrn)
	       (and (string? clrn) (string-ci=? "black" clrn))) 0)
	  ((or (eq? 'white clrn)
	       (and (string? clrn) (string-ci=? "white" clrn))) 255)
	  (else (or (saturate clrn) (resene clrn)
		    (string->color (if (symbol? clrn)
				       (symbol->string clrn)
				       clrn))))))
  (define (num->str x)
    (define num (inexact->exact (round (+ 1000 (* x 999/255)))))
    (scheme->ps "." (substring (number->string num) 1 4) " "))
  (cond ((number? clr) (string-append (num->str clr) " setgray"))
	(clr (apply scheme->ps
		    (append (map num->str (color->sRGB clr)) '(setrgbcolor))))
	(else "")))

;;@args font height
;;@args font encoding height
;;@1 should be a (case-sensitive) string naming a PostScript font.
;;@var{height} should be a positive real number.
;;@var{encoding} should name a PostScript encoding such as
;;@samp{ISOLatin1Encoding}.
;;
;;@0 Changes the current PostScript font to @1 with the @var{encoding}
;;encoding, and height equal to @var{height}.  The default font is
;;@samp{Helvetica} (12pt).  The default encoding is
;;@samp{StandardEncoding}.
(define (set-font name arg2 . args)
  (define fontheight (if (null? args) arg2 (car args)))
  (define encoding (and (not (null? args)) arg2))
  (scheme->ps
   (if (null? args)
       ""
       (string-append " /" name " " encoding " /" name "-" encoding
		      " combine-font-encoding"))
   " /fontsize " fontheight " def /"
   (if encoding (string-append name "-" encoding) name)
   " fontsize selectfont"))

;;@noindent
;;The base set of PostScript fonts is:
;;
;;@multitable @columnfractions .20 .25 .25 .30
;;@item Times @tab Times-Italic @tab Times-Bold @tab Times-BoldItalic
;;@item Helvetica @tab Helvetica-Oblique @tab Helvetica-Bold @tab Helvetica-BoldOblique
;;@item Courier @tab Courier-Oblique @tab Courier-Bold @tab Courier-BoldOblique
;;@item Symbol
;;@end multitable

;;@noindent
;;The base set of PostScript encodings is:
;;
;;@multitable @columnfractions .33 .33 .33
;;@item StandardEncoding @tab ISOLatin1Encoding @tab ExpertEncoding
;;@item ExpertSubsetEncoding @tab SymbolEncoding
;;@end multitable

;;@noindent
;;Line parameters do no affect fonts; they do effect glyphs.

;;@body
;;The default linewidth is 1.  Setting it to 0 makes the lines drawn
;;as skinny as possible.  Linewidth must be much smaller than
;;glyphsize for readable glyphs.
(define (set-linewidth w) (scheme->ps w " setlinewidth"))

;;@args j k
;;Lines are drawn @1-on @2-off.
;;@args j
;;Lines are drawn @1-on @1-off.
;;@args
;;Turns off dashing.
(define (set-linedash . args) (scheme->ps args " 0 setdash"))

;;@body
;;Sets the (PostScript) variable glyphsize to @1.  The default
;;glyphsize is 6.
(define (set-glyphsize w) (scheme->ps "/glyphsize " w " def"))

;;@noindent
;;The effects of @code{clip-to-rect} are also part of the graphic
;;context.


;;@node Rectangles, Legending, Graphics Context, PostScript Graphing
;;@subsubsection Rectangles

;;@noindent
;;A @dfn{rectangle} is a list of 4 numbers; the first two elements are
;;the x and y coordinates of lower left corner of the rectangle.  The
;;other two elements are the width and height of the rectangle.

;;@body
;;Pushes a rectangle for the whole encapsulated page onto the
;;PostScript stack.  This pushed rectangle is an implicit argument to
;;@code{partition-page} or @code{setup-plot}.
(define (whole-page) 'whole-page)

;;@body
;;Pops the rectangle currently on top of the stack and pushes @1 * @2
;;sub-rectangles onto the stack in decreasing y and increasing x order.
;;If you are drawing just one graph, then you don't need @0.
(define (partition-page xparts yparts)
  (scheme->ps xparts " " yparts " partition-page"))

;;@body
;;The rectangle where data points should be plotted.  @0 is set by
;;@code{setup-plot}.
(define plotrect 'plotrect)

;;@body
;;The @var{pagerect} argument of the most recent call to
;;@code{setup-plot}.  Includes plotrect, legends, etc.
(define graphrect 'graphrect)

;;@body
;;fills @1 with the current color.
(define (fill-rect rect) (scheme->ps rect " fill-rect"))

;;@body
;;Draws the perimiter of @1 in the current color.
(define (outline-rect rect) (scheme->ps rect " outline-rect"))

;;@body
;;Modifies the current graphics-state so that nothing will be drawn
;;outside of the rectangle @1.  Use @code{in-graphic-context} to limit
;;the extent of @0.
(define (clip-to-rect rect) (scheme->ps rect " clip-to-rect"))


;;@node Legending, Legacy Plotting, Rectangles, PostScript Graphing
;;@subsubsection Legending

;;@args title subtitle
;;@args title
;;Puts a @1 line and an optional @2 line above the @code{graphrect}.
(define (title-top title . subtitle)
  (set! *plot-title* title)
  (scheme->ps "(" title ") ("
	      (if (null? subtitle) "" (car subtitle))
	      ") title-top"))

;;@args title subtitle
;;@args title
;;Puts a @1 line and an optional @2 line below the @code{graphrect}.
(define (title-bottom title . subtitle)
  (set! *plot-title* title)
  (scheme->ps "(" title ") ("
	      (if (null? subtitle) "" (car subtitle))
	      ") title-bottom"))

;;@body
;;These edge coordinates of @code{graphrect} are suitable for passing
;;as the first argument to @code{rule-horizontal}.
(define topedge 'topedge)
(define bottomedge 'bottomedge)

;;@body
;;These edge coordinates of @code{graphrect} are suitable for passing
;;as the first argument to @code{rule-vertical}.
(define leftedge 'leftedge)
(define rightedge 'rightedge)

;;@body
;;The margin-templates are strings whose displayed width is used to
;;reserve space for the left and right side numerical legends.
;;The default values are "-.0123456789".
(define (set-margin-templates left right)
  (scheme->ps "/lmargin-template (" left ") def "
	      "/rmargin-template (" right ") def"))

;;@body
;;Draws a vertical ruler with X coordinate @1 and labeled with string
;;@2.  If @3 is positive, then the ticks are @3 long on the right side
;;of @1; and @2 and numeric legends are on the left.  If @3 is
;;negative, then the ticks are -@3 long on the left side of @1; and @2
;;and numeric legends are on the right.
(define (rule-vertical x-coord text tick-width)
  (scheme->ps x-coord " (" text ") " tick-width " rule-vertical"))

;;@body
;;Draws a horizontal ruler with Y coordinate @1 and labeled with
;;string @2.  If @3 is positive, then the ticks are @3 long on the top
;;side of @1; and @2 and numeric legends are on the bottom.  If @3 is
;;negative, then the ticks are -@3 long on the bottom side of @1; and
;;@2 and numeric legends are on the top.
(define (rule-horizontal y-coord text tick-height)
  (scheme->ps y-coord " (" text ") " tick-height " rule-horizontal"))

;;@body
;;Draws the y-axis.
(define (y-axis) 'y-axis)
;;@body
;;Draws the x-axis.
(define (x-axis) 'x-axis)
;;@body
;;Draws vertical lines through @code{graphrect} at each tick on the
;;vertical ruler.
(define (grid-verticals) 'grid-verticals)
;;@body
;;Draws horizontal lines through @code{graphrect} at each tick on the
;;horizontal ruler.
(define (grid-horizontals) 'grid-horizontals)

;;@node Legacy Plotting, Example Graph, Legending, PostScript Graphing
;;@subsubsection Legacy Plotting

(define (graph:plot tmp data xlabel ylabel . histogram?)
  (set! histogram? (if (null? histogram?) #f (car histogram?)))
  (if (list? data)
      (let ((len (length data))
	    (nra (make-array (A:floR64b) (length data) 2)))
	(do ((idx 0 (+ 1 idx))
	     (lst data (cdr lst)))
	    ((>= idx len)
	     (set! data nra))
	  (array-set! nra (caar lst) idx 0)
	  (array-set! nra (if (list? (cdar lst)) (cadar lst) (cdar lst))
		      idx 1))))
  (create-postscript-graph
   tmp (or graph:dimensions '(600 300))
   (whole-page)
   (setup-plot (column-range data 0)
	       (apply combine-ranges
		      (do ((idx (+ -1 (cadr (array-dimensions data))) (+ -1 idx))
			   (lst '() (cons (column-range data idx) lst)))
			  ((< idx 1) lst))))
   (outline-rect plotrect)
   (x-axis) (y-axis)
   (do ((idx (+ -1 (cadr (array-dimensions data))) (+ -1 idx))
	(lst '() (cons 
		  (plot-column data 0 idx (if histogram? 'bargraph 'line))
		  lst)))
       ((< idx 1) lst))
   (rule-vertical leftedge ylabel 10)
   (rule-horizontal bottomedge xlabel 10)))

(define (functions->array vlo vhi npts . funcs)
  (let ((dats (make-array (A:floR32b) npts (+ 1 (length funcs)))))
    (define jdx 1)
    (array-index-map! (make-shared-array dats
					 (lambda (idx) (list idx 0))
					 npts)
		      (lambda (idx)
			(+ vlo (* (- vhi vlo) (/ idx (+ -1 npts))))))
    (for-each (lambda (func)
		(array-map!
		 (make-shared-array dats (lambda (idx) (list idx jdx)) npts)
		 func
		 (make-shared-array dats (lambda (idx) (list idx 0)) npts))
		(set! jdx (+ 1 jdx)))
	      funcs)
    dats))

(define (graph:plot-function tmp func vlo vhi . npts)
  (set! npts (if (null? npts) 200 (car npts)))
  (let ((dats (functions->array vlo vhi npts func)))
    (graph:plot tmp dats "" "")))

;;@body
;;A list of the width and height of the graph to be plotted using
;;@code{plot}.
(define graph:dimensions #f)

;;@args func x1 x2 npts
;;@args func x1 x2
;;Creates and displays using @code{(system "gv tmp.eps")} an
;;encapsulated PostScript graph of the function of one argument @1
;;over the range @2 to @3.  If the optional integer argument @4 is
;;supplied, it specifies the number of points to evaluate @1 at.
;;
;;@args x1 x2 npts func1 func2 ...
;;Creates and displays an encapsulated PostScript graph of the
;;one-argument functions @var{func1}, @var{func2}, ... over the range
;;@var{x1} to @var{x2} at @var{npts} points.
;;
;;@args coords x-label y-label
;;@var{coords} is a list or vector of coordinates, lists of x and y
;;coordinates.  @var{x-label} and @var{y-label} are strings with which
;;to label the x and y axes.
(define (plot . args)
  (call-with-tmpnam
   (lambda (tmp)
     (cond ((procedure? (car args))
	    (apply graph:plot-function (cons tmp args)))
	   ((or (array? (car args))
		(and (pair? (car args))
		     (pair? (caar args))))
	    (apply graph:plot (cons tmp args)))
	   (else (let ((dats (apply functions->array args)))
		   (graph:plot tmp dats "" ""))))
     (system (string-append "gv '" tmp "'")))
   ".eps"))

;;@node Example Graph,  , Legacy Plotting, PostScript Graphing
;;@subsubsection Example Graph

;;@noindent
;;The file @file{am1.5.html}, a table of solar irradiance, is fetched
;;with @samp{wget} if it isn't already in the working directory.  The
;;file is read and stored into an array, @var{irradiance}.
;;
;;@code{create-postscript-graph} is then called to create an
;;encapsulated-PostScript file, @file{solarad.eps}.  The size of the
;;page is set to 600 by 300.  @code{whole-page} is called and leaves
;;the rectangle on the PostScript stack.  @code{setup-plot} is called
;;with a literal range for x and computes the range for column 1.
;;
;;Two calls to @code{top-title} are made so a different font can be
;;used for the lower half.  @code{in-graphic-context} is used to limit
;;the scope of the font change.  The graphing area is outlined and a
;;rule drawn on the left side.
;;
;;Because the X range was intentionally reduced,
;;@code{in-graphic-context} is called and @code{clip-to-rect} limits
;;drawing to the plotting area.  A black line is drawn from data
;;column 1.  That line is then overlayed with a mountain plot of the
;;same column colored "Bright Sun".
;;
;;After returning from the @code{in-graphic-context}, the bottom ruler
;;is drawn.  Had it been drawn earlier, all its ticks would have been
;;painted over by the mountain plot.
;;
;;The color is then changed to @samp{seagreen} and the same graphrect
;;is setup again, this time with a different Y scale, 0 to 1000.  The
;;graphic context is again clipped to @var{plotrect}, linedash is set,
;;and column 2 is plotted as a dashed line.  Finally the rightedge is
;;ruled.  Having the line and its scale both in green helps
;;disambiguate the scales.

;;@example
;;(require 'eps-graph)
;;(require 'line-i/o)
;;(require 'string-port)
;;
;;(define irradiance
;;  (let ((url "http://www.pv.unsw.edu.au/am1.5.html")
;;        (file "am1.5.html"))
;;    (define (read->list line)
;;      (define elts '())
;;      (call-with-input-string line
;;        (lambda (iprt) (do ((elt (read iprt) (read iprt)))
;;                           ((eof-object? elt) elts)
;;                         (set! elts (cons elt elts))))))
;;    (if (not (file-exists? file))
;;        (system (string-append "wget -c -O" file " " url)))
;;    (call-with-input-file file
;;      (lambda (iprt)
;;        (define lines '())
;;        (do ((line (read-line iprt) (read-line iprt)))
;;            ((eof-object? line)
;;             (let ((nra (make-array (A:floR64b)
;;                                      (length lines)
;;                                      (length (car lines)))))
;;               (do ((lns lines (cdr lns))
;;                    (idx (+ -1 (length lines)) (+ -1 idx)))
;;                   ((null? lns) nra)
;;                 (do ((kdx (+ -1 (length (car lines))) (+ -1 kdx))
;;                      (lst (car lns) (cdr lst)))
;;                     ((null? lst))
;;                   (array-set! nra (car lst) idx kdx)))))
;;          (if (and (positive? (string-length line))
;;                   (char-numeric? (string-ref line 0)))
;;              (set! lines (cons (read->list line) lines))))))))
;;
;;(let ((xrange '(.25 2.5)))
;;  (create-postscript-graph
;;   "solarad.eps" '(600 300)
;;   (whole-page)
;;   (setup-plot xrange (column-range irradiance 1))
;;   (title-top
;;    "Solar Irradiance   http://www.pv.unsw.edu.au/am1.5.html")
;;   (in-graphic-context
;;    (set-font "Helvetica-Oblique" 12)
;;    (title-top
;;     ""
;;     "Key Centre for Photovoltaic Engineering UNSW - Air Mass 1.5 Global Spectrum"))
;;   (outline-rect plotrect)
;;   (rule-vertical leftedge "W/(m^2.um)" 10)
;;   (in-graphic-context (clip-to-rect plotrect)
;;                       (plot-column irradiance 0 1 'line)
;;                       (set-color "Bright Sun")
;;                       (plot-column irradiance 0 1 'mountain)
;;                       )
;;   (rule-horizontal bottomedge "Wavelength in .um" 5)
;;   (set-color 'seagreen)
;;
;;   (setup-plot xrange '(0 1000) graphrect)
;;   (in-graphic-context (clip-to-rect plotrect)
;;                       (set-linedash 5 2)
;;                       (plot-column irradiance 0 2 'line))
;;   (rule-vertical rightedge "Integrated .W/(m^2)" -10)
;;   ))
;;
;;(system "gv solarad.eps")
;;@end example
