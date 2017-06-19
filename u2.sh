#!/bin/bash
## u2.sh - update html v2
## version 0.2.0 - get-files-fallback
## =to do=
## - strip html comments
##################################################
set -e # exit on error
##################################################
markdown() { ${SH}/markdown.sh ${@} 2>/dev/null ; }
file_mime_encoding() { ${SH}/file-mime-encoding.sh ${@} ; }
##################################################
_cleanup() {
 rm navigation* --verbose
}
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
h1() { { local text ; text="${@}" ; }
 markdown "# ${text}" 
}
#-------------------------------------------------
process-navigation() {
 echo index
 local el
 for el in ${navigation}
 do
  test ! "${el}" = "index" || {
   continue
  }
  echo ${el}
 done
}
#-------------------------------------------------
get-navigation() {
 local navigation
 navigation=$(
  for-each-file echo 
 )
 test "${navigation}"
 process-navigation > navigation-base
}
#-------------------------------------------------
navigation=
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
   sed -e 's/\(.*\)/- [\1](\1.html)/' navigation-base > navigation 
   navigation=$( 
    markdown navigation
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
 git ls-files
}
#-------------------------------------------------
git-show-name-only() { { local depth ; depth="${1}" ; }
 git show --name-only $( git-show-name-only-if-depth ${depth} )
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
 grep \
  --invert-match \
  --file=config/ignore
}
#-------------------------------------------------
get-all-files() { 
 # get get-all-files behavior from config later
 get-all-files-show-name-only || # default
 get-all-files-git-ls-files ||
 false # exit on git-ls-files failure
}
#-------------------------------------------------
get-untracked-files() {
 git status --short |
 grep -e '^[?]' |
 gawk '{print $(2)}'
}
#-------------------------------------------------
get-index-files() {
 git ls-files --modified
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
 echo "${files}"
}
#-------------------------------------------------
get-files() { 
 get-files-default-behavior
 get-files-filter
 get-files-fallback
 get-files-output
}
#-------------------------------------------------
for-each-file() { { local function ; function="${1}" ; }
 local file
 for file in ${files}
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
 echo ${file} ${charset} 1>&2
 case ${charset} in
  SHIFT_JIS)	echo Shift_JIS ;;
  utf-8) 	echo UTF-8 ;;
  us-ascii) 	echo US-ASCII ;;
  *)		echo ISO-8859-1 ;;
 esac 
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
file-convert-to-html() {
 echo -n "converting $( file-basename ) to html ..."
 cat > html/$( file-basename ).html << EOF
<!DOCTYPE html>
<html>
<head>
$( file-charset )
<title>$( file-basename )</title>
<style>
div#header ul li {
 display: inline ;
}
</style>
</head>
<body>
<div id="header">
${navigation} 
</div>
$( h1 $( file-basename ) )
$( file-the-content )
<div id="footer">
${navigation}
</div>
</body>
</html>
EOF
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
initialize-directories() {
 if-config
 if-html 
}
#-------------------------------------------------
initialize() {
 initialize-directories
}
#-------------------------------------------------
start-prompt() {
 cat << EOF
=u2=
number of files: $( echo ${files} | wc --words )
(press enter to start)
EOF
 read
}
#-------------------------------------------------
u2-list() {
 initialize
 get-files # ${files}
 start-prompt
 generate-navigation # ${navigation}
 for-each-file convert-to-html # > *.html
 _cleanup
}
#-------------------------------------------------
u2() { 
 u2-list
}
##################################################
if [ ${#} -eq 0 ] 
then
 true
else
 exit 1 # wrong args
fi
##################################################
u2
##################################################
