#!/bin/bash
## commands (alias)
## - function command cli adapter
## version 0.0.9 - add avialable commands
##################################################
available-commands() { { local function_name ; function_name="${1}" ; local filter_include ; filter_include="${2}" ; }
  declare -f \
  | grep -e "^${function_name}" \
  | cut "-f1" "-d " \
  | grep -v -e "which" -e "for-each" -e "payload" -e "initialize" -e "main" \
  | sed -e '1d'
}
list-available-commands() { { local function_name ; function_name="${1}" ; local filter_include ; filter_include="${2}" ; }
  echo available commands:
  available-commands ${@} \
  | sed -e "s/${function_name}-//" \
  | xargs -I {} echo "- {}" \
  | grep -e "${filter_include}"
}
shopt -s expand_aliases
alias commands='
 { local _command ; _command="${1:-main}" ; }
 { local _args ; _args=${@:2} ; }
 test ! "$( declare -f ${FUNCNAME}-${_command} )" && {
  {    
    ## may depreciate	  
    #test ! "${_command}" || {
    #  test ! "${_command}" != "main" || {
    #    echo "${FUNCNAME} command \"${_command}\" not yet implemented"
    #  }
    #}
    list-available-commands ${FUNCNAME} 
  } 1>&2
 true
 } || {
  ${FUNCNAME}-${_command} ${_args}
 }
'
alias run-commands-as-main='
{
  local command
  for command in $( available-commands ${FUNCNAME/-main} )
  do
    ${command}
  done
}
'
##################################################
