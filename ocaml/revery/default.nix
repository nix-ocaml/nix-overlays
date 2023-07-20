{ lib
, buildDunePackage
, fetchFromGitHub
, dune-configurator
, pkg-config
, reason
, lru
, uchar
, ppx_deriving
, brisk-reconciler
, lwt_ppx
, ppx_optcomp
, uutf
, uucp
, rebez
, bos
, charInfo_width
, reason-sdl2
, reason-skia
, reason-harfbuzz
, rench
, timber
}:

let
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

in

buildDunePackage {
  pname = "Revery";
  version = "0.0.0";
  # TODO: check if a patch can avoid disabling this
  # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wstrict-overflow
  hardeningDisable = [ "strictoverflow" ];
  inherit (reason-sdl2) src;
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
