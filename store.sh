#!/bin/bash
## store
## version 0.0.5 - add incr subcommand
#################################################
. ${SH2}/aliases/commands.sh
shopt -s expand_aliases
alias init-store='
{
  test ! -f ~/$( basename ${0} .sh )-store && {
    touch ${_}
  } || {
    source ${_}
    cecho green "loading store ..."
    sleep 1
    cecho green "done loading store"
  }
}
{
  declare -p store 2>/dev/null || { 
    cecho green "initializing store ..."  
    declare -A store
    store initialize
    cecho green "done initializing store"  
  }
}
'
alias init-store-silent='
{
  init-store
} &>/dev/null
'
store-initialize() {
  store["run"]=0
  declare -p store &>/dev/null
}
store-persist() {
  store[run]=$(( store[run] + 1 ))
  declare -p store | tee "${store_file}" &>/dev/null
}
store-set() { { local key ; key="${1}" ; local value ; value="${@:2}" ; }
  store[${key}]=${value}  
}
store-get() { { local key ; key="${1}" ; }
  echo "${store[${key}]}"
}
store-incr() { { local key ; key="${1}" ; local value ; value="${@:2}" ; }
  local -i new_value
  new_value=$( store get ${key} )
  let new_value+=value
  store set ${key} ${new_value}
}
store() {
  local store_file
  store_file=~/$( basename ${0} .sh )-store
  commands
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Tue, 01 Oct 2019 15:13:44 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
