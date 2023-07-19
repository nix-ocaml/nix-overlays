{ lib
, buildDunePackage
, fetchFromGitHub
, fetchgit
, ocaml
, stdenv
, gn
, ninja
, libjpeg
, libpng
, zlib
, python3
, expat
, darwin
, dune-configurator
, SDL2
, libcxx
  # TODO: try to remove?
, findlib
  # TODO: try to remove?
, pkg-config
, libiconv
, reason
, ctypes
, lru
, uchar
, harfbuzz
, freetype
, flex
, fpath
, fmt
, logs
, re
, ppx_deriving
, brisk-reconciler
, lwt_ppx
, ppx_optcomp
, uutf
, uucp
, rebez
, bos
, charInfo_width
}:

let
  reverySrc = fetchFromGitHub {
    owner = "revery-ui";
    repo = "revery";
    # master branch as of Aug 27, 2021
    rev = "141f70f69d6abd69674b46d805a783411b38cd79";
    sha256 = "sha256-3AGdf0vcFoxcmGUHCUcmjb+VCpp2WDYmkv9Tp7VJqsw=";
  };
  angle2 = fetchgit {
    url = "https://chromium.googlesource.com/angle/angle.git";
    rev = "47b3db22be33213eea4ad58f2453ee1088324ceb";
    sha256 = "sha256-ZF5wDOqh3cRfQGwOMay//4aWh9dBWk/cLmUsx+Ab2vw=";
  };
  piex = fetchgit {
    url = "https://android.googlesource.com/platform/external/piex.git";
    rev = "bb217acdca1cc0c16b704669dd6f91a1b509c406";
    sha256 = "05ipmag6k55jmidbyvg5mkqm69zfw03gfkqhi9jnjlmlbg31y412";
  };
  esy-skia = stdenv.mkDerivation rec {
    name = "skia";
    patches = [
      ./patches/0002-esy-skia-use-libtool.patch
    ];
    src = fetchFromGitHub {
      owner = "revery-ui";
      repo = "esy-skia";
      rev = "29349b9279ed24a73ec41acd7082caea9bd8c04e";
      sha256 = "sha256-VyY1clAdTEZu0cFy/+Bw19OQ4lb55s4gIV/7TsFKdnk=";
    };
    nativeBuildInputs = [
      gn
      ninja
      libjpeg
      libpng
      zlib
      python3
      expat
      # TODO: add optional webp support
      #libwebp
      darwin.apple_sdk.frameworks.ApplicationServices
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.OpenGL
      # TODO handle ios, android
      #-framework CoreServices -framework CoreGraphics -framework CoreText -framework CoreFoundation
      stdenv.cc
      # needed to get libtool - TODO: double check this, add darwin flag, test on linux if ar is needed
      darwin.cctools
    ];

    preConfigure = ''
      mkdir -p third_party/externals
      ln -s ${angle2} third_party/externals/angle2
      ln -s ${piex} third_party/externals/piex
    '';
    #TODO: remove cc= ccx=
    #TODO: optional xcode_sysroot
    #TODO: built this based on feature flags, with sane defaults per os
    #TODO: enable more features
    configurePhase = ''
        runHook preConfigure
      gn gen out/Release --args='is_debug=false is_official_build=true skia_use_egl=false skia_use_dng_sdk=false skia_use_wuffs=false skia_enable_tools=false extra_asmflags=[] xcode_sysroot="${darwin.apple_sdk_11_0.MacOSX-SDK}" host_os="mac" skia_enable_gpu=true skia_use_metal=true skia_use_vulkan=false skia_use_angle=false skia_use_fontconfig=false skia_use_freetype=false skia_use_no_jpeg_encode=true skia_enable_pdf=false skia_use_sfntly=false skia_use_icu=false skia_use_libwebp=false skia_use_libpng=true esy_skia_enable_svg=true'
        runHook postConfigure
    '';
    buildPhase = ''
      runHook preBuild
      ninja -C out/Release skia
      runHook postBuild
    '';

    # TODO: these includes were taken from alperite and can probably be simplified to include everything
    installPhase = ''
      mkdir -p $out

      # Glob will match all subdirs.
      shopt -s globstar

      cp -r --parents -t $out/ \
        include/codec \
        include/config \
        include/core \
        include/effects \
        include/gpu \
        include/private \
        include/utils \
        include/c \
        out/Release/*.a \
        src/gpu/**/*.h \
        third_party/externals/angle2/include \
        third_party/skcms/**/*.h
    '';
  };
  reason-sdl2 = buildDunePackage rec {
    pname = "reason-sdl2";
    version = "0.0.0";
    src = reverySrc;
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
      SDL2
      SDL2.dev
      findlib
      darwin.apple_sdk.frameworks.Cocoa
      darwin.apple_sdk.frameworks.ForceFeedback
      libiconv
    ];
    nativeBuildInputs = [
      reason
      SDL2
      SDL2.dev
      findlib
    ];
    propagatedBuildInputs = [
      SDL2
      SDL2.dev
      ctypes
      findlib
    ];
    SDL2_LIB_PATH = ''${(SDL2.override { withStatic = true; }).out}/lib'';
    SDL2_INCLUDE_PATH = "${SDL2.dev}/include";
    cur__root = "${src}";
    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  };
  # This change is allows configuring initial capacity of the cache
  # https://github.com/pqwy/lru/pull/8/commits/f646450cc5a165bbb39121d5a456dd3f5ad4dba5
  lruOverride = lru.overrideAttrs (_: super: {
    patches = [ ./patches/0001-lru-initial-size.patch ];
  });
  omd = buildDunePackage {
    pname = "omd";
    version = "0.0.0";
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "omd";
      rev = "1535e3c684323f370f3f80bce2564863140de6ba";
      sha256 = "sha256-Tu60WdHvVq24m6QMJTe3B55gfNjtoxomW/Q3MT6//n4=";
    };
    propagatedBuildInputs = [
      uchar
    ];
  };
  reason-harfbuzz = buildDunePackage {
    pname = "reason-harfbuzz";
    version = "0.0.0";
    src = reverySrc;
    buildInputs = [
      pkg-config
      dune-configurator
      stdenv
      findlib
    ];
    nativeBuildInputs = [
      reason
      pkg-config
      findlib
    ];
    HARFBUZZ_INCLUDE_PATH = "${harfbuzz.dev}/include/harfbuzz";
    HARFBUZZ_LIB_PATH = ''${harfbuzz}/lib'';
    env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-I${lib.getDev libcxx}/include/c++/v1";
  };
  reason-skia = buildDunePackage {
    pname = "reason-skia";
    version = "0.0.0";
    src = reverySrc;
    postPatch = ''
      # the cptr function was removed from ctypes, so the value now needs to be
      # destructured to get to the pointer
      substituteInPlace packages/reason-skia/src/Skia.re \
        --replace "module CI = Cstubs_internals;" \
                  "module CI = { include Cstubs_internals; let cptr = (CPointer(a)) => a; };"
      #substituteInPlace packages/reason-skia/src/wrapped/bindings/SkiaWrappedBindings.re \
      #packages/reason-skia/src/Skia.re \
      #  --replace "module CI = Cstubs_internals;" \
      #            "module CI = { include Cstubs_internals; let cptr = (CPointer(a)) => a; };"
    '';
    buildInputs = [
      dune-configurator
    ];
    nativeBuildInputs = [
      reason
      pkg-config
    ];
    propagatedBuildInputs = [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.Cocoa
      darwin.apple_sdk.frameworks.ForceFeedback
      libiconv
      findlib
      reason-sdl2
      ctypes
    ];
    SDL2_INCLUDE_PATH = "${SDL2.dev}/include";
    SDL2_LIB_PATH = ''${(SDL2.override { withStatic = true; }).out}/lib'';
    SKIA_INCLUDE_PATH = "${esy-skia}/include/c";
    SKIA_LIB_PATH = "${esy-skia}/out/Release";
    JPEG_LIB_PATH = "${(libjpeg.override{enableStatic = true;}).out}/lib";
    FREETYPE2_LIB_PATH = "${freetype}/lib";
  };
  rench = buildDunePackage {
    pname = "Rench";
    version = "0.0.0";
    src = fetchFromGitHub {
      owner = "revery-ui";
      repo = "rench";
      rev = "df44c5277ed1d3ccfa959f2623705baefd26ad99";
      sha256 = "sha256-cGBYBIxVIuhbvkGxM1lAN0j5m5Fiqlc3O1xyt9OFP4U=";
    };
    nativeBuildInputs = [
      reason
    ];
    propagatedBuildInputs = [
      flex
      fpath
    ];
  };
  timber = buildDunePackage {
    pname = "timber";
    version = "0.0.0";
    src = fetchFromGitHub {
      owner = "revery-ui";
      repo = "timber";
      rev = "f4c40ee5d7cb93801160340ac4ac9c974ce01b66";
      sha256 = "sha256-tk/2Of0R4WzjM7Fiv0mXVSbmiRHXMtppLgBcgvX4p9s=";
    };
    nativeBuildInputs = [
      reason
    ];
    propagatedBuildInputs = [
      fmt
      logs
      re
    ];
  };
in
buildDunePackage {
  pname = "Revery";
  version = "0.0.0";
  # TODO: check if a patch can avoid disabling this 
  # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wstrict-overflow
  hardeningDisable = [ "strictoverflow" ];
  src = reverySrc;
  preBuild = ''
    substituteInPlace packages/zed/src/dune --replace "bytes" ""
    # This supresses a warning from the use of CAMLparam2, where caml__frame is unused:
    #   dialog.c:32:5: error: unused variable 'caml__frame' [-Werror,-Wunused-variable]
    # TODO: try to suppress this for the single file
    substituteInPlace src/Native/dune --replace "-Werror" "-Werror\n   -Wno-unused-variable"
  '';
  buildInputs = [
    dune-configurator
  ];
  nativeBuildInputs = [
    reason
    pkg-config
  ];
  propagatedBuildInputs = [
    ppx_deriving
    brisk-reconciler
    lwt_ppx
    ppx_optcomp
    uutf
    uucp
    reason-skia
    omd
    rebez
    bos
    reason-harfbuzz
    charInfo_width
    lruOverride
    rench
    timber
  ];
}
