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
  version = "0.5";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/eio/archive/c3431a07.tar.gz;
    sha256 = "12nniw0zsbwx7fyq5hb4ba6llwwc5jvi3i51ilaqb68mgjm093az";
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
