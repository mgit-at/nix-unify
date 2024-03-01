{ pkgs, ... }: {
  imports = [
    ../base.nix
    ../example.nix
  ];

  environment.systemPackages = with pkgs; [
    curl
  ];
}
