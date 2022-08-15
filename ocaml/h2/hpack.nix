{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/releases/download/0.9.0/h2-0.9.0.tbz;
    sha256 = "0phbyjbk6n95ikq72j6687b9knaghli5x049dk8fg6inkf2d227f";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
