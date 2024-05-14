#!/bin/bash

set -euxo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/oslist.sh"

if [ -v 1 ]; then
  OS="$1"
else
  OS="$OSLIST"
fi

chmod 600 "$SELF/id_ed25519_dev"

for os in $OS; do
  IP=$(get_ip "unify-$os")
  NIX_SSHOPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i $SELF/id_ed25519_dev" nixos-rebuild --flake ".#test" --target-host "root@$IP" switch --show-trace
done
