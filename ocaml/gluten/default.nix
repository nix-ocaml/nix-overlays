{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "gluten";
  version = "0.2.2-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/c5eada58.tar.gz;
    sha256 = "1a6dcrwpycrncjxhr76vaz57hxjhnnk7sps5k3xjl7948p9qy14d";
  };

  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
