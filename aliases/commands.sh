#!/bin/bash
## commands (alias)
## - function command cli adapter
## version 0.1.0 - slack.sh commands
##################################################
list-available-commands-filter-exclude-list-default() { 
 cat << EOF
which
for-each
payload
initialize
test
EOF
}
list-available-commands-filter-exclude-list() { 
 ${FUNCNAME}-default
}
list-available-commands-filter-exclude() { 
 local filter_exclude
 filter_exclude=$( 
   local el
   for el in $( ${FUNCNAME}-list )
   do
    echo "-e ${el}"
   done
 )
 echo ${filter_exclude}
}
list-available-commands() { { local function_name ; function_name="${1}" ; local filter_include ; filter_include="${2}" ; }
  echo available commands:
  {
    declare -f \
    | grep -e "^${function_name}[^(]*.)" \
    | cut "-f1" "-d " \
    | grep -v -e $( ${FUNCNAME}-filter-exclude ) \
    | sed -e "s/${function_name}[-]\?//" \
    | xargs -I {} echo "- {}" \
    | grep -e "${filter_include}" \
    | sort
  }
}
shopt -s expand_aliases
alias read-command-args='
 list-available-commands ${FUNCNAME}
 echo "enter new command (or q to quite)"
 read command_args
'
alias parse-command-args='
 _car() { echo ${1} ; }
 _cdr() { echo ${@:2} ; }
 _command=$( _car ${command_args} )
 _args=$( _cdr ${command_args} )
'
alias commands='
 { local _command ; _command="${1}" ; }
 { local _args ; _args=${@:2} ; }
 test ! "$( declare -f ${FUNCNAME}-${_command} )" && {
  {    
    test ! "${_command}" || {
     echo "${FUNCNAME} command \"${_command}\" not yet implemented"
    }
    list-available-commands ${FUNCNAME} 
  } 1>&2
 true
 } || {
  ${FUNCNAME}-${_command} ${_args}
 }
'
alias run-command='
 {
   commands
 } || true
'
alias handle-command-args='
 case ${command_args} in
   q|quit) {
    break  
   } ;; 
   *) { 
    parse-command-args
   } ;;
 esac
'
alias command-loop='
 while [ ! ]
 do
  run-command
  read-command-args
  handle-command-args
 done
'
##################################################
