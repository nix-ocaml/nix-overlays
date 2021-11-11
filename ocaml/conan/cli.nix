{ buildDunePackage, conan, conan-database, conan-unix, dune-site }:

buildDunePackage {
  inherit (conan) version src;
  pname = "conan-cli";
  propagatedBuildInputs = [ conan conan-database conan-unix dune-site ];
}
