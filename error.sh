#!/bin/bash
## error
## =standalone=
## version: 2.0.7 - revise date format
#####################################################################################
{ # error handling

 set -e # exit on error

 date_offset=0 # may depreciate later
 _date() {   _() { echo "date" ; } ;  __() { echo "--$( _ )=@$(( $( $( _ ) +%s ) + ${date_offset} ))" ; } ;  ___() { echo "+%y%m%dT%H%M" ; } ;  "$( _ )" "$( __ )" "$( ___ )" ; }  
 _finally() { true ; }
 _cleanup() { true ; }
 _on_error() { true ; }
 _on_success() { true ; }
 error-show() {
  cat << EOF
error_message: ${error_message}
error_function_name: ${error_function_name}
error_line_number: ${error_line_number}
error_show: ${error_show}
EOF
 }
 error-help() {
  cat << EOF
error
- error handling interface

USAGE

# show|hide error errors
error true|false

# exit with error message
false || {
 error "manual break" "\${BASH_FUNC}" "\${LINE_NO}"
 false
}


EOF
 } 
 error() {
  case ${#} in
   3) {
    error_message="${1}"
    error_function_name="${2}"
    error_line_number="${3}" 
   } ;;
   1) {
    error_show=${1}
   } ;;
  esac
 }
 _exit() { set +v +x ; { local function_name ; local line_number ; function_name=${1} ; line_number=${2} ; }
 if-function-name() { _() { echo $( test "${1}" && { echo "${1}" ; true ; } || { echo "${2}" ; } ; ) ; } ; _ "${error_function_name}" "${function_name}" ; }
 if-line-number() { _() { echo $( test ! "${1}" -a ! ${2} -ne 1 || { echo "on line" ; test ! "${1}" && { test ! ${2} -ne 1 || { echo "${2}" ; } ; true ; } || { echo "${1}" ; } ; } ; ) ; } ; _ "${error_line_number}" "${line_number}" ; }
 if-message() { _() { test ! "${1}" || { echo "\"${1}\"" ; } ; } ; _ "${error_message}" ; }
 if-error-show() {
   test "${error_show}" = "false" || {
    cat >> error-log << EOF
$( _date ) ${0} $( if-message )
error in $( if-function-name ) $( if-line-number )
EOF
    echo $( tail -n 2 error-log ) 1>&2 # stdout to stderr
   }
  }
  test ! "${function_name}" = "" && {
   if-error-show 
   _on_error
  true
  } || { # on success
   _on_success
  }
  _finally ; _cleanup ;
 }
 error "false" # default
 trap '_exit "${FUNCNAME}" "${LINENO}"' EXIT ERR
}
#####################################################################################
