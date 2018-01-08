#!/bin/bash
## generate-temp
## version 0.0.2 - sh2 initial
##################################################
generate-temp() { 
 echo ${prefix}-$( date +%s )-${RANDOM}
}
##################################################
if [ ${#} -eq 1 ] 
then
 prefix="${1}"
elif [ ${#} -eq 0 ] 
then
 prefix="temp"
else
 exit 1 # wrong args
fi
##################################################
generate-temp
##################################################
