{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/909297dd811fcd03bf8ce54affd7da21ad31c067.tar.gz;
    sha256 = "0h5jfnrxqfg9jk49l8zq6g551nnm0qh29mnza1cjm4jb7vbsj54n";
  };
}
