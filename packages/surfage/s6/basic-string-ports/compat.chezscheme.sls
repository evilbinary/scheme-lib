
(library (surfage s6 basic-string-ports compat)
  
  (export open-output-string get-output-string)
  
  (import (only (chezscheme) open-output-string get-output-string)))