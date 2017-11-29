#!/bin/bash
## log-stat
## - breakdown log by path
## version 1.0.0 - initial
##################################################
set -e # exit on error
##################################################
. $( dirname ${0} )/aliases.sh
##################################################
range() { $( dirname ${0} )/range.sh ${@} ; }
print-line() { $( dirname ${0} )/print-line.sh ${@} ; }
##################################################
car() {
 echo ${1}
}
#-------------------------------------------------
cdr() {
 echo ${@:2}
}
#-------------------------------------------------
get-paths-wordpress() {
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
get-paths-http() {
 cat << EOF
name		path
http-200	200\s200
http-206	206\s206
http-301	301\s301
http-302	302\s302
http-304	304\s304
http-403	403\s403
http-404	404\s404
http-503	503\s503
http-504	 -1\s504
EOF
} 
#-------------------------------------------------
get-paths-file() { { local filename ; filename="${1}" ; }
 test -f "${1}" && {
  cat ${1}
 } || {
  echo "file '${filename}' does not exist" 1>&2
  false
 }
} 
#-------------------------------------------------
get-paths() { 
 commands
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


  path_count=$( get-path-count )

  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }

  echo ${path_line} : ${path_name} : ${path_pattern} : ${path_count} : ${path_pattern_previous} 1>&2

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
log-stat-help() {
 cat << EOF
log-stat 
1 - log file 
 default:log.txt
2 - dates directory

EOF
}
#-------------------------------------------------
log-stat() { 
 #log-stat-list 2> error.txt
 commands
}
##################################################
if [ ${#} -ge 3 ]
then
 paths="${1}"
 dates="${@:2}"
elif [ ${#} -eq 1 -a -d "${1}" ] 
then
 paths="http"
 dates="${1}"
elif [ ${#} -eq 2 -a -f "${1}" ]
then
 log="${1}"
 paths="${2}"
elif [ ${#} -eq 1 -a -f "${1}" ]
then
 log="${1}"
 paths="http"
elif [ ${#} -eq 0 -a -f "log.txt" ]
then
 log="log.txt"
else
 log-stat-help
 exit 1 # wrong args
fi
##################################################
log-stat
##################################################
