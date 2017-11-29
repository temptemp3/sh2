#!/bin/bash
## aliases
## - aliases
## version 0.0.1 - commands
##################################################
#-------------------------------------------------
# commands (alias)
# - function command cli adapter
# version 0.0.4 - ignore child functions
#-------------------------------------------------
alias commands='
 { local _command ; _command="${1}" ; local args=${@:2} ; }
 test ! "$( declare -f ${FUNCNAME}-${_command} )" && {
  {    
    test ! "${_command}" || {
     echo "${FUNCNAME} command \"${_command}\" not yet implemented"
    }
    echo available commands:
    declare -f \
 	  | grep -e "^${FUNCNAME}" \
 	  | cut "-f1" "-d " \
 	  | grep -v -e "which" -e "for-each" -e "payload" \
   	  | sed -e "s/${FUNCNAME}-//" \
	  | xargs -I {} echo "- {}" \
	  | sed  "1d" # ignore self

  } 1>&2
 true
 } || {
  ${FUNCNAME}-${_command} ${args}
 }
'
#aliases() {
# true
#}
##################################################
#if [ ${#} -eq 0 ] 
#then
# true
#else
# exit 1 # wrong args
#fi
##################################################
#aliases
##################################################
