#!/bin/bash
## log-stat
## - breakdown log by path
## version 1.4.0 - add worker, temp, etc
## =to do=
## (11 Jul 2019)
## + json output
## + expand all expressions before loop
## (6 Apr 2018)
## + allow path file comments
## (5 Apr 2018)
## + hide row if other equals sum 
##################################################
. $( dirname ${0} )/temp.sh	# temp
. $( dirname ${0} )/error.sh	# error handling
error "true"			# show errors
_cleanup() {
  test ! "$( temp this )" || {
    cecho yellow $( rm -vf "$( temp this )*" )
  }
}
. $( dirname ${0} )/cache.sh	# cache
. $( dirname ${0} )/aliases/commands.sh # commands
. $( dirname ${0} )/cecho.sh	# colored echo
##################################################
shopt -s expand_aliases
alias sed-remove-double-quotes='sed -e "s/\"//g"'
alias bind-variables='
{
  local cache_ts
  local log_paths
}
'
##################################################
car() { $( dirname ${0} )/car.sh ${@} ; }
cdr() { $( dirname ${0} )/cdr.sh ${@} ; }
##################################################
# args_hash=
# paths_hash=
##################################################
args_hash=$( car $( echo "${@}" | sha1sum ) )
test ! -d "$( dirname ${0} )/paths" || {
  ## files in paths
  paths_hash=$( car $( cat $( dirname ${0} )/paths/* | sha1sum ) )
  {
    echo importing paths $( echo $( dirname ${0} )/paths/*.sh ) ..
  } 1>&2 &>/dev/null
  for path_file in $( find $( dirname ${0} )/paths -type f -name \*.sh )
  do
   . ${path_file}
  done
}
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
  cdr $( seq $( get-path-lines ) )
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
  echo ${number:0:1}
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
#-------------------------------------------------
log-stat-payload-foreach-iter() { 
  local path_line
  local path_name
  local path_pattern
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
}
#-------------------------------------------------
log-stat-payload() { { local log ; log="${1}" ; }
  local sum
  local path_line_no
  local total
  total=$( get-total-count )
  echo total: ${total}
  sum=0
  for path_line_no in $( get-path-line-range )
  do 
   ${FUNCNAME}-foreach-iter
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
  {
    cat $( temp global )-out \
    | sort --numeric-sort --reverse \
    | ${FUNCNAME}-gawk
  } | tr ',' '\t'
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
  ##-----------------------------------------------
  test ! -f "$( temp global )-out" || rm -vf ${_}
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
    ##---------------------------------------------
    cat >> $( temp global )-out << EOF
${total} total $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
    ##---------------------------------------------
  }

}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-path-count() { 
  #path_count=$( get-path-count )
  test ! -f "$( temp global )-${path_name}.count" && {
   path_count="0"
  true 
  } || {
   path_count=$( cat ${_} )
  }
  cecho yellow "path_count: ${path_count}"
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-line() { 
  path_line=$( print-path-line ${path} ${path_line_no} )
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-name() { 
  path_name=${paths}.$( car ${path_line} )
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-pattern() { 
  path_pattern=$( cdr ${path_line} )
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-work-1() { 
  cat << EOF
get-path-count ${log} ${path_name} ${path_pattern} ${path_pattern_previous}
EOF
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-work-2() { 
  cat << EOF
get-latency log.${path_name}.txt
EOF
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-work() { 
  ${FUNCNAME}-1
  ${FUNCNAME}-2
}
#-------------------------------------------------
log-stat-payload2-for-each-path-if-count() {
  test ! ${path_count} -eq 0 || { true ; return ; }
 
  local latency
  #get-latency-using-path-name
  latency=$( cat $( temp global )-log.${path_name}.txt.latency )

  path_name_simple="$( echo ${path_name} | cut '-f2-' '-d.' )"
  header="${header},${path_name_simple}" 
  data="${data},${path_count}"
  sum=$(( ${sum} + ${path_count} ))
  remaining=$(( ${remaining} - ${path_count} ))

  ##---------------------------------------------
  ## add path to temp file
  ##---------------------------------------------
  cat >> $( temp global )-out << EOF
${path_count} ${path_name_simple} $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
  ##---------------------------------------------
}
#-------------------------------------------------
log-stat-payload2-for-each-path-on-remaining() { 
  echo remaining: ${remaining} 1>&2
  test ! ${remaining} -eq 0 || false # break
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-previous-path() { 
  test "${path_pattern_previous}" && {
   path_pattern_previous="${path_pattern_previous}\|\(${path_pattern}\)" 
  true
  } || {
   path_pattern_previous="\(${path_pattern}\)" 
  }
  cecho yellow "path_pattern_previous: ${path_pattern_previous}"
}
#-------------------------------------------------
payload2-foreach() { { local function_name ; function_name="${1}" ; }
  local path_line
  local path_name
  local path_pattern
  local path_count
  local path_name_simple
  local path_line_no
  for path_line_no in $( get-path-line-range )
  do
   ${function_name}
  done
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-1() { 
  log-stat-payload2-for-each-path-setup-line
  log-stat-payload2-for-each-path-setup-name
  log-stat-payload2-for-each-path-setup-pattern
  log-stat-payload2-for-each-path-setup-work-1
  log-stat-payload2-for-each-path-setup-previous-path  
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-2() { 
  log-stat-payload2-for-each-path-setup-line
  log-stat-payload2-for-each-path-setup-name
  log-stat-payload2-for-each-path-setup-work-2
}
#-------------------------------------------------
log-stat-payload2-for-each-path-setup-3() { 
  log-stat-payload2-for-each-path-setup-line
  log-stat-payload2-for-each-path-setup-name
  log-stat-payload2-for-each-path-setup-path-count
  log-stat-payload2-for-each-path-if-count
}
#-------------------------------------------------
log-stat-payload2-for-each-path() { 

  {
    local path_line
    local path_name
    local path_pattern
    local path_count
    local path_name_simple
    local path_line_no
  }

  #-----------------------------------------------
  # setup for work
  #-----------------------------------------------
  _() {
    payload2-foreach log-stat-payload2-for-each-path-setup-1
  }
  {
    cache \
    "${cache}/${paths_hash}-${args_hash}-${FUNCNAME}-work-1" \
    "_"
  } | tee $( temp global )-${paths}.work 1>&2
  #-----------------------------------------------
  _() {
    payload2-foreach log-stat-payload2-for-each-path-setup-2
  }
  {
    cache \
    "${cache}/${paths_hash}-${args_hash}-${FUNCNAME}-work-2" \
    "_"
  } | tee $( temp global )-${paths}.work2 1>&2
  #-----------------------------------------------

  #-----------------------------------------------
  # work
  # get path counts
  # get latencies
  #-----------------------------------------------
  ${0} worker $( temp global )-${paths}.work 100
  ${0} worker $( temp global )-${paths}.work2 100
  #-----------------------------------------------

  #-----------------------------------------------
  # use work ***
  #-----------------------------------------------
  for path_line_no in $( get-path-line-range )
  do 
   log-stat-payload2-for-each-path-setup-3
  done
  #-----------------------------------------------


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
 ##-----------------------------------------------
 cat >> $( temp global )-out << EOF
${path_count} ${path_name_simple} $( latency-sum ${latency} ) $( latency-avg ${latency} )
EOF
 ##-----------------------------------------------

 ##-----------------------------------------------
 ## add sum
 ##-----------------------------------------------
 header="${header},sum"
 data="${data},${sum}"
 ##-----------------------------------------------

}
#-------------------------------------------------
log-stat-payload2() { { local log ; log="${1}" ; }
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
    #error "log file '${log_paths}/${log}' does not exist" "${FUNCNAME}" "${LINENO}"
    error "false"
    log-stat-for-log-help 1>&2
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
log-stat-for-log-help() { 
  cat << EOF

log-stat for log LOG PATH

INPUT
	1 - LOG, name of file in log-paths
	2 - PATH, name of path (default: http)
OUTPUT
	LOG, total
	PATH, ####
	latency-sum, ####.##
	latency-avg, ##.####
EOF
}
#-------------------------------------------------
log-stat-for-log() { { local log ; log="${1-log.txt}" ; local paths ; paths="${2-http}" ; } 
 ${FUNCNAME}-test

 ## debug paths
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
 #sum+=(int($(7)*1000))
 #
 sum+=($(7)*1000)
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
 latency=$( get-latency $( basename ${log} ) )
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
  get-latency ${log} | tee $( temp global )-${log}.latency 1>&2
}
#-------------------------------------------------
log-stat-get-path-count() { { local log ; log="${1}" ; local path_name ; path_name="${2}" ; local path_pattern ; path_pattern="${3}" ; local path_pattern_previous ; path_pattern_previous="${4}" ; }
  cecho yellow "log: ${log}"
  cecho yellow "path_name: ${path_name}"
  cecho yellow "path_pattern: ${path_pattern}"
  cecho yellow "path_pattern_previous: ${path_pattern_previous}"
  get-path-count | tee $( temp global )-${path_name}.count 1>&2
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
log-stat-initialize-log-paths() { 
  log_paths="log-paths"
  test -d "${log_paths}" || {
    mkdir -v ${log_paths}
  }
}
#-------------------------------------------------
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
log-stat-testing() { 
  log="access-log-2019-07-14"
  echo log-stat-for-log ${log}
  log-stat-for-log ${log}
}
#-------------------------------------------------
log-stat-worker() { { local infile ; infile="${1}" ; local -i concurrency ; concurrency="${2-1}" ; }
  if-concurrency() {
    test ! ${concurrency} -gt 1 || {
      echo "-P ${concurrency}"
      cecho yellow "concurrency: ${concurrency}"
    }
  }
  cecho green "doing work on $( cat ${infile} | wc -l ) jobs ..."
  time { 
    cat ${infile} | 
    xxd -ps | 
    sed 's/0a/00/g' | 
    xxd -ps -r | 
    xargs $( if-concurrency ) -0 -i bash ${0} {}
  }
  cecho green "done doing work"
}
#-------------------------------------------------
log-stat() {
  bind-variables
  cecho yellow $( declare -p temp )
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
