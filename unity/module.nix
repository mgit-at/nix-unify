{ config, modulesPath, pkgs, lib, ... }:

with lib;

let
  cfg = config.nix-unity;
  cfgFile = pkgs.formats.json {};
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  options.nix-unity = {
    # enable = mkEnableOption "nix-unity";

    modules = {
      mergePath = {
        enable = mkEnableOption "path merging. /run/current-system/sw/bin will be appended to system path";
      };
      etcMerge = {
        enable = mkEnableOption "etc merge module";

        files = mkOption {
          description = "Add the following files to host /etc, symlinked from nix";
          default = [];
          type = types.listOf types.str;
        };
      };
    };

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

    system.build.installBootLoader = pkgs.writeScript "install-lxd-sbin-init.sh" ''
      #!${pkgs.runtimeShell}
      ${pkgs.coreutils}/bin/ln -fs "$1/init" /sbin/init
    '';

    system.extraSystemBuilderCmds = ''
      cp "${cfgFile.generate "unify.json" cfg.modules}" $out/unify.json

      # add our custom unify
      install -D ${./unify.sh} $out/bin/unify
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
