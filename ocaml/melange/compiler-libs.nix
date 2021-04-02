{ ocamlPackages }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/eefcbe8.tar.gz;
    sha256 = "18w7w7kgpky0662g9q7bsdw06rnddpynmlsp6n7cfdccw37y7sxd";
  };

  propagatedBuildInputs = [ menhir ];
}
