{ fetchFromGitHub, buildDunePackage, httpun-types, angstrom, faraday }:

buildDunePackage {
  inherit (httpun-types) version src;
  pname = "httpun";
  propagatedBuildInputs = [ angstrom faraday httpun-types ];
}
