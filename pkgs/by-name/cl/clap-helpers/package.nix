{ lib
, stdenv
, fetchFromGitHub
, cmake
, catch2
}:

stdenv.mkDerivation {
  pname = "clap-helpers";
  version = "unstable-2023-10-25";

  src = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-helpers";
    rev = "4a2e3ee4d7de38912b9375a47a0e1294075909f6";
    hash = "sha256-xU1PYnbypmv4ViP2XbaH2vS0x+YS/BaeZcyeOwbz/WU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    catch2
  ];

  buildPhase = ''
    cmake .
    make
  '';

  installPhase = ''
    make install
  '';

  meta = with lib; {
    description = "Minimal set of helpers to implement your plugin";
    homepage = "https://github.com/free-audio/clap-helpers";
    license = licenses.mit;
    maintainers = with maintainers; [ multivac61 ];
    mainProgram = "clap-helpers";
    platforms = platforms.all;
  };
}
