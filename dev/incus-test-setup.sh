#!/bin/bash

set -euxo pipefail

for img in debian/12 ubuntu/22.04; do
  os=$(dirname "$img")

  incus delete -f "unify-$os" || true

  incus launch "images:$img" "unify-$os"
  sleep 10s

  echo "
    apt update
    apt dist-upgrade -y
    apt install curl xz-utils openssh-server -y
    yes y | sh <(curl -L https://nixos.org/nix/install) --daemon
    mkdir -p /root/.ssh
    echo \"$(cat ~/.ssh/*pub)\" > /root/.ssh/authorized_keys
    chmod 600 -R /root/.ssh
    mkdir -p /var/nix-unify
    touch /var/nix-unify/DEBUG
  " | incus exec "unify-$os" bash -

  echo 'for f in /nix/var/nix/profiles/default/bin/nix*; do
    ln -s "$f" "/usr/bin/$(basename "$f")"
  done' | incus exec "unify-$os" bash -
done
