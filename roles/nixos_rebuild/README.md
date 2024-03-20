# nixos_rebuild

Builds and deploys a nixos/nix-unify configuration to the host (meant for local usage)

- Include for nix-unify and nixos deployments
- Requires local_nix or `nix_wrapper` being set to `env` (effectivly no wrapper)
- Note that this role depends on a fully configured flake being present in the repo that exposes the given system configurations
