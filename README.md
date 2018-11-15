# sh2
just some bash scripts for log analysis and much more


**quickstart**

```
sh2-install() {
 git clone https://github.com/temptemp3/sh2.git -b working sh2
 find sh2 -type f -name \*.sh | xargs chmod +x
 echo "SH2=$( realpath sh2 )" >> commands
 source commands
}
sh2-install
```
