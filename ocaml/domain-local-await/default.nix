{ buildDunePackage }:

buildDunePackage {
  pname = "domain-local-await";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domain-local-await/releases/download/0.2.0/domain-local-await-0.2.0.tbz;
    sha256 = "0fjwqylxd7dqw1r4aykf8c18sn27ycdqsg3mbrdzn677inq8jc6q";
  };
}
