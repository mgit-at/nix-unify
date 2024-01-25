{ stdenv
, lib
, bash
, coreutils
, gnugrep
, gnused
}:

stdenv.mkDerivation {
  name = "nix-unify-script";
  src = ./src-script;

  buildInputs = [
    bash
  ];

  buildPhase = ''
    substituteInPlace *.sh \
      --subst-var-by self $out \
      --subst-var-by PATH ${lib.makeBinPath [
        coreutils
        gnugrep
        gnused
      ]}
    patchShebangs .
  '';

  installPhase = ''
    cp -r . $out
  '';
}
