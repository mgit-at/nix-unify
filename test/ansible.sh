#!/bin/bash

set -euxo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/oslist.sh"

if [ -v 1 ]; then
  OS="$1"
else
  OS="$OSLIST"
fi

for os in $OS; do
  IP=$(get_ip "unify-$os")
  NIX_SSHOPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i $SELF/id_ed25519_dev" ansible-playbook --ssh-common-args "-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o IdentitiesOnly=yes" --private-key "$SELF/id_ed25519_dev" -u root -i "$IP," playbooks/test.yml
done

