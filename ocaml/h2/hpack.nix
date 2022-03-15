{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/ea8c9af.tar.gz;
    sha256 = "1zfhkz35c6q2q82d65v14pvz4m5gcdzpwiyjimp6nn2ky1r8l3cb";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
