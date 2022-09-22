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
    url = https://github.com/ocaml-multicore/eio/archive/97248d9.tar.gz;
    sha256 = "1hivj3m94zwcnjd29lgsnnmwf881zara98n53ml4cldlpd7gqvhd";
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
