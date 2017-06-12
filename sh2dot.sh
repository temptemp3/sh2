#!/bin/bash
## sh2dot - generates dot from sh
## version 0.0.1 - initial, import
##################################################
. ${SH}/core.sh
attr file_name
attr function_def_lines
attr function_list
attr dot_expression
##################################################
get_lines() { ${SH}/get-lines.sh ${@} ; }
print_line() { ${SH}/print-line.sh ${@} ; }
print_lines() { ${SH}/print-lines.sh ${@} ; }
pattern() { ${SH}/pattern.sh ${@} ; }
range() { ${SH}/range.sh ${@} ; }
union() { ${SH}/union.sh ${@} ; }
##################################################
# $1- lines
print_the_lines() {
 local lines
 lines=${@}
 print_lines $( get_file_name ) ${lines}
}
#-------------------------------------------------
# $1- pattern
get_the_lines() {
 local pattern
 pattern=${@}
 get_lines $( get_file_name ) ${pattern}
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
 print_line $( get_file_name ) ${line_no}
} 
#+++++++++++++++++++++++++++++++++++++++++++++++++
print_line_function_name() {
  local line_no
 line_no=${1}
 get_line_function_name $( print_the_line ${line_no} )
}
#-------------------------------------------------
pattern_sh_func_def() {
 pattern sh func def
}
#+++++++++++++++++++++++++++++++++++++++++++++++++
get_sh_func_def_lines() {
 get_the_lines "$( pattern_sh_func_def )" 
}
#+++++++++++++++++++++++++++++++++++++++++++++++++
set_the_function_list_loop() {
 for line_no in $( get_function_def_lines )
 do
  get_line_function_name $( print_the_line ${line_no} )
 done
}
#*************************************************
set_the_function_def_lines() {
 set_function_def_lines $( get_sh_func_def_lines )
}
#*************************************************
set_the_function_list() {
 set_function_list $( set_the_function_list_loop )
}
#+++++++++++++++++++++++++++++++++++++++++++++++++
get_file_name_entry() {
 basename $( get_file_name | sed -e 's/[-]/_/g' ) .sh
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
label = "$( get_file_name )" ;
$( dot_all_functions )
$( get_dot_expression )
}
EOF
 
}
#*************************************************
dot() {
 dot_construct
}
#-------------------------------------------------
# $1 - fuctionn
# $2- list
mapcar_list() {
 local func
 local list
 func=${1}
 list=${@:2}
 for el in ${list}
 do
  ${func} ${list}
  list=$( cdr ${list} )
 done
}
cdr() { ${SH}/cdr.sh ${@} ; }
car() { ${SH}/car.sh ${@} ; }
# $1- list
pair() {
 local list
 list=${@}
 #test "$( cdr ${list} )" = "nil" || {
  echo "($( car ${list} ),$( car $( cdr ${list} ) ))"
 #}
}
#-------------------------------------------------
# $1 - pair
destruct_pair() {
 local pair
 local destructed_pair
 pair=${1}
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
   set_dot_expression $( get_dot_expression ) $( echo "func_${function_name} -> func_${function_call} ; " )
   #echoe $( get_dot_expression )
  done
 done
}
#-------------------------------------------------
_list() {
 set_the_function_def_lines
 set_the_function_list
 set_the_dot_expression
 dot
}
##################################################
sh2dot() {
 _list
}
##################################################
## $1 - file name
if [ ${#} -eq 1 -a -f ${1} ] 
then
 set_file_name ${1}
 sh2dot
##################################################
else
 exit 1 # wrong args
fi
##################################################
