{ buildDunePackage
, fetchFromGitHub
, bigstringaf
, domain-local-await
, cstruct
, lwt-dllist
, optint
, psq
, fmt
, hmap
, mtime
}:

buildDunePackage {
  pname = "eio";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "eio";
    rev = "v0.10";
    hash = "sha256-93gCe3/gRccQ8+KAEn4NWYr/VtSx8m/ZNYiYZX77a7Y=";
  };

  propagatedBuildInputs = [
    bigstringaf
    cstruct
    domain-local-await
    fmt
    hmap
    lwt-dllist
    mtime
    optint
    psq
  ];
}
