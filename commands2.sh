#!/bin/bash
## commands2
## - handles subcommands
## version 0.0.1 - initial
##
## USAGE
##	. commands2.sh
##	foo-subcommand() { ... }
##	foo() {
##	  commands2 ${FUNCNAME} ${@}
##	}
##
##################################################
commands2() { { local base ; base="${1}" ; local subcommand_no ; subcommand_no="${2}" ; local args ; args=${@:3} ; }
 local subcommand_count
 local subcommands
 _get-subcommands() {
   subcommands=$(
    car $(
     declare -f \
     | grep --color=auto -e '()' \
     | grep --color=auto ${base} \
     | cut '-d ' '-f1'
    )
  )
 }
 _count-subcommands() {
   subcommand_count=$(
    echo ${subcommands} \
    | wc -w
   )
 }
 _list-subcommands() {
   local subcommand
   local count
   count=1
   echo commands:
   for subcommand in ${subcommands}
   do
    echo "(${count})     ${subcommand}"
    count=$(( ${count} + 1 ))
   done
 }
 _get-subcommands # ${subcommands}
  test ${#} -eq 1 && {
   _list-subcommands
  true
  } || {
   _count-subcommands # ${subcommand_count}
   test ${subcommand_no} -gt 0 2>/dev/null || {
     {
       echo "'${2}' not an integer or too low"
       echo "try again"
     } 1>&2
     _list-subcommands
     false
     return
   }
   test ${subcommand_no} -le ${subcommand_count} || {
     {
       echo "'${2}' too high"
       echo "try again"
     } 1>&2
     _list-subcommands
     false
     return
   }
   test ${subcommand_no} -gt 0 -a ${subcommand_no} -le ${subcommand_count}
   subcommand=$(
    echo ${subcommands} \
    | cut '-d ' "-f${subcommand_no}"
   )
   echo ${subcommand} ${args}
   ${subcommand} ${args}
 }
}
##################################################
