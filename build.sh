#!/bin/bash
## build
## - builds a copy of script with resolved . lines
## version 0.0.3 - obfuscate output
##################################################
build() {
  local outfile
  outfile="${build}/$( basename ${0} .sh )"
  cecho green "building standalone ..."
  ################################################
  ## 1.  cleanup build (creates empty build dir)
  ## 1.  populate build (minimum: source script)
  ## 1.1 migrate script
  ################################################
  ## 1. cleanup build (creates empty build dir)
  ################################################
  cecho green "cleanup up build ..."
  cecho yellow $( test ! -d "${build}" || rm -rvf ${_} )
  cecho yellow $( mkdir -v "${build}" )
  cecho green "build clean"
  ################################################
  ## 1. populate build (minimum: source script)
  ################################################
  ## 1.1 migrate script
  ## - resolves '.' lines
  ## - keeps 'source' lines
  ################################################
  { # resolve source lines
    bash -vp ${0} true 2>&1 | 
    grep -v -e '^\s*[.]\s\+' 
  } | tee ${outfile}.sh
  ################################################
  ## obfuscate output to prevent easy tampering
  ################################################
  test ! $( which bash-obfuscate 2>/dev/null ) || {
    bash-obfuscate ${outfile}.sh > ${outfile}.sh-temp
    mv -v ${outfile}.sh{-temp,}
  }
  ################################################
  cecho green "standalone built"
}
##################################################
## generated by create-stub2.sh v0.1.2
## on Sat, 04 May 2019 11:57:45 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
