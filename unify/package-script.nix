{ stdenv
, lib
, bash
, oil
, coreutils
, gnugrep
, gnused
}:

stdenv.mkDerivation {
  name = "nix-unify-script";
  src = ./src-script;

  buildInputs = [
    bash
    oil
  ];

  buildPhase = ''
    patchShebangs .
    for f in modules/*.ysh; do
      mod=$(basename "$f" .ysh)
      sed \
        -e "s|^const |const $mod_|g" \
        -e "s|^var |var $mod_|g" \
        -e "s|^proc |proc $mod_|g" \
        -i "$f"
    done
    srcblock=""
    for f in lib/*.ysh modules/*.ysh; do
      srcblock="''${srcblock}source $out/$f\n"
    done

    substituteInPlace unify.ysh \
      --subst-var-by self $out \
      --subst-var-by PATH ${lib.makeBinPath [
        coreutils
        gnugrep
        gnused
      ]} \
      --subst-var-by srcblock "$srcblock"
  '';

  installPhase = ''
    cp -r . $out
  '';
}
