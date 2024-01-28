{ config, modulesPath, pkgs, lib, ... }:

with lib;

let
  cfg = config.nix-unify.modules;
in
{
  options.nix-unify.modules = {
    mergePath = {
      enable = mkEnableOption "path merging. /run/current-system/sw/bin will be appended to system path" // { default = true; };
    };
    useNixDaemon = {
      enable = mkEnableOption "usage of nix-unify provided daemon instead of nix install script daemon." // { default = true; };
    };
    shareNftables = {
      enable = mkEnableOption "nftables rules";
    };
    shareSystemd = {
      enable = mkEnableOption "systemd units" // { default = true; };
      units = mkOption {
        description = "Units to share";
        default = [];
        type = types.listOf types.str;
      };
      replace = mkOption {
        description = "Replace those units regardless of whether they already exist on the host";
        default = [];
        type = types.listOf types.str;
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.shareNftables.enable) {
      nix-unify.modules.shareSystemd = {
        units = [ "nftables.service" ];
        replace = [ "nftables.service" ];
      };
    })
  ];
}
