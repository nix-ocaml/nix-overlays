{ lib, buildDunePackage, fetchFromGitHub, stringext, angstrom }:

buildDunePackage {
  pname = "uri";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "mirage";
    repo = "ocaml-uri";
    rev = "v4.4.0";
    sha256 = "sha256-KCZIYMQi+/uIBF2hynSpefe9zI4aBvXAy3WrKw8GUfg=";
  };

  propagatedBuildInputs = [ stringext angstrom ];

  meta = {
    description =
      "RFC3986 URI parsing library for OCaml";
    license = lib.licenses.isc;
  };
}
