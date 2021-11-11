{ buildDunePackage }:

buildDunePackage {
  pname = "dataloader";
  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-dataloader/archive/c2e6d7d057d4453b36511a5d293e9ab502755484.tar.gz;
    sha256 = "1w4wnwx854358wymdd26xkccyl3lql4j3k3lbr57bd7rv5xpplwq";
  };
}
