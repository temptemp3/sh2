#!/bin/bash
## cdr
## - the rest
## =standalone=
## version 1.0.0 - nil successful exit status
##################################################
cdr() {
 echo ${cdr}
}
##################################################
if [ ${#} -ge 2 ] 
then
 cdr=${@:2}
elif [ ${#} -eq 1 ] 
then
 cdr="nil"
else
 exit 1 # wrong args
fi
##################################################
cdr
##################################################
