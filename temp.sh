#!/bin/bash
## temp
## version 0.0.1 - initial
##################################################
. ${SH2}/aliases/commands.sh # commands
test "${temp}" && {
  temp=${temp}_
true
} || {
  declare -x temp
  temp=$( mktemp )
}
temp-global() {
  echo ${temp//_/}
}
temp-super() {
  echo ${temp/_/}
}
temp-this() {
  echo ${temp}
}
temp() { 
  commands
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Wed, 17 Jul 2019 13:48:35 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
