#!/usr/bin/env bash
s="${BASH_SOURCE[0]}"
while [ -h "$s" ]; do
  r="$( cd -P "$( dirname "$s" )" >/dev/null 2>&1 && pwd )"
  s="$(readlink "$s")"
  [[ $s != /* ]] && s="$r/$s"
done
r="$( cd -P "$( dirname "$s" )" >/dev/null 2>&1 && pwd )"
# ${r}/tool/dartaotruntime ${r}/lib/cat.aot "$@"
a=("$@")
unset a[0]
# dartaotruntime ${r}/lib/$1.aot "${a}"
${r}/tool/dartaotruntime ${r}/lib/$1.aot "${a[@]}"