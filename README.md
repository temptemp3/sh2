# sh2

just some bash scripts

## requirements

### git
#### windows

- [Git for windows](https://git-for-windows.github.io/)
  + bash
  + perl

### optional

- [Graphviz](http://www.graphviz.org/)

## installation

### set environment

```
SH=/path/to/script
```

## usage

```
${SH}/command.sh args
```

---

## programs

- markdown - somehow markdown

- diff-path - compare request protocol varied response
  + may be useful when performing post http to https migration optimizations or resolving mixed content in https response

- create-stub2 - create program stub

```
# examples

## example i: create stub for program b with location a imports c though z

${SH}/create-stub2.sh a b {c..z} 
#!/bin/bash
## b
## =stub=
## version 0.0.0 - stub
exit 0
##################################################
location="a"
c() { ${location}/c.sh ${@} ; }
d() { ${location}/d.sh ${@} ; }
...
y() { ${location}/y.sh ${@} ; }
z() { ${location}/z.sh ${@} ; }
##################################################
b() {
 true
}
##################################################
if [ ${#} -eq 0 ]
then
 true
else
 exit 1 # wrong args
fi
##################################################
b
##################################################

## example ii: create stub for standalone program foo and write to file foo.sh

${SH}/create-stub.sh foo | tee ${SH}/foo.sh
#!/bin/bash
## foo
## =stub=
## version 0.0.0 - stub
exit 0
##################################################
foo() {
 true
}
##################################################
if [ ${#} -eq 0 ]
then
 true
else
 exit 1 # wrong args
fi
##################################################
foo
##################################################
```
  
---
