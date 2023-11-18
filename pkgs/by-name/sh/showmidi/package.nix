{ lib
, stdenv
, fetchFromGitHub
, cmake
, juce
, clap-juce-extensions
}:

stdenv.mkDerivation rec {
  pname = "show-midi";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "gbevin";
    repo = "ShowMIDI";
    rev = version;
    sha256 = "sha256-mvlAHlNDxWHzK/Z+NAw2aotH3tk3ltAak6gQepzZwja=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    juce
    clap-juce-extensions
  ];

  meta = with lib; {
    description = "Multi-platform GUI application to effortlessly visualize MIDI activity";
    homepage = "https://github.com/gbevin/ShowMIDI";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ multivac61 ];
    mainProgram = "show-midi";
    platforms = platforms.all;
  };
}
