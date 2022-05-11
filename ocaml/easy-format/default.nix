{ buildDunePackage }:

buildDunePackage {
  pname = "easy-format";
  version = "1.3.3";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/easy-format/releases/download/1.3.3/easy-format-1.3.3.tbz;
    sha256 = "05n4mm1yz33h9gw811ivjw7x4m26lpmf7kns9lza4v6227lwmz7a";
  };
}
