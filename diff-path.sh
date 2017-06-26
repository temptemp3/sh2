#!/bin/bash
## diff-http-https-path.sh
## - diff protocoal path request response
## version 0.1.0 - if-domain-path
##################################################
set -e # exit on error
##################################################
if-domain-path() {
 test "${domain}" && {
  echo ${domain}${path}
 true
 } || {
  echo ${path}
 }
}
#-------------------------------------------------
curl-url-payload() { 
 local url
 url=${protocol}://$( if-domain-path )
 curl -ks ${url}
}
#-------------------------------------------------
curl-url-validate-protocol() {
 case ${protocol} in
  http|https) true ;;
  *) false ;;
 esac
}
#-------------------------------------------------
curl-url() { { local protocol ; protocol="${1}" ; }
 curl-url-validate-protocol
 curl-url-payload
}
#-------------------------------------------------
temp=
generate-temp() {
 temp=$( basename ${0} .sh )-$( date +%s )-${RANDOM}
}
#-------------------------------------------------
_cleanup() { 
 test ! "${temp}" || {
  rm ${temp}* --verbose 1>/dev/null
 }
}
#-------------------------------------------------
main() { 
 echo testing
 generate-temp # ${temp}
 for protocol in http https 
 do 
  echo ${protocol}
  curl-url ${protocol} > ${temp}-${protocol} &
 done
 wait 
 diff ${temp}-* || true
 _cleanup
}
##################################################
if [ ${#} -eq 2 ]
then
 domain="${1}"
 path="${2}"
elif [ ${#} -eq 1 ]
then
 path="${1}"
else
 exit 1 # wrong args
fi
##################################################
main
##################################################
