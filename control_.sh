#!/bin/bash
src=$1
dir=$2
dir=${dir:=_}
gsed -e "s@^\(Version:\).*@\1 $(./version_.sh)@" "${src}"
echo "Installed-Size: $(du -s "${dir}" | cut -f 1)"
