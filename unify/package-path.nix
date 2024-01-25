{ stdenv
, lib
, bash
, oil
, coreutils
, gnugrep
, gnused
}:

stdenv.mkDerivation {
  name = "nix-unify-path";
  src = ./src-path;

  buildInputs = [
    bash
    oil
  ];

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    cp -r . $out
  '';
}
