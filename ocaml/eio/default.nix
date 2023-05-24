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
    rev = "a40753560607c77ca89b5e0575ccac0e834b6d94";
    hash = "sha256-0EnL0j+fUOBx/i18iDMFFiBtBC8lxxN17DOHxfDCc68=";
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
