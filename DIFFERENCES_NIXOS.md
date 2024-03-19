# Differences between vanilla NixOS and nix-unify

## Systemd services

Services aren't automatically enabled

`nix-unify.modules.shareSystemd.enable` (default true) must be enabled for systemd sharing to work

In nix-unify, after creating a service it needs to be added to `nix-unify.modules.shareSystemd.units`

In order to override an existing host-service the service additionally needs to be added to `nix-unify.modules.shareSystemd.replace`

## Path

`nix-unify.modules.sharePath.enable` (default true) must be enabled for /run/current-system/sw/bin to be added to the host's path

## Networkd

`nix-unify.modules.shareNetworkd.enable` (default false) must be enavbled for networkd configuration to be replaced by the one provided by nixos

Note: If ifupdown is detected, ifupdown is disabled before activating networkd.

## Tmpfiles

Not currently supported, support planned

## /etc

Symlinks in /etc aren't automatically created

`nix-unify.files.etc."file-or-folder" = {}` can be used to create a symlink from the nixos /etc to the host's /etc
