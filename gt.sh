#!/bin/bash
## gt
## version 0.0.1 - initial
##################################################
gt() { { local car ; car="${1}" ; local cadr ; cadr="${2}" ; local cddr ; cddr=${@:3} ; }
  test "${cadr}" || { return ; }
  test ! ${car} -lt ${cadr} || { echo ${car} ${cadr} ; return ; }
  ${FUNCNAME} ${car} ${cddr}
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Mon, 01 Jul 2019 12:15:43 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
