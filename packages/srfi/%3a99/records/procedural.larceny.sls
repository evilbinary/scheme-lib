(library (srfi :99 records procedural)
  (export
   make-rtd rtd? rtd-constructor rtd-predicate rtd-accessor rtd-mutator)
  (import (err5rs records procedural)))
