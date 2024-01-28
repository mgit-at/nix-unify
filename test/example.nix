{ config, pkgs, lib, ... }: {
  nix-unify = {
    modules.shareNftables.enable = true;
    modules.shareSystemd.units = [ "nginx.service" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts.example = {
      default = true;
      root = "/var/www";
    };
  };
}
