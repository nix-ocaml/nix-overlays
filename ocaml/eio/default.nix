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
  version = "0.9";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "eio";
    rev = "v0.9";
    hash = "sha256-/pKnGT2mPqe5reVc5/AdbNxFkK8vpSfZ5Kdg37PfU6c=";
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
