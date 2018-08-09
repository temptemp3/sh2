#!/bin/bash
## file-mime-encoding
## - returns file mime encoding
## version 0.0.1 - initial
##################################################
location=${SH2}
cdr() { ${location}/cdr.sh ${@} ; }
##################################################
mime-encodings() { { local candidate_encoding ; candidate_encoding="${1}" ; }
 case ${candidate_encoding} in
  unknown-8bit) echo SHIFT_JIS ;; # or maybe not sjis 
  *) echo ${candidate_encoding} ;;
 esac
}
#-------------------------------------------------
file-mime-encoding() {
 mime-encodings $( cdr $( file --mime-encoding ${infile} ) )
}
##################################################
if [ ${#} -eq 1 -a -f "${1}" ] 
then
 infile="${1}"
else
 exit 1 # wrong args
fi
##################################################
file-mime-encoding
##################################################
