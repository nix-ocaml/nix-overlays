{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "yojson";
  version = "1.7.0";
  src = builtins.fetchurl {
    url = "https://github.com/ocaml-community/yojson/releases/download/${version}/yojson-${version}.tbz";
    sha256 = "1iich6323npvvs8r50lkr4pxxqm9mf6w67cnid7jg1j1g5gwcvv5";
  };
  propagatedNativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ easy-format biniou ];
}
