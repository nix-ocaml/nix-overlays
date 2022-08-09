{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/893ca40760.tar.gz;
    sha256 = "0mw6clix5jaq9m4ipi5026l7s2ha4nn0kczag5c9pn9v7wsva6lx";
  };
}
