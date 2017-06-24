#!/bin/bash
## markdown
## - pl markdown wrapper
## version 0.0.2 - fix @ zenkaku space
## =to do=
## - check for markdown command  
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
convert-infile() {
 perl ${PL}/Markdown.pl ${infile} 
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
