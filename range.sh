#!/bin/bash
## range
## - returns range of numbers
## version 0.1.2 - include local source fix
#####################################################################################
. $( dirname ${0} )/error.sh	# error handling
error "true"			# show errors
#####################################################################################
eval-range() {
 eval echo {${range_start}..${range_end}..${range_incr}}
}
#------------------------------------------------------------------------------------
test-range() {
 test ${range_start} -ge 0 -a ${range_end} -ge ${range_start} || {
  error "out of range" "${BASHFUNC}" "${LINENO}"
  false
 }
}
#------------------------------------------------------------------------------------
range-list() {
 test-range
 eval-range
}
#------------------------------------------------------------------------------------
range() {
 range-list
}
#####################################################################################
if [ ${#} -eq 3 ]
then
 range_start=${1}
 range_end=${2}
 range_incr=${3}
elif [ ${#} -eq 2 ]
then
 range_start=${1}
 range_end=${2}
 range_incr=1
elif [ ${#} -eq 1 ] 
then
 range_start=1
 range_end=${1}
 range_incr=1
else
 exit 1 # wrong args
fi
#####################################################################################
range
#####################################################################################
