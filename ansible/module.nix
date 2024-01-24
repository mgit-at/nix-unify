{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    ansible = {
      facts = mkOption {};
    };
    ansible-src = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config.ansible = mkIf (config.ansible-src != null) importJSON config.ansible-src;
}
