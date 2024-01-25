{ config, pkgs, lib, ... }: {
  nix-unify = {
    modules.shareNftables.enable = true;
  };
}
