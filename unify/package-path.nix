{ stdenv
, lib
, bash
, coreutils
, gnugrep
, gnused
}:

stdenv.mkDerivation {
  name = "nix-unify-path";
  src = ./src-path;

  buildInputs = [
    bash
  ];

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    cp -r . $out
  '';
}
