{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "pecu";

  version = "0.4";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/pecu/releases/download/v${version}/pecu-v${version}.tbz";
    sha256 = "07mw7k81368hnv3z6j1gc85xfykh8yv5vmv21g7aqmsjg0xwxlvp";
  };
}
