#!/bin/sh

# nix-unity-deploy

nixos-rebuild build "$EXPR" -o bla
nix-copy-closure --to "$TARGET" bla
ssh "$TARGET" nix-env -p /nix/var/nix/profiles/system --set $(readlink -f bla)
ssh "$TARGET" $(readlink -f bla)/bin/nix-unity switch
# TODO: nix unity will set it's own "set booted" service up
