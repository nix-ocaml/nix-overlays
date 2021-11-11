{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "gluten-async";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-async
    gluten
  ];
}
