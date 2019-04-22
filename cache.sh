#!/bin/bash
## cache
## - simple lazy caching
## version 0.0.2 - allow cache dir override
##################################################
shopt -s expand_aliases	# enable alias expansion
alias cache-generic-payload='
{ 
  cache "${cache}/${FUNCNAME}" "${FUNCNAME}-payload"
}
'
##################################################
test "${cache}" || {
  cache="$( dirname ${0} )/cache"
}
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
"${cache}/cache-test" \
"_" \
&>/dev/null
##################################################
