#!/bin/bash
## markdown 
## - pl markdown wrapper
## version 0.1.0 - exit on error, get-markdown-command
## =to do=
## - check for markdown command, mc
##  + use mc, primary
## - check for perl
##  + install Markdown.pl as mc
##     + use mc, secondary
## - allow override, may require entry modification
##  + use mc provided with interface, optional
##################################################
set -e # exit on error
##################################################
markdown() {
 test ! "${infile}" || {
  convert-infile
 }
 test ! "${input}" || {
  convert-input
 }
}
#-------------------------------------------------
test-markdown-command() {
 command markdown -V 2>/dev/null && {
  echo markdown
 }
}
#-------------------------------------------------
test-perl() {
 perl -v 2>/dev/null && {
 true
}
#-------------------------------------------------
test-markdown-global() {
 true
 # 1. return markdown if installed else
 # 1. download <http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip>, it
 # 1. test PL, if _ does not exist install _ in user home
 # 1. put it in PL
 # 1. install it
}
#-------------------------------------------------
test-markdown-global-command() {
 perl ${markdown} --version 2>/dev/null && {
  echo perl ${markdown}
 }
}
#-------------------------------------------------
markdown_command=
get-markdown-command() {
 markdown_command=$( 
  test-markdown-command ||
  test-perl || 
  test-markdown-global ||
  test-markdown-global-command ||
  false
 )
 test "${markdown_command}" 
}
#-------------------------------------------------
convert-infile() {
 perl ${PL}/Markdown.pl ${infile} # use Markdown.pl
}
#-------------------------------------------------
convert-input() { 
 echo ${input} | 
 perl ${PL}/Markdown.pl
}
##################################################
## $1 - file name
##################################################
if [ ${#} -eq 1 -a -f "${1}" ]
then 
 infile="${1}"
elif [ ${#} -gt 0 ]
then
 input="${@}"
else
 exit 1 # wrong args
fi
##################################################
markdown
##################################################
