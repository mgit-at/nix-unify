# nix-unify

Use NixOS parts in your host operating-system, for a step-by-step migration.

# Usage

Add nix-unify to your flake.nix

```
  inputs.nix-unify.url = "github:mgit-at/nix-unify/master";
  inputs.nix-unify.inputs.nixpkgs.follows = "nixpkgs";
```

Add `nix-unify.nixosModules.nix-unify` to the nixos configuration that you want to convert

Use `nixos-rebuild .#your-config --target-host user@host` to deploy the configuration

# API

tbd
