{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "markup";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "markup.ml";
    rev = version;
    sha256 = "13zcrwzjmifniv3bvjbkd2ah8wwa3ld75bxh1d8hrzdvfxzh9szn";
  };

  propagatedBuildInputs = [ uutf uchar ];
}
