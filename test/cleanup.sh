#!/bin/bash

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/oslist.sh"

set -euxo pipefail

# Images
rm -rfv "$IMAGES"
# Incus-Images
for img in $(incus image list -f csv -c l | grep "^unify-test"); do
  incus image delete "$img"
done
# Test-Containers
for cont in $(incus ls -f csv -c n | grep "^unify-[0-9]*-test"); do
  incus delete -f "$cont"
done
# Dev-Containers
for cont in $(incus ls -f csv -c n | grep "^unify-"); do
  incus delete -f "$cont"
done
