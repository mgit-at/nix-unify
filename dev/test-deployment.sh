#!/bin/bash

set -euxo pipefail

if [ -v 1 ]; then
  OS="$1"
else
  OS="ubuntu"
fi

IP=$(incus info "unify-$OS" | grep "inet" | grep 10. | grep "[0-9.]*" -o | head -n 1)
nixos-rebuild --flake ".#test" --target-host "root@$IP" switch --show-trace
