{ buildDunePackage
, ctypes
, darwin
, dune-configurator
, esy-skia
, freetype
, libiconv
, libjpeg
, pkg-config
, reason
, reason-sdl2
, SDL2
}:

buildDunePackage {
  pname = "reason-skia";
  version = "0.0.0";
  inherit (reason-sdl2) src;
  # the cptr function was removed from ctypes, so the value now needs to be
  # destructured to get to the pointer
  postPatch = ''
    substituteInPlace packages/reason-skia/src/Skia.re \
      --replace "module CI = Cstubs_internals;" \
                "module CI = { include Cstubs_internals; let cptr = (CPointer(a)) => a; };"
  '';

  nativeBuildInputs = [ reason pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = with darwin.apple_sdk.frameworks; [
    AppKit
    Cocoa
    ForceFeedback
    libiconv
    reason-sdl2
    ctypes
  ];
  SDL2_INCLUDE_PATH = "${SDL2.dev}/include";
  SDL2_LIB_PATH = "${SDL2.override { withStatic = true; }}/lib";
  SKIA_INCLUDE_PATH = "${esy-skia}/include/c";
  SKIA_LIB_PATH = "${esy-skia}/out/Release";
  JPEG_LIB_PATH = "${(libjpeg.override { enableStatic = true; }).out}/lib";
  FREETYPE2_LIB_PATH = "${freetype}/lib";
}
