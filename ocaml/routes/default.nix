{ stdenv, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.8.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/routes/archive/0241c337649c2a6f9aa1f5fb05a1ae9a92262d56.tar.gz;
    sha256 = "0y9dvn3wsb784h8304pr1ng0ajqcfl8zknvvr1lnbxvx1q7szjc7";
  };
}
