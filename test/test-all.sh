#!/bin/bash

set -euo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/oslist.sh"

for os in $OSLIST; do
  if ! incus image list -f csv -c l | grep "unify-test-$os" >/dev/null; then
    incus image import "$IMAGES/$OS.tar.gz" --alias "unify-test-$OS"
  fi

  I="unify-$$-run-test-$os"

  incus launch "unify-test-$os" "$I" -e
  sleep 10s

  bash "$SELF/test.sh" "$(get_ip "$I")"
done
