{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4-dev";
  src = builtins.fetchurl {
    url = https://github.com/LexiFi/landmarks/archive/ea90c65.tar.gz;
    sha256 = "0bvjr4c018k8xh8irc6yldc5qw6vi0vdpg4mv104wkmvzgysd5xf";
  };

  propagatedBuildInputs = [ ppxlib ];
}
