#!/bin/bash
## header
## - sh2 header
## version 0.0.2 - fix commands
##################################################
test ${#} -eq 1 && {
 sh2_source_path="${1}"
true
} || {
 sh2_source_path=$( dirname ${0} )
}
. ${slack_source_path}/sh2/cache.sh
. ${slack_source_path}/sh2/cecho.sh
. ${slack_source_path}/sh2/error.sh
. ${slack_source_path}/sh2/aliases/commands.sh
. ${slack_source_path}/sh2/getops.sh
unset sh2_source_path
##################################################
## generated by create-stub2.sh v0.1.1
## on Mon, 07 May 2018 10:37:17 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
