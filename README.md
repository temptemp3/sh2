# sh2

just some bash scripts for log analysis and much more


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

+ requires cecho.sh
+ may not be in main branch

```
. ${SH2}/store.sh
store set ...
store persist
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

+ 27 Mar 2020 - Delete some older seldom used scripts
+  1 Mar 2020 - use https in quickstart, add coreutil install in case of new bourne mac
+ 23 Jan 2020 - use master branch in quickstart

