{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/90bb3cb.tar.gz;
    sha256 = "0wwvlh3hi0277vfnrvsfvam1bs2pr0a6m17yg764ybbw6n7rip9b";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
