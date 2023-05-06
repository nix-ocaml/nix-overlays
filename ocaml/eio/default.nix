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
    rev = "b5b5de777f9efcea0e4082c0c856681e53331c83";
    hash = "sha256-3POYL7/aOHV846cHRUcORNVSUZxtL+daLQH4yQ3+D70=";
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
