#!/bin/bash

lxc launch ubuntu:22.04 unify-ubuntu
echo "
apt update
apt dist-upgrade -y
yes y | sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p /root/.ssh
echo \"$(cat ~/.ssh/*pub)\" > /root/.ssh/authorized_keys
chmod 600 -R /root/.ssh
mkdir -p /var/nix-unify
touch /var/nix-unify/DEBUG
" | lxc exec unify-ubuntu bash -
echo 'for f in /nix/var/nix/profiles/default/bin/nix*; do
  ln -s "$f" "/usr/bin/$(basename "$f")"
done' | lxc exec unify-ubuntu bash -
