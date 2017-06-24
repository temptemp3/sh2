#!/bin/bash
## create-stub2
## - create program stub
## =standalone=
## version 0.0.1 - initial
##################################################
set -e # exit on error
##################################################
create-stub-generate-stub-head() { 
 cat << EOF
#!/bin/bash
## ${program}
## =stub=
## version 0.0.0 - stub
exit 0
EOF
}
#-------------------------------------------------
create-stub-generate-stub-import-line() {
 cat << EOF
${candidate_program}() { \${location}/${candidate_program}.sh \${@} ; }
EOF
}
#-------------------------------------------------
for-each-create-stub-generate-stub-import-line() {
 local candidate_program
 for candidate_program in ${programs}
 do
  create-stub-generate-stub-import-line
 done
} 
#-------------------------------------------------
create-stub-generate-stub-imports-head() {
 cat << EOF
##################################################
location="${location}"
EOF
} 
#-------------------------------------------------
create-stub-generate-stub-imports() {
 create-stub-generate-stub-imports-head
 for-each-create-stub-generate-stub-import-line
}
#-------------------------------------------------
create-stub-generate-stub-entry() {
 cat << EOF
##################################################
${program}() {
 true
}
##################################################
if [ \${#} -eq 0 ] 
then
 true
else
 exit 1 # wrong args
fi
##################################################
${program}
##################################################
EOF
}
#-------------------------------------------------
create-stub-generate-stub() {
 create-stub-generate-stub-head
 create-stub-generate-stub-imports
 create-stub-generate-stub-entry
}
#-------------------------------------------------
create-stub-validate-arguments() {
 true 
 #------------------------------------------------
 # TO-DO 
 # true if all conditions are satisfied for each [argument]
 # [location], l
 #  1. exists
 # [program], p
 #  1. does not exist in l
 # [programs], Q
 #  1. all q in P exist in l
 # else 
 # false
 #------------------------------------------------
}
#-------------------------------------------------
create-stub-list() {
 create-stub-validate-arguments # check conditions
 create-stub-generate-stub
}
#-------------------------------------------------
create-stub-help() {
 cat << EOF
 create-stub
1 - location
2 - stub name
3- list of programs
EOF
}
#-------------------------------------------------
create-stub2() {
 create-stub-list
}
#-------------------------------------------------
if [ ${#} -ge 2 ] 
then
 location="${1}"
 program="${2}"
 programs="${@:3}"
else
 create-stub-help
 exit 1 # wrong args
fi
##################################################
create-stub2
##################################################
