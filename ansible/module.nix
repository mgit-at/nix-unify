{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    ansible = with types; {
      facts = mkOption {
        type = attrsOf anything;
        default = {};
      };
      hostvars = mkOption {
        type = attrsOf anything;
        default = {};
      };
    };
    ansible-src = mkOption {
      type = types.nullOr types.str;
      default = builtins.getEnv "ANSIBLE_JSON";
    };
  };

  config.ansible = mkIf (config.ansible-src != null && config.ansible-src != "") (builtins.fromJSON config.ansible-src);
}
