{ ocamlPackages }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/74916dd.tar.gz;
    sha256 = "0gkp2x86ky91lxw834a0byqg6wcdcr9jamifl7z2kg1j7yv6sscp";
  };

  propagatedBuildInputs = [ menhir ];
}
