#!/bin/bash
## sanitize
## - sanitize input string
## version 0.0.1 - initial
##################################################
shopt -s expand_aliases
alias sed-sanitize='sed -e "s/[^a-zA-Z0-9]//g"'
sanitize() { 
 echo "${@}" \
 | sed-sanitize
}
##################################################
if [ ! ] 
then
 true
else
 exit 1 # wrong args
fi
##################################################
{
  echo testing sanitization ... 
  echo "sanitize test 1 2 3 4 a B c d = '$( sanitize test 1 2 3 4 a B c d )'" 
} 1>&2
##################################################
