{ buildDunePackage, alcotest, re }:

buildDunePackage {
  pname = "calendar";
  version = "3.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-community/calendar/archive/refs/tags/v3.0.0.tar.gz;
    sha256 = "17kfa0gfrv0d5f6zksg7yah8ly5pwyzws483mwvqiwfkc8bx617a";
  };

  checkInputs = [ alcotest ];

  propagatedBuildInputs = [ re ];
}
