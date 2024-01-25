{ stdenv
, vmTools }:

{ name }:

vmTools.runInLinuxVM (
  pkgs.runCommand "test-${name}" {
    preVM =
      ''
        touch $out
      '';
    diskImageBase = "test-unify-${name}";
    buildInputs = [ pkgs.util-linux pkgs.perl ];
  }
  ''
    # run test
  ''
)
