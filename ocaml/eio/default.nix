{ buildDunePackage
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
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/eio/archive/a70865e8f.tar.gz;
    sha256 = "0mv2zj7v2mym1r8qb9gk8hhns1c5vjprjq3mqmcyiasv0hf4k852";
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
