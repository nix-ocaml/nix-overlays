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
    url = https://github.com/ocaml-multicore/eio/releases/download/v0.5/eio-0.5.tbz;
    sha256 = "1l2ga5jqrkvpix8fallsjpg5z9rjz4vj2a0lh1jl5kqdvyl59cnf";
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
