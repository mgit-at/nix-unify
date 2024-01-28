final: prev: {
  makeHostPassthrough = { name, bins ? [name] }: prev.stdenv.mkDerivation {
    # make script that calls binary from host path
    name = "host-passthru-${name}";
    dontUnpack = true;
    dontConfigure = true;

    inherit bins;

    buildPhase = ''
      for b in ''${bins[@]}; do
        cp ${./host-passthrough.sh} "$b"
        substituteInPlace "$b" \
          --subst-var-by exec "$b"
      done
    '';

    installPhase = ''
      chmod 755 *
      mkdir -p $out
      cp -r . $out/bin
    '';
  };
}
