{ config, pkgs, lib, ... }:

with lib;

{
  networking.hostName = mkIf (config.ansible.hostvars ? "ansible_hostname") (mkDefault config.ansible.hostvars.ansible_hostname);
  nixpkgs.hostPlatform = mkIf (config.ansible.hostvars ? "ansible_architecture") (mkDefault "${config.ansible.hostvars.ansible_architecture}-linux");
}
