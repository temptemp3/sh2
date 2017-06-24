#!/bin/bash
## cdr
## - the rest
## =standalone=
## version 0.0.1 - initial
##################################################
cdr() {
 echo ${rest}
}
##################################################
if [ ${#} -ge 2 ] 
then
 rest=${@:2}
elif [ ${#} -eq 1 ] 
then
 echo nil
 exit 2 # nil
else
 exit 1 # wrong args
fi
##################################################
cdr
##################################################
