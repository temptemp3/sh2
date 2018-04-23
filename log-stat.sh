#!/bin/bash
## log-stat
## - breakdown log by path
## version 1.1.7 - export paths
## + move individual log files to sub folder
## =to do=
## (7 Apr 2018)
## + break on empty other
##	 + allow get path count loop to terminate if remaining paths is empty
##		 + as in case of early hours
## (6 Apr 2018)
## + allow path file comments
## (5 Apr 2018)
## + hide row if other equals sum 
##################################################
. $( dirname ${0} )/error.sh	# error handling
error "true"			# show errors
##################################################
. $( dirname ${0} )/cache.sh
##################################################
. $( dirname ${0} )/aliases/commands.sh
##################################################
range() { $( dirname ${0} )/range.sh ${@} ; }
print-line() { $( dirname ${0} )/print-line.sh ${@} ; }
car() { $( dirname ${0} )/car.sh ${@} ; }
cdr() { $( dirname ${0} )/cdr.sh ${@} ; }
##################################################
print-path-line() {
 get-paths ${paths} | 
 sed -n "${1}p"
}
#-------------------------------------------------
get-path-lines() {
 get-paths ${paths} | 
 wc --lines
}
#-------------------------------------------------
get-path-line-range() {
 cdr $( range $( get-path-lines ) )
}
#-------------------------------------------------
sanitize() { # stub
 echo "${@}"
}
#-------------------------------------------------
get-paths() { 
 commands
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
## try import paths
test ! -d "$( dirname ${0} )/paths" || {
 {
   echo importing paths $( echo $( dirname ${0} )/paths/*.sh ) ..
 } 1>&2 &>/dev/null
 for path_file in $( find $( dirname ${0} )/paths -type f -name \*.sh )
 do
  . ${path_file}
 done
}
#-------------------------------------------------
group-paths() { { local candidate_path_name ; candidate_path_name="${1}" ; }
 local path_group
 path_group=$(
  ${FUNCNAME}-get-patterns
 )
 test "${path_group}"
 echo "${path_group}"
}
#-------------------------------------------------
log-stat-test-get-paths() {
 get-paths ${@}
}
#-------------------------------------------------
log-stat-test() {
 commands
}
#-------------------------------------------------
log-stat-test-group-paths() {
 group-paths ${@} 
}
#-------------------------------------------------
group-paths-get-patterns-range() {
  {
    get-paths ${candidate_path_name} \
    | gawk '{print $(2)}' \
    | sed "1d"
  }
}
#-------------------------------------------------
group-paths-get-patterns() {
 local pattern
 for pattern in $( ${FUNCNAME}-range )
 do
  echo -n "${pattern}\\|" 
 done | sed 's/..$//'
}
#-------------------------------------------------
get-total-count() {
 cat ${log} | 
 wc --line
}
#-------------------------------------------------
get-path-count-payload() {
 get-log-path | 
 wc --line
}
#-------------------------------------------------
get-path-count() {
  {
    #cache \
    #"${cache}/$( sanitize ${log}-${path_name} )" \
    ${FUNCNAME}-payload
  }
}
#-------------------------------------------------
padded-digit() { { local candidate_digit ; candidate_digit="${1}" ; }
 test "${candidate_digit}"
 local padded_digit
 test ! $( echo -n "${candidate_digit}" | wc --chars ) -eq 1 && {
  padded_digit="${candidate_digit}"
 true
 } || {
  padded_digit="0${candidate_digit}"
 }
 echo "${padded_digit}"
}
#-------------------------------------------------
leading-digit() { { local number ; number="${1}" ; }
 ## debug
 #set -v -x
 #echo ${number}
 echo ${number:0:1}
 ## debug
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
   tee ${log_paths}/log.${path_name}.txt
  } || { # first path_pattern
   cat ${log} | 
   grep -e "${path_pattern}" | 
   tee ${log_paths}/log.${path_name}.txt
  }
 } || { # other
  cat ${log} |
  grep -v -e "${path_pattern_previous}" |
  tee ${log_paths}/log.${path_name}.txt
 }
}
#-------------------------------------------------
# log-stat-payload
# - sum line output
log-stat-payload() { { local log ; log="${1}" ; }
 local sum
 local path_line_no
 local total
 total=$( get-total-count )
 echo total: ${total}
 sum=0
 for path_line_no in $( get-path-line-range )
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
# log-stat-payload2
# - header data block output
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
 for path_line_no in $( get-path-line-range )
 do 
  path_line=$( print-path-line ${path} ${path_line_no} )
  path_name=${paths}.$( car ${path_line} )
  path_pattern=$( cdr ${path_line} )


  path_count=$( get-path-count )

  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }

  ## debug
  #echo ${path_line} : ${path_name} : ${path_pattern} : ${path_count} : ${path_pattern_previous} 1>&2

  test ${path_count} -eq 0 || {
   header="${header},$( echo ${path_name} | cut '-f2-' '-d.' )" 
   data="${data},${path_count}"
   sum=$(( ${sum} + ${path_count} ))
  }

  unset path_line
  unset path_name
  unset path_pattern

 done
 # get other path_count ##########################
 path_line=$( print-path-line ${path} ${path_line_no} )
 path_name=${paths}.other
 path_count=$( get-path-count ) 
 header="${header},$( echo ${path_name} | cut '-f2-' '-d.' )" 
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
combine-log-location() { { local log_location ; log_location="${1}" ; }
 find ${log_location} -type f -name \*.log \
	 | xargs cat 
}
#-------------------------------------------------
for-each-date() {
 local log
 local date
 test ! "${dates}" || {
  for date in ${dates}
  do
   ## debug
   #echo ${date}
   #continue
   ## test if directory
   test ! -d "${date}" || {
    log="log.txt"
    ## populate log
    combine-log-location ${date} > ${log}
    ## 1
    #{ 
    #  find ${date} -type f -name \*.log \
    #	      | xargs cat 
    #} > ${log}
    ## 0
    #cat ${date}/* > ${log}
    ## debug
    {
      echo log.txt
      du log.txt 
      head -n 3 log.txt
    } 1>&2
    ## debug\
    #read
    #cat ${log}
    log-stat-for-log "${log}" "${paths}"
   }
   read
  done
 }
}
#-------------------------------------------------
log-stat-for-date() { { local paths ; paths="${1-http}" ; local dates=${@:2} ; }
 ## debug
 #echo ${FUNCNAME}
 #echo paths: ${paths}
 #echo dates: ${dates}
 for-each-date
}
#-------------------------------------------------
log-stat-for-log-test() { 
 test -f "${log_paths}/${log}" || {
  error "log file '${log_paths}/${log}' does not exist" "${FUNCNAME}" "${LINENO}"
  false 
 }
}
#-------------------------------------------------
log-stat-for-log-payload() { 
 log-stat-payload2 ${log_paths}/${log} 
}
#-------------------------------------------------
log-stat-for-log-candidate-key() { 
 echo "${log}-$( car $( sha1sum ${log_paths}/${log} ) )-${paths}-$( car $( get-paths ${paths} | sha1sum ) )"
}
#-------------------------------------------------
log-stat-for-log() { { local log ; log="${1-log.txt}" ; local paths ; paths="${2-http}" ; } 
 ${FUNCNAME}-test

 ## debug
 {
   get-paths ${paths}
 } 1>&2


 #echo running log stat for log ${log} using ${paths} .. 1>&2
 {
   #cache \
   #"${cache}/$( ${FUNCNAME}-candidate-key )" \
   "${FUNCNAME}-payload"
 }
}
#-------------------------------------------------
log-stat-for() {
 commands
}
#-------------------------------------------------
log-stat-help() {
 cat << EOF
log-stat 

EOF
log-stat
}
#-------------------------------------------------
log-stat-combine-help() {
 cat << EOF
log-stat combine command - combines log files

USAGE

	log-stat combine directory

	directory	path of directory containing log files
EOF
}
#-------------------------------------------------
log-stat-combine-directory() {
 test -d "${log_location}"  || {
  error "directory '${log_location}' does not exist" "${FUNCNAME}" "${LINENO}"
  false
 }
 echo "combining log files at location '${log_location}'" 1>&2
 {
   find ${log_location} -type f \
   | xargs cat 
 }
}
#-------------------------------------------------
log-stat-combine() { { local log_location ; log_location="${1}" ; local log_output ; log_output=${2} ; }
 test "${log_location}" || {
  error "false"
  {
   ${FUNCNAME}-help
  } 1>&2
  false
 }

 test "${log_output}" || {
  log_output="${log_paths}/combined-$( date +%s ).txt"
 }

 { # comment me 
   ${FUNCNAME}-directory > ${log_paths}/${log_output} 
 } 
}
#-------------------------------------------------
log_paths=
log-stat-initialize-log-paths() { 
 log_paths="log-paths"
 test -d "${log_paths}" || {
   mkdir -v ${log_paths}
 }
}
#-------------------------------------------------
log-stat-initialize() { 
 ${FUNCNAME}-log-paths
}
#-------------------------------------------------
log-stat() { 
 ${FUNCNAME}-initialize
 commands
}
##################################################
if [ ! ]
then
 true
fi
##################################################
log-stat ${@}
##################################################
