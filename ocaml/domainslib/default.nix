{ buildDunePackage, lockfree }:

buildDunePackage {
  pname = "domainslib";
  version = "0.5.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domainslib/archive/a9c705a.tar.gz;
    sha256 = "0kwlmiap8g5slwqz4bml3z4mjbsssi4v71aam85j5w309gqin4mq";
  };

  propagatedBuildInputs = [ lockfree ];
}
