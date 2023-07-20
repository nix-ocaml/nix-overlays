{ buildDunePackage
, fetchFromGitHub
, SDL2
, ctypes
, findlib
, reason
, dune-configurator
, darwin
, libiconv
, lib
, stdenv
, libcxx

}:

buildDunePackage rec {
  pname = "reason-sdl2";
  version = "0.0.0";
  src = fetchFromGitHub {
    owner = "revery-ui";
    repo = "revery";
    # master branch as of Aug 27, 2021
    rev = "141f70f69d6abd69674b46d805a783411b38cd79";
    sha256 = "sha256-3AGdf0vcFoxcmGUHCUcmjb+VCpp2WDYmkv9Tp7VJqsw=";
  };
  postPatch = ''
    substituteInPlace packages/reason-sdl2/src/sdl2_wrapper.cpp \
      --replace "case SDL_PANEVENT:" "/* case SDL_PANEVENT:" \
      --replace "case SDL_DROPTEXT:" "*/ case SDL_DROPTEXT:" \
      --replace "case SDL_WINDOWEVENT_FULLSCREEN:" "/* case SDL_WINDOWEVENT_FULLSCREEN:" \
      --replace "case SDL_WINDOWEVENT_RESTORED:" "*/ case SDL_WINDOWEVENT_RESTORED:" \
      --replace "hash_variant" "caml_hash_variant"
  '';
  buildInputs = [
    dune-configurator
    # SDL2
    # SDL2.dev
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.ForceFeedback
    libiconv
  ];
  nativeBuildInputs = [
    reason
    # SDL2
    # SDL2.dev
    findlib
  ];
  propagatedBuildInputs = [
    SDL2
    SDL2.dev
    ctypes
    # findlib
  ];
  SDL2_LIB_PATH = ''${(SDL2.override { withStatic = true; }).out}/lib'';
  SDL2_INCLUDE_PATH = "${SDL2.dev}/include";
  cur__root = "${src}";
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
}
