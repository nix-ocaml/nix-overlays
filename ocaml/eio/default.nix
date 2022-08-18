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
  version = "0.4";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/eio/archive/e4413913.tar.gz;
    sha256 = "1vviih4wcg0phsd88l13r7ys9jginpzqy7fg0154vjqxwqi3hzl6";
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
    # crowbar
    mtime
    # alcotest
  ];
}
