{ buildDunePackage, conan }:

buildDunePackage {
  inherit (conan) version src;
  pname = "conan-unix";
  propagatedBuildInputs = [ conan ];
}
