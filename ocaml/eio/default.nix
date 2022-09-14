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
    url = https://github.com/ocaml-multicore/eio/archive/995e2559.tar.gz;
    sha256 = "0pil8j048a52sjq8l15nsjd5il74hgmbyjzdbs0fz5pcs8rn9hk9";
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
