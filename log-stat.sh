#!/bin/bash
## log-stat
## - breakdown log by path
## version 0.0.1 - initial
## =to do=
## + implement hour parameter
##################################################
set -e # exit on error
#set -v -x
##################################################
range() { ${SH2}/range.sh ${@} ; }
print-line() { ${SH2}/print-line.sh ${@} ; }
##################################################
car() {
 echo ${1}
}
#-------------------------------------------------
cdr() {
 echo ${@:2}
}
#-------------------------------------------------
get-paths() {
 cat << EOF
name		path
elb		GET\shttp:\/\/elb
themes		themes
plugin		plugins
html		html\sHTTP
uploads		uploads
favicon		favicon
robots		robots
top		80\/\sHTTP
feed		feed\/\sHTTP
category	[a-z]\+\/\sHTTP
category-page	[0-9]\+\/\sHTTP
sitemap		sitemap
icon		icon
wp-login	wp-login[.]php\sHTTP
wp-admin	wp-admin
openhand	openhand
other-404	404\s404
other-jorgee	Mozilla\/5[.]0\sJorgee
EOF
} 
#-------------------------------------------------
print-path-line() {
 get-paths | 
 sed -n "${1}p"
}
#-------------------------------------------------
get-path-lines() {
 get-paths | 
 wc --lines
}
#-------------------------------------------------
get-total-count() {
 cat ${log} | 
 wc --line
}
#-------------------------------------------------
get-path-count() {
 get-log-path | 
 wc --line
}
#-------------------------------------------------
leading-digit() { { local number ; number="${1}" ; }
 #set -v -x
 #echo ${number}
 echo ${number:0:1}
 #set +v +x
}
#-------------------------------------------------
get-percent-total() { 
  echo $(( ${path_count} * 100 / ${total} )).$( leading-digit $(( ${path_count} * 1000 / ${total} )))$( leading-digit $(( ${path_count} * 10000 / ${total} )) )
}
#-------------------------------------------------
get-log-path() { 
 test "${path_pattern}" && { # first and last path_pattern
  test "${path_pattern_previous}" && { # second through last path_pattern
   cat ${log} | 
   grep -v "${path_pattern_previous}" |
   grep -e "${path_pattern}" | 
   tee log.${path_name}.txt
  } || { # first path_pattern
   cat ${log} | 
   grep -e "${path_pattern}" | 
   tee log.${path_name}.txt
  }
 } || { # other
  cat ${log} |
  grep -v -e "${path_pattern_previous}" |
  tee log.${path_name}.txt
 }
}
#-------------------------------------------------
log-stat-payload() { { local log ; log="${1}" ; }
 local sum
 local path_line_no
 local total
 total=$( get-total-count )
 echo total: ${total}
 sum=0
 for path_line_no in $( cdr $( range $( get-path-lines ) ) )
 do 
  path_line=$( print-path-line ${path} ${path_line_no} )
  path_name=$( car ${path_line} )
  path_pattern=$( cdr ${path_line} )
  #echo ${path_line} : ${path_name} : ${path_pattern}
  path_count=$( get-path-count )

  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }

  echo ${path_name}: ${path_count} $( get-percent-total )%
  sum=$(( ${sum} + ${path_count} ))
  unset path_line
  unset path_name
  unset path_pattern 
 done
 # get other path_count ##########################
 path_line=$( print-path-line ${path} ${path_line_no} )
 path_name=other
 path_count=$( get-path-count ) 
 echo ${path_name}: ${path_count} $( get-percent-total )%
 sum=$(( ${sum} + ${path_count} ))  
 #################################################
 echo sum: ${sum} 
}
#-------------------------------------------------
log-stat-payload2() { { local log ; log="${1}" ; }
 local sum
 local path_line_no
 local total
 local header
 local data
 total=$( get-total-count )
 header="total"
 data="${total}"
 sum=0
 for path_line_no in $( cdr $( range $( get-path-lines ) ) )
 do 
  path_line=$( print-path-line ${path} ${path_line_no} )
  path_name=$( car ${path_line} )
  path_pattern=$( cdr ${path_line} )
  #echo ${path_line} : ${path_name} : ${path_pattern}
  path_count=$( get-path-count )
  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }
  header="${header},${path_name}" 
  data="${data},${path_count}"
  sum=$(( ${sum} + ${path_count} ))
  unset path_line
  unset path_name
  unset path_pattern
 done
 # get other path_count ##########################
 path_line=$( print-path-line ${path} ${path_line_no} )
 path_name=other
 path_count=$( get-path-count ) 
 header="${header},${path_name}" 
 data="${data},${path_count}"
 sum=$(( ${sum} + ${path_count} ))  
 #################################################
 header="${header},sum"
 data="${data},${sum}"
 cat << EOF
${header}
${data}
EOF
}
#-------------------------------------------------
log-stat-for-each-date() {
 local log
 test ! "${dates}" || {
  for date in ${dates}
  do
  # test if directory
  test ! -d "${date}" || {
   log="log.txt"
   cat ${date}/* > ${log}
   log-stat-for-log
  }
  done
 }
}
#-------------------------------------------------
log-stat-for-log() {
 test ! "${log}" || {
  #log-stat-payload ${log}
  log-stat-payload2 ${log}
 }
}
#-------------------------------------------------
log-stat-list() {
 log-stat-for-each-date
 log-stat-for-log
}
#-------------------------------------------------
log-stat() { 
 log-stat-list 2> error.txt
}
##################################################
if [ ${#} -ge 2 ]
then
 dates="${@}"
elif [ ${#} -eq 1 -a -d "${1}" ] 
then
 dates="${1}"
elif [ ${#} -eq 1 -a -f "${1}" ]
then
 log="${1}"
elif [ ${#} -eq 0 -a -f "log.txt" ]
then
 log="log.txt"
else
 exit 1 # wrong args
fi
##################################################
log-stat
##################################################
