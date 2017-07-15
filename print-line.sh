#########################################
#!/bin/bash
## print-line
## - print file line
## version 0.0.1 - initial
##################################################
print-line() {
 gawk "//{if(NR==\"${line_no}\")print}" ${file}
}
##################################################
if [ ${#} -eq 2 ] # -a -f "${1}" -a "${2}" -ge 1 -a ${2} -le $( wc ${1} --lines ) ] 
then
 file="${1}"
 line_no="${2}"
else
 exit 1 # wrong args
fi
##################################################
print-line
##################################################
