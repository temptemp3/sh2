#!/bin/bash
## cecho
## - color echo
## version 0.0.2 - remove entry
##################################################
cecho-color() { #{ local candidate_color ; candidate_color="${1}" ; }
 case ${candidate_color} in
  blue) {
   echo 34 
  } ;;
  yellow) {
   echo 33
  } ;;
  green) {
   echo 32 
  } ;; 
  *) {
   echo 0
  } ;;
 esac
}
#-------------------------------------------------
cecho() { { local candidate_color ; candidate_color="${1}" ; local line ; line=${@:2} ; }
  test ! "${line}" || {
    echo -e "\e[$( ${FUNCNAME}-color )m ${line} \e[0m" 
  } 1>&2
}
##################################################
