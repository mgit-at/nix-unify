{ lib
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "oils-ci";
  version = "6015"; # Version of the github job...

  src = pkgs.fetchurl {
    # url = "http://travis-ci.oilshell.org/github-jobs/6015/cpp-tarball.wwz/_release/oils-for-unix.tar";
    url = "https://mkg20001.io/tmp/f7qmpbj3dmajcxki05b6gc0hxl0967p8-oils-for-unix.tar";
    hash = "sha256-TFbzcbdpqKw7J12iNtKPgJQ2g/8Ed84edcKeDfGdDuI=";
  };

  patchPhase = ''
    patchShebangs build
    patchShebangs _build
  '';

  buildPhase = ''
    _build/oils.sh
  '';

  installPhase = ''
    ./install
  '';

  dontStrip = true;

  meta = with lib; {
    description = "Oils for Unix. The C++ build directly from the CI!";
    homepage = "https://oilshell.org";
    #changelog = "https://github.com/mtkennerly/ludusavi/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    #maintainers = with maintainers; [ melkor333 ];
    #mainProgram = "ysh";
  };
}
