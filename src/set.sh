#!/bin/bash
## set - set bash behavior
## version 0.0.1 - initial, import
##################################################
set_exit_on_error() { __set exit on error ; } 
#-------------------------------------------------
__set() {
. ${SH}/attr.sh
option_name=option_${RANDOM}
option_value=option_${RANDOM}
eval ${option_name}=${option_value}
attr ${option_name}
##################################################
_set() {
 case $( get_${option_name} ) in
  "exit on error") set -e ;;
  *) false ;;
 esac
}
##################################################
## $1 - option
if [ ${#} -ge 1 ] 
then
 set_${option_name} ${*}
 _set || {
  echo option \"${*}\" no supported
  false
 }
##################################################
else
 exit 1 # wrong args
fi
##################################################
}
