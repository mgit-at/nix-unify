{
  description = "Use NixOS parts in your host operating-system, for a step-by-step migration";

  # For checks
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs } @ inputs: let
    inherit (self) outputs;
  in {

    nixosConfigurations = {
      test = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          ./test/base.nix
          ./test/example.nix
        ];
      };
    };


    nixosModules = {
      unify = import ./unify/module.nix;
    };

    checks = {

    };

  };
}
