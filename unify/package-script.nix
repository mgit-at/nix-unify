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
        -e "s|^proc main|proc ''${mod}_main|g" \
        -i "$f"
      handlerblock="''${handlerblock}
      ''${mod}_main (ctx=ctx, cfg=cfg.modules.$mod)"
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
