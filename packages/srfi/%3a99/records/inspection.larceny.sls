(library (srfi :99 records inspection)
  (export
   record? record-rtd rtd-name rtd-parent
   rtd-field-names rtd-all-field-names rtd-field-mutable?)
  (import (err5rs records inspection)))
