#!/bin/bash
## u2.sh - update hwip, error, imports, temp, charset
## version 0.3.0 - true
##################################################
## get bloginfo
test ! -f "bloginfo" || {
 rm bloginfo
}
touch bloginfo
for info in $( find config -type f -name bloginfo-\* | grep -v -e '~' )
do
 {
   echo $( basename ${info} ) $( cat ${info} ) 
 } |  tee -a bloginfo &>/dev/null
done
##################################################
. ${SH2}/error.sh 		# error handling
. ${SH2}/aliases/commands.sh 	# commands
. ${SH2}/cecho.sh		# colored echo
##################################################
file_mime_encoding() { ${SH2}/file-mime-encoding.sh ${@} ; }
generate_temp() { ${SH}/generate-temp.sh ${@} ; }
markdown() { ${SH}/markdown.sh ${@} 2>/dev/null ; }
##################################################
_cleanup() { 
 #rm navigation* --verbose || true
 test ! "${temp}" || {
  rm ${temp}* -rvf
 }
}
#-------------------------------------------------
cdr() { echo ${@:2} ; }
#-------------------------------------------------
if-directory() { { local candidate_directory ; candidate_directory="${1}" ; }
 test -d "${candidate_directory}" || {
  mkdir ${candidate_directory} --verbose
 }
}
#-------------------------------------------------
if-html() {
 if-directory "html"
}
#-------------------------------------------------
if-config() {
 if-directory "config"
}
#-------------------------------------------------
if-config-ignore() {
 test -f "config/ignore" || {
  touch config/ignore
 }
}
#-------------------------------------------------
process-navigation() {
 #echo index
 local el
 for el in ${navigation}
 do
  test ! "${el}" = "index" || {
   continue
  }
  ###***

  echo ${el}
 done
}
#-------------------------------------------------
#
# - may refactor later using navigation-base instead
#   of barebone 
#
navigation=
get-navigation() {
 local navigation
 navigation=$(
  for-each-file echo 
 )
 test "${navigation}"
 {
   process-navigation
 } >  ${temp}-navigation-base
}
#-------------------------------------------------
generate-navigation() {
 echo -n "generating navigation ..."
 get-navigation & # > navigation-base
 local jobs_running
 while [ ! ]
 do
  jobs_running="$( jobs -pr )"
  test "${jobs_running}" || {
   echo ""

   ###############################################
   ## convert navigation to markdown list       ##
   ## < navigation-base > navigation            ##
   ## ${navigation}                             ##
   #sed -e 's/\(.*\)/- [\1](\1.html)/' navigation-base > navigation 
   sed -e 's/\(.*\)/\1/' ${temp}-navigation-base > ${temp}-navigation 
   #navigation=$( 
   # markdown navigation
   #)
   #######################
   #                     #
   # barebone navigation #
   #                     #
   #######################
   navigation=$(
    cat ${temp}-navigation
   )
   ###############################################

   break
  }
  echo -n "."
  sleep 1
 done
}
#-------------------------------------------------
car() {
 echo ${1}
}
#-------------------------------------------------
git-show-name-only-lines() { { local depth ; depth="${1}" ; }
 local lines
 lines=$( 
  git-show-name-only ${depth} |
  tac |
  gawk '
   /^$/{
    print NR
   }
  '
 )
 test "${lines}" && {
  car ${lines}
 }
}
#-------------------------------------------------
git-show-name-only-if-depth() { { local depth ; depth="${1}" ; }
 case ${depth} in
  0) { 
   echo "HEAD" 
  } ;;
  1*|2*|3*|4*|5*|6*|7*|8*|9*) { 
   echo "HEAD~${depth}" 
  } ;;
  *) false || {
   false # exit on invalid depth
  } ;;
 esac
}
#-------------------------------------------------
git-ls-files() {
 git ls-files docs
}
#-------------------------------------------------
git-show-name-only() { { local depth ; depth="${1}" ; }
  {
    git show --name-only $( git-show-name-only-if-depth ${depth} ) docs \
    | grep -v -e 'html'
  }
}
#-------------------------------------------------
get-all-files-show-name-only-single() { { local depth ; depth="${1}" ; }
 git-show-name-only ${depth} | 
 tac | 
 head -n $( git-show-name-only-lines ${depth} )
}
#-------------------------------------------------
get-all-files-show-name-only-all() {
 for step in {0..5} # read from config later 
 do
  get-all-files-show-name-only-single ${step}
 done 
}
#-------------------------------------------------
get-all-files-show-name-only() { 
 echo $( get-all-files-show-name-only-all ) | 
 sed \
  -e 's/\s/\n/g' |
 gawk ' # rank files by number of times updated 
  BEGIN {
   HASH[0]=0
  }
  // {
   if(!HASH[$(0)]) {
    HASH[++HASH[0]]=$(0)
    HASH[$(0)]=0
   }
   HASH[$(0)]++
  }
 END {
  for(i=1;i<HASH[0];i++) { 
   print HASH[HASH[i]] " " HASH[i]
  }
 } 
 ' | 
 sort --numeric-sort --reverse |
 gawk ' # throw away files not updated after creation
  // {
   if($(1)>1) { # file updated more than once
    print $(2)
   }
  }
 ' |
 uniq |
 head -n 50 # read from config later
}
#-------------------------------------------------
get-all-files-git-ls-files() {
 if-config-ignore
 git-ls-files | 
 grep -e '^docs\/' |
 grep \
  --invert-match \
  --file=config/ignore
}
#-------------------------------------------------
get-all-files() { 
 # get get-all-files behavior from config later
 get-all-files-git-ls-files ||
 #get-all-files-show-name-only || # !default
 false # exit on git-ls-files failure
}
#echo getting all files ..
#sleep 1
#get-all-files
#exit
#-------------------------------------------------
get-untracked-files() {
 git status --short |
 grep -e '^[?]' |
 gawk '{print $(2)}' |
 grep \
  -e 'docs' |
 grep -v \
  -e '[.]html$' \
  -e '\/[.]'
}
#-------------------------------------------------
get-index-files() {
 git ls-files --modified |
 grep \
  -e 'docs' |
 grep -v \
  -e 'html' \
  -e '\/[.]'
}
#-------------------------------------------------
files=
get-files-default-behavior() {
 files=$(
  cat << EOF
docs/index
$( get-index-files )
$( get-untracked-files )
EOF
 )
 test "${files}"
}
#-------------------------------------------------
get-files-filter() {
 #################################################
 ## prevent duplicates of index                  #
 ## i.e. when index is modified or created       #
 files=$(
  echo ${files} | 
  sed -e 's/\s/\n/g' | 
  sort | # (1) uniq depends on sorted lines
  uniq
 )
 #################################################
}
#-------------------------------------------------
get-files-fallback() {
 # files fallback
 # case ${files} = docs/index
 test ! $( echo ${files} | wc --words ) -eq 1 || {
  files=$(
   get-all-files
  )
 }
}
#-------------------------------------------------
get-files-output() { 
 local file
 files=$(
  for file in ${files}
  do
   #-----------------------------------------------
   # ignore hidden
   cat ${file} | grep -e 'visibility:hidden' &>/dev/null && {
    #----------------------------------------------
    # on hidden doc
    #local candidate_hidden_doc_html
    #candidate_hidden_doc_html="html/$( basename ${file} ).html" 
    #test ! -f "${candidate_hidden_doc_html}" || {
    # rm ${candidate_hidden_doc_html} --verbose 1>&2
    # file-hidden-html > ${candidate_hidden_doc_html}
    #}
    #----------------------------------------------
   true 
   } || { # not hidden
    echo ${file}
   }
   #-----------------------------------------------
  done
 )
}
#-------------------------------------------------
files_hidden=
get-files-hidden() { 
 files_hidden=$( 
  local file
  for file in $( git ls-files | grep -e '^docs' )
  do
   test ! -f "${file}" || {
    cat ${file} | grep -e 'visibility:hidden' &>/dev/null && { true ; 
     echo ${file}
    true
    } || { 
     true # not hidden file
    }
   }
  done
 )
 echo files_hidden: ${files_hidden}
}
#-------------------------------------------------
get-files() { 
 get-files-default-behavior
 cecho yellow "files (prefilter): ${files}"	# prefilter files
 cecho yellow $( echo "${files}" | wc )		# wc files
 get-files-filter 				# filter files
 #get-files-fallback
 #get-files-output
 cecho yellow "files (final): ${files}"		# final files
 cecho yellow $( echo "${files}" | wc )		# wc files
 echo "${files}"
}
#get-files
#exit
#-------------------------------------------------
which-files() { { local files_name ; files_name="${1}" ; }
 case ${files_name} in
  hidden) echo ${files_hidden} ;;
  *) echo ${files} ;;
 esac
}
#-------------------------------------------------
for-each-file() { { local function ; function="${1}" ; local files_name ; files_name="${2}" ; }
 local file
 for file in $( which-files ${files_name} )
 do
  file-${function} ${file} &
 done
 local jobs_running
 while [ ! ]
 do
  jobs_running="$( jobs -pr )"
  test "${jobs_running}" || {
   # no more jobs
   break
  }
  sleep 1
 done
}
#-------------------------------------------------
file-basename() {
 basename ${file}
}
#-------------------------------------------------
file-cat() {
 cat ${file}
}
#-------------------------------------------------
file-the-content() {
 markdown ${file}
}
#-------------------------------------------------
file-charsets() { { local charset ; charset="${1}" ; }
 case ${charset} in
  SHIFT_JIS)	echo Shift_JIS ;;
  utf-8) 	echo UTF-8 ;;
  us-ascii) 	echo US-ASCII ;;
  *)		echo ISO-8859-1 ;;
 esac 
}
#-------------------------------------------------
meta-charset() {  { local charset ; charset="${1}" ; }
 true #todo
}
#-------------------------------------------------
file-charset() {
 local charset
 charset=$( file-charsets $( file_mime_encoding ${file} ) )
 cat << EOF
<meta charset="${charset}">
EOF
}
#-------------------------------------------------
if-global-meta() {
 test ! -d "meta"
}
#-------------------------------------------------
get-global-meta() {
 local meta_key
 local meta_value
 for meta_key in $( find meta -type f -name meta-\* )
 do
  echo ${meta_key} 1>&2
  meta_value=$( cat ${meta_key} )
  echo ${meta_value}
 done
}
#-------------------------------------------------
theme="default" # move to config
#-------------------------------------------------
file-get-mime-encoding() {
 cat << EOF
$( basename ${file} ) $( file_mime_encoding ${file} )
EOF
}
#-------------------------------------------------
file-template() {
 # todo: replace file-error-404, file-convert-to-html
 true
}
#-------------------------------------------------
file-error-404() { 
 echo generating html for $( basename ${file} ) ... 1>&2
 local candidate_theme
 candidate_theme="theme/${theme}/error-404-html.sh"
 test ! -f "${candidate_theme}" || {
  ${candidate_theme} ${file} "bloginfo" ${navigation} > html/$( file-basename ).html 
 }
}
#-------------------------------------------------
file-convert-to-html-mime-encoding-utf8() {
 #-----------------------------------------------
 # convert all doc html to utf-8 
 #-----------------------------------------------
 {
   {
     ${candidate_theme} \
     ${file} \
     "bloginfo" \
     ${navigation} 
   } > ${temp}-$( file-basename ).html
   {
     iconv \
     -f $( file_mime_encoding ${file} ) \
     -t utf-8 \
     ${temp}-$( file-basename ).html 
   } | tee html/$( file-basename ).html 
 }
 #-----------------------------------------------
}
#-------------------------------------------------
file-convert-to-html() {
 cecho green generating html for $( basename ${file} )
 local candidate_theme
 candidate_theme="theme/${theme}/doc-html.sh"
 test ! -f "${candidate_theme}" || {
  ${FUNCNAME}-mime-encoding-utf8
 }
}
#-------------------------------------------------
file-echo() {
 file-basename
}
#-------------------------------------------------
file-generate-link() {
 markdown "- [$( file-basename )]($( file-basename ).html)"
}
#-------------------------------------------------
categories=
initialize-bloginfo-categories() {
 
 local category
 for category in $( find config -type f -name category-\* )
 do
  categories="${categories} $( basename ${category} | cut "-f2-" "-d-" )"
 done 
	
}
#-------------------------------------------------
initialize-bloginfo() {
 ${FUNCNAME}-categories
}
#-------------------------------------------------
initialize-directories() {
 if-config
 if-html 
}
#-------------------------------------------------
temp=
initialize-temp() {
  temp=$(
    generate_temp $( basename ${0} .sh )
  )
  cecho yellow "temp: ${temp}"
  sleep 1
}
#-------------------------------------------------
initialize() {
 ${FUNCNAME}-temp
 ${FUNCNAME}-directories
 ${FUNCNAME}-bloginfo
}
#-------------------------------------------------
start-prompt() {
 cat << EOF
=u2=
number of files: $( echo ${files} | wc --words )
(press enter to start)
EOF
 # manual break
 #read
}
#-------------------------------------------------
list() {
 #------------------------------------------------
 # initialize temp and directories
 #------------------------------------------------
 initialize
 #------------------------------------------------
 #echo manual break 1>&2
 #echo ${categories}
 #exit
 #------------------------------------------------
 get-files # ${files}
 #echo "files: ${files}"
 #read
 #------------------------------------------------
 # output encoding for all files
 for-each-file get-mime-encoding 
 # manual break
 #read 
 #------------------------------------------------
 #echo ${files}
 #echo manual break ; false ;
 #------------------------------------------------
 get-files-hidden # ${files_hidden}
 start-prompt
 #------------------------------------------------
 #echo manual break 1>&2
 #exit
 #------------------------------------------------
 { # ${navigation}
   generate-navigation
 }
 { # > *.html
   for-each-file \
   convert-to-html 
 }
 #------------------------------------------------
 # manual break
 #read
 #------------------------------------------------
 [ ! ] || {
   for-each-file \
   error-404 hidden
 }
 #------------------------------------------------
 # sync css
 #------------------------------------------------
 {
   cp -rvf css html/
 }
 #------------------------------------------------
 #_cleanup
 #------------------------------------------------
}
#-------------------------------------------------
prompt() {
 echo press any key to continue
 # manual break
 read
}
#-------------------------------------------------
u2-build() {
 #prompt
 list
}
#-------------------------------------------------
u2-true() { 
  true
}
#-------------------------------------------------
u2() { 
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
u2 ${@}
##################################################
