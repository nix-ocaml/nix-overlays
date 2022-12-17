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
    url = https://github.com/ocaml-multicore/eio/archive/56ea1cd6.tar.gz;
    sha256 = "05mxc0x18gphjk8cl0w4b4y90fwqsllw4knn3yz4s74lvly0x0ji";
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
