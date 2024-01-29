{ config, modulesPath, pkgs, lib, ... }:

with lib;

let
  cfg = config.nix-unify.modules;
  mkList = attrs: mkOption ({
    default = [];
    type = types.listOf types.str;
  } // attrs);
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
      enable = mkEnableOption "share nftables rules";
    };
    shareUsers = {
      enable = mkEnableOption "share users";
      ignoreUsers = mkList {
        description = "Ignore certain users from being shared";
      };
      ignoreGroups = mkList {
        description = "Ignore certain groups from being shared";
      };
      forceUsers = mkList {
        description = "Claim certain users regardless of whether the host manages them";
      };
      forceGroups = mkList {
        description = "Claim certain groups regardless of whether the host manages them";
      };
    };
    shareSystemd = {
      enable = mkEnableOption "systemd units" // { default = true; };
      units = mkList {
        description = "Units to share";
      };
      replace = mkList {
        description = "Replace those units regardless of whether they already exist on the host";
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.useNixDaemon.enable) {
      nix-unify = {
        modules = {
          shareSystemd = {
            units = [ "nix-daemon.service" ];
            replace = [ "nix-daemon.service" ];
          };
          shareUsers = {
            forceUsers = map (id: "nixbld${toString id}") (range 1 32);
            forceGroups = [ "nixbld" ];
          };
        };
      };
    })
    (mkIf (cfg.shareNftables.enable) {
      nix-unify.modules.shareSystemd = {
        units = [ "nftables.service" ];
        replace = [ "nftables.service" ];
      };
    })
    (mkIf (cfg.shareSystemd.enable) {
      nix-unify.files.etc."systemd/system/service.d/zzz-nix-unify.conf" = {};

      # fix /nix/store in restricted services
      systemd.packages = [
        (pkgs.writeTextFile {
          name = "systemd-nix-unify-service-overrides";
          destination = "/etc/systemd/system/service.d/zzz-nix-unify.conf";
          text = ''
            [Service]
            ReadOnlyPaths=/nix/store
          '';
        })
      ];
    })
  ];
}
