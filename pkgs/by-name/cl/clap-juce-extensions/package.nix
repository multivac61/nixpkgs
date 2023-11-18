{ lib
, stdenv
, fetchFromGitHub
, cmake
, juce
}:

stdenv.mkDerivation rec {
  pname = "clap-juce-extensions";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "free-audio";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-1th4cJLCuRUenFUp1r+y5yGAnH8DODpa1r4fdjqDhnI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    juce
  ];

  meta = with lib;
    {
      description = "";
      homepage = "https://github.com/free-audio/clap-juce-extensions";
      license = licenses.mit;
      maintainers = with maintainers; [ multivac61 ];
      mainProgram = "clap-juce-extensions";
      platforms = platforms.all;
    };
}
