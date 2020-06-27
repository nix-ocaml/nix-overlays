{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "yuscii";

  version = "0.3.0";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/yuscii/releases/download/v${version}/yuscii-v${version}.tbz";
    sha256 = "1cbla1fw8ygcmid9v220bk9ki9n0v3wk0yc84rrm852xaznqg3gg";
  };
}
