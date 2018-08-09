#!/bin/bash
## attr
## version: 1.0.1 - attribute name
##################################################
attr() {
##################################################
local attribute_name
##################################################
temp() {
 echo attr-${attribute_name}-$( date +%s )-${RANDOM}
}
#-------------------------------------------------
main() {
 _() {
  cat > ${2} << EOF
set_${1}() {
 test ! "\${*}" = "" || { 
  echo error: empty set_ on ${1} 1>&2
  return 1 ; 
 }
 ${1}=\${*} 
} 
get_${1}(){ echo \${${1}} ; }
EOF
  . ${2}
  rm ${2} --force #--verbose
 } ; _ "${attribute_name}" "$( temp )"
}
##################################################
## $1 - attribute name
##################################################
if [ ${#} -eq 1 ] 
then
 attribute_name=${1}
 main
else
 exit 1 # wrong args
fi
}
##################################################
