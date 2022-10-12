{ buildDunePackage
, bigstringaf
, cstruct
, lwt-dllist
, optint
, psq
, fmt
, hmap
, astring
  # crowbar
, mtime
}:

buildDunePackage {
  pname = "eio";
  version = "0.6";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/eio/releases/download/v0.6/eio-0.6.tbz;
    sha256 = "0f7gndh96s2r9r5jdpj67xmmwkd9dkpbxz8zm08psgfxaaiyxlza";
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
