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
    url = https://github.com/ocaml-multicore/eio/archive/51ad9c3.tar.gz;
    sha256 = "0h8rpk451y915sggsibhns54p2z6gp1yd23b7c9bcaqb01qmzd60";
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
