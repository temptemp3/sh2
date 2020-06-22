#!/bin/bash
## get-line
##############################################
. ${SH2}/attr.sh
attr file
attr pattern
##############################################
car() { ${SH2}/car.sh ${@} ; }
##############################################
get_first_match_line() {
 car $( cat $( get_file ) | gawk "/$( get_pattern )/{print NR}" )
}
#---------------------------------------------
get_line() { 
 get_first_match_line
}
##############################################
## $1 - file
## $2 - pattern
##############################################
if [ ${#} -ge 2 -a -e "${1}" ]
then
 set_file ${1}
 set_pattern ${@:2}
 get_line
##############################################
else
cat << EOF
get-line
options:
 1 - file
 2 - pattern
EOF
 exit 1 # wrong args
fi
##############################################