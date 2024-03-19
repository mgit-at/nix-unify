#!/bin/bash

set -euxo pipefail

SELF=$(dirname "$(readlink -f "$0")")
. "$SELF/oslist.sh"

# What is this?
# Since we will be testing within a nixos derivation
# we won't have access to things ike the internet
# (which is good, sinve the code shouldn't require it outside of (fod) build time)
# This means we need to create the image on a regular machine
# and then import it to the CI VM's incus daemon
if [ -v EXPORT_IMAGE ]; then
  rm -rf "$IMAGES"
  mkdir -p "$IMAGES"
fi

for img in $IMGLIST; do
  os=$(dirname "$img")

  incus delete -f "unify-$os" || true

  incus launch "images:$img" "unify-$os"
  sleep 10s

  echo "
    if [ -e /usr/bin/apt-get ]; then
      apt update
      apt dist-upgrade -y
      apt install curl xz-utils openssh-server -y
    elif [ -e /usr/bin/dnf ]; then
      dnf install openssh-server xz-static -y
    fi

    yes y | sh <(curl -L https://nixos.org/nix/install) --daemon
    mkdir -p /root/.ssh
    echo \"$(cat $SELF/id_ed25519_dev.pub)\" > /root/.ssh/authorized_keys
    chmod 600 -R /root/.ssh
    mkdir -p /var/nix-unify
    touch /var/nix-unify/DEBUG
  " | incus exec "unify-$os" bash -

  echo 'for f in /nix/var/nix/profiles/default/bin/nix*; do
    ln -s "$f" "/usr/bin/$(basename "$f")"
  done' | incus exec "unify-$os" bash -

  if [ -v EXPORT_IMAGE ]; then
    incus image delete "unify-test-$os" || true
    incus publish "unify-$os" --force --alias "unify-test-$os"
    incus image export "unify-test-$os" "$IMAGES/$os"
  fi
done
