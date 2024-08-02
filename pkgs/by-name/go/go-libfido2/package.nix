{ lib
, buildGoModule
, fetchFromGitHub
, libfido2
, stdenv
, openssl
, libcbor
, hidapi
, pkgs
}:

let
  static-openssl = openssl.override { static = true; };
  static-libcbor = libcbor.override { static = true; };
in
buildGoModule rec {
  pname = "go-libfido2";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "keys-pub";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-bweJNKYsSZ8a4KV+evBvymrYDezApBaaWfFGuhl5h2M=";
  };

  vendorHash = "sha256-1KWZRMSJaGkV6L4gRLGNH7VtaxEurUOXHCTylOGK2Y8=";

  postConfigure =
    (
      lib.optionalString stdenv.isDarwin /* bash */ ''
        ${pkgs.tree}/bin/tree

        substituteInPlace fido2_static_arm64.go \
          --replace-fail "/opt/homebrew/opt/libfido2/lib/libfido2.a" "${lib.getLib libfido2}/lib/libfido2.a" \
          --replace-fail "/opt/homebrew/opt/openssl@1.1/lib/libcrypto.a" "${lib.getLib static-openssl}/lib/libcrypto.a" \
          --replace-fail "{SRCDIR}/darwin/arm64/lib/libcbor.a" "${lib.getLib static-libcbor}/lib/libcbor.a" \
          --replace-fail "/opt/homebrew/opt/libfido2/include" "${lib.getLib libfido2.dev}/include" \
          --replace-fail "/opt/homebrew/opt/openssl@1.1/include" "${lib.getLib static-openssl.dev}/include -I${lib.getLib hidapi}/include" \
          --replace-fail "''$" ""

        cat fido2_static_arm64.go
      ''
    );
  # subPackages = [ "cmd/fido2" ];
  tags = [ "libfido2" ];

  buildInputs = [ libfido2 libfido2.dev hidapi static-openssl static-openssl.dev static-libcbor ];
  propagatedBuildInputs = buildInputs;
  # modRoot = "./cmd";
  CGO_ENABLED = 0;

  # buildPhase = ''
  #   (rm -rf build && mkdir build && cd build && cmake ..) && make -C build
  #   mv build $out
  # '';

  testPhase = ''
    FIDO2_EXAMPLES=1 go test -v -run ExampleDeviceLocations
    FIDO2_EXAMPLES=1 go test -v -run ExampleDevice_Assertion
    FIDO2_EXAMPLES=1 go test -v -run ExampleDevice_Credentials
    FIDO2_EXAMPLES=1 go test -v -run ExampleDevice_BioList
  '';


  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "libfido2 bindings for golang";
    homepage = "https://github.com/keys-pub/go-libfido2";
    changelog = "https://github.com/keys-pub/go-libfido2/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ multivac61 ];
  };
}
