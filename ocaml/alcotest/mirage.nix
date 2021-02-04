{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (alcotest) version src;
  pname = "alcotest-mirage";
  propagatedBuildInputs = [ alcotest lwt logs mirage-clock duration ];
}
