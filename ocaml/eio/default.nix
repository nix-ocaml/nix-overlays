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
  version = "0.6";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "eio";
    rev = "56ea1cd6";
    sha256 = "sha256-/CLfCo0RcdDLDauEfGi3wJ8Y4hzOW8X99xBkjqeHGLU=";
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
