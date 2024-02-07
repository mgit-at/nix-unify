# nix-unify

Use NixOS parts in your host operating-system, for a step-by-step migration.

This repository contains multiple parts, each usable on their own:
- nix unify module: Allows using NixOS services and configuration on non-NixOS hosts
  - deployment works using nixos-rebuild
- ansible module: module that allows reading ansible variables from the environment variable ANSIBLE_JSON
- ansible roles:
  - local_nix: installs nix-portable and nix-wrapper, which uses nix-portable if no local nix install is found (meant for local usage)
  - nix: installs nix in multi-user mode (meant for server usage)
  - nixos_rebuild: runs nixos-rebuild and deploys the configuration on the host (meant for local usage)
    - can be used with both pure nixos and nix-unify system configurations

# Usage (nix-unify)

Add nix-unify to your flake.nix

```
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
```

Add `nix-unify.nixosModules.unify` to the nixos configuration that you want to convert

Use `nixos-rebuild .#your-config --target-host user@host` to deploy the configuration

## Adding a nixos flake.nix to your ansible repo

flake.nix:

```nix
{
  description = "My company ansible";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-unify }@inputs: let
    inherit (self) outputs;
  in {
    nixosConfigurations = nixpkgs.lib.mapAttrs (host: _: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        "${./nixos}/${host}"
      ];
    }) (builtins.readDir ./nixos);
  };
}
```

For each individual host add a `./nixos/HOST/default.nix`. Template:

```nix
{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.nix-unify.nixosModules.unify
    inputs.nix-unify.nixosModules.ansible
  ];

  networking.hostName = "your-hostname";
  nixpkgs.hostPlatform = "x86_64-linux";
}
```

# API

tbd

# Usage (ansible module)

Add nix-unify to your flake.nix

```
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
```

Add `nix-unify.nixosModules.ansible` to the nixos configuration

Either set `ANSIBLE_JSON` manually or use the nixos-rebuild role

# Usage (ansible roles)

Install the collection using ansible-galaxy

```
ansible-galaxy collection install git+https://github.com/mgit-at/nix-unify.git
```

- local_nix: Include before any nixos-rebuild roles
- nix: Include on non-nixos hosts that will be managed by nix-unify
- nixos_rebuild: Include for nix-unify and nixos deployments
  - Requires local_nix or `nix_wrapper` being set to `env` (effectivly no wrapper)
  - Note that this role depends on a fully configured flake being present in the repo that exposes the given system configurations
