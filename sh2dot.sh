#!/bin/bash
## sh2dot - generates dot from sh
## version 0.0.3 - wip
##################################################
. ${SH2}/aliases/commands.sh
. ${SH2}/cecho.sh
##################################################
get_lines() { ${SH}/get-lines.sh ${@} ; }
print_line() { ${SH}/print-line.sh ${@} ; }
print_lines() { ${SH}/print-lines.sh ${@} ; }
range() { ${SH}/range.sh ${@} ; }
union() { ${SH}/union.sh ${@} ; }
##################################################
car() { echo ${1} ; }
#-------------------------------------------------
cdr() { echo ${@:2} ; }
#-------------------------------------------------
print_the_lines() { { local lines ; lines=${@} ; }
 print_lines ${infile} ${lines}
}
#-------------------------------------------------
get_the_lines() { { local pattern ; pattern="${@}" ; }
 get_lines ${infile} ${pattern}
}
#-------------------------------------------------
# $1- function def line
get_line_function_name() {
 local sh_func_def_line
 sh_func_def_line=${@}
 echo ${sh_func_def_line} | sed -e 's/(.*$//'
}
#-------------------------------------------------
# $1 - line number
print_the_line() {
 local line_no
 line_no=${1}
 print_line ${infile} ${line_no}
} 
#+++++++++++++++++++++++++++++++++++++++++++++++++
print_line_function_name() {
  local line_no
 line_no=${1}
 get_line_function_name $( print_the_line ${line_no} )
}
#-------------------------------------------------
set_the_function_list_loop() {
 for line_no in $( get_function_def_lines )
 do
  get_line_function_name $( print_the_line ${line_no} )
 done
}
#-------------------------------------------------
get_sh_func_def_lines() {
 local pattern_sh_func_def_line
 pattern_sh_func_def_line='^[a-z_-]*[(][)]\s*{.*$'
 get_the_lines "${pattern_sh_func_def_line}"
}
#-------------------------------------------------
set-function-def-lines() {
 set_function_def_lines $( 
  get_sh_func_def_lines 
 )
}
#-------------------------------------------------
set-function-list() {
 set_function_list $(
  set_the_function_list_loop
 )
}
#+++++++++++++++++++++++++++++++++++++++++++++++++
get_file_name_entry() {
 basename $( echo ${infile} | sed -e 's/[-]/_/g' ) .sh
}
#+++++++++++++++++++++++++++++++++++++++++++++++++
dot_all_functions() {
 true ; return ;
 local limit
 local count
 limit=0
 count=0
 for func in $( get_function_list )
 do
  test ${limit} -eq 0 -o ! ${count} -ge ${limit} || { break ; }
  echo "func_${func} ;"
  count=$(( ${count} + 1 ))
 done 
}
#*************************************************
dot_construct() {
 cat << EOF
digraph G {
graph [layout=dot rankdir=LR] ;
label = "$( basename ${infile} )" ;
$( dot_all_functions )
$( get_dot_expression )
}
EOF
}
#-------------------------------------------------
dot() {
 dot_construct
}
#-------------------------------------------------
# $1 - fuctionn
# $2- list
mapcar_list() { { local func ; func="${1}" ; local list ; list="${@:2}" ; }
 local el
 for el in ${list}
 do
  ${func} ${list}
  list=$( cdr ${list} )
 done
}
# $1- list
pair() { { local list ; list=${@} ; }
 #test "$( cdr ${list} )" = "nil" || {
  echo "($( car ${list} ),$( car $( cdr ${list} ) ))"
 #}
}
#-------------------------------------------------
# $1 - pair
destruct_pair() { { local pair ; pair="${1}" ; }
 local destructed_pair
 destructed_pair=$( echo ${pair} | sed -e 's/[(,)]/ /g' )
 echo ${destructed_pair}
}
#-------------------------------------------------
is_function() {
 cat > is-function << EOF
 is_function() {
local token
token=\${1}
case \${token} in
$( for function_name in $( get_function_list )
do
 echo "${function_name}) true ;;"
done
echo "*) false ;;" 
echo "esac" 
echo }]
EOF
 . is-function
 rm is-function --force --verbose &>/dev/null
 is_function_build=true
 is_function ${@}
}
#-------------------------------------------------
clean_function_name() { { local function_name ; function_name="${1}" ; }
 echo ${function_name} |
 sed \
  -e 's/[_-]/_/g'
}
#-------------------------------------------------
set_the_dot_expression() {
 local destsruted_pair
 local pair_a
 local pair_b
 local lines
 local line
 for pair in $( mapcar_list pair $( get_function_def_lines ) )
 do
  #echoe ${pair}
  destucted_pair=$( destruct_pair ${pair} ) 
  pair_a=$( car ${destucted_pair} )
  pair_b=$( cdr ${destucted_pair} )
  test ! ${pair_b} = "nil" || {
   #echo last function defition most likely entry point
   candidate_line_no=$(( ${pair_a} + 1 ))
   while :
   do
    line=$( print_the_line ${candidate_line_no} )
    #echo ${candidate_line_no}:${line}
    echo ${line} | grep -e '^[#]\+$' &>/dev/null && { break ; } || { true ; }
    candidate_line_no=$(( ${candidate_line_no} + 1 ))
   done
   pair_b=$(( ${candidate_line_no} - 1 ))
  }
  lines=$( range ${pair_a} $(( ${pair_b} - ${pair_a} )) )
  #echo ${lines}
  #print_the_lines ${lines}
  function_name=$( get_line_function_name $( print_the_line $( car ${lines} ) ) )
  function_definition=$( print_the_lines $( cdr ${lines} ) )
  #echo ${function_definition}
  function_calls=$( union $( for token in ${function_definition}
  do
   is_function ${token} && { echo ${token} ; } || { true ; } 
  done ) 2>/dev/null || { true ; } )
  #echo function_calls:${function_calls}
  # build dot expression
  for function_call in ${function_calls}
  do
   set_dot_expression $( get_dot_expression ) $( echo "func_$( clean_function_name ${function_name} ) -> func_$( clean_function_name ${function_call} ) ; " )
  done
 done
}
#-------------------------------------------------
sh2dot-list() {
 set-function-def-lines	# set attr function_def_lines
 set-function-list 	# set attr function_list
 set_the_dot_expression
 dot
}
#-------------------------------------------------
sh2dot-testing() {
 true
}
#-------------------------------------------------
sh2dot-initialize() { 
 cecho green initializing ...
}
#-------------------------------------------------
sh2dot() { 
 ${FUNCNAME}-initialize
 commands
}
##################################################
if [ ! ]
then
 true
else
 exit 1 # wrong args
fi
##################################################
sh2dot ${@}
##################################################
