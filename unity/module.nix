{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.nix-unity;
in
{
  options.nix-unity = {
    enable = mkEnableOption "nix-unity";

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

  config = mkIf (cfg.enable) {
    system.extraSystemBuilderCommands = ''
      # toJSON cfg.modules
      install -D ${./unify.sh} $out/bin/unify
      substituteInPlace $out/bin/nix-unity \
        --subst-var-by toplevel $out \
        --subst-var-by etc ${config.system.build.etc}/etc \
        --subst-var-by path ${config.system.path}
    '';
  };
}
