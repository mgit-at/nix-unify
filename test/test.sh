#!/bin/bash

set -euo pipefail

IP="$1"

SELF=$(dirname "$(readlink -f "$0")")
KEY="$SELF/../dev/id_ed25519_dev"
KNOWN_HOSTS=$(mktemp)
DEST="root@$IP"

export NIX_SSHOPTS="-o UserKnownHostsFile=$KNOWN_HOSTS -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i $KEY"

m() {
  echo "$*" >&2
}

s() {
  m
  m " == $* == "
  m
}

t() {
  m "-> $*"
}

t_a() {
  if [ "$1" != "$2" ]; then
    m "assertion failed"
    diff -u <(echo "$1") <(echo "$2")
  fi
}

t_e() {
  m " ... ok"
  m
}

ssh() {
  m "\$ $*"
  command ssh $NIX_SSHOPTS "$DEST" "$@"
}

deploy() {
  SRC="$1"
  s "deploying $SRC"

  F="/tmp/nix-unify-$SRC"
  nix-build --arg conf "$SELF/tests/$SRC.nix" buildos.nix -o "$F"
  STORE=$(readlink -f "$F")

  nix-copy-closure --to "$DEST" "$STORE"
  ssh nix-env -p /nix/var/nix/profiles/system --set "$STORE"
  ssh "$STORE/bin/switch-to-configuration" switch
}

deploy initial

s "basics"

t "check if /run/current-system exists"
ssh test -e /run/current-system
t_e

t "check if nix-daemon was overwritten"
OUT=$(ssh systemctl show "nix-daemon.service" -p FragmentPath --value)
t_a "$OUT" "/run/systemd/generator.early/nix-daemon.service"
t_e

t "check if nix still working and correctly configured"
ssh nix --extra-experimental-features "nix-command" config check
ssh nix --extra-experimental-features "nix-command" store ping
t_e

t "check if mergePath applied, nix in path"
OUT=$(ssh which nix)
t_a "$OUT" /run/current-system/bin/nix
t_e

# TODO: once nix-unify starts services check here aswell if nginx running

s "reboot"
ssh reboot
while ! timeout 1 ssh true 2>/dev/null >/dev/null; do
  sleep 1s
done

t "check if nginx is running"
ssh systemctl is-active nginx
ssh curl --fail "http://localhost"
t_e

t "check if /run/current-system was created again by nix-unify-at-boot"
ssh test -e /run/current-system
t_e

t "check if new nix in use"
echo todo
t_e

t "check if nftables loaded"
ssh nft list ruleset | grep nixos-fw
t_e

# deploy change without nginx
# check if nginx properly removed
# run uninstall
# check if mergePath un-applied
