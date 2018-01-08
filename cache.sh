#!/bin/bash
## cache
## - simple lazy caching
## version 0.0.1 - initial
##################################################
cache="$( dirname ${0} )/cache"
cache() { { local candidate_key ; candidate_key="${1}" ; local function_name ; function_name="${2}" ; }

  {
    test -f "${candidate_key}" || { 
     ${function_name} > ${candidate_key}
    }
    cat ${candidate_key}
  } 
}
##################################################
if [ ! ] 
then
 test -d "${cache}" || {
  {
   echo creating cache folder ... 
   mkdir -v ${cache}
  } 1>&2
 }
else
 exit 1 # wrong args
fi
##################################################
_() {
 echo Created $( date )
}
cache \
"$( dirname ${0} )/cache-test" \
"_" \
&>/dev/null
##################################################
