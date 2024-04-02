#!/bin/bash

set -euxo pipefail

v="$1"

sed "s|version: .*|version: $v|" -i galaxy.yml
git add galaxy.yml
git commit -m "version $v"
git tag "v$v"
git push
git push origin "v$v"
