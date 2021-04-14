# sh2

just some bash scripts for log analysis and much more

* [quickstart](#quickstart)
* [store](#store)
* [getops](#store)

## quickstart

```
{
  command realpath --version &>/dev/null || {
    case $( uname ) in
      Darwin) {
        brew install coreutil
      } ;;
      *) true ;;
    esac
  }
  test -d "sh2" || git clone https://github.com/temptemp3/sh2.git
  find sh2 -type f -name \*.sh | xargs chmod +x
  echo "declare -x SH2=$( realpath sh2 )" >> ~/.bashrc
  source ~/.bashrc
}
```

## store

+ use as persistent variable store
+ requires cecho.sh and aliases/commands.sh

boilerplate

```
. ${SH2}/aliases/commands.sh
. ${SH2}/cecho.sh
. ${SH2}/store.sh
main() {
  init-store-silent 
  store get some_key
  store set some_key new_value
  store persist
}
main
```

boilerplate (annotated)

```
. ${SH2}/aliases/commands.sh
. ${SH2}/cecho.sh
. ${SH2}/store.sh
main() {
  # make store available
  init-store-silent 
  # see also init-store
  # store now available
  # ... do some work
  # recover stored value
  store get some_key
  # ...
  # update stored value
  store set some_key new_value
  # create new stored value
  store set some_other_key some_other_value
  # persit store
  store persist
}
main
```

## getopts

* easy short/long option interface

boilerplate

```
. ${SH2}/getops.sh
on-shortops-case() { ... }
main() {
  getops "${@}"
}
```

## commands2

```
. ${SH2}/commands2.sh
foo-subcommand() { ... }
foo() { 
 commands2 ${FUNCNAME} ${@}
}
```

## log-stat

```
USAGE
  log-stat for log relative/path/to/log/in/log-paths path-name
```

## changelog

+ 14 Apr 2021 - update readme, add getops boilerplate
+ 29 May 2020 - update readme, add to store
+ 28 Mar 2020 - delete some older seldom used scripts
+  1 Mar 2020 - use https in quickstart, add coreutil install in case of new bourne mac
+ 23 Jan 2020 - use master branch in quickstart

