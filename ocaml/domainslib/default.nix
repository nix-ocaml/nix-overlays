{ buildDunePackage }:

buildDunePackage {
  pname = "domainslib";
  version = "0.5.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domainslib/archive/00f016cbb226e539c038f4700d354296d6c140ba.tar.gz;
    sha256 = "0qblng694npdisyb4q0ka1rxi78hj6fd229lw1azkgpfbyy036c7";
  };
}
