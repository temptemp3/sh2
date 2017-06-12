#!/bin/bash
## attr - attribute class
## version 0.0.1 - initial, import
##################################################
attr() {
##################################################
temp() {
 echo attr-$( date +%s )-${RANDOM}
}
##################################################
main() {
 local temp
 temp=$( temp )
 cat > ${temp} << EOF
set_${1}() {
 test ! "\${*}" = "" || { 
  echo error: empty set_ on ${1} 1>&2
  return 1 ; 
 }
 ${1}=\${*} 
} 
get_${1}(){ echo \${${1}} ; }
EOF
 . ${temp}
 rm ${temp} --force
}
##################################################
## $1 - attribute name
##################################################
if [ ${#} -eq 1 ] 
then
 main ${@}
else
 exit 1 # wrong args
fi
##################################################
}
