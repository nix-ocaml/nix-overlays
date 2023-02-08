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
  version = "0.8-dev";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "eio";
    rev = "b83534e400a08a929257114a740979e1e0295566";
    sha256 = "sha256-msOVVJp7J9oNw78gHv++PggvGFUY2QQ/ESNAxKpEu/4=";
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
