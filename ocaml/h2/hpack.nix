{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/3f85e31.tar.gz;
    sha256 = "1ddp5qq2w8ln1lkrbly99dpykcacnrk6cpf25mabrsc0l71x29hc";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
