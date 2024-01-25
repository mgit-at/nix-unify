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
    # tests:
    # - basic install: check if everything runs through
    # - boot-persistence: check if the early boot script runs
    # - install properly: check, for each module, if it works
    # - leave system untouched: check for any differences after uninstall
  ''
)
