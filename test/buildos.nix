{ conf }:
let
  flake = builtins.getFlake (builtins.toString ../.);
  inherit (flake) inputs outputs;
in
  (flake.inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inputs = inputs // { self = outputs; };
      outputs = outputs;
    };
    modules = [
      (import conf)
    ];
  }).config.system.build.toplevel
