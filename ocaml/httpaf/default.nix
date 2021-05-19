{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/559019829b7ed267a5b4b86aed1e7d7795214bcd.tar.gz;
    sha256 = "1v4h9m485i3gfy9xdgz94sm31jbhi53c7n9ry7q615a6ih78vfnb";
  };
}
