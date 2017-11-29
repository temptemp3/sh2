#!/bin/bash
## aliases
## - aliases
## version 0.0.2 - expand aliases
##################################################
shopt -s expand_aliases
#-------------------------------------------------
# commands (alias)
# - function command cli adapter
# version 0.0.4 - ignore child functions
# usage:
# - place commands in a function
# - on calling the function commands will attempt 
#   to call a child function whose sufix is 
#   indicated by the first argument with arguments
# - in the case that ...
# to do:
# - exclude args
# + allow available command listing exclude patterns
#   to be specified from the outside
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
