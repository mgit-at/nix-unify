{
  description = "";

  # For checks
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs } @ inputs: let
    inherit (self) outputs;
  in {

    nixosConfigurations = {
      # FIXME replace with your hostname
      test = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };
        # > Our main nixos configuration file <
        modules = [
          ./test/base.nix
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
