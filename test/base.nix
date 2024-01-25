{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.unify
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
