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
    url = https://github.com/ocaml-multicore/eio/archive/5c1eae4.tar.gz;
    sha256 = "1r0x6xvimik827r04pqf9f02zf345pc9w5wjs0bpcq6rdrhsp69k";
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
