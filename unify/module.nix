{ config, modulesPath, pkgs, lib, ... }:

with lib;

let
  cfg = config.nix-unify;
  cfgFile = pkgs.formats.json {};
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./modules.nix
  ];

  options.nix-unify = {
    # enable = mkEnableOption "nix-unify";

    files = mkOption {
      type = types.attrsOf mkSubmodule ({ ... }: {
        target = mkOption {
          type = types.str;
        };
      });
    };

    use = {
      systemd = mkOption {
        type = types.listOf types.str;
      };
      systemdNetwork = mkOption {
        type = types.listOf types.str;
      };
    };
  };

  config = { # mkIf (cfg.enable) {
    # disable kernel and such
    boot.isContainer = true;

    # for exposing etc/profile.d from, for ex, unify
    environment.pathsToLink = [ "/etc/profile.d" ];

    # for sharing networkd config with host
    networking.useNetworkd = mkForce true;
    # disable resolvconf, as it's default in containers
    networking.resolvconf.enable = mkForce false;
    networking.useHostResolvConf = mkForce false;
    # don't do dhcp everywhere
    networking.useDHCP = mkForce false;
    # broken
    systemd.network.wait-online.enable = false;

    # making sure no legacy scripts are included
    boot.initrd.systemd.enable = mkForce true;
    # for sharing nftables config with host
    networking.nftables.enable = mkForce true;
    networking.nftables.flushRuleset = mkForce false;

    # causes many unnecessary rebuilds
    environment.noXlibs = false;

    # managment, etc/profile.d
    environment.systemPackages = [
      pkgs.nix-unify.path
    ];

    nixpkgs.overlays = [
      (self: prev: {
        nix-unify = { # TODO: scope
          path = prev.callPackage ./package-path.nix {};
          script = prev.callPackage ./package-script.nix {};
        };
      })
    ];

    # early-boot init
    # see https://raspberrypi.stackexchange.com/a/77999
    systemd.services.nix-unify-at-boot = {
      script = ''
        /nix/var/nix/profiles/system/bin/unify at_boot
      '';
      before = [ "basic.target" ];
      after = [ "local-fs.target" "sysinit.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        DefaultDependencies = "no";
      };
    };

    system.extraSystemBuilderCmds = let
      unify_primer = lib.escapeShellArg
      (concatStringsSep "\n" (mapAttrsToList (mod: cfg:
          ''handler ${mod} ${if cfg.enable then "install" else "uninstall"}''
        ) cfg.modules));
    in ''
      cp "${cfgFile.generate "unify.json" cfg.modules}" $out/unify.json

      # add unify
      install -D ${pkgs.nix-unify.script}/unify.sh $out/bin/unify
      echo ${unify_primer} >> $out/bin/unify

      substituteInPlace $out/bin/unify \
        --subst-var-by toplevel $out \
        --subst-var-by etc ${config.system.build.etc}/etc \
        --subst-var-by path ${config.system.path}

      # replace switch-to-configuration
      rm -f $out/bin/switch-to-configuration
      ln -s $out/bin/unify $out/bin/switch-to-configuration
    '';
  };
}
