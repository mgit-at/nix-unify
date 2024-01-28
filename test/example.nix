{ config, pkgs, lib, ... }: {
  nix-unify = {
    modules.shareNftables.enable = true;
    modules.shareSystemd.units = [ "nginx.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    80 443
  ];

  networking.firewall.allowedUDPPorts = [
    443
  ];

  services.nginx = {
    enable = true;
    virtualHosts.example = {
      default = true;
      root = "/var/www";
    };
  };
}
