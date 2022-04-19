{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/f89da4a.tar.gz;
    sha256 = "1rs3025ljckmf80v2cwkwfl3594wn08l6q11n3yqd0m8hvdwh123";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
