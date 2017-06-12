#!/bin/bash
## u2.sh - update html v2
## version 0.1.0 - html
##################################################
set -e # exit on error
##################################################
markdown() { ${SH}/markdown.sh ${@} 2>/dev/null ; }
##################################################
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
get-all-files() {
 if-config-ignore
 git ls-files | 
 grep \
  --invert-match \
  --file=config/ignore
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
get-files() { 
 files=$(
  cat << EOF
index
$( get-index-files )
$( get-untracked-files )
EOF
)

 #################################################
 ## prevent duplicates of index ##################
 files=$(
  echo ${files} | sed -e 's/\s/\n/g' | uniq
 )
 #################################################

 test ! $( echo ${files} | wc --words ) -eq 1 || {
  files=$(
   get-all-files
  )
 }
 echo "${files}"
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
file-convert-to-html() {
 echo -n "converting $( file-basename ) to html ..."
 cat > html/$( file-basename ).html << EOF
<!DOCTYPE html>
<html>
<head>
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
