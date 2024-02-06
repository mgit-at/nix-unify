{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.unify
    inputs.self.nixosModules.ansible
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
