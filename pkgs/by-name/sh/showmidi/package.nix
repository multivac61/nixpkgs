{ lib
, stdenv
, fetchFromGitHub
, cmake
, juce
, pkg-config
, alsaLib
, freetype
, fetchzip
, libxml2
, xorg
, ...
}:

stdenv.mkDerivation rec {
  pname = "show-midi";
  version = "0.6.1"; # Replace with the dynamic version if needed

  src = fetchFromGitHub {
    owner = "gbevin";
    repo = "ShowMIDI";
    rev = version;
    sha256 = "sha256-mvlAHlNDxWHzK/Z+NAw2aotH3tk3ltAak6gQepzZwja=";
    fetchSubmodules = true;
  };

  vst2sdk = fetchzip {
    url = "https://archive.org/download/VST2SDK/vst_sdk2_4_rev2.zip";
    hash = "sha256-6eDJYGfuVczOTaZNUYa/dLEoCzl6Ysi1I1NrxuN2mPQ=";
  };

  nativeBuildInputs = [ cmake libxml2 ];

  buildInputs = [
    juce
    pkg-config
    alsaLib
    freetype
    xorg.libX11
    xorg.xrandr
    xorg.libXinerama
    xorg.libXcursor
  ];

  buildPhase = ''
    mv ${vst2sdk} libs/vst2

    # Makefile build
    pushd Builds/LinuxMakefile
    make CONFIG=Release
    popd

    # CMake build
    cmake -BBuilds/LinuxMakefile/build/clap -DCMAKE_BUILD_TYPE=Release
    cmake --build Builds/LinuxMakefile/build/clap --config Release
  '';

  installPhase = ''
    mkdir -p $out/bin

    pushd Builds/LinuxMakefile/build
    STAGE_DIR="$out/bin/ShowMIDI-$version"

    # Organize build artifacts
    mkdir -p $STAGE_DIR/vst $STAGE_DIR/vst3 $STAGE_DIR/clap $STAGE_DIR/lv2
    mv ShowMIDI $STAGE_DIR
    mv ShowMIDI.so $STAGE_DIR/vst
    mv ShowMIDI.vst3 $STAGE_DIR/vst3
    mv clap/ShowMIDI_artefacts/Release/ShowMIDI.clap $STAGE_DIR/clap
    mv ShowMIDI.lv2 $STAGE_DIR/lv2
    cp $src/*.md $STAGE_DIR
    popd
  '';

  meta = with lib; {
    description = "Multi-platform GUI application to effortlessly visualize MIDI activity";
    homepage = "https://github.com/gbevin/ShowMIDI";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ multivac61 ];
    platforms = platforms.all;
  };
}
