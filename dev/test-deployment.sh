#!/bin/bash

set -euxo pipefail

SELF=$(dirname "$(readlink -f "$0")")

if [ -v 1 ]; then
  OS="$1"
else
  OS="ubuntu debian"
fi

for os in $OS; do
  IP=$(incus info "unify-$os" | grep "inet" | grep 10. | grep "[0-9.]*" -o | head -n 1)
  NIX_SSHOPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i $SELF/id_ed25519_dev" nixos-rebuild --flake ".#test" --target-host "root@$IP" switch --show-trace
done
