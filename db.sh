#!/bin/bash
## db
## version 0.0.3 - fix leaves tmp files behind
##################################################
# requires sh2/aliases/commands
shopt -s expand_aliases
alias bind-variables='
{
  local MYSQL_TEST_LOGIN_FILE
}
'
template-mysql-defaults-extra-file() { { local block_name ; block_name="${1}" ; }
  cat << EOF
[${block_name}]
host = ${dbhost}
port = 3306
user = ${dbuser}
password = ${dbpasswd}
EOF
}
template() {
  commands
}
setup-db-defaults-extra-file() { { local block_name ; block_name="${1}" ; }
  MYSQL_TEST_LOGIN_FILE=$( mktemp )
  touch ${MYSQL_TEST_LOGIN_FILE}
  chmod 600 ${_}
  template-mysql-defaults-extra-file ${block_name} > ${MYSQL_TEST_LOGIN_FILE}
}
cleanup-db-defaults-extra-file() {
  rm ${MYSQL_TEST_LOGIN_FILE}
}
db-mysql() {
  _ mysql
}
db-mysqldump() {
  _ mysqldump
}
db() {
  _() {
    bind-variables
    setup-db-defaults-extra-file ${1}
    command ${1} --defaults-extra-file=${MYSQL_TEST_LOGIN_FILE} ${dbname}
    cleanup-db-defaults-extra-file
  }
  commands
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Mon, 17 Feb 2020 10:22:29 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
