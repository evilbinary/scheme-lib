#!/bin/bash

run_in_each () {
    ikarus --r6rs-script     $1
    scheme --program         $1
    ypsilon                  $1
    larceny --r6rs --program $1
    mosh                     $1
}    

run_in_each $SCHEME_LIBRARIES/dharmalab/tests/records.sps
run_in_each $SCHEME_LIBRARIES/dharmalab/tests/records-typed-fields.sps
