{ stdenv
, lib
, bash
, oil
, coreutils
, gnugrep
, gnused
, makeHostPassthrough
, getent
}:

stdenv.mkDerivation {
  name = "nix-unify-script";
  src = ./src-script;

  buildInputs = [
    bash
    oil
  ];

  buildPhase = ''
    doHook() {
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
''$h (ctx=ctx, cfg=cfg)"
    }

    patchShebangs .
    handlerblock=""
    for h in hook_files final; do
      doHook
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
        getent
        (makeHostPassthrough { name = "systemd"; bins = [ "systemctl" "networkctl" "systemd-sysusers" ]; })
      ]} \
      --subst-var-by srcblock "$srcblock" \
      --subst-var-by handlerblock "$handlerblock"

    handlerblock="$srcblock"
    h="describe"
    doHook
    echo "$handlerblock" > unify-overview.ysh
    chmod +x unify-overview.ysh
  '';

  installPhase = ''
    cp -r . $out
  '';
}
