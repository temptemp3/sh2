#!/bin/bash
## echo - echo functions
## version 0.0.1 - initial, import
##################################################
. ${SH}/attr.sh
attr echo_input
attr echo_last
##################################################
echoe() {
 set_echo_input ${@}
 __echo 1>&2 
}
#-------------------------------------------------
 __echo() {
 test "$( get_echo_input )" = "" || {
  $( which echo ) $( get_echo_input )
  set_echo_last $( get_echo_input )
  return
 } && {
  $( which echo ) $( get_echo_last )
 }
}
_echo() {
 #------------------------------------------------
 if [ ! ] 
 then
  set_echo_input ${@}
  __echo
 else
  exit 1 # wrong args
 fi
 #------------------------------------------------
}
##################################################
