{
  git clone https://github.com/temptemp3/sh2.git -b 190717
  find sh2 -type f -name \*.sh | xargs chmod +x
  echo "declare -x SH2=$( realpath sh2 )" >> commands
  source commands
}
