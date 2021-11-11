{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-mongodb/archive/535ae1b003b9c8a3844b92a78d2123881f2d404b.tar.gz;
    sha256 = "01243z8ibmns7lqm0mx7as7xpql3c81qyqx63ylgjzpaq85i32gk";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
