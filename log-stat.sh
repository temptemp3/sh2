#!/bin/bash
## log-stat
## - breakdown log by path
## version 1.3.3 - silence combine log message
## =to do=
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
shopt -s expand_aliases
. $( dirname ${0} )/aliases/commands.sh
alias sed-remove-double-quotes='sed -e "s/\"//g"'
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

 ## debug leading digit start
 #set -v -x
 #echo ${number}

 echo ${number:0:1}

 ## debug leading digit end
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
# version 0.0.2 - output sorted by path hit count
#-------------------------------------------------
log-stat-payload2-output-unsorted() { 
 ## output not sorted by path count
 cat << EOF
${header}
${data}
EOF
}
#-------------------------------------------------
log-stat-payload2-output-sorted-gawk() { 
 gawk -v paths=${paths} -v log_basename=$( basename ${log} .txt ) '
BEGIN {
 header=log_basename
 data=paths
 data2="latency-sum"
 data3="latency-avg"
}
//{
 header=header","$(2)
 data=data","$(1)
 data2=data2","$(3)
 data3=data3","$(4)
}
END {
 print header
 print data
 print data2
 print data3
}
'
}
#-------------------------------------------------
log-stat-payload2-output-sorted() { 
 ## output sorted by path count
 ## convert out to header data line
 #echo testing ...
 cat out \
 | sort --numeric-sort --reverse \
 | ${FUNCNAME}-gawk
}
#-------------------------------------------------
log-stat-payload2-output() { 
 local using
 using="sorted"
 case ${using} in
  sorted) {
   ${FUNCNAME}-sorted
  } ;;
 esac
}
#-------------------------------------------------
log-stat-payload2-initialize() { 

 ##-----------------------------------------------
 ## initialize temp file
 test ! -f "out" || {
  rm out
 }
 ##-----------------------------------------------

 { ## initialization
   total=$( get-total-count )
   header="total"
   data="${total}"
   sum=0
   remaining=${total}

   {
     local latency
     get-latency-using-log-basename
   }

   ##---------------------------------------------
   ## add total to temp file
   cat >> out << EOF
${total} total $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
   ##---------------------------------------------
 }

}
#-------------------------------------------------
log-stat-payload2-for-each-path-do-setup() { 

  path_line=$( print-path-line ${path} ${path_line_no} )
  path_name=${paths}.$( car ${path_line} )
  path_pattern=$( cdr ${path_line} )
  path_count=$( get-path-count )

  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  true
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }
}
#-------------------------------------------------
log-stat-payload2-for-each-path-do-if-count() {

  test ${path_count} -eq 0 || {
 
   {
     local latency
     get-latency-using-path-name
   }

   path_name_simple="$( echo ${path_name} | cut '-f2-' '-d.' )"
   header="${header},${path_name_simple}" 
   data="${data},${path_count}"
   sum=$(( ${sum} + ${path_count} ))
   remaining=$(( ${remaining} - ${path_count} ))

   ##---------------------------------------------
   ## add path to temp file
   cat >> out << EOF
${path_count} ${path_name_simple} $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
   ##---------------------------------------------

  }
}
#-------------------------------------------------
log-stat-payload2-for-each-path-do-debug() { 
 echo ${path_line} : ${path_name} : ${path_pattern} : ${path_count} : ${path_pattern_previous} 1>&2
}
#-------------------------------------------------
log-stat-payload2-for-each-path-do-on-remaining() { 
  echo remaining: ${remaining} 1>&2
  test ! ${remaining} -eq 0 || {
   break
  }
}
#-------------------------------------------------
log-stat-payload2-for-each-path-do() { 

  {
    local path_line
    local path_name
    local path_pattern
    local path_count
    local path_name_simple
  }

  ${FUNCNAME}-on-remaining
  ${FUNCNAME}-setup
  #${FUNCNAME}-debug
  ${FUNCNAME}-if-count
}
#-------------------------------------------------
log-stat-payload2-for-each-path() { 

 local path_line_no
 for path_line_no in $( get-path-line-range )
 do 
  ${FUNCNAME}-do
 done
}
#-------------------------------------------------
log-stat-payload2-special-paths() { 

 ## post loop paths

 ##-----------------------------------------------
 ## get other path_count 
 path_name=${paths}.other
 path_name_simple="$( echo ${path_name} | cut '-f2-' '-d.' )"
 path_count=$( get-path-count ) 
 header="${header},${path_name_simple}"
 data="${data},${path_count}"
 sum=$(( ${sum} + ${path_count} ))  
 remaining=$(( ${remaining} - ${path_count} ))
 ##-----------------------------------------------

 {
   local latency
   get-latency-using-path-name   
 }

 ##-----------------------------------------------
 ## add path to temp file
 cat >> out << EOF
${path_count} ${path_name_simple} $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
 ##-----------------------------------------------

 ##-----------------------------------------------
 ## add sum
 header="${header},sum"
 data="${data},${sum}"
 ##-----------------------------------------------

}
#-------------------------------------------------
log-stat-payload2() { { local log ; log="${1}" ; }
 
 #echo log: ${log} 1>&2


 { 
   local sum
   local total
   local remaining
   local header
   local data
 }

 ${FUNCNAME}-initialize
 ${FUNCNAME}-for-each-path
 ${FUNCNAME}-special-paths
 ${FUNCNAME}-output

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

   ## debug date
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

    ## debug log
    {
      echo log.txt
      du log.txt 
      head -n 3 log.txt
    } 1>&2

    ## debug log output
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

 ## debug for date args
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

 ## debug paths
 {
   get-paths ${paths}
 } 1>&2


 ## debug
 #set -v -x
 #echo ${cache}/$( ${FUNCNAME}-candidate-key )
 #set +v +x
 #read

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
 #echo "combining log files at location '${log_location}'" 1>&2
 {
   find ${log_location} -type f \
   | xargs cat 
 }
}
#-------------------------------------------------
get-latency-gawk() { 
 gawk '
BEGIN {
 # latency(ms) sum
 sum=0 
}
//{
 ## floored
 #sum+=(int($(6)*1000))
 #
 sum+=($(6)*1000)
}
END {
 sum_sec=( sum / 1000 ) # converted back to seconds

 if(NR!=0) { # prevent divide by zero error
  avg_sec=( sum_sec / NR ) 
 } else {
  avg_sec=0
 }

 ## json
 print "{"
 print "\"sum\":" ( sum_sec ) ","
 print "\"avg\":" ( avg_sec ) 
 print "}"
}
'
}
#-------------------------------------------------
get-latency-gawk2() { 
 gawk '
//{
 print "{" "\"ts\":" "\"" $(1) "\"" "," "\"lat\":" $(6) "}"
}
'
}
#-------------------------------------------------
latency-avg() { { local json ; json=${@} ; }
 echo ${json} | jq '.avg'
}
#-------------------------------------------------
latency-sum() { { local json ; json=${@} ; }
 echo ${json} | jq '.sum'
}
#-------------------------------------------------
get-latency-using-path-name() {
 latency=$( 
  get-latency "log.${path_name}.txt"
 )
}
get-latency-using-log-basename() {
 latency=$( 
   get-latency $(
    basename ${log}
   )
  )
}
get-latency() { { local log ; log="${1}" ; }
  test "${log}"
  _() {
    test -f "${1}"
    ## debug
    #echo ${1}
    #head -n 5 ${1}
    cat ${1}
  }
  { 

    ## return sum avg
    # =sample output=
    #{
    #	"sum":1051.44,
    #	"avg":0.134938
    #}
    _ "${log_paths}/${log}" | ${FUNCNAME}-gawk 

    return

    ## list ts_lat
    local ts_raw
    local lat_raw
    for ts_lat in $( _ "${log_paths}/${log}" | ${FUNCNAME}-gawk2 )
    do
     #echo ${ts_lat}
     ts_raw=$( echo ${ts_lat} | jq '.ts' | sed-remove-double-quotes )
     #echo ${ts_raw}
     lat_raw=$( echo ${ts_lat} | jq '.lat' )
     echo "${lat_raw} $( date --date=${ts_raw} +%X )" &
    done
    wait
  }
}
#-------------------------------------------------
log-stat-get-latency() { { local log ; log="${1}" ; }
 get-latency ${log}
}
#-------------------------------------------------
log-stat-get() {
 commands
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
cache_ts=
log-stat-initialize-cache-ts() { 
 cache_ts=$(
  date +%s | sed -e 's/.\{5\}$/00000/'
 )
}
#-------------------------------------------------
log-stat-initialize() { 
 ${FUNCNAME}-log-paths
 ${FUNCNAME}-cache-ts
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
