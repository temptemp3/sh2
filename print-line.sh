#!/bin/bash
## print-line
## version 0.0.2 - sh initial
#############################################
print-line() {
 sed -n "${line_number}p" "${file_name}"
}
#############################################
if [ ${#} -eq 2 -a -f "${1}" -a ${2} -ge 1 ] 
then
 file_name=${1} 
 line_number=${2}
else
 exit 1 # wrong args
fi
#############################################
print-line
#############################################
