{ buildDunePackage
, pkg-config
, reason-sdl2
, reason
, dune-configurator
, harfbuzz
, lib
, libcxx
, stdenv
, darwin
}:

buildDunePackage {
  pname = "reason-harfbuzz";
  version = "0.0.0";
  inherit (reason-sdl2) src;

  buildInputs = [ dune-configurator ] ++
    lib.optionals stdenv.isDarwin
      (with darwin.apple_sdk.frameworks; [ Foundation AppKit ]);
  nativeBuildInputs = [
    reason
    pkg-config
  ];
  HARFBUZZ_INCLUDE_PATH = "${harfbuzz.dev}/include/harfbuzz";
  HARFBUZZ_LIB_PATH = ''${harfbuzz}/lib'';
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
}
