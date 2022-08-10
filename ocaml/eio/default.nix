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
    url = https://github.com/ocaml-multicore/eio/releases/download/v0.4/eio-0.4.tbz;
    sha256 = "1w2x6ljd81f4ikp1axjw8qrbn96f9fd40n0jwxr756pzdgjn6ibp";
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
