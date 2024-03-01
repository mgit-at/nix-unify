#!/bin/bash

IMGLIST="debian/12 ubuntu/22.04"
OSLIST="debian ubuntu"

IMAGES="$SELF/images"

for_each_os() {
  for os in $IMGLIST; do
    "$1" "$(dirname "$os")" "$os"
  done
}

get_ip() {
  incus info "$1" | grep "inet" | grep 10. | grep "[0-9.]*" -o | head -n 1
}
