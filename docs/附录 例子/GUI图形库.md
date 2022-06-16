# 支持多窗口gui

```scheme

(define (test-win-order)
  (window "gaga" 800 800
	  (let (
		(win1 (window '() "win1哈哈1" 400 200 :top))
		(win2  (window '() "win2" 300 200 :right))
		(win3  (window '() "win3" 600 600 :bottom))
		(win4  (window '() "win4" 700 700 :bottom))
		(win5  (window '() "win5" 300 300 :bottom))
		(win6  (window '() "win6" 300 300 :bottom))
		(win7  (window '() "win7" 300 300 :bottom))
		(win8  (window '() "win8" 300 300 :bottom))
		(win9  (window '() "win9" 300 300 :bottom))
		(win10  (window '() "win10" 600 600 :bottom))
		(win11  (window '() "win11" 600 600 :bottom))
		(win12  (window '() "win12" 600 600 :bottom))
		(win13  (window '() "win13" 600 600 :bottom))
		(win14  (window '() "win14" 600 600 :bottom))
		)
	    (button win1 "win1" 80 40 :bottom (color-rgba  0 255 0 255) (color-rgba 255 0 0 255 ))
	    (button win2 "win2" 80 40 :bottom (color-rgba  0 255 0 255) )
	    (button win3 "win3" 80 40 :bottom (color-rgba  0 255 0 255) )
	    (button win3 "win3-4" 80 40 :left (color-rgba  0 255 0 255) )
	    (label win2 "hello" 40 30 :center )
	    (button '() "button" 40 40 :center) ) ))