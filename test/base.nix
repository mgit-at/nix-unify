{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.unity
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
