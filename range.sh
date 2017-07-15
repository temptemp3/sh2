#!/bin/bash
## range 
## - returns range
## version 0.0.1 - inital
##############################################
. ${SH}/attr.sh
attr start
attr length
validation() {
 test ! $( get_start ) -le 0 	|| exit 111
 test ! $( get_length ) -le 0	|| exit 112
}
##############################################
range_end() {
 echo $(( $( get_start ) + $( get_length ) - 1 ))
}
##############################################
range_string() {
 echo {$( get_start )..$( range_end )}
}
##############################################
range() { 
 eval echo $( range_string )
}
##############################################
## $1 - start
## $2 - length
##############################################
if [ ${#} -eq 2 ]
then
 set_start ${1} &&
 set_length ${2} &&
 validation &&
 range &&
 true
##############################################
elif [ ${#} -eq 1 ]
then
 "${0}" "1" "${1}"
##############################################
else
 exit 1 # wrong args
fi
##############################################
