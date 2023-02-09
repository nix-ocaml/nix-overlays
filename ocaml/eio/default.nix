{ buildDunePackage
, fetchFromGitHub
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
  version = "0.8.1";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "eio";
    rev = "v0.8.1";
    sha256 = "sha256-nzgp17e2IXh8VA5tnUGvdMRPbmqJXU/aPomItXiJCQs=";
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
