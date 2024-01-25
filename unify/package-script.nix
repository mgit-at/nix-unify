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
    handlerblock=""
    for f in modules/*.ysh; do
      mod=$(basename "$f" .ysh)
      sed \
        -e "s|^const |const ''${mod}_|g" \
        -e "s|^var |var ''${mod}_|g" \
        -e "s|^proc |proc ''${mod}_|g" \
        -i "$f"
      handlerblock="''${handlerblock}
      handler \"$mod\" (&ctx) (&cfg.modules.$mod)"
    done
    srcblock=""
    for f in lib/*.ysh modules/*.ysh; do
      srcblock="''${srcblock}
      source $out/$f"
    done

    substituteInPlace unify.ysh \
      --subst-var-by self $out \
      --subst-var-by PATH ${lib.makeBinPath [
        coreutils
        gnugrep
        gnused
      ]} \
      --subst-var-by srcblock "$srcblock" \
      --subst-var-by handlerblock "$handlerblock"
  '';

  installPhase = ''
    cp -r . $out
  '';
}
