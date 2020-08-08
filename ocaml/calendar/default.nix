{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "calendar";
  version = "3.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/calendar/archive/26a8c3d7667d49698fb5c7d1d464924aa7476a1d.tar.gz;
    sha256 = "1r5p5jqv275mcq8qa402wl9k300iy5mv0lyiad9g5cwcs7yzvxac";
  };

  checkInputs = [ alcotest ];

  propagatedBuildInputs = [ re ];
}
