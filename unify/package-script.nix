{ stdenv
, lib
, bash
, oils-for-unix
, coreutils
, gnugrep
, gnused
, makeHostPassthrough
, getent
, findutils
, util-linux
, perl
}:

let
  perlWrapped = perl.withPackages (p: with p; [ ConfigIniFiles FileSlurp ]);
in
stdenv.mkDerivation {
  name = "nix-unify-script";
  src = ./src-script;

  buildInputs = [
    bash
    oils-for-unix
  ];

  buildPhase = ''
    doHook() {
      for f in modules/*.ysh; do
        if grep "proc $h" "$f" >/dev/null 2>/dev/null; then
          mod=$(basename "$f" .ysh)
          sed \
            -e "s|^proc $h|proc ''${mod}_$h|g" \
            -i "$f"
          newblock="''${newblock}
''${mod}_$h (ctx=ctx, cfg=cfg.modules.$mod)"
        fi
      done
      newblock="''${newblock}
''$h (ctx=ctx, cfg=cfg)"
    }

    patchShebangs .

    newblock=""
    for h in hook_files final; do
      doHook
    done
    handlerblock="$newblock"

    srcblock=""
    for f in lib/*.ysh modules/*.ysh; do
      srcblock="''${srcblock}
      source $out/$f"
    done

    newblock=""
    for h in hook_systemd; do
      doHook
    done
    generatorblock="$newblock"

    substituteInPlace unify.ysh \
      --subst-var-by self $out \
      --subst-var-by PATH ${lib.makeBinPath [
        coreutils
        gnugrep
        gnused
        getent
        findutils
        (makeHostPassthrough { name = "systemd"; bins = [ "systemctl" "networkctl" "systemd-sysusers" "systemd-escape" "busctl" ]; })
      ]} \
      --subst-var-by srcblock "$srcblock" \
      --subst-var-by handlerblock "$handlerblock" \
      --subst-var-by generatorblock "$generatorblock"

    substituteInPlace reload-units.pl \
      --subst-var out \
      --subst-var-by coreutils "${coreutils}" \
      --subst-var-by perl "${perlWrapped}" \
      --subst-var-by shell "${bash}/bin/sh" \
      --subst-var-by utillinux "${util-linux}" \

    newblock="$srcblock"
    h="describe"
    doHook
    echo "$newblock" > unify-overview.ysh
    chmod +x unify-overview.ysh
  '';

  installPhase = ''
    cp -r . $out
  '';
}
