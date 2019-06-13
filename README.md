# sh2
just some bash scripts for log analysis and much more


**quickstart**

```
{
  git clone https://github.com/temptemp3/sh2.git -b working sh2
  find sh2 -type f -name \*.sh | xargs chmod +x
  echo "SH2=$( realpath sh2 )" >> commands
  source commands
}
```

**commands2**

```
. ${SH2}/commands2.sh
foo-subcommand() { ... }
foo() { 
 commands2 ${FUNCNAME} ${@}
}
```

**log-stat**

```
USAGE
  log-stat for log relative/path/to/log/in/log-paths path-name
```
