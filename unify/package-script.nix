{ stdenv
, lib
, bash
, oil
, coreutils
, gnugrep
, gnused
, makeHostPassthrough
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
    for h in hook_files final; do
      for f in modules/*.ysh; do
        if grep "proc $h" "$f" >/dev/null 2>/dev/null; then
          mod=$(basename "$f" .ysh)
          sed \
            -e "s|^proc $h|proc ''${mod}_$h|g" \
            -i "$f"
          handlerblock="''${handlerblock}
''${mod}_$h (ctx=ctx, cfg=cfg.modules.$mod)"
        fi
      done
      handlerblock="''${handlerblock}
''$h (ctx=ctx, cfg=cfg.modules.$mod)"
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
        (makeHostPassthrough { name = "systemctl"; })
      ]} \
      --subst-var-by srcblock "$srcblock" \
      --subst-var-by handlerblock "$handlerblock"
  '';

  installPhase = ''
    cp -r . $out
  '';
}
