#!/bin/bash
## db
## version 0.0.1 - initial
##################################################
# requires sh2/aliases/commands
db-mysql() {
  local -x MYSQL_TEST_LOGIN_FILE
  MYSQL_TEST_LOGIN_FILE=$( mktemp )-
  template-mysql-defaults-extra-file ${FUNCNAME/_/} > ${MYSQL_TEST_LOGIN_FILE}
  mysql --defaults-extra-file=${MYSQL_TEST_LOGIN_FILE} ${dbname}
  cat ${MYSQL_TEST_LOGIN_FILE}
  rm -v ${MYSQL_TEST_LOGIN_FILE} 1>&2
}
db-mysqldump() {
  local -x MYSQL_TEST_LOGIN_FILE
  MYSQL_TEST_LOGIN_FILE=$( mktemp )-
  template-mysql-defaults-extra-file ${FUNCNAME/_/} > ${MYSQL_TEST_LOGIN_FILE}
  mysqldump --defaults-extra-file=${MYSQL_TEST_LOGIN_FILE} ${dbname}
  cat ${MYSQL_TEST_LOGIN_FILE}
  rm -v ${MYSQL_TEST_LOGIN_FILE} 1>&2
}
db() {
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
  commands
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Mon, 17 Feb 2020 10:22:29 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
