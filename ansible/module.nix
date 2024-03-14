{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./defaults.nix
  ];

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

  config.ansible = if config.ansible-src != null && config.ansible-src != ""
    then builtins.fromJSON (builtins.readFile config.ansible-src)
    else {};
}
