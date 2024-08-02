{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, libfido2
, hidapi
, openssl
, libcbor
, darwin
, pkgs
, makeWrapper
, ...
}:

let
  static-openssl = openssl.override { static = true; };
  static-libcbor = libcbor.override { static = true; };
in
buildGoModule rec {
  pname = "age-plugin-fido2-hmac";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "olastor";
    repo = "age-plugin-fido2-hmac";
    rev = "v${version}";
    hash = "sha256-P2gNOZeuODWEb/puFe6EA1wW3pc0xgM567qe4FKbFXg=";
  };

  vendorHash = "sha256-h4/tyq9oZt41IfRJmmsLHUpJiPJ7YuFu59ccM7jHsFo=";

  tags = [ "libfido2" "webassets_embed" ];

  ldflags = [ "-s" "-w" ];

  # CGO_ENABLED = 0;

  # Clipboard support on X11 and Wayland
  nativeBuildInputs = [ makeWrapper ];
  # buildPhase = '' go build ./cmd/... '';

  postConfigure =
    (
      lib.optionalString stdenv.isDarwin ''
        substituteInPlace \
          vendor/github.com/keys-pub/go-libfido2/fido2_static_arm64.go \
          --replace-fail "/opt/homebrew/opt/libfido2/lib/libfido2.a" "${lib.getLib libfido2}/lib/libfido2.a" \
          --replace-fail "/opt/homebrew/opt/openssl@3/lib/libcrypto.a" "${lib.getLib static-openssl}/lib/libcrypto.a" \
          --replace-fail "/darwin/arm64/lib/libcbor.a" "${lib.getLib static-libcbor}/lib/libcbor.a" \
          --replace-fail "/opt/homebrew/opt/libfido2/include" "${lib.getLib libfido2.dev}/include" \
          --replace-fail "/opt/homebrew/opt/openssl@3/include" "${lib.getLib static-openssl.dev}/include -I${lib.getLib hidapi}/include" \
          --replace-fail "SRCDIR" "" \
          --replace-fail "''$" "" \
          --replace-fail "{}" ""

        cat vendor/github.com/keys-pub/go-libfido2/fido2_static_arm64.go
      ''
    );

  makeFlags = [
    "INSTALL=install"
    "PREFIX=$(out)"
    "VERBOSE=1"
  ];

  buildInputs = [ libfido2 hidapi ];
  extraBuildInputs = [ libfido2 hidapi ];
  propagatedBuildInputs = [
    libfido2
    hidapi
    static-libcbor
    static-openssl
  ] ++ lib.optional stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
    IOKit
    CoreFoundation
    darwin.cctools
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    darwin.apple_sdk.frameworks.CoreServices
    darwin.developer_cmds
    darwin.DarwinTools
  ]);

  meta = with lib; {
    description = "Age plugin to encrypt files with fido2 tokens using the hmac-secret extension and non-discoverable credentials";
    homepage = "https://github.com/olastor/age-plugin-fido2-hmac/";
    license = licenses.mit;
    maintainers = with maintainers; [ matthewcroughan ];
    mainProgram = "age-plugin-fido2-hmac";
  };
}
