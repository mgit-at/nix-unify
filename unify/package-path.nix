{ stdenv
, lib
, bash
, oils-for-unix
, coreutils
, gnugrep
, gnused
}:

stdenv.mkDerivation {
  name = "nix-unify-path";
  src = ./src-path;

  buildInputs = [
    bash
    oils-for-unix
  ];

  buildPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    cp -r . $out
  '';
}
