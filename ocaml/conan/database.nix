{ buildDunePackage, conan }:

buildDunePackage {
  inherit (conan) version src;
  pname = "conan-database";
  propagatedBuildInputs = [ conan ];
}
