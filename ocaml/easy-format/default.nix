{ buildDunePackage }:

buildDunePackage rec {
  pname = "easy-format";
  version = "1.3.2+500";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/easy-format/archive/4568bfa1887146ab6ce41a48c9e00c8c1329c6e4.tar.gz;
    sha256 = "1f8pkbcz6y2mjr89k3kr5zimn4s1vvs14c0m3lzd4dwxs5vlz9g9";
  };
}
