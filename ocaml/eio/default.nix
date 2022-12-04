{ buildDunePackage
, bigstringaf
, cstruct
, lwt-dllist
, optint
, psq
, fmt
, hmap
, astring
, mtime
}:

buildDunePackage {
  pname = "eio";
  version = "0.6";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/eio/archive/e2e94d71.tar.gz;
    sha256 = "1rhw7qj4rmf2iy93pf6mmv1jcfx8s2c0rmxd14apnb70pmw2cshs";
  };

  propagatedBuildInputs = [
    bigstringaf
    cstruct
    lwt-dllist
    optint
    psq
    fmt
    hmap
    astring
    mtime
  ];
}
