#!/bin/bash
## diff-http-https-path.sh
## - diff protocol path request response
## version 0.2.1 - wip curl ua-device iphone
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
 curl -ks ${url} -A "iPhone"
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
diff-path-single() {
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
#-------------------------------------------------
diff-path() { 
 test ! "${path}" || {
  diff-path-single
  return
 }
 while [ ! ]
 do
  read path
  diff-path-single
 done
}
##################################################
if [ ${#} -eq 2 ]
then
 domain="${1}"
 path="${2}"
elif [ ${#} -eq 1 ]
then
 path="${1}"
elif [ ${#} -eq 0 ]
then
 path=""
else
 exit 1 # wrong args
fi
##################################################
diff-path
##################################################
