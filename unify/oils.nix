{ lib
, stdenv
, pkgs
}:

stdenv.mkDerivation rec {
  pname = "oils-ci";
  version = "5996"; # Version of the github job...

  src = pkgs.fetchurl {
    url = "http://travis-ci.oilshell.org/github-jobs/git-89df688a7a62addff2a0a4c27e92aff044892093/oils-for-unix.tar";
    hash = "sha256-6YrTbsKfpsuvYOmCljz094wxiH1XSxE2EzNVyQ8xMmY=";
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
